import 'package:flutter/material.dart';
import 'package:mobile/presentation/inventory/provider/inventory_provider.dart';
import 'package:provider/provider.dart';

class InventoryList extends StatefulWidget {
  const InventoryList({super.key});

  @override
  State<InventoryList> createState() => _InventoryListState();
}

class _InventoryListState extends State<InventoryList> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        context.read<InventoryProvider>().fetchInventory());
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InventoryProvider>();

    if (provider.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final items = provider.items;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: items.isEmpty
          ? _buildPlaceholderList()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _buildInventoryCard(item);
                  },
                ),
              ],
            ),
    );
  }

  /// Placeholder list of cards
  Widget _buildPlaceholderList() {
    return Column(
      children: List.generate(3, (index) {
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            title: Container(
              height: 16,
              width: 120,
              color: Colors.grey.shade300,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                Container(height: 12, width: 180, color: Colors.grey.shade300),
                const SizedBox(height: 4),
                Container(height: 12, width: 100, color: Colors.grey.shade300),
              ],
            ),
            trailing: Container(
              height: 24,
              width: 70,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        );
      }),
    );
  }

  /// Card for each inventory item
  Widget _buildInventoryCard(item) {
  final statusLabel = _mapStockStatus(item.stockStatus);
  final statusColor = _mapStockColor(item.stockStatus);

  return Card(
    margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 2,
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      title: Text(item.product?.name ?? 'Unknown',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("In: ${item.stockIn}, Out: ${item.stockOut}"),
          Text("Total: ${item.totalStock}"),
          Text("Avg Daily Sales: ${item.averageDailySales.toStringAsFixed(1)}"),
        ],
      ),
      trailing: Chip(
        label: Text(statusLabel),
        backgroundColor: statusColor.withOpacity(0.2),
        labelStyle: TextStyle(
          fontWeight: FontWeight.bold,
          color: statusColor,
        ),
      ),
    ),
  );
}

  String _mapStockStatus(String status) {
    switch (status) {
      case "out_of_stock":
        return "Out of Stock";
      case "low_stock":
        return "Low Stock";
      case "in_stock":
        return "In Stock";
      default:
        return "Unknown";
    }
  }

  Color _mapStockColor(String status) {
    switch (status) {
      case "out_of_stock":
        return Colors.red;
      case "low_stock":
        return Colors.orange;
      case "in_stock":
        return Colors.green;
      default:
        return Colors.blue;
    }
  }
}
