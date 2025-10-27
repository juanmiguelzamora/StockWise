"""
Test script for AI Assistant improvements.
Run this to verify the new features work correctly.

Usage:
    python test_ai_improvements.py
"""

import requests
import json

# Configuration
API_URL = "http://localhost:8000/api/ai/ask/"
HEADERS = {"Content-Type": "application/json"}

# Test cases
test_cases = [
    {
        "name": "General Inventory Query - Total Stock",
        "query": "What is the total stock?",
        "expected_keys": ["query_type", "total_stock", "total_products", "summary"]
    },
    {
        "name": "General Inventory Query - Overall Status",
        "query": "How is our overall inventory?",
        "expected_keys": ["query_type", "total_stock", "total_products", "summary"]
    },
    {
        "name": "General Inventory Query - All Stock",
        "query": "Show me stock in general",
        "expected_keys": ["query_type", "total_stock", "total_products", "summary"]
    },
    {
        "name": "Item Not Found",
        "query": "Do we have flying carpets?",
        "expected_keys": ["item", "current_stock", "recommendation"],
        "expected_values": {
            "current_stock": 0,
            "average_daily_sales": 0.0,
            "restock_needed": False
        }
    },
    {
        "name": "Specific Item Query",
        "query": "How much stock for Fleece Hoodie?",
        "expected_keys": ["item", "current_stock", "average_daily_sales", "recommendation"]
    },
    {
        "name": "Category Query",
        "query": "Total stock in Women's Wear?",
        "expected_keys": ["category", "total_stock", "low_stock_items"]
    },
    {
        "name": "Trend Query",
        "query": "Predict trends for Christmas",
        "expected_keys": ["predicted_trends", "overall_prediction"]
    }
]

def test_query(test_case):
    """Test a single query."""
    print(f"\n{'='*60}")
    print(f"Test: {test_case['name']}")
    print(f"Query: {test_case['query']}")
    print(f"{'='*60}")
    
    try:
        response = requests.post(
            API_URL,
            headers=HEADERS,
            json={"query": test_case["query"]},
            timeout=30
        )
        
        if response.status_code != 200:
            print(f"❌ FAILED: HTTP {response.status_code}")
            print(f"Response: {response.text}")
            return False
        
        data = response.json()
        print(f"✅ Response received")
        print(f"Response: {json.dumps(data, indent=2)}")
        
        # Check expected keys
        missing_keys = [key for key in test_case["expected_keys"] if key not in data]
        if missing_keys:
            print(f"⚠️  WARNING: Missing keys: {missing_keys}")
        else:
            print(f"✅ All expected keys present")
        
        # Check expected values
        if "expected_values" in test_case:
            for key, expected_value in test_case["expected_values"].items():
                actual_value = data.get(key)
                if actual_value != expected_value:
                    print(f"⚠️  WARNING: {key} = {actual_value}, expected {expected_value}")
                else:
                    print(f"✅ {key} matches expected value")
        
        # Validate no null values in critical fields
        critical_fields = ["current_stock", "average_daily_sales", "total_stock"]
        null_fields = [field for field in critical_fields if field in data and data[field] is None]
        if null_fields:
            print(f"❌ FAILED: Null values in critical fields: {null_fields}")
            return False
        
        return True
        
    except requests.exceptions.RequestException as e:
        print(f"❌ FAILED: Request error: {e}")
        return False
    except json.JSONDecodeError as e:
        print(f"❌ FAILED: Invalid JSON response: {e}")
        return False
    except Exception as e:
        print(f"❌ FAILED: Unexpected error: {e}")
        return False

def main():
    """Run all tests."""
    print("\n" + "="*60)
    print("AI ASSISTANT IMPROVEMENTS TEST SUITE")
    print("="*60)
    
    # Check if server is running
    try:
        response = requests.get("http://localhost:8000/", timeout=5)
        print("✅ Server is running")
    except requests.exceptions.RequestException:
        print("❌ Server is not running. Please start Django server:")
        print("   python manage.py runserver")
        return
    
    # Run tests
    results = []
    for test_case in test_cases:
        result = test_query(test_case)
        results.append((test_case["name"], result))
    
    # Summary
    print("\n" + "="*60)
    print("TEST SUMMARY")
    print("="*60)
    
    passed = sum(1 for _, result in results if result)
    total = len(results)
    
    for name, result in results:
        status = "✅ PASSED" if result else "❌ FAILED"
        print(f"{status}: {name}")
    
    print(f"\n{passed}/{total} tests passed")
    
    if passed == total:
        print("\n🎉 All tests passed! AI Assistant improvements are working correctly.")
    else:
        print(f"\n⚠️  {total - passed} test(s) failed. Please review the output above.")

if __name__ == "__main__":
    main()
