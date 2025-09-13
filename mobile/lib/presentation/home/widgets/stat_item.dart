import 'package:flutter/material.dart';

class StatItem extends StatelessWidget {
  final String value;
  final String label;
  final double fontLarge;
  final double fontSmall;

  const StatItem({
    super.key,
    required this.value,
    required this.label,
    required this.fontLarge,
    required this.fontSmall,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(color: Colors.white, fontSize: fontLarge, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label,
            style: TextStyle(color: Colors.white70, fontSize: fontSmall)),
      ],
    );
  }
}
