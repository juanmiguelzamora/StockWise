import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/domain/ai_assistant/bloc/ai_state.dart';
import 'package:mobile/domain/ai_assistant/entity/ai_response.dart';
import 'package:mobile/domain/ai_assistant/entity/chat_message.dart';  // NEW: Import
import 'package:mobile/domain/ai_assistant/repository/ai_repository.dart';

class AiCubit extends Cubit<AiState> {
  final AiRepository repository;

  AiCubit(this.repository) : super(const AiIdle());

  Future<void> sendQuery(String query) async {
  if (query.trim().isEmpty) return;

  //  Use state.history directly (no cast—works for any state)
  final currentHistory = state.history;
  final updatedHistory = [...currentHistory, UserMessage(query)];
  emit(AiLoading(history: updatedHistory));

  try {
    final response = await repository.askInventory(query);
    final newHistory = [...updatedHistory, AiMessage(response)];
    emit(AiResponseLoaded(response, history: newHistory));
  } catch (e) {
    // Consistent error handling—use generic message
    final userError = _mapToUserError(e);  // NEW: Helper for friendly errors (see below)
    final newHistory = [...updatedHistory, AiMessage(
      AiResponse(  // Empty fallback
        item: '',
        currentStock: 0,
        averageDailySales: 0.0,
        restockNeeded: false,
        recommendation: '',
      ),
      error: userError,
    )];
    emit(AiError(userError, history: newHistory));
  }
}

  void clearError() {
    emit(const AiIdle());
  }

  void reset() {
    emit(const AiIdle());
  }

  String _mapToUserError(Object e) {
    if (e is SocketException) return 'No internet connection. Please check your network.';
    if (e.toString().contains('429')) return 'Too many requests. Please wait a moment.';
    return 'Something went wrong. Please try again.';
  }

  
  String getLastUserQuery() {
    final userMessages = state.history.whereType<UserMessage>().toList();  // Use state.history
    return userMessages.isNotEmpty ? userMessages.last.text : '';
  }

  
  void clearHistory() {
    emit(const AiIdle());
  }
}