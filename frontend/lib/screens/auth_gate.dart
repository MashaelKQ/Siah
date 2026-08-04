import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'login_screen.dart';
import 'main_navigation_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      // ===========================================================
      // Authentication State
      // Listens for Firebase sign-in and sign-out changes.
      // ===========================================================
      stream: FirebaseAuth.instance.authStateChanges(),

      builder: (context, snapshot) {
        // ===========================================================
        // Loading State
        // Waits while Firebase restores the saved user session.
        // ===========================================================
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // ===========================================================
        // Signed-In User
        // Opens the main application when a user session exists.
        // ===========================================================
        if (snapshot.hasData) {
          return const MainNavigationScreen();
        }

        // ===========================================================
        // Signed-Out User
        // Opens the login screen when no user session exists.
        // ===========================================================
        return const LoginScreen();
      },
    );
  }
}
