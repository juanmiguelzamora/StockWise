import 'package:flutter/material.dart';
import 'package:mobile/domain/ai_assistant/entity/ai_response.dart';
import 'package:mobile/domain/ai_assistant/repository/ai_repository.dart';

class AiProvider with ChangeNotifier {
  final AiRepository repository;

  AiProvider(this.repository);

  AiResponse? response;
  bool isLoading = false;
  String? error;

  Future<void> askInventory(String query) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      response = await repository.askInventory(query);
    } catch (e) {
      error = e.toString();
    }
    isLoading = false;
    notifyListeners();
  }
}