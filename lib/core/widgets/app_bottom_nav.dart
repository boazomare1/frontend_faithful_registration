import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const AppBottomNav({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    print('Rendering AppBottomNav: currentIndex=$currentIndex'); // Debug
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      backgroundColor: AppColors.background,
      selectedItemColor: AppColors.accent,
      unselectedItemColor: AppColors.primary,
      elevation: 8.0, // Ensure visibility
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.person_add), label: 'Faithfuls'),
        BottomNavigationBarItem(icon: Icon(Icons.mosque), label: 'Mosques'),
        BottomNavigationBarItem(icon: Icon(Icons.family_restroom), label: 'Households'),
      ],
    );
  }
}