class AiResponse {
  final String item;
  final int currentStock;
  final double averageDailySales;
  final bool restockNeeded;
  final String recommendation;

  AiResponse({
    required this.item,
    required this.currentStock,
    required this.averageDailySales,
    required this.restockNeeded,
    required this.recommendation,
  });
}