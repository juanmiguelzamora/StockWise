"""
Test script to verify trend queries are working correctly.
This checks if the AI assistant properly references the product_app_trend table.

Usage:
    python test_trend_query.py
"""

import os
import django

# Setup Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from product_app.models import Trend, Category
from django.utils import timezone
from datetime import timedelta

def check_trend_data():
    """Check if trend data exists in database."""
    print("\n" + "="*60)
    print("CHECKING TREND DATA IN DATABASE")
    print("="*60)
    
    total_trends = Trend.objects.all().count()
    print(f"\n✅ Total trends in database: {total_trends}")
    
    if total_trends == 0:
        print("\n⚠️  WARNING: No trend data found!")
        print("   Run the scraper first: curl -X POST http://localhost:8000/api/trends/scrape/")
        return False
    
    # Check by season
    seasons = ["Christmas", "Summer", "Winter", "Spring"]
    for season in seasons:
        count = Trend.objects.filter(season__icontains=season).count()
        if count > 0:
            print(f"   - {season}: {count} trends")
    
    # Check recent trends (last 30 days)
    thirty_days_ago = timezone.now() - timedelta(days=30)
    recent_count = Trend.objects.filter(scraped_at__gte=thirty_days_ago).count()
    print(f"\n✅ Recent trends (last 30 days): {recent_count}")
    
    if recent_count == 0:
        print("\n⚠️  WARNING: No recent trends found!")
        print("   Trend data may be outdated. Run scraper to get fresh data.")
    
    # Show sample trends
    print("\n📊 Sample Trends:")
    sample_trends = Trend.objects.order_by('-hot_score')[:3]
    for t in sample_trends:
        keywords_preview = t.keywords[:60] + "..." if len(t.keywords) > 60 else t.keywords
        category_name = t.category.name if t.category else "No category"
        print(f"   - {t.season}: {keywords_preview}")
        print(f"     Score: {t.hot_score:.2f} | Category: {category_name}")
    
    return True

def test_keyword_splitting():
    """Test that keywords can be split correctly."""
    print("\n" + "="*60)
    print("TESTING KEYWORD SPLITTING")
    print("="*60)
    
    sample_trend = Trend.objects.first()
    if not sample_trend:
        print("\n❌ No trends to test with")
        return False
    
    print(f"\n📝 Sample trend: {sample_trend.season}")
    print(f"   Raw keywords: {sample_trend.keywords}")
    
    # Split keywords like the AI assistant does
    keywords_list = [kw.strip() for kw in sample_trend.keywords.split(',') if kw.strip()]
    print(f"\n✅ Split into {len(keywords_list)} individual keywords:")
    for i, kw in enumerate(keywords_list[:5], 1):
        print(f"   {i}. {kw}")
    
    # Show how it would be formatted for LLM
    print(f"\n📤 Format for LLM:")
    hot_trends = []
    for keyword in keywords_list[:3]:
        hot_trends.append({
            "keyword": keyword,
            "hot_score": sample_trend.hot_score,
            "category": sample_trend.category.name if sample_trend.category else "General"
        })
    
    import json
    print(json.dumps(hot_trends, indent=2))
    
    return True

def test_ai_query():
    """Test actual AI query (requires server running)."""
    print("\n" + "="*60)
    print("TESTING AI QUERY")
    print("="*60)
    
    try:
        import requests
        import json
        
        # Check if server is running
        try:
            requests.get("http://localhost:8000/", timeout=2)
        except requests.exceptions.RequestException:
            print("\n⚠️  Server not running. Start with: python manage.py runserver")
            return False
        
        # Test trend query
        print("\n📤 Sending query: 'Predict Christmas trends for clothing'")
        response = requests.post(
            "http://localhost:8000/api/ai/ask/",
            json={"query": "Predict Christmas trends for clothing"},
            timeout=30
        )
        
        if response.status_code == 200:
            data = response.json()
            print("\n✅ Response received!")
            
            if 'predicted_trends' in data:
                print(f"\n📊 Predicted Trends ({len(data['predicted_trends'])} items):")
                for i, trend in enumerate(data['predicted_trends'][:5], 1):
                    print(f"   {i}. {trend.get('keyword', 'N/A')} (Score: {trend.get('hot_score', 0)})")
                    print(f"      💡 {trend.get('suggestion', 'No suggestion')}")
                
                if 'overall_prediction' in data:
                    print(f"\n🔮 Overall Prediction:")
                    print(f"   {data['overall_prediction']}")
                
                return True
            else:
                print("\n⚠️  Response doesn't contain 'predicted_trends'")
                print(f"   Response keys: {list(data.keys())}")
                print(f"   Full response: {json.dumps(data, indent=2)}")
                return False
        else:
            print(f"\n❌ Request failed with status {response.status_code}")
            print(f"   Response: {response.text[:200]}")
            return False
            
    except ImportError:
        print("\n⚠️  'requests' library not installed. Skipping API test.")
        print("   Install with: pip install requests")
        return None
    except Exception as e:
        print(f"\n❌ Error testing AI query: {e}")
        return False

def main():
    """Run all tests."""
    print("\n" + "="*60)
    print("TREND QUERY TEST SUITE")
    print("="*60)
    
    results = []
    
    # Test 1: Check database
    results.append(("Database Check", check_trend_data()))
    
    # Test 2: Keyword splitting
    results.append(("Keyword Splitting", test_keyword_splitting()))
    
    # Test 3: AI query (optional)
    api_result = test_ai_query()
    if api_result is not None:
        results.append(("AI Query Test", api_result))
    
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
        print("\n🎉 All tests passed! Trend queries are working correctly.")
        print("\n💡 Try these queries in your frontend:")
        print("   - 'Predict Christmas trends for clothing'")
        print("   - 'What are the summer fashion trends?'")
        print("   - 'Show me trending items'")
    else:
        print(f"\n⚠️  {total - passed} test(s) failed. Check the output above.")

if __name__ == "__main__":
    main()
