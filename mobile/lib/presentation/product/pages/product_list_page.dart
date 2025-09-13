import 'package:flutter/material.dart';
import 'package:mobile/domain/product/entity/product.dart';
import 'package:mobile/presentation/product/provider/product_provider.dart';
import 'package:mobile/presentation/product/widget/product_card.dart';
import 'package:provider/provider.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F7FA),
      appBar: AppBar(
        title: TextField(
          controller: TextEditingController(text: provider.searchQuery),
          onChanged: provider.setSearchQuery,
          decoration: InputDecoration(
            hintText: "Search products...",
            border: InputBorder.none,
            suffixIcon: provider.searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      provider.clearSearch();
                    },
                  )
                : null,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // --- Filters Row ---
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                // Category filter
                DropdownButton<String>(
                  hint: const Text("Category"),
                  value: provider.categoryFilter ?? "All",
                  onChanged: (val) {
                    if (val == "All") {
                      provider.setCategoryFilter(null);
                    } else {
                      provider.setCategoryFilter(val);
                    }
                  },
                  items: [
                    const DropdownMenuItem(
                      value: "All",
                      child: Text("All"),
                    ),
                    ...provider.products
                        .map((p) => p.category)
                        .toSet()
                        .map((cat) => DropdownMenuItem(
                              value: cat,
                              child: Text(cat),
                            ))
                        .toList(),
                  ],
                ),
                const SizedBox(width: 16),
                // Stock Status filter
                DropdownButton<StockStatus?>(
                  hint: const Text("Stock Status"),
                  value: provider.statusFilter,
                  onChanged: (val) => provider.setStatusFilter(val),
                  items: [
                    const DropdownMenuItem<StockStatus?>(
                      value: null,
                      child: Text("All"),
                    ),
                    ...StockStatus.values.map(
                      (s) => DropdownMenuItem(
                        value: s,
                        child: Text(s.name),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // --- Product List ---
          Expanded(
            child: provider.isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFF5283FF)),
                    ),
                  )
                : provider.error != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'Error: ${provider.error}',
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        color: const Color(0xFF5283FF),
                        backgroundColor: Colors.white,
                        onRefresh: () => provider.loadProducts(),
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16.0),
                          itemCount: provider.filteredProducts.length,
                          itemBuilder: (context, idx) {
                            final p = provider.filteredProducts[idx];
                            return ProductCard(
                              product: p,
                              onIncrement: () =>
                                  provider.onQuantityIncrement(p.sku),
                              onDecrement: () =>
                                  provider.onQuantityDecrement(p.sku),
                            );
                          },
                          separatorBuilder: (context, idx) =>
                              const SizedBox(height: 12),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
