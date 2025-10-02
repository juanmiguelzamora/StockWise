from django.core.management.base import BaseCommand
from trend_app.models import TrendItem
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.linear_model import LogisticRegression
import pickle
from pathlib import Path
from django.conf import settings

MODEL_PATH = Path(settings.BASE_DIR) / "trend_app" / "ml_model.pkl"

class Command(BaseCommand):
    help = "Train ML predictor from TrendItem data"

    def handle(self, *args, **kwargs):
        # Pull keywords + seasons directly from DB
        items = TrendItem.objects.all()

        if not items.exists():
            self.stdout.write(self.style.ERROR(" No TrendItem data found in DB. Scrape first!"))
            return

        texts = [i.keyword for i in items]
        # Example: mark items that appear more than once as trending
        labels = [i.season for i in items]

        # Train TF-IDF + Logistic Regression
        vectorizer = TfidfVectorizer()
        X = vectorizer.fit_transform(texts)
        clf = LogisticRegression(max_iter=1000)
        clf.fit(X, labels)

        # Save model
        with open(MODEL_PATH, "wb") as f:
            pickle.dump((vectorizer, clf), f)

        self.stdout.write(self.style.SUCCESS(f" Model trained and saved to {MODEL_PATH}"))
