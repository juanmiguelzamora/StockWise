import 'package:flutter/material.dart';
import 'package:mobile/domain/inventory/entity/inventory.dart';
import 'package:mobile/domain/inventory/entity/inventory_summary.dart';
import 'package:mobile/domain/inventory/usecases/get_inventory.dart';
import 'package:mobile/domain/inventory/usecases/get_stock_status.dart';
import 'package:mobile/domain/inventory/usecases/get_inventory_summary.dart';

class InventoryProvider extends ChangeNotifier {
  final GetInventory getInventoryUseCase;
  final GetStockStatus getStockStatusUseCase;
  final GetInventorySummary getInventorySummaryUseCase;

  InventoryProvider(
    this.getInventoryUseCase,
    this.getStockStatusUseCase,
    this.getInventorySummaryUseCase,
  );

  List<Inventory> _items = [];
  List<Inventory> get items => _items;

  bool _loading = false;
  bool get loading => _loading;

  // Stock status counts
  int get outOfStockCount => outOfStock.length;
  int get lowStockCount => lowStock.length;
  int get overStockCount => overStock.length;

  // Filtered lists
  List<Inventory> get outOfStock =>
      getStockStatusUseCase.filterByStatus(_items, "Out of Stock");
  List<Inventory> get lowStock =>
      getStockStatusUseCase.filterByStatus(_items, "Low Stock");
  List<Inventory> get overStock =>
      getStockStatusUseCase.filterByStatus(_items, "Overstock");

  // New: Summary
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
