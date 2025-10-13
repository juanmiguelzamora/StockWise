from django.core.cache import cache
from django.db import models
from django.utils import timezone
from datetime import timedelta
from decimal import Decimal
from django.core.mail import send_mail
from django.conf import settings
from auth_app.models import User
import logging

logger = logging.getLogger(__name__)

class Category(models.Model):
    """
    Separate table for product categories to ensure data consistency
    and allow relationships (instead of free-text).
    """
    name = models.CharField(max_length=128, unique=True)

    def __str__(self):
        return self.name


class Supplier(models.Model):
    """
    NEW: Tracks suppliers for products to enable reorder recommendations.
    """
    name = models.CharField(max_length=255)
    contact_email = models.EmailField(blank=True)
    phone = models.CharField(max_length=20, blank=True)
    lead_time_days = models.PositiveIntegerField(default=3)  # Days to deliver

    def __str__(self):
        return self.name


class Product(models.Model):
    """
    Core Product model representing inventory items.
    SKU is unique and used as the lookup field in API endpoints.
    """
    sku = models.CharField(max_length=64, unique=True, db_index=True)
    name = models.CharField(max_length=255, db_index=True)
    description = models.TextField(blank=True)  # optional long text
    category = models.ForeignKey(
        Category, on_delete=models.SET_NULL, null=True, related_name="products"
    )
    supplier = models.ForeignKey(
        Supplier, on_delete=models.SET_NULL, null=True, blank=True, related_name="products"
    )  # NEW: Link to supplier
    image_url = models.CharField(max_length=500, blank=True, help_text="Relative path, e.g., 'products/gray_pants.png'")

    # Audit fields
    created_at = models.DateTimeField(auto_now_add=True)  # first created
    updated_at = models.DateTimeField(auto_now=True)      # last update

    class Meta:
        ordering = ["name"]
        indexes = [
            models.Index(fields=["sku"]),
            models.Index(fields=["name"]),
        ]

    def __str__(self):
        return f"{self.sku} - {self.name}"

    @property
    def quantity(self):
        """
        Computed field: always returns the linked Inventory's total_stock.
        Defaults to 0 if no inventory record exists yet.
        """
        return self.inventory.total_stock if hasattr(self, "inventory") else 0


class SalesHistory(models.Model):
    """
    NEW: Tracks daily sales for trend analysis and better averages/forecasts.
    """
    product = models.ForeignKey(Product, on_delete=models.CASCADE, related_name="sales_history")
    date = models.DateField(db_index=True)
    units_sold = models.PositiveIntegerField(default=0)

    class Meta:
        unique_together = ["product", "date"]  # One entry per day per product
        ordering = ["-date"]  # Latest first

    def __str__(self):
        return f"{self.product.name} - {self.date}: {self.units_sold} sold"


class Inventory(models.Model):
    """
    Manages detailed inventory metrics for each product.
    One-to-one relationship with Product.
    """
    product = models.OneToOneField(Product, on_delete=models.CASCADE, related_name="inventory")
    stock_in = models.PositiveIntegerField(default=0)
    stock_out = models.PositiveIntegerField(default=0)
    total_stock = models.PositiveIntegerField(default=0)
    average_daily_sales = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    low_stock_threshold = models.PositiveIntegerField(default=10)

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def save(self, *args, **kwargs):
        # Auto-calculate total stock
        old_stock = self.total_stock  # Track old value for delta check
        self.total_stock = self.stock_in - self.stock_out
        
        # NEW: Compute average_daily_sales from last 30 days of SalesHistory (fallback to 0)
        thirty_days_ago = timezone.now().date() - timedelta(days=30)
        recent_sales = self.product.sales_history.filter(date__gte=thirty_days_ago).aggregate(
            total=models.Sum('units_sold'),
            days=models.Count('date')
        )
        total_sold = recent_sales['total'] or 0
        days_count = recent_sales['days'] or 1  # Avoid div by zero
        self.average_daily_sales = Decimal(total_sold) / Decimal(days_count)
        
        super().save(*args, **kwargs)

        # Trigger notification only when stock *drops below threshold*
        if self.total_stock < self.low_stock_threshold:
            self._send_low_stock_email()
            
    def _send_low_stock_email(self):
        """Send email alert to staff users."""
        cache_key = f"low_stock_alert_sent_{self.product.id}"
        # Avoid spamming by limiting one alert every 6 hours per product
        if cache.get(cache_key):
            logger.info(f"Skipping duplicate alert for {self.product.name} (recently sent).")
            return

        subject = f"⚠️ Low Stock Alert: {self.product.name}"
        message = (
            f"Dear Team,\n\n"
            f"The stock for *{self.product.name}* (SKU: {self.product.sku}) "
            f"is now **low**.\n\n"
            f"📦 Current stock: {self.total_stock}\n"
            f"🔻 Threshold: {self.low_stock_threshold}\n"
            f"📅 Avg Daily Sales: {self.average_daily_sales:.2f} units/day\n"
            f"🚚 Supplier: {self.product.supplier.name if self.product.supplier else 'N/A'}\n\n"
            f"Suggested Action: Please reorder or review sales forecast.\n\n"
            f"— StockWise Auto Alert"
        )

        # Get all active staff emails
        staff_emails = list(
            User.objects.filter(is_staff=True, is_active=True)
            .values_list("email", flat=True)
            .distinct()
        )
        if not staff_emails:
            staff_emails = [settings.EMAIL_HOST_USER]

        try:
            send_mail(
                subject=subject,
                message=message,
                from_email=settings.DEFAULT_FROM_EMAIL,
                recipient_list=staff_emails,
                fail_silently=False,
            )
            logger.info(
                f"Low stock email sent for {self.product.name} "
                f"to {len(staff_emails)} recipients."
            )
            cache.set(cache_key, True, timeout=6 * 60 * 60)  # prevent resending for 6 hours
        except Exception as e:
            logger.error(f"Error sending low stock email for {self.product.name}: {e}")

    def __str__(self):
        return f"Inventory for {self.product.name}"
    

class Trend(models.Model):
    """
    Stores scraped fashion trends for seasonal predictions.
    """
    season = models.CharField(max_length=50, help_text="e.g., 'Christmas', 'Summer'")
    keywords = models.TextField(help_text="Comma-separated trends, e.g., 'red sweaters, festive patterns'")
    popularity_score = models.FloatField(default=0.0, help_text="From scrape, e.g., like count / 100")
    hot_score = models.FloatField(default=0.0, help_text="Pre-computed: frequency * popularity (for predictions)")  # NEW
    category = models.ForeignKey(Category, on_delete=models.CASCADE, related_name="trends", null=True)
    scraped_at = models.DateTimeField(auto_now_add=True)
    source_url = models.URLField(blank=True, help_text="Original trend page")
    source_name = models.CharField(max_length=100, blank=True, help_text="Source site, e.g., Vogue")


    class Meta:
        ordering = ["-scraped_at"]

    def __str__(self):
        return f"{self.season} Trends: {self.keywords[:50]}... (Hot: {self.hot_score:.2f})"