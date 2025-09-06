import 'package:flutter/material.dart';
import 'package:mobile/domain/auth/usecases/get_user.dart';


class ProfileApp extends StatelessWidget {
  const ProfileApp({super.key});

  @override
  Widget build(BuildContext context) {
    final getProfile = GetUserUseCase();

    return FutureBuilder(
      future: getProfile(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Splash-like loading screen
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        // } else if (snapshot.hasData) {
        //   return ProfilePage(profile: snapshot.data!);
        } else {
          return const Scaffold(
            body: Center(child: Text("Error loading profile")),
          );
        }
      },
    );
  }
}
