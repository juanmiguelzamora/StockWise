from django.urls import path, include
from rest_framework.routers import DefaultRouter
from apps.inventory.views import ProductViewSet, user_me

# Router for ProductViewSet
router = DefaultRouter()
router.register(r'products', ProductViewSet, basename='product')

urlpatterns = [
    path("api/", include(router.urls)),        # Products API
    path("api/user/me/", user_me, name="user_me"),  # Current user info
]
