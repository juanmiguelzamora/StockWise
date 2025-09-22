import 'package:flutter/material.dart';
import 'package:mobile/domain/inventory/entity/inventory.dart';
import 'package:mobile/domain/inventory/entity/inventory_summary.dart';
import 'package:mobile/domain/inventory/usecases/get_inventory.dart';
import 'package:mobile/domain/inventory/usecases/get_inventory_summary.dart';

class InventoryProvider extends ChangeNotifier {
  final GetInventory getInventoryUseCase;
  final GetInventorySummary getInventorySummaryUseCase;

  InventoryProvider(
    this.getInventoryUseCase,
    this.getInventorySummaryUseCase,
  );

  List<Inventory> _items = [];
  List<Inventory> get items => _items;

  bool _loading = false;
  bool get loading => _loading;

  // Stock status filters using backend-provided stock_status field
  List<Inventory> get outOfStock =>
      _items.where((i) => i.stockStatus == "out_of_stock").toList();

  List<Inventory> get lowStock =>
      _items.where((i) => i.stockStatus == "low_stock").toList();

  List<Inventory> get inStock =>
      _items.where((i) => i.stockStatus == "in_stock").toList();

  // Counts
  int get outOfStockCount => outOfStock.length;
  int get lowStockCount => lowStock.length;
  int get inStockCount => inStock.length;

  // Summary
  InventorySummary? get summary =>
      _items.isEmpty ? null : getInventorySummaryUseCase(_items);

  Future<void> fetchInventory() async {
    _loading = true;
    notifyListeners();

    try {
      final result = await getInventoryUseCase();
      _items = result;
    } catch (e) {
      debugPrint("Error fetching inventory: $e");
    }

    _loading = false;
    notifyListeners();
  }
}
