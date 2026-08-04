import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // ===========================================================
  // Sign Out
  // Ends the current Firebase session through AuthService.
  // AuthGate automatically redirects the user to Login.
  // ===========================================================
  Future<void> _signOut() async {
    await AuthService.signOut();
  }

  @override
  Widget build(BuildContext context) {
    // ===========================================================
    // Current User
    // Retrieves the currently authenticated user through AuthService.
    // ===========================================================
    final user = AuthService.currentUser;

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
              // Signs the current user out through AuthService.
              // ===========================================================
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _signOut,
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
