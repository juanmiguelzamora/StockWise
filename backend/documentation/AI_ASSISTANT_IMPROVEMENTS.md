# AI Assistant Improvements

## Overview
Enhanced the AI assistant with better database-grounded responses, extended query types, and improved accuracy.

## Key Improvements

### 1. **General Inventory Query Support** ✨ NEW
Added support for queries about overall stock status (not item-specific).

**Triggers:**
- "total stock"
- "all stock"
- "overall stock"
- "stock in general"
- "entire inventory"
- "whole inventory"
- "all inventory"

**Response Schema:**
```json
{
  "query_type": "general_inventory",
  "total_stock": 1547,
  "total_products": 52,
  "average_daily_sales": 21.3,
  "low_stock_items": 5,
  "out_of_stock_items": 1,
  "restock_needed": true,
  "recommendation": "5 items low, 1 out of stock—prioritize restocking.",
  "summary": "52 products with 1,547 total units. 5 items need restocking, 1 is out of stock."
}
```

**Example Queries:**
- "What is the total stock?"
- "Show me stock in general"
- "How is our overall inventory?"
- "What's the entire inventory status?"

### 2. **Improved Database Accuracy** 🎯
Enhanced response grounding to ensure LLM only uses actual database values.

**Changes:**
- **Stricter prompt rules**: "CRITICAL: Use ONLY data from Facts. Never invent, estimate, or modify values."
- **Validation layer**: Checks for null values and replaces with actual database values
- **Not found handling**: Proper response when item doesn't exist in database
- **Example responses**: Added "not found" examples to training

**Before:**
```json
{
  "item": "NonExistent Product",
  "current_stock": null,  // ❌ LLM might hallucinate
  "recommendation": "Restock soon"  // ❌ Inaccurate
}
```

**After:**
```json
{
  "item": "NonExistent Product",
  "current_stock": 0,  // ✅ From database
  "average_daily_sales": 0.0,  // ✅ From database
  "restock_needed": false,  // ✅ Correct logic
  "recommendation": "Item not found in inventory. Please verify product name."  // ✅ Accurate
}
```

### 3. **Extended Response Types**
Now supports 4 query types:

| Type | Trigger Keywords | Use Case |
|------|-----------------|----------|
| **Inventory** | item name, SKU, product | Single product queries |
| **Category** | category, "all in", total, group | Category-level queries |
| **Trend** | trend, season, predict, holiday | Trend predictions |
| **General Inventory** | total stock, all stock, entire inventory | Overall stock status |

### 4. **Enhanced Query Detection**
Improved `_detect_query_type()` function:
- Returns 3 booleans: `(is_category, is_trend, is_general_stock)`
- Prioritizes general stock queries (most specific)
- Uses both keyword matching and fuzzy similarity
- More accurate intent detection

### 5. **New Helper Function**
Added `_get_total_inventory_overview()`:
- Aggregates total stock across all products
- Counts low stock and out-of-stock items
- Calculates average daily sales
- Returns top 5 categories by stock
- Efficient ORM queries (no Python loops)

### 6. **Response Validation**
Enhanced `_call_ollama()` with:
- Schema validation for general inventory responses
- Null value safeguards for all response types
- Fallback to database values if LLM returns null
- Better error logging

## Database Schema Understanding

### Product Model
```python
- sku (unique identifier)
- name
- description
- category (ForeignKey)
- supplier (ForeignKey)
- image_url
```

### Inventory Model (One-to-One with Product)
```python
- product (OneToOneField)
- stock_in
- stock_out
- total_stock (calculated: stock_in - stock_out)
- average_daily_sales (calculated from SalesHistory)
- low_stock_threshold (default: 10)
```

### SalesHistory Model
```python
- product (ForeignKey)
- date
- units_sold
```

## Usage Examples

### General Inventory Query
```bash
curl -X POST http://localhost:8000/api/ai/ask/ \
  -H "Content-Type: application/json" \
  -d '{"query": "What is the total stock?"}'
```

**Response:**
```json
{
  "query_type": "general_inventory",
  "total_stock": 1547,
  "total_products": 52,
  "average_daily_sales": 21.3,
  "low_stock_items": 5,
  "out_of_stock_items": 1,
  "restock_needed": true,
  "recommendation": "5 items low, 1 out of stock—prioritize restocking.",
  "summary": "52 products with 1,547 total units. 5 items need restocking, 1 is out of stock."
}
```

### Item Not Found
```bash
curl -X POST http://localhost:8000/api/ai/ask/ \
  -H "Content-Type: application/json" \
  -d '{"query": "Do we have unicorn shoes?"}'
```

**Response:**
```json
{
  "item": "unicorn shoes",
  "current_stock": 0,
  "average_daily_sales": 0.0,
  "restock_needed": false,
  "recommendation": "Item not found in inventory. Please verify product name."
}
```

