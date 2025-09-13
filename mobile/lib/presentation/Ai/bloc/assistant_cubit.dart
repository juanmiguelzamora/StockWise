import 'package:flutter_bloc/flutter_bloc.dart';

class AssistantState {
  final List<String> messages;
  final bool isLoading;

  AssistantState({this.messages = const [], this.isLoading = false});

  AssistantState copyWith({
    List<String>? messages,
    bool? isLoading,
  }) {
    return AssistantState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AssistantCubit extends Cubit<AssistantState> {
  AssistantCubit() : super(AssistantState());

  void sendMessage(String message) {
    if (message.isEmpty) return;

    final updated = List<String>.from(state.messages)..add("You: $message");
    emit(state.copyWith(messages: updated, isLoading: true));

    // Simulate AI reply
    Future.delayed(const Duration(seconds: 1), () {
      final reply = "AI: Response to '$message'";
      final newList = List<String>.from(updated)..add(reply);
      emit(state.copyWith(messages: newList, isLoading: false));
    });
  }

  void clearMessages() {
    emit(AssistantState(messages: []));
  }
}
