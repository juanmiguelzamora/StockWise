from abc import ABC, abstractmethod
from typing import List, Optional
from decimal import Decimal
from datetime import datetime

from ..domain.entities import Product, User, ProductRepository, UserRepository
from ..domain.services import ProductService, UserService, InventoryService
from .dtos import (
    CreateProductRequest, UpdateProductRequest, ProductResponse, ProductListResponse,
    CreateUserRequest, UserResponse, StockAdjustmentRequest, InventoryReportRequest,
    InventoryReportResponse
)


class UseCase(ABC):
    """Base class for use cases"""
    
    def __init__(self):
        self.errors = []
    
    def add_error(self, error: str) -> None:
        """Add error to use case"""
        self.errors.append(error)
    
    def has_errors(self) -> bool:
        """Check if use case has errors"""
        return len(self.errors) > 0


class CreateProductUseCase(UseCase):
    """Use case for creating a new product"""
    
    def __init__(self, product_repository: ProductRepository, product_service: ProductService):
        super().__init__()
        self.product_repository = product_repository
        self.product_service = product_service
    
    def execute(self, request: CreateProductRequest) -> Optional[ProductResponse]:
        """Execute the use case"""
        # Validate input
        errors = self.product_service.validate_product_data(
            request.name, float(request.price), request.quantity
        )
        
        for error in errors:
            self.add_error(error)
        
        if self.has_errors():
            return None
        
        # Check if product with same name exists
        existing_product = self.product_repository.get_by_name(request.name)
        if existing_product:
            self.add_error("Product with this name already exists")
            return None
        
        # Create product
        product = Product.create(
            name=request.name,
            description=request.description,
            price=request.price,
            quantity=request.quantity
        )
        
        # Save to repository
        self.product_repository.save(product)
        
        # Return response
        return ProductResponse(
            id=product.id,
            name=product.name,
            description=product.description,
            price=product.price,
            quantity=product.quantity,
            created_at=product.created_at,
            updated_at=product.updated_at,
            is_in_stock=product.is_in_stock()
        )


class GetProductUseCase(UseCase):
    """Use case for getting a product by ID"""
    
    def __init__(self, product_repository: ProductRepository):
        super().__init__()
        self.product_repository = product_repository
    
    def execute(self, product_id: str) -> Optional[ProductResponse]:
        """Execute the use case"""
        product = self.product_repository.get_by_id(product_id)
        
        if not product:
            self.add_error("Product not found")
            return None
        
        return ProductResponse(
            id=product.id,
            name=product.name,
            description=product.description,
            price=product.price,
            quantity=product.quantity,
            created_at=product.created_at,
            updated_at=product.updated_at,
            is_in_stock=product.is_in_stock()
        )


class UpdateProductUseCase(UseCase):
    """Use case for updating a product"""
    
    def __init__(self, product_repository: ProductRepository, product_service: ProductService):
        super().__init__()
        self.product_repository = product_repository
        self.product_service = product_service
    
    def execute(self, product_id: str, request: UpdateProductRequest) -> Optional[ProductResponse]:
        """Execute the use case"""
        product = self.product_repository.get_by_id(product_id)
        
        if not product:
            self.add_error("Product not found")
            return None
        
        # Update fields if provided
        if request.name is not None:
            product.name = request.name
        
        if request.description is not None:
            product.description = request.description
        
        if request.price is not None:
            product.update_price(request.price)
        
        if request.quantity is not None:
            product.update_quantity(request.quantity)
        
        # Save to repository
        self.product_repository.save(product)
        
        # Return response
        return ProductResponse(
            id=product.id,
            name=product.name,
            description=product.description,
            price=product.price,
            quantity=product.quantity,
            created_at=product.created_at,
            updated_at=product.updated_at,
            is_in_stock=product.is_in_stock()
        )


