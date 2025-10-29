class AiResponse {
  final String? queryType; 
  final String? item; 
  final int? currentStock; 
  final int? totalProducts;
  final double? averageDailySales;
  final bool? restockNeeded;
  final String? recommendation;
  final int? lowStockItems; 
  final int? outOfStockItems; 
  final String? summary; 
  final List<TopCategory>? topCategories; 
  // For trend predictions
  final List<PredictedTrend>? predictedTrends;
  final List<String>? restockSuggestions;
  final String? overallPrediction;

  AiResponse({
    this.queryType,
    this.item,
    this.currentStock,
    this.totalProducts,
    this.averageDailySales,
    this.restockNeeded,
    this.recommendation,
    this.lowStockItems,
    this.outOfStockItems,
    this.summary,
    this.topCategories,
    this.predictedTrends,
    this.restockSuggestions,
    this.overallPrediction,
  });

  bool get isTrendResponse => predictedTrends != null && predictedTrends!.isNotEmpty;
  bool get isGeneralInventory => queryType == 'general_inventory';

  // Optional: Factory for backward compatibility
  factory AiResponse.inventory({
    required String item,
    required int currentStock,
    required double averageDailySales,
    required bool restockNeeded,
    required String recommendation,
  }) {
    return AiResponse(
      item: item,
      currentStock: currentStock,
      averageDailySales: averageDailySales,
      restockNeeded: restockNeeded,
      recommendation: recommendation,
    );
  }
}

class PredictedTrend {
  final String keyword;
  final double hotScore;
  final String suggestion;

  PredictedTrend({
    required this.keyword,
    required this.hotScore,
    required this.suggestion,
  });
}

class TopCategory {
  final String category;
  final int stock;

  TopCategory({
    required this.category,
    required this.stock,
  });
}