from rest_framework import permissions, viewsets
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from .models import InventoryProduct
from .serializer import InventoryProductSerializer
from .models import StockTransaction
from .serializer import StockTransactionSerializer
from rest_framework.decorators import action
from rest_framework import status

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
        Custom action to adjust stock and log a StockTransaction.
        Example body: { "change": -1, "note": "Manual deduction" }
        """
        try:
            product = self.get_object()
            change = int(request.data.get("change", 0))
            note = request.data.get("note", "")

            # Update quantity
            product.quantity += change
            product.save()

            # Create stock transaction
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

        except Exception as e:
            return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)

class StockTransactionViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = StockTransaction.objects.all().order_by("-timestamp")
    serializer_class = StockTransactionSerializer
    permission_classes = [IsAuthenticated]  # 👈 Add this for safety

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


