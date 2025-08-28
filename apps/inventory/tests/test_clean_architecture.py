"""
Tests for Clean Architecture components
"""
import pytest
from decimal import Decimal
from datetime import datetime
from unittest.mock import Mock, MagicMock

from apps.domain.entities import Product, User
from apps.domain.services import ProductService, UserService, InventoryService
from apps.application.use_cases import (
    CreateProductUseCase, GetProductUseCase, UpdateProductUseCase
)
from apps.application.dtos import CreateProductRequest, UpdateProductRequest
from apps.infrastructure.services import ConcreteProductService, ConcreteUserService, ConcreteInventoryService


class TestDomainEntities:
    """Test domain entities"""
    
    def test_product_creation(self):
        """Test product creation with factory method"""
        product = Product.create(
            name="Test Product",
            description="Test Description",
            price=Decimal("10.99"),
            quantity=5
        )
        
        assert product.name == "Test Product"
        assert product.description == "Test Description"
        assert product.price == Decimal("10.99")
        assert product.quantity == 5
        assert product.is_in_stock() is True
        assert isinstance(product.id, str)
        assert isinstance(product.created_at, datetime)
        assert isinstance(product.updated_at, datetime)
    
    def test_product_stock_update(self):
        """Test product stock update"""
        product = Product.create(
            name="Test Product",
            description="Test Description",
            price=Decimal("10.99"),
            quantity=5
        )
        
        original_updated_at = product.updated_at
        
        # Update quantity
        product.update_quantity(10)
        assert product.quantity == 10
        assert product.updated_at > original_updated_at
        
        # Test negative quantity validation
        with pytest.raises(ValueError, match="Quantity cannot be negative"):
            product.update_quantity(-1)
    
    def test_product_price_update(self):
        """Test product price update"""
        product = Product.create(
            name="Test Product",
            description="Test Description",
            price=Decimal("10.99"),
            quantity=5
        )
        
        original_updated_at = product.updated_at
        
        # Update price
        product.update_price(Decimal("15.99"))
        assert product.price == Decimal("15.99")
        assert product.updated_at > original_updated_at
        
        # Test negative price validation
        with pytest.raises(ValueError, match="Price cannot be negative"):
            product.update_price(Decimal("-1.00"))
    
    def test_user_creation(self):
        """Test user creation with factory method"""
        user = User.create(
            email="test@example.com",
            firebase_uid="firebase_uid_123"
        )
        
        assert user.email == "test@example.com"
        assert user.firebase_uid == "firebase_uid_123"
        assert user.is_active is True
        assert isinstance(user.id, str)
        assert isinstance(user.created_at, datetime)
        assert isinstance(user.updated_at, datetime)
    
    def test_user_activation_deactivation(self):
        """Test user activation and deactivation"""
        user = User.create(
            email="test@example.com",
            firebase_uid="firebase_uid_123"
        )
        
        original_updated_at = user.updated_at
        
        # Deactivate user
        user.deactivate()
        assert user.is_active is False
        assert user.updated_at > original_updated_at
        
        # Reactivate user
        user.activate()
        assert user.is_active is True


class TestDomainServices:
    """Test domain services"""
    
    def test_product_service_validation(self):
        """Test product service validation"""
        service = ConcreteProductService()
        
        # Valid data
        errors = service.validate_product_data("Valid Product", 10.99, 5)
        assert len(errors) == 0
        
        # Invalid data
        errors = service.validate_product_data("", -1, -5)
        assert len(errors) == 3
        assert "Product name is required" in errors
        assert "Price cannot be negative" in errors
        assert "Quantity cannot be negative" in errors
    
    def test_user_service_email_validation(self):
        """Test user service email validation"""
        service = ConcreteUserService()
        
        # Valid emails
        assert service.is_email_valid("test@example.com") is True
        assert service.is_email_valid("user.name@domain.co.uk") is True
        
        # Invalid emails
        assert service.is_email_valid("") is False
        assert service.is_email_valid("invalid-email") is False
        assert service.is_email_valid("@domain.com") is False


