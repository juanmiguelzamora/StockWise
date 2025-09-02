import 'package:mobile/domain/inventory/entity/inventory.dart';

abstract class InventoryRepository {
  Future<List<Inventory>> getInventory();
}