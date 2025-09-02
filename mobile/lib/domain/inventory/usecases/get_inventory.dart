import 'package:mobile/domain/inventory/entity/inventory.dart';
import 'package:mobile/domain/inventory/repository/inventory_repository.dart';

class GetInventory {
  final InventoryRepository repository;

  GetInventory(this.repository);

  Future<List<Inventory>> call() async {
    return await repository.getInventory();
  }
}