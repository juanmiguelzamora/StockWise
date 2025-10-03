#apps/inventory/serializer.py
from rest_framework import serializers
from .models import InventoryProduct
from .models import InventoryProduct, StockTransaction  # Make sure to import StockTransaction

class InventoryProductSerializer(serializers.ModelSerializer):
    image_url = serializers.SerializerMethodField()
    last_change = serializers.SerializerMethodField()  # <-- new field

    class Meta:
        model = InventoryProduct
        fields = "__all__"
        extra_fields = ["image_url", "last_change"]

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

    class Meta:
        model = StockTransaction
        fields = ["id", "product", "product_name", "change", "timestamp", "note"]