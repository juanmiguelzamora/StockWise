import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/common/bloc/button/nav_cubit.dart';
// import 'package:mobile/presentation/scanner/scanner_screen.dart';

class BottomNavPage extends StatelessWidget {
  const BottomNavPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NavCubit(),
      child: BlocBuilder<NavCubit, int>(
        builder: (context, selectedIndex) {
          final pages = [
            const Center(child: Text('Home')),
            const Center(child: Text('Stocks')),
            const Center(child: Text('AI Assistant')),
            const Center(child: Text('Profile')),
          ];

          void onFabPressed() {
            // AppNavigator.push(context, ScannerScreen()); // when ready
          }

          void onItemTapped(int index) {
            if (index == 2) return; // skip FAB placeholder
            context.read<NavCubit>().selectTab(index > 2 ? index - 1 : index);
          }

          return Scaffold(
            body: pages[selectedIndex],
            floatingActionButton: FloatingActionButton(
              onPressed: onFabPressed,
              backgroundColor: Colors.blue,
              tooltip: 'Scanner',
              child: const Icon(Icons.qr_code_scanner),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            bottomNavigationBar: BottomAppBar(
              shape: const CircularNotchedRectangle(),
              notchMargin: 8,
              child: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                currentIndex: selectedIndex > 1
                    ? selectedIndex + 1
                    : selectedIndex,
                onTap: onItemTapped,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.show_chart),
                    label: 'Stocks',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(
                      Icons.qr_code_scanner,
                      color: Colors.transparent,
                    ), // placeholder
                    label: '',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.smart_toy),
                    label: 'AI Assistant',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person),
                    label: 'Profile',
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
