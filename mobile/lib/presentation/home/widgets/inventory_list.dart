import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/presentation/inventory/inventory_provider.dart';

class InventoryList extends StatelessWidget{
  const InventoryList({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InventoryProvider>();

    if (provider.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.items.isEmpty) {
      return const Center(child: Text("No inventory data available."));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: provider.items.length,
      itemBuilder: (context, index) {
        final item = provider.items[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          child: ListTile(
            title: Text(item.item, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('In: ${item.stockIn}, Out: ${item.stockOut}, Total: ${item.totalStock}'),
          ),
        );
      },
    );
  }
}