import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mobile/common/bloc/button/button_state.dart';
import 'package:mobile/common/bloc/button/button_state_cubit.dart';
import 'package:mobile/common/helper/navigator/app_navigator.dart';
import 'package:mobile/common/widgets/appbar/app_bar.dart';
import 'package:mobile/common/widgets/button/basic_app_button.dart';
import 'package:mobile/core/configs/assets/app_vectors.dart';
import 'package:mobile/domain/auth/usecases/send_password_reset_email.dart';
import 'package:mobile/presentation/auth/pages/password_reset_email.dart';
import 'package:mobile/presentation/auth/pages/signup.dart';

class ForgotPasswordPage extends StatelessWidget {
  ForgotPasswordPage({super.key});
  final TextEditingController _emailCon = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: const BasicAppbar(hideBack: false),
      body: BlocProvider(
        create: (context) => ButtonStateCubit(),
        child: BlocListener<ButtonStateCubit, ButtonState>(
          listener: (context, state) {
            if (state is ButtonFailureState) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }

            if (state is ButtonSuccessState) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Password reset email sent!"),
                  behavior: SnackBarBehavior.floating,
                ),
              );
              AppNavigator.push(context, const PasswordResetEmailPage());
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // --- Illustration ---
                Center(
                  child: SvgPicture.asset(
                    AppVectors.forgotpass, // use your SVG asset
                    height: 140,
                  ),
                ),
                const SizedBox(height: 30),

                // --- Title ---
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Forget your Password?",
                    style: TextStyle(
                      fontSize: 28, // larger size
                      fontWeight: FontWeight.w900, // heavier bold
                      color: Colors.black, // ensure it's black
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // --- Subtitle ---
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Provide your account’s email for which you want to reset password!",
                    style: TextStyle(color: Colors.black54, fontSize: 14),
                  ),
                ),
                const SizedBox(height: 30),

                // --- Email Field ---
                TextField(
                  controller: _emailCon,
                  decoration: InputDecoration(
                    hintText: "johndoe@gmail.com",
                    filled: true,
                    fillColor:
                        Colors.transparent, // Make background transparent
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // --- Send Button ---
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: Builder(
                    builder: (context) {
                      return BasicAppButton(
                        onPressed: () {
                          final email = _emailCon.text.trim();

                          if (email.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Please enter your email"),
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
                        title: "Send",
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // --- Footer Redirect ---
                RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.black54, fontSize: 14),
                    children: [
                      const TextSpan(text: "Don’t have an account? "),
                      TextSpan(
                        text: "Register",
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () =>
                              AppNavigator.push(context, SignupPage()),
                      ),
                    ],
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
