import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../widgets/activity_card.dart';
import '../widgets/mood_option.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ===========================================================
      // App Bar
      // Displays the standard screen title using Flutter's AppBar.
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
              // Greets the user and introduces the daily check-in.
              // ===========================================================
              const Text(
                'Hello, Nourah!',
                style: AppTextStyles.heading1,
              ),

              const SizedBox(height: AppSpacing.xSmall),

              const Text(
                'Daily check-in',
                style: AppTextStyles.caption,
              ),

              const SizedBox(height: AppSpacing.large),

              // ===========================================================
              // Mood Check-in
              // Allows the user to choose their current emotional state.
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
              // Displays the main wellbeing activities available today.
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
