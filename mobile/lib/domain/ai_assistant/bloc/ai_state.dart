import 'package:equatable/equatable.dart';
import 'package:mobile/domain/ai_assistant/entity/ai_response.dart';
import 'package:mobile/domain/ai_assistant/entity/chat_message.dart';  // NEW: Import

abstract class AiState extends Equatable {
  final List<ChatMessage> history;  // NEW: Shared history across states

  const AiState({this.history = const []});

  @override
  List<Object?> get props => [history];
}

class AiIdle extends AiState {
  const AiIdle();
}

class AiLoading extends AiState {
  const AiLoading({super.history});  // Inherit history
}

class AiError extends AiState {
  final String message;

  const AiError(this.message, {super.history});

  @override
  List<Object?> get props => [message, ...super.props];
}

class AiResponseLoaded extends AiState {
  final AiResponse response;

  const AiResponseLoaded(this.response, {super.history});

  @override
  List<Object?> get props => [response, ...super.props];
}