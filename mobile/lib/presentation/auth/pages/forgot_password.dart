import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/common/bloc/button/button_state.dart';
import 'package:mobile/common/bloc/button/button_state_cubit.dart';
import 'package:mobile/common/helper/navigator/app_navigator.dart';
import 'package:mobile/common/widgets/appbar/app_bar.dart';
import 'package:mobile/common/widgets/button/basic_app_button.dart';
import 'package:mobile/domain/auth/usecases/send_password_reset_email.dart';
import 'package:mobile/presentation/auth/pages/password_reset_email.dart';
import 'package:mobile/core/configs/assets/app_vectors.dart';

class ForgotPasswordPage extends StatelessWidget {
  ForgotPasswordPage({super.key});

  final TextEditingController _emailCon = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const BasicAppbar(hideBack: false),
      body: BlocProvider(
        create: (_) => ButtonStateCubit(),
        child: BlocListener<ButtonStateCubit, ButtonState>(
          listener: (context, state) {
            if (state is ButtonFailureState) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Colors.redAccent,
                ),
              );
            }

            if (state is ButtonSuccessState) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Password reset email sent!"),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Colors.green,
                ),
              );
              AppNavigator.push(context, const PasswordResetEmailPage());
            }
          },
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // --- Illustration ---
                SvgPicture.asset(
                  AppVectors.forgot,
                  height: 180,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 40),

                // --- Title ---
                Text(
                  "Forgot your password?",
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                // --- Subtitle ---
                Text(
                  "Enter your registered email address below and we’ll send you instructions to reset your password.",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.black54,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // --- Email Input ---
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _emailCon,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.black),
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.email_outlined,
                          color: Colors.grey),
                      hintText: "johndoe@gmail.com",
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: Colors.transparent),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: Color(0xFF5283FF)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // --- Button ---
                Builder(builder: (context) {
                  return BasicAppButton(
                    title: "Send Reset Link",
                    onPressed: () {
                      final email = _emailCon.text.trim();

                      if (email.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Please enter your email."),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        return;
                      }

                      context.read<ButtonStateCubit>().execute(
                            usecase: SendPasswordResetEmailUseCase(),
                            params: email,
                          );
                    },
                  );
                }),
                const SizedBox(height: 25),

                // --- Footer ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don’t have an account? ",
                      style: TextStyle(color: Colors.black54),
                    ),
                    GestureDetector(
                      onTap: () {
                        // TODO: Navigate to Register Page
                      },
                      child: const Text(
                        "Register",
                        style: TextStyle(
                          color: Color(0xFF5283FF),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // --- Back to Login ---
                TextButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios_new, size: 16),
                  label: const Text("Back to Login"),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF5283FF),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
