import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../widgets/loading_indicator.dart';
import 'login_screen.dart';
import 'main_navigation_screen.dart';
import 'onboarding_screen.dart';

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

        // Signed in: the profile decides whether the onboarding
        // questions still need answering.
        //
        // The key matters. Without it, signing out and into a
        // different account reuses the same State object, so
        // initState never runs again and the new user inherits
        // the previous user's answer.
        final user = snapshot.data;

        if (user != null) {
          return _OnboardingGate(
            key: ValueKey(user.uid),
            userId: user.uid,
          );
        }

        // Show login when there is no signed-in user.
        return const LoginScreen();
      },
    );
  }
}

// ===========================================================
// Onboarding Gate
//
// Sits between sign-in and the app, and sends anyone without a
// completed onboarding record through the questions first.
//
// Note this applies to accounts created before onboarding
// existed: they have no completion date, so they will be asked
// once on next launch. That is intended, but it does mean your
// existing test accounts will see the questions.
//
// A profile that cannot be read is treated as complete. Being
// unable to reach Firestore should not trap someone in a form
// they cannot submit either.
// ===========================================================
class _OnboardingGate extends StatefulWidget {
  const _OnboardingGate({
    required this.userId,
    super.key,
  });

  final String userId;

  @override
  State<_OnboardingGate> createState() => _OnboardingGateState();
}

class _OnboardingGateState extends State<_OnboardingGate> {
  bool _isLoading = true;
  bool _needsOnboarding = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    try {
      // Right after sign-up the account exists before its profile
      // document has finished writing, so a first read can come
      // back empty. A couple of quick retries covers that without
      // making an established user wait.
      AppUser? profile;

      for (var attempt = 0; attempt < 3; attempt++) {
        profile = await UserService.getUser(widget.userId);

        if (profile != null) break;

        await Future<void>.delayed(const Duration(milliseconds: 400));
      }

      if (!mounted) return;

      setState(() {
        // No profile at all also means no onboarding. Treating a
        // missing document as "complete" is what let a brand new
        // account slip straight past the questions.
        _needsOnboarding =
            profile == null || !profile.hasCompletedOnboarding;
        _isLoading = false;
        _failed = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _failed = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: LoadingIndicator()),
      );
    }

    if (_failed) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.large),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Could not load your profile.',
                  style: AppTextStyles.title,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.small),
                const Text(
                  'Check your connection and try again.',
                  style: AppTextStyles.caption,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.large),
                FilledButton(
                  onPressed: () {
                    setState(() => _isLoading = true);
                    _check();
                  },
                  child: const Text('Try Again'),
                ),
                TextButton(
                  onPressed: AuthService.signOut,
                  child: const Text('Sign Out'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_needsOnboarding) {
      return OnboardingScreen(
        onCompleted: () {
          setState(() {
            _needsOnboarding = false;
          });
        },
      );
    }

    return const MainNavigationScreen();
  }
}
