import 'package:mobile/data/product/models/product_model.dart';
import 'package:mobile/domain/inventory/entity/inventory.dart';

class InventoryModel extends Inventory {
  final int id;
  @override
  final String stockStatus;
  final ProductModel? product; // Add product field

  InventoryModel({
    required this.id,
    required super.stockIn,
    required super.stockOut,
    required super.totalStock,
    required super.averageDailySales,
    required this.stockStatus,
    this.product, // Add to constructor
  }) : super(
          stockStatus: stockStatus,
        );

  factory InventoryModel.fromJson(Map<String, dynamic> json) {
    final inventoryJson = json['product']?['inventory'] ?? json;
    return InventoryModel(
      id: json['id'] ?? 0,
      stockIn: int.tryParse(inventoryJson['stock_in'].toString()) ?? 0,
      stockOut: int.tryParse(inventoryJson['stock_out'].toString()) ?? 0,
      totalStock: int.tryParse(inventoryJson['total_stock'].toString()) ?? 0,
      averageDailySales: double.tryParse(
              (inventoryJson['average_daily_sales'] ?? '0').toString()) ??
          0.0,
      stockStatus: inventoryJson['stock_status'] ?? 'out_of_stock',
      product: json['product'] != null
          ? ProductModel.fromJson(json['product'])
          : json['sku'] != null
              ? ProductModel.fromJson(json) // Handle case where json is already product-like
              : null, // Parse product if available
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'stock_in': stockIn,
        'stock_out': stockOut,
        'total_stock': totalStock,
        'average_daily_sales': averageDailySales,
        'stock_status': stockStatus,
        'product': product?.toJson(), // Include product in JSON
      };
}
