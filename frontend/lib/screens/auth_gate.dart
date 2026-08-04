import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'login_screen.dart';
import 'main_navigation_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      // Listens for sign-in and sign-out changes.
      stream: AuthService.authStateChanges,

      builder: (context, snapshot) {
        // Wait while Firebase restores the saved session.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Show the main app when the user is signed in.
        if (snapshot.hasData) {
          return const MainNavigationScreen();
        }

        // Show login when there is no signed-in user.
        return const LoginScreen();
      },
    );
  }
}
