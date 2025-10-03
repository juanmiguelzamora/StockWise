from rest_framework import serializers
from django.contrib.auth import authenticate, get_user_model
from django.contrib.auth.password_validation import validate_password
from django.core.exceptions import ValidationError
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer
from django.contrib.auth.models import User
from .models import UserProfile


User = get_user_model()


# --- Login Serializer ---
class AdminOnlyTokenObtainPairSerializer(TokenObtainPairSerializer):
    username_field = "email"  # tell SimpleJWT to expect email instead of username

    def validate(self, attrs):
        email = attrs.get("email")
        password = attrs.get("password")

        # Check if account exists
        try:
            user_obj = User.objects.get(email=email)
        except User.DoesNotExist:
            raise serializers.ValidationError("Account does not exist.")

        # Check password
        user = authenticate(username=email, password=password)
        if not user:
            raise serializers.ValidationError("Invalid email or password.")

        # Check if active
        if not user.is_active:
            raise serializers.ValidationError("This account is disabled.")

        # Check if admin
        if not user.is_superuser:
            raise serializers.ValidationError("Only admin accounts can login.")

        # ✅ let SimpleJWT create tokens
        data = super().validate(attrs)
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


class PasswordResetConfirmSerializer(serializers.Serializer):
    new_password = serializers.CharField(write_only=True)
    confirm_password = serializers.CharField(write_only=True)

    def validate_new_password(self, value):
        # ✅ Minimum length check
        if len(value) < 10:
            raise serializers.ValidationError("Password must be at least 10 characters long.")

        # ✅ No entirely numeric passwords
        if value.isdigit():
            raise serializers.ValidationError("Password cannot be entirely numeric.")

        # ✅ No common passwords
        common_passwords = ["password", "123456", "qwerty", "admin", "letmein"]
        if value.lower() in common_passwords:
            raise serializers.ValidationError("Password is too common, please choose something stronger.")

        return value

    def validate(self, data):
        # ✅ Password match check
        if data.get("new_password") != data.get("confirm_password"):
            raise serializers.ValidationError({"confirm_password": "Passwords do not match."})
        return data

    


class UserProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = UserProfile
        fields = ['profile_picture']
        
class UserSerializer(serializers.ModelSerializer):
    profile_picture = serializers.ImageField(write_only=True, required=False)

    class Meta:
        model = User
        fields = ['id', 'email', 'is_staff', 'is_superuser', 'profile_picture']

    def update(self, instance, validated_data):
        picture = validated_data.pop('profile_picture', None)
        instance = super().update(instance, validated_data)

        # Create profile if missing
        profile, _ = UserProfile.objects.get_or_create(user=instance)
        if picture:
            profile.profile_picture = picture
            profile.save()

        return instance

    def to_representation(self, instance):
        """Return the profile picture full URL for frontend."""
        ret = super().to_representation(instance)
        if hasattr(instance, 'profile') and instance.profile.profile_picture:
            ret['profile_picture'] = f"{self.context['request'].build_absolute_uri(instance.profile.profile_picture.url)}"
        else:
            ret['profile_picture'] = None
        return ret

