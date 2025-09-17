from rest_framework import serializers
from .models import Product


class ProductSerializer(serializers.ModelSerializer):
    """
    Serializer used for GET/POST/PUT/PATCH of products.
    Includes both `id` (DB PK) and `sku` (business identifier).
    """
    id = serializers.IntegerField(read_only=True)  # expose pk
    category = serializers.CharField(source="category.name", default="")

    class Meta:
        model = Product
        fields = ['id', 'sku', 'name', 'category', 'quantity', 'image_url']


class ProductQuantityUpdateSerializer(serializers.Serializer):
    """
    Serializer for PATCH request to update quantity.
    Accepts only the 'quantity' field (integer >= 0).
    """
    quantity = serializers.IntegerField(min_value=0)

    def validate_quantity(self, value):
        if value < 0:
            raise serializers.ValidationError("Quantity cannot be negative.")
        return value
