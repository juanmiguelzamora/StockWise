import 'package:flutter/foundation.dart';
import 'package:mobile/domain/product/entity/product.dart';
import 'package:mobile/domain/product/usecases/get_product_by_sku.dart';
import 'package:mobile/domain/product/usecases/update_product_quantity_usecase.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScannerState {
  final bool isLoading;
  final bool showPopup;
  final String? sku;
  final Product? product;
  final int totalQuantity;  // Renamed from quantity
  final int adjustment;      // New: local adjustment amount
  final String? error;

  QrScannerState({
    this.isLoading = false,
    this.showPopup = false,
    this.sku,
    this.product,
    this.totalQuantity = 0,  // Renamed
    this.adjustment = 1,      // Default to 1; change to 0 if you want no default update
    this.error,
  });

  QrScannerState copyWith({
    bool? isLoading,
    bool? showPopup,
    String? sku,
    Product? product,
    int? totalQuantity,  
    int? adjustment,     
    String? error,
  }) {
    return QrScannerState(
      isLoading: isLoading ?? this.isLoading,
      showPopup: showPopup ?? this.showPopup,
      sku: sku ?? this.sku,
      product: product ?? this.product,
      totalQuantity: totalQuantity ?? this.totalQuantity,  
      adjustment: adjustment ?? this.adjustment,           
      error: error ?? this.error,
    );
  }
}

class QrScannerController extends ValueNotifier<QrScannerState> {
  final MobileScannerController mobileScannerController;
  final GetProductBySku getProductBySku;
  final UpdateProductQuantityUseCase updateQuantity;
  bool _isProcessing = false;

  QrScannerController({
    required this.mobileScannerController,
    required this.getProductBySku,
    required this.updateQuantity,
  }) : super(QrScannerState());

  Future<void> handleQrCode(BarcodeCapture capture) async {
    if (_isProcessing) return;
    _isProcessing = true;

    final sku = capture.barcodes.first.rawValue;
    if (sku == null) {
      _isProcessing = false;
      return;
    }

    await mobileScannerController.stop();
    value = value.copyWith(sku: sku, showPopup: true, isLoading: true);

    try {
      final product = await getProductBySku(sku);
      value = value.copyWith(
        product: product,
        totalQuantity: product.inventory?.totalStock ?? 0,  // Renamed
        adjustment: 0,  // Initialize adjustment; set to 0 if preferred
        isLoading: false,
      );
    } catch (e) {
      value = value.copyWith(isLoading: false, error: e.toString());
      _isProcessing = false;
    }
  }

  void incrementAdjustment() {
    value = value.copyWith(adjustment: value.adjustment + 1);
  }

  void decrementAdjustment() {
    if (value.adjustment > 0) {  // Or >1 if you want min 1
      value = value.copyWith(adjustment: value.adjustment - 1);
    }
  }

  Future<void> updateStock(bool isStockIn) async {
    final delta = isStockIn ? value.adjustment : -value.adjustment;
    final newQuantity = value.totalQuantity + delta;
    if (newQuantity < 0) return;

    try {
      final updated = await updateQuantity(value.sku!, newQuantity);
      value = value.copyWith(
        product: updated,
        totalQuantity: updated.inventory?.totalStock ?? 0,
        adjustment: 1,  // Reset to 1 (or 0); optional—could leave as-is for multiple applies
        error: null,
      );
      // Optionally call closePopup() here if you want to auto-close after update
    } catch (e) {
      value = value.copyWith(error: e.toString());
    }
  }

  void closePopup() {
    value = value.copyWith(showPopup: false, error: null);
    mobileScannerController.start();
    _isProcessing = false;
  }

  @override
  void dispose() {
    mobileScannerController.dispose();
    super.dispose();
  }
}