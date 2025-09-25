import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mobile/presentation/qr_scanner/controllers/qr_scanner_controller.dart';
import 'package:mobile/presentation/qr_scanner/widget/product_popup.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:mobile/domain/product/usecases/get_product_by_sku.dart';
import 'package:mobile/domain/product/usecases/update_product_quantity_usecase.dart';
import 'package:get_it/get_it.dart';

class QrScannerPage extends StatefulWidget {
  const QrScannerPage({super.key});

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  late final QrScannerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = QrScannerController(
      mobileScannerController: MobileScannerController(),
      getProductBySku: GetIt.I<GetProductBySku>(),
      updateQuantity: GetIt.I<UpdateProductQuantityUseCase>(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cameraSize = screenWidth * 0.8;

    return Scaffold(
      appBar: AppBar(title: const Text("Scan Product")),
      body: ValueListenableBuilder<QrScannerState>(
        valueListenable: _controller,
        builder: (context, state, child) {
          return Stack(
            children: [
              Center(
                child: Container(
                  width: cameraSize,
                  height: cameraSize,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                  ),
                  child: MobileScanner(
                    controller: _controller.mobileScannerController,
                    onDetect: (capture) => _controller.handleQrCode(capture),
                  ),
                ),
              ),
              if (state.showPopup)
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    color: Colors.black.withOpacity(0.3),
                  ),
                ),
              if (state.showPopup && state.sku != null)
                Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: screenWidth * 0.8),
                    child: ProductPopup(
                      state: state,
                      onStockIn: () => _controller.updateStock(true),
                      onStockOut: () => _controller.updateStock(false),
                      onClose: _controller.closePopup,
                      onIncrement: _controller.incrementAdjustment,  
                      onDecrement: _controller.decrementAdjustment,  
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}