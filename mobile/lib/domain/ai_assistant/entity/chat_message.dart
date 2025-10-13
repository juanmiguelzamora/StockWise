import 'package:equatable/equatable.dart';
import 'package:mobile/domain/ai_assistant/entity/ai_response.dart';

abstract class ChatMessage extends Equatable {
  const ChatMessage();

  @override
  List<Object?> get props => [];
}

class UserMessage extends ChatMessage {
  final String text;

  const UserMessage(this.text);

  @override
  List<Object?> get props => [text];
}

class AiMessage extends ChatMessage {
  final AiResponse response;
  final String? error;  // For error display in bubble if needed

  const AiMessage(this.response, {this.error});

  @override
  List<Object?> get props => [response, error];
}