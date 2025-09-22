class Inventory {
  final int stockIn;
  final int stockOut;
  final int totalStock;
  final double averageDailySales;
  final String stockStatus; // add this to match backend

  Inventory({
    required this.stockIn,
    required this.stockOut,
    required this.totalStock,
    required this.averageDailySales,
    required this.stockStatus,
  });

  // Optional derived getter if you want a user-friendly label
  String get stockLabel {
    switch (stockStatus) {
      case "out_of_stock":
        return "Out of Stock";
      case "low_stock":
        return "Low Stock";
      case "in_stock":
        return "In Stock";
      default:
        return "Unknown";
    }
  }
}