### Specific Item Query
```bash
curl -X POST http://localhost:8000/api/ai/ask/ \
  -H "Content-Type: application/json" \
  -d '{"query": "How much stock do we have for Fleece Hoodie?"}'
```

**Response:**
```json
{
  "item": "Fleece Hoodie",
  "current_stock": 45,
  "average_daily_sales": 3.2,
  "restock_needed": false,
  "recommendation": "Stock sufficient for 14 days."
}
```

## Training Data

### Original Dataset
- `json_extraction_dataset_500.json` - 500 training examples
- Covers inventory, category, and trend queries

### New Training Samples
- `general_inventory_training_samples.json` - 5 new examples
- Covers general inventory queries and "not found" cases

**To retrain your model with new samples:**
```bash
# Merge the datasets
python -c "
import json
with open('json_extraction_dataset_500.json') as f1, \
     open('general_inventory_training_samples.json') as f2:
    data1 = json.load(f1)
    data2 = json.load(f2)
    merged = data1 + data2
    with open('json_extraction_dataset_505.json', 'w') as out:
        json.dump(merged, out, indent=2)
"

# Then retrain your Ollama model with the merged dataset
```

## Configuration

### Settings (backend/settings.py)
```python
OLLAMA_API = "http://localhost:11434/api/generate"
OLLAMA_MODEL = "stockwise-model"
LOW_STOCK_THRESHOLD = 10  # Items below this are "low stock"
RECENT_TREND_DAYS = 30
RECENT_SALES_DAYS = 90
```

### Rate Limiting
- **Window**: 60 seconds
- **Max Requests**: 10 per IP
- Prevents abuse and excessive LLM calls

## Testing Recommendations

### 1. Test General Inventory Queries
```python
# Test cases
queries = [
    "What is the total stock?",
    "Show me stock in general",
    "How is our overall inventory?",
    "What's the entire inventory status?",
    "All inventory"
]
```

### 2. Test Not Found Cases
```python
# Test cases
queries = [
    "Do we have flying carpets?",
    "Magic wand stock",
    "Unicorn shoes inventory"
]
# Expected: restock_needed=false, appropriate "not found" message
```

### 3. Test Database Accuracy
```python
# Verify response values match database
# Check that current_stock, average_daily_sales are never null
# Ensure no hallucinated data
```

### 4. Test Edge Cases
```python
# Test cases
queries = [
    "",  # Empty query
    "a" * 600,  # Too long (>500 chars)
    "SELECT * FROM products",  # SQL injection attempt
    "<script>alert('xss')</script>",  # XSS attempt
]
```

## Performance Optimizations

### Database Queries
- Uses ORM aggregates (`Sum`, `Avg`, `Count`) instead of Python loops
- Efficient indexing on `Product.name`, `Product.sku`
- One-to-one relationship for `Inventory` (no N+1 queries)

### Caching
- Trend data cached for 1 hour
- Season-specific cache keys
- Reduces database load

### Query Optimization
```python
# Before (N+1 problem)
for product in products:
    stock = product.inventory.total_stock  # ❌ Query per product

# After (single query)
total = Inventory.objects.filter(
    product__in=products
).aggregate(total=Sum('total_stock'))['total']  # ✅ One query
```

## Troubleshooting

### Issue: LLM Returns Null Values
**Solution**: Safeguards in `_call_ollama()` replace nulls with database values.

### Issue: Inaccurate Responses
**Solution**: 
1. Check if item exists in database
2. Verify `Inventory` record exists for product
3. Check `SalesHistory` for average_daily_sales calculation
4. Review prompt rules in `_build_prompt()`

### Issue: General Inventory Not Detected
**Solution**: Check query contains one of the trigger phrases:
- "total stock", "all stock", "overall stock", etc.

### Issue: Performance Slow
**Solution**:
1. Check database indexes
2. Review query complexity
3. Enable caching for trends
4. Optimize Ollama model response time

## Future Enhancements

1. **Multi-language Support**: Detect query language and respond accordingly
2. **Voice Queries**: Integrate with speech-to-text
3. **Predictive Analytics**: ML-based demand forecasting
4. **Supplier Integration**: Auto-reorder from suppliers
5. **Real-time Alerts**: Push notifications for low stock
6. **Dashboard Integration**: Visual charts for inventory overview
7. **Batch Queries**: Support multiple questions in one request
8. **Export Reports**: Generate PDF/Excel inventory reports

## Summary of Changes

| File | Changes |
|------|---------|
| `views.py` | Added `_get_total_inventory_overview()`, updated `_detect_query_type()`, enhanced prompt, added validation |
| `general_inventory_training_samples.json` | New training data for general inventory queries |
| `AI_ASSISTANT_IMPROVEMENTS.md` | This documentation |

## Migration Notes

**No database migrations required** - All changes are in application logic only.

**API Compatibility**: Fully backward compatible. Existing queries work as before.

**Model Retraining**: Optional but recommended to improve general inventory responses.
