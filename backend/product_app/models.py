from django.db import models
from django.utils import timezone


class Category(models.Model):
    """
    Separate table for product categories to ensure data consistency
    and allow relationships (instead of free-text).
    """
    name = models.CharField(max_length=128, unique=True)

    def __str__(self):
        return self.name


class Product(models.Model):
    """
    Core Product model representing inventory items.
    SKU is unique and used as the lookup field in API endpoints.
    """
    sku = models.CharField(max_length=64, unique=True, db_index=True)
    name = models.CharField(max_length=255, db_index=True)
    description = models.TextField(blank=True)  # optional long text
    category = models.ForeignKey(
        Category, on_delete=models.SET_NULL, null=True, related_name="products"
    )
    quantity = models.PositiveIntegerField(default=0)
    image_url = models.URLField(blank=True)

    # Audit fields
    created_at = models.DateTimeField(auto_now_add=True)  # first created
    updated_at = models.DateTimeField(auto_now=True)      # last update

    class Meta:
        ordering = ["name"]   # default sort
        indexes = [
            models.Index(fields=["sku"]),
            models.Index(fields=["name"]),
        ]

    def __str__(self):
        return f"{self.sku} - {self.name}"
