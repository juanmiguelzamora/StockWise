#apps/inventory/urls.py
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from apps.inventory.views import ProductViewSet, user_me
from apps.inventory.views import ProductViewSet, StockTransactionViewSet, user_me


# Router for ProductViewSet
router = DefaultRouter()
router.register("transactions", StockTransactionViewSet, basename="transactions")
router.register(r'', ProductViewSet, basename='inventory')  # ✅ just empty string


urlpatterns = [
  path("", include(router.urls)),   # ✅ no extra "api/"
    path("api/user/me/", user_me, name="user_me"),  # Current user info
]
