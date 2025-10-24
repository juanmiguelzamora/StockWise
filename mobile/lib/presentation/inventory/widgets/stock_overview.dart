import 'package:flutter/material.dart';
import 'package:mobile/presentation/inventory/provider/inventory_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class StockOverview extends StatelessWidget {
  const StockOverview({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InventoryProvider>();
    final summary = provider.summary;
    final hasError = provider.hasError;
    final isLoading = provider.isLoading;

    final dateFormat = DateFormat('MMM dd, yyyy');
    final today = dateFormat.format(DateTime.now());

    // Safe fallback values
    final totalStock = summary?.totalStock ?? 0;
    final stockIn = summary?.stockIn ?? 0;
    final stockOut = summary?.stockOut ?? 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Header Date & Status ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  "Today $today",
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              if (isLoading)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              else if (hasError || summary == null)
                const Icon(
                  Icons.wifi_off_rounded,
                  color: Colors.white70,
                  size: 20,
                ),
            ],
          ),

          const SizedBox(height: 16),

          // --- Stock Values ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStockItem(totalStock, "Total"),
              _buildStockItem(stockIn, "Stock In"),
              _buildStockItem(stockOut, "Stock Out"),
            ],
          ),

          // --- Offline Info (if backend unavailable) ---
          if (hasError || summary == null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                "Offline mode: showing last known values or defaults.",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Small reusable UI builder for a stock metric
  Widget _buildStockItem(num value, String label) {
    final formattedValue = _formatLargeNumber(value);

    return Expanded(
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              formattedValue,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Helper to shorten large numbers (e.g. 12500 -> 12.5K)
  String _formatLargeNumber(num value) {
    if (value >= 1000000) {
      return "${(value / 1000000).toStringAsFixed(1)}M";
    } else if (value >= 1000) {
      return "${(value / 1000).toStringAsFixed(1)}K";
    } else {
      return value.toString();
    }
  }
}