class CreateUserUseCase(UseCase):
    """Use case for creating a new user"""
    
    def __init__(self, user_repository: UserRepository, user_service: UserService):
        super().__init__()
        self.user_repository = user_repository
        self.user_service = user_service
    
    def execute(self, request: CreateUserRequest) -> Optional[UserResponse]:
        """Execute the use case"""
        # Validate input
        errors = self.user_service.validate_user_data(request.email, request.firebase_uid)
        
        for error in errors:
            self.add_error(error)
        
        if self.has_errors():
            return None
        
        # Check if user already exists
        existing_user = self.user_repository.get_by_firebase_uid(request.firebase_uid)
        if existing_user:
            self.add_error("User already exists")
            return None
        
        # Create user
        user = User.create(
            email=request.email,
            firebase_uid=request.firebase_uid
        )
        
        # Save to repository
        self.user_repository.save(user)
        
        # Return response
        return UserResponse(
            id=user.id,
            email=user.email,
            firebase_uid=user.firebase_uid,
            is_active=user.is_active,
            created_at=user.created_at,
            updated_at=user.updated_at
        )


class StockAdjustmentUseCase(UseCase):
    """Use case for adjusting product stock"""
    
    def __init__(self, product_repository: ProductRepository, inventory_service: InventoryService):
        super().__init__()
        self.product_repository = product_repository
        self.inventory_service = inventory_service
    
    def execute(self, request: StockAdjustmentRequest) -> Optional[ProductResponse]:
        """Execute the use case"""
        product = self.product_repository.get_by_id(request.product_id)
        
        if not product:
            self.add_error("Product not found")
            return None
        
        # Process stock adjustment
        updated_product = self.inventory_service.process_stock_adjustment(
            product, request.adjustment, request.reason
        )
        
        # Save to repository
        self.product_repository.save(updated_product)
        
        # Return response
        return ProductResponse(
            id=updated_product.id,
            name=updated_product.name,
            description=updated_product.description,
            price=updated_product.price,
            quantity=updated_product.quantity,
            created_at=updated_product.created_at,
            updated_at=updated_product.updated_at,
            is_in_stock=updated_product.is_in_stock()
        )


class GenerateInventoryReportUseCase(UseCase):
    """Use case for generating inventory report"""
    
    def __init__(self, product_repository: ProductRepository, inventory_service: InventoryService):
        super().__init__()
        self.product_repository = product_repository
        self.inventory_service = inventory_service
    
    def execute(self, request: InventoryReportRequest) -> Optional[InventoryReportResponse]:
        """Execute the use case"""
        # Get all products
        products = self.product_repository.get_all()
        
        if not products:
            self.add_error("No products found")
            return None
        
        # Calculate totals
        total_products = len(products)
        total_value = sum(product.price * product.quantity for product in products)
        
        # Get low stock products
        low_stock_products = []
        if request.include_low_stock:
            low_stock_products = self.inventory_service.get_products_needing_restock(
                products, request.low_stock_threshold
            )
        
        # Get out of stock products
        out_of_stock_products = []
        if request.include_out_of_stock:
            out_of_stock_products = [p for p in products if p.quantity == 0]
        
        # Convert to DTOs
        low_stock_dtos = [
            ProductResponse(
                id=p.id, name=p.name, description=p.description,
                price=p.price, quantity=p.quantity,
                created_at=p.created_at, updated_at=p.updated_at,
                is_in_stock=p.is_in_stock()
            ) for p in low_stock_products
        ]
        
        out_of_stock_dtos = [
            ProductResponse(
                id=p.id, name=p.name, description=p.description,
                price=p.price, quantity=p.quantity,
                created_at=p.created_at, updated_at=p.updated_at,
                is_in_stock=p.is_in_stock()
            ) for p in out_of_stock_products
        ]
        
        return InventoryReportResponse(
            total_products=total_products,
            total_value=total_value,
            low_stock_products=low_stock_dtos,
            out_of_stock_products=out_of_stock_dtos,
            generated_at=datetime.utcnow()
        )







