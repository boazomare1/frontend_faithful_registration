import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    const storage = FlutterSecureStorage();

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: AppColors.primary),
            child: FutureBuilder<String?>(
              future: storage.read(key: 'full_name'),
              builder: (context, snapshot) {
                return Text(
                  'Welcome, ${snapshot.data ?? 'User'}',
                  style: const TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 24,
                    color: Colors.white,
                  ),
                );
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile', style: TextStyle(fontFamily: 'Amiri')),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile Coming Soon')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout', style: TextStyle(fontFamily: 'Amiri')),
            onTap: () async {
              await storage.deleteAll();
              context.go('/login');
            },
          ),
        ],
      ),
    );
  }
}