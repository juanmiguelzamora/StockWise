// lib/domain/entities/product.dart
/// Domain entity representing a product.
///
/// This is the core business object used across the domain and presentation layers.
class Product {
  final String sku;
  final String name;
  final String category;
  final int quantity;
  final String imageUrl;

  Product({
    required this.sku,
    required this.name,
    required this.category,
    required this.quantity,
    required this.imageUrl,
  });

  Product copyWith({int? quantity}) {
    return Product(
      sku: sku,
      name: name,
      category: category,
      quantity: quantity ?? this.quantity,
      imageUrl: imageUrl,
    );
  }
}

/// StockStatus enum used by the UI to show a badge.
enum StockStatus { inStock, lowStock, outOfStock }

StockStatus stockStatusFromQuantity(int q) {
  if (q == 0) return StockStatus.outOfStock;
  if (q <= 10) return StockStatus.lowStock; // business rule for low stock
  return StockStatus.inStock;
}
