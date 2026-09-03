import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/common/widgets/appbar/app_bar.dart';
import 'package:mobile/common/widgets/button/basic_app_button.dart';
import 'package:mobile/core/configs/assets/app_vectors.dart';
import 'package:mobile/core/configs/theme/app_colors.dart';
import 'package:mobile/domain/auth/repository/auth.dart';
import 'package:mobile/service_locator.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController _oldPasswordCon = TextEditingController();
  final TextEditingController _newPasswordCon = TextEditingController();
  final TextEditingController _confirmPasswordCon = TextEditingController();

  bool _oldObscure = true;
  bool _newObscure = true;
  bool _confirmObscure = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BasicAppbar(
        hideBack: false,
        title: Text('Change Password', style: TextStyle(color: Colors.black)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ✅ SVG Illustration
            SvgPicture.asset(
              AppVectors.changepass,
              height: 180,
            ),
            const SizedBox(height: 30),

            // ✅ Title
            const Text(
              "Change Password",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            // ✅ Old Password
            _passwordField(
              label: "Old Password",
              controller: _oldPasswordCon,
              obscureText: _oldObscure,
              onToggle: () => setState(() => _oldObscure = !_oldObscure),
            ),
            const SizedBox(height: 15),

            // ✅ New Password
            _passwordField(
              label: "New Password",
              controller: _newPasswordCon,
              obscureText: _newObscure,
              onToggle: () => setState(() => _newObscure = !_newObscure),
            ),
            const SizedBox(height: 15),

            // ✅ Confirm Password
            _passwordField(
              label: "Confirm Password",
              controller: _confirmPasswordCon,
              obscureText: _confirmObscure,
              onToggle: () => setState(() => _confirmObscure = !_confirmObscure),
            ),
            const SizedBox(height: 30),

            // ✅ Confirm Button
            BasicAppButton(
              title: "Confirm Change",
              textColor: Colors.white,
              onPressed: () async {
                final oldPass = _oldPasswordCon.text.trim();
                final newPass = _newPasswordCon.text.trim();
                final confirmPass = _confirmPasswordCon.text.trim();

                if (oldPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please fill in all fields", style: TextStyle(color: Colors.black)),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }

                if (newPass != confirmPass) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("New passwords do not match", style: TextStyle(color: Colors.black)),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }

                final result = await sl<AuthRepository>().changePassword(
                  oldPassword: oldPass,
                  newPassword: newPass,
                );
                if (!context.mounted) return;
                result.fold(
                  (error) => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed: $error', style: const TextStyle(color: Colors.black))),
                  ),
                  (_) {
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// ✅ Custom Password Input
  Widget _passwordField({
    required String label,
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.primary),
        floatingLabelStyle: const TextStyle(color: AppColors.primary),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_off : Icons.visibility,
            color: AppColors.primary,
          ),
          onPressed: onToggle,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.primary),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 14,
        ),
      ),
    );
  }
}