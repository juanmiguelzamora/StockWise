import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/common/helper/navigator/app_navigator.dart';
import 'package:mobile/core/configs/assets/app_vectors.dart';
import 'package:mobile/core/configs/theme/app_colors.dart';
import 'package:mobile/presentation/auth/pages/signin.dart';
import 'package:mobile/presentation/bottom_nav/pages/bottom_nav_page.dart';
import 'package:mobile/presentation/splash/bloc/splash_state.dart';
import 'package:mobile/presentation/splash/bloc/splash_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';



class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashCubit,SplashState>(
      listener: (context, state) {
        if(state is UnAuthenticated) {
          AppNavigator.pushReplacement(
            context, SigninPage()
          );
        }
        if(state is Authenticated) {
          AppNavigator.pushReplacement(
            context, const BottomNavPage()
            );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: SvgPicture.asset(
            AppVectors.stockcube
          ),
        ),
      ),
    );
  }
}