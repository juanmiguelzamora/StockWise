from rest_framework import generics, status
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from .serializers import RegisterSerializer, UserSerializer
from .models import User
from rest_framework_simplejwt.tokens import RefreshToken
from django.shortcuts import render
from django.http import HttpResponseBadRequest
from django_rest_passwordreset.models import ResetPasswordToken
from django.contrib.auth.password_validation import validate_password
from django.core.exceptions import ValidationError
from datetime import datetime, timedelta
from django.utils import timezone
from django.conf import settings

class RegisterView(generics.CreateAPIView):
    serializer_class = RegisterSerializer

    def post(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        if serializer.is_valid():
            user = serializer.save()
            refresh = RefreshToken.for_user(user)
            return Response({
                'message': 'User created successfully',
                'access': str(refresh.access_token),
                'refresh': str(refresh),
            }, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class UserView(generics.RetrieveAPIView):
    permission_classes = [IsAuthenticated]
    serializer_class = UserSerializer

    def get_object(self):
        return self.request.user


class PasswordResetConfirmView(generics.GenericAPIView):
    def get(self, request, token):
        try:
            reset_token = ResetPasswordToken.objects.get(key=token)
            # Check if token is expired
            expiry_time = timedelta(seconds=settings.DJANGO_REST_PASSWORDRESET['RESET_PASSWORD_TOKEN_EXPIRY_TIME'])
            if timezone.now() > reset_token.created_at + expiry_time:
                reset_token.delete()  # Clean up expired token
                return render(request, "password_reset_confirm.html", {
                    "token": token,  # Pass token to context
                    "errors": ["This password reset link has expired. Please request a new one."],
                    "expired": True  # Add flag for template to show resend option
                })
            if reset_token.user is None:
                return render(request, "password_reset_confirm.html", {
                    "token": token,
                    "errors": ["Invalid token"]
                })
            return render(request, "password_reset_confirm.html", {"token": token})
        except ResetPasswordToken.DoesNotExist:
            return render(request, "password_reset_confirm.html", {
                "token": token,  # Pass token to context
                "errors": ["Invalid or expired token"],
                "expired": True  # Add flag for template to show resend option
            })

    def post(self, request, token):
        password = request.POST.get("password")

        try:
            reset_token = ResetPasswordToken.objects.get(key=token)
            # Check if token is expired
            expiry_time = timedelta(seconds=settings.DJANGO_REST_PASSWORDRESET['RESET_PASSWORD_TOKEN_EXPIRY_TIME'])
            if timezone.now() > reset_token.created_at + expiry_time:
                reset_token.delete()  # Clean up expired token
                return render(request, "password_reset_confirm.html", {
                    "token": token,
                    "errors": ["This password reset link has expired. Please request a new one."],
                    "expired": True  # Add flag for template to show resend option
                })
            if reset_token.user is None:
                return render(request, "password_reset_confirm.html", {
                    "token": token,
                    "errors": ["Invalid token"]
                })

            # Validate password
            try:
                validate_password(password, reset_token.user)
            except ValidationError as e:
                return render(request, "password_reset_confirm.html", {
                    "token": token,
                    "errors": list(e.messages)
                })

            # If valid, update password
            reset_token.user.set_password(password)
            reset_token.user.save()
            reset_token.delete()

            return render(request, "password_reset_success.html")

        except ResetPasswordToken.DoesNotExist:
            return render(request, "password_reset_confirm.html", {
                "token": token,
                "errors": ["Invalid or expired token"],
                "expired": True  # Add flag for template to show resend option
            })