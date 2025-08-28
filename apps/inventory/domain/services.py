from abc import ABC, abstractmethod
from typing import List, Optional
from .entities import Product, User


class ProductService(ABC):
    """Domain service for product-related business logic"""
    
    @abstractmethod
    def calculate_total_value(self, products: List[Product]) -> float:
        """Calculate total inventory value"""
        pass
    
    @abstractmethod
    def get_products_needing_restock(self, products: List[Product], threshold: int = 5) -> List[Product]:
        """Get products that need restocking"""
        pass
    
    @abstractmethod
    def validate_product_data(self, name: str, price: float, quantity: int) -> List[str]:
        """Validate product data and return list of errors"""
        pass


class UserService(ABC):
    """Domain service for user-related business logic"""
    
    @abstractmethod
    def validate_user_data(self, email: str, firebase_uid: str) -> List[str]:
        """Validate user data and return list of errors"""
        pass
    
    @abstractmethod
    def is_email_valid(self, email: str) -> bool:
        """Check if email format is valid"""
        pass


class InventoryService(ABC):
    """Domain service for inventory management business logic"""
    
    @abstractmethod
    def process_stock_adjustment(self, product: Product, adjustment: int, reason: str) -> Product:
        """Process stock adjustment with audit trail"""
        pass
    
    @abstractmethod
    def check_stock_availability(self, product: Product, requested_quantity: int) -> bool:
        """Check if requested quantity is available"""
        pass
    
    @abstractmethod
    def calculate_reorder_point(self, product: Product, lead_time_days: int, daily_usage: float) -> int:
        """Calculate reorder point for inventory management"""
        pass







