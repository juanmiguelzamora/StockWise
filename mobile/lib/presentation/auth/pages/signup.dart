import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/common/bloc/button/button_state.dart';
import 'package:mobile/common/bloc/button/button_state_cubit.dart';
import 'package:mobile/common/helper/navigator/app_navigator.dart';
import 'package:mobile/common/widgets/appbar/app_bar.dart';
import 'package:mobile/common/widgets/button/basic_reactive_button.dart';
import 'package:mobile/core/configs/theme/app_colors.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BasicAppbar(),
      body: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => ButtonStateCubit())
        ],
        child: BlocListener<ButtonStateCubit, ButtonState>(
          listener: (context, state) {
            if (state is ButtonFailureState) {
              var snackbar = SnackBar(
                content: Text(state.errorMessage),
                behavior: SnackBarBehavior.floating,
              );
              ScaffoldMessenger.of(context).showSnackBar(snackbar);
            }
            if (state is ButtonSuccessState) {
              AppNavigator.push(context, SigninPage());
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _signupText(),
                const SizedBox(height: 20),
                _firstNameField(),
                const SizedBox(height: 20),
                _lastNameField(),
                const SizedBox(height: 20),
                _emailField(),
                const SizedBox(height: 20),
                _passwordField(),
                const SizedBox(height: 20),
                _signupButton(context),
                const SizedBox(height: 20),
                _createAccount(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _signupText() {
    return const Text(
      'Create Account',
      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
    );
  }

  Widget _firstNameField() {
    return TextField(
      controller: _firstNameController,
      decoration: const InputDecoration(hintText: 'Firstname'),
    );
  }

  Widget _lastNameField() {
    return TextField(
      controller: _lastNameController,
      decoration: const InputDecoration(hintText: 'Lastname'),
    );
  }

  Widget _emailField() {
    return TextField(
      controller: _emailController,
      decoration: const InputDecoration(hintText: 'Enter Email'),
    );
  }

  Widget _passwordField() {
    return TextField(
      controller: _passwordController,
      decoration: const InputDecoration(hintText: 'Password'),
      obscureText: true,
    );
  }

  Widget _signupButton(BuildContext context) {
    return Container(
      height: 100,
      color: AppColors.secondBackground,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Center(
        child: Builder( 
          builder: (context) {
            return BasicReactiveButton(
              onPressed: () {
                final userCreationReq = UserCreationReq(
                  firstName: _firstNameController.text,
                  lastName: _lastNameController.text,
                  email: _emailController.text,
                  password: _passwordController.text,
                );

                context.read<ButtonStateCubit>().execute(
                  usecase: sl<SignupUseCase>(),
                  params: userCreationReq,
                );
              },
              title: 'Signup',
            );
          },
        ),
      ),
    );
  }

  Widget _createAccount(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          const TextSpan(text: "Do you have an account? "),
          TextSpan(
            text: 'Signin',
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                AppNavigator.pushReplacement(context, SigninPage());
              },
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
