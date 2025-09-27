import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/common/bloc/button/button_state.dart';
import 'package:mobile/common/bloc/button/button_state_cubit.dart';
import 'package:mobile/common/helper/navigator/app_navigator.dart';
import 'package:mobile/common/widgets/button/basic_reactive_button.dart';
import 'package:mobile/core/configs/assets/app_vectors.dart';
import 'package:mobile/data/auth/models/user_creation_req.dart';
import 'package:mobile/domain/auth/usecases/signup.dart';
import 'package:mobile/presentation/auth/pages/signin.dart';
import 'package:mobile/service_locator.dart';

class SignupPage extends StatelessWidget {
  SignupPage({super.key});

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final ValueNotifier<bool> _obscurePassword = ValueNotifier(true);
  final ValueNotifier<bool> _obscureConfirm = ValueNotifier(true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: MultiBlocProvider(
        providers: [
          BlocProvider<ButtonStateCubit>(
            create: (_) => ButtonStateCubit(),
          ),
        ],
        child: BlocListener<ButtonStateCubit, ButtonState>(
          listener: (context, state) {
            if (state is ButtonFailureState) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errorMessage)),
              );
            }
            if (state is ButtonSuccessState) {
              AppNavigator.pushReplacement(context, SigninPage());
            }
          },
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),

                  /// --- SVG Illustration ---
                  SvgPicture.asset(
                    AppVectors.signup,
                    height: 150,
                    fit: BoxFit.contain,
                    placeholderBuilder: (context) => const CircularProgressIndicator(),
                  ),
                  const SizedBox(height: 24),

                  /// --- Title ---
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Welcome!",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Create a new account.",
                      style: TextStyle(color: Colors.black54, fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildTextField(
                    controller: _firstNameController,
                    hint: "First Name",
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    controller: _lastNameController,
                    hint: "Last Name",
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    controller: _emailController,
                    hint: "johndoe@gmail.com",
                  ),
                  const SizedBox(height: 16),

                  _buildPasswordField(
                    controller: _passwordController,
                    hint: "Password",
                    obscure: _obscurePassword,
                  ),
                  const SizedBox(height: 16),

                  _buildPasswordField(
                    controller: _confirmPasswordController,
                    hint: "Confirm Password",
                    obscure: _obscureConfirm,
                  ),
                  const SizedBox(height: 24),

                  /// --- Signup Button ---
                  Builder(
                    builder: (buttonContext) {
                      return SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: BasicReactiveButton(
                          onPressed: () {
                            _onSignupPressed(buttonContext, context);
                          },
                          title: "Sign up",
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  /// --- Login Redirect ---
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(color: Colors.black54),
                      children: [
                        const TextSpan(text: "Already have an account? "),
                        TextSpan(
                          text: "Login",
                          style: const TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => AppNavigator.pushReplacement(
                                  context,
                                  SigninPage(),
                                ),
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
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.transparent,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.blue),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required ValueNotifier<bool> obscure,
  }) {
    return ValueListenableBuilder(
      valueListenable: obscure,
      builder: (_, isObscure, __) {
        return TextField(
          controller: controller,
          obscureText: isObscure,
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.transparent,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.blue),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            suffixIcon: IconButton(
              icon: Icon(
                  isObscure ? Icons.visibility_off : Icons.visibility),
              onPressed: () => obscure.value = !isObscure,
            ),
          ),
        );
      },
    );
  }

  void _onSignupPressed(BuildContext buttonContext, BuildContext context) {
    if (_firstNameController.text.trim().isEmpty) {
      _showError(context, "First name is required");
      return;
    }
    if (_lastNameController.text.trim().isEmpty) {
      _showError(context, "Last name is required");
      return;
    }
    if (_emailController.text.trim().isEmpty) {
      _showError(context, "Email is required");
      return;
    }
    if (_passwordController.text.isEmpty) {
      _showError(context, "Password is required");
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      _showError(context, "Passwords do not match");
      return;
    }

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

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
