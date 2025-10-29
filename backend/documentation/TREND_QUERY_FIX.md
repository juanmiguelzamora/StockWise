# Trend Query Fix - AI Assistant

## Issue Identified

The AI assistant was giving inaccurate responses for trend/prediction queries because of a data structure mismatch between the `Trend` model and what the LLM expected.

### Root Cause

**Trend Model Structure** (`product_app_trend` table):
```python
class Trend(models.Model):
    season = models.CharField(max_length=50)  # e.g., "Christmas", "Summer"
    keywords = models.TextField()  # Comma-separated: "red sweaters, festive patterns, ugly sweaters"
    hot_score = models.FloatField()  # Pre-computed popularity score
    category = models.ForeignKey(Category, ...)
    scraped_at = models.DateTimeField(auto_now_add=True)
```

**Previous Code** (Incorrect):
```python
hot_trends = [{"keywords": t.keywords, "hot_score": t.hot_score} for t in hot_trends_qs]
# Result: {"keywords": "red sweaters, festive patterns", "hot_score": 95}
```

**LLM Expected Format**:
```python
[
  {"keyword": "red sweaters", "hot_score": 95, "suggestion": "..."},
  {"keyword": "festive patterns", "hot_score": 95, "suggestion": "..."}
]
```

The mismatch caused the LLM to:
- Not properly parse the comma-separated keywords
- Generate inaccurate or generic predictions
- Miss individual trend items

---

## Solution Implemented

### 1. Split Keywords into Individual Trend Items

**File**: `backend/ai_assistant/views.py`

```python
if hot_trends_qs.exists():
    # Split comma-separated keywords into individual trend items
    hot_trends = []
    for t in hot_trends_qs:
        # Split keywords by comma and create individual entries
        keywords_list = [kw.strip() for kw in t.keywords.split(',') if kw.strip()]
        for keyword in keywords_list[:3]:  # Max 3 keywords per trend entry
            hot_trends.append({
                "keyword": keyword,  # SINGULAR, not plural
                "hot_score": t.hot_score,
                "category": t.category.name if t.category else "General"
            })
    
    # Sort by hot_score and take top 5
    hot_trends = sorted(hot_trends, key=lambda x: x['hot_score'], reverse=True)[:5]
```

**Benefits**:
- ✅ Each keyword becomes an individual trend item
- ✅ Maintains the hot_score from the scraped data
- ✅ Includes category information for better context
- ✅ Sorted by hot_score to prioritize trending items

### 2. Enhanced Prompt Instructions

Updated the LLM prompt to be more explicit:

```python
Rules:
- For trends: Use hot_trends from Facts. Each entry has keyword, hot_score, and category. 
  Create predicted_trends with actionable suggestions based on these keywords and their scores.
```

### 3. Added Comprehensive Logging

```python
logger.info(f"Trend query detected: {season_match} | Found {len(hot_trends)} trend keywords from {hot_trends_qs.count()} trend entries")
logger.warning(f"No trends found for season: {season_match} in last {RECENT_TREND_DAYS} days")
logger.info(f"Using cached trends for {season_match}: {len(hot_trends)} keywords")
```

### 4. Set Found Flag for Trends

```python
found = True  # Mark as found so LLM processes it
```

This ensures trend queries always go through the LLM processing pipeline.

---

## Data Flow

### Before Fix
```
Database (Trend table)
  ↓
  season: "Christmas"
  keywords: "red sweaters, festive patterns, ugly sweaters"
  hot_score: 95
  ↓
AI Assistant (Incorrect format)
  ↓
  {"keywords": "red sweaters, festive patterns, ugly sweaters", "hot_score": 95}
  ↓
LLM (Confused by comma-separated string)
  ↓
  ❌ Inaccurate predictions
```

### After Fix
```
Database (Trend table)
  ↓
  season: "Christmas"
  keywords: "red sweaters, festive patterns, ugly sweaters"
  hot_score: 95
  ↓
AI Assistant (Split keywords)
  ↓
  [
    {"keyword": "red sweaters", "hot_score": 95, "category": "Clothing"},
    {"keyword": "festive patterns", "hot_score": 95, "category": "Clothing"},
    {"keyword": "ugly sweaters", "hot_score": 95, "category": "Clothing"}
  ]
  ↓
LLM (Clear individual items)
  ↓
  ✅ Accurate predictions with specific suggestions
```

---

## Example Response

### Query
"Predict Christmas trends for clothing"

