from rest_framework import viewsets, status, filters, permissions
from rest_framework.decorators import action
from rest_framework.response import Response
from django.shortcuts import get_object_or_404
from .models import Product
from .serializers import ProductSerializer, ProductQuantityUpdateSerializer


class ProductViewSet(viewsets.ModelViewSet):
    """
    Provides full CRUD for products.
    - GET    /products/           → list products
    - POST   /products/           → create product
    - GET    /products/{id}/      → retrieve product
    - PUT    /products/{id}/      → update product
    - PATCH  /products/{id}/      → partial update
    - DELETE /products/{id}/      → delete product

    Extra:
    - PATCH  /products/{sku}/update_quantity/ → update quantity by SKU
    Supports ?category=, ?status=, ?search=
    """

    queryset = Product.objects.all().order_by("-id")
    serializer_class = ProductSerializer
    permission_classes = [permissions.IsAuthenticated]

    lookup_field = "sku"   # 👈 use SKU instead of id

    # enable search + ordering
    filter_backends = [filters.SearchFilter, filters.OrderingFilter]
    search_fields = ["sku", "name", "category__name"]
    ordering_fields = ["name", "category", "quantity", "id"]

    def get_queryset(self):
        queryset = super().get_queryset()

        # filter by category
        category = self.request.query_params.get("category")
        if category:
            queryset = queryset.filter(category__iexact=category)

        # filter by stock status
        status_param = self.request.query_params.get("status")
        if status_param == "in_stock":
            queryset = queryset.filter(quantity__gt=10)
        elif status_param == "low_stock":
            queryset = queryset.filter(quantity__gt=0, quantity__lte=10)
        elif status_param == "out_of_stock":
            queryset = queryset.filter(quantity=0)

        return queryset

    @action(detail=False, methods=["patch"], url_path=r"sku/(?P<sku>[^/.]+)/update_quantity")
    def update_quantity_by_sku(self, request, sku=None):
        """
        PATCH /products/sku/{sku}/update_quantity/
        Body: { "quantity": <int> }
        """
        product = get_object_or_404(Product, sku=sku)
        serializer = ProductQuantityUpdateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        product.quantity = serializer.validated_data["quantity"]
        product.save()

        return Response(ProductSerializer(product).data, status=status.HTTP_200_OK)
