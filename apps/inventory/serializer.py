from rest_framework import serializers
from .models import InventoryProduct

class InventoryProductSerializer(serializers.ModelSerializer):
    class Meta:
        model = InventoryProduct
        fields = "__all__"
