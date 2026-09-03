import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/common/helper/navigator/app_navigator.dart';
import 'package:mobile/domain/auth/usecases/is_logged_out.dart';
import 'package:mobile/presentation/Profile/pages/history_page.dart';
import 'package:mobile/presentation/Profile/pages/change_pass.dart';
import 'package:mobile/presentation/Profile/pages/edit_profile.dart';
import 'package:mobile/presentation/Profile/widgets/profile_menu_item.dart';
import 'package:mobile/presentation/auth/pages/signin.dart';
import 'package:mobile/presentation/inventory/provider/inventory_provider.dart';
import 'package:mobile/service_locator.dart';
import 'package:mobile/domain/auth/entity/user.dart';
import 'package:mobile/domain/auth/usecases/get_user.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserEntity? _user;

  String _profileImageUrl(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    if (path.startsWith('/media/')) {
      final serverUrl = mediaBaseUrl.substring(0, mediaBaseUrl.length - 7);
      return '$serverUrl${path.substring(1)}';
    }
    return '$mediaBaseUrl$path';
  }

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final result = await sl<GetUserUseCase>().call();
    if (!mounted) return;
    result.fold((_) {}, (user) => setState(() => _user = user));
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: const Text(
          'Confirm Logout',
          style: TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Are you sure you want to log out?',
          style: TextStyle(color: Colors.blue),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.blue),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ],
      ),
    );

    if (shouldLogout == true && context.mounted) {
      _handleLogout(context);
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    final logoutUseCase = sl<LogoutUseCase>();
    final result = await logoutUseCase();

    if (!context.mounted) return;

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
        // Clear navigation stack so pressing back won't return to profile
        AppNavigator.pushAndRemoveAll(context, SigninPage());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Ensures status bar icons are always visible
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Transparent for modern look
      statusBarIconBrightness: Brightness.dark, // Icons visible on light bg
      statusBarBrightness: Brightness.light, // For iOS compatibility
    ));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.white,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        title: const Text(
          "Profile",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blue,
              child: _user?.profilePicture == null
                  ? const CircleAvatar(
                      radius: 48,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, size: 60, color: Colors.blue),
                    )
                  : CircleAvatar(
                      radius: 48,
                      backgroundImage: NetworkImage(
                        _profileImageUrl(_user!.profilePicture!),
                      ),
                      onBackgroundImageError: (_, __) {},
                    ),
            ),

            const SizedBox(height: 12),

            Text(
              _user == null
                  ? 'Loading profile...'
                  : '${_user!.firstName} ${_user!.lastName}',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_user != null) ...[
              const SizedBox(height: 4),
              Text(
                _user!.email,
                style: const TextStyle(color: Colors.black54, fontSize: 14),
              ),
            ],

            const SizedBox(height: 24),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                physics: const BouncingScrollPhysics(),
                children: [
                  ProfileMenuItem(
                    icon: Icons.lock_outline,
                    title: "Change Password",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ChangePasswordPage()),
                    ),
                  ),
                  ProfileMenuItem(
                    icon: Icons.edit,
                    title: "Edit Profile",
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const EditProfilePage()),
                      );
                      _loadProfile();
                    },
                  ),
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
                  ProfileMenuItem(
                    icon: Icons.logout,
                    title: "Log out",
                    onTap: () => _confirmLogout(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
