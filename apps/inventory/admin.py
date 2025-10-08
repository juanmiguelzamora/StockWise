from django.contrib import admin
from .models import InventoryProduct

@admin.register(InventoryProduct)
class InventoryProductAdmin(admin.ModelAdmin):
    list_display = ("product_name", "sku","category", "quantity")
    fields = ("product_name", "sku", "category","quantity", "image")  # include image field
