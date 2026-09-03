from django.test import TestCase
from django.utils import timezone

from .models import Inventory, Product, SalesHistory, StockMovement
from .serializers import ProductQuantityUpdateSerializer, SalesHistorySerializer


class ProductQuantityUpdateTests(TestCase):
	def test_decrease_creates_negative_history_entry(self):
		product = Product.objects.create(sku="TEST-001", name="Test product")
		inventory = Inventory.objects.get(product=product)
		inventory.stock_in = 10
		inventory.save()

		serializer = ProductQuantityUpdateSerializer(
			product, data={"quantity": 7}, partial=True
		)
		serializer.is_valid(raise_exception=True)
		serializer.save()

		inventory = Inventory.objects.get(product=product)
		history = SalesHistory.objects.get(product=product, date=timezone.now().date())

		self.assertEqual(inventory.stock_out, 3)
		self.assertEqual(inventory.total_stock, 7)
		self.assertEqual(history.units_sold, 3)
		self.assertEqual(SalesHistorySerializer(history).data["change"], -3)

	def test_each_quantity_change_creates_a_signed_movement(self):
		product = Product.objects.create(sku="TEST-002", name="Another product")
		inventory = Inventory.objects.get(product=product)
		inventory.stock_in = 10
		inventory.save()

		for quantity in (11, 10):
			serializer = ProductQuantityUpdateSerializer(
				product, data={"quantity": quantity}, partial=True
			)
			serializer.is_valid(raise_exception=True)
			serializer.save()

		movements = list(
			StockMovement.objects.filter(product=product).order_by("created_at", "id")
		)
		self.assertEqual([movement.change for movement in movements], [1, -1])
		self.assertEqual([movement.quantity_after for movement in movements], [11, 10])
