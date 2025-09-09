import 'package:mobile/domain/inventory/entity/inventory.dart';

class GetStockStatus {
  List<Inventory> filterByStatus(List<Inventory> items, String status) {
    return items.where((item) => item.stockStatus == status).toList();
  }
}
