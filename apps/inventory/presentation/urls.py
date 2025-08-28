from django.urls import path
from . import views   

app_name = 'presentation'

urlpatterns = [
    # Test endpoint for debugging
    path('test/', views.test_connection, name='test_connection'),
    
    # Product endpoints
    path('products/', views.create_product, name='create_product'),
    path('products/<str:product_id>/', views.get_product, name='get_product'),
    path('products/<str:product_id>/update/', views.update_product, name='update_product'),
    
    # User endpoints
    path('users/', views.create_user, name='create_user'),
    
    # Inventory management endpoints
    path('inventory/adjust-stock/', views.adjust_stock, name='adjust_stock'),
    path('inventory/report/', views.generate_inventory_report, name='generate_inventory_report'),
    
    # Legacy Firebase endpoint (for backward compatibility)
    path('firebase/protected/', views.protected_data, name='protected_data'),
]
