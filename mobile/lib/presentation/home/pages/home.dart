import 'package:flutter/material.dart';
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
    return ChangeNotifierProvider(
      create: (_) => sl<InventoryProvider>()..fetchInventory(),
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              await context.read<InventoryProvider>().fetchInventory();
            },
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Header(),
                  const SizedBox(height: 8),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: StockOverview(),
                  ),
                  const SizedBox(height: 8),
                  // Stock Summary Section
                  _buildSectionTitle(context, "Stocks"),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: StockSummary(),
                  ),
                  const SizedBox(height: 24),

                  // History Section
                  _buildSectionTitle(context, "History"),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: InventoryList(),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
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