# Web Scraper Improvement Guide

## Overview
The scraper system has been enhanced with better anti-detection, retry logic, and improved selectors for more reliable data collection.

## Key Improvements

### 1. **Dependencies Added**
- `beautifulsoup4==4.12.3` - HTML parsing
- `selenium==4.16.0` - Browser automation
- `lxml==5.1.0` - Fast XML/HTML parser

### 2. **Enhanced Anti-Detection**
- **Selenium Stealth**: CDP commands to hide webdriver properties
- **User-Agent Rotation**: Multiple realistic user agents
- **Human-like Behavior**: Random delays, progressive scrolling
- **Anti-automation Flags**: Disabled automation indicators

### 3. **Retry Logic**
- Exponential backoff for failed requests
- Configurable retry attempts (default: 2-3)
- Graceful fallback to curated trends

### 4. **Site-Specific Improvements**

#### **Vogue**
- Multiple CSS selectors for better coverage
- Duplicate removal
- Retry decorator with 2 attempts
- Increased timeout to 20s

#### **ASOS**
- Flexible waiting strategies (multiple selectors)
- Human-like scrolling (random positions)
- Enhanced element detection
- Better error handling

#### **Pinterest**
- Direct Selenium approach (skips requests)
- Longer human-like delays (4-7s initial)
- Progressive scrolling in increments
- Multiple content extraction strategies
- Duplicate filtering

#### **Google Trends**
- Exponential backoff (5s → 10s → 20s)
- Varied timeframes and regions
- 3 retry attempts with increased delays
- Better timeout configuration

## Installation

```bash
cd backend
.\venv\Scripts\activate
pip install -r requirements.txt
```

## Usage

### Basic Command
```bash
python manage.py scrape_trends
```

### With Options
```bash
# Dry run (no save to DB)
python manage.py scrape_trends --season="Christmas" --sites="vogue,asos,pinterest,googletrends" --no-save --verbose-sites

# Save to database
python manage.py scrape_trends --season="Christmas" --sites="vogue,asos,pinterest,googletrends" --verbose-sites

# Limit results
python manage.py scrape_trends --max-trends 30
```

### Available Options
- `--season` - Override detected season (e.g., "Christmas", "Summer")
- `--sites` - Comma-separated list of sites (vogue,asos,pinterest,googletrends)
- `--no-save` - Dry run mode (preview only)
- `--max-trends` - Maximum unique trends to keep (default: 50)
- `--verbose-sites` - Show detailed per-site progress

## Best Practices

### 1. **Rate Limiting**
- Don't run scrapers too frequently (wait 1-2 hours between runs)
- Google Trends has strict rate limits - use sparingly
- Consider running different sites at different times

### 2. **Proxy Usage** (Optional)
```bash
# Set environment variable
$env:SCRAPER_PROXY="http://user:pass@proxy:port"
python manage.py scrape_trends
```

### 3. **Error Handling**
- Scrapers automatically fall back to curated trends
- Check logs for specific error messages
- Use `--verbose-sites` to debug individual scrapers

### 4. **Performance Tips**
- Run during off-peak hours for better success rates
- Use `--no-save` first to test before saving
- Monitor Chrome/Selenium memory usage

## Troubleshooting

### Issue: Google Trends 429 Error
**Solution**: Wait longer between requests. The scraper now includes exponential backoff, but you may need to wait 30-60 minutes before retrying.

### Issue: ASOS/Pinterest Blocking
**Solution**: 
- These sites have strong anti-bot measures
- Success rates vary by time of day
- Consider using a proxy service
- The scraper will use fallback trends if blocked

### Issue: Selenium ChromeDriver Error
**Solution**:
```bash
# Update ChromeDriver to match your Chrome version
# Download from: https://chromedriver.chromium.org/
```

### Issue: Low Success Rate
**Solution**:
- Run with `--verbose-sites` to see which scrapers fail
- Check your internet connection
- Verify Chrome/ChromeDriver compatibility
- Consider running sites individually

## Monitoring Success

### Check Scraper Output
```bash
python manage.py scrape_trends --season="Christmas" --verbose-sites --no-save
```

Look for:
- ✅ Success indicators
- ⚠️ Fallback warnings
- ❌ Error messages
- Item counts per site

### Expected Results
- **Vogue**: 5-15 items
- **ASOS**: 5-20 items (varies)
- **Pinterest**: 8-12 items (often blocked)
- **Google Trends**: 5-8 items (rate limited)

## Advanced Configuration

### Custom User Agents
Edit `scraper_sites.py` line 52-57 to add more user agents.

### Adjust Timeouts
- Vogue: Line 156 (`timeout=20`)
- Selenium waits: Lines 241, 339 (adjust `WebDriverWait` duration)

### Modify Delays
- Between sites: `scrape_trends.py` line 82 (2-5s)
- Google Trends: `scraper_sites.py` line 419 (exponential backoff)
- Pinterest: `scraper_sites.py` line 339 (4-7s)

## Future Improvements

1. **Proxy Rotation**: Implement automatic proxy rotation
2. **Headless Browser Alternatives**: Consider Playwright or undetected-chromedriver
3. **API Integration**: Use official APIs where available
4. **Caching**: Cache results to reduce scraping frequency
5. **Distributed Scraping**: Run scrapers on different machines/IPs

## Support

For issues or questions:
1. Check logs in Django console
2. Review error messages with `--verbose-sites`
3. Verify all dependencies are installed
4. Ensure Chrome and ChromeDriver versions match
