"""Test LLM directly with trend prompt."""
import requests
import json
import re

OLLAMA_API = "http://localhost:11434/api/generate"
MODEL = "stockwise-model"

# Simulate the trend facts that would be passed
facts = {
    "category": "General",
    "total_stock": 0,
    "average_daily_sales": 0.0,
    "product_count": 0,
    "hot_trends": [
        {
            "keyword": "Christmas Festive knit sweaters and cozy jumpers",
            "hot_score": 95.0,
            "category": "Clothing"
        },
        {
            "keyword": "The 11 Key Fall/Winter 2025 Fashion Trends",
            "hot_score": 91.9,
            "category": "Clothing"
        }
    ],
    "prediction_hint": "Prioritize high hot_score for Christmas season. Higher scores indicate rising demand."
}

# Build a simplified prompt
prompt = f"""You are an AI inventory assistant. Analyze the data and respond with ONLY a valid JSON object.

Facts:
{json.dumps(facts)}

User question:
Predict Christmas trends for clothing

Rules:
- CRITICAL: Use ONLY data from Facts. Never invent values.
- This is a TREND query. Return predicted_trends array from hot_trends in Facts.
- For trends: Use hot_trends from Facts. Each entry has keyword, hot_score, and category.
- Create predicted_trends with actionable suggestions based on these keywords and their scores.
- Format: {{"predicted_trends": [{{"keyword": "...", "hot_score": 95, "suggestion": "..."}}], "overall_prediction": "..."}}

Example (trend):
{{"predicted_trends": [{{"keyword": "ugly sweaters", "hot_score": 1583, "suggestion": "Restock fun patterns"}}], "restock_suggestions": ["Contact suppliers"], "overall_prediction": "Rising festive demand"}}

Output ONLY the JSON object, nothing else:"""

print("\n" + "="*70)
print("TESTING LLM DIRECTLY WITH TREND PROMPT")
print("="*70)

print("\n📤 Sending prompt to LLM...")
print(f"Model: {MODEL}")
print(f"Facts contain {len(facts['hot_trends'])} hot trends")

try:
    response = requests.post(
        OLLAMA_API,
        json={"model": MODEL, "prompt": prompt, "stream": False},
        timeout=60
    )
    
    if response.status_code == 200:
        data = response.json()
        raw_response = data.get('response', '').strip()
        
        print("\n✅ LLM responded!")
        print("\n" + "="*70)
        print("RAW RESPONSE:")
        print("="*70)
        print(raw_response[:500])
        if len(raw_response) > 500:
            print(f"... (truncated, total length: {len(raw_response)})")
        
        # Try to extract JSON
        json_pattern = r'\{[^{}]*(?:\{[^{}]*\}[^{}]*)*\}'
        matches = list(re.finditer(json_pattern, raw_response))
        
        print(f"\n📊 Found {len(matches)} JSON-like patterns")
        
        if matches:
            for i, match in enumerate(matches, 1):
                candidate = match.group(0)
                print(f"\n--- Pattern {i} ---")
                print(candidate[:200])
                if len(candidate) > 200:
                    print(f"... (truncated, total: {len(candidate)} chars)")
                
                try:
                    parsed = json.loads(candidate)
                    print(f"✅ Valid JSON!")
                    print(f"   Keys: {list(parsed.keys())}")
                    
                    if 'predicted_trends' in parsed:
                        print(f"   🎉 HAS predicted_trends! ({len(parsed['predicted_trends'])} items)")
                        for trend in parsed['predicted_trends'][:2]:
                            print(f"      - {trend.get('keyword', 'N/A')[:50]}")
                    else:
                        print(f"   ⚠️  Missing 'predicted_trends'")
                        
                except json.JSONDecodeError as e:
                    print(f"❌ Invalid JSON: {e}")
        else:
            print("\n❌ No JSON patterns found in response!")
            
    else:
        print(f"\n❌ Error: {response.status_code}")
        print(response.text[:300])
        
except requests.exceptions.Timeout:
    print("\n❌ Request timed out (>60s)")
except Exception as e:
    print(f"\n❌ Error: {e}")

print("\n" + "="*70)
