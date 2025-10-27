import 'package:mobile/data/ai_assistant/source/ai_remote_datasource.dart';
import 'package:mobile/domain/ai_assistant/entity/ai_response.dart';
import 'package:mobile/domain/ai_assistant/repository/ai_repository.dart';

class AiRepositoryImpl implements AiRepository {
  final AiRemoteDataSource remoteDataSource;

  AiRepositoryImpl(this.remoteDataSource);

  @override
  Future<AiResponse> askInventory(String query) async {
    final model = await remoteDataSource.askInventory(query);
    
    return AiResponse(
      // Query type and general fields
      queryType: model.queryType,
      item: model.item,
      currentStock: model.currentStock,
      
      // General inventory fields
      totalProducts: model.totalProducts,
      lowStockItems: model.lowStockItems,
      outOfStockItems: model.outOfStockItems,
      summary: model.summary,
      topCategories: model.topCategories?.map((m) => TopCategory(
        category: m.category,
        stock: m.stock,
      )).toList(),
      
      // Common fields
      averageDailySales: model.averageDailySales,
      restockNeeded: model.restockNeeded,
      recommendation: model.recommendation,
      
      // Trend fields
      predictedTrends: model.predictedTrends?.map((m) => PredictedTrend(
        keyword: m.keyword,
        hotScore: m.hotScore,
        suggestion: m.suggestion,
      )).toList(),
      restockSuggestions: model.restockSuggestions,
      overallPrediction: model.overallPrediction,
    );
  }
}