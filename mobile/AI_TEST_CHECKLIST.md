# Mobile AI Assistant - Test Checklist

## Pre-Testing Setup

### Backend
- [ ] Django server is running (`python manage.py runserver`)
- [ ] Ollama is running with `stockwise-model`
- [ ] Trend data exists in database (run scraper if needed)
- [ ] Backend accessible from mobile device

### Mobile
- [ ] Backend URL configured correctly in `service_locator.dart`
- [ ] Dependencies installed (`flutter pub get`)
- [ ] App builds successfully (`flutter build`)

## Test Cases

### 1. Quick Actions

#### Test: Total Inventory
- [ ] Tap "Total Inventory" button
- [ ] Query sent: "What is the total stock?"
- [ ] Response shows:
  - [ ] Total products count
  - [ ] Total stock count
  - [ ] Low stock items count
  - [ ] Out of stock items count
  - [ ] Top categories list
  - [ ] Summary text
  - [ ] Recommendation

#### Test: Seasonal Trends
- [ ] Tap "Seasonal Trends" button
- [ ] Query sent: "Predict Christmas trends for clothing"
- [ ] Response shows:
  - [ ] Predicted trends list (with keywords)
  - [ ] Hot scores for each trend
  - [ ] Suggestions for each trend
  - [ ] Bar chart visualization
  - [ ] Overall prediction text

#### Test: Low Stock Items
- [ ] Tap "Low Stock Items" button
- [ ] Query sent: "Show me low stock items"
- [ ] Response shows appropriate data

### 2. Manual Queries

#### General Inventory Queries
- [ ] "What is the total stock?"
- [ ] "Show me overall inventory"
- [ ] "How is our stock doing?"
- [ ] "All inventory"

**Expected**: General inventory UI with metrics grid

#### Trend Queries
- [ ] "Predict Christmas trends for clothing"
- [ ] "What are the summer fashion trends?"
- [ ] "Show me trending items"
- [ ] "Forecast winter clothing demand"

**Expected**: Trend UI with chart and predictions

#### Item-Specific Queries
- [ ] "How much stock for Fleece Hoodie?"
- [ ] "Current stock for gray pants"
- [ ] "Do we have red sweaters?"

**Expected**: Item UI with stock details

#### Category Queries
- [ ] "Total stock in Women's Wear"
- [ ] "How much inventory in Clothing?"

**Expected**: Category UI with aggregated data

### 3. UI/UX Tests

#### Welcome Section
- [ ] Welcome message displays on first load
- [ ] Quick action buttons are visible
- [ ] Quick action buttons are tappable
- [ ] Welcome section hides after first query

#### Chat Area
- [ ] User messages appear on right (blue bubble)
- [ ] AI responses appear on left (white bubble)
- [ ] Messages scroll automatically
- [ ] Chat history persists during session

#### Input Section
- [ ] Text field is visible
- [ ] Placeholder text: "Ask about stock, trends, or predictions..."
- [ ] Can type in text field
- [ ] Send button is visible
- [ ] Send button sends query
- [ ] Keyboard dismisses after send
- [ ] Input field clears after send

#### Loading State
- [ ] Shimmer animation shows while loading
- [ ] Input section hides during loading
- [ ] Loading state shows after query sent

#### Error Handling
- [ ] Network error shows friendly message
- [ ] "Try Again" button appears on error
- [ ] Can retry after error
- [ ] Error doesn't crash app

### 4. Response Display Tests

#### General Inventory Response
- [ ] Shows "Overall Inventory Status" header
- [ ] Displays 2x2 metrics grid:
  - [ ] Total Products (with icon)
  - [ ] Total Stock (with icon)
  - [ ] Low Stock (with icon)
  - [ ] Out of Stock (with icon)
- [ ] Shows average daily sales
- [ ] Lists top 5 categories
- [ ] Shows summary box
- [ ] Shows recommendation with appropriate color

#### Trend Response
- [ ] Shows "Inventory Trend Forecast" header
- [ ] Displays bar chart with hot scores
- [ ] Lists top 3-5 predicted trends
- [ ] Each trend shows:
  - [ ] Keyword
  - [ ] Hot score
  - [ ] Suggestion
- [ ] Shows overall prediction
- [ ] Shows restock suggestions (if any)

#### Item Response
- [ ] Shows item name in header
- [ ] Displays current stock
- [ ] Displays average daily sales
- [ ] Shows restock needed status (Yes/No)
- [ ] Shows recommendation box
- [ ] Colors match status (red for restock, green for ok)

### 5. Edge Cases

#### Empty/Invalid Queries
- [ ] Empty query doesn't send
- [ ] Invalid item name shows "not found" message
- [ ] Malformed query handled gracefully

#### Network Issues
- [ ] No internet shows error message
- [ ] Backend down shows error message
- [ ] Timeout handled properly

#### Large Responses
- [ ] Long trend lists display correctly
- [ ] Many categories display correctly
- [ ] Scrolling works with large responses

### 6. Performance

- [ ] App doesn't lag during queries
- [ ] Animations are smooth
- [ ] No memory leaks
- [ ] Response time < 5 seconds (with backend)

### 7. Visual Consistency

- [ ] Colors match app theme
- [ ] Fonts are consistent
- [ ] Icons are appropriate
- [ ] Spacing is uniform
- [ ] Borders and shadows look good

## Test Results

### Device Information
- **Device**: _________________
- **OS Version**: _________________
- **Flutter Version**: _________________
- **Test Date**: _________________

### Overall Status
- [ ] All tests passed
- [ ] Some tests failed (list below)
- [ ] Major issues found (list below)

### Issues Found
1. _______________________________________________
2. _______________________________________________
3. _______________________________________________

### Notes
_____________________________________________________
_____________________________________________________
_____________________________________________________

## Sign-off

- **Tester**: _________________
- **Date**: _________________
- **Status**: ✅ Approved / ❌ Needs Work
