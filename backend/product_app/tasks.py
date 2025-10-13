from .models import Trend
from django.utils import timezone
from django.db.models import Count, Q  # For potential freq count

def compute_hot_trends(season: str):
    """Compute hot_score for Trends for a season.

    This implementation is synchronous and can be called from management command.
    If you use Celery, move logic into a @shared_task and call .delay().
    """
    trends = Trend.objects.filter(season__iexact=season)
    total = trends.count() or 1
    
    # IMPROVED: Pre-compute keyword frequency for bonus to hot_score
    keyword_counts = trends.values('keywords').annotate(freq=Count('keywords'))
    freq_dict = {item['keywords']: item['freq'] for item in keyword_counts}
    
    for t in trends:
        # FIXED: Use timezone.now() correctly
        age_days = (timezone.now().date() - t.scraped_at.date()).days if t.scraped_at else 0
        recency = max(0.5, 1.0 - (age_days / 365.0))
        
        # IMPROVED: hot_score = popularity * recency * (freq bonus if >1)
        base_score = float(t.popularity_score) * recency
        freq_bonus = freq_dict.get(t.keywords, 1)
        if freq_bonus > 1:
            base_score *= (1 + (freq_bonus - 1) * 0.2)  # 20% boost per extra occurrence
        
        t.hot_score = min(100.0, base_score)  # Cap at 100
        t.save(update_fields=["hot_score"])
    
    return f"Computed hot scores for {total} trends (with frequency bonuses)"