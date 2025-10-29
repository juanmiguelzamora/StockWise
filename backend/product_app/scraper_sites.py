import os
import random
import time
import logging
from urllib.parse import urljoin, quote_plus
from functools import wraps

import requests
from bs4 import BeautifulSoup
from pytrends.request import TrendReq

from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException, WebDriverException
from utils.fallbacks import generate_fallback_entries


logger = logging.getLogger(__name__)

# Retry decorator for network requests
def retry_on_failure(max_attempts=3, delay=2, backoff=2):
    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            attempts = 0
            current_delay = delay
            while attempts < max_attempts:
                try:
                    return func(*args, **kwargs)
                except Exception as e:
                    attempts += 1
                    if attempts >= max_attempts:
                        logger.error(f"{func.__name__} failed after {max_attempts} attempts: {e}")
                        raise
                    logger.warning(f"{func.__name__} attempt {attempts} failed: {e}. Retrying in {current_delay}s...")
                    time.sleep(current_delay)
                    current_delay *= backoff
            return None
        return wrapper
    return decorator

# ----------------------------
# Configuration
# ----------------------------
# Optional proxy (set environment variable SCRAPER_PROXY="http://user:pass@host:port")
SCRAPER_PROXY = os.environ.get("SCRAPER_PROXY")

# Curated list of User-Agents to rotate through
USER_AGENTS = [
    # desktop chrome
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 13_0) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.2 Safari/605.1.15",
    "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
    # mobile
    "Mozilla/5.0 (iPhone; CPU iPhone OS 18_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.0 Mobile/15E148 Safari/604.1",
    # Firefox
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:123.0) Gecko/20100101 Firefox/123.0",
]

def _choose_ua():
    return random.choice(USER_AGENTS)

def _requests_session():
    s = requests.Session()
    ua = _choose_ua()
    headers = {
        "User-Agent": ua,
        "Accept-Language": "en-US,en;q=0.9",
        "Referer": "https://www.google.com/",
        "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
    }
    s.headers.update(headers)
    if SCRAPER_PROXY:
        s.proxies.update({"http": SCRAPER_PROXY, "https": SCRAPER_PROXY})
    # small retry/backoff could be added here if you'd like
    return s

def _selenium_driver_with_ua(ua: str, headless=True):
    opts = Options()
    if headless:
        opts.add_argument("--headless=new")
    opts.add_argument("--no-sandbox")
    opts.add_argument("--disable-gpu")
    opts.add_argument("--disable-dev-shm-usage")
    opts.add_argument("--disable-blink-features=AutomationControlled")
    opts.add_argument("--window-size=1920,1080")
    opts.add_argument(f"user-agent={ua}")
    
    # Enhanced anti-detect flags
    opts.add_experimental_option("excludeSwitches", ["enable-automation", "enable-logging"])
    opts.add_experimental_option("useAutomationExtension", False)
    opts.add_argument("--disable-extensions")
    opts.add_argument("--disable-infobars")
    
    # optionally set proxy via capability if SCRAPER_PROXY present
    driver = webdriver.Chrome(options=opts)
    try:
        # Enhanced stealth scripts
        driver.execute_cdp_cmd("Page.addScriptToEvaluateOnNewDocument", {
            "source": """
                Object.defineProperty(navigator, 'webdriver', {get: () => undefined});
                Object.defineProperty(navigator, 'plugins', {get: () => [1, 2, 3, 4, 5]});
                Object.defineProperty(navigator, 'languages', {get: () => ['en-US', 'en']});
                window.chrome = {runtime: {}};
            """
        })
    except Exception:
        pass
    return driver

# ----------------------------
# BaseScraper
# ----------------------------
class BaseScraper:
    site_name = "Base"

    def __init__(self, season: str):
        self.season = season

    def _get_fallback(self):
        """
        Returns smart, season-aware fallback trends instead of generic placeholders.
        """
        from utils.fallbacks import generate_fallback_entries

        fallback_entries = generate_fallback_entries(self.season, count=5)

        # Assign site name to each fallback (for traceability)
        for entry in fallback_entries:
            entry["source_name"] = self.site_name

        print(f"⚠️ Using smart fallback for {self.season} from {self.site_name}")
        return fallback_entries

    def fetch(self):
        raise NotImplementedError

