import 'package:mobile/domain/inventory/entity/inventory.dart';

class Product {
  final String sku;
  final String name;
  final String category;
  final String imageUrl;
  final Inventory? inventory;

  Product({
    required this.sku,
    required this.name,
    required this.category,
    required this.imageUrl,
    this.inventory,
  });

  Product copyWith({
    String? sku,
    String? name,
    String? category,
    String? imageUrl,
    Inventory? inventory,
  }) {
    return Product(
      sku: sku ?? this.sku,
      name: name ?? this.name,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      inventory: inventory ?? this.inventory,
    );
  }
}

/// StockStatus enum used by the UI to show a badge.
enum StockStatus { inStock, lowStock, outOfStock }

StockStatus stockStatusFromInventory(Inventory? inv) {
  final q = inv?.totalStock ?? 0;
  if (q == 0) return StockStatus.outOfStock;
  if (q <= 10) return StockStatus.lowStock; // business rule for low stock
  return StockStatus.inStock;
}
