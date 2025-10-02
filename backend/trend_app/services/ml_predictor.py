import pickle
from pathlib import Path
from django.conf import settings

MODEL_PATH = Path(settings.BASE_DIR) / "trend_app" / "ml_model.pkl"

def load_model():
    """Load vectorizer + classifier"""
    if not MODEL_PATH.exists():
        raise FileNotFoundError("❌ ML model not found. Run `python manage.py train_predictor` first.")

    with open(MODEL_PATH, "rb") as f:
        vectorizer, clf = pickle.load(f)
    return vectorizer, clf

def predict_trends(keywords, top_n=5):
    """
    Predict trending probability for given keywords.
    Returns top_n keywords ranked by probability.
    """
    vectorizer, clf = load_model()
    X = vectorizer.transform(keywords)
    probs = clf.predict_proba(X)[:, 1]  # trending probability

    scored = sorted(zip(keywords, probs), key=lambda x: x[1], reverse=True)
    return [{"keyword": kw, "score": round(float(p), 3)} for kw, p in scored[:top_n]]
