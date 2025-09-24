import 'package:flutter/material.dart';
import 'package:mobile/presentation/qr_scanner/widget/product_popup.dart';
import 'package:mobile/domain/product/usecases/get_product_by_sku.dart';
import 'package:mobile/domain/product/usecases/update_product_quantity_usecase.dart'; // ✅ fixed import
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:get_it/get_it.dart';

class QrScannerPage extends StatefulWidget {
  const QrScannerPage({super.key});

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan Product")),
      body: MobileScanner(
        onDetect: (capture) async {
          if (_isProcessing) return;
          _isProcessing = true;

          final sku = capture.barcodes.first.rawValue;
          if (sku != null) {
            print("📷 QR scanned: $sku");

            // ✅ Pull correct dependencies from GetIt
            final getProductBySku = GetIt.I<GetProductBySku>();
            final updateQuantity = GetIt.I<UpdateProductQuantityUseCase>();

            await showDialog(
              context: context,
              builder: (_) => ProductPopup(
                sku: sku,
                getProductBySku: getProductBySku,
                updateQuantity: updateQuantity,
              ),
            );

            // ✅ Reset flag when dialog closes
            _isProcessing = false;
          } else {
            _isProcessing = false;
          }
        },
      ),
    );
  }
}
