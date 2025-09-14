# apps/users/signals.py

from django.db.models.signals import pre_delete
from django.dispatch import receiver
from django.contrib.auth import get_user_model

User = get_user_model()

@receiver(pre_delete, sender=User)
def delete_user_tokens(sender, instance, **kwargs):
    """
    If using JWT (SimpleJWT), tokens are not stored in the database,
    so we don't need to delete anything here.
    """
    pass  # <-- Just do nothing
