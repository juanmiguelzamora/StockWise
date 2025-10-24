import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
        padding: const EdgeInsets.only(top: 40, right: 16, left: 16),
        child: BlocBuilder<UserInfoDisplayCubit, UserInfoDisplayState>(
          builder: (context, state) {
            if (state is UserInfoLoading) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.person, color: Colors.white70),
                  ),
                  Text(
                    "Loading...",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
                    ),
                  ),
                ],
              );
            }

            if (state is UserInfoLoaded) {
              return _buildHeader(context, state.user);
            }

            // Fallback (e.g., offline or no data)
            return _buildHeader(
              context,
              UserEntity(
                userId: "0",
                firstName: "Guest",
                lastName: "",
                email: "guest@stockwise.app",
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, UserEntity user) {
    final greeting = user.greeting.isNotEmpty
        ? user.greeting
        : "Welcome, ${user.firstName}";

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Profile avatar with shimmer animation
        CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.primary.withOpacity(0.2),
          child: Icon(
            Icons.person,
            size: 28,
            color: AppColors.primary,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: AppColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                user.email,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary.withOpacity(0.8),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),

       /*  IconButton(
          icon: const Icon(Icons.notifications_none, color: AppColors.textPrimary),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Notifications coming soon!")),
            );
          },
        ), */
      ],
    );
  }
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
