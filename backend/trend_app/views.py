from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from .serializers import TrendItemSerializer
from .services.scraper import scrape_trending_clothes
from .models import TrendItem
from rest_framework.permissions import AllowAny
import pickle
from pathlib import Path
from django.conf import settings


MODEL_PATH = Path(settings.BASE_DIR) / "trend_app" / "ml_model.pkl"


class TrendListView(APIView):
    permission_classes = [AllowAny]

    def get(self, request, *args, **kwargs):
        season = request.query_params.get("season", "christmas")
        items = TrendItem.objects.filter(season=season)
        keywords = [i.keyword for i in items]

        if not keywords:
            return Response({"error": f"No keywords available for {season}"}, status=404)

        if not MODEL_PATH.exists():
            return Response({"error": "ML model not found. Run `python manage.py train_predictor` first."}, status=500)

        with open(MODEL_PATH, "rb") as f:
            vectorizer, clf = pickle.load(f)

        X_new = vectorizer.transform(keywords)
        predicted = clf.predict(X_new)
        predicted_probs = clf.predict_proba(X_new)

        predictions = []
        for keyword, label, probs in zip(keywords, predicted, predicted_probs):
            predictions.append({
                "keyword": keyword,
                "predicted_season": label,
                "probabilities": dict(zip(clf.classes_, probs.round(3)))
            })

        return Response({"season": season, "predictions": predictions}, status=200)


class ScrapeTrendsView(APIView):
    permission_classes = [AllowAny]

    def post(self, request, *args, **kwargs):
        try:
            items = scrape_trending_clothes()
            serializer = TrendItemSerializer(items, many=True)
            keywords = [i.keyword for i in items]

            if not keywords:
                return Response({"items": [], "predictions": []}, status=201)

            if not MODEL_PATH.exists():
                return Response({"error": "ML model not found. Run `python manage.py train_predictor` first."}, status=500)

            with open(MODEL_PATH, "rb") as f:
                vectorizer, clf = pickle.load(f)

            X_new = vectorizer.transform(keywords)
            predicted = clf.predict(X_new)
            predicted_probs = clf.predict_proba(X_new)

            predictions = []
            for keyword, label, probs in zip(keywords, predicted, predicted_probs):
                predictions.append({
                    "keyword": keyword,
                    "predicted_season": label,
                    "probabilities": dict(zip(clf.classes_, probs.round(3)))
                })

            return Response({"items": serializer.data, "predictions": predictions}, status=201)

        except Exception as e:
            return Response({"error": f"Scraping failed: {str(e)}"}, status=500)


class TrendPredictionView(APIView):
    permission_classes = [AllowAny]

    def get(self, request):
        try:
            items = TrendItem.objects.all()
            keywords = [i.keyword for i in items]

            if not keywords:
                return Response({"error": "No keywords available for prediction"}, status=404)

            if not MODEL_PATH.exists():
                return Response({"error": "ML model not found. Run `python manage.py train_predictor` first."}, status=500)

            with open(MODEL_PATH, "rb") as f:
                vectorizer, clf = pickle.load(f)

            X_new = vectorizer.transform(keywords)
            predicted = clf.predict(X_new)
            predicted_probs = clf.predict_proba(X_new)

            predictions = []
            for keyword, label, probs in zip(keywords, predicted, predicted_probs):
                predictions.append({
                    "keyword": keyword,
                    "predicted_season": label,
                    "probabilities": dict(zip(clf.classes_, probs.round(3)))
                })

            return Response({"predictions": predictions}, status=200)

        except Exception as e:
            return Response({"error": f"Prediction failed: {str(e)}"}, status=500)


class TrendForecastView(APIView):
    permission_classes = [AllowAny]

    def get(self, request):
        """Predict NEXT season/event for current keywords"""
        items = TrendItem.objects.all()
        keywords = [i.keyword for i in items]

        if not keywords:
            return Response({"error": "No keywords available for forecast"}, status=404)

        if not MODEL_PATH.exists():
            return Response({"error": "ML model not found. Run `python manage.py train_predictor` first."}, status=500)

        with open(MODEL_PATH, "rb") as f:
            vectorizer, clf = pickle.load(f)

        X_new = vectorizer.transform(keywords)
        predicted_next = clf.predict(X_new)

        forecast = []
        for kw, nxt in zip(keywords, predicted_next):
            forecast.append({"keyword": kw, "forecast_season": nxt})

        return Response({"forecast": forecast}, status=200)
