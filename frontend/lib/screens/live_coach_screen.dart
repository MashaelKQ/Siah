import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class LiveCoachScreen extends StatelessWidget {
  const LiveCoachScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final sessions = [
      const _CoachSession(
        title: 'Stress Reset',
        description:
            'Reset after a stressful day with guided relaxation and simple coping techniques.',
        duration: '20 min',
        category: 'Stress',
        icon: Icons.self_improvement_outlined,
      ),
      const _CoachSession(
        title: 'Sleep Better',
        description:
            'Learn practical habits that can support a calmer and more consistent sleep routine.',
        duration: '25 min',
        category: 'Sleep',
        icon: Icons.nightlight_outlined,
      ),
      const _CoachSession(
        title: 'Mindful Focus',
        description:
            'Practice techniques designed to improve focus and reduce mental overload.',
        duration: '15 min',
        category: 'Focus',
        icon: Icons.psychology_alt_outlined,
      ),
      const _CoachSession(
        title: 'Energy & Movement',
        description:
            'Build more movement into your day through a light guided wellness session.',
        duration: '20 min',
        category: 'Activity',
        icon: Icons.directions_walk_outlined,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Live Coach Sessions',
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            16,
            10,
            16,
            24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // =====================================================
              // Page Header
              // =====================================================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(
                  16,
                ),
                decoration: BoxDecoration(
                  color: AppColors.blue40,
                  borderRadius: BorderRadius.circular(
                    22,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      height: 48,
                      width: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(
                          alpha: 0.55,
                        ),
                        borderRadius: BorderRadius.circular(
                          14,
                        ),
                      ),
                      child: const Icon(
                        Icons.support_agent_outlined,
                        size: 25,
                      ),
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Live Wellness Coaching',
                            style: AppTextStyles.title,
                          ),
                          SizedBox(
                            height: 3,
                          ),
                          Text(
                            'Join guided sessions to support your wellbeing.',
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 18,
              ),

              // =====================================================
              // Section Header
              // =====================================================
              const Text(
                'Available Sessions',
                style: AppTextStyles.heading2,
              ),

              const SizedBox(
                height: 4,
              ),

              const Text(
                'Choose a session based on what you need today.',
                style: AppTextStyles.caption,
              ),

              const SizedBox(
                height: 12,
              ),

              // =====================================================
              // Sessions
              // =====================================================
              Expanded(
                child: ListView.separated(
                  itemCount: sessions.length,
                  separatorBuilder: (
                    context,
                    index,
                  ) {
                    return const SizedBox(
                      height: 9,
                    );
                  },
                  itemBuilder: (
                    context,
                    index,
                  ) {
                    final session = sessions[index];

                    return _CoachSessionCard(
                      session: session,
                      onTap: () {
                        _openSessionDetails(
                          context,
                          session,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================
  // Session Details
  // ===========================================================
  static void _openSessionDetails(
    BuildContext context,
    _CoachSession session,
  ) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              4,
              20,
              24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: AppColors.blue40,
                    borderRadius: BorderRadius.circular(
                      14,
                    ),
                  ),
                  child: Icon(
                    session.icon,
                    size: 25,
                  ),
                ),

                const SizedBox(
                  height: 12,
                ),

                Text(
                  session.title,
                  style: AppTextStyles.heading2,
                ),

                const SizedBox(
                  height: 5,
                ),

                Text(
                  '${session.category} • ${session.duration}',
                  style: AppTextStyles.caption,
                ),

                const SizedBox(
                  height: 12,
                ),

                Text(
                  session.description,
                  style: AppTextStyles.body,
                ),

                const SizedBox(
                  height: 18,
                ),

                // ===============================================
                // Coach
                // ===============================================
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(
                    12,
                  ),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(
                      14,
                    ),
                  ),
                  child: const Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        child: Icon(
                          Icons.person_outline,
                          size: 19,
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Wellness Coach',
                              style: AppTextStyles.title,
                            ),
                            SizedBox(
                              height: 2,
                            ),
                            Text(
                              'Guided wellbeing session',
                              style: AppTextStyles.caption,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  height: 18,
                ),

                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(
                        context,
                      );

                      _showBookingMessage(
                        context,
                      );
                    },
                    icon: const Icon(
                      Icons.calendar_month_outlined,
                    ),
                    label: const Text(
                      'Book Session',
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ===========================================================
  // Booking Placeholder
  // ===========================================================
  static void _showBookingMessage(
    BuildContext context,
  ) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              4,
              20,
              24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.video_call_outlined,
                  size: 42,
                ),
                const SizedBox(
                  height: 12,
                ),
                const Text(
                  'Booking Coming Soon',
                  style: AppTextStyles.heading2,
                ),
                const SizedBox(
                  height: 5,
                ),
                const Text(
                  'Live coach scheduling will be available here once coach availability is connected.',
                  style: AppTextStyles.caption,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 18,
                ),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      Navigator.pop(
                        context,
                      );
                    },
                    child: const Text(
                      'Done',
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// =====================================================================
// Coach Session Card
// =====================================================================
class _CoachSessionCard extends StatelessWidget {
  const _CoachSessionCard({
    required this.session,
    required this.onTap,
  });

  final _CoachSession session;
  final VoidCallback onTap;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(
          18,
        ),
        child: Padding(
          padding: const EdgeInsets.all(
            13,
          ),
          child: Row(
            children: [
              // Icon
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(
                    14,
                  ),
                ),
                child: Icon(
                  session.icon,
                  size: 23,
                ),
              ),

              const SizedBox(
                width: 12,
              ),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.title,
                      style: AppTextStyles.title.copyWith(
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(
                      height: 3,
                    ),
                    Text(
                      session.description,
                      style: AppTextStyles.caption.copyWith(
                        fontSize: 11,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(
                      height: 6,
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(
                              20,
                            ),
                          ),
                          child: Text(
                            session.category,
                            style: AppTextStyles.small.copyWith(
                              fontSize: 10,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        const Icon(
                          Icons.schedule_outlined,
                          size: 13,
                        ),
                        const SizedBox(
                          width: 3,
                        ),
                        Text(
                          session.duration,
                          style: AppTextStyles.small.copyWith(
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(
                width: 7,
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

// =====================================================================
// Session Data
// =====================================================================
class _CoachSession {
  const _CoachSession({
    required this.title,
    required this.description,
    required this.duration,
    required this.category,
    required this.icon,
  });

  final String title;
  final String description;
  final String duration;
  final String category;
  final IconData icon;
}
