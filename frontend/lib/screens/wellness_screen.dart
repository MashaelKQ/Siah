import 'package:flutter/material.dart';

import '../models/habit_quest.dart';
import '../models/wellness_assessment.dart';
import '../services/auth_service.dart';
import '../services/weekly_quest_service.dart';
import '../services/wellness_service.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../widgets/loading_indicator.dart';
import 'wellness_survey_screen.dart';
import 'wellness_trend_screen.dart';

class WellnessScreen extends StatefulWidget {
  const WellnessScreen({super.key});

  @override
  State<WellnessScreen> createState() => _WellnessScreenState();
}

class _WellnessScreenState extends State<WellnessScreen> {
  Future<WellnessAssessment?>? _assessmentFuture;
  Future<List<HabitQuest>>? _weeklyQuestsFuture;

  bool _isUpdatingQuest = false;

  @override
  void initState() {
    super.initState();
    _loadWellnessData();
  }

  // ===========================================================
  // Load Wellness Data
  // ===========================================================
  void _loadWellnessData() {
    final user = AuthService.currentUser;

    if (user == null) {
      _assessmentFuture = Future.value(null);
      _weeklyQuestsFuture = Future.value([]);
      return;
    }

    _assessmentFuture = WellnessService.getCurrentMonthAssessment(user.uid);

    _weeklyQuestsFuture = WeeklyQuestService.getCurrentWeeklyPlan(user.uid);
  }

  // ===========================================================
  // Refresh Weekly Quests
  // ===========================================================
  void _refreshWeeklyQuests() {
    final user = AuthService.currentUser;

    if (user == null) {
      _weeklyQuestsFuture = Future.value([]);
      return;
    }

    _weeklyQuestsFuture = WeeklyQuestService.getCurrentWeeklyPlan(user.uid);
  }

