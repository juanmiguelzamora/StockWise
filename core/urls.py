from django.contrib import admin
from django.urls import path, include
from django.http import JsonResponse
from django.middleware.csrf import get_token
from rest_framework_simplejwt.views import (
    TokenObtainPairView,
    TokenRefreshView,
)

# -------------------------
# Root views
# -------------------------
def root_view(request):
    return JsonResponse({
        "message": "StockWise Inventory Management API",
        "version": "1.0.0",
        "endpoints": {
            "admin": "/admin/",
            "api": "/api/v1/",
            "frontend": "http://localhost:5173"
        },
        "status": "running"
    })


def api_root_view(request):
    return JsonResponse({
        "message": "API root",
        "available_endpoints": {
            "auth-users": "/api/v1/users/",               # signup/login/logout/reset
            "user-management": "/api/v1/users/user-management/",  # CRUD (staff/admin)
            "csrf": "/api/v1/auth/csrf/",
            "token": "/api/v1/token/",
            "token-refresh": "/api/v1/token/refresh/",
        }
    })


def csrf_token_view(request):
    return JsonResponse({"csrfToken": get_token(request)})


# -------------------------
# URL patterns
# -------------------------
urlpatterns = [
    path("", root_view, name="root"),
    path("admin/", admin.site.urls),

    # API root
    path("api/v1/", api_root_view, name="api-root"),


    # Users + Auth (signup/login/logout/password reset + CRUD)
    path("api/v1/users/", include("apps.users.urls")),

    # JWT auth (SimpleJWT)
    path("api/v1/token/", TokenObtainPairView.as_view(), name="token_obtain_pair"),
    path("api/v1/token/refresh/", TokenRefreshView.as_view(), name="token_refresh"),

    # CSRF token helper
    path("api/v1/auth/csrf/", csrf_token_view, name="csrf-token"),
    
]
