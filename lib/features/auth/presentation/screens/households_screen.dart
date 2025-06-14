import 'package:flutter/material.dart';
import 'package:salam/core/constants/app_colors.dart';

class HouseholdsScreen extends StatelessWidget {
  const HouseholdsScreen({super.key});

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
            'Households Page Coming Soon',
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