from django.db import models


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
    image_url = models.URLField(blank=True)

    # Audit fields
    created_at = models.DateTimeField(auto_now_add=True)  # first created
    updated_at = models.DateTimeField(auto_now=True)      # last update

    class Meta:
        ordering = ["name"]
        indexes = [
            models.Index(fields=["sku"]),
            models.Index(fields=["name"]),
        ]

    def __str__(self):
        return f"{self.sku} - {self.name}"

    @property
    def quantity(self):
        """
        Computed field: always returns the linked Inventory's total_stock.
        Defaults to 0 if no inventory record exists yet.
        """
        return self.inventory.total_stock if hasattr(self, "inventory") else 0


class Inventory(models.Model):
    """
    Manages detailed inventory metrics for each product.
    One-to-one relationship with Product.
    """
    product = models.OneToOneField(Product, on_delete=models.CASCADE, related_name="inventory")
    stock_in = models.PositiveIntegerField(default=0)
    stock_out = models.PositiveIntegerField(default=0)
    total_stock = models.PositiveIntegerField(default=0)
    average_daily_sales = models.DecimalField(max_digits=10, decimal_places=2, default=0)

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def save(self, *args, **kwargs):
        # auto-calculate total stock every time
        self.total_stock = self.stock_in - self.stock_out
        super().save(*args, **kwargs)

    def __str__(self):
        return f"Inventory for {self.product.name}"
