import 'package:flutter/material.dart';
import 'package:mobile/presentation/inventory/provider/inventory_provider.dart';
import 'package:provider/provider.dart';

class StockSummary extends StatelessWidget {
  const StockSummary({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InventoryProvider>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(
          child: _buildSummaryItem(
            context,
            count: provider.outOfStockCount,
            label: "Out of Stock",
            color: Colors.red.shade700,
          
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryItem(
            context,
            count: provider.lowStockCount,
            label: "Low Stock",
            color: Colors.orange.shade700,
            
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryItem(
            context,
            count: provider.overStockCount,
            label: "Overstock",
            color: Colors.green.shade700,
            
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryItem(
      BuildContext context, {
        required int count,
        required String label,
        required Color color,
      }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 8),
          Text(
            "$count",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}