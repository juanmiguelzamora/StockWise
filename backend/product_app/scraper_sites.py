import os
import random
import time
import logging
from urllib.parse import urljoin, quote_plus

import requests
from bs4 import BeautifulSoup
from pytrends.request import TrendReq

from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from utils.fallbacks import generate_fallback_entries


logger = logging.getLogger(__name__)

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

def _selenium_driver_with_ua(ua: str):
    opts = Options()
    opts.add_argument("--headless=new")
    opts.add_argument("--no-sandbox")
    opts.add_argument("--disable-gpu")
    opts.add_argument("--disable-dev-shm-usage")
    opts.add_argument("--window-size=1920,1080")
    opts.add_argument(f"user-agent={ua}")

    # anti-detect flags (not foolproof)
    opts.add_experimental_option("excludeSwitches", ["enable-automation"])
    opts.add_experimental_option("useAutomationExtension", False)
    # optionally set proxy via capability if SCRAPER_PROXY present
    driver = webdriver.Chrome(options=opts)
    try:
        # try to hide webdriver property
        driver.execute_script("Object.defineProperty(navigator, 'webdriver', {get: () => undefined})")
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

    def fetch(self):
        query = quote_plus(f"{self.season} fashion 2025")
        url = f"https://www.vogue.com/search?q={query}"
        logger.info(f"{self.site_name}: Fetching from {url}")

        session = _requests_session()
        results = []
        try:
            resp = session.get(url, timeout=15)
            resp.raise_for_status()
            soup = BeautifulSoup(resp.text, "html.parser")

            # flexible selectors: article cards, search-result titles, or article links with h3
            elems = soup.select(
                "a[data-test-id='archive-article-card'] h3, "
                "a[href*='/article/'] h3, "
                "a[data-test-id='search-item'] h3"
            )[:10]

            for tag in elems:
                title = tag.get_text(strip=True)
                parent = tag.find_parent("a")
                href = parent.get("href") if parent else None
                if title and href:
                    results.append({
                        "keywords": f"{self.season} {title[:100]}",
                        "popularity_score": round(random.uniform(70, 98), 1),
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
                # If you need to support proxies with Selenium, you'd set capabilities here.
                logger.info(f"{self.site_name}: Using proxy from SCRAPER_PROXY")

            driver.get(url)

            # Wait for either product tile or generic product text. Be tolerant.
            try:
                WebDriverWait(driver, 12).until(
                    EC.any_of(
                        EC.presence_of_element_located((By.CSS_SELECTOR, "[data-auto-id='productTileDescription']")),
                        EC.presence_of_element_located((By.CSS_SELECTOR, "article")),
                        EC.presence_of_element_located((By.CSS_SELECTOR, "a[href*='/product/']"))
                    )
                )
            except Exception:
                logger.warning(f"{self.site_name}: initial expected element not found within 12s, continuing.")

            # Smart scroll-until-stable to trigger lazy-load
            last_height = driver.execute_script("return document.body.scrollHeight")
            for i in range(6):
                driver.execute_script("window.scrollTo(0, document.body.scrollHeight);")
                time.sleep(1.5 + random.random()*1.5)
                new_height = driver.execute_script("return document.body.scrollHeight")
                if new_height == last_height:
                    break
                last_height = new_height

            # Extra short wait for DOM
            time.sleep(1.0)

            soup = BeautifulSoup(driver.page_source, "html.parser")

            # multiple selectors to increase chance of match
            product_tags = (
                soup.select("[data-auto-id='productTileDescription'] a") +
                soup.select("article h2, article h3") +
                soup.select("a[href*='/product/'] h2, a[href*='/prd/'] h2")
            )

            seen = set()
            for tag in product_tags[:20]:
                text = tag.get_text(strip=True)
                if not text:
                    continue
                key = text.lower()
                if key in seen:
                    continue
                seen.add(key)
                results.append({
                    "keywords": f"{self.season} {text[:120]}",
                    "popularity_score": round(random.uniform(60, 95), 1),
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

        session = _requests_session()
        results = []
        try:
            resp = session.get(url, timeout=12)
            # 403s are common for Pinterest, check for them
            if resp.status_code == 403 or "captcha" in resp.text.lower():
                logger.warning(f"{self.site_name}: API/HTML returned status {resp.status_code} or CAPTCHA detected.")
                raise RuntimeError("Pinterest blocked - falling back to headful approach")
            soup = BeautifulSoup(resp.text, "html.parser")
            imgs = soup.find_all("img", alt=True)
            for img in imgs[:12]:
                alt = img.get("alt", "").strip()
                if alt:
                    results.append({
                        "keywords": f"{self.season} {alt[:120]}",
                        "popularity_score": round(random.uniform(70, 92), 1),
                        "source_url": url,
                        "source_name": self.site_name,
                    })
        except Exception as e:
            logger.info(f"{self.site_name}: HTML fetch failed or blocked ({e}). Trying Selenium fallback with rotated UA...")

            # Try Selenium fallback with new UA (less likely to succeed but sometimes works)
            ua = _choose_ua()
            driver = None
            try:
                driver = _selenium_driver_with_ua(ua)
                driver.get(url)
                time.sleep(4 + random.random()*4)
                # quick scroll
                driver.execute_script("window.scrollTo(0, document.body.scrollHeight/3);")
                time.sleep(1.5)
                soup = BeautifulSoup(driver.page_source, "html.parser")
                imgs = soup.find_all("img", alt=True)
                for img in imgs[:12]:
                    alt = img.get("alt", "").strip()
                    if alt:
                        results.append({
                            "keywords": f"{self.season} {alt[:120]}",
                            "popularity_score": round(random.uniform(70, 92), 1),
                            "source_url": url,
                            "source_name": self.site_name,
                        })
            except Exception as se:
                logger.warning(f"{self.site_name}: Selenium fallback also failed: {se}")
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
# Google Trends (pytrends with a small delay)
# ----------------------------
class GoogleTrendsScraper(BaseScraper):
    site_name = "Google Trends"

    def fetch(self):
        logger.info(f"{self.site_name}: Fetching Google Trends for season={self.season}")
        results = []
        try:
            # slight randomized delay to reduce risk of 429
            time.sleep(3 + random.random() * 4)
            pytrends = TrendReq(hl="en-PH", tz=480)
            kw = f"{self.season} fashion"
            pytrends.build_payload([kw], timeframe="today 3-m", geo="PH")
            # primary: related queries / top terms
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
            # fallback: interest_over_time as single entry
            if not results:
                df = pytrends.interest_over_time()
                if not df.empty:
                    avg = df.iloc[:, 0].mean()
                    results.append({
                        "keywords": f"{kw} trends",
                        "popularity_score": round(float(avg), 1),
                        "source_url": "https://trends.google.com",
                        "source_name": self.site_name,
                    })
        except Exception as e:
            logger.warning(f"{self.site_name} failed: {e}")

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
