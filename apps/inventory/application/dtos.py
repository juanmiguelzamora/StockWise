from dataclasses import dataclass
from decimal import Decimal
from typing import Optional, List
from datetime import datetime


@dataclass
class CreateProductRequest:
    """DTO for creating a product"""
    name: str
    description: Optional[str]
    price: Decimal
    quantity: int


@dataclass
class UpdateProductRequest:
    """DTO for updating a product"""
    name: Optional[str] = None
    description: Optional[str] = None
    price: Optional[Decimal] = None
    quantity: Optional[int] = None


@dataclass
class ProductResponse:
    """DTO for product response"""
    id: str
    name: str
    description: Optional[str]
    price: Decimal
    quantity: int
    created_at: datetime
    updated_at: datetime
    is_in_stock: bool


@dataclass
class ProductListResponse:
    """DTO for product list response"""
    products: List[ProductResponse]
    total_count: int
    total_value: Decimal


@dataclass
class CreateUserRequest:
    """DTO for creating a user"""
    email: str
    firebase_uid: str


@dataclass
class UserResponse:
    """DTO for user response"""
    id: str
    email: str
    firebase_uid: str
    is_active: bool
    created_at: datetime
    updated_at: datetime


@dataclass
class StockAdjustmentRequest:
    """DTO for stock adjustment"""
    product_id: str
    adjustment: int
    reason: str


@dataclass
class InventoryReportRequest:
    """DTO for inventory report"""
    include_low_stock: bool = True
    low_stock_threshold: int = 5
    include_out_of_stock: bool = True


@dataclass
class InventoryReportResponse:
    """DTO for inventory report response"""
    total_products: int
    total_value: Decimal
    low_stock_products: List[ProductResponse]
    out_of_stock_products: List[ProductResponse]
    generated_at: datetime







