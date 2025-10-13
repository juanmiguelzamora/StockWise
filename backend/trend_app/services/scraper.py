from pytrends.request import TrendReq
from trend_app.models import TrendItem
from datetime import datetime
import logging, time, random

logger = logging.getLogger(__name__)

def get_current_season():
    """
    Return season/event label based on PH events + climate patterns.
    Uses month + day ranges for better accuracy.
    """
    today = datetime.now()
    month, day = today.month, today.day

    # Christmas season (Sept–Dec, extended in PH culture)
    if month in [9, 10, 11, 12]:
        return "christmas"

    # Valentines (Feb 7–21)
    if month == 2 and 7 <= day <= 21:
        return "valentines"

    # Halloween (Oct 15 – Nov 2)
    if (month == 10 and day >= 15) or (month == 11 and day <= 2):
        return "halloween"

    # Back to school (June)
    if month == 6:
        return "back_to_school"

    # Summer (Mar–May)
    if 3 <= month <= 5:
        return "summer"

    # Rainy season (Jun–Aug)
    if 6 <= month <= 8:
        return "rainy"

    # Fall-like fashion (Sept–Nov, but not Halloween/Christmas tagged already)
    if 9 <= month <= 11:
        return "fall"

    return "general"



def scrape_trending_clothes(max_retries=3, subset_size=2):
    """
    Scrape trending fashion-related keywords from Google Trends,
    update/create records, and archive old ones.
    Runs only a subset of keywords per execution to avoid hitting rate limits.
    """
    pytrends = TrendReq(hl="en-US", tz=360)
    season = get_current_season()

    seed_keywords = [
        "fashion", "clothes", "outfit", "dress", "jacket",
        "tshirt", "pants", "shorts", "hoodie", "shoes",
        "streetwear", "formal wear", "swimwear", "summer fashion",
        "winter outfit", "bag", "hat"
    ]


    # 👉 Randomly sample a subset to run this time
    keywords_to_run = random.sample(seed_keywords, subset_size)

    all_trends = []
    latest_keywords = set()

    for kw in keywords_to_run:
        retries = 0
        success = False

        while retries < max_retries and not success:
            try:
                # Build payload
                pytrends.build_payload([kw], timeframe="today 12-m", geo="PH")
                related = pytrends.related_queries().get(kw)

                if related and "rising" in related:
                    rising = related["rising"].head(10)  # top 10 rising queries
                    for _, row in rising.iterrows():
                        keyword = row["query"].strip()
                        score = float(row["value"]) / 100.0  # normalize 0–1

                        # ✅ Update if exists, else create
                        item, created = TrendItem.objects.update_or_create(
                            keyword=keyword,
                            season=season,
                            defaults={
                                "source": "google_trends",
                                "score": score,
                            },
                        )
                        all_trends.append(item)
                        latest_keywords.add(keyword)

                success = True

            except Exception as e:
                retries += 1
                wait_time = random.uniform(5, 10) * retries
                logger.error(f"❌ Failed scraping for keyword '{kw}' (attempt {retries}): {e}")
                if retries < max_retries:
                    logger.info(f"⏳ Retrying '{kw}' after {wait_time:.1f}s...")
                    time.sleep(wait_time)
                else:
                    logger.error(f"🚨 Giving up on keyword '{kw}' after {max_retries} attempts.")

        # 👌 random delay before next keyword
        time.sleep(random.uniform(3, 6))

    # ✅ Archive old trends for this season that are not in latest scrape
    if latest_keywords:
        TrendItem.objects.filter(season=season).exclude(
            keyword__in=latest_keywords
        ).update(source="archived", score=0.0)

    return all_trends
