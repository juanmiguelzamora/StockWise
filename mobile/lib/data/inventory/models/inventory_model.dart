import 'package:mobile/domain/inventory/entity/inventory.dart';

class InventoryModel extends Inventory {

  InventoryModel({
    required String item,
    required int stockIn,
    required int stockOut,
    required int totalStock,
    required double averageDailySales,
  }) : super(
          item: item,
          stockIn: stockIn,
          stockOut: stockOut,
          totalStock: totalStock,
          averageDailySales: averageDailySales,
        );

  factory InventoryModel.fromJson(Map<String, dynamic> json) {
    return InventoryModel(
      item: json['item'],
      stockIn: json['stock_in'],
      stockOut: json['stock_out'],
      totalStock: json['total_stock'],
      averageDailySales: (json['average_daily_sales'] as num).toDouble()
    );
  }
}