from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from .serializers import TrendItemSerializer
from .services.scraper import scrape_trending_clothes
from .services.ml_predictor import predict_trends
from .models import TrendItem
from rest_framework.permissions import AllowAny

class TrendListView(APIView):
    permission_classes = [AllowAny]

    def get(self, request, *args, **kwargs):
        season = request.query_params.get("season", "wet")

        # Collect keywords from DB for this season
        items = TrendItem.objects.filter(season=season)
        keywords = [i.keyword for i in items]

        if not keywords:
            return Response(
                {"error": f"No keywords available for {season}"},
                status=status.HTTP_404_NOT_FOUND,
            )

        import pickle
        from pathlib import Path
        from django.conf import settings

        MODEL_PATH = Path(settings.BASE_DIR) / "trend_app" / "ml_model.pkl"

        predictions = []
        if MODEL_PATH.exists():
            with open(MODEL_PATH, "rb") as f:
                vectorizer, clf = pickle.load(f)

            X_new = vectorizer.transform(keywords)
            predicted = clf.predict(X_new)
            predicted_probs = clf.predict_proba(X_new)

            for keyword, label, probs in zip(keywords, predicted, predicted_probs):
                predictions.append({
                    "keyword": keyword,
                    "predicted_season": label,
                    "probabilities": dict(zip(clf.classes_, probs.round(3)))
                })
        else:
            return Response(
                {"error": "ML model not found. Run `python manage.py train_predictor` first."},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR,
            )

        return Response(
            {"season": season, "predictions": predictions},
            status=status.HTTP_200_OK,
        )



class ScrapeTrendsView(APIView):
    permission_classes = [AllowAny]

    def post(self, request, *args, **kwargs):
        try:
            items = scrape_trending_clothes()
            serializer = TrendItemSerializer(items, many=True)

            # Collect keywords from scraped items
            keywords = [i.keyword for i in items]

            predictions = []
            if keywords:
                import pickle
                from pathlib import Path
                from django.conf import settings

                MODEL_PATH = Path(settings.BASE_DIR) / "trend_app" / "ml_model.pkl"

                if MODEL_PATH.exists():
                    with open(MODEL_PATH, "rb") as f:
                        vectorizer, clf = pickle.load(f)

                    X_new = vectorizer.transform(keywords)
                    predicted = clf.predict(X_new)
                    predicted_probs = clf.predict_proba(X_new)

                    for keyword, label, probs in zip(keywords, predicted, predicted_probs):
                        predictions.append({
                            "keyword": keyword,
                            "predicted_season": label,
                            "probabilities": dict(zip(clf.classes_, probs.round(3)))
                        })
                else:
                    return Response(
                        {"error": "ML model not found. Run `python manage.py train_predictor` first."},
                        status=status.HTTP_500_INTERNAL_SERVER_ERROR,
                    )

            return Response(
                {
                    "items": serializer.data,
                    "predictions": predictions,
                },
                status=status.HTTP_201_CREATED,
            )

        except Exception as e:
            return Response(
                {"error": f"Scraping failed: {str(e)}"},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR,
            )





class TrendPredictionView(APIView):
    permission_classes = [AllowAny]

    def get(self, request):
        try:
            items = TrendItem.objects.all()
            keywords = [i.keyword for i in items]

            if not keywords:
                return Response(
                    {"error": "No keywords available for prediction"},
                    status=status.HTTP_404_NOT_FOUND,
                )

            import pickle
            from pathlib import Path
            from django.conf import settings

            MODEL_PATH = Path(settings.BASE_DIR) / "trend_app" / "ml_model.pkl"

            predictions = []
            if MODEL_PATH.exists():
                with open(MODEL_PATH, "rb") as f:
                    vectorizer, clf = pickle.load(f)

                X_new = vectorizer.transform(keywords)
                predicted = clf.predict(X_new)
                predicted_probs = clf.predict_proba(X_new)

                for keyword, label, probs in zip(keywords, predicted, predicted_probs):
                    predictions.append({
                        "keyword": keyword,
                        "predicted_season": label,
                        "probabilities": dict(zip(clf.classes_, probs.round(3)))
                    })
            else:
                return Response(
                    {"error": "ML model not found. Run `python manage.py train_predictor` first."},
                    status=status.HTTP_500_INTERNAL_SERVER_ERROR,
                )

            return Response(
                {"predictions": predictions},
                status=status.HTTP_200_OK,
            )

        except Exception as e:
            return Response(
                {"error": f"Prediction failed: {str(e)}"},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR,
            )

