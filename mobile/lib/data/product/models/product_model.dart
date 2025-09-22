import 'package:mobile/domain/product/entity/product.dart';
import 'package:mobile/data/inventory/models/inventory_model.dart';

class ProductModel extends Product {
  final InventoryModel? inventory;

  ProductModel({
    required String sku,
    required String name,
    required String category,
    required String imageUrl,
    this.inventory,
  }) : super(
          sku: sku,
          name: name,
          category: category,
          imageUrl: imageUrl,
          inventory: inventory,
        );

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      sku: json['sku'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown',
      category: json['category'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? '',
      inventory: json['inventory'] != null
          ? InventoryModel.fromJson(json['inventory']) // Pass only inventory data
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sku': sku,
      'name': name,
      'category': category,
      'image_url': imageUrl,
      'inventory': inventory?.toJson(),
    };
  }
}

