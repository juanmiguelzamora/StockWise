import 'package:mobile/data/ai_assistant/source/ai_remote_datasource.dart';
import 'package:mobile/domain/ai_assistant/entity/ai_response.dart';
import 'package:mobile/domain/ai_assistant/repository/ai_repository.dart';

class AiRepositoryImpl implements AiRepository {
  final AiRemoteDataSource remoteDataSource;

  AiRepositoryImpl(this.remoteDataSource);

  @override
  Future<AiResponse> askInventory(String query) async {
    final model = await remoteDataSource.askInventory(query);  // Assumes this returns AiResponseModel
    return AiResponse(
      item: model.item ?? '',
      currentStock: model.currentStock ?? 0,
      averageDailySales: model.averageDailySales ?? 0.0,
      restockNeeded: model.restockNeeded ?? false,
      recommendation: model.recommendation ?? '',
      // NEW: Map trend fields (optional)
      predictedTrends: model.predictedTrends?.map((m) => PredictedTrend(
        keyword: m.keyword,
        hotScore: m.hotScore,
        suggestion: m.suggestion,
      )).toList(),
      restockSuggestions: model.restockSuggestions ?? [],
      overallPrediction: model.overallPrediction ?? '',
    );
  }
}