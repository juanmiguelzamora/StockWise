import 'package:mobile/domain/product/entity/product.dart';

class ProductModel extends Product {
  ProductModel({
    required String sku,
    required String name,
    required String category,
    required int quantity,
    required String imageUrl,
  }) : super(sku: sku, name: name, category: category, quantity: quantity, imageUrl: imageUrl);

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      sku: json['sku'] as String,
      name: json['name'] as String,
      category: (json['category'] ?? '') as String,
      quantity: json['quantity'] as int,
      imageUrl: (json['image_url'] ?? '') as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sku': sku,
      'name': name,
      'category': category,
      'quantity': quantity,
      'image_url': imageUrl,
    };
  }
}