import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/common/bloc/button/button_state.dart';
import 'package:mobile/common/bloc/button/button_state_cubit.dart';
import 'package:mobile/common/helper/navigator/app_navigator.dart';
import 'package:mobile/common/widgets/button/basic_reactive_button.dart';
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
                  // --- Logo and Illustration ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset("assets/logo.png", height: 30), // replace with your logo
                    ],
                  ),
                  const SizedBox(height: 20),
                  Image.asset("assets/signup_illustration.png", height: 120), // replace with your illustration

                  const SizedBox(height: 24),
                  // --- Title ---
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Welcome!",
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
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

                  // --- First Name ---
                  TextField(
                    controller: _firstNameController,
                    decoration: InputDecoration(
                      hintText: "First Name",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // --- Last Name ---
                  TextField(
                    controller: _lastNameController,
                    decoration: InputDecoration(
                      hintText: "Last Name",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // --- Email ---
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      hintText: "johndoe@gmail.com",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // --- Password ---
                  ValueListenableBuilder(
                    valueListenable: _obscurePassword,
                    builder: (_, obscure, __) {
                      return TextField(
                        controller: _passwordController,
                        obscureText: obscure,
                        decoration: InputDecoration(
                          hintText: "Password",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          suffixIcon: IconButton(
                            icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
                            onPressed: () => _obscurePassword.value = !obscure,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // --- Confirm Password ---
                  ValueListenableBuilder(
                    valueListenable: _obscureConfirm,
                    builder: (_, obscure, __) {
                      return TextField(
                        controller: _confirmPasswordController,
                        obscureText: obscure,
                        decoration: InputDecoration(
                          hintText: "Confirm Password",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          suffixIcon: IconButton(
                            icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
                            onPressed: () => _obscureConfirm.value = !obscure,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // --- Signup Button ---
                  Builder(
                    builder: (buttonContext) {
                      return SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: BasicReactiveButton(
                          onPressed: () {
                            // Validate inputs
                            if (_firstNameController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("First name is required")),
                              );
                              return;
                            }
                            if (_lastNameController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Last name is required")),
                              );
                              return;
                            }
                            if (_emailController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Email is required")),
                              );
                              return;
                            }
                            if (_passwordController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Password is required")),
                              );
                              return;
                            }
                            if (_passwordController.text != _confirmPasswordController.text) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Passwords do not match")),
                              );
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
                          },
                          title: "Sign up",
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // --- Login Redirect ---
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
                            ..onTap = () => AppNavigator.pushReplacement(context, SigninPage()),
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
}