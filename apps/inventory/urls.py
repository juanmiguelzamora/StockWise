from django.urls import path
from apps.inventory.presentation import views   # ✅ Correct import

urlpatterns = [
    path('test/', views.test_connection, name='test_connection'),
]
