import 'package:flutter/material.dart';
import 'package:mobile/domain/product/entity/product.dart';
import 'package:mobile/domain/product/usecases/get_product_usecase.dart';
import 'package:mobile/domain/product/usecases/update_product_quantity_usecase.dart';

/// Uses Provider for DI & state management.
class ProductProvider extends ChangeNotifier {
  final GetProductsUseCase getProductsUseCase;
  final UpdateProductQuantityUseCase updateQuantityUseCase;

  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;

  // Filters
  String _searchQuery = '';
  String? _categoryFilter; // null = All
  StockStatus? _statusFilter; // null = All

  ProductProvider({
    required this.getProductsUseCase,
    required this.updateQuantityUseCase,
  });

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;

  String? get categoryFilter => _categoryFilter;
  StockStatus? get statusFilter => _statusFilter;
  String get searchQuery => _searchQuery;

  // --- Filtering logic ---
  List<Product> get filteredProducts {
    var result = _products;

    if (_searchQuery.isNotEmpty) {
      result = result
          .where((p) =>
              p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              p.sku.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    if (_categoryFilter != null && _categoryFilter != "All") {
      result = result.where((p) => p.category == _categoryFilter).toList();
    }

    if (_statusFilter != null) {
      result = result
          .where((p) =>
              stockStatusFromInventory(p.inventory) == _statusFilter)
          .toList();
    }

    return result;
  }

  // --- Public filter setters ---
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  void setCategoryFilter(String? category) {
    _categoryFilter = category;
    notifyListeners();
  }

  void setStatusFilter(StockStatus? status) {
    _statusFilter = status;
    notifyListeners();
  }

  // --- Data loading ---
  Future<void> loadProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _products = await getProductsUseCase();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- Quantity updates ---
  Future<void> onQuantityIncrement(String sku) async {
    final idx = _products.indexWhere((p) => p.sku == sku);
    if (idx == -1) return;
    final current = _products[idx];
    final currentQty = current.inventory?.totalStock ?? 0;
    final newQty = currentQty + 1;

    try {
      final updated = await updateQuantityUseCase(sku, newQty);
      _products[idx] = updated;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> onQuantityDecrement(String sku) async {
    final idx = _products.indexWhere((p) => p.sku == sku);
    if (idx == -1) return;
    final current = _products[idx];
    final currentQty = current.inventory?.totalStock ?? 0;
    final newQty = currentQty - 1;
    if (newQty < 0) return;

    try {
      final updated = await updateQuantityUseCase(sku, newQty);
      _products[idx] = updated;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
