from celery import shared_task
from .services.scraper import scrape_trending_clothes

@shared_task
def refresh_trends():
    scrape_trending_clothes()
