import 'package:flutter/material.dart';
import 'package:mobile/domain/inventory/entity/inventory.dart';
import 'package:mobile/domain/inventory/usecases/get_inventory.dart';

class InventoryProvider extends ChangeNotifier{
  final GetInventory getInventoryUseCase;

  InventoryProvider(this.getInventoryUseCase);

  List<Inventory> _items = [];
  List<Inventory> get items => _items;

  bool _loading = false;
  bool get loading => _loading;

  Future<void> fetchInventory() async {
    _loading = true;
    notifyListeners();

    try {
      _items = await getInventoryUseCase();
    } catch (e) {
      debugPrint("Error fetching inventory: $e");
    }

    _loading = false;
    notifyListeners();
  }
} 