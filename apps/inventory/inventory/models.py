from django.db import models
from django.utils import timezone
import uuid


class Product(models.Model):
    """Product model for inventory management"""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    name = models.CharField(max_length=200)
    description = models.TextField(blank=True, null=True)
    price = models.DecimalField(max_digits=10, decimal_places=2)
    quantity = models.IntegerField(default=0)
    category = models.CharField(max_length=100, blank=True)
    sku = models.CharField(max_length=50, unique=True, blank=True)
    created_at = models.DateTimeField(default=timezone.now)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'inventory_product'
        verbose_name = 'Product'
        verbose_name_plural = 'Products'
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.name} - {self.sku}"

    @property
    def is_in_stock(self):
        """Check if product is in stock"""
        return self.quantity > 0

    @property
    def total_value(self):
        """Calculate total inventory value"""
        return self.price * self.quantity

    def save(self, *args, **kwargs):
        if not self.sku:
            self.sku = f"SKU-{self.id}"
        super().save(*args, **kwargs)
