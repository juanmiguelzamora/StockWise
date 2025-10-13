import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/common/widgets/appbar/app_bar.dart';
import 'package:mobile/common/widgets/button/basic_app_button.dart';
import 'package:mobile/core/configs/assets/app_vectors.dart';

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
      appBar: const BasicAppbar(hideBack: false),
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
              onPressed: () {
                final oldPass = _oldPasswordCon.text.trim();
                final newPass = _newPasswordCon.text.trim();
                final confirmPass = _confirmPasswordCon.text.trim();

                if (oldPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please fill in all fields"),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }

                if (newPass != confirmPass) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("New passwords do not match"),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }

                // TODO: Implement change password logic
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Password changed successfully"),
                    behavior: SnackBarBehavior.floating,
                  ),
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
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: onToggle,
        ),
        border: OutlineInputBorder(
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