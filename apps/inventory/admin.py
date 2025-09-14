from django.contrib import admin
from .models import InventoryProduct

@admin.register(InventoryProduct)
class InventoryProductAdmin(admin.ModelAdmin):
    list_display = ("product_name", "category", "quantity", "price", "supplier")