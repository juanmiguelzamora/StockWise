from rest_framework import serializers
from decimal import Decimal
from datetime import datetime

from ..application.dtos import (
    CreateProductRequest, UpdateProductRequest, ProductResponse,
    CreateUserRequest, UserResponse, StockAdjustmentRequest,
    InventoryReportRequest, InventoryReportResponse
)


class CreateProductRequestSerializer(serializers.Serializer):
    """Serializer for creating a product"""
    name = serializers.CharField(max_length=100)
    description = serializers.CharField(required=False, allow_blank=True, allow_null=True)
    price = serializers.DecimalField(max_digits=10, decimal_places=2)
    quantity = serializers.IntegerField(min_value=0)
    
    def to_dto(self) -> CreateProductRequest:
        """Convert to DTO"""
        return CreateProductRequest(
            name=self.validated_data['name'],
            description=self.validated_data.get('description'),
            price=self.validated_data['price'],
            quantity=self.validated_data['quantity']
        )


class UpdateProductRequestSerializer(serializers.Serializer):
    """Serializer for updating a product"""
    name = serializers.CharField(max_length=100, required=False)
    description = serializers.CharField(required=False, allow_blank=True, allow_null=True)
    price = serializers.DecimalField(max_digits=10, decimal_places=2, required=False)
    quantity = serializers.IntegerField(min_value=0, required=False)
    
    def to_dto(self) -> UpdateProductRequest:
        """Convert to DTO"""
        return UpdateProductRequest(
            name=self.validated_data.get('name'),
            description=self.validated_data.get('description'),
            price=self.validated_data.get('price'),
            quantity=self.validated_data.get('quantity')
        )


class ProductResponseSerializer(serializers.Serializer):
    """Serializer for product response"""
    id = serializers.CharField()
    name = serializers.CharField()
    description = serializers.CharField(allow_null=True)
    price = serializers.DecimalField(max_digits=10, decimal_places=2)
    quantity = serializers.IntegerField()
    created_at = serializers.DateTimeField()
    updated_at = serializers.DateTimeField()
    is_in_stock = serializers.BooleanField()
    
    @classmethod
    def from_dto(cls, dto: ProductResponse):
        """Create serializer from DTO"""
        return cls(dto)


class CreateUserRequestSerializer(serializers.Serializer):
    """Serializer for creating a user"""
    email = serializers.EmailField()
    firebase_uid = serializers.CharField()
    
    def to_dto(self) -> CreateUserRequest:
        """Convert to DTO"""
        return CreateUserRequest(
            email=self.validated_data['email'],
            firebase_uid=self.validated_data['firebase_uid']
        )


class UserResponseSerializer(serializers.Serializer):
    """Serializer for user response"""
    id = serializers.CharField()
    email = serializers.EmailField()
    firebase_uid = serializers.CharField()
    is_active = serializers.BooleanField()
    created_at = serializers.DateTimeField()
    updated_at = serializers.DateTimeField()
    
    @classmethod
    def from_dto(cls, dto: UserResponse):
        """Create serializer from DTO"""
        return cls(dto)


class StockAdjustmentRequestSerializer(serializers.Serializer):
    """Serializer for stock adjustment"""
    product_id = serializers.CharField()
    adjustment = serializers.IntegerField()
    reason = serializers.CharField(max_length=200)
    
    def to_dto(self) -> StockAdjustmentRequest:
        """Convert to DTO"""
        return StockAdjustmentRequest(
            product_id=self.validated_data['product_id'],
            adjustment=self.validated_data['adjustment'],
            reason=self.validated_data['reason']
        )


class InventoryReportRequestSerializer(serializers.Serializer):
    """Serializer for inventory report request"""
    include_low_stock = serializers.BooleanField(default=True)
    low_stock_threshold = serializers.IntegerField(default=5, min_value=1)
    include_out_of_stock = serializers.BooleanField(default=True)
    
    def to_dto(self) -> InventoryReportRequest:
        """Convert to DTO"""
        return InventoryReportRequest(
            include_low_stock=self.validated_data.get('include_low_stock', True),
            low_stock_threshold=self.validated_data.get('low_stock_threshold', 5),
            include_out_of_stock=self.validated_data.get('include_out_of_stock', True)
        )


class InventoryReportResponseSerializer(serializers.Serializer):
    """Serializer for inventory report response"""
    total_products = serializers.IntegerField()
    total_value = serializers.DecimalField(max_digits=15, decimal_places=2)
    low_stock_products = ProductResponseSerializer(many=True)
    out_of_stock_products = ProductResponseSerializer(many=True)
    generated_at = serializers.DateTimeField()
    
    @classmethod
    def from_dto(cls, dto: InventoryReportResponse):
        """Create serializer from DTO"""
        return cls(dto)


class ErrorResponseSerializer(serializers.Serializer):
    """Serializer for error responses"""
    errors = serializers.ListField(child=serializers.CharField())
    message = serializers.CharField()
    status_code = serializers.IntegerField()