  // ===========================================================
  // Open Survey
  // ===========================================================
  Future<void> _openSurvey() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const WellnessSurveyScreen(),
      ),
    );

    if (!mounted) return;

    setState(() {
      _loadWellnessData();
    });
  }

  // ===========================================================
  // Open Trends
  // ===========================================================
  void _openTrends() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const WellnessTrendScreen(),
      ),
    );
  }

  // ===========================================================
  // Month Name
  // ===========================================================
  String _monthName(int month) {
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

    if (month < 1 || month > 12) {
      return '';
    }

    return months[month - 1];
  }

  // ===========================================================
  // Complete / Undo Quest Today
  // ===========================================================
  Future<void> _toggleQuestToday(
    HabitQuest quest,
  ) async {
    if (_isUpdatingQuest) return;

    final user = AuthService.currentUser;

    if (user == null) return;

    final today = WeeklyQuestService.dateId(DateTime.now());

    final completedToday = quest.completedDates.contains(today);

    setState(() {
      _isUpdatingQuest = true;
    });

    try {
      if (completedToday) {
        await WeeklyQuestService.undoQuestToday(
          userId: user.uid,
          questId: quest.id,
        );
      } else {
        await WeeklyQuestService.completeQuestToday(
          userId: user.uid,
          questId: quest.id,
        );
      }

      if (!mounted) return;

      setState(() {
        _refreshWeeklyQuests();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingQuest = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wellness'),
      ),
      body: SafeArea(
        child: FutureBuilder<WellnessAssessment?>(
          future: _assessmentFuture,
          builder: (context, assessmentSnapshot) {
            if (assessmentSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: LoadingIndicator(),
              );
            }

            if (assessmentSnapshot.hasError) {
              return _ErrorState(
                onRetry: () {
                  setState(() {
                    _loadWellnessData();
                  });
                },
              );
            }

            final assessment = assessmentSnapshot.data;

            return FutureBuilder<List<HabitQuest>>(
              future: _weeklyQuestsFuture,
              builder: (context, questSnapshot) {
                if (questSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: LoadingIndicator(),
                  );
                }

                if (questSnapshot.hasError) {
                  return _ErrorState(
                    onRetry: () {
                      setState(() {
                        _loadWellnessData();
                      });
                    },
                  );
                }

                final weeklyQuests = questSnapshot.data ?? [];

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.regular,
                    AppSpacing.medium,
                    AppSpacing.regular,
                    120,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (assessment != null)
                        _CompactAssessmentCard(
                          assessment: assessment,
                          monthName: _monthName(assessment.month),
                          onViewTrends: _openTrends,
                        )
                      else
                        _IncompleteAssessmentCard(
                          onStartAssessment: _openSurvey,
                          onViewTrends: _openTrends,
                        ),
                      if (weeklyQuests.isNotEmpty) ...[
                        const SizedBox(
                          height: AppSpacing.medium,
                        ),
                        const Text(
                          'Weekly Wellness Quests',
                          style: AppTextStyles.heading2,
                        ),
                        const SizedBox(
                          height: AppSpacing.xSmall,
                        ),
                        const Text(
                          'Improve your wellness by completing the quests below.',
                          style: AppTextStyles.caption,
                        ),
                        const SizedBox(
                          height: AppSpacing.small,
                        ),
                        for (final quest in weeklyQuests) ...[
                          _CompactQuestTile(
                            quest: quest,
                            enabled: !_isUpdatingQuest,
                            onTap: () => _toggleQuestToday(quest),
                          ),
                          const SizedBox(
                            height: AppSpacing.xSmall,
                          ),
                        ],
                      ],
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

// =====================================================================
// Compact Assessment Card
// =====================================================================
class _CompactAssessmentCard extends StatelessWidget {
  const _CompactAssessmentCard({
    required this.assessment,
    required this.monthName,
    required this.onViewTrends,
  });

  final WellnessAssessment assessment;
  final String monthName;
  final VoidCallback onViewTrends;

  Color _scoreColor(BuildContext context) {
    if (assessment.score <= 3) {
      return Colors.green;
    }

    if (assessment.score <= 7) {
      return Theme.of(context).colorScheme.primary;
    }

    return Colors.amber.shade700;
  }

  String _scoreLabel() {
    if (assessment.score <= 3) {
      return 'Low distress';
    }

    if (assessment.score <= 7) {
      return 'Moderate distress';
    }

    return 'Elevated distress';
  }

  String _scoreMessage() {
    if (assessment.score <= 3) {
      return 'Few signs of psychological distress.';
    }

    if (assessment.score <= 7) {
      return 'Some signs of psychological distress.';
    }

    return 'Higher signs of psychological distress.';
  }

  @override
  Widget build(BuildContext context) {
    final scoreColor = _scoreColor(context);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(
          AppSpacing.medium,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===========================================================
            // Header
            // ===========================================================
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(
                  child: Text(
                    'Monthly Wellness Check',
                    style: AppTextStyles.heading2,
                  ),
                ),
                const SizedBox(
                  width: AppSpacing.small,
                ),
                IntrinsicWidth(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 34),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: onViewTrends,
                    icon: const Icon(
                      Icons.show_chart,
                      size: 15,
                    ),
                    label: const Text(
                      'Trends',
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: AppSpacing.medium,
            ),

            // ===========================================================
            // Score
            // ===========================================================
            Text(
              '${assessment.score} / 12',
              style: AppTextStyles.heading1,
            ),

            const SizedBox(
              height: AppSpacing.small,
            ),

            // ===========================================================
            // Status
            // ===========================================================
            Text(
              _scoreLabel(),
              style: AppTextStyles.title.copyWith(
                color: scoreColor,
              ),
            ),

            const SizedBox(
              height: AppSpacing.xSmall,
            ),

            Text(
              _scoreMessage(),
              style: AppTextStyles.caption,
            ),

            const SizedBox(
              height: AppSpacing.small,
            ),

            Text(
              'Completed • $monthName ${assessment.year}',
              style: AppTextStyles.caption,
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================================
// Compact Quest Tile
// =====================================================================
class _CompactQuestTile extends StatelessWidget {
  const _CompactQuestTile({
    required this.quest,
    required this.enabled,
    required this.onTap,
  });

  final HabitQuest quest;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final today = WeeklyQuestService.dateId(DateTime.now());

    final completedToday = quest.completedDates.contains(today);

    final targetReached = quest.isCompleted;

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: enabled && (!targetReached || completedToday) ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.medium,
            vertical: AppSpacing.small,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Checkbox(
                value: completedToday || targetReached,
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                onChanged: enabled && (!targetReached || completedToday)
                    ? (_) => onTap()
                    : null,
              ),
              const SizedBox(
                width: AppSpacing.small,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quest.title,
                      style: AppTextStyles.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    Text(
                      quest.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption,
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    Text(
                      targetReached
                          ? 'Completed this week'
                          : completedToday
                              ? 'Done today • '
                                  '${quest.completedCount}/${quest.targetCount}'
                              : '${quest.completedCount}/${quest.targetCount} this week',
                      style: AppTextStyles.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =====================================================================
// Incomplete Assessment
// =====================================================================
class _IncompleteAssessmentCard extends StatelessWidget {
  const _IncompleteAssessmentCard({
    required this.onStartAssessment,
    required this.onViewTrends,
  });

  final VoidCallback onStartAssessment;
  final VoidCallback onViewTrends;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(
          AppSpacing.medium,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Current Wellness Score',
              style: AppTextStyles.heading2,
            ),
            const SizedBox(
              height: AppSpacing.medium,
            ),
            const Text(
              'Not completed this month',
              style: AppTextStyles.title,
            ),
            const SizedBox(
              height: AppSpacing.xSmall,
            ),
            const Text(
              'Complete your monthly wellness check to view your score.',
              style: AppTextStyles.caption,
            ),
            const SizedBox(
              height: AppSpacing.medium,
            ),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onStartAssessment,
                icon: const Icon(
                  Icons.assignment_outlined,
                ),
                label: const Text(
                  'Start Assessment',
                ),
              ),
            ),
            const SizedBox(
              height: AppSpacing.small,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: IntrinsicWidth(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 34),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: onViewTrends,
                  icon: const Icon(
                    Icons.show_chart,
                    size: 16,
                  ),
                  label: const Text(
                    'Previous Trends',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================================
// Error State
// =====================================================================
class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.onRetry,
  });

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(
          AppSpacing.regular,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Unable to load your wellness information.',
              style: AppTextStyles.body,
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: AppSpacing.medium,
            ),
            FilledButton(
              onPressed: onRetry,
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
