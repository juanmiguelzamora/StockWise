import jwt
from django.conf import settings
from django.contrib.auth import get_user_model
from rest_framework.authentication import BaseAuthentication
from rest_framework.exceptions import AuthenticationFailed

User = get_user_model()

class JWTAuthentication(BaseAuthentication):
    def authenticate(self, request):
        auth_header = request.headers.get("Authorization")

        if not auth_header:
            return None  # no header, skip

        parts = auth_header.split()
        if len(parts) != 2 or parts[0].lower() != "bearer":
            return None  # not a Bearer token

        token = parts[1]

        try:
            payload = jwt.decode(token, settings.SECRET_KEY, algorithms=["HS256"])
        except jwt.ExpiredSignatureError:
            raise AuthenticationFailed("⚠️ Token has expired. Please log in again.")
        except jwt.InvalidTokenError:
            raise AuthenticationFailed("⚠️ Invalid token. Please log in again.")

        user_id = payload.get("user_id")
        if not user_id:
            raise AuthenticationFailed("⚠️ Invalid token payload: user_id missing.")

        try:
            user = User.objects.get(id=user_id)
        except User.DoesNotExist:
            raise AuthenticationFailed("⚠️ User not found.")

        return (user, None)
