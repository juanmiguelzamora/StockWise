from rest_framework import serializers
from .models import Product, Inventory


class InventoryMiniSerializer(serializers.ModelSerializer):
    """Compact inventory info to nest inside ProductSerializer."""
    stock_status = serializers.SerializerMethodField()

    class Meta:
        model = Inventory
        fields = ["stock_in", "stock_out", "total_stock", "average_daily_sales", "stock_status"]

    def get_stock_status(self, obj):
        """Return stock status label based on total stock."""
        if obj.total_stock == 0:
            return "out_of_stock"
        if obj.total_stock <= 10:
            return "low_stock"
        return "in_stock"


class ProductSerializer(serializers.ModelSerializer):
    """
    Serializer for products.
    Includes inline inventory details (no duplicate `quantity` field).
    """
    id = serializers.IntegerField(read_only=True)
    category = serializers.CharField(source="category.name", default="")
    inventory = InventoryMiniSerializer(read_only=True)

    class Meta:
        model = Product
        fields = ["id", "sku", "name", "description", "category", "image_url", "inventory"]


class ProductQuantityUpdateSerializer(serializers.Serializer):
    """
    Serializer for PATCH { "quantity": <int> } → updates Inventory.
    Always returns a full ProductSerializer response.
    """
    quantity = serializers.IntegerField(min_value=0)

    def validate_quantity(self, value):
        if value < 0:
            raise serializers.ValidationError("Quantity cannot be negative.")
        return value

    def update(self, instance, validated_data):
        """
        instance = Product
        validated_data = {"quantity": new_quantity}
        """
        new_quantity = validated_data["quantity"]
        inventory, _ = Inventory.objects.get_or_create(product=instance)
        old_quantity = inventory.total_stock or 0

        if new_quantity > old_quantity:
            inventory.stock_in += (new_quantity - old_quantity)
        elif new_quantity < old_quantity:
            inventory.stock_out += (old_quantity - new_quantity)

        inventory.total_stock = new_quantity
        inventory.save()

        # Refresh so inline inventory is updated
        instance.refresh_from_db()
        return instance

    def to_representation(self, instance):
        """Ensure PATCH response matches GET product format."""
        return ProductSerializer(instance).data


class InventorySerializer(serializers.ModelSerializer):
    """Detailed serializer for inventory, includes nested product."""
    product = ProductSerializer(read_only=True)

    class Meta:
        model = Inventory
        fields = ["id", "product", "stock_in", "stock_out", "total_stock", "average_daily_sales"]


class InventorySummarySerializer(serializers.Serializer):
    """Lightweight serializer for reporting (no nested product)."""
    stock_in = serializers.IntegerField()
    stock_out = serializers.IntegerField()
    total_stock = serializers.IntegerField()
    average_daily_sales = serializers.DecimalField(max_digits=10, decimal_places=2)
