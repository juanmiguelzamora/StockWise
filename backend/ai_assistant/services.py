"""
Business logic services for AI Assistant

Provides:
- Query type detection (product, category, trend, general)
- Product matching and search
- Data aggregation and insights
- Inventory analytics
"""

import difflib
import logging
from typing import Dict, Any, Optional, Tuple
from datetime import timedelta

from django.db.models import Sum, Avg, Q
from django.utils import timezone
from django.core.cache import cache

from product_app.models import Product, Inventory, Category, SalesHistory, Trend

from .utils import (
    FUZZY_CUTOFF,
    MAX_FUZZY_SEARCH,
    LOW_STOCK_THRESHOLD,
    RECENT_TREND_DAYS,
    DEFAULT_INVENTORY_TYPE,
)

logger = logging.getLogger(__name__)


# ============================================================================
# QUERY TYPE DETECTION
# ============================================================================

def detect_query_type(user_query: str) -> Tuple[bool, bool, bool]:
    """
    Detect the type of inventory query from user input.
    
    Classification logic:
    1. General stock: Phrases like "total stock", "all inventory"
    2. Trend query: Keywords like "predict", "trend", "forecast", seasonal terms
    3. Category query: Keywords like "category", "all in", "total"
    
    Uses combination of:
    - Exact phrase matching for general stock
    - Keyword presence detection
    - Fuzzy string similarity (difflib) for category matching
    
    Returns:
        Tuple[bool, bool, bool]: (is_category, is_trend, is_general_stock)
    """
    query_lower = user_query.lower()
    inventory_intents = ["stock", "inventory", "item", "product", "reorder"]
    category_intents = ["category", "all in", "total", "group"]
    # PRIORITY: Strong trend indicators should be checked first
    strong_trend_intents = ["predict", "trend", "forecast", "prediction"]
    season_intents = ["season", "holiday", "christmas", "winter", "summer", "spring", "fall", "autumn"]
    general_stock_intents = ["total stock", "all stock", "overall stock", "stock in general", "entire inventory", "whole inventory", "all inventory"]

    def has_intent(intents: list) -> bool:
        return any(word in query_lower for word in intents)

    # Check for general stock query first (most specific)
    is_general_stock = any(phrase in query_lower for phrase in general_stock_intents)
    
    # PRIORITY: Check for strong trend indicators (predict, trend, forecast)
    has_strong_trend = has_intent(strong_trend_intents)
    has_season = has_intent(season_intents)
    
    # Trend query if it has strong trend words OR (season words AND not just asking about stock)
    is_trend = has_strong_trend or (has_season and not any(word in query_lower for word in ["stock for", "inventory for", "how much", "how many"]))
    
    cat_score = max(difflib.SequenceMatcher(None, query_lower, w).ratio() for w in category_intents)

    return (has_intent(category_intents) or cat_score > 0.6), is_trend, is_general_stock


# ============================================================================
# PRODUCT MATCHING & SEARCH
# ============================================================================

def find_best_product_match(query: str) -> Optional[Product]:
    """
    Find the best matching product for a user query using multi-tier search.
    
    Search strategy (in order of priority):
    1. Direct match: Exact substring match on product name or SKU
    2. PostgreSQL full-text search: Trigram similarity with ranking
    3. Difflib fuzzy match: Fallback for non-PostgreSQL databases
    4. Category fallback: Match by category name if no product found
    
    Returns:
        Product object if match found, None otherwise
    """
    if not query:
        return None

    base_qs = Product.objects.all()
    logger.debug(f"MATCH DEBUG | Total products available: {base_qs.count()}")

    # TIER 1: Direct substring match (fastest, most accurate)
    q_obj = Q(name__icontains=query) | Q(sku__icontains=query)
    match_qs = base_qs.filter(q_obj)
    logger.debug(f"MATCH DEBUG | Direct match count for '{query}': {match_qs.count()}")
    if match_qs.exists():
        match = match_qs.first()
        logger.debug(f"MATCH DEBUG | Direct match selected: {match.name} (ID: {match.id})")
        return match

    # TIER 2: PostgreSQL full-text search with trigram similarity
    try:
        from django.contrib.postgres.search import SearchVector, SearchQuery, SearchRank
        vector = SearchVector('name', weight='A') + SearchVector('sku', weight='B')
        query_vec = SearchQuery(query)
        # SearchRank for annotation; order by rank for relevance
        fuzzy_match = base_qs.annotate(
            rank=SearchRank(vector, query_vec)
        ).filter(rank__gt=FUZZY_CUTOFF).order_by('-rank').first()
        if fuzzy_match:
            logger.debug(f"MATCH DEBUG | Trigram fuzzy match: {fuzzy_match.name} (rank: {fuzzy_match.rank})")
            return fuzzy_match
    except (ImportError, AttributeError) as e:
        logger.debug(f"PostgreSQL search failed ({e}); falling back to difflib")

    # TIER 3: Difflib fuzzy matching (works on any database)
    recent_values = base_qs.values_list("name", "sku")[:MAX_FUZZY_SEARCH]
    all_refs = [ref.lower() for name, sku in recent_values for ref in (name, sku) if ref]
    if not all_refs:
        logger.debug(f"MATCH DEBUG | No references for difflib")
        return None

    # Find closest string match using sequence matching
    best = difflib.get_close_matches(query.lower(), all_refs, n=1, cutoff=FUZZY_CUTOFF)
    if best:
        match = best[0].title()
        ret = base_qs.filter(Q(name__iexact=match) | Q(sku__iexact=match)).first()
        logger.debug(f"MATCH DEBUG | Difflib match attempted '{match}' -> selected: {ret.name if ret else 'None'}")
        return ret

    # TIER 4: Category fallback (when query might be a category name)
    categories = list(Category.objects.values_list("name", flat=True)[:20])
    cat_matches = difflib.get_close_matches(query.lower(), [c.lower() for c in categories], n=1, cutoff=0.4)
    if cat_matches:
        category = Category.objects.filter(name__iexact=cat_matches[0].title()).first()
        ret = category.products.first() if category else None
        logger.debug(f"MATCH DEBUG | Category fallback '{cat_matches[0]}' -> product: {ret.name if ret else 'None'}")
        return ret

    logger.debug(f"MATCH DEBUG | No match found for '{query}'")
    return None


