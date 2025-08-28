from abc import ABC, abstractmethod
from dataclasses import dataclass
from decimal import Decimal
from typing import Optional
from datetime import datetime
import uuid


@dataclass
class Product:
    """Product domain entity"""
    id: str
    name: str
    description: Optional[str]
    price: Decimal
    quantity: int
    created_at: datetime
    updated_at: datetime
    
    @classmethod
    def create(cls, name: str, description: str, price: Decimal, quantity: int = 0) -> 'Product':
        """Factory method to create a new product"""
        now = datetime.utcnow()
        return cls(
            id=str(uuid.uuid4()),
            name=name,
            description=description,
            price=price,
            quantity=quantity,
            created_at=now,
            updated_at=now
        )
    
    def update_quantity(self, new_quantity: int) -> None:
        """Update product quantity"""
        if new_quantity < 0:
            raise ValueError("Quantity cannot be negative")
        self.quantity = new_quantity
        self.updated_at = datetime.utcnow()
    
    def update_price(self, new_price: Decimal) -> None:
        """Update product price"""
        if new_price < 0:
            raise ValueError("Price cannot be negative")
        self.price = new_price
        self.updated_at = datetime.utcnow()
    
    def is_in_stock(self) -> bool:
        """Check if product is in stock"""
        return self.quantity > 0


@dataclass
class User:
    """User domain entity"""
    id: str
    email: str
    firebase_uid: str
    is_active: bool
    created_at: datetime
    updated_at: datetime
    
    @classmethod
    def create(cls, email: str, firebase_uid: str) -> 'User':
        """Factory method to create a new user"""
        now = datetime.utcnow()
        return cls(
            id=str(uuid.uuid4()),
            email=email,
            firebase_uid=firebase_uid,
            is_active=True,
            created_at=now,
            updated_at=now
        )
    
    def deactivate(self) -> None:
        """Deactivate user account"""
        self.is_active = False
        self.updated_at = datetime.utcnow()
    
    def activate(self) -> None:
        """Activate user account"""
        self.is_active = True
        self.updated_at = datetime.utcnow()


class Repository(ABC):
    """Abstract base class for repositories"""
    
    @abstractmethod
    def save(self, entity) -> None:
        pass
    
    @abstractmethod
    def get_by_id(self, entity_id: str):
        pass
    
    @abstractmethod
    def delete(self, entity_id: str) -> None:
        pass


class ProductRepository(Repository):
    """Abstract product repository interface"""
    
    @abstractmethod
    def get_by_name(self, name: str) -> Optional[Product]:
        pass
    
    @abstractmethod
    def get_low_stock_products(self, threshold: int = 5) -> list[Product]:
        pass


class UserRepository(Repository):
    """Abstract user repository interface"""
    
    @abstractmethod
    def get_by_firebase_uid(self, firebase_uid: str) -> Optional[User]:
        pass
    
    @abstractmethod
    def get_by_email(self, email: str) -> Optional[User]:
        pass







