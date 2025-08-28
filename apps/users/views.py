from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.contrib.auth import get_user_model, authenticate
from django.core.mail import send_mail
from django.utils.crypto import get_random_string
from django.utils.http import urlsafe_base64_encode, urlsafe_base64_decode
from django.utils.encoding import force_bytes, force_str
from django.contrib.auth.tokens import default_token_generator
import json, jwt, datetime, re, traceback
from django.conf import settings

User = get_user_model()

# --- Helpers ---
def generate_jwt(user, hours=24):
    payload = {
        "user_id": user.id,
        "email": user.email,
        "exp": datetime.datetime.utcnow() + datetime.timedelta(hours=hours),
        "iat": datetime.datetime.utcnow(),
    }
    token = jwt.encode(payload, settings.SECRET_KEY, algorithm="HS256")
    return token if isinstance(token, str) else token.decode("utf-8")


def validate_password(password):
    if len(password) < 8:
        return "Password must be at least 8 characters long."
    if not re.search(r"[A-Z]", password):
        return "Password must contain at least one uppercase letter."
    if not re.search(r"[a-z]", password):
        return "Password must contain at least one lowercase letter."
    if not re.search(r"\d", password):
        return "Password must contain at least one number."
    if not re.search(r"[!@#$%^&*(),.?\":{}|<>]", password):
        return "Password must contain at least one special character."
    return None


# --- Signup/Login/Logout ---
@csrf_exempt
def signup_view(request):
    if request.method != "POST":
        return JsonResponse({"success": False, "message": "Invalid request method"}, status=405)
    try:
        data = json.loads(request.body)
        email = data.get("email")
        password = data.get("password")

        if not email or not password:
            return JsonResponse({"success": False, "message": "Email and password required"}, status=400)

        password_error = validate_password(password)
        if password_error:
            return JsonResponse({"success": False, "message": password_error}, status=400)

        if User.objects.filter(email=email).exists():
            return JsonResponse({"success": False, "message": "Email already in use"}, status=400)

        user = User.objects.create_user(username=email, email=email, password=password)
        return JsonResponse({"success": True, "message": "Signup successful"}, status=201)

    except Exception as e:
        traceback.print_exc()
        return JsonResponse({"success": False, "message": str(e)}, status=500)


@csrf_exempt
def login_view(request):
    if request.method != "POST":
        return JsonResponse({"success": False, "message": "Method not allowed"}, status=405)
    try:
        data = json.loads(request.body)
        email = data.get("email")
        password = data.get("password")

        if not email or not password:
            return JsonResponse({"success": False, "message": "Email and password are required."}, status=400)

        try:
            user = User.objects.get(email=email)
        except User.DoesNotExist:
            return JsonResponse({"success": False, "message": "Invalid email or password"}, status=401)

        user = authenticate(username=user.username, password=password)
        if user is None:
            return JsonResponse({"success": False, "message": "Invalid email or password"}, status=401)

        if not user.is_active:
            return JsonResponse({"success": False, "message": "This account has been disabled"}, status=403)

        token = generate_jwt(user)
        return JsonResponse({"success": True, "message": "Login successful", "token": token}, status=200)

    except Exception as e:
        traceback.print_exc()
        return JsonResponse({"success": False, "message": f"Login failed: {str(e)}"}, status=500)


@csrf_exempt
def logout_view(request):
    if request.method == "POST":
        return JsonResponse({
            "success": True,
            "message": "Logout successful. Please remove the token on client side."
        }, status=200)
    return JsonResponse({"success": False, "message": "Method not allowed"}, status=405)


# --- Password Reset ---
@csrf_exempt
def password_reset_request_view(request):
    if request.method != "POST":
        return JsonResponse({"success": False, "message": "Method not allowed"}, status=405)
    try:
        data = json.loads(request.body)
        email = data.get("email")
        if not email:
            return JsonResponse({"success": False, "message": "Email required"}, status=400)

        try:
            user = User.objects.get(email=email)
        except User.DoesNotExist:
            # Always pretend success to prevent email enumeration
            return JsonResponse({"success": True, "message": "If the email exists, a reset link was sent."})

        uid = urlsafe_base64_encode(force_bytes(user.pk))
        token = default_token_generator.make_token(user)

        reset_link = f"{settings.FRONTEND_URL}/reset-password?uid={uid}&token={token}"

        send_mail(
            subject="Password Reset Request",
            message=f"Click this link to reset your password:\n{reset_link}",
            from_email=settings.DEFAULT_FROM_EMAIL,
            recipient_list=[email],
        )

        return JsonResponse({"success": True, "message": "Reset link sent to email"})

    except Exception as e:
        traceback.print_exc()
        return JsonResponse({"success": False, "message": str(e)}, status=500)


@csrf_exempt
def password_reset_confirm_view(request):
    if request.method != "POST":
        return JsonResponse({"success": False, "message": "Method not allowed"}, status=405)
    
    try:
        data = json.loads(request.body)
        uidb64 = data.get("uid")
        token = data.get("token")
        new_password = data.get("password")

        if not uidb64 or not token or not new_password:
            return JsonResponse({"success": False, "message": "UID, token, and password required"}, status=400)

        try:
            # Decode UID safely
            uid = force_str(urlsafe_base64_decode(uidb64))
            user = User.objects.get(pk=uid)
        except Exception as e:
            traceback.print_exc()
            return JsonResponse({
                "success": False,
                "message": f"Invalid UID. Error: {str(e)}"
            }, status=400)

        # Check token validity
        if not default_token_generator.check_token(user, token):
            return JsonResponse({"success": False, "message": "Invalid or expired token"}, status=400)

        # Validate new password
        password_error = validate_password(new_password)
        if password_error:
            return JsonResponse({"success": False, "message": password_error}, status=400)

        user.set_password(new_password)
        user.save()

        return JsonResponse({"success": True, "message": "Password reset successfully"})

    except Exception as e:
        traceback.print_exc()
        return JsonResponse({"success": False, "message": f"Server error: {str(e)}"}, status=500)
