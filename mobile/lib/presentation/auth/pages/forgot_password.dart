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
    return Scaffold(
      backgroundColor: Colors.white, // <-- Set background to white
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
                // ✅ SVG illustration
                SvgPicture.asset(
                  AppVectors.forgot,
                  height: 180,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 30),

                // ✅ Title
                const Text(
                  "Forget your Password?",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),

                // ✅ Subtitle
                const Text(
                  "Provide your account’s email for which you want to reset password!",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),

                // ✅ Email input
                TextField(
                controller: _emailCon,
                decoration: InputDecoration(
                hintText: "johndoe@gmail.com",
                filled: true,
                fillColor: Colors.transparent,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 15,
                                vertical: 14,
                            ),
                          ),
                        ),
                const SizedBox(height: 25),

                // ✅ Button
                Builder(
                  builder: (context) {
                    return BasicAppButton(
                      title: "Send",
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
                    );
                  },
                ),
                const SizedBox(height: 25),

                // ✅ Footer
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don’t have an account? "),
                    GestureDetector(
                      onTap: () {
                        // Navigate to register page
                      },
                      child: const Text(
                        "Register",
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
