from django.utils.timezone import now
from collections import Counter
from .models import TrendItem

SEASON_KEYWORDS = {
    "summer": ["shirt", "shorts", "sunglasses", "swimwear", "tank"],
    "winter": ["coat", "jacket", "sweater", "boots", "scarf"],
    "spring": ["dress", "skirt", "cardigan", "light jacket"],
    "autumn": ["hoodie", "jeans", "boots", "sweater"],
}

def get_current_season():
    """Return current season name based on month"""
    month = now().month
    if month in [12, 1, 2]:
        return "winter"
    elif month in [3, 4, 5]:
        return "spring"
    elif month in [6, 7, 8]:
        return "summer"
    else:
        return "autumn"

def predict_trends(top_n=5):
    """Rule-based trend predictor with frequency + season weighting"""
    items = TrendItem.objects.all()
    if not items.exists():
        return []

    # Count frequency of all keywords
    freq = Counter([i.keyword.lower() for i in items])

    season = get_current_season()
    season_keywords = SEASON_KEYWORDS.get(season, [])

    scores = {}
    for keyword, count in freq.items():
        score = count

        # Bonus if item matches seasonal keywords
        if any(season_kw in keyword for season_kw in season_keywords):
            score *= 1.5  # seasonal weight factor

        scores[keyword] = score

    # Sort and return top N items
    ranked = sorted(scores.items(), key=lambda x: x[1], reverse=True)
    return [{"keyword": k, "score": v} for k, v in ranked[:top_n]]


def predict_trending_for_season(season: str, top_n: int = 5):
    """Predict trends for a given season (DB + seasonal weighting)"""
    items = TrendItem.objects.filter(season=season)
    if not items.exists():
        return []

    freq = Counter([i.keyword.lower() for i in items])
    season_keywords = SEASON_KEYWORDS.get(season, [])

    scores = {}
    for keyword, count in freq.items():
        score = count
        if any(season_kw in keyword for season_kw in season_keywords):
            score *= 1.5
        scores[keyword] = score

    ranked = sorted(scores.items(), key=lambda x: x[1], reverse=True)
    return [{"keyword": k, "score": v} for k, v in ranked[:top_n]]
