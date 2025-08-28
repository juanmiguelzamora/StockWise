# apps/users/urls.py
from django.urls import path
from .views import signup_view, login_view, logout_view

app_name = 'users'

urlpatterns = [
    path("signup/", signup_view, name="signup"),
    path("login/", login_view, name="login"),
    path("logout/", logout_view, name="logout"),  # ✅ fixed
    # path("protected/", views.protected_view, name="protected"),
]
