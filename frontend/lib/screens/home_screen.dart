import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/mood_check_in.dart';
import '../widgets/ui_kit.dart';
import '../widgets/wellbeing_dashboard.dart';
import 'live_coach_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    this.onOpenJournal,
    this.onOpenWellness,
    super.key,
  });

  final VoidCallback? onOpenJournal;
  final VoidCallback? onOpenWellness;

  // ===========================================================
  // Greeting
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
  // ===========================================================
  IconData _getGreetingIcon() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return Icons.wb_twilight_outlined;
    }

    if (hour < 17) {
      return Icons.light_mode_outlined;
    }

    return Icons.dark_mode_outlined;
  }

  // ===========================================================
  // Date
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
            16,
            6,
            16,
            92,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // =====================================================
              // Welcome Header
              // =====================================================
              GradientSurface(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ===============================================
                    // Date Row
                    // ===============================================
                    Row(
                      children: [
                        Icon(
                          _getGreetingIcon(),
                          size: 17,
                          color: Colors.white,
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Expanded(
                          child: Text(
                            currentDate,
                            style: AppTextStyles.bodyOnBrand.copyWith(
                              fontSize: 13,
                              height: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 14,
                    ),

                    // ===============================================
                    // Greeting
                    // ===============================================
                    Text(
                      '$greeting,',
                      style: AppTextStyles.bodyOnBrand.copyWith(
                        fontSize: 14,
                        height: 1.2,
                      ),
                    ),

                    const SizedBox(
                      height: 3,
                    ),

                    // ===============================================
                    // User Name
                    // ===============================================
                    Text(
                      userName,
                      style: AppTextStyles.displayOnBrand.copyWith(
                        fontSize: 27,
                        height: 1.05,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 10,
              ),

              // =====================================================
              // Weekly Wellbeing
              // =====================================================
              const WellbeingDashboard(),

              const SizedBox(
                height: 10,
              ),

              // =====================================================
              // Mood
              // =====================================================
              const MoodCheckIn(),

              const SizedBox(
                height: 11,
              ),

              // =====================================================
              // Quick Access
              // =====================================================
              Text(
                'Quick Access',
                style: AppTextStyles.heading2.copyWith(
                  fontSize: 19,
                ),
              ),

              const SizedBox(
                height: 8,
              ),

              // =====================================================
              // Live Coach Sessions
              // =====================================================
              _CompactActivityCard(
                title: 'Live Coach Sessions',
                subtitle: 'Join guided sessions with a wellness coach.',
                icon: Icons.support_agent_outlined,
                color: AppColors.blue40,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LiveCoachScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(
                height: 7,
              ),

              // =====================================================
              // Daily Journal
              // =====================================================
              _CompactActivityCard(
                title: 'Daily Journal',
                subtitle: 'Capture your thoughts and feelings.',
                icon: Icons.edit_outlined,
                color: AppColors.green40,
                onTap: onOpenJournal ?? () {},
              ),

              const SizedBox(
                height: 7,
              ),

              // =====================================================
              // Wellness Insight
              // =====================================================
              _CompactActivityCard(
                title: 'Wellness Insight',
                subtitle: 'View your wellness progress.',
                icon: Icons.show_chart,
                color: AppColors.yellow40,
                onTap: onOpenWellness ?? () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =====================================================================
// Compact Activity Card
// =====================================================================
class _CompactActivityCard extends StatelessWidget {
  const _CompactActivityCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(
        18,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(
          18,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 9,
          ),
          child: Row(
            children: [
              // Icon box
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(
                    12,
                  ),
                ),
                child: Icon(
                  icon,
                  size: 21,
                ),
              ),

              const SizedBox(
                width: 11,
              ),

              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.title.copyWith(
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    Text(
                      subtitle,
                      style: AppTextStyles.caption.copyWith(
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              const SizedBox(
                width: 6,
              ),

              const Icon(
                Icons.chevron_right,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
