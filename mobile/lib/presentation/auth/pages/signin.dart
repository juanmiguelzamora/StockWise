import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/common/bloc/button/button_state.dart';
import 'package:mobile/common/bloc/button/button_state_cubit.dart';
import 'package:mobile/common/helper/navigator/app_navigator.dart';
import 'package:mobile/common/widgets/button/basic_reactive_button.dart';
import 'package:mobile/data/auth/models/user_signin_req.dart';
import 'package:mobile/domain/auth/usecases/signin.dart';
import 'package:mobile/presentation/auth/pages/forgot_password.dart';
import 'package:mobile/presentation/auth/pages/signup.dart';
import 'package:mobile/presentation/home/pages/home.dart';
import 'package:mobile/service_locator.dart';

class SigninPage extends StatelessWidget {
  SigninPage({super.key});

  final TextEditingController _emailCon = TextEditingController();
  final TextEditingController _passwordCon = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 40
        ),
        child: BlocProvider(
          create: (context) => ButtonStateCubit(),
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
              AppNavigator.pushReplacement(context, HomePage());
            }
          },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _signinText(context),
                const SizedBox(height: 20,),
                _emailField(context),
                const SizedBox(height: 20,),
                _passwordField(context),
                const SizedBox(height: 20,),
                _forgotPassword(context),
                const SizedBox(height: 20,),
                _signinButton(context),
                const SizedBox(height: 20,),
                _createAccount(context)
              ],
            ),
          ),
        ),
      )
    );
  }
  
  Widget _signinText(BuildContext context) {
    return Text(
      'Sign In',
      style: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold
      ),
    );
  }

  Widget _emailField(BuildContext context) {
    return TextField(
      controller: _emailCon,
      decoration: InputDecoration(
        hintText: 'Enter Email'
      ),
    );
  }

  Widget _passwordField(BuildContext context) {
    return TextField(
      controller: _passwordCon,
      decoration: InputDecoration(
        hintText: 'Enter Password'
      ),
      obscureText: true,
    );
  }

  Widget _signinButton(BuildContext context) {
    return Builder(
      builder: (context) {
        return BasicReactiveButton(
          onPressed: (){
            final userSigninReq = UserSigninReq(
                  email: _emailCon.text,
                  password: _passwordCon.text,
                );
            context.read<ButtonStateCubit>().execute(
              usecase: sl<SigninUseCase>(),
              params: userSigninReq,
            );
          },
          title: 'Signin'
        );
      }
    );
  }

  Widget _createAccount(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: 'Dont have an account?'
          ),
          TextSpan(
            text: 'Create Account',
            recognizer: TapGestureRecognizer()..onTap = () {
               AppNavigator.push(context, SignupPage());
            },
            style: TextStyle(
              fontWeight: FontWeight.bold
            )
          )
        ]
      )
    );
  }

  Widget _forgotPassword(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: RichText(
        text: TextSpan(
          text: 'Forgot Password?',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blue, 
          ),
          recognizer: TapGestureRecognizer()..onTap = () {
               AppNavigator.push(context, ForgotPasswordPage());
            },
        ),
      ),
    );
  }
}