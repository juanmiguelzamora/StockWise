import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/common/helper/navigator/app_navigator.dart';
import 'package:mobile/core/configs/theme/app_colors.dart';
import 'package:mobile/domain/auth/entity/user.dart';
import 'package:mobile/presentation/home/bloc/user_info_display_cubit.dart';
import 'package:mobile/presentation/home/bloc/user_info_display_state.dart';
import 'package:mobile/presentation/mappers/user_presentation.dart';

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UserInfoDisplayCubit()..displayUserInfo(),
      child: Padding(
        padding: const EdgeInsets.only(
            top: 40,
            right: 16,
            left: 16
          ),
          child: BlocBuilder < UserInfoDisplayCubit, UserInfoDisplayState > (
            builder: (context, state) {
              if (state is UserInfoLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is UserInfoLoaded) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    //_profileImage(state.user,context),
                    _name(state.user),
                    //_card(context)
                  ],
                );
              }
              return Container();
            },
          ),
      ),
    );
  }

  Widget _name(UserEntity user) {
  return Container(
    height: 40,
    padding: const EdgeInsets.symmetric(
      horizontal: 16
    ),
    decoration: BoxDecoration(
      color: AppColors.secondBackground,
      //borderRadius: BorderRadius.circular(100)
    ),
    child: Center(
      child: Text(
        // Display the first and last name
        user.greeting,
        //user.email,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 32,
          color: Colors.amber
        ),
      ),
    ),
  );
}

// Widget _profileImage(UserEntity user,BuildContext context) {
  //   return GestureDetector(
  //     onTap: (){
  //       AppNavigator.push(context, const SettingsPage());
  //     },
  //     child: Container(
  //       height: 40,
  //       width: 40,
  //       decoration: BoxDecoration(
  //         image: DecorationImage(
  //           image: user.image.isEmpty ? 
  //           const AssetImage(
  //             AppImages.profile
  //           ) : NetworkImage(
  //             user.image
  //           )
  //         ),
  //         color: Colors.red,
  //         shape: BoxShape.circle
  //       ),
  //     ),
  //   );
  // }

  // Widget _card(BuildContext context) {
  //   return GestureDetector(
  //     onTap: (){
  //       AppNavigator.push(context,const CartPage());
  //     },
  //     child: Container(
  //       height: 40,
  //       width: 40,
  //       decoration: const BoxDecoration(
  //         color: AppColors.primary,
  //         shape: BoxShape.circle
  //       ),
  //       child: SvgPicture.asset(
  //         AppVectors.bag,
  //         fit: BoxFit.none,
  //       ),
  //     ),
  //   );
  // }
}
