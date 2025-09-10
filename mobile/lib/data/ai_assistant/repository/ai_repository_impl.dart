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
      item: model.item,
      currentStock: model.currentStock,
      averageDailySales: model.averageDailySales,
      restockNeeded: model.restockNeeded,
      recommendation: model.recommendation,
    );
  }
}