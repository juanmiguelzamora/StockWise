from typing import List, Optional
from django.db import models
from django.db.models import Q

from ..domain.entities import Product, User, ProductRepository, UserRepository
from ..domain.services import ProductService, UserService, InventoryService


class DjangoProductRepository(ProductRepository):
    """Django ORM implementation of ProductRepository"""
    
    def __init__(self, product_model):
        self.product_model = product_model
    
    def save(self, entity: Product) -> None:
        """Save product to database"""
        if hasattr(entity, 'pk') and entity.pk:
            # Update existing
            self.product_model.objects.filter(pk=entity.pk).update(
                name=entity.name,
                description=entity.description,
                price=entity.price,
                quantity=entity.quantity,
                updated_at=entity.updated_at
            )
        else:
            # Create new
            self.product_model.objects.create(
                id=entity.id,
                name=entity.name,
                description=entity.description,
                price=entity.price,
                quantity=entity.quantity,
                created_at=entity.created_at,
                updated_at=entity.updated_at
            )
    
    def get_by_id(self, entity_id: str):
        """Get product by ID"""
        try:
            db_product = self.product_model.objects.get(id=entity_id)
            return self._to_domain_entity(db_product)
        except self.product_model.DoesNotExist:
            return None
    
    def get_by_name(self, name: str) -> Optional[Product]:
        """Get product by name"""
        try:
            db_product = self.product_model.objects.get(name=name)
            return self._to_domain_entity(db_product)
        except self.product_model.DoesNotExist:
            return None
    
    def get_low_stock_products(self, threshold: int = 5) -> List[Product]:
        """Get products with low stock"""
        db_products = self.product_model.objects.filter(quantity__lte=threshold)
        return [self._to_domain_entity(p) for p in db_products]
    
    def get_all(self) -> List[Product]:
        """Get all products"""
        db_products = self.product_model.objects.all()
        return [self._to_domain_entity(p) for p in db_products]
    
    def delete(self, entity_id: str) -> None:
        """Delete product by ID"""
        try:
            self.product_model.objects.filter(id=entity_id).delete()
        except self.product_model.DoesNotExist:
            pass
    
    def _to_domain_entity(self, db_product) -> Product:
        """Convert Django model to domain entity"""
        return Product(
            id=str(db_product.id),
            name=db_product.name,
            description=db_product.description,
            price=db_product.price,
            quantity=db_product.quantity,
            created_at=db_product.created_at,
            updated_at=db_product.updated_at
        )


class DjangoUserRepository(UserRepository):
    """Django ORM implementation of UserRepository"""
    
    def __init__(self, user_model):
        self.user_model = user_model
    
    def save(self, entity: User) -> None:
        """Save user to database"""
        if hasattr(entity, 'pk') and entity.pk:
            # Update existing
            self.user_model.objects.filter(pk=entity.pk).update(
                email=entity.email,
                firebase_uid=entity.firebase_uid,
                is_active=entity.is_active,
                updated_at=entity.updated_at
            )
        else:
            # Create new
            self.user_model.objects.create(
                id=entity.id,
                email=entity.email,
                firebase_uid=entity.firebase_uid,
                is_active=entity.is_active,
                created_at=entity.created_at,
                updated_at=entity.updated_at
            )
    
    def get_by_id(self, entity_id: str):
        """Get user by ID"""
        try:
            db_user = self.user_model.objects.get(id=entity_id)
            return self._to_domain_entity(db_user)
        except self.user_model.DoesNotExist:
            return None
    
    def get_by_firebase_uid(self, firebase_uid: str) -> Optional[User]:
        """Get user by Firebase UID"""
        try:
            db_user = self.user_model.objects.get(firebase_uid=firebase_uid)
            return self._to_domain_entity(db_user)
        except self.user_model.DoesNotExist:
            return None
    
    def get_by_email(self, email: str) -> Optional[User]:
        """Get user by email"""
        try:
            db_user = self.user_model.objects.get(email=email)
            return self._to_domain_entity(db_user)
        except self.user_model.DoesNotExist:
            return None
    
    def delete(self, entity_id: str) -> None:
        """Delete user by ID"""
        try:
            self.user_model.objects.filter(id=entity_id).delete()
        except self.user_model.DoesNotExist:
            pass
    
    def _to_domain_entity(self, db_user) -> User:
        """Convert Django model to domain entity"""
        return User(
            id=str(db_user.id),
            email=db_user.email,
            firebase_uid=db_user.firebase_uid,
            is_active=db_user.is_active,
            created_at=db_user.created_at,
            updated_at=db_user.updated_at
        )







