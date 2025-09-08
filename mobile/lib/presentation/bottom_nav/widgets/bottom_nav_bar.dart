import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/common/bloc/navigation/nav_cubit.dart';
import 'package:mobile/domain/navigation/entity/nav_item.dart';

class BottomNavBar extends StatelessWidget {
  final NavItem selectedItem;
  const BottomNavBar({super.key, required this.selectedItem});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _mapItemToIndex(selectedItem),
        onTap: (index) {
          if (index == 2) return; // Skip FAB placeholder
          final adjustedIndex = index > 2 ? index - 1 : index;
          final item = _mapIndexToItem(adjustedIndex);
          context.read<NavCubit>().selectTab(item);
        },
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
            icon: Icon(Icons.qr_code_scanner, color: Colors.transparent),
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
    );
  }

  int _mapItemToIndex(NavItem item) {
    switch (item) {
      case NavItem.home:
        return 0;
      case NavItem.stocks:
        return 1;
      case NavItem.assistant:
        return 3;
      case NavItem.profile:
        return 4;
    }
  }

  NavItem _mapIndexToItem(int index) {
    switch (index) {
      case 0:
        return NavItem.home;
      case 1:
        return NavItem.stocks;
      case 2:
        return NavItem.assistant;
      case 3:
        return NavItem.profile;
      default:
        return NavItem.home;
    }
  }
}
