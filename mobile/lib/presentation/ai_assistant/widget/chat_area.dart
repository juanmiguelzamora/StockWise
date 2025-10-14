import 'package:flutter/material.dart';
import 'package:mobile/core/configs/theme/app_colors.dart';
import 'package:mobile/domain/ai_assistant/bloc/ai_cubit.dart';
import 'package:mobile/domain/ai_assistant/bloc/ai_state.dart';
import 'package:mobile/domain/ai_assistant/entity/chat_message.dart';
import 'package:mobile/presentation/ai_assistant/widget/ai_response.dart';
import 'package:mobile/presentation/ai_assistant/widget/message_bubble.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatArea extends StatefulWidget {
  final ScrollController scrollController;
  final AiState state;
  final String lastUserQuery;

  const ChatArea({
    super.key,
    required this.scrollController,
    required this.state,
    required this.lastUserQuery,
  });

  @override
  State<ChatArea> createState() => _ChatAreaState();
}

class _ChatAreaState extends State<ChatArea> with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack));
    if (widget.state is AiResponseLoaded) {
      _slideController.forward();
    }
  }

  @override
  void didUpdateWidget(ChatArea oldWidget) {
  super.didUpdateWidget(oldWidget);
    if (widget.state is AiResponseLoaded && oldWidget.state is! AiResponseLoaded) {
      _slideController.reset();  // FIXED: Reset for fresh animation
      _slideController.forward();
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.state is AiLoading) {
      return Shimmer.fromColors(
        baseColor: AppColors.background,
        highlightColor: AppColors.primary.withOpacity(0.2),
        child: ListView.builder(
          controller: widget.scrollController,
          itemCount: 3,
          itemBuilder: (context, index) => Container(
            height: 60,
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      );
    }

    if (widget.state is AiError) {
      final error = widget.state as AiError;
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: AppColors.error,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                error.message,  // Now uses parsed friendly message
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.error,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.read<AiCubit>().clearError(),
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    if (widget.state is AiResponseLoaded) {
      final state = widget.state as AiResponseLoaded;
      return ListView.builder(
        controller: widget.scrollController,
        padding: const EdgeInsets.all(16.0),
        itemCount: state.history.length,
        itemBuilder: (context, index) {
          final message = state.history[index];
          if (message is UserMessage) {
            return Align(
              alignment: Alignment.centerRight,
              child: MessageBubble(
                sender: 'You',
                message: message.text,
                isUser: true,
              ),
            );
          } else if (message is AiMessage) {
            return Align(
              alignment: Alignment.centerLeft,
              child: AiResponseBubble(
                response: message.response,
                isError: message.error != null,  // FIXED: Now passed correctly (widget updated below)
              ),
            );
          }
          return const SizedBox.shrink();
        },
      );
    }

    return const SizedBox(); // Idle/Empty
  }
}