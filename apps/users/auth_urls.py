from django.urls import path
from .views import (
    RegisterView,
    LoginView,
    LogoutView,
    PasswordResetRequestView,
    PasswordResetConfirmView,
)

urlpatterns = [
    path("signup/", RegisterView.as_view(), name="signup"),
    path("login/", LoginView.as_view(), name="login"),
    path("logout/", LogoutView.as_view(), name="logout"),
    path("password-reset/", PasswordResetRequestView.as_view(), name="password_reset_request"),  # ✅ fixed
    path("password-reset-confirm/", PasswordResetConfirmView.as_view(), name="password_reset_confirm"),
]