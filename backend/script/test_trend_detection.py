"""
Simple test for trend query detection logic.
Tests the _detect_query_type function without Django dependencies.
"""

def detect_query_type(user_query: str):
    """Simplified version of the detection logic."""
    query_lower = user_query.lower()
    
    # Strong trend indicators
    strong_trend_intents = ["predict", "trend", "forecast", "prediction"]
    season_intents = ["season", "holiday", "christmas", "winter", "summer", "spring", "fall", "autumn"]
    general_stock_intents = ["total stock", "all stock", "overall stock", "stock in general", "entire inventory", "whole inventory", "all inventory"]
    category_intents = ["category", "all in", "total", "group"]
    
    def has_intent(intents: list) -> bool:
        return any(word in query_lower for word in intents)
    
    # Check for general stock query first
    is_general_stock = any(phrase in query_lower for phrase in general_stock_intents)
    
    # Check for strong trend indicators
    has_strong_trend = has_intent(strong_trend_intents)
    has_season = has_intent(season_intents)
    
    # Trend query if it has strong trend words OR (season words AND not just asking about stock)
    is_trend = has_strong_trend or (has_season and not any(word in query_lower for word in ["stock for", "inventory for", "how much", "how many"]))
    
    # Category detection
    is_category = has_intent(category_intents)
    
    return is_category, is_trend, is_general_stock

# Test cases
test_queries = [
    ("Predict Christmas trends for clothing", (False, True, False)),
    ("What are the summer fashion trends?", (False, True, False)),
    ("Show me trending items", (False, True, False)),
    ("What is the total stock?", (False, False, True)),
    ("How much stock for Fleece Hoodie?", (False, False, False)),
    ("Total stock in Women's Wear?", (False, False, True)),  # Has "total" but also "stock"
    ("Christmas stock for red sweaters", (False, False, False)),  # Has season but asking for stock
    ("Forecast winter clothing demand", (False, True, False)),
]

print("\n" + "="*70)
print("TREND DETECTION TEST")
print("="*70)

passed = 0
failed = 0

for query, expected in test_queries:
    result = detect_query_type(query)
    is_category, is_trend, is_general = result
    exp_category, exp_trend, exp_general = expected
    
    status = "✅" if result == expected else "❌"
    if result == expected:
        passed += 1
    else:
        failed += 1
    
    print(f"\n{status} Query: '{query}'")
    print(f"   Expected: category={exp_category}, trend={exp_trend}, general={exp_general}")
    print(f"   Got:      category={is_category}, trend={is_trend}, general={is_general}")

print("\n" + "="*70)
print(f"RESULTS: {passed}/{len(test_queries)} passed")
print("="*70)

if failed > 0:
    print(f"\n⚠️  {failed} test(s) failed")
else:
    print("\n🎉 All tests passed!")
