from django.urls import path, include
from .views import current_user
from .views import UserManagementView
from django.urls import path
from .views import AdminOnlyTokenObtainPairView


from rest_framework.routers import DefaultRouter
from rest_framework_simplejwt.views import (
    TokenObtainPairView,
    TokenRefreshView,
    TokenVerifyView,
)
from .views import (
    RegisterView,
    LogoutView,
    PasswordResetRequestView,
    PasswordResetConfirmView,
    UserViewSet,
)

app_name = "users"

# Router for user management (admin/staff only)
router = DefaultRouter()
router.register("user-management", UserViewSet, basename="user")

urlpatterns = [
    # 🔑 Authentication
    path("signup/", RegisterView.as_view(), name="signup"),          # Register
   path("login/", AdminOnlyTokenObtainPairView.as_view(), name="login"),  # ✅ use custom view   # Login (admin only)
    path("verify/", TokenVerifyView.as_view(), name="verify"),       # JWT verify
    path("logout/", LogoutView.as_view(), name="logout"),            # Logout (blacklist token)

    # 🔑 Password reset
    path("password-reset/", PasswordResetRequestView.as_view(), name="password_reset"),
    path("password-reset-confirm/", PasswordResetConfirmView.as_view(), name="password_reset_confirm"),

    path("me/", current_user, name="current_user"),

    # 👤 User CRUD (admin/staff only)
    path("", include(router.urls)),
]
