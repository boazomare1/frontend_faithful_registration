import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import 'dashboard_screen.dart';
import 'faithful_registration_screen.dart';
import 'mosques_screen.dart';
import 'households_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const FaithfulRegistrationScreen(),
    const MosquesScreen(),
    const HouseholdsScreen(),
  ];

  void _onNavTap(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Salam App',
          style: TextStyle(fontFamily: 'Amiri', color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: const AppDrawer(),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _selectedIndex,
        onTap: _onNavTap,
      ),
      body: _screens[_selectedIndex],
    );
  }
}