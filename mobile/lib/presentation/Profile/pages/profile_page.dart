import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/presentation/Profile/profile_menu_item.dart';
import '../../../domain/auth/entity/user.dart';

class ProfilePage extends StatelessWidget {


  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Profile",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),

          const CircleAvatar(
            radius: 50,
            backgroundColor: Colors.blue,
            child: CircleAvatar(
              radius: 48,
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 60, color: Colors.blue),
            ),
          ),

          const SizedBox(height: 12),

          // Text(
          //   user.username,
          //   style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          // ), uncomment when username is available

       
          const SizedBox(height: 20),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                ProfileMenuItem(icon: Icons.edit, title: "Edit Profile", onTap: () {}),
                ProfileMenuItem(icon: Icons.history, title: "History", onTap: () {}),
                ProfileMenuItem(icon: Icons.lock, title: "Change password", onTap: () {}),
                ProfileMenuItem(icon: Icons.logout, title: "Log out", onTap: () {}, isLogout: true),
              ],
            ),
          ),
        ],
      ),
    );
  }
}