import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
              // Displays the user's basic profile details.
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

              const Center(
                child: Text(
                  'Nourah',
                  style: AppTextStyles.heading1,
                ),
              ),

              const SizedBox(height: AppSpacing.xSmall),

              const Center(
                child: Text(
                  'nourah@example.com',
                  style: AppTextStyles.caption,
                ),
              ),

              const SizedBox(height: AppSpacing.large),

              // ===========================================================
              // Profile Options
              // Provides access to account and application settings.
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
              // Allows the user to leave their account.
              // ===========================================================
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {},
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
