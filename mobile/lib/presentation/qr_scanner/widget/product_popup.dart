import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/presentation/qr_scanner/controllers/qr_scanner_controller.dart';

class ProductPopup extends StatelessWidget {
  final QrScannerState state;
  final VoidCallback onStockIn;
  final VoidCallback onStockOut;
  final VoidCallback onClose;
  final VoidCallback onIncrement;  // New: for local adjustment
  final VoidCallback onDecrement;  // New: for local adjustment

  const ProductPopup({
    super.key,
    required this.state,
    required this.onStockIn,
    required this.onStockOut,
    required this.onClose,
    required this.onIncrement,  // New
    required this.onDecrement,  // New
  });

  @override
  Widget build(BuildContext context) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final String mediaBaseUrl = GetIt.instance.get<String>(instanceName: "mediaBaseUrl");
    final product = state.product;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              product?.name ?? "Product",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if ((product?.imageUrl ?? '').isNotEmpty)
            Builder(builder: (context) {
                final imageUrl = product!.imageUrl.startsWith('http')
                    ? product.imageUrl
                    : '$mediaBaseUrl${product.imageUrl}';
                final uri = Uri.tryParse(imageUrl);
                if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https') && uri.host.isNotEmpty) {
                  return Image.network(
                    imageUrl,
                    height: 100,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 100,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported, size: 50),
                    ),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 100,
                        child: const Center(child: CircularProgressIndicator()),
                      );
                    },
                  );
                }
                return Container(
                  height: 100,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image_not_supported, size: 50),
                );
              }),
            Text("Stock Status: ${product?.inventory?.stockStatus ?? ''}"),
            const SizedBox(height: 8),
            Text("Current Stock: ${state.totalQuantity}"),  // New: show live total separately
            const SizedBox(height: 8),
            Text("Adjustment Amount:"),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: state.adjustment > 0 ? onDecrement : null,  // Calls local decrement
                  icon: const Icon(Icons.remove),
                ),
                Text("${state.adjustment}"),
                IconButton(
                  onPressed: onIncrement,  // Calls local increment
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: (state.adjustment > 0) ? onStockOut : null,  // Disable if adjustment == 0 (optional)
                  child: const Text("Stock Out"),
                ),
                ElevatedButton(
                  onPressed: (state.adjustment > 0) ? onStockIn : null,  // Disable if adjustment == 0 (optional)
                  child: const Text("Stock In"),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: onClose,
              child: const Text("Close"),
            ),
          ],
        ),
      ),
    );
  }
}