import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/services/api_service.dart';
import 'core/routing/app_router.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ApiService(),
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Salam App',
        theme: ThemeData(
          primarySwatch: Colors.green,
          fontFamily: 'Amiri',
        ),
        routerConfig: appRouter,
      ),
    );
  }
}