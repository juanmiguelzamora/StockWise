from rest_framework import viewsets, status, filters, permissions
from rest_framework.response import Response
from django.db.models import Sum, Avg, Value, DecimalField, IntegerField
from django.db.models.functions import Coalesce

from .models import Product, Inventory
from .serializers import (
    ProductSerializer,
    ProductQuantityUpdateSerializer,
    InventorySerializer,
    InventorySummarySerializer,
)


class ProductViewSet(viewsets.ModelViewSet):
    queryset = Product.objects.all().order_by("-id")
    serializer_class = ProductSerializer
    permission_classes = [permissions.IsAuthenticated]
    #permission_classes = [permissions.AllowAny]

    lookup_field = "sku"

    filter_backends = [filters.SearchFilter, filters.OrderingFilter]
    search_fields = ["sku", "name", "category__name"]
    ordering_fields = ["name", "category", "id"]

    def get_queryset(self):
        queryset = super().get_queryset()
        category = self.request.query_params.get("category")
        if category:
            queryset = queryset.filter(category__iexact=category)

        status_param = self.request.query_params.get("status")
        if status_param == "in_stock":
            queryset = queryset.filter(inventory__total_stock__gt=10)
        elif status_param == "low_stock":
            queryset = queryset.filter(
                inventory__total_stock__gt=0, inventory__total_stock__lte=10
            )
        elif status_param == "out_of_stock":
            queryset = queryset.filter(inventory__total_stock=0)

        return queryset

    def partial_update(self, request, *args, **kwargs):
        """
        PATCH /products/{sku}/
        - If payload has "quantity" → delegate to ProductQuantityUpdateSerializer
        - Else → fall back to normal ProductSerializer
        """
        instance = self.get_object()

        if "quantity" in request.data:
            serializer = ProductQuantityUpdateSerializer(
                instance, data=request.data, partial=True
            )
            serializer.is_valid(raise_exception=True)
            updated_product = serializer.save()
            return Response(ProductSerializer(updated_product).data, status=status.HTTP_200_OK)

        # default behavior for other fields
        return super().partial_update(request, *args, **kwargs)


class InventoryViewSet(viewsets.ModelViewSet):
    queryset = Inventory.objects.select_related("product").all()
    serializer_class = InventorySerializer
    permission_classes = [permissions.IsAuthenticated]
    #permission_classes = [permissions.AllowAny]

    def summary(self, request):
        data = Inventory.objects.aggregate(
            stock_in=Coalesce(Sum("stock_in"), Value(0, output_field=IntegerField())),
            stock_out=Coalesce(Sum("stock_out"), Value(0, output_field=IntegerField())),
            total_stock=Coalesce(Sum("total_stock"), Value(0, output_field=IntegerField())),
            average_daily_sales=Coalesce(
                Avg("average_daily_sales"),
                Value(0, output_field=DecimalField(max_digits=10, decimal_places=2)),
            ),
        )
        serializer = InventorySummarySerializer(data)
        return Response(serializer.data, status=status.HTTP_200_OK)