# ----------------------------
# Vogue (requests + BS with UA rotation)
# ----------------------------
class VogueScraper(BaseScraper):
    site_name = "Vogue"

    @retry_on_failure(max_attempts=2, delay=3)
    def fetch(self):
        query = quote_plus(f"{self.season} fashion 2025")
        url = f"https://www.vogue.com/search?q={query}"
        logger.info(f"{self.site_name}: Fetching from {url}")

        session = _requests_session()
        results = []
        try:
            resp = session.get(url, timeout=20)
            resp.raise_for_status()
            soup = BeautifulSoup(resp.text, "lxml")

            # Multiple selector strategies for better coverage
            selectors = [
                "article h3",
                "article h2",
                "[data-testid='SummaryItemHed']",
                ".summary-item__hed",
                "a[href*='/article/'] h3",
                "a[href*='/article/'] h2",
                ".SummaryItemWrapper h3",
            ]
            
            elems = []
            for selector in selectors:
                found = soup.select(selector)
                if found:
                    elems.extend(found)
                    if len(elems) >= 15:
                        break
            
            # Remove duplicates while preserving order
            seen_titles = set()
            for tag in elems[:20]:
                title = tag.get_text(strip=True)
                if not title or title.lower() in seen_titles:
                    continue
                seen_titles.add(title.lower())
                
                # Find parent link
                parent = tag.find_parent("a")
                href = parent.get("href") if parent else None
                if title and href:
                    results.append({
                        "keywords": f"{self.season} {title[:100]}",
                        "popularity_score": round(random.uniform(75, 95), 1),
                        "source_url": urljoin("https://www.vogue.com", href),
                        "source_name": self.site_name,
                    })
                    
        except Exception as e:
            logger.warning(f"{self.site_name} request failed: {e}")

        if not results:
            logger.warning(f"{self.site_name}: No valid data parsed, using fallback.")
            results = self._get_fallback()
        return results

# ----------------------------
# ASOS (Selenium smarter waiting + scroll-until-stable + UA rotation)
# ----------------------------
class AsosScraper(BaseScraper):
    site_name = "ASOS"

    def fetch(self):
        query = quote_plus(f"{self.season} fashion trends")
        url = f"https://www.asos.com/us/search/?q={query}"
        logger.info(f"{self.site_name}: Fetching from {url}")

        ua = _choose_ua()
        driver = None
        results = []
        try:
            driver = _selenium_driver_with_ua(ua)
            if SCRAPER_PROXY:
                logger.info(f"{self.site_name}: Using proxy from SCRAPER_PROXY")

            driver.get(url)
            
            # Human-like delay before interacting
            time.sleep(random.uniform(2, 4))

            # More flexible waiting strategy
            wait_selectors = [
                (By.CSS_SELECTOR, "article[data-auto-id='productTile']"),
                (By.CSS_SELECTOR, "[data-auto-id='productList']"),
                (By.CSS_SELECTOR, "section[data-testid='product-grid']"),
                (By.CSS_SELECTOR, "article"),
            ]
            
            element_found = False
            for by, selector in wait_selectors:
                try:
                    WebDriverWait(driver, 8).until(
                        EC.presence_of_element_located((by, selector))
                    )
                    element_found = True
                    logger.info(f"{self.site_name}: Found elements with selector: {selector}")
                    break
                except TimeoutException:
                    continue
            
            if not element_found:
                logger.warning(f"{self.site_name}: No expected elements found, trying to parse anyway")

            # Progressive scroll with human-like behavior
            scroll_pause = random.uniform(1.5, 2.5)
            last_height = driver.execute_script("return document.body.scrollHeight")
            
            for i in range(5):
                # Scroll to random position, not always bottom
                scroll_to = random.randint(int(last_height * 0.6), last_height)
                driver.execute_script(f"window.scrollTo(0, {scroll_to});")
                time.sleep(scroll_pause)
                
                new_height = driver.execute_script("return document.body.scrollHeight")
                if new_height == last_height:
                    break
                last_height = new_height

            time.sleep(2)

            soup = BeautifulSoup(driver.page_source, "lxml")

            # Comprehensive selector list
            selectors = [
                "article[data-auto-id='productTile'] p",
                "[data-auto-id='productTileDescription']",
                "article h2",
                "article h3",
                "article p[data-auto-id]",
                "a[href*='/prd/'] p",
            ]
            
            product_tags = []
            for selector in selectors:
                found = soup.select(selector)
                if found:
                    product_tags.extend(found)

            seen = set()
            for tag in product_tags[:25]:
                text = tag.get_text(strip=True)
                if not text or len(text) < 5:
                    continue
                key = text.lower()
                if key in seen:
                    continue
                seen.add(key)
                results.append({
                    "keywords": f"{self.season} {text[:120]}",
                    "popularity_score": round(random.uniform(65, 92), 1),
                    "source_url": url,
                    "source_name": self.site_name,
                })

        except Exception as e:
            logger.warning(f"{self.site_name} Selenium error: {e}")
        finally:
            if driver:
                try:
                    driver.quit()
                except Exception:
                    pass

        if not results:
            logger.warning(f"{self.site_name}: No valid data parsed, using fallback.")
            results = self._get_fallback()
        return results

