from django.contrib import admin
from django.urls import path, include
from django.http import JsonResponse
from django.middleware.csrf import get_token

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
            "users": "/api/v1/users/",
            "auth": "/api/v1/auth/"
        }
    })

def csrf_token_view(request):
    return JsonResponse({"csrfToken": get_token(request)})

urlpatterns = [
    path('', root_view, name='root'),
    path('admin/', admin.site.urls),

    path('api/v1/', api_root_view, name='api-root'),
    path('api/v1/users/', include('apps.users.urls')),   # signup/login/logout
    path('api/v1/auth/', include('apps.users.auth_urls')),  # password reset
    path('api/v1/auth/csrf/', csrf_token_view, name='csrf-token'),
]
