"""Quick test for trend query API."""
import requests
import json

API_URL = "http://localhost:8000/api/ai/ask/"

# Test trend query
query = "Predict Christmas trends for clothing"
print(f"\n📤 Testing query: '{query}'")
print("="*60)

try:
    response = requests.post(
        API_URL,
        json={"query": query},
        timeout=60
    )
    
    if response.status_code == 200:
        data = response.json()
        print("\n✅ Response received!")
        print(json.dumps(data, indent=2))
        
        if 'predicted_trends' in data:
            print("\n🎉 SUCCESS! Trend response detected!")
            print(f"Found {len(data['predicted_trends'])} predicted trends")
        else:
            print("\n⚠️  WARNING: Response doesn't contain 'predicted_trends'")
            print(f"Response keys: {list(data.keys())}")
    else:
        print(f"\n❌ Request failed: {response.status_code}")
        print(response.text[:500])
        
except requests.exceptions.ConnectionError:
    print("\n❌ Server not running!")
    print("Start with: python manage.py runserver")
except Exception as e:
    print(f"\n❌ Error: {e}")