# ----------------------------
# Pinterest (requests first with UA/referrer; fallback to Selenium only if needed)
# ----------------------------
class PinterestScraper(BaseScraper):
    site_name = "Pinterest"

    def fetch(self):
        query = quote_plus(f"{self.season} fashion 2025")
        url = f"https://www.pinterest.com/search/pins/?q={query}&rs=typed"
        logger.info(f"{self.site_name}: Fetching from {url}")

        # Pinterest is heavily protected, go straight to Selenium with enhanced stealth
        ua = _choose_ua()
        driver = None
        results = []
        
        try:
            driver = _selenium_driver_with_ua(ua)
            driver.get(url)
            
            # Longer initial wait to appear more human
            time.sleep(random.uniform(4, 7))
            
            # Human-like scrolling pattern
            for _ in range(3):
                # Scroll in increments
                scroll_amount = random.randint(300, 800)
                driver.execute_script(f"window.scrollBy(0, {scroll_amount});")
                time.sleep(random.uniform(2, 4))
            
            # Final wait for content to load
            time.sleep(3)
            
            soup = BeautifulSoup(driver.page_source, "lxml")
            
            # Multiple strategies to find content
            # Strategy 1: Images with alt text
            imgs = soup.find_all("img", alt=True)
            for img in imgs[:15]:
                alt = img.get("alt", "").strip()
                if alt and len(alt) > 10 and "pinterest" not in alt.lower():
                    results.append({
                        "keywords": f"{self.season} {alt[:120]}",
                        "popularity_score": round(random.uniform(72, 90), 1),
                        "source_url": url,
                        "source_name": self.site_name,
                    })
            
            # Strategy 2: Pin titles/descriptions
            pin_texts = soup.select("[data-test-id='pin-title'], [data-test-id='pinrep-description']")
            for elem in pin_texts[:10]:
                text = elem.get_text(strip=True)
                if text and len(text) > 10:
                    results.append({
                        "keywords": f"{self.season} {text[:120]}",
                        "popularity_score": round(random.uniform(72, 90), 1),
                        "source_url": url,
                        "source_name": self.site_name,
                    })
                    
        except Exception as e:
            logger.warning(f"{self.site_name} Selenium error: {e}")
        finally:
            if driver:
                try:
                    driver.quit()
                except Exception:
                    pass

        # Remove duplicates
        seen = set()
        unique_results = []
        for r in results:
            key = r["keywords"].lower()
            if key not in seen:
                seen.add(key)
                unique_results.append(r)

        if not unique_results:
            logger.warning(f"{self.site_name}: No valid data parsed, using fallback.")
            unique_results = self._get_fallback()
        
        return unique_results[:12]

# ----------------------------
# Google Trends (pytrends with a small delay)
# ----------------------------
class GoogleTrendsScraper(BaseScraper):
    site_name = "Google Trends"

    def fetch(self):
        logger.info(f"{self.site_name}: Fetching Google Trends for season={self.season}")
        results = []
        
        # Exponential backoff for rate limiting
        max_retries = 3
        base_delay = 5
        
        for attempt in range(max_retries):
            try:
                # Longer randomized delay to avoid rate limiting
                delay = base_delay * (2 ** attempt) + random.uniform(2, 5)
                logger.info(f"{self.site_name}: Waiting {delay:.1f}s before request (attempt {attempt + 1}/{max_retries})")
                time.sleep(delay)
                
                # Use different timeframes and regions to reduce detection
                timeframes = ["today 3-m", "today 1-m", "now 7-d"]
                geos = ["", "US", "PH"]
                
                pytrends = TrendReq(
                    hl="en-US",
                    tz=480,
                    timeout=(10, 25),
                    retries=2,
                    backoff_factor=0.5
                )
                
                kw = f"{self.season} fashion"
                timeframe = random.choice(timeframes)
                geo = random.choice(geos)
                
                logger.info(f"{self.site_name}: Querying with timeframe={timeframe}, geo={geo}")
                pytrends.build_payload([kw], timeframe=timeframe, geo=geo)
                
                # Try related queries first
                try:
                    related = pytrends.related_queries()
                    if related and isinstance(related, dict):
                        for _, block in related.items():
                            if block and "top" in block and block["top"] is not None:
                                for _, row in block["top"].head(8).iterrows():
                                    results.append({
                                        "keywords": row["query"],
                                        "popularity_score": float(row["value"]),
                                        "source_url": "https://trends.google.com",
                                        "source_name": self.site_name,
                                    })
                except Exception as e:
                    logger.warning(f"{self.site_name}: Related queries failed: {e}")
                
                # Fallback: interest over time
                if not results:
                    try:
                        df = pytrends.interest_over_time()
                        if not df.empty and kw in df.columns:
                            avg = df[kw].mean()
                            results.append({
                                "keywords": f"{kw} trends",
                                "popularity_score": round(float(avg), 1),
                                "source_url": "https://trends.google.com",
                                "source_name": self.site_name,
                            })
                    except Exception as e:
                        logger.warning(f"{self.site_name}: Interest over time failed: {e}")
                
                # If we got results, break the retry loop
                if results:
                    logger.info(f"{self.site_name}: Successfully fetched {len(results)} trends")
                    break
                    
            except Exception as e:
                logger.warning(f"{self.site_name} attempt {attempt + 1} failed: {e}")
                if attempt == max_retries - 1:
                    logger.error(f"{self.site_name}: All retry attempts exhausted")

        if not results:
            logger.warning(f"{self.site_name}: No valid data parsed, using fallback.")
            results = self._get_fallback()
        return results

# ----------------------------
# SCRAPER_REGISTRY (used by management command)
# ----------------------------
SCRAPER_REGISTRY = {
    "vogue": VogueScraper,
    "asos": AsosScraper,
    "pinterest": PinterestScraper,
    "googletrends": GoogleTrendsScraper,
}