class TestUseCases:
    """Test use cases"""
    
    def test_create_product_use_case_success(self):
        """Test successful product creation"""
        # Mock dependencies
        mock_repository = Mock()
        mock_service = Mock()
        mock_service.validate_product_data.return_value = []
        mock_repository.get_by_name.return_value = None
        
        # Create use case
        use_case = CreateProductUseCase(mock_repository, mock_service)
        
        # Execute
        request = CreateProductRequest(
            name="Test Product",
            description="Test Description",
            price=Decimal("10.99"),
            quantity=5
        )
        
        result = use_case.execute(request)
        
        # Assertions
        assert result is not None
        assert result.name == "Test Product"
        assert use_case.has_errors() is False
        mock_repository.save.assert_called_once()
    
    def test_create_product_use_case_validation_error(self):
        """Test product creation with validation errors"""
        # Mock dependencies
        mock_repository = Mock()
        mock_service = Mock()
        mock_service.validate_product_data.return_value = ["Name is required"]
        
        # Create use case
        use_case = CreateProductUseCase(mock_repository, mock_service)
        
        # Execute
        request = CreateProductRequest(
            name="",
            description="Test Description",
            price=Decimal("10.99"),
            quantity=5
        )
        
        result = use_case.execute(request)
        
        # Assertions
        assert result is None
        assert use_case.has_errors() is True
        assert "Name is required" in use_case.errors
        mock_repository.save.assert_not_called()
    
    def test_get_product_use_case_success(self):
        """Test successful product retrieval"""
        # Mock repository
        mock_repository = Mock()
        mock_product = Product.create(
            name="Test Product",
            description="Test Description",
            price=Decimal("10.99"),
            quantity=5
        )
        mock_repository.get_by_id.return_value = mock_product
        
        # Create use case
        use_case = GetProductUseCase(mock_repository)
        
        # Execute
        result = use_case.execute("test-id")
        
        # Assertions
        assert result is not None
        assert result.name == "Test Product"
        assert use_case.has_errors() is False
    
    def test_get_product_use_case_not_found(self):
        """Test product retrieval when not found"""
        # Mock repository
        mock_repository = Mock()
        mock_repository.get_by_id.return_value = None
        
        # Create use case
        use_case = GetProductUseCase(mock_repository)
        
        # Execute
        result = use_case.execute("non-existent-id")
        
        # Assertions
        assert result is None
        assert use_case.has_errors() is True
        assert "Product not found" in use_case.errors


class TestInfrastructureServices:
    """Test infrastructure service implementations"""
    
    def test_concrete_product_service(self):
        """Test concrete product service implementation"""
        service = ConcreteProductService()
        
        # Test total value calculation
        products = [
            Product.create("Product 1", "Desc 1", Decimal("10.00"), 2),
            Product.create("Product 2", "Desc 2", Decimal("15.00"), 3)
        ]
        
        total_value = service.calculate_total_value(products)
        expected_value = 10.00 * 2 + 15.00 * 3
        assert total_value == expected_value
        
        # Test low stock products
        low_stock_products = service.get_products_needing_restock(products, threshold=5)
        assert len(low_stock_products) == 2  # Both products have quantity <= 5
    
    def test_concrete_inventory_service(self):
        """Test concrete inventory service implementation"""
        service = ConcreteInventoryService()
        
        product = Product.create("Test Product", "Test Description", Decimal("10.99"), 10)
        
        # Test stock adjustment
        updated_product = service.process_stock_adjustment(product, -3, "Sale")
        assert updated_product.quantity == 7
        
        # Test stock availability
        assert service.check_stock_availability(product, 5) is True
        assert service.check_stock_availability(product, 15) is False
        
        # Test reorder point calculation
        reorder_point = service.calculate_reorder_point(product, 7, 2.0)
        expected = int(2.0 * 2 + 2.0 * 7)  # safety_stock + lead_time_stock
        assert reorder_point == expected
        
        # Test negative stock adjustment validation
        with pytest.raises(ValueError, match="Stock adjustment would result in negative quantity"):
            service.process_stock_adjustment(product, -15, "Return")


if __name__ == "__main__":
    pytest.main([__file__])







