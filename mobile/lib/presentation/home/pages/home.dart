import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/presentation/Profile/pages/history_page.dart';
import 'package:mobile/presentation/home/widgets/header.dart';
import 'package:mobile/presentation/inventory/widgets/inventory_list.dart';
import 'package:mobile/presentation/inventory/widgets/stock_overview.dart';
import 'package:mobile/presentation/inventory/widgets/stock_summary.dart';
import 'package:mobile/presentation/inventory/provider/inventory_provider.dart';
import 'package:mobile/service_locator.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ Set system overlay style to ensure visible status bar
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // no background behind status bar
      statusBarIconBrightness: Brightness.dark, // dark icons for light background
      statusBarBrightness: Brightness.light, // iOS
    ));

    return ChangeNotifierProvider(
      create: (_) => sl<InventoryProvider>()..fetchInventory(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          bottom: false,
          child: Consumer<InventoryProvider>(
            builder: (context, provider, _) {
              return RefreshIndicator(
                onRefresh: () async => await provider.fetchInventory(),
                color: Colors.blueAccent,
                backgroundColor: Colors.white,
                displacement: 40,
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  slivers: [
                    // 🔹 Header
                    const SliverToBoxAdapter(child: Header()),
                    const SliverToBoxAdapter(child: SizedBox(height: 8)),

                    // 🔹 Stock Overview
                    const SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      sliver: SliverToBoxAdapter(child: StockOverview()),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 16)),

                    // 🔹 Stock Section
                    const SliverToBoxAdapter(
                      child: _SectionTitle(title: "Stocks"),
                    ),
                    const SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      sliver: SliverToBoxAdapter(child: StockSummary()),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 24)),

                    // 🔹 History Section
                    const SliverToBoxAdapter(child: _HistorySectionTitle()),
                    const SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      sliver: SliverToBoxAdapter(child: InventoryList()),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 24)),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// 🔹 Reusable Section Title
class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }
}

/// 🔹 Reusable History Section Title + Button
class _HistorySectionTitle extends StatelessWidget {
  const _HistorySectionTitle();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "History",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChangeNotifierProvider(
                    create: (_) => sl<InventoryProvider>(),
                    child: const InventoryHistoryPage(),
                  ),
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.blueAccent,
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            child: const Text("See all"),
          ),
        ],
      ),
    );
  }
}
