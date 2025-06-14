import 'package:flutter/material.dart';
import 'package:salam/core/constants/app_colors.dart';

class MosquesScreen extends StatelessWidget {
  const MosquesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.primary, AppColors.secondary],
        ),
      ),
      child: const SafeArea(
        child: Center(
          child: Text(
            'Mosques Page Coming Soon',
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 24,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}