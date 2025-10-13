import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/core/configs/theme/app_colors.dart';
import 'package:mobile/domain/product/usecases/get_product_by_sku.dart';
import 'package:mobile/domain/product/usecases/update_product_quantity_usecase.dart';
import 'package:mobile/presentation/qr_scanner/controllers/qr_scanner_controller.dart';
import 'package:mobile/presentation/qr_scanner/widget/product_popup.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScannerPage extends StatefulWidget {
  const QrScannerPage({super.key});

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage>
    with SingleTickerProviderStateMixin {
  late final QrScannerController _controller;
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _controller = QrScannerController(
      mobileScannerController: MobileScannerController(),
      getProductBySku: GetIt.I<GetProductBySku>(),
      updateQuantity: GetIt.I<UpdateProductQuantityUseCase>(),
    );

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final cameraSize = size.width * 0.8;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: AppColors.blueLight,
      appBar: AppBar(
        title: const Text(
          "Scan Product",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ValueListenableBuilder<QrScannerState>(
        valueListenable: _controller,
        builder: (context, state, _) {
          return Stack(
            children: [
              // --- Fullscreen blurred background ---
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    color: Colors.black.withOpacity(0.6),
                  ),
                ),
              ),

              // --- Centered 1:1 Camera Feed ---
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: SizedBox(
                    width: cameraSize,
                    height: cameraSize,
                    child: MobileScanner(
                      controller: _controller.mobileScannerController,
                      fit: BoxFit.cover,
                      onDetect: (capture) => _controller.handleQrCode(capture),
                    ),
                  ),
                ),
              ),

              // --- Scanning Frame Overlay ---
              Center(
                child: Container(
                  width: cameraSize,
                  height: cameraSize,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.8),
                      width: 2,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Animated scanning line
                      AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, _) {
                          final position =
                              _animationController.value * cameraSize;
                          return Positioned(
                            top: position,
                            left: cameraSize * 0.05,
                            right: cameraSize * 0.05,
                            child: Container(
                              height: 2,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    AppColors.primary.withOpacity(0.9),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // --- Helper Text ---
              Positioned(
                bottom: 120,
                left: 0,
                right: 0,
                child: Column(
                  children: const [
                    Text(
                      "Align QR code within the frame",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 10),
                    Icon(
                      Icons.qr_code_scanner_rounded,
                      size: 36,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),

              // --- Product Popup Overlay ---
              if (state.showPopup)
                AnimatedOpacity(
                  opacity: state.showPopup ? 1 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(
                      color: Colors.black.withOpacity(0.5),
                      child: Center(
                        child: ConstrainedBox(
                          constraints:
                              BoxConstraints(maxWidth: size.width * 0.85),
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