### Database Data (product_app_trend)
```sql
SELECT season, keywords, hot_score, category_id 
FROM product_app_trend 
WHERE season ILIKE '%Christmas%' 
  AND scraped_at >= NOW() - INTERVAL '30 days'
ORDER BY hot_score DESC 
LIMIT 10;

-- Results:
-- Christmas | red sweaters, festive patterns, ugly sweaters | 95.5 | 1
-- Christmas | velvet dresses, sequin tops | 87.2 | 2
-- Christmas | green pants, holiday accessories | 78.9 | 3
```

### AI Response (After Fix)
```json
{
  "predicted_trends": [
    {
      "keyword": "red sweaters",
      "hot_score": 95.5,
      "suggestion": "Restock red sweaters immediately—highest demand for Christmas season"
    },
    {
      "keyword": "festive patterns",
      "hot_score": 95.5,
      "suggestion": "Stock items with festive patterns—strong seasonal trend"
    },
    {
      "keyword": "ugly sweaters",
      "hot_score": 95.5,
      "suggestion": "Popular Christmas item—ensure adequate inventory"
    },
    {
      "keyword": "velvet dresses",
      "hot_score": 87.2,
      "suggestion": "Premium holiday item—target high-end market"
    },
    {
      "keyword": "sequin tops",
      "hot_score": 87.2,
      "suggestion": "Party wear trending—stock for holiday events"
    }
  ],
  "restock_suggestions": [
    "Contact suppliers for red sweaters and festive patterns",
    "Prioritize velvet and sequin items for premium segment"
  ],
  "overall_prediction": "Strong Christmas demand for festive clothing. Red sweaters and festive patterns show highest trend scores. Expect 20-30% sales increase in December."
}
```

---

## Testing

### 1. Check Database Has Trend Data
```bash
python manage.py shell
```

```python
from product_app.models import Trend
from django.utils import timezone
from datetime import timedelta

# Check if trends exist
trends = Trend.objects.filter(
    season__icontains='Christmas',
    scraped_at__gte=timezone.now() - timedelta(days=30)
)

print(f"Found {trends.count()} Christmas trends")
for t in trends[:3]:
    print(f"  - {t.keywords[:50]}... (Score: {t.hot_score})")
```

### 2. Test Trend Query
```bash
curl -X POST http://localhost:8000/api/ai/ask/ \
  -H "Content-Type: application/json" \
  -d '{"query": "Predict Christmas trends for clothing"}'
```

### 3. Check Logs
```bash
# Look for these log messages:
# "Trend query detected: Christmas | Found 5 trend keywords from 2 trend entries"
# "Using cached trends for Christmas: 5 keywords"
```

### 4. Test Different Seasons
```bash
# Summer trends
curl -X POST http://localhost:8000/api/ai/ask/ \
  -H "Content-Type: application/json" \
  -d '{"query": "What are the summer fashion trends?"}'

# Winter trends
curl -X POST http://localhost:8000/api/ai/ask/ \
  -H "Content-Type: application/json" \
  -d '{"query": "Predict winter trends"}'

# General trends (no specific season)
curl -X POST http://localhost:8000/api/ai/ask/ \
  -H "Content-Type: application/json" \
  -d '{"query": "What trends should I watch?"}'
```

---

## Configuration

### Settings
```python
# backend/settings.py
RECENT_TREND_DAYS = 30  # Look for trends from last 30 days
```

### Cache
- Trend data is cached for 1 hour (3600 seconds)
- Cache key format: `hot_trends_{category}_{season}`
- Clear cache if needed: `python manage.py shell` → `from django.core.cache import cache; cache.clear()`

---

## Troubleshooting

### Issue: "No trends found"
**Cause**: No trend data in database for the requested season

**Solution**:
1. Run the scraper to populate trend data:
   ```bash
   curl -X POST http://localhost:8000/api/trends/scrape/
   ```
2. Check if trends exist in database:
   ```python
   from product_app.models import Trend
   print(Trend.objects.all().count())
   ```

### Issue: Still getting generic responses
**Cause**: Cache contains old data format

**Solution**:
```python
from django.core.cache import cache
cache.clear()
```

### Issue: Keywords not splitting correctly
**Cause**: Keywords in database don't have commas

**Solution**: Ensure scraped data uses comma-separated format:
```python
# When saving trends:
trend = Trend(
    season="Christmas",
    keywords="red sweaters, festive patterns, ugly sweaters",  # Use commas
    hot_score=95.5
)
```

---

## Summary

✅ **Fixed**: Trend queries now correctly reference `product_app_trend` table  
✅ **Fixed**: Keywords are split into individual trend items  
✅ **Fixed**: LLM receives proper data structure with `keyword` (singular)  
✅ **Added**: Category information for better context  
✅ **Added**: Comprehensive logging for debugging  
✅ **Added**: Cache handling for cached trend data  

The AI assistant now provides **accurate, data-driven trend predictions** based on actual scraped data from the `product_app_trend` table! 🎉
