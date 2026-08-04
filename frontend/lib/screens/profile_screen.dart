import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // ===========================================================
  // Sign Out
  // Ends the current Firebase session and returns the user
  // to the Login screen.
  // ===========================================================
  Future<void> _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    // ===========================================================
    // Current User
    // Retrieves the currently authenticated Firebase user.
    // ===========================================================
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      // ===========================================================
      // App Bar
      // Displays the standard title for the Profile screen.
      // ===========================================================
      appBar: AppBar(
        title: const Text('Profile'),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.regular),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===========================================================
              // User Information
              // Displays the authenticated user's profile details.
              // ===========================================================
              const Center(
                child: CircleAvatar(
                  radius: 44,
                  child: Icon(
                    Icons.person_outline,
                    size: 44,
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.medium),

              Center(
                child: Text(
                  user?.displayName ?? 'User',
                  style: AppTextStyles.heading1,
                ),
              ),

              const SizedBox(height: AppSpacing.xSmall),

              Center(
                child: Text(
                  user?.email ?? '',
                  style: AppTextStyles.caption,
                ),
              ),

              const SizedBox(height: AppSpacing.large),

              // ===========================================================
              // Account Options
              // Provides access to profile and application settings.
              // ===========================================================
              const Text(
                'Account',
                style: AppTextStyles.heading2,
              ),

              const SizedBox(height: AppSpacing.medium),

              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('Personal Information'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),

              const Divider(),

              ListTile(
                leading: const Icon(Icons.lock_outline),
                title: const Text('Privacy and Security'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),

              const Divider(),

              ListTile(
                leading: const Icon(Icons.settings_outlined),
                title: const Text('Settings'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),

              const Divider(),

              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('About Siah'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),

              const Spacer(),

              // ===========================================================
              // Sign Out
              // Signs the current user out of Firebase Authentication.
              // ===========================================================
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _signOut(context),
                  icon: const Icon(Icons.logout),
                  label: const Text('Sign Out'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
