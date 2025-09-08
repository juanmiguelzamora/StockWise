import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/common/bloc/navigation/nav_cubit.dart';
import 'package:mobile/domain/navigation/entity/nav_item.dart';
import 'package:mobile/presentation/Profile/pages/profile_page.dart';
import 'package:mobile/presentation/home/pages/home.dart';
//import 'package:mobile/presentation/stocks/stocks_page.dart';
// import 'package:mobile/presentation/assistant/assistant_page.dart';
// import 'package:mobile/presentation/profile/profile_page.dart';
import '../widgets/bottom_nav_bar.dart';

class BottomNavPage extends StatelessWidget {
  const BottomNavPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NavCubit(),
      child: BlocBuilder<NavCubit, NavItem>(
        builder: (context, selectedItem) {
          final pages = {
            NavItem.home: const HomePage(),
            //NavItem.stocks: const StocksPage(),
            //NavItem.assistant: const AssistantPage(),
           NavItem.profile: const ProfilePage(),
          };

          void onFabPressed() {
            // TODO: Implement scanner navigation later
            // AppNavigator.push(context, const ScannerScreen());
          }

          return Scaffold(
            body: pages[selectedItem] ?? const Center(child: Text("Page not found")),
            floatingActionButton: FloatingActionButton(
              onPressed: onFabPressed,
              backgroundColor: Colors.blue,
              tooltip: 'Scanner',
              child: const Icon(Icons.qr_code_scanner),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            bottomNavigationBar: BottomNavBar(selectedItem: selectedItem),
          );
        },
      ),
    );
  }
}
