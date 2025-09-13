import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/common/helper/navigator/app_navigator.dart';
import 'package:mobile/domain/auth/usecases/is_logged_out.dart';
import 'package:mobile/presentation/auth/pages/signin.dart';
import 'package:mobile/presentation/home/widgets/header.dart';
import 'package:mobile/presentation/home/widgets/inventory_list.dart';
import 'package:mobile/presentation/inventory/inventory_provider.dart';
import 'package:mobile/service_locator.dart';


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
        AppNavigator.push(context, SigninPage());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double fontSmall = screenWidth * 0.035;
    double fontMedium = screenWidth * 0.045;
    double fontLarge = screenWidth * 0.055;

    return ChangeNotifierProvider(
      create: (_) => sl<InventoryProvider>()..fetchInventory(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(screenWidth * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const Header(),
                SizedBox(height: screenHeight * 0.02),

                // Logout Button
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () => _confirmLogout(context),
                  ),
                ),

                // Greeting
                Text(
                  "Welcome back,",
                  style: TextStyle(fontSize: fontMedium, color: Colors.grey),
                ),
              

                SizedBox(height: screenHeight * 0.02),

                // Stats Card
                Container(
                  padding: EdgeInsets.all(screenWidth * 0.04),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.blueAccent, Colors.lightBlueAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(screenWidth * 0.04),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text("Today",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: fontMedium,
                                  fontWeight: FontWeight.bold)),
                          SizedBox(width: screenWidth * 0.02),
                          Text("Jul, 29 2025",
                              style: TextStyle(
                                  color: Colors.grey[300], fontSize: fontSmall)),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _StatItem("392", "Total", fontLarge, fontSmall),
                          _divider(screenHeight),
                          _StatItem("123", "Stock In", fontLarge, fontSmall),
                          _divider(screenHeight),
                          _StatItem("242", "Stock Out", fontLarge, fontSmall),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: screenHeight * 0.02),

                // Stock Alerts
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        child: _StockAlertCard(
                            color: Colors.black87,
                            title: "Overstock",
                            value: "10",
                            fontLarge: fontLarge,
                            fontSmall: fontSmall)),
                    const SizedBox(width: 8),
                    Expanded(
                        child: _StockAlertCard(
                            color: Colors.redAccent,
                            title: "Out of Stock",
                            value: "99",
                            fontLarge: fontLarge,
                            fontSmall: fontSmall)),
                    const SizedBox(width: 8),
                    Expanded(
                        child: _StockAlertCard(
                            color: Colors.orangeAccent,
                            title: "Low Stock Alerts",
                            value: "32",
                            fontLarge: fontLarge,
                            fontSmall: fontSmall,
                            isLongTitle: true)),
                  ],
                ),

                SizedBox(height: screenHeight * 0.03),

                // Inventory Section (from your Provider)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text("Inventory",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 8),
                const InventoryList(),

                SizedBox(height: screenHeight * 0.03),

                // History Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("History",
                        style: TextStyle(
                            fontSize: fontMedium, fontWeight: FontWeight.bold)),
                    Text("See all",
                        style: TextStyle(
                            fontSize: fontSmall, color: Colors.blueAccent)),
                  ],
                ),

                // Example history (static for now)
                _HistoryItem(
                    imagePath: 'assets/mouse.png',
                    title: 'Gaming Mouse',
                    stock: '45',
                    change: '-50',
                    changeColor: Colors.red,
                    fontMedium: fontMedium,
                    fontSmall: fontSmall),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _divider(double screenHeight) => Container(
        width: 1,
        height: screenHeight * 0.05,
        color: Colors.white.withOpacity(0.5),
      );

  Widget _StatItem(
      String value, String label, double fontLarge, double fontSmall) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                color: Colors.white,
                fontSize: fontLarge,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label,
            style: TextStyle(color: Colors.white70, fontSize: fontSmall)),
      ],
    );
  }

  Widget _StockAlertCard({
    required Color color,
    required String title,
    required String value,
    required double fontLarge,
    required double fontSmall,
    bool isLongTitle = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: Colors.white70,
                  fontSize: isLongTitle ? fontSmall * 0.9 : fontSmall,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: fontLarge,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // ignore: non_constant_identifier_names
  Widget _HistoryItem({
    required String imagePath,
    required String title,
    required String stock,
    required String change,
    required Color changeColor,
    required double fontMedium,
    required double fontSmall,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            CircleAvatar(radius: fontMedium, backgroundImage: AssetImage(imagePath)),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title,
                  style:
                      TextStyle(fontWeight: FontWeight.w500, fontSize: fontMedium)),
              Text('Stock: $stock',
                  style: TextStyle(color: Colors.grey[600], fontSize: fontSmall)),
            ]),
          ]),
          Text(change,
              style: TextStyle(
                  color: changeColor,
                  fontSize: fontMedium,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
