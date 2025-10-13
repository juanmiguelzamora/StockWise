from django.contrib import admin
from django.utils.html import format_html
from django.urls import reverse
from django.conf import settings
from .models import Category, Product, Supplier, Inventory, SalesHistory


@admin.register(Category)
class CategoryAdmin(admin.ModelAdmin):
    list_display = ("id", "name")
    search_fields = ("name",)


class InventoryInline(admin.StackedInline):
    """
    Inline for Inventory (one-to-one with Product) to edit together.
    """
    model = Inventory
    extra = 1  # Show one empty form by default
    fields = ("stock_in", "stock_out", "total_stock", "average_daily_sales")
    readonly_fields = ("total_stock", "average_daily_sales")  # Computed on save


class SalesHistoryInline(admin.TabularInline):
    """
    Inline for SalesHistory to add daily sales entries easily.
    """
    model = SalesHistory
    extra = 0  # No empty forms; add as needed
    fields = ("date", "units_sold")
    list_display = ("date", "units_sold")


@admin.register(Supplier)
class SupplierAdmin(admin.ModelAdmin):
    list_display = ("id", "name", "contact_email", "phone", "lead_time_days")
    search_fields = ("name", "contact_email")
    list_filter = ("lead_time_days",)


@admin.register(Product)
class ProductAdmin(admin.ModelAdmin):
    list_display = ("id", "sku", "name", "category", "supplier", "quantity", "image_preview")
    search_fields = ("sku", "name", "description")
    list_filter = ("category", "supplier")
    inlines = [SalesHistoryInline]  # Edit inventory/history inline
    readonly_fields = ("image_preview",)  # For image display

    def image_preview(self, obj):
        """
        Custom method to display image thumbnail in admin list.
        Uses MEDIA_URL for paths like 'products/mouse.png' (full: /media/products/mouse.png).
        """
        if obj.image_url:
            url = f"{settings.MEDIA_URL}{obj.image_url}"  # E.g., /media/products/mouse.png
            return format_html('<img src="{}" width="50" height="50" style="object-fit: cover;" />', url)
        return "No Image"
    image_preview.short_description = "Image Preview"


@admin.register(Inventory)
class InventoryAdmin(admin.ModelAdmin):
    list_display = ("id", "product", "total_stock", "average_daily_sales", "updated_at")
    search_fields = ("product__name", "product__sku")
    list_filter = ("updated_at",)
    readonly_fields = ("total_stock", "average_daily_sales")  # Computed


@admin.register(SalesHistory)
class SalesHistoryAdmin(admin.ModelAdmin):
    list_display = ("id", "product", "date", "units_sold")
    search_fields = ("product__name", "date")
    list_filter = ("date", "product__category")
    date_hierarchy = "date"  # Filter by date range