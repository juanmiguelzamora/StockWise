import 'package:mobile/domain/product/entity/product.dart';

/// Abstract repository interface for products.
/// Implementations belong to the data layer.
abstract class ProductRepository {
  Future<List<Product>> getProducts();
  /// Update product quantity by SKU.
  Future<Product> updateProductQuantity(String sku, int newQuantity);

  /// Fetch single product by SKU
  Future<Product> getProductBySku(String sku);
}
