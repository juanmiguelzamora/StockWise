from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status
from django.http import JsonResponse
import json


# Import Django models for repository injection
from apps.inventory.inventory.models import Product as ProductModel
from apps.users.models import User as UserModel

# Import clean architecture components
from apps.domain.entities import Product, User, ProductRepository, UserRepository
from apps.domain.services import ProductService, UserService, InventoryService
from apps.application.use_cases import (
    CreateProductUseCase, GetProductUseCase, UpdateProductUseCase,
    CreateUserUseCase, StockAdjustmentUseCase, GenerateInventoryReportUseCase
)
from apps.infrastructure.repositories import DjangoProductRepository, DjangoUserRepository
from apps.infrastructure.services import ConcreteProductService, ConcreteUserService, ConcreteInventoryService
from .serializers import (
    CreateProductRequestSerializer, UpdateProductRequestSerializer, ProductResponseSerializer,
    CreateUserRequestSerializer, UserResponseSerializer, StockAdjustmentRequestSerializer,
    InventoryReportRequestSerializer, InventoryReportResponseSerializer, ErrorResponseSerializer
)


class BaseView:
    """Base view class with common functionality"""
    
    def __init__(self):
        # Initialize repositories
        self.product_repository = DjangoProductRepository(ProductModel)
        self.user_repository = DjangoUserRepository(UserModel)
        
        # Initialize services
        self.product_service = ConcreteProductService()
        self.user_service = ConcreteUserService()
        self.inventory_service = ConcreteInventoryService()
    
    def create_error_response(self, errors, message="Validation failed", status_code=400):
        """Create standardized error response"""
        error_data = {
            "errors": errors,
            "message": message,
            "status_code": status_code
        }
        return Response(error_data, status=status_code)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def create_product(request):
    """Create a new product"""
    view = BaseView()
    
    # Validate request data
    serializer = CreateProductRequestSerializer(data=request.data)
    if not serializer.is_valid():
        return view.create_error_response(
            serializer.errors,
            "Invalid product data",
            status.HTTP_400_BAD_REQUEST
        )
    
    # Convert to DTO
    dto = serializer.to_dto()
    
    # Execute use case
    use_case = CreateProductUseCase(view.product_repository, view.product_service)
    result = use_case.execute(dto)
    
    if use_case.has_errors():
        return view.create_error_response(
            use_case.errors,
            "Failed to create product",
            status.HTTP_400_BAD_REQUEST
        )
    
    # Return response
    response_serializer = ProductResponseSerializer.from_dto(result)
    return Response(response_serializer.data, status=status.HTTP_201_CREATED)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_product(request, product_id):
    """Get a product by ID"""
    view = BaseView()
    
    # Execute use case
    use_case = GetProductUseCase(view.product_repository)
    result = use_case.execute(product_id)
    
    if use_case.has_errors():
        return view.create_error_response(
            use_case.errors,
            "Failed to get product",
            status.HTTP_404_NOT_FOUND
        )
    
    # Return response
    response_serializer = ProductResponseSerializer.from_dto(result)
    return Response(response_serializer.data, status=status.HTTP_200_OK)


@api_view(['PUT'])
@permission_classes([IsAuthenticated])
def update_product(request, product_id):
    """Update a product"""
    view = BaseView()
    
    # Validate request data
    serializer = UpdateProductRequestSerializer(data=request.data)
    if not serializer.is_valid():
        return view.create_error_response(
            serializer.errors,
            "Invalid product data",
            status.HTTP_400_BAD_REQUEST
        )
    
    # Convert to DTO
    dto = serializer.to_dto()
    
    # Execute use case
    use_case = UpdateProductUseCase(view.product_repository, view.product_service)
    result = use_case.execute(product_id, dto)
    
    if use_case.has_errors():
        return view.create_error_response(
            use_case.errors,
            "Failed to update product",
            status.HTTP_400_BAD_REQUEST
        )
    
    # Return response
    response_serializer = ProductResponseSerializer.from_dto(result)
    return Response(response_serializer.data, status=status.HTTP_200_OK)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def create_user(request):
    """Create a new user"""
    view = BaseView()
    
    # Validate request data
    serializer = CreateUserRequestSerializer(data=request.data)
    if not serializer.is_valid():
        return view.create_error_response(
            serializer.errors,
            "Invalid user data",
            status.HTTP_400_BAD_REQUEST
        )
    
    # Convert to DTO
    dto = serializer.to_dto()
    
    # Execute use case
    use_case = CreateUserUseCase(view.user_repository, view.user_service)
    result = use_case.execute(dto)
    
    if use_case.has_errors():
        return view.create_error_response(
            use_case.errors,
            "Failed to create user",
            status.HTTP_400_BAD_REQUEST
        )
    
    # Return response
    response_serializer = UserResponseSerializer.from_dto(result)
    return Response(response_serializer.data, status=status.HTTP_201_CREATED)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def adjust_stock(request):
    """Adjust product stock"""
    view = BaseView()
    
    # Validate request data
    serializer = StockAdjustmentRequestSerializer(data=request.data)
    if not serializer.is_valid():
        return view.create_error_response(
            serializer.errors,
            "Invalid stock adjustment data",
            status.HTTP_400_BAD_REQUEST
        )
    
    # Convert to DTO
    dto = serializer.to_dto()
    
    # Execute use case
    use_case = StockAdjustmentUseCase(view.product_repository, view.inventory_service)
    result = use_case.execute(dto)
    
    if use_case.has_errors():
        return view.create_error_response(
            use_case.errors,
            "Failed to adjust stock",
            status.HTTP_400_BAD_REQUEST
        )
    
    # Return response
    response_serializer = ProductResponseSerializer.from_dto(result)
    return Response(response_serializer.data, status=status.HTTP_200_OK)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def generate_inventory_report(request):
    """Generate inventory report"""
    view = BaseView()
    
    # Validate request data
    serializer = InventoryReportRequestSerializer(data=request.data)
    if not serializer.is_valid():
        return view.create_error_response(
            serializer.errors,
            "Invalid report request data",
            status.HTTP_400_BAD_REQUEST
        )
    
    # Convert to DTO
    dto = serializer.to_dto()
    
    # Execute use case
    use_case = GenerateInventoryReportUseCase(view.product_repository, view.inventory_service)
    result = use_case.execute(dto)
    
    if use_case.has_errors():
        return view.create_error_response(
            use_case.errors,
            "Failed to generate inventory report",
            status.HTTP_400_BAD_REQUEST
        )
    
    # Return response
    response_serializer = InventoryReportResponseSerializer.from_dto(result)
    return Response(response_serializer.data, status=status.HTTP_200_OK)


# Test endpoint for debugging
@api_view(['GET'])
@permission_classes([])
def test_connection(request):
    """Simple test endpoint to verify connectivity"""
    return JsonResponse({"message": "Backend is working! Connection successful."})

# Legacy Firebase view for backward compatibility
@api_view(['POST'])
@permission_classes([])
def protected_data(request):
    """Legacy Firebase protected data endpoint"""
    if request.method == "POST":
        try:
            body = json.loads(request.body)
            id_token = body.get("idToken")
            
            # Import here to avoid circular imports
            from apps.users.firebase_config import firebase_auth
            decoded_token = firebase_auth.verify_id_token(id_token)
            uid = decoded_token["uid"]
            
            return JsonResponse({"message": f"Hello, user {uid}! This is protected data."})
        except Exception as e:
            return JsonResponse({"error": str(e)}, status=401)
    
    return JsonResponse({"error": "POST required"}, status=400)
