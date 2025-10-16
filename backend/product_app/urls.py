from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import ProductViewSet, InventoryViewSet, StockHistoryViewSet

router = DefaultRouter()
router.register(r"products", ProductViewSet, basename="product")
router.register(r"inventory", InventoryViewSet, basename="inventory")
router.register(r"stock/history", StockHistoryViewSet, basename="stock-history")

urlpatterns = router.urls
