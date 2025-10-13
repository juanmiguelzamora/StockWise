import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/presentation/trends/provider/trends_provider.dart';

class TrendsPage extends StatelessWidget {
  const TrendsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TrendsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text("Fashion Trends")),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: provider.trends.length,
              itemBuilder: (context, index) {
                final trend = provider.trends[index];
                return ListTile(
                  title: Text(trend.keyword),
                  subtitle: Text(
                    "Season: ${trend.season} | Score: ${trend.score}",
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => provider.runScraperAndFetch(),
        child: const Icon(Icons.refresh),
      ),
    );
  }
}