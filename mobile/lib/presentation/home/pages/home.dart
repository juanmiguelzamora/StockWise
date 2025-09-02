import 'package:flutter/material.dart';
import 'package:mobile/common/helper/navigator/app_navigator.dart';
import 'package:mobile/domain/auth/usecases/is_logged_out.dart';
import 'package:mobile/presentation/auth/pages/signin.dart';
import 'package:mobile/presentation/home/widgets/header.dart';
import 'package:mobile/presentation/home/widgets/inventory_list.dart';
import 'package:mobile/presentation/inventory/inventory_provider.dart';
import 'package:mobile/service_locator.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
    return ChangeNotifierProvider(
      create: (_) => sl<InventoryProvider>()..fetchInventory(),
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Header(),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () => _confirmLogout(context),
                ),
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Inventory",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              const InventoryList(), // our new widget
            ],
          ),
        ),
      ),
    );
  }
}
