from typing import List
import re
from decimal import Decimal

from ..domain.entities import Product
from ..domain.services import ProductService, UserService, InventoryService


class ConcreteProductService(ProductService):
    """Concrete implementation of ProductService"""
    
    def calculate_total_value(self, products: List[Product]) -> float:
        """Calculate total inventory value"""
        return float(sum(product.price * product.quantity for product in products))
    
    def get_products_needing_restock(self, products: List[Product], threshold: int = 5) -> List[Product]:
        """Get products that need restocking"""
        return [product for product in products if product.quantity <= threshold]
    
    def validate_product_data(self, name: str, price: float, quantity: int) -> List[str]:
        """Validate product data and return list of errors"""
        errors = []
        
        if not name or not name.strip():
            errors.append("Product name is required")
        elif len(name.strip()) < 2:
            errors.append("Product name must be at least 2 characters long")
        
        if price < 0:
            errors.append("Price cannot be negative")
        elif price == 0:
            errors.append("Price cannot be zero")
        
        if quantity < 0:
            errors.append("Quantity cannot be negative")
        
        return errors


class ConcreteUserService(UserService):
    """Concrete implementation of UserService"""
    
    def validate_user_data(self, email: str, firebase_uid: str) -> List[str]:
        """Validate user data and return list of errors"""
        errors = []
        
        if not self.is_email_valid(email):
            errors.append("Invalid email format")
        
        if not firebase_uid or not firebase_uid.strip():
            errors.append("Firebase UID is required")
        
        return errors
    
    def is_email_valid(self, email: str) -> bool:
        """Check if email format is valid"""
        if not email:
            return False
        
        # Simple email validation regex
        pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
        return re.match(pattern, email) is not None


class ConcreteInventoryService(InventoryService):
    """Concrete implementation of InventoryService"""
    
    def process_stock_adjustment(self, product: Product, adjustment: int, reason: str) -> Product:
        """Process stock adjustment with audit trail"""
        new_quantity = product.quantity + adjustment
        
        if new_quantity < 0:
            raise ValueError(f"Stock adjustment would result in negative quantity: {new_quantity}")
        
        product.update_quantity(new_quantity)
        
        # In a real application, you would log this adjustment
        # self._log_stock_adjustment(product, adjustment, reason)
        
        return product
    
    def check_stock_availability(self, product: Product, requested_quantity: int) -> bool:
        """Check if requested quantity is available"""
        return product.quantity >= requested_quantity
    
    def calculate_reorder_point(self, product: Product, lead_time_days: int, daily_usage: float) -> int:
        """Calculate reorder point for inventory management"""
        safety_stock = daily_usage * 2  # 2 days safety stock
        lead_time_stock = daily_usage * lead_time_days
        return int(safety_stock + lead_time_stock)
    
    def _log_stock_adjustment(self, product: Product, adjustment: int, reason: str):
        """Log stock adjustment for audit trail"""
        # This would typically write to a log file or database
        # For now, we'll just pass
        pass







