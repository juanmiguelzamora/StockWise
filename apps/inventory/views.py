from rest_framework import permissions, status, viewsets
from rest_framework.decorators import api_view, action, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response

from .models import InventoryProduct, StockTransaction
from .serializer import InventoryProductSerializer, StockTransactionSerializer


class IsStaffOrSuperuser(permissions.BasePermission):
    def has_permission(self, request, view):
        return bool(
            request.user and (request.user.is_staff or request.user.is_superuser)
        )


class ProductViewSet(viewsets.ModelViewSet):
    queryset = InventoryProduct.objects.all()
    serializer_class = InventoryProductSerializer

    def get_permissions(self):
        if self.action in ["create", "update", "partial_update", "destroy"]:
            return [IsStaffOrSuperuser()]
        return [permissions.AllowAny()]

    @action(detail=True, methods=["post"], permission_classes=[IsAuthenticated])
    def adjust_stock(self, request, pk=None):
        """
        Adjust stock safely and log a transaction.
        Example body: { "change": -1, "note": "Manual deduction" }
        """
        product = self.get_object()
        try:
            change = int(request.data.get("change", 0))
        except (TypeError, ValueError):
            return Response({"error": "Invalid change value"}, status=status.HTTP_400_BAD_REQUEST)

        note = request.data.get("note", "")

        # 🚫 Prevent negative stock
        if change < 0 and product.quantity + change < 0:
            return Response({"error": "Stock cannot go below 0"}, status=status.HTTP_400_BAD_REQUEST)

        # ✅ Update quantity
        product.quantity += change
        product.save()

        # ✅ Log transaction
        StockTransaction.objects.create(
            product=product,
            change=change,
            note=note
        )

        return Response({
            "product_id": product.product_id,
            "new_quantity": product.quantity,
            "change": change,
            "note": note,
        }, status=status.HTTP_200_OK)


class StockTransactionViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = StockTransaction.objects.all().order_by("-timestamp")
    serializer_class = StockTransactionSerializer
    permission_classes = [IsAuthenticated]
    pagination_class = None  # 👈 disables pagination for this viewset


# ✅ User info endpoint
@api_view(["GET"])
@permission_classes([IsAuthenticated])
def user_me(request):
    user = request.user
    return Response({
        "id": user.id,
        "email": user.email,
        "is_staff": user.is_staff,
        "is_superuser": user.is_superuser,
    })


