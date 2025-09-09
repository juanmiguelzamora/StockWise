import 'package:flutter/material.dart';
import 'package:mobile/presentation/inventory/provider/inventory_provider.dart';
import 'package:provider/provider.dart';

class StockOverview extends StatelessWidget {
  const StockOverview({super.key});

  @override
  Widget build(BuildContext context) {
    final summary = context.watch<InventoryProvider>().summary;

    if (summary == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Today: ${summary.date.toLocal().toString().split(' ')[0]}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildItem("Total Stock", summary.totalStock, Colors.blue),
                _buildItem("Stock In", summary.stockIn, Colors.green),
                _buildItem("Stock Out", summary.stockOut, Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          "$value",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
