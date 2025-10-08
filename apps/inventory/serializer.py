#apps/inventory/serializer.py
from rest_framework import serializers
from .models import InventoryProduct
from .models import InventoryProduct, StockTransaction  # Make sure to import StockTransaction

class InventoryProductSerializer(serializers.ModelSerializer):
    image_url = serializers.SerializerMethodField()
    last_change = serializers.SerializerMethodField()  # <-- new field

    class Meta:
        model = InventoryProduct
        fields = [
            "product_id",
            "product_name",
            "sku",
            "category",
            "quantity",
            "image",
            "created_at",
            "updated_at",
            "image_url",
            "last_change",
        ]

    def get_image_url(self, obj):
        request = self.context.get("request")
        if obj.image and request:
            return request.build_absolute_uri(obj.image.url)
        return None

    def get_last_change(self, obj):
        last_tx = obj.transactions.order_by("-timestamp").first()
        return last_tx.change if last_tx else 0


class StockTransactionSerializer(serializers.ModelSerializer):
    product_name = serializers.CharField(source="product.product_name", read_only=True)
    description = serializers.CharField(source="product.description", read_only=True)
    price = serializers.DecimalField(source="product.price", max_digits=10, decimal_places=2, read_only=True)
    sku = serializers.CharField(source="product.sku", read_only=True)
    category = serializers.CharField(source="product.category", read_only=True)
    new_quantity = serializers.IntegerField(source="product.quantity", read_only=True)
    image_url = serializers.SerializerMethodField()

    class Meta:
        model = StockTransaction
        fields = [
            "id",
            "product",
            "product_name",
            "description",
            "price",
            "sku",
            "category",
            "new_quantity",
            "image_url",
            "change",
            "timestamp",
            "note",
        ]

    def get_image_url(self, obj):
        request = self.context.get("request")
        if obj.product.image and request:
            return request.build_absolute_uri(obj.product.image.url)
        return None
