from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status, permissions, generics, viewsets
from django.contrib.auth import get_user_model, authenticate
from django.contrib.auth.tokens import default_token_generator
from django.utils.http import urlsafe_base64_encode, urlsafe_base64_decode
from django.utils.encoding import force_bytes, force_str
from django.core.mail import send_mail
from django.conf import settings
from django.shortcuts import get_object_or_404
from rest_framework.decorators import api_view, permission_classes
from rest_framework_simplejwt.tokens import RefreshToken
import datetime
import jwt
from .permissions import IsAdminUser
from rest_framework_simplejwt.views import TokenObtainPairView
from .serializers import AdminOnlyTokenObtainPairSerializer

from .serializers import (
    RegisterSerializer,
    PasswordResetSerializer,
    PasswordResetConfirmSerializer,
    UserSerializer,
)

User = get_user_model()


# --- Current user ---
@api_view(["GET"])
@permission_classes([permissions.IsAuthenticated])
def current_user(request):
    user = request.user
    return Response({
        "id": user.id,
        "email": user.email,
        "is_staff": user.is_staff,
        "is_superuser": user.is_superuser,
    })


# --- JWT helper ---
def generate_jwt(user, hours=24):
    payload = {
        "user_id": str(user.id),
        "email": user.email,
        "exp": datetime.datetime.utcnow() + datetime.timedelta(hours=hours),
        "iat": datetime.datetime.utcnow(),
    }
    return jwt.encode(payload, settings.SECRET_KEY, algorithm="HS256")

#---Login ---
class AdminOnlyTokenObtainPairView(TokenObtainPairView):
    serializer_class = AdminOnlyTokenObtainPairSerializer

# --- Signup ---
class RegisterView(generics.CreateAPIView):
    serializer_class = RegisterSerializer
    permission_classes = [permissions.AllowAny]

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.save()

        refresh = RefreshToken.for_user(user)

        return Response({
            "message": "User registered successfully",
            "user": {
                "id": user.id,
                "email": user.email,
                "is_staff": user.is_staff,
                "is_superuser": user.is_superuser,
            },
            "tokens": {
                "refresh": str(refresh),
                "access": str(refresh.access_token),
            },
        }, status=status.HTTP_201_CREATED)


# --- Logout ---
class LogoutView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        return Response(
            {"success": True, "message": "Logout successful. Please remove token client-side."},
            status=status.HTTP_200_OK,
        )


# --- Password Reset Request ---
class PasswordResetRequestView(APIView):
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        serializer = PasswordResetSerializer(data=request.data)
        if serializer.is_valid():
            email = serializer.validated_data["email"]
            user = get_object_or_404(User, email=email)

            uid = urlsafe_base64_encode(force_bytes(str(user.pk)))
            token = default_token_generator.make_token(user)
            reset_link = f"{settings.FRONTEND_URL}/reset-password?uid={uid}&token={token}"

            try:
                send_mail(
                    subject="Password Reset Request",
                    message=f"Click this link to reset your password:\n{reset_link}",
                    from_email=settings.DEFAULT_FROM_EMAIL,
                    recipient_list=[email],
                )
            except Exception as e:
                return Response(
                    {"success": False, "message": f"Email send failed: {str(e)}"},
                    status=status.HTTP_500_INTERNAL_SERVER_ERROR,
                )

            return Response({"success": True, "message": "Reset link sent to email"}, status=status.HTTP_200_OK)

        return Response({"success": False, "errors": serializer.errors}, status=status.HTTP_400_BAD_REQUEST)


# --- Password Reset Confirm ---
class PasswordResetConfirmView(APIView):
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        serializer = PasswordResetConfirmSerializer(data=request.data)
        if not serializer.is_valid():
            return Response({"success": False, "errors": serializer.errors}, status=status.HTTP_400_BAD_REQUEST)

        uidb64 = request.data.get("uid")
        token = request.data.get("token")
        new_password = serializer.validated_data.get("new_password")
        confirm_password = serializer.validated_data.get("confirm_password")

        if new_password != confirm_password:
            return Response({"success": False, "message": "Passwords do not match."}, status=status.HTTP_400_BAD_REQUEST)

        if not uidb64 or not token:
            return Response({"success": False, "message": "Missing UID or token."}, status=status.HTTP_400_BAD_REQUEST)

        try:
            uid_decoded = force_str(urlsafe_base64_decode(uidb64))
            user = get_object_or_404(User, pk=int(uid_decoded))
        except Exception:
            return Response({"success": False, "message": "Invalid UID."}, status=status.HTTP_400_BAD_REQUEST)

        if not default_token_generator.check_token(user, token):
            return Response({"success": False, "message": "Invalid or expired token."}, status=status.HTTP_400_BAD_REQUEST)

        user.set_password(new_password)
        user.save()

        return Response({"success": True, "message": "Password reset successfully."}, status=status.HTTP_200_OK)


# --- Custom Permission ---

class IsSuperuserOrReadOnlyForStaff(permissions.BasePermission):
    """
    Superusers: full access
    Staff: read-only (cannot create/edit/delete)
    """

    def has_permission(self, request, view):
        if request.user.is_superuser:
            return True
        if request.user.is_staff and request.method in permissions.SAFE_METHODS:
            return True
        return False

    def has_object_permission(self, request, view, obj):
        if request.user.is_superuser:
            return True
        if request.user.is_staff and request.method in permissions.SAFE_METHODS:
            return True
        return False

# --- User ViewSet ---

class UserViewSet(viewsets.ModelViewSet):
    queryset = User.objects.all()
    serializer_class = UserSerializer
    permission_classes = [permissions.IsAuthenticated, IsSuperuserOrReadOnlyForStaff]

    def destroy(self, request, *args, **kwargs):
        user = self.get_object()
        current_user = request.user

        # Prevent deleting superuser by staff
        if user.is_superuser and not current_user.is_superuser:
            return Response(
                {"detail": "You cannot delete a superuser account."},
                status=403
            )

        # Prevent self-deletion
        if user.id == current_user.id:
            return Response(
                {"detail": "You cannot delete your own account."},
                status=400
            )

        return super().destroy(request, *args, **kwargs)


        
class UserManagementView(APIView):
    permission_classes = [IsAdminUser]

    def delete(self, request, user_id):
        try:
            user = User.objects.get(id=user_id)
            user.delete()
            return Response({"message": "User deleted successfully"}, status=status.HTTP_200_OK)
        except User.DoesNotExist:
            return Response({"error": "User not found"}, status=status.HTTP_404_NOT_FOUND)
        
        