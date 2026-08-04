import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/siah_logo.dart';
import 'auth_gate.dart';

/// Displays the Siah logo briefly before checking whether
/// the user already has an active Firebase session.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    // ===========================================================
    // Startup Flow
    // Displays the splash screen briefly before opening AuthGate.
    // ===========================================================
    _navigationTimer = Timer(
      const Duration(seconds: 2),
      _openAuthGate,
    );
  }

  // ===========================================================
  // Authentication Routing
  // Replaces the splash screen with the authentication gate.
  // ===========================================================
  void _openAuthGate() {
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const AuthGate(),
      ),
    );
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          // ===========================================================
          // Application Branding
          // Displays the Siah logo while the application starts.
          // ===========================================================
          child: SiahLogo(
            height: 180,
          ),
        ),
      ),
    );
  }
}
