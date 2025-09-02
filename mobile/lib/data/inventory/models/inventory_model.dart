import 'package:mobile/domain/inventory/entity/inventory.dart';

class InventoryModel extends Inventory {

  InventoryModel({
    required String item,
    required int stockIn,
    required int stockOut,
    required int totalStock,
  }) : super(
          item: item,
          stockIn: stockIn,
          stockOut: stockOut,
          totalStock: totalStock,
        );

  factory InventoryModel.fromJson(Map<String, dynamic> json) {
    return InventoryModel(
      item: json['item'],
      stockIn: json['stock_in'],
      stockOut: json['stock_out'],
      totalStock: json['total_stock'],
    );
  }
}