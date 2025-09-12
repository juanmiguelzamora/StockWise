import 'package:flutter/material.dart';
import 'package:stock_wise/screens/home_screen.dart';

import 'scanner_screen.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({Key? key}) : super(key: key);

  @override
  State<BottomNav> createState() => _BottomNavState();
}


class _BottomNavState extends State<BottomNav> {
    int _selectedIndex = 0;
    
    final List<Widget> _pages = [
      const HomeScreen(),
      const Center(child: Text('Stocks')),
      const Center(child: Text('AI Assistant')),
      const Center(child: Text('Profile')),
    ];


    void _onItemTapped(int index) {
      setState(() {
        _selectedIndex = index;
      });
    }


    void _onFabPressed() {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ScannerScreen()),
    );
}


@override Widget build(BuildContext context) {
    return Scaffold(
        body: _pages[_selectedIndex],
        floatingActionButton: FloatingActionButton(
        onPressed: _onFabPressed,
        child: const Icon(Icons.qr_code_scanner),
        tooltip: 'Scanner',
        backgroundColor: Colors.blue,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 8,
            child: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                currentIndex: _selectedIndex > 1 ? _selectedIndex + 1 : _selectedIndex,
                onTap: (index) {
                  if (index == 2) return; // It will skip the FAB space for the scanner
                  _onItemTapped(index > 2 ? index - 1 : index);
                },
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: 'HomeScreen',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.show_chart),
                    label: 'Stocks',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.qr_code_scanner, color: Colors.transparent), // Placeholder for FAB
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
    }
}