import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mobile/core/configs/assets/app_vectors.dart';
import 'package:mobile/core/configs/theme/app_colors.dart';
import 'package:mobile/domain/ai_assistant/bloc/ai_cubit.dart';
import 'package:mobile/domain/ai_assistant/bloc/ai_state.dart';
import 'package:mobile/domain/ai_assistant/repository/ai_repository.dart';
import 'package:mobile/presentation/ai_assistant/widget/chat_area.dart';
import 'package:mobile/presentation/ai_assistant/widget/input_section.dart';
import 'package:mobile/presentation/ai_assistant/widget/welcome_section.dart';
import 'package:mobile/presentation/ai_assistant/widget/quick_actions_bar.dart';
import 'package:mobile/service_locator.dart' as di;

class AiPage extends StatefulWidget {
  const AiPage({super.key});

  @override
  State<AiPage> createState() => _AiPageState();
}

class _AiPageState extends State<AiPage> with TickerProviderStateMixin {
  final controller = TextEditingController();
  final scrollController = ScrollController();
  final focusNode = FocusNode();
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  final quickActions = [
    {'title': 'Total Inventory', 'query': 'What is the total stock?'},
    {
      'title': 'Seasonal Trends',
      'query': 'Predict Christmas trends for clothing',
    },
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));
    _fadeController.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    scrollController.dispose();
    focusNode.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _sendMessage(BuildContext blocContext, String query) {
    if (query.trim().isEmpty) return;
    blocContext.read<AiCubit>().sendQuery(
      query,
    ); // IMPROVED: Removed addUserMessage; assume cubit handles
    controller.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AiCubit(di.sl<AiRepository>())..reset(),
      child: Builder(
        builder: (blocContext) {
          return Scaffold(
            backgroundColor: AppColors.background,
            resizeToAvoidBottomInset: true,
            appBar: AppBar(
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SvgPicture.asset(AppVectors.stockcube),
              ),
              backgroundColor: AppColors.surface,
              elevation: 0,
            ),
            body: SafeArea(
              child: BlocBuilder<AiCubit, AiState>(
                builder: (blocContext, state) {
                  // Shared logic for conditions
                  final keyboardVisible =
                      MediaQuery.of(blocContext).viewInsets.bottom > 0;
                  final showWelcome =
                      !keyboardVisible &&
                      (state is AiIdle ||
                          state is AiError ||
                          (state.history.isEmpty && state is! AiLoading));
                  final showInput = state is! AiLoading;

                  return Column(
                    children: [
                      // Welcome (conditional)
                      if (showWelcome)
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: const WelcomeSection(key: ValueKey('welcome')),
                        ),
                      // Chat Area (always expanded)
                      BlocBuilder<AiCubit, AiState>(
                        builder: (context, chatState) {
                          final cubit = context.read<AiCubit>();
                          final lastUserQuery = cubit.getLastUserQuery();
                          return Expanded(
                            child: ChatArea(
                              scrollController: scrollController,
                              state: chatState,
                              lastUserQuery: lastUserQuery,
                            ),
                          );
                        },
                      ),
                      // Quick Actions (only when NOT showing welcome)
                      if (!showWelcome)
                        QuickActionsBar(
                          quickActions: quickActions,
                          onQuickAction: (query) =>
                              _sendMessage(blocContext, query),
                        ),
                      // Input (conditional on loading)
                      if (showInput)
                        InputSection(
                          controller: controller,
                          focusNode: focusNode,
                          onSend: (query) {
                            focusNode.unfocus();
                            _sendMessage(blocContext, query);
                          },
                        ),
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
