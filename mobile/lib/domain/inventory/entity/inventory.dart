class Inventory {
  final String item;
  final int stockIn;
  final int stockOut;
  final int totalStock;
  final double averageDailySales;

  Inventory({
    required this.item,
    required this.stockIn,
    required this.stockOut,
    required this.totalStock,
    required this.averageDailySales,
  });

  // Derived getter for stock status
  String get stockStatus {
    if (totalStock == 0) return "Out of Stock";
    if (totalStock < 30) return "Low Stock";
    if (totalStock >= 70) return "Overstock";
    return "Normal";
  }
}
