from django.db.models.signals import post_save
from django.dispatch import receiver
from .models import Product, Inventory


@receiver(post_save, sender=Product)
def create_inventory_for_product(sender, instance, created, **kwargs):
    """
    Automatically create an Inventory record when a Product is created.
    """
    if created:
        Inventory.objects.create(product=instance)
