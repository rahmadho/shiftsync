import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// S1 — Splash / About screen.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 1600), () {
      if (mounted) context.go('/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.badge_outlined,
                  color: Colors.white, size: 44),
            ),
            const SizedBox(height: 20),
            const Text('ShiftSync', style: AppTextStyles.h1),
            const SizedBox(height: 6),
            const Text('HR & Workforce Management', style: AppTextStyles.bodySm),
            const SizedBox(height: 40),
            const Text('v1.0.2 © 2024 ShiftSync Inc.',
                style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }
}
