import 'package:mobile/data/inventory/datasources/inventory_remote_datasource.dart';
import 'package:mobile/domain/inventory/entity/inventory.dart';
import 'package:mobile/domain/inventory/repository/inventory_repository.dart';

class InventoryRepositoryImpl implements InventoryRepository{
  final InventoryRemoteDataSource remoteDataSource;

  InventoryRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Inventory>> getInventory() async {
    return await remoteDataSource.getInventory();
  }
}