from rest_framework import serializers
from .models import TrendItem

class TrendItemSerializer(serializers.ModelSerializer):
    class Meta:
        model = TrendItem
        fields = ["id", "season", "keyword", "source", "score", "created_at"]
