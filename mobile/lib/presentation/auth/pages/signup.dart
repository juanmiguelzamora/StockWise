import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/common/bloc/button/button_state.dart';
import 'package:mobile/common/bloc/button/button_state_cubit.dart';
import 'package:mobile/common/helper/navigator/app_navigator.dart';
import 'package:mobile/common/widgets/button/basic_reactive_button.dart';
import 'package:mobile/core/configs/assets/app_vectors.dart';
import 'package:mobile/core/configs/theme/app_colors.dart';
import 'package:mobile/data/auth/models/user_creation_req.dart';
import 'package:mobile/domain/auth/usecases/signup.dart';
import 'package:mobile/presentation/auth/pages/signin.dart';
import 'package:mobile/service_locator.dart';

class SignupPage extends StatelessWidget {
  SignupPage({super.key});

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final ValueNotifier<bool> _obscurePassword = ValueNotifier(true);
  final ValueNotifier<bool> _obscureConfirm = ValueNotifier(true);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: MultiBlocProvider(
        providers: [
          BlocProvider<ButtonStateCubit>(create: (_) => ButtonStateCubit()),
        ],
        child: BlocListener<ButtonStateCubit, ButtonState>(
          listener: (context, state) {
            if (state is ButtonFailureState) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage),
                  backgroundColor: AppColors.error,
                ),
              );
            }
            if (state is ButtonSuccessState) {
              AppNavigator.pushReplacement(context, SigninPage());
            }
          },
          child: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.07,
                vertical: 24,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // --- Logo / Illustration ---
                    Center(
                      child: SvgPicture.asset(
                        AppVectors.signup,
                        height: size.height * 0.25,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // --- Title ---
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Welcome!",
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Create a new account",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // --- Input Fields ---
                    _buildInputField(
                      controller: _firstNameController,
                      hintText: "First Name",
                      icon: Icons.person_outline,
                      validator: (value) =>
                          value!.trim().isEmpty ? "First name is required" : null,
                    ),
                    const SizedBox(height: 16),
                    _buildInputField(
                      controller: _lastNameController,
                      hintText: "Last Name",
                      icon: Icons.person_outline,
                      validator: (value) =>
                          value!.trim().isEmpty ? "Last name is required" : null,
                    ),
                    const SizedBox(height: 16),
                    _buildInputField(
                      controller: _emailController,
                      hintText: "johndoe@gmail.com",
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value!.trim().isEmpty) return "Email is required";
                        final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                        if (!emailRegex.hasMatch(value)) {
                          return "Enter a valid email address";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    ValueListenableBuilder(
                      valueListenable: _obscurePassword,
                      builder: (_, obscure, __) => _buildInputField(
                        controller: _passwordController,
                        hintText: "Password",
                        icon: Icons.lock_outline,
                        obscureText: obscure,
                        suffix: IconButton(
                          icon: Icon(
                            obscure ? Icons.visibility_off : Icons.visibility,
                            color: AppColors.textHint,
                          ),
                          onPressed: () =>
                              _obscurePassword.value = !_obscurePassword.value,
                        ),
                        validator: (value) {
                          if (value!.isEmpty) return "Password is required";
                          if (value.length < 6) {
                            return "Password must be at least 6 characters";
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    ValueListenableBuilder(
                      valueListenable: _obscureConfirm,
                      builder: (_, obscure, __) => _buildInputField(
                        controller: _confirmPasswordController,
                        hintText: "Confirm Password",
                        icon: Icons.lock_outline,
                        obscureText: obscure,
                        suffix: IconButton(
                          icon: Icon(
                            obscure ? Icons.visibility_off : Icons.visibility,
                            color: AppColors.textHint,
                          ),
                          onPressed: () =>
                              _obscureConfirm.value = !_obscureConfirm.value,
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Please confirm your password";
                          }
                          if (value != _passwordController.text) {
                            return "Passwords do not match";
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 28),

                    // --- Signup Button ---
                    Builder(
                      builder: (buttonContext) => SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: BasicReactiveButton(
                          title: "Sign up",
                          onPressed: () {
                            if (_formKey.currentState?.validate() ?? false) {
                              final userReq = UserCreationReq(
                                firstName: _firstNameController.text.trim(),
                                lastName: _lastNameController.text.trim(),
                                email: _emailController.text.trim(),
                                password: _passwordController.text,
                              );

                              buttonContext.read<ButtonStateCubit>().execute(
                                    usecase: sl<SignupUseCase>(),
                                    params: userReq,
                                  );
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // --- Redirect to Login ---
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(color: AppColors.textSecondary),
                        children: [
                          const TextSpan(text: "Already have an account? "),
                          TextSpan(
                            text: "Login",
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => AppNavigator.pushReplacement(
                                  context, SigninPage()),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 🔹 Reusable Input Builder
  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    Widget? suffix,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: AppColors.primary),
        suffixIcon: suffix,
        hintText: hintText,
        hintStyle: const TextStyle(color: AppColors.textHint),
        filled: true,
        fillColor: AppColors.surface,
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.lightGray),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
