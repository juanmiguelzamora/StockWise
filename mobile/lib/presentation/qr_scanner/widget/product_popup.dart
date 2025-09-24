import 'package:flutter/material.dart';
import 'package:mobile/domain/product/entity/product.dart';
import 'package:mobile/domain/product/usecases/get_product_by_sku.dart';
import 'package:mobile/domain/product/usecases/update_product_quantity_usecase.dart';

class ProductPopup extends StatefulWidget {
  final String sku;
  final GetProductBySku getProductBySku;
  final UpdateProductQuantityUseCase updateQuantity;

  const ProductPopup({
    super.key,
    required this.sku,
    required this.getProductBySku,
    required this.updateQuantity,
  });

  @override
  State<ProductPopup> createState() => _ProductPopupState();
}

class _ProductPopupState extends State<ProductPopup> {
  Product? product;
  int quantity = 0;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _fetchProduct();
  }

  Future<void> _fetchProduct() async {
    try {
      print("🔍 Fetching product for SKU: ${widget.sku}");
      final fetched = await widget.getProductBySku(widget.sku);
      setState(() {
        product = fetched;
        quantity = fetched.inventory?.totalStock ?? 0;
        loading = false;
      });
      print("✅ Product fetched: ${product?.name}, stock=$quantity");
    } catch (e) {
      print("❌ Error fetching product: $e");
      setState(() => loading = false);
    }
  }

  Future<void> _updateStock(bool isStockIn) async {
    final newQuantity = isStockIn ? quantity + 1 : quantity - 1;
    if (newQuantity < 0) return;

    try {
      print("🔄 Updating stock for ${widget.sku} → $newQuantity");
      final updated = await widget.updateQuantity(widget.sku, newQuantity);
      setState(() {
        product = updated;
        quantity = updated.inventory?.totalStock ?? 0;
      });

      // ✅ Snackbar confirmation
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "✅ Stock updated: now $quantity",
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }

      print("✅ Stock updated: now $quantity");
    } catch (e) {
      print("❌ Error updating stock: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ Failed to update stock"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return AlertDialog(
      title: Text(product?.name ?? "Product"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (product?.imageUrl.isNotEmpty ?? false)
            Image.network(product!.imageUrl, height: 100),
          Text("Stock Status: ${product?.inventory?.stockStatus ?? ''}"),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: quantity > 0
                    ? () => setState(() => quantity--)
                    : null,
                icon: const Icon(Icons.remove),
              ),
              Text("$quantity"),
              IconButton(
                onPressed: () => setState(() => quantity++),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () => _updateStock(false),
          child: const Text("Stock Out"),
        ),
        ElevatedButton(
          onPressed: () => _updateStock(true),
          child: const Text("Stock In"),
        ),
      ],
    );
  }
}