# ============================================================================
# DATA AGGREGATION & INSIGHTS
# ============================================================================

def get_category_insights(category_name: str) -> Dict[str, Any]:
    """
    Get aggregated insights for a specific product category.
    
    Calculates:
    - Total stock across all products in category
    - Average daily sales (last 30 days)
    - Count of low-stock items
    - Total product count
    
    Uses ORM aggregates for performance (no Python loops).
    """
    category = Category.objects.filter(name__iexact=category_name).first()
    if not category:
        return {"error": "Category not found"}

    thirty_days_ago = timezone.now().date() - timedelta(days=RECENT_TREND_DAYS)
    products = category.products.all()

    total_stock = Inventory.objects.filter(product__in=products).aggregate(total=Sum('total_stock'))['total'] or 0
    avg_sales = SalesHistory.objects.filter(
        product__in=products, date__gte=thirty_days_ago
    ).aggregate(avg=Avg('units_sold'))['avg'] or 0.0
    low_stock_count = Inventory.objects.filter(
        product__in=products, total_stock__lt=LOW_STOCK_THRESHOLD
    ).count()

    return {
        "category": category_name,
        "total_stock": total_stock,
        "average_daily_sales": float(avg_sales),
        "low_stock_items": low_stock_count,
        "product_count": products.count(),
    }


def get_total_inventory_overview() -> Dict[str, Any]:
    """
    Get comprehensive overview of entire inventory system.
    
    Provides high-level metrics:
    - Total stock units across all products
    - Total number of products
    - Average daily sales (last 30 days)
    - Low stock and out-of-stock counts
    - Top 5 categories by stock volume
    - Restock recommendation flag
    
    Used for general inventory queries like "what's my total stock?"
    """
    total_stock = Inventory.objects.aggregate(total=Sum('total_stock'))['total'] or 0
    total_products = Product.objects.count()
    
    thirty_days_ago = timezone.now().date() - timedelta(days=RECENT_TREND_DAYS)
    avg_sales = SalesHistory.objects.filter(
        date__gte=thirty_days_ago
    ).aggregate(avg=Avg('units_sold'))['avg'] or 0.0
    
    low_stock_count = Inventory.objects.filter(
        total_stock__lt=LOW_STOCK_THRESHOLD
    ).count()
    
    out_of_stock_count = Inventory.objects.filter(total_stock=0).count()
    
    # Get top categories by stock
    top_categories = Inventory.objects.values(
        'product__category__name'
    ).annotate(
        category_stock=Sum('total_stock')
    ).order_by('-category_stock')[:5]
    
    return {
        "query_type": "general_inventory",
        "total_stock": total_stock,
        "total_products": total_products,
        "average_daily_sales": float(avg_sales),
        "low_stock_items": low_stock_count,
        "out_of_stock_items": out_of_stock_count,
        "top_categories": [
            {"category": cat['product__category__name'] or "Uncategorized", "stock": cat['category_stock']}
            for cat in top_categories
        ],
        "restock_needed": low_stock_count > 0 or out_of_stock_count > 0,
    }


