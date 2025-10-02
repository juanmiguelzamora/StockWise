from pytrends.request import TrendReq
from trend_app.models import TrendItem
from datetime import datetime
import logging, time, random

logger = logging.getLogger(__name__)

def get_current_season():
    """Return season based on PH climate (2 seasons: Dry and Wet)."""
    month = datetime.now().month
    if 12 <= month or month <= 5:  # December–May
        return "dry"
    else:  # June–November
        return "wet"


def scrape_trending_clothes(max_retries=3, subset_size=2):
    """
    Scrape trending fashion-related keywords from Google Trends,
    update/create records, and archive old ones.
    Runs only a subset of keywords per execution to avoid hitting rate limits.
    """
    pytrends = TrendReq(hl="en-US", tz=360)
    season = get_current_season()

    seed_keywords = ["fashion", "clothes", "outfit", "dress", "jacket"]

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
                pytrends.build_payload([kw], timeframe="now 7-d", geo="PH")
                related = pytrends.related_queries().get(kw)

                if related and "rising" in related:
                    rising = related["rising"].head(3)  # top 3 rising queries
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
