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
    return Scaffold(
      body: Container(
        // ===========================================================
        // Opening Wash
        // Light, not a full-strength gradient. The app opens onto
        // the same pale blue it uses everywhere, so the splash is
        // continuous with the first real screen rather than a dark
        // panel that flashes away.
        // ===========================================================
        decoration: const BoxDecoration(
          gradient: AppGradients.sky,
        ),
        child: const SafeArea(
          child: Center(
            child: SiahLogo(
              height: 180,
            ),
          ),
        ),
      ),
    );
  }
}
