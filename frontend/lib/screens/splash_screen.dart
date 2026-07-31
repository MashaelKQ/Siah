import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/siah_logo.dart';
import 'main_navigation_screen.dart';

/// SplashScreen
///
/// Displays the application's branding while the app initializes.
/// After a short delay, the user is automatically redirected to the
/// main navigation screen.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // ===========================================================
    // App Initialization
    // Displays the splash screen briefly before entering the app.
    // ===========================================================
    Timer(const Duration(seconds: 2), () {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const MainNavigationScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ===========================================================
      // Splash Screen Layout
      // Displays the application's logo while loading.
      // ===========================================================
      backgroundColor: AppColors.background,
      body: const SafeArea(
        child: Center(
          child: SiahLogo(
            height: 180,
          ),
        ),
      ),
    );
  }
}
