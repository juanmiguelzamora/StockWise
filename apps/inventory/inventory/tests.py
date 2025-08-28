from django.test import TestCase
from .models import Product
from decimal import Decimal

class ProductModelTest(TestCase):
    def test_product_creation(self):
        product = Product.objects.create(
            name="Test Product",
            description="Test Description",
            price=Decimal('10.99'),
            quantity=5,
            category="Test Category"
        )
        self.assertEqual(product.name, "Test Product")
        self.assertEqual(product.quantity, 5)
        self.assertTrue(product.is_in_stock)









