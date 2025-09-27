import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HistoryItem extends StatelessWidget {
  final String svgAsset;
  final String title;
  final String stock;
  final int change;

  const HistoryItem({
    super.key,
    required this.svgAsset,
    required this.title,
    required this.stock,
    required this.change,
  });

  @override
  Widget build(BuildContext context) {
    final bool positive = change >= 0;
    final Color changeColor = positive ? Colors.green : Colors.red;

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        child: Row(
          children: [
            // SVG avatar
            Container(
              width: 48,
              height: 48,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(24),
              ),
              child: SvgPicture.asset(
                svgAsset,
                fit: BoxFit.contain,
                // if any colorization is needed, use color or allowOriginalColors
              ),
            ),

            const SizedBox(width: 12),

            // Title + Stock
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Stock: $stock',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

            // Change amount
            Text(
              (positive ? '+${change.toString()}' : change.toString()),
              style: TextStyle(
                color: changeColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
