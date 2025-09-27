import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/common/bloc/button/button_state.dart';
import 'package:mobile/common/bloc/button/button_state_cubit.dart';
import 'package:mobile/common/helper/navigator/app_navigator.dart';
import 'package:mobile/common/widgets/button/basic_reactive_button.dart';
import 'package:mobile/data/auth/models/user_signin_req.dart';
import 'package:mobile/domain/auth/usecases/signin.dart';
import 'package:mobile/presentation/bottom_nav/pages/bottom_nav_page.dart';
import 'package:mobile/presentation/auth/pages/forgot_password.dart';
import 'package:mobile/presentation/auth/pages/signup.dart';
import 'package:mobile/presentation/home/pages/home.dart';
import 'package:mobile/service_locator.dart';
import 'package:mobile/core/configs/assets/app_vectors.dart';

class SigninPage extends StatelessWidget {
  SigninPage({super.key});

  final TextEditingController _emailCon = TextEditingController();
  final TextEditingController _passwordCon = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                _illustration(),
                const SizedBox(height: 32),
                _welcomeText(),
                const SizedBox(height: 24),
                _emailField(),
                const SizedBox(height: 16),
                _passwordField(context),
                const SizedBox(height: 16),
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
    );
  }

  /// Illustration (center image)
  Widget _illustration() {
    return Center(
      child: SvgPicture.asset(
        AppVectors.login,
        height: 160,
      ),
    );
  }

  /// Welcome text
  Widget _welcomeText() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
    Text(
  "Welcome Back!",
  style: TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w900,
    letterSpacing: 0.5,
    color: Colors.black, // <-- Add this line
  ),
),
        SizedBox(height: 8),
        Text(
          "Sign in to continue to StockWise.",
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
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black,),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _emailCon,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.transparent,
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue),
              borderRadius: BorderRadius.circular(8),
            ),
            hintText: "Enter your email",
            hintStyle: const TextStyle(color: Colors.grey),
          ),
        ),
      ],
    );
  }

  /// Password input
  Widget _passwordField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Password",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _passwordCon,
          obscureText: true,
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.transparent,
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue),
              borderRadius: BorderRadius.circular(8),
            ),
            hintText: "Enter your password",
            hintStyle: const TextStyle(color: Colors.grey),
          ),
        ),
      ],
    );
  }

  /// Remember me + forgot password row
  Widget _rememberForgot(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Checkbox(
              value: false,
              onChanged: (value) {},
            ),
            const Text("Remember me", style: TextStyle(color: Colors.black)),
          ],
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ForgotPasswordPage()),
            );
          },
          child: const Text("Forgot Password?", style: TextStyle(color: Colors.blueAccent)),
        ),
      ],
    );
  }

  /// Login button (connected to ButtonStateCubit + SigninUseCase)
  Widget _signinButton(BuildContext context) {
    return BlocProvider<ButtonStateCubit>(
      create: (_) => ButtonStateCubit(),
      child: BlocListener<ButtonStateCubit, ButtonState>(
        listener: (context, state) {
          if (state is ButtonSuccessState) {
            // Navigate to homepage on successful sign in
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => BottomNavPage()),
            );
          }
          if (state is ButtonFailureState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage)),
            );
          }
        },
        child: BlocBuilder<ButtonStateCubit, ButtonState>(
          builder: (context, state) {
            return BasicReactiveButton(
              title: "Sign In",
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
            );
          },
        ),
      ),
    );
  }

  /// Create Account (signup link)
  Widget _createAccount(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Don't have an account?"),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => SignupPage()),
            );
          },
          child: const Text("Register", style: TextStyle(color: Colors.blueAccent)),
        ),
      ],
    );
  }
}
