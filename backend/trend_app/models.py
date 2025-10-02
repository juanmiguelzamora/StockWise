from django.db import models
from django.utils import timezone

class TrendItem(models.Model):
    season = models.CharField(max_length=50)  # e.g., "summer", "winter"
    keyword = models.CharField(max_length=100)  # e.g., "floral dress"
    source = models.CharField(max_length=100)   # e.g., "google_trends", "scraper"
    score = models.FloatField(default=0.0)      # popularity score
    created_at = models.DateTimeField(default=timezone.now)

    def __str__(self):
        return f"{self.keyword} ({self.season})"
