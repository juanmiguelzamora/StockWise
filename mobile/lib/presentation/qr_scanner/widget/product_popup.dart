import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/core/configs/theme/app_colors.dart';
import 'package:mobile/presentation/qr_scanner/controllers/qr_scanner_controller.dart';

class ProductPopup extends StatelessWidget {
  final QrScannerState state;
  final VoidCallback onStockIn;
  final VoidCallback onStockOut;
  final VoidCallback onClose;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const ProductPopup({
    super.key,
    required this.state,
    required this.onStockIn,
    required this.onStockOut,
    required this.onClose,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final String mediaBaseUrl =
        GetIt.instance.get<String>(instanceName: "mediaBaseUrl");
    final product = state.product;

    String? imageUrl;
    if (product != null && product.imageUrl.isNotEmpty) {
      imageUrl = product.imageUrl.startsWith('http')
          ? product.imageUrl
          : '$mediaBaseUrl${product.imageUrl}';
    }

    return Card(
      elevation: 8,
      color: AppColors.surface,
      shadowColor: AppColors.shadow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // --- Product Title ---
              Text(
                product?.name ?? "Product",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 16),

              // --- Product Image ---
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: imageUrl != null
                    ? Image.network(
                        imageUrl,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _placeholderImage(),
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return _imageLoader();
                        },
                      )
                    : _placeholderImage(),
              ),
              const SizedBox(height: 16),

              // --- Info Section ---
              _infoRow("Category", product?.category ?? "-"),
              _infoRow("Stock Status", product?.inventory?.stockStatus ?? "-"),
              _infoRow("Current Stock", "${state.totalQuantity}"),
              const Divider(height: 24, color: AppColors.lightGray),

              // --- Quantity Adjuster ---
              Text(
                "Adjust Quantity",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.grayLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: state.adjustment > 0 ? onDecrement : null,
                      icon: const Icon(Icons.remove_circle_outline),
                      color: AppColors.textSecondary,
                    ),
                    Text(
                      "${state.adjustment}",
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: onIncrement,
                      icon: const Icon(Icons.add_circle_outline),
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // --- Action Buttons ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _actionButton(
                    label: "Stock Out",
                    color: AppColors.error,
                    enabled: state.adjustment > 0,
                    onTap: onStockOut,
                  ),
                  _actionButton(
                    label: "Stock In",
                    color: AppColors.success,
                    enabled: state.adjustment > 0,
                    onTap: onStockIn,
                  ),
                ],
              ),

              const SizedBox(height: 12),
              TextButton(
                onPressed: onClose,
                child: const Text(
                  "Close",
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          Text(value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              )),
        ],
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required Color color,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return ElevatedButton(
      onPressed: enabled ? onTap : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: enabled ? color : AppColors.lightGray,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: enabled ? 2 : 0,
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _placeholderImage() => Container(
        height: 120,
        width: double.infinity,
        color: AppColors.lightGray,
        child: const Icon(Icons.image_not_supported,
            size: 50, color: AppColors.textHint),
      );

  Widget _imageLoader() => Container(
        height: 120,
        alignment: Alignment.center,
        color: AppColors.lightGray,
        child: const CircularProgressIndicator(color: AppColors.primary),
      );
}
