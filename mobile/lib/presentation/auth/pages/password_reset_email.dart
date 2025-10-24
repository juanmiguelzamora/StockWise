import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/common/helper/navigator/app_navigator.dart';
import 'package:mobile/common/widgets/button/basic_app_button.dart';
import 'package:mobile/core/configs/assets/app_vectors.dart';
import 'package:mobile/presentation/auth/pages/signin.dart';

class PasswordResetEmailPage extends StatelessWidget {
  const PasswordResetEmailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // --- Illustration ---
              SvgPicture.asset(
                AppVectors.emailSending,
                height: 180,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 40),

              // --- Title ---
              Text(
                "Check your email!",
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // --- Subtitle ---
              Text(
                "We’ve sent you a password reset link.\nPlease check your inbox and follow the instructions.",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.black54,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // --- Return to Login Button ---
              BasicAppButton(
                title: "Return to Login",
                width: 220,
                onPressed: () {
                  AppNavigator.pushReplacement(context, SigninPage());
                },
              ),
              const SizedBox(height: 20),

              // --- Secondary Info ---
              TextButton(
                onPressed: () {
                  // Could open email app or resend link
                },
                child: const Text(
                  "Didn’t receive the email? Resend",
                  style: TextStyle(
                    color: Color(0xFF5283FF),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
