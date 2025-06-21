import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import 'dashboard_screen.dart';
import 'faithful_dashboard_screen.dart';
import 'mosques_screen.dart';
import 'households_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static final GlobalKey<_HomeScreenState> _homeScreenKey = GlobalKey<_HomeScreenState>();

  static void switchToHome() {
    _homeScreenKey.currentState?._switchToHome();
  }

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const FaithfulDashboardScreen(),
    const MosquesScreen(),
    const HouseholdsScreen(),
  ];

  final List<String> _tabPaths = ['/home', '/faithfuls', '/mosques', '/households'];

  void _onNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _switchToHome() {
    setState(() {
      _selectedIndex = 0; // Switch to Home tab
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: HomeScreen._homeScreenKey,
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