class AiResponse {
  final String? item; // Or category for aggregates
  final int? currentStock; // Or total_stock for categories
  final double? averageDailySales;
  final bool? restockNeeded;
  final String? recommendation;
  // NEW: For trend predictions
  final List<PredictedTrend>? predictedTrends;
  final List<String>? restockSuggestions;
  final String? overallPrediction;

  AiResponse({
    this.item,
    this.currentStock,
    this.averageDailySales,
    this.restockNeeded,
    this.recommendation,
    this.predictedTrends,
    this.restockSuggestions,
    this.overallPrediction,
  });

  bool get isTrendResponse => predictedTrends != null && predictedTrends!.isNotEmpty;

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