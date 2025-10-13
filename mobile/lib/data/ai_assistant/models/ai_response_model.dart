class AiResponseModel {
  final String? item;  // Or category for aggregates
  final int? currentStock;  // Or total_stock for categories
  final double? averageDailySales;
  final bool? restockNeeded;
  final String? recommendation;

  // NEW: For trend predictions
  final List<PredictedTrendModel>? predictedTrends;
  final List<String>? restockSuggestions;
  final String? overallPrediction;

  AiResponseModel({
    this.item,
    this.currentStock,
    this.averageDailySales,
    this.restockNeeded,
    this.recommendation,
    this.predictedTrends,
    this.restockSuggestions,
    this.overallPrediction,
  });

  factory AiResponseModel.fromJson(Map<String, dynamic> json) {
    return AiResponseModel(
      item: json['item'] ?? json['category'],  // Handle both item and category
      currentStock: json['current_stock'] ?? json['total_stock'],
      averageDailySales: (json['average_daily_sales'] as num?)?.toDouble(),
      restockNeeded: json['restock_needed'],
      recommendation: json['recommendation'],
      // NEW: Parse trends if present
      predictedTrends: (json['predicted_trends'] as List?)?.map((e) => PredictedTrendModel.fromJson(e as Map<String, dynamic>)).toList(),
      restockSuggestions: (json['restock_suggestions'] as List?)?.cast<String>(),
      overallPrediction: json['overall_prediction'],
    );
  }
}

class PredictedTrendModel {
  final String keyword;
  final double hotScore;
  final String suggestion;

  PredictedTrendModel({
    required this.keyword,
    required this.hotScore,
    required this.suggestion,
  });

  factory PredictedTrendModel.fromJson(Map<String, dynamic> json) {
    return PredictedTrendModel(
      keyword: json['keyword'] ?? '',
      hotScore: (json['hot_score'] as num?)?.toDouble() ?? 0.0,
      suggestion: json['suggestion'] ?? '',
    );
  }
}