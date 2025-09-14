from django.urls import path, include
from rest_framework.permissions import AllowAny
from django_rest_passwordreset.views import (
    reset_password_request_token,
    reset_password_confirm,
)

# Make views public
reset_password_request_token.permission_classes = [AllowAny]
reset_password_confirm.permission_classes = [AllowAny]

urlpatterns = [
    path('', include('django_rest_passwordreset.urls', namespace='password_reset')),
]