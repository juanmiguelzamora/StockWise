"""
Utility functions for AI Assistant

Provides:
- Security and validation functions (rate limiting, API key validation, input sanitization)
- Error response generation
- Configuration constants
"""

from django.http import JsonResponse, HttpResponse
from django.shortcuts import render
from django.conf import settings
from django.utils.html import escape
from django.core.exceptions import ValidationError
from typing import Dict, Any, Union
import time
import logging

logger = logging.getLogger(__name__)

# ============================================================================
# CONFIGURATION CONSTANTS
# ============================================================================

# LLM/Ollama settings
OLLAMA_API = getattr(settings, "OLLAMA_API", "http://localhost:11434/api/generate")
DEFAULT_MODEL = getattr(settings, "OLLAMA_MODEL", "stockwise-model")
DEFAULT_INVENTORY_TYPE = getattr(settings, "DEFAULT_TREND_CATEGORY", "General")

# Business logic thresholds
RECENT_SALES_DAYS = getattr(settings, "RECENT_SALES_DAYS", 90)
RECENT_TREND_DAYS = getattr(settings, "RECENT_TREND_DAYS", 30)
LOW_STOCK_THRESHOLD = getattr(settings, "LOW_STOCK_THRESHOLD", 10)

# Search/matching settings
FUZZY_CUTOFF = getattr(settings, "FUZZY_CUTOFF", 0.3)
MAX_FUZZY_SEARCH = getattr(settings, "MAX_FUZZY_SEARCH", 100)

# Security settings
API_KEY = getattr(settings, "AI_API_KEY", "")
RATE_LIMIT_WINDOW = 60  # Seconds
MAX_REQUESTS_PER_WINDOW = 10  # Per IP

# In-memory rate limiting storage
_request_times = {}  # IP -> list of timestamps


# ============================================================================
# SECURITY & VALIDATION FUNCTIONS
# ============================================================================

def get_client_ip(request) -> str:
    """Extract client IP address from request, handling proxies."""
    x_forwarded_for = request.META.get('HTTP_X_FORWARDED_FOR')
    if x_forwarded_for:
        return x_forwarded_for.split(',')[0].strip()
    return request.META.get('REMOTE_ADDR', '')


def rate_limit_check(request) -> bool:
    """
    Check if request is within rate limit window.
    
    Tracks requests per IP and enforces MAX_REQUESTS_PER_WINDOW limit.
    Returns True if request is allowed, False if rate limit exceeded.
    """
    ip = get_client_ip(request)
    now = time.time()
    
    # Initialize tracking for new IPs
    if ip not in _request_times:
        _request_times[ip] = []
    
    # Clean up old timestamps outside the window
    _request_times[ip] = [t for t in _request_times[ip] if now - t < RATE_LIMIT_WINDOW]
    
    # Check if limit exceeded
    if len(_request_times[ip]) >= MAX_REQUESTS_PER_WINDOW:
        return False
    
    # Record this request
    _request_times[ip].append(now)
    return True


def validate_api_key(request) -> bool:
    """
    Validate API key from request header.
    
    Checks X-API-KEY header against configured API_KEY.
    If no API_KEY is configured, all requests are allowed.
    """
    provided_key = request.headers.get('X-API-KEY', '')
    if not API_KEY or provided_key == API_KEY:
        return True
    logger.warning(f"Unauthorized API access from IP: {get_client_ip(request)}")
    return False


def sanitize_input(query: str) -> str:
    """
    Sanitize user input to prevent injection attacks.
    
    - Escapes HTML/JS characters
    - Enforces maximum length (500 chars)
    - Strips whitespace
    """
    if len(query) > 500:
        raise ValidationError("Query too long")
    return escape(query.strip())


def error_response(request, message: str, code: int = 400, details: Dict[str, Any] | None = None,
                   friendly_message: str | None = None) -> Union[JsonResponse, HttpResponse]:
    """
    Generate standardized error response.
    
    Returns JSON for API requests or renders HTML template for web requests.
    Includes both technical and user-friendly error messages.
    """
    error_payload = {
        "success": False,
        "error": {
            "message": message,
            "code": code,
            "friendly_message": friendly_message or "Something went wrong. Please try again."
        }
    }
    if details:
        error_payload["error"]["details"] = details

    if request.headers.get("Content-Type", "").startswith("application/json"):
        return JsonResponse(error_payload, status=code)
    return render(request, "ai_assistant/ask_llm.html", error_payload)


def safe_fallback(facts: Dict[str, Any], found: bool, is_category: bool = False, is_trend: bool = False) -> Dict[str, Any]:
    """
    Generate safe fallback response when LLM call fails or item not found.
    
    Applies business logic:
    - Calculates restock_needed based on days_left (< 3 days)
    - Handles zero sales and zero stock edge cases
    - Provides appropriate recommendations
    - Uses consistent key naming for items vs categories
    - Handles trend queries with proper trend schema
    
    Returns structured dict matching expected schema.
    """
    # Handle trend queries
    if is_trend:
        hot_trends = facts.get("hot_trends", [])
        if hot_trends:
            # Convert hot_trends to predicted_trends format
            predicted_trends = [
                {
                    "keyword": trend["keyword"],
                    "hot_score": trend["hot_score"],
                    "suggestion": f"Stock items related to {trend['keyword']}"
                }
                for trend in hot_trends
            ]
            return {
                "predicted_trends": predicted_trends,
                "restock_suggestions": [f"Consider stocking {t['keyword']}" for t in hot_trends[:3]],
                "overall_prediction": f"Trending items detected with high demand potential"
            }
        else:
            # No trend data available
            return {
                "predicted_trends": [],
                "restock_suggestions": ["Monitor seasonal trends and adjust inventory accordingly"],
                "overall_prediction": "No specific trend data available. Monitor market for emerging patterns."
            }
    
    # Handle regular item/category queries
    cs = int(facts.get("total_stock", facts.get("current_stock", 0)))
    ads = float(facts.get("average_daily_sales", 0.0))
    restock = found and ads > 0 and (cs / ads < 3)

    item_key = "category" if is_category else "item"
    item_val = facts.get("category", facts.get("item", "(unknown)"))

    if not found:
        rec = "Item not found in inventory. Please verify the product name."
        restock = False
    else:
        if cs == 0:
            rec = "Out of stock—reorder ASAP." if not is_category else "All out of stock—reorder category items."
            restock = True
        else:
            rec = (
                "Aggregate low stock—reorder from supplier." if is_category else
                ("Run out soon—reorder ASAP." if restock else "Stock sufficient.")
            )

    base_response = {
        item_key: item_val,
        "average_daily_sales": ads,
        "restock_needed": restock,
        "recommendation": rec,
    }
    if is_category:
        base_response["total_stock"] = cs
        base_response["low_stock_items"] = facts.get("low_stock_items", 0)
    else:
        base_response["current_stock"] = cs

    return base_response
