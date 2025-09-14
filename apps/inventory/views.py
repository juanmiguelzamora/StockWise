from rest_framework import permissions, viewsets
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from .models import InventoryProduct
from .serializer import InventoryProductSerializer


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
