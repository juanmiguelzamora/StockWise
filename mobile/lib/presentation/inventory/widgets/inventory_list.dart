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
    Future.microtask(() {
      if (mounted) {
        context.read<InventoryProvider>().fetchInventory();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InventoryProvider>();

    // --- Loading State ---
    if (provider.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: CircularProgressIndicator(),
        ),
      );
    }

    // --- Error but has cache ---
    if (provider.hasError && provider.items.isNotEmpty) {
      return _buildContainer(
        child: Column(
          children: [
            _buildHeaderRow(
              title: "Recent Activity (Offline)",
              icon: Icons.cloud_off_rounded,
              color: Colors.orangeAccent,
            ),
            _buildInventoryList(provider.items),
          ],
        ),
      );
    }

    // --- No data at all ---
    if (provider.items.isEmpty) {
      return _buildContainer(
        child: _buildEmptyState(),
      );
    }

    // --- Normal State ---
    return _buildContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInventoryList(provider.items),
        ],
      ),
    );
  }

  /// Common container for all states
  Widget _buildContainer({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }

  /// Header title for sections
  Widget _buildHeaderRow({
    required String title,
    required IconData icon,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 6),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  /// Empty state placeholder (e.g. backend offline, no cache)
  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Icon(Icons.inventory_2_outlined,
              size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 8),
          const Text(
            "No inventory data available",
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(height: 4),
          Text(
            "Connect to the internet and refresh to fetch data.",
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () =>
                context.read<InventoryProvider>().fetchInventory(),
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text("Retry"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the inventory list
  Widget _buildInventoryList(List items) {
    final limitedItems = items.take(3).toList();
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: limitedItems.length,
      itemBuilder: (context, index) {
        final item = limitedItems[index];
        return _buildInventoryCard(item);
      },
    );
  }

  /// Inventory item card
  Widget _buildInventoryCard(item) {
    final delta = item.stockIn - item.stockOut;
    final isPositive = delta > 0;
    final changeText = isPositive ? '+${delta.abs()}' : '-${delta.abs()}';
    final changeColor = isPositive ? Colors.green : Colors.red;

    final icon = item.product?.name?.toLowerCase().contains('headphones') == true
        ? Icons.headset
        : Icons.shopping_bag_outlined;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Icon(icon, color: Colors.blueAccent, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product?.name ?? 'Unknown Item',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Stock: ${item.totalStock}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            changeText,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: changeColor,
            ),
          ),
        ],
      ),
    );
  }
}
