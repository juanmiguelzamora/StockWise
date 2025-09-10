class AiResponseModel {
  final String item;
  final int currentStock;
  final double averageDailySales;
  final bool restockNeeded;
  final String recommendation;

  AiResponseModel({
    required this.item,
    required this.currentStock,
    required this.averageDailySales,
    required this.restockNeeded,
    required this.recommendation,
  });

  factory AiResponseModel.fromJson(Map<String, dynamic> json) {
    return AiResponseModel(
      item: json['item'] ?? '',
      currentStock: json['current_stock'] ?? 0,
      averageDailySales: (json['average_daily_sales'] ?? 0).toDouble(),
      restockNeeded: json['restock_needed'] ?? false,
      recommendation: json['recommendation'] ?? '',
    );
  }
}