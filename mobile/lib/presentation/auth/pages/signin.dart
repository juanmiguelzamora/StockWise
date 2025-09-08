import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/common/bloc/button/button_state.dart';
import 'package:mobile/common/bloc/button/button_state_cubit.dart';
import 'package:mobile/common/helper/navigator/app_navigator.dart';
import 'package:mobile/common/widgets/button/basic_reactive_button.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA), // light background
      body: SafeArea(
        child: BlocProvider(
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
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => BottomNavPage()),
                );
              }
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _logo(),
                  const SizedBox(height: 32),
                  _illustration(),
                  const SizedBox(height: 32),
                  _welcomeText(),
                  const SizedBox(height: 32),
                  _emailField(),
                  const SizedBox(height: 20),
                  _passwordField(context),
                  const SizedBox(height: 12),
                  _rememberForgot(context),
                  const SizedBox(height: 24),
                  _signinButton(context),
                  const SizedBox(height: 24),
                  _createAccount(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Logo + title top-left
  Widget _logo() {
    return Row(
      children: [
        Image.asset("assets/stockwise_logo.png", height: 32),
        const SizedBox(width: 6),
        const Text(
          "STOCKWISE",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  /// Illustration (center image)
  Widget _illustration() {
    return Center(
      child: Image.asset("assets/tablet_login_picture.png", height: 160),
    );
  }

  /// Welcome text
  Widget _welcomeText() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Welcome back",
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 8),
        Text(
          "Please enter your details to login.",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ],
    );
  }

  /// Email input
  Widget _emailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Email",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _emailCon,
          decoration: InputDecoration(
            hintText: "johndoe@gmail.com",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
      ],
    );
  }

  /// Password input
  Widget _passwordField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Password",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            GestureDetector(
              onTap: () {
                AppNavigator.push(context, ForgotPasswordPage());
              },
              child: const Text(
                "Forgot Password?",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _passwordCon,
          obscureText: true,
          decoration: InputDecoration(
            hintText: "Enter your password",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  /// Remember me + forgot password row
  Widget _rememberForgot(BuildContext context) {
    return Row(
      children: [
        Checkbox(value: false, onChanged: (_) {}),
        const Text("Remember me"),
      ],
    );
  }

  /// Login button (connected to ButtonStateCubit + SigninUseCase)
  Widget _signinButton(BuildContext context) {
    return Builder(
      builder: (context) {
        return BasicReactiveButton(
          onPressed: () {
            final userSigninReq = UserSigninReq(
              email: _emailCon.text,
              password: _passwordCon.text,
            );
            context.read<ButtonStateCubit>().execute(
              usecase: sl<SigninUseCase>(),
              params: userSigninReq,
            );
          },
          title: 'Login',
        );
      },
    );
  }

  /// Create Account (signup link)
  Widget _createAccount(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Don’t have an account?",
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: () {
            AppNavigator.push(context, SignupPage());
          },
          child: const Text(
            "Register",
            style: TextStyle(
              fontSize: 14,
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
