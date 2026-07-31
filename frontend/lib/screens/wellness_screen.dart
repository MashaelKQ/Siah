import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../widgets/activity_card.dart';

class WellnessScreen extends StatelessWidget {
  const WellnessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ===========================================================
      // App Bar
      // Displays the standard title for the Wellness screen.
      // ===========================================================
      appBar: AppBar(
        title: const Text('Wellness'),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.regular),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===========================================================
              // Wellness Overview
              // Gives the user a quick summary of their wellbeing.
              // ===========================================================
              const Text(
                'Your Wellness',
                style: AppTextStyles.heading1,
              ),

              const SizedBox(height: AppSpacing.xSmall),

              const Text(
                'A simple overview of your recent wellbeing activity.',
                style: AppTextStyles.body,
              ),

              const SizedBox(height: AppSpacing.large),

              // ===========================================================
              // Weekly Progress
              // Shows how many wellness activities were completed this week.
              // ===========================================================
              const Text(
                'Weekly Progress',
                style: AppTextStyles.heading2,
              ),

              const SizedBox(height: AppSpacing.medium),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.regular),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '3 of 5 activities completed',
                        style: AppTextStyles.title,
                      ),
                      const SizedBox(height: AppSpacing.medium),
                      const LinearProgressIndicator(
                        value: 0.6,
                      ),
                      const SizedBox(height: AppSpacing.small),
                      const Text(
                        'Keep going — you are making steady progress.',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.large),

              // ===========================================================
              // Wellness Activities
              // Provides quick access to the user's wellbeing activities.
              // ===========================================================
              const Text(
                'Wellness Activities',
                style: AppTextStyles.heading2,
              ),

              const SizedBox(height: AppSpacing.medium),

              ActivityCard(
                title: 'Breathing Exercise',
                subtitle: 'Take a short guided breathing session.',
                icon: Icons.air,
                color: AppColors.blue40,
                onTap: () {},
              ),

              const SizedBox(height: AppSpacing.medium),

              ActivityCard(
                title: 'Mindful Moment',
                subtitle: 'Pause and focus on the present moment.',
                icon: Icons.self_improvement,
                color: AppColors.green40,
                onTap: () {},
              ),

              const SizedBox(height: AppSpacing.medium),

              ActivityCard(
                title: 'View Insights',
                subtitle: 'Review your recent wellbeing progress.',
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
