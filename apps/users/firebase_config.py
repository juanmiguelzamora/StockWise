#apps/users/firebase_config.py
import firebase_admin
from firebase_admin import credentials, auth

# Initialize Firebase Admin SDK
# You'll need to download your service account key from Firebase Console
# For now, we'll use the default credentials (if you have GOOGLE_APPLICATION_CREDENTIALS set)
try:
    # Try to initialize with default credentials
    firebase_admin.initialize_app()
except ValueError:
    # If already initialized, that's fine
    pass

# Export the auth module for use in views
firebase_auth = auth