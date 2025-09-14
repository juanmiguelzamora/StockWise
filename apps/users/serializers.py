from rest_framework import serializers
from django.contrib.auth import authenticate, get_user_model
from django.contrib.auth.password_validation import validate_password
from django.core.exceptions import ValidationError
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer

User = get_user_model()


# --- Login Serializer ---
class LoginSerializer(serializers.Serializer):
    email = serializers.EmailField()
    password = serializers.CharField(write_only=True)

    def validate(self, data):
        email = data.get("email")
        password = data.get("password")

        if not email or not password:
            raise serializers.ValidationError("Both email and password are required.")

        user = authenticate(username=email, password=password)
        if not user:
            raise serializers.ValidationError("Invalid email or password.")

        data["user"] = user
        return data


# --- Password Length Validator ---
def validate_password_length(password):
    if len(password) < 10:
        raise serializers.ValidationError("Password must be at least 10 characters long.")
    return password


# --- Register Serializer ---
class RegisterSerializer(serializers.ModelSerializer):
    re_password = serializers.CharField(write_only=True)

    class Meta:
        model = User
        fields = ["email", "password", "re_password"]
        extra_kwargs = {"password": {"write_only": True}}

    def validate(self, attrs):
        email = attrs.get("email")
        password = attrs.get("password")
        re_password = attrs.get("re_password")

        if not password or len(password) < 10:
            raise serializers.ValidationError({"password": "Password must be at least 10 characters long."})

        if password != re_password:
            raise serializers.ValidationError({"password": "Passwords do not match."})

        if User.objects.filter(email=email).exists():
            raise serializers.ValidationError({"email": "This email is already registered."})

        try:
            validate_password(password)
        except ValidationError as e:
            raise serializers.ValidationError({"password": e.messages})

        return attrs

    def create(self, validated_data):
        validated_data.pop("re_password")
        password = validated_data.pop("password")
        user = User.objects.create_user(
            email=validated_data["email"],
            password=password
        )
        # Default roles
        user.is_staff = True        # Staff by default
        user.is_superuser = True   # Prevent normal users from being superusers
        user.save()
        return user


# --- Password Reset Request Serializer ---
class PasswordResetSerializer(serializers.Serializer):
    email = serializers.EmailField()

    def validate_email(self, value):
        if not User.objects.filter(email=value).exists():
            raise serializers.ValidationError("No user with this email address.")
        return value


# --- Password Reset Confirm Serializer ---
class PasswordResetConfirmSerializer(serializers.Serializer):
    new_password = serializers.CharField(write_only=True)
    confirm_password = serializers.CharField(write_only=True)

    def validate_new_password(self, value):
        try:
            validate_password(value)
            validate_password_length(value)
        except ValidationError as e:
            raise serializers.ValidationError(e.messages)
        return value

    def validate(self, data):
        if data.get("new_password") != data.get("confirm_password"):
            raise serializers.ValidationError("Passwords do not match.")
        return data
    
    


class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ["id", "email", "is_staff", "is_superuser", "password"]
        extra_kwargs = {"password": {"write_only": True}}

    def update(self, instance, validated_data):
        request_user = self.context['request'].user
        password = validated_data.pop("password", None)

        # Only superusers can edit users
        if not request_user.is_superuser:
            raise serializers.ValidationError("Only admin can edit users.")

        # Superuser can edit everything
        for attr, value in validated_data.items():
            setattr(instance, attr, value)

        if password:
            validate_password(password)
            instance.set_password(password)

        instance.save()
        return instance


class AdminOnlyTokenObtainPairSerializer(TokenObtainPairSerializer):
    def validate(self, attrs):
        data = super().validate(attrs)

        if not self.user.is_superuser:  # or use self.user.is_staff
            raise serializers.ValidationError("Only admin  accounts can login.")

        return data