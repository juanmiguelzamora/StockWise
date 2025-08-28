from django.urls import path
from .views import (
    signup_view,
    login_view,
    logout_view,
    password_reset_request_view,
    password_reset_confirm_view,
)

urlpatterns = [
    path("signup/", signup_view, name="signup"),
    path("login/", login_view, name="login"),
    path("logout/", logout_view, name="logout"),

    path("password-reset/", password_reset_request_view, name="password_reset_request"),
    path("password-reset-confirm/", password_reset_confirm_view, name="password_reset_confirm"),
]
