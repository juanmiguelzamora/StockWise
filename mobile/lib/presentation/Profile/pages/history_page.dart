import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../widgets/history_item.dart';
import 'package:mobile/core/configs/assets/app_vectors.dart'; // optional: if you have AppVectors

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    // sample data (replace with real data / provider / bloc later)
    final history = <Map<String, dynamic>>[
      {
        "name": "Wireless Headphones",
        "stock": 454,
        "change": 100,
        "svg": AppVectors.headphones // e.g. "assets/vectors/headphones.svg"
      },
      {
        "name": "Wireless Headphones",
        "stock": 404,
        "change": -50,
        "svg": AppVectors.headphones
      },
      {
        "name": "Gaming Mouse",
        "stock": 50,
        "change": 100,
        "svg": AppVectors.mouse
      },
      {
        "name": "Gaming Mouse",
        "stock": 45,
        "change": -50,
        "svg": AppVectors.mouse
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "History",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // TODO: implement clear action (call usecase / bloc)
            },
            child: const Text("Clear", style: TextStyle(color: Colors.black54)),
          )
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        itemCount: history.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final item = history[index];
          return HistoryItem(
            svgAsset: item['svg'] as String,
            title: item['name'] as String,
            stock: item['stock'].toString(),
            change: (item['change'] as int),
          );
        },
      ),
    );
  }
}
