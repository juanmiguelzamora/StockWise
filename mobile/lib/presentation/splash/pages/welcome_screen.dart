import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/core/configs/assets/app_vectors.dart';
import 'package:mobile/common/helper/navigator/app_navigator.dart';
import 'package:mobile/presentation/auth/pages/signin.dart';
import 'package:mobile/presentation/auth/pages/signup.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F8),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ===== Logo + Brand Name =====
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(width: 8),
                  SvgPicture.asset(
                    AppVectors.stockLogo, // STOCKWISE svg
                    height: 28,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ===== Comment / Tagline under logo =====
              const Text(
                "Your stock management assistant", // adjust text
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 60),

              // ===== Login button =====
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    AppNavigator.push(context, SigninPage());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text(
                    "Login",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ===== Sign up button =====
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    AppNavigator.push(context, SignupPage());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text(
                    "Sign up",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),

              const Spacer(),

              // ===== Continue as Guest =====
              GestureDetector(
                onTap: () {
                  // TODO: Add guest navigation
                },
                child: const Text(
                  "Continue as a Guest",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
