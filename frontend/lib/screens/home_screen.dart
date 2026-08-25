import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../widgets/activity_card.dart';
import '../widgets/ui_kit.dart';
import '../widgets/mood_check_in.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    this.onOpenJournal,
    super.key,
  });

  // ===========================================================
  // Tab Switching
  // The Journal lives in the navigation stack, not on a route,
  // so opening it means switching tab rather than pushing a
  // screen. MainNavigationScreen supplies this.
  // ===========================================================
  final VoidCallback? onOpenJournal;

  // ===========================================================
  // Time-Based Greeting
  // Returns a greeting based on the current device time.
  // ===========================================================
  String _getGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return 'Good Morning';
    }

    if (hour < 17) {
      return 'Good Afternoon';
    }

    return 'Good Evening';
  }

  // ===========================================================
  // Greeting Icon
  // A small detail that makes the header feel like it belongs
  // to this moment rather than any moment.
  // ===========================================================
  IconData _getGreetingIcon() {
    final hour = DateTime.now().hour;

    if (hour < 12) return Icons.wb_twilight_outlined;
    if (hour < 17) return Icons.light_mode_outlined;

    return Icons.dark_mode_outlined;
  }

  // ===========================================================
  // Current Date
  // Formats today's date without requiring an extra package.
  // ===========================================================
  String _getFormattedDate() {
    final today = DateTime.now();

    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    final weekday = weekdays[today.weekday - 1];
    final month = months[today.month - 1];

    return '$weekday, $month ${today.day}';
  }

  // ===========================================================
  // User Name
  // Returns the authenticated user's display name.
  // ===========================================================
  String _getUserName() {
    final user = AuthService.currentUser;
    final displayName = user?.displayName?.trim();

    if (displayName != null && displayName.isNotEmpty) {
      return displayName;
    }

    final email = user?.email;

    if (email != null && email.contains('@')) {
      return email.split('@').first;
    }

    return 'there';
  }

  @override
  Widget build(BuildContext context) {
    final greeting = _getGreeting();
    final userName = _getUserName();
    final currentDate = _getFormattedDate();

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.regular,
            AppSpacing.small,
            AppSpacing.regular,
            AppSpacing.xxLarge,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===========================================================
              // Welcome Header
              // The one gradient element on this screen. It anchors the
              // page and gives the app its identity in the first second.
              // ===========================================================
              GradientSurface(
                padding: const EdgeInsets.all(AppSpacing.large),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _getGreetingIcon(),
                          size: 18,
                          color: Colors.white,
                        ),
                        const SizedBox(width: AppSpacing.small),
                        Text(
                          currentDate,
                          style: AppTextStyles.bodyOnBrand,
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.regular),

                    Text(
                      '$greeting,',
                      style: AppTextStyles.bodyOnBrand,
                    ),

                    const SizedBox(height: AppSpacing.xSmall),

                    Text(
                      userName,
                      style: AppTextStyles.displayOnBrand,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.large),

              // ===========================================================
              // Mood Check-In
              // Records the user's emotional state in Cloud Firestore.
              // The card keeps its own state so this screen does not
              // need to become a StatefulWidget.
              // ===========================================================
              const MoodCheckIn(),

              const SizedBox(height: AppSpacing.large),

              // ===========================================================
              // Today's Activities
              // Displays the wellbeing activities available to the user.
              // ===========================================================
              const Text(
                'Today’s Activities',
                style: AppTextStyles.heading2,
              ),

              const SizedBox(height: AppSpacing.medium),

              ActivityCard(
                title: 'Breathing Session',
                subtitle: 'Take a short guided breathing break.',
                icon: Icons.air_outlined,
                color: AppColors.blue40,
                onTap: () {},
              ),

              const SizedBox(height: AppSpacing.medium),

              ActivityCard(
                title: 'Daily Journal',
                subtitle: 'Write down your thoughts and feelings.',
                icon: Icons.edit_outlined,
                color: AppColors.green40,
                onTap: onOpenJournal ?? () {},
              ),

              const SizedBox(height: AppSpacing.medium),

              ActivityCard(
                title: 'Wellness Insight',
                subtitle: 'View your latest wellbeing progress.',
                icon: Icons.show_chart,
                color: AppColors.yellow40,
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
