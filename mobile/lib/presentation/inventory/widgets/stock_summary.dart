import 'package:flutter/material.dart';
import 'package:mobile/presentation/inventory/provider/inventory_provider.dart';
import 'package:provider/provider.dart';

class StockSummary extends StatelessWidget {
  const StockSummary({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InventoryProvider>();
    final screenWidth = MediaQuery.of(context).size.width;

    // 🔹 Adjust sizes for small phones, tablets, and large screens
    final isSmall = screenWidth < 360;
    final isTablet = screenWidth > 600;

    final double fontSizeCount = isTablet
        ? 28
        : isSmall
            ? 18
            : 22;
    final double fontSizeLabel = isTablet
        ? 14
        : isSmall
            ? 10
            : 12;
    final double padding = isTablet
        ? 20
        : isSmall
            ? 8
            : 12;
    final double spacing = isTablet
        ? 24
        : isSmall
            ? 8
            : 12;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: _buildSummaryItem(
            count: provider.inStockCount,
            label: "In Stock",
            color: Colors.black,
            fontSizeCount: fontSizeCount,
            fontSizeLabel: fontSizeLabel,
            padding: padding,
          ),
        ),
        SizedBox(width: spacing),
        Expanded(
          child: _buildSummaryItem(
            count: provider.outOfStockCount,
            label: "Out of Stock",
            color: Colors.red.shade700,
            fontSizeCount: fontSizeCount,
            fontSizeLabel: fontSizeLabel,
            padding: padding,
          ),
        ),
        SizedBox(width: spacing),
        Expanded(
          child: _buildSummaryItem(
            count: provider.lowStockCount,
            label: "Low Stock",
            color: Colors.yellow.shade700,
            fontSizeCount: fontSizeCount,
            fontSizeLabel: fontSizeLabel,
            padding: padding,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryItem({
    required int count,
    required String label,
    required Color color,
    required double fontSizeCount,
    required double fontSizeLabel,
    required double padding,
  }) {
    return AspectRatio(
      aspectRatio: 1, // 🔹 Keeps it a square shape
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.all(padding),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "$count",
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: fontSizeCount,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: fontSizeLabel,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
