"""
LLM interaction module for AI Assistant

Provides:
- Ollama API calls
- JSON response parsing and validation
- Response safeguards and validation
"""

import json
import re
import requests
import logging
from typing import Dict, Any, Optional
from django.conf import settings

from .utils import OLLAMA_API

logger = logging.getLogger(__name__)


def _clean_llm_response(raw: str) -> str:
    """
    Clean common LLM artifacts from response before JSON parsing.
    
    Removes:
    - Conversational prefixes (e.g., "Here is the JSON:", "employee:")
    - Markdown code blocks
    - Text after the JSON object ends
    """
    # Remove markdown code blocks
    raw = re.sub(r'```json\s*', '', raw)
    raw = re.sub(r'```\s*', '', raw)
    
    # Remove specific conversational patterns
    raw = re.sub(r'employee:\s*', '', raw, flags=re.IGNORECASE)
    raw = re.sub(r'assistant:\s*', '', raw, flags=re.IGNORECASE)
    raw = re.sub(r'(?:Here is|Here\'s)\s+(?:the|a)\s+(?:JSON|response):\s*', '', raw, flags=re.IGNORECASE)
    
    # Find the first { and last } to extract just the JSON portion
    start = raw.find('{')
    if start == -1:
        return raw
    
    # Find the matching closing brace by counting
    brace_count = 0
    end = -1
    for i in range(start, len(raw)):
        if raw[i] == '{':
            brace_count += 1
        elif raw[i] == '}':
            brace_count -= 1
            if brace_count == 0:
                end = i + 1
                break
    
    if end != -1:
        return raw[start:end].strip()
    
    return raw.strip()


def call_ollama(model_name: str, prompt: str, facts: Dict[str, Any]) -> Optional[Dict[str, Any]]:
    """
    Call Ollama LLM API and extract structured JSON response.
    
    Process:
    1. Send prompt to Ollama API with specified model
    2. Extract JSON from response using regex patterns
    3. Validate JSON structure against expected schemas
    4. Apply safeguards to replace null values with fact data
    5. Return parsed and validated response
    
    Handles multiple JSON extraction strategies:
    - Regex pattern matching (tries all matches in reverse order)
    - Substring extraction as fallback
    
    Returns None if API call fails or no valid JSON found.
    """
    try:
        # Prepare API payload with system message if supported
        payload = {
            "model": model_name,
            "prompt": prompt,
            "stream": False,
            "format": "json",  # Request JSON format output
            "options": {
                "temperature": 0.1,  # Lower temperature for more consistent output
            }
        }
        
        logger.info(f"Calling Ollama API with model: {model_name}")
        
        response = requests.post(
            OLLAMA_API,
            json=payload,
            timeout=getattr(settings, "OLLAMA_TIMEOUT", 120),
        )
        response.raise_for_status()
        raw = response.json().get("response", "").strip()
        if not raw:
            return None

        # PREPROCESSING: Clean common LLM artifacts
        # Remove common conversational prefixes/suffixes
        original_raw = raw
        raw = _clean_llm_response(raw)
        if raw != original_raw:
            logger.debug(f"Cleaned LLM response. Original length: {len(original_raw)}, Cleaned length: {len(raw)}")

        # STRATEGY 1: Regex extraction - find all JSON-like patterns
        # More aggressive pattern that handles nested objects and arrays
        json_pattern = r'\{(?:[^{}]|(?:\{[^{}]*\}))*\}'
        matches = list(re.finditer(json_pattern, raw, re.DOTALL))
        
        # If no matches with complex pattern, try simpler extraction
        if not matches:
            # Try to find JSON by looking for opening brace and extracting until valid close
            start_idx = raw.find('{')
            if start_idx != -1:
                # Count braces to find matching closing brace
                brace_count = 0
                for i, char in enumerate(raw[start_idx:], start=start_idx):
                    if char == '{':
                        brace_count += 1
                    elif char == '}':
                        brace_count -= 1
                        if brace_count == 0:
                            candidate = raw[start_idx:i+1]
                            try:
                                parsed = json.loads(candidate)
                                if _validate_schema(parsed):
                                    parsed = _apply_safeguards(parsed, facts)
                                    logger.info(f"Successfully parsed JSON using brace counting")
                                    return parsed
                            except json.JSONDecodeError:
                                pass
                            break
            
            logger.warning(f"No JSON pattern found in raw: {raw[:200]}")
            return None

        # Try matches in reverse order (last match is usually most complete)
        for match in reversed(matches):
            candidate = match.group(0)
            try:
                parsed = json.loads(candidate)
                
                # VALIDATION: Check if JSON matches expected schema
                if _validate_schema(parsed):
                    # SAFEGUARD: Replace LLM null values with actual facts
                    parsed = _apply_safeguards(parsed, facts)
                    logger.info(f"Successfully parsed JSON from candidate: {candidate[:100]}...")
                    return parsed
            except (json.JSONDecodeError, ValueError) as e:
                logger.debug(f"Failed to parse candidate: {candidate[:100]}... | Error: {e}")
                continue

        # STRATEGY 2: Substring extraction fallback
        # If regex failed, try simple brace matching
        start, end = raw.find("{"), raw.rfind("}")
        if start != -1 and end != -1:
            candidate = raw[start:end + 1]
            try:
                parsed = json.loads(candidate)
                # Apply validation and safeguards
                if _validate_schema(parsed):
                    parsed = _apply_safeguards(parsed, facts)
                    return parsed
            except json.JSONDecodeError:
                pass

        logger.warning(f"All JSON candidates failed for raw: {raw[:200]}")
    except Exception as e:
        logger.error(f"Ollama API call failed: {e} | Prompt preview: {prompt[:100]}")
    return None


def _validate_schema(parsed: Dict[str, Any]) -> bool:
    """
    Validate that parsed JSON matches one of the expected schemas.
    
    Checks for:
    - Trend query schema (predicted_trends list)
    - General inventory schema (query_type and required fields)
    - Item/category schema (required fields based on type)
    - Data integrity (no corrupted values with conversational text)
    
    Returns True if valid, False otherwise.
    """
    # Check for corrupted values (conversational text in data)
    if _has_corrupted_values(parsed):
        logger.warning("Rejected JSON due to corrupted values (conversational text detected)")
        return False
    
    if 'predicted_trends' in parsed:
        # Trend query schema
        if not isinstance(parsed.get('predicted_trends'), list):
            return False
        # Validate each trend has required fields
        for trend in parsed['predicted_trends']:
            if not isinstance(trend, dict) or 'keyword' not in trend or 'hot_score' not in trend:
                return False
        return True
    
    elif 'query_type' in parsed and parsed['query_type'] == 'general_inventory':
        # General inventory schema
        required = ['total_stock', 'total_products', 'average_daily_sales', 'low_stock_items', 'restock_needed']
        return all(k in parsed for k in required)
    
    elif 'item' in parsed or 'category' in parsed:
        # Item or category schema
        if 'category' in parsed:
            required = ['total_stock', 'average_daily_sales', 'restock_needed', 'recommendation', 'low_stock_items']
        else:
            required = ['current_stock', 'average_daily_sales', 'restock_needed', 'recommendation']
        return all(k in parsed for k in required)
    
    return False


def _has_corrupted_values(data: Any, depth: int = 0) -> bool:
    """
    Recursively check if JSON contains corrupted values (conversational text).
    
    Looks for phrases like "I'm sorry", "employee:", "Thank you", etc.
    """
    if depth > 10:  # Prevent infinite recursion
        return False
    
    corruption_patterns = [
        "i'm sorry",
        "i am sorry", 
        "employee:",
        "assistant:",
        "thank you",
        "i don't have access",
        "as an ai",
        "i apologize",
        "let me",
        "here is",
        "here's",
    ]
    
    if isinstance(data, str):
        data_lower = data.lower()
        return any(pattern in data_lower for pattern in corruption_patterns)
    elif isinstance(data, dict):
        return any(_has_corrupted_values(v, depth + 1) for v in data.values())
    elif isinstance(data, list):
        return any(_has_corrupted_values(item, depth + 1) for item in data)
    
    return False


def _apply_safeguards(parsed: Dict[str, Any], facts: Dict[str, Any]) -> Dict[str, Any]:
    """
    Apply safeguards to replace LLM null values with actual facts.
    
    Ensures that critical numeric fields are never null by falling back
    to the original facts data.
    
    Returns the safeguarded parsed response.
    """
    if 'item' in parsed:
        if parsed.get('current_stock') is None:
            parsed['current_stock'] = facts.get('current_stock', 0)
        if parsed.get('average_daily_sales') is None:
            parsed['average_daily_sales'] = facts.get('average_daily_sales', 0.0)
    
    elif 'category' in parsed:
        if parsed.get('total_stock') is None:
            parsed['total_stock'] = facts.get('total_stock', 0)
        if parsed.get('average_daily_sales') is None:
            parsed['average_daily_sales'] = facts.get('average_daily_sales', 0.0)
        if parsed.get('low_stock_items') is None:
            parsed['low_stock_items'] = facts.get('low_stock_items', 0)
    
    elif 'query_type' in parsed and parsed['query_type'] == 'general_inventory':
        # Safeguard for general inventory
        if parsed.get('total_stock') is None:
            parsed['total_stock'] = facts.get('total_stock', 0)
        if parsed.get('total_products') is None:
            parsed['total_products'] = facts.get('total_products', 0)
        if parsed.get('average_daily_sales') is None:
            parsed['average_daily_sales'] = facts.get('average_daily_sales', 0.0)
        if parsed.get('low_stock_items') is None:
            parsed['low_stock_items'] = facts.get('low_stock_items', 0)
        if parsed.get('out_of_stock_items') is None:
            parsed['out_of_stock_items'] = facts.get('out_of_stock_items', 0)
    
    return parsed
