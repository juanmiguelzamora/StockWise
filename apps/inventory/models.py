from django.db import models

class InventoryProduct(models.Model):
    product_id = models.AutoField(primary_key=True)
    product_name = models.CharField(max_length=255)
    sku = models.CharField(max_length=100, unique=True, null=True, blank=True)# ✅ add SKU
    category = models.CharField(max_length=100, null=True, blank=True) 
    quantity = models.IntegerField(default=0)
    image = models.ImageField(upload_to="products/", null=True, blank=True) 
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = "inventory_product"
        verbose_name = "Product"
        verbose_name_plural = "Products"

    def __str__(self):
        return self.product_name
    

class StockTransaction(models.Model):
    product = models.ForeignKey(
        InventoryProduct,
        on_delete=models.CASCADE,
        related_name="transactions"
    )
    change = models.IntegerField()
    timestamp = models.DateTimeField(auto_now_add=True)
    note = models.CharField(max_length=255, null=True, blank=True)