import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mobile/common/bloc/button/button_state.dart';
import 'package:mobile/common/bloc/button/button_state_cubit.dart';
import 'package:mobile/common/helper/navigator/app_navigator.dart';
import 'package:mobile/common/widgets/button/basic_reactive_button.dart';
import 'package:mobile/core/configs/assets/app_vectors.dart';
import 'package:mobile/core/configs/theme/app_colors.dart';
import 'package:mobile/data/auth/models/user_signin_req.dart';
import 'package:mobile/domain/auth/usecases/signin.dart';
import 'package:mobile/presentation/bottom_nav/pages/bottom_nav_page.dart';
import 'package:mobile/presentation/auth/pages/forgot_password.dart';
import 'package:mobile/presentation/auth/pages/signup.dart';
import 'package:mobile/service_locator.dart';

class SigninPage extends StatelessWidget {
  SigninPage({super.key});

  final TextEditingController _emailCon = TextEditingController();
  final TextEditingController _passwordCon = TextEditingController();
  final ValueNotifier<bool> _obscurePassword = ValueNotifier(true);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 32 : 20,
                vertical: 32,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- Illustration ---
                  SvgPicture.asset(
                    AppVectors.login,
                    height: isTablet ? 200 : 160,
                  ),
                  const SizedBox(height: 32),

                  // --- Title ---
                  const Text(
                    "Welcome Back!",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Sign in to continue to StockWise.",
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // --- Email Field ---
                  TextField(
                    controller: _emailCon,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      hintText: "Enter your email",
                      hintStyle: const TextStyle(color: AppColors.textHint),
                      labelText: "Email",
                      labelStyle: const TextStyle(
                        color: AppColors.textSecondary,
                      ),
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.lightGray),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.primary,
                          width: 1.8,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // --- Password Field ---
                  ValueListenableBuilder(
                    valueListenable: _obscurePassword,
                    builder: (_, obscure, __) {
                      return TextField(
                        controller: _passwordCon,
                        style: const TextStyle(color: Colors.black),
                        obscureText: obscure,
                        decoration: InputDecoration(
                          hintText: "Enter your password",
                          hintStyle: const TextStyle(color: AppColors.textHint),
                          labelText: "Password",
                          labelStyle: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
                          filled: true,
                          fillColor: AppColors.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.lightGray),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppColors.primary,
                              width: 1.8,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscure ? Icons.visibility_off : Icons.visibility,
                              color: AppColors.textHint,
                            ),
                            onPressed: () => _obscurePassword.value = !obscure,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  // --- Remember + Forgot Password ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: false,
                            onChanged: (_) {},
                            activeColor: AppColors.primary,
                          ),
                          const Text(
                            "Remember me",
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () =>
                            AppNavigator.push(context, ForgotPasswordPage()),
                        child: const Text(
                          "Forgot Password?",
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // --- Sign In Button ---
                  BlocProvider<ButtonStateCubit>(
                    create: (_) => ButtonStateCubit(),
                    child: BlocConsumer<ButtonStateCubit, ButtonState>(
                      listener: (context, state) {
                        if (state is ButtonSuccessState) {
                          AppNavigator.pushReplacement(
                            context,
                            BottomNavPage(),
                          );
                        } else if (state is ButtonFailureState) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor:
                                  Colors.black, // <-- sets background to black
                              content: Text(
                                state.errorMessage,
                                style: const TextStyle(
                                  color: Colors.white,
                                ), // make text visible
                              ),
                              behavior: SnackBarBehavior
                                  .floating, // optional: makes it look modern
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ), // optional
                            ),
                          );
                        }
                      },
                      builder: (context, state) {
                        return SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: BasicReactiveButton(
                            title: "Sign In",
                            onPressed: () {
                              final email = _emailCon.text.trim();
                              final password = _passwordCon.text.trim();

                              if (email.isEmpty || password.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Please fill in all fields"),
                                  ),
                                );
                                return;
                              }

                              final userSigninReq = UserSigninReq(
                                email: email,
                                password: password,
                              );
                              context.read<ButtonStateCubit>().execute(
                                usecase: sl<SigninUseCase>(),
                                params: userSigninReq,
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- Create Account ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don’t have an account?",
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () =>
                            AppNavigator.pushReplacement(context, SignupPage()),
                        child: const Text(
                          "Register",
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
