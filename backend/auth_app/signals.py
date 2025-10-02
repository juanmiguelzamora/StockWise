from django.dispatch import receiver
from django_rest_passwordreset.signals import reset_password_token_created
from django.core.mail import EmailMultiAlternatives
from django.conf import settings

@receiver(reset_password_token_created)
def password_reset_token_created(sender, instance, reset_password_token, *args, **kwargs):
    email = reset_password_token.user.email
    token = reset_password_token.key
    reset_url = f"https://ca9b4d99fd88.ngrok-free.app/api/password_reset/confirm/{token}/"

    subject = 'Password Reset Request'
    from_email = settings.DEFAULT_FROM_EMAIL
    to_email = email

    text_content = f"""
    Hi {reset_password_token.user.first_name},

    You requested a password reset. 
    Open the link below to reset your password:

    {reset_url}

    If you didn’t request this, please ignore this email.
    """

    html_content = f"""
    <p>Hi {reset_password_token.user.first_name},</p>
    <p>You requested a password reset.</p>
    <p>
        <a href="{reset_url}" 
           style="display:inline-block;padding:10px 20px;background:#4CAF50;color:#fff;
                  text-decoration:none;border-radius:5px;">
           Reset Password
        </a>
    </p>
    <p>This link will expire in 15 minutes. If you did not request a password reset, please ignore this email.</p>
    """

    msg = EmailMultiAlternatives(subject, text_content, from_email, [to_email])
    msg.attach_alternative(html_content, "text/html")
    msg.send()