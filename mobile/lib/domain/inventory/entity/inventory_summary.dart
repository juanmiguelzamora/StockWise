class InventorySummary {
  final DateTime date;
  final int totalStock;
  final int stockIn;
  final int stockOut;

  InventorySummary({
    required this.date,
    required this.totalStock,
    required this.stockIn,
    required this.stockOut,
  });
}
