import 'package:mobile/domain/ai_assistant/entity/ai_response.dart';

abstract class AiRepository {
  Future<AiResponse> askInventory(String query);
}