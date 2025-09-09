import 'package:mobile/domain/inventory/entity/inventory.dart';
import 'package:mobile/domain/inventory/entity/inventory_summary.dart';

class GetInventorySummary {
  InventorySummary call(List<Inventory> items) {
    int totalStock = 0;
    int stockIn = 0;
    int stockOut = 0;

    for (final item in items) {
      totalStock += item.totalStock;
      stockIn += item.stockIn;
      stockOut += item.stockOut;
    }

    return InventorySummary(
      date: DateTime.now(),
      totalStock: totalStock,
      stockIn: stockIn,
      stockOut: stockOut,
    );
  }
}
