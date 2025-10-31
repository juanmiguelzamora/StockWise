"""
AI Assistant Views for StockWise Inventory Management

This module provides the main endpoint for the AI assistant that answers
inventory-related queries using an LLM (Ollama).

Flow:
1. Request validation (rate limiting, API key, input sanitization)
2. Query type detection (product, category, trend, or general inventory)
3. Data gathering from database
4. LLM prompt construction with facts and context
5. LLM response parsing and validation
6. Fallback handling for edge cases
"""

from django.shortcuts import render
from django.http import JsonResponse, HttpResponseBadRequest
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_http_methods
from django.core.exceptions import ValidationError
import json
import logging

# Import from our modular components
from .utils import (
    get_client_ip,
    rate_limit_check,
    validate_api_key,
    sanitize_input,
    error_response,
    safe_fallback,
    DEFAULT_MODEL,
)
from .services import (
    detect_query_type,
    find_best_product_match,
    get_category_insights,
    get_total_inventory_overview,
    get_product_facts,
    get_trend_facts,
)
from .prompts import build_prompt
from .llm import call_ollama

logger = logging.getLogger(__name__)


# ============================================================================
# MAIN VIEW ENDPOINT
# ============================================================================

@csrf_exempt
@require_http_methods(["GET", "POST"])
def ask_llm(request):
    """
    Main AI assistant endpoint for inventory queries.
    
    REQUEST FLOW:
    1. Security checks (API key validation, rate limiting)
    2. Input sanitization and parsing
    3. Query type detection (product/category/trend/general)
    4. Data gathering from database
    5. LLM prompt construction and API call
    6. Response parsing and validation
    7. Fallback handling if needed
    
    GET: Renders HTML form
    POST: Processes query and returns JSON or HTML response
    
    Security features:
    - Rate limiting (10 requests per minute per IP)
    - API key authentication (optional)
    - Input sanitization (HTML escaping, length limits)
    - Prompt injection guardrails
    
    Supported query types:
    - Product stock: "How much coffee do we have?"
    - Category analytics: "Show me all beverages"
    - Trend predictions: "What will sell for Christmas?"
    - General inventory: "What's my total stock?"
    """
    client_ip = get_client_ip(request)
    
    # POST request security checks
    if request.method == "POST":
        if not validate_api_key(request):
            return error_response(request, "Unauthorized", code=401, friendly_message="Invalid API key.")
        if not rate_limit_check(request):
            logger.warning(f"Rate limit exceeded for IP: {client_ip}")
            return error_response(request, "Too many requests", code=429, friendly_message="Please wait a minute and try again.")

    logger.info(f"AI query from IP: {client_ip.rsplit('.', 1)[0]}.X | Method: {request.method}")

    # GET request: Render HTML form
    if request.method == "GET":
        return render(request, "ai_assistant/ask_llm.html", {"answer": None})

    # POST request: Process query
    if request.method == "POST":
        wants_json = request.headers.get("Content-Type", "").startswith("application/json")

        # Parse and sanitize input
        try:
            if wants_json:
                body = json.loads(request.body.decode("utf-8"))
                user_query = sanitize_input(body.get("query", ""))
            else:
                user_query = sanitize_input(request.POST.get("query", ""))
        except (json.JSONDecodeError, ValidationError) as e:
            logger.error(f"Input error: {e}")
            return error_response(request, "Invalid input", code=400)

        if not user_query:
            return error_response(request, "Missing query", code=400)

        # Detect query type to determine data gathering strategy
        is_category_query, is_trend_query, is_general_stock = detect_query_type(user_query)
        logger.info(f"Query type detection: category={is_category_query}, trend={is_trend_query}, general={is_general_stock} | Query: '{user_query[:50]}'")

        supplier_info = None
        forecast = None
        found = False

        # BRANCH 1: General inventory overview
        if is_general_stock:
            facts = get_total_inventory_overview()
            found = True
            logger.info(f"General inventory query detected: {user_query[:50]}...")
        
        # BRANCH 2: Trend prediction query
        elif is_trend_query:
            facts = get_trend_facts(user_query)
            found = True  # Trends always processed by LLM
        
        # BRANCH 3: Product or category query
        else:
            # Find matching product from database
            product = find_best_product_match(user_query)
            logger.info(f"MATCH DEBUG | Query: '{user_query}' | Product found: {product.name if product else 'NONE'} (ID: {product.id if product else 'N/A'}) | Has inventory: {getattr(product, 'inventory_id', None) is not None if product else False}")
            
            # Sub-branch 3A: Single product query
            if product and not is_category_query:
                facts, supplier_info, forecast = get_product_facts(product)
                found = True
            
            # Sub-branch 3B: Category query
            elif is_category_query and product and getattr(product, 'category', None):
                facts = get_category_insights(product.category.name)
                found = True
            
            # Sub-branch 3C: No match found
            else:
                facts = {
                    "item": user_query,
                    "current_stock": 0,
                    "average_daily_sales": 0.0
                }
                found = False

        # RESPONSE GENERATION
        if is_general_stock and found:
            # General inventory: Use facts directly (no LLM needed)
            # Add human-readable summary and recommendation
            if 'summary' not in facts:
                facts['summary'] = f"{facts['total_products']} products with {facts['total_stock']:,} total units. "
                if facts['out_of_stock_items'] > 0:
                    facts['summary'] += f"{facts['low_stock_items']} items need restocking, {facts['out_of_stock_items']} are out of stock."
                elif facts['low_stock_items'] > 0:
                    facts['summary'] += f"{facts['low_stock_items']} items need restocking."
                else:
                    facts['summary'] += "All items adequately stocked."
            
            if 'recommendation' not in facts:
                if facts['out_of_stock_items'] > 0:
                    facts['recommendation'] = f"{facts['low_stock_items']} items low, {facts['out_of_stock_items']} out of stock—urgent restocking required."
                elif facts['low_stock_items'] > 0:
                    facts['recommendation'] = f"{facts['low_stock_items']} items running low—review and reorder soon."
                else:
                    facts['recommendation'] = "Inventory levels healthy—no immediate action needed."
            
            parsed = facts
        else:
            # Build LLM prompt with gathered facts
            prompt = build_prompt(facts, user_query, supplier_info, forecast)

            # Call LLM only if we have valid data (trend or product/category found)
            # Otherwise use fallback to avoid hallucinations
            if is_trend_query or found:
                parsed = call_ollama(DEFAULT_MODEL, prompt, facts) or safe_fallback(facts, found, is_category=is_category_query, is_trend=is_trend_query)
            else:
                # Item not found - skip LLM, use direct fallback
                parsed = safe_fallback(facts, found=False, is_category=is_category_query, is_trend=False)

        logger.info(f"Query: {user_query[:50]}... | Response keys: {list(parsed.keys())} | IP: {client_ip.rsplit('.', 1)[0]}.X | Found: {found} | Trend: {is_trend_query} | Parsed stock: {parsed.get('current_stock', 'N/A')}, avg sales: {parsed.get('average_daily_sales', 'N/A')}")

        return JsonResponse(parsed) if wants_json else render(
            request, "ai_assistant/ask_llm.html", {"answer": parsed}
        )

    return HttpResponseBadRequest({"error": "Method not allowed"})
