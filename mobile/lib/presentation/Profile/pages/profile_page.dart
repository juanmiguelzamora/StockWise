import 'package:flutter/material.dart';
import 'package:mobile/common/helper/navigator/app_navigator.dart';
import 'package:mobile/domain/auth/usecases/is_logged_out.dart';
import 'package:mobile/presentation/Profile/pages/change_pass.dart';
import 'package:mobile/presentation/Profile/pages/edit_profile_page.dart';
import 'package:mobile/presentation/Profile/pages/history_page.dart';
import 'package:mobile/presentation/Profile/widgets/profile_menu_item.dart';
import 'package:mobile/presentation/auth/pages/signin.dart';
import 'package:mobile/presentation/inventory/provider/inventory_provider.dart';
import 'package:mobile/presentation/trends/pages/trends_page.dart';
import 'package:mobile/service_locator.dart';
import 'package:provider/provider.dart';


class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<void> _confirmLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      _handleLogout(context);
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    final logoutUseCase = sl<LogoutUseCase>();
    final result = await logoutUseCase();

    result.fold(
      (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout failed: $error')),
        );
      },
      (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logged out successfully')),
        );
        AppNavigator.push(context,SigninPage());
      },
    );
  }

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
                ProfileMenuItem(icon: Icons.edit, title: "Edit Profile", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TrendsPage()))),
                ProfileMenuItem(
                  icon: Icons.history,
                  title: "History",
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChangeNotifierProvider(
                        create: (_) => sl<InventoryProvider>(),
                        child: const InventoryHistoryPage(),
                      ),
                    ),
                  ),
                ),
                ProfileMenuItem(icon: Icons.lock, title: "Change password", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordPage()))),
                ProfileMenuItem(icon: Icons.logout, title: "Log out", onTap: () => _confirmLogout(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}