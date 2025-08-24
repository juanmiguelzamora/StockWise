import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/common/bloc/button/button_state.dart';
import 'package:mobile/common/bloc/button/button_state_cubit.dart';
import 'package:mobile/common/helper/navigator/app_navigator.dart';
import 'package:mobile/common/widgets/appbar/app_bar.dart';
import 'package:mobile/common/widgets/button/basic_app_button.dart';
import 'package:mobile/domain/auth/usecases/send_password_reset_email.dart';
import 'package:mobile/presentation/auth/pages/password_reset_email.dart';


class ForgotPasswordPage extends StatelessWidget {
  ForgotPasswordPage({super.key});
  final TextEditingController _emailCon = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _signinText(),
                const SizedBox(height: 20),
                _emailField(),
                const SizedBox(height: 20),
                _continueButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _signinText() {
    return const Text(
      'Forgot Password',
      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
    );
  }

  Widget _emailField() {
    return TextField(
      controller: _emailCon,
      decoration: const InputDecoration(
        hintText: 'Enter Email',
      ),
    );
  }

  Widget _continueButton() {
    return Builder(
      builder: (context) {
        return BasicAppButton(
          onPressed: () {
            final email = _emailCon.text.trim();

            if (email.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please enter your email'),
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
          title: 'Continue',
        );
      },
    );
  }
}