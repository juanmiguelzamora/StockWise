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
import 'package:mobile/service_locator.dart' as di;

class AiPage extends StatefulWidget {
  const AiPage({super.key});

  @override
  State<AiPage> createState() => _AiPageState();
}

class _AiPageState extends State<AiPage> with TickerProviderStateMixin {
  final controller = TextEditingController();
  final scrollController = ScrollController();
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  final quickActions = [  // IMPROVED: Added inventory quick action
    {'title': 'Check Stock', 'query': 'Current stock for gray pants'},
    {'title': 'Seasonal Trends', 'query': 'Predict Christmas trends for clothing'},
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    scrollController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _sendMessage(BuildContext blocContext, String query) {
    if (query.trim().isEmpty) return;
    blocContext.read<AiCubit>().sendQuery(query);  // IMPROVED: Removed addUserMessage; assume cubit handles
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
            appBar: AppBar(
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SvgPicture.asset(AppVectors.stockcube)
              ),
              backgroundColor: AppColors.surface,
              elevation: 0,
            ),
            body: Column(
              children: [
                // IMPROVED: Conditional Welcome (hide after first response)
                BlocBuilder<AiCubit, AiState>(
                  builder: (context, state) {
                    // FIXED: Use AiIdle instead of AiInitial
                    final showWelcome = state is AiIdle || state is AiError || (state.history.isEmpty && state is! AiLoading);
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: showWelcome
                          ? FadeTransition(
                              opacity: _fadeAnimation,
                              child: WelcomeSection(
                                key: const ValueKey('welcome'),
                                quickActions: quickActions,
                                onQuickAction: (query) => _sendMessage(blocContext, query),
                              ),
                            )
                          : const SizedBox.shrink(key: ValueKey('hidden')),
                    );
                  },
                ),
                // Chat Area
                BlocBuilder<AiCubit, AiState>(
                  builder: (context, state) {
                    final cubit = context.read<AiCubit>();
                    final lastUserQuery = cubit.getLastUserQuery();  // NEW: Use cubit method
                    return Expanded(
                      child: ChatArea(
                        scrollController: scrollController,
                        state: state,
                        lastUserQuery: lastUserQuery,  // Now reliable
                      ),
                    );
                  },
                ),
                // Input Section (unchanged conditional)
                // Input Section (FIXED: Show unless loading; dismiss keyboard on send)
                BlocBuilder<AiCubit, AiState>(
                  builder: (context, state) {
                    if (state is AiLoading) {
                      return const SizedBox.shrink();  // Hide only during loading
                    }
                    return InputSection(
                      controller: controller,
                      onSend: (query) {
                        // FIXED: Dismiss keyboard
                        FocusScope.of(context).unfocus();
                        _sendMessage(blocContext, query);
                      },
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}