def get_product_facts(product: Product) -> Tuple[Dict[str, Any], Dict[str, Any] | None, Dict[str, Any] | None]:
    """
    Get facts, supplier info, and forecast for a specific product.
    
    Returns:
        Tuple containing:
        - facts: Dict with item name, current_stock, average_daily_sales
        - supplier_info: Dict with supplier name and email (or None)
        - forecast: Dict with projected_days (or None)
    """
    avg_sales = 0.0
    current_stock = 0
    inv_exists = True
    
    try:
        # Fetch inventory data (handles Decimal types and None values)
        inv = Inventory.objects.get(product=product)
        logger.debug(f"INVENTORY DEBUG | Raw fields for {product.name} (ID {product.id}): total_stock={inv.total_stock}, avg={inv.average_daily_sales}, type_avg={type(inv.average_daily_sales)}")
        
        # Convert to Python native types
        avg_sales = float(inv.average_daily_sales) if inv.average_daily_sales is not None else 0.0
        current_stock = int(inv.total_stock) if inv.total_stock is not None else 0
    except Inventory.DoesNotExist:
        # New product with no inventory record yet
        logger.debug(f"INVENTORY DEBUG | No Inventory record for {product.name} (ID {product.id}) - treating as new item with 0 stock/sales")
        inv_exists = False
    except (AttributeError, ValueError, TypeError) as e:
        # Handle data type errors gracefully
        logger.warning(f"INVENTORY DEBUG | Error accessing inventory fields for {product.name} (ID {product.id}): {e} - defaulting to 0")
        inv_exists = False

    # Calculate forecast and gather supplier info
    forecast = {"projected_days": round(current_stock / max(avg_sales, 0.01), 1)} if avg_sales > 0 or current_stock > 0 else None
    supplier_info = {"name": product.supplier.name, "email": product.supplier.contact_email} if hasattr(product, 'supplier') and product.supplier else None

    # Build facts dict
    facts = {
        "item": product.name,
        "current_stock": current_stock,
        "average_daily_sales": avg_sales,
    }
    
    logger.debug(f"FACTS DEBUG | For {product.name} (ID {product.id}): stock={current_stock}, avg_sales={avg_sales}, inv_exists={inv_exists}")
    
    return facts, supplier_info, forecast


def get_trend_facts(user_query: str) -> Dict[str, Any]:
    """
    Get trend prediction facts based on seasonal keywords in query.
    
    Fetches hot trends from database, processes keywords, and caches results.
    
    Returns:
        Dict with category, stock info, and hot_trends data
    """
    facts = {"category": DEFAULT_INVENTORY_TYPE, "total_stock": 0, "average_daily_sales": 0.0, "product_count": 0}
    
    # Detect season from query for targeted trend data
    season_match = next((word for word in ["Christmas", "Summer", "Winter"] if word.lower() in user_query.lower()), "General")
    cache_key = f"hot_trends_{DEFAULT_INVENTORY_TYPE}_{season_match.lower()}"
    hot_trends = cache.get(cache_key)
    
    if not hot_trends:
        hot_trends_qs = Trend.objects.filter(
            season__icontains=season_match,
            scraped_at__gte=timezone.now() - timedelta(days=RECENT_TREND_DAYS)
        ).order_by('-hot_score')[:10]  # Get more to split keywords

        if hot_trends_qs.exists():
            # Process keywords from trend data
            # Trends may have comma-separated keywords or single phrases
            hot_trends = []
            for t in hot_trends_qs:
                # Split comma-separated keywords
                if ',' in t.keywords:
                    keywords_list = [kw.strip() for kw in t.keywords.split(',') if kw.strip()]
                else:
                    # Single keyword/phrase
                    keywords_list = [t.keywords.strip()]
                
                # Extract up to 2 keywords per trend entry
                for keyword in keywords_list[:2]:
                    hot_trends.append({
                        "keyword": keyword,
                        "hot_score": t.hot_score,
                        "category": t.category.name if t.category else "General"
                    })
            
            # Prioritize highest scoring trends (top 5)
            hot_trends = sorted(hot_trends, key=lambda x: x['hot_score'], reverse=True)[:5]
            
            trends_data = {
                "hot_trends": hot_trends,
                "prediction_hint": f"Prioritize high hot_score for {season_match} season. Higher scores indicate rising demand."
            }
            cache.set(cache_key, hot_trends, 3600)
            facts.update(trends_data)
            logger.info(f"Trend query detected: {season_match} | Found {len(hot_trends)} trend keywords from {hot_trends_qs.count()} trend entries")
        else:
            facts["trends_note"] = f"No recent {season_match} trends found. Use general advice: Monitor seasonal spikes in relevant items."
            logger.warning(f"No trends found for season: {season_match} in last {RECENT_TREND_DAYS} days")
    else:
        # Use cached trend data
        logger.info(f"Using cached trends for {season_match}: {len(hot_trends)} keywords")
        facts.update({"hot_trends": hot_trends, "prediction_hint": f"Prioritize high hot_score for {season_match} season."})
    
    return facts
