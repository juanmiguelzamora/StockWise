class AiResponseModel {
  final String? queryType;
  final String? item;  // Or category for aggregates
  final int? currentStock;  // Or total_stock for categories
  final int? totalProducts;
  final double? averageDailySales;
  final bool? restockNeeded;
  final String? recommendation;
  final int? lowStockItems;
  final int? outOfStockItems;
  final String? summary;
  final List<TopCategoryModel>? topCategories;

  // For trend predictions
  final List<PredictedTrendModel>? predictedTrends;
  final List<String>? restockSuggestions;
  final String? overallPrediction;

  AiResponseModel({
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

  factory AiResponseModel.fromJson(Map<String, dynamic> json) {
    // Handle case where backend returns a single trend object instead of array
    List<PredictedTrendModel>? trends;
    String? overallPred = json['overall_prediction'];
    
    if (json['predicted_trends'] != null) {
      trends = (json['predicted_trends'] as List).map((e) => PredictedTrendModel.fromJson(e as Map<String, dynamic>)).toList();
    } else if (json['keyword'] != null && json['hot_score'] != null) {
      // Single trend object returned - wrap it in an array
      trends = [
        PredictedTrendModel(
          keyword: json['keyword'] ?? '',
          hotScore: (json['hot_score'] as num?)?.toDouble() ?? 0.0,
          suggestion: json['suggestion'] ?? '',
        )
      ];
      // Generate a default overall prediction if missing
      if (overallPred == null) {
        overallPred = 'Trend analysis based on current data';
      }
    }
    
    return AiResponseModel(
      queryType: json['query_type'],
      item: json['item'] ?? json['category'],  // Handle both item and category
      currentStock: json['current_stock'] ?? json['total_stock'],
      totalProducts: json['total_products'],
      averageDailySales: (json['average_daily_sales'] as num?)?.toDouble(),
      restockNeeded: json['restock_needed'],
      recommendation: json['recommendation'],
      lowStockItems: json['low_stock_items'],
      outOfStockItems: json['out_of_stock_items'],
      summary: json['summary'],
      topCategories: (json['top_categories'] as List?)?.map((e) => TopCategoryModel.fromJson(e as Map<String, dynamic>)).toList(),
      // Use the trends we parsed above
      predictedTrends: trends,
      restockSuggestions: (json['restock_suggestions'] as List?)?.cast<String>(),
      overallPrediction: overallPred,
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

class TopCategoryModel {
  final String category;
  final int stock;

  TopCategoryModel({
    required this.category,
    required this.stock,
  });

  factory TopCategoryModel.fromJson(Map<String, dynamic> json) {
    return TopCategoryModel(
      category: json['category'] ?? 'Uncategorized',
      stock: json['stock'] ?? 0,
    );
  }
}