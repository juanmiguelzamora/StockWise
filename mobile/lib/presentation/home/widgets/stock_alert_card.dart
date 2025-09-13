import 'package:flutter/material.dart';

class StockAlertCard extends StatelessWidget {
  final Color color;
  final String title;
  final String value;
  final double fontLarge;
  final double fontSmall;
  final bool isLongTitle;

  const StockAlertCard({
    super.key,
    required this.color,
    required this.title,
    required this.value,
    required this.fontLarge,
    required this.fontSmall,
    this.isLongTitle = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: Colors.white70,
                  fontSize: isLongTitle ? fontSmall * 0.9 : fontSmall,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: fontLarge,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
