from rest_framework import serializers
from django.db import transaction
from django.utils import timezone
from .models import Product, Inventory, SalesHistory, StockMovement


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
        with transaction.atomic():
            inventory, _ = Inventory.objects.select_for_update().get_or_create(product=instance)
            old_quantity = inventory.total_stock or 0
            change = new_quantity - old_quantity

            if change > 0:
                inventory.stock_in += change
            elif change < 0:
                units_sold = abs(change)
                inventory.stock_out += units_sold
                history, _ = SalesHistory.objects.get_or_create(
                    product=instance,
                    date=timezone.now().date(),
                    defaults={"units_sold": 0},
                )
                history.units_sold += units_sold
                history.save(update_fields=["units_sold"])

            inventory.total_stock = new_quantity
            inventory.save()
            if change:
                StockMovement.objects.create(
                    product=instance,
                    change=change,
                    quantity_after=new_quantity,
                )

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


class SalesHistorySerializer(serializers.ModelSerializer):
    product_name = serializers.CharField(source="product.name", read_only=True)
    sku = serializers.CharField(source="product.sku", read_only=True)
    image = serializers.CharField(source="product.image_url", read_only=True)
    change = serializers.SerializerMethodField()

    def get_change(self, obj):
        return -obj.units_sold

    class Meta:
        model = SalesHistory
        fields = ["id", "product_name", "sku", "image", "units_sold", "change", "date"]


class StockMovementSerializer(serializers.ModelSerializer):
    product_name = serializers.CharField(source="product.name", read_only=True)
    sku = serializers.CharField(source="product.sku", read_only=True)
    image = serializers.CharField(source="product.image_url", read_only=True)
    date = serializers.DateTimeField(source="created_at", read_only=True)

    class Meta:
        model = StockMovement
        fields = ["id", "product_name", "sku", "image", "change", "quantity_after", "date"]
