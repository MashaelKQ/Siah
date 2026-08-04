import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../widgets/activity_card.dart';
import '../widgets/mood_option.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
      // ===========================================================
      // App Bar
      // Displays the standard application title.
      // ===========================================================
      appBar: AppBar(
        title: const Text('Siah'),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.regular),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===========================================================
              // Welcome Section
              // Greets the authenticated user using the current time.
              // ===========================================================
              Text(
                '$greeting, $userName!',
                style: AppTextStyles.heading1,
              ),

              const SizedBox(height: AppSpacing.xSmall),

              Text(
                currentDate,
                style: AppTextStyles.caption,
              ),

              const SizedBox(height: AppSpacing.large),

              // ===========================================================
              // Mood Check-In
              // Allows the user to select their current emotional state.
              // Mood saving will be connected to Firestore later.
              // ===========================================================
              const Text(
                'How are you feeling right now?',
                style: AppTextStyles.title,
              ),

              const SizedBox(height: AppSpacing.medium),

              Row(
                children: [
                  Expanded(
                    child: MoodOption(
                      icon: Icons.sentiment_very_satisfied,
                      label: 'Happy',
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(width: AppSpacing.small),
                  Expanded(
                    child: MoodOption(
                      icon: Icons.sentiment_neutral,
                      label: 'Okay',
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(width: AppSpacing.small),
                  Expanded(
                    child: MoodOption(
                      icon: Icons.sentiment_dissatisfied,
                      label: 'Low',
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(width: AppSpacing.small),
                  Expanded(
                    child: MoodOption(
                      icon: Icons.bolt,
                      label: 'Stressed',
                      onTap: () {},
                    ),
                  ),
                ],
              ),

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
                icon: Icons.air,
                color: AppColors.blue40,
                onTap: () {},
              ),

              const SizedBox(height: AppSpacing.medium),

              ActivityCard(
                title: 'Daily Journal',
                subtitle: 'Write down your thoughts and feelings.',
                icon: Icons.edit_note,
                color: AppColors.green40,
                onTap: () {},
              ),

              const SizedBox(height: AppSpacing.medium),

              ActivityCard(
                title: 'Wellness Insight',
                subtitle: 'View your latest wellbeing progress.',
                icon: Icons.insights,
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
