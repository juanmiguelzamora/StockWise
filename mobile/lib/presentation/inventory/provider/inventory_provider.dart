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

  InventorySummary? _summary;
  InventorySummary? get summary => _summary;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _hasError = false;
  bool get hasError => _hasError;

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

  /// Fetches inventory data and computes summary.
  /// Keeps showing last known data if the backend fails.
  Future<void> fetchInventory() async {
    _isLoading = true;
    _hasError = false;
    notifyListeners();

    try {
      final result = await getInventoryUseCase();
      _items = result;
      _summary = getInventorySummaryUseCase(_items);
    } catch (e) {
      debugPrint("⚠️ Error fetching inventory: $e");
      _hasError = true;

      // Keep showing last known data if available
      if (_items.isNotEmpty && _summary == null) {
        _summary = getInventorySummaryUseCase(_items);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Allows manual refresh of summary from existing items (no API call)
  void refreshSummary() {
    if (_items.isNotEmpty) {
      _summary = getInventorySummaryUseCase(_items);
      notifyListeners();
    }
  }

  /// Clears all inventory data (for logout or cache reset)
  void clearData() {
    _items = [];
    _summary = null;
    _hasError = false;
    _isLoading = false;
    notifyListeners();
  }
}
