# Single Trend Object Fix

## Problem

When querying for trend predictions, the backend sometimes returns a **single trend object** instead of the expected `predicted_trends` array:

**Expected Format**:
```json
{
  "predicted_trends": [
    {
      "keyword": "Christmas It May Be Fall Down Under",
      "hot_score": 95.0,
      "suggestion": "Stock festive clothing"
    }
  ],
  "overall_prediction": "..."
}
```

**Actual Response**:
```json
{
  "keyword": "Christmas It May Be Fall Down Under",
  "hot_score": 95.0,
  "suggestion": "Stock festive clothing"
}
```

This caused:
- ❌ Trend data not displayed in UI
- ❌ `isTrendResponse` returns false
- ❌ Falls back to inventory UI (which shows empty data)

## Root Cause

The LLM sometimes generates incomplete JSON or a single trend object instead of wrapping it in the `predicted_trends` array. The mobile app's `fromJson` parser expected the array format and couldn't handle the single object.

## Solution

### Updated `AiResponseModel.fromJson()` ✅

**File**: `lib/data/ai_assistant/models/ai_response_model.dart`

Added logic to detect and handle single trend objects:

```dart
factory AiResponseModel.fromJson(Map<String, dynamic> json) {
  List<PredictedTrendModel>? trends;
  String? overallPred = json['overall_prediction'];
  
  if (json['predicted_trends'] != null) {
    // Standard format: array of trends
    trends = (json['predicted_trends'] as List)
        .map((e) => PredictedTrendModel.fromJson(e))
        .toList();
  } else if (json['keyword'] != null && json['hot_score'] != null) {
    // Single trend object - wrap it in an array
    trends = [
      PredictedTrendModel(
        keyword: json['keyword'] ?? '',
        hotScore: (json['hot_score'] as num?)?.toDouble() ?? 0.0,
        suggestion: json['suggestion'] ?? '',
      )
    ];
    
    // Generate default overall prediction if missing
    if (overallPred == null) {
      overallPred = 'Trend analysis based on current data';
    }
  }
  
  return AiResponseModel(
    // ... other fields
    predictedTrends: trends,
    overallPrediction: overallPred,
  );
}
```

## How It Works

### Detection Logic

1. **Check for `predicted_trends` array** (standard format)
   - If present → Parse as array
   
2. **Check for `keyword` and `hot_score` fields** (single object)
   - If present → Wrap in array
   - Generate default `overall_prediction` if missing

3. **Otherwise** → `trends` remains `null`

### Result

- ✅ Both formats now supported
- ✅ Single trend object wrapped in array
- ✅ `isTrendResponse` returns `true` (array is not empty)
- ✅ Trend UI displays correctly
- ✅ Default overall prediction added

## Testing

### Test Case 1: Single Trend Object

**Backend Response**:
```json
{
  "keyword": "Christmas It May Be Fall Down Under",
  "hot_score": 95.0,
  "suggestion": "Stock festive clothing"
}
```

**Parsed Result**:
```dart
AiResponse(
  predictedTrends: [
    PredictedTrend(
      keyword: "Christmas It May Be Fall Down Under",
      hotScore: 95.0,
      suggestion: "Stock festive clothing"
    )
  ],
  overallPrediction: "Trend analysis based on current data"
)
```

**UI Display**: ✅ Shows trend card with extracted keyword

### Test Case 2: Standard Array Format

**Backend Response**:
```json
{
  "predicted_trends": [
    {"keyword": "...", "hot_score": 95.0, "suggestion": "..."},
    {"keyword": "...", "hot_score": 92.0, "suggestion": "..."}
  ],
  "overall_prediction": "Strong demand expected"
}
```

**Parsed Result**: ✅ Works as before

### Test Case 3: No Trend Data

**Backend Response**:
```json
{
  "item": "Fleece Hoodie",
  "current_stock": 15,
  "average_daily_sales": 2.5
}
```

**Parsed Result**: ✅ `predictedTrends` is `null`, shows inventory UI

## Benefits

✅ **Robust Parsing**: Handles both array and single object formats  
✅ **Backward Compatible**: Standard array format still works  
✅ **Graceful Fallback**: Generates default prediction if missing  
✅ **Better UX**: Trend data always displays when available  
✅ **No Breaking Changes**: Existing functionality unchanged  

## Files Modified

- `mobile/lib/data/ai_assistant/models/ai_response_model.dart`
  - Updated `fromJson()` factory method
  - Added single trend object detection
  - Added default overall prediction

## Summary

The mobile app now **gracefully handles** both response formats:
1. Standard `predicted_trends` array ✅
2. Single trend object (wraps in array) ✅
3. No trend data (shows inventory UI) ✅

Trend predictions will now display correctly regardless of backend response format! 🎉
