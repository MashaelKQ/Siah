import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/siah_logo.dart';
import 'auth_gate.dart';

/// Displays the Siah logo briefly before checking
/// whether the user already has an active Firebase session.
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
    // Startup Flow
    // Displays the splash screen before checking authentication.
    // ===========================================================
    Timer(const Duration(seconds: 2), () {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const AuthGate(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          // ===========================================================
          // Application Branding
          // Displays the Siah logo while the app starts.
          // ===========================================================
          child: SiahLogo(
            height: 180,
          ),
        ),
      ),
    );
  }
}
