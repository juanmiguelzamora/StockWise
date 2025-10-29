import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/core/configs/assets/app_vectors.dart';
import 'package:mobile/core/configs/theme/app_colors.dart';
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
  late TextEditingController _searchController;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<ProductProvider>(context, listen: false);
    _searchController = TextEditingController(text: provider.searchQuery);

    // Debounce search input for smoother UX
    _searchController.addListener(() {
      if (_debounce?.isActive ?? false) _debounce!.cancel();
      _debounce = Timer(const Duration(milliseconds: 300), () {
        provider.setSearchQuery(_searchController.text);
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      provider.loadProducts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF6FBFF),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, provider),
            Expanded(child: _buildProductSection(provider)),
          ],
        ),
      ),
    );
  }

  // --- Header (Logo + Search + Filters) ---
  Widget _buildHeader(BuildContext context, ProductProvider provider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: SvgPicture.asset(AppVectors.stockcube, height: 36)),
          const SizedBox(height: 16),
          _buildSearchBar(),
          const SizedBox(height: 12),
          _buildFilterRow(provider),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        cursorColor: const Color(0xFF5283FF),
        style: const TextStyle(color: Colors.black87, fontSize: 16),
        decoration: const InputDecoration(
          hintText: "Search products...",
          hintStyle: TextStyle(color: Colors.grey),
          prefixIcon: Icon(Icons.search, color: Colors.grey),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        ),
      ),
    );
  }

  Widget _buildFilterRow(ProductProvider provider) {
    return Row(
      children: [
        Expanded(
          child: _buildDropdown<String>(
            label: "Category",
            labelStyle: TextStyle(color: AppColors.textPrimary),
            value: provider.categoryFilter ?? "All",
            items: [
              "All",
              ...provider.products.map((p) => p.category).toSet(),
            ],
            onChanged: (val) =>
                provider.setCategoryFilter(val == "All" ? null : val),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildDropdown<StockStatus?>(
            label: "Status",
            labelStyle: TextStyle(color: AppColors.textPrimary),
            value: provider.statusFilter,
            items: [null, ...StockStatus.values],
            onChanged: provider.setStatusFilter,
          ),
        ),
      ],
    );
  }

  // --- Product Section ---
  Widget _buildProductSection(ProductProvider provider) {
    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5283FF)),
        ),
      );
    }

    if (provider.error != null) {
      return _buildErrorState(provider.error!);
    }

    if (provider.filteredProducts.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      color: const Color(0xFF5283FF),
      onRefresh: () => provider.loadProducts(),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: ListView.builder(
          key: ValueKey(provider.filteredProducts.length),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: provider.filteredProducts.length,
          itemBuilder: (context, idx) {
            final product = provider.filteredProducts[idx];
            return ProductCard(
              product: product,
              onIncrement: () => provider.onQuantityIncrement(product.sku),
              onDecrement: () => provider.onQuantityDecrement(product.sku),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              AppVectors.stockcube,
              height: 80,
              colorFilter: ColorFilter.mode(Colors.grey.shade400, BlendMode.srcIn),
            ),
            const SizedBox(height: 16),
            Text(
              "No products found",
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Try adjusting your filters or search query.",
              style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 60),
            const SizedBox(height: 12),
            Text(
              "Something went wrong",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: const TextStyle(color: Colors.black54, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text("Retry"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5283FF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => Provider.of<ProductProvider>(
                context,
                listen: false,
              ).loadProducts(),
            ),
          ],
        ),
      ),
    );
  }

  // --- Custom Dropdown Builder ---
  Widget _buildDropdown<T>({
    required String label,
    TextStyle? labelStyle,
    required T? value,
    required List<T> items,
    required void Function(T?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- Label ---
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            label,
            style:
                labelStyle ??
                const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
          ),
        ),

        // --- Dropdown Container ---
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(13),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
            border: Border.all(color: Colors.grey.withAlpha(51), width: 1),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              isExpanded: true,
              value: value,
              icon: const Icon(Icons.keyboard_arrow_down_rounded),
              dropdownColor: Colors.white,
              style: const TextStyle(color: Colors.black87, fontSize: 14),
              items: items.map((item) {
                String text;
                if (item == null) {
                  text = "All";
                } else if (item is Enum) {
                  text = item.name;
                } else {
                  text = item.toString();
                }
                return DropdownMenuItem<T>(value: item, child: Text(text));
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
