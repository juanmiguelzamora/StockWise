import 'package:flutter/material.dart';
?
class ProfileApp extends StatelessWidget {
  const ProfileApp({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = ProfileRepositoryImpl();
    final getProfile = GetProfile(repository);

    return FutureBuilder(
      future: getProfile(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Splash-like loading screen
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasData) {
          return ProfilePage(profile: snapshot.data!);
        } else {
          return const Scaffold(
            body: Center(child: Text("Error loading profile")),
          );
        }
      },
    );
  }
}
