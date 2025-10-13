from django.urls import path
from .views import TrendListView, ScrapeTrendsView, TrendPredictionView, TrendForecastView

urlpatterns = [
    path("trends/", TrendListView.as_view(), name="trend-list"),
    path("trends/scrape/", ScrapeTrendsView.as_view(), name="trend-scrape"),
    path("trends/predict/", TrendPredictionView.as_view(), name="trend-predict"),
    path("trends/forecast/", TrendForecastView.as_view(), name="trend-forecast"),
]
