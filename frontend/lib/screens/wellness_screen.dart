import 'package:flutter/material.dart';

import '../models/habit_quest.dart';
import '../models/wellness_assessment.dart';
import '../services/auth_service.dart';
import '../services/weekly_quest_service.dart';
import '../services/wellness_service.dart';
import '../theme/app_text_styles.dart';
import '../utils/snackbar_helper.dart';
import '../widgets/loading_indicator.dart';
import 'rewards_screen.dart';
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
  // Open Rewards
  // ===========================================================
  void _openRewards() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RewardsScreen(),
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
  // Complete / Undo Quest
  // ===========================================================
  Future<void> _toggleQuest(
    HabitQuest quest,
  ) async {
    if (_isUpdatingQuest) return;

    final user = AuthService.currentUser;

    if (user == null) return;

    setState(() {
      _isUpdatingQuest = true;
    });

    try {
      if (quest.isCompleted) {
        await WeeklyQuestService.undoQuest(
          userId: user.uid,
          questId: quest.id,
        );

        if (!mounted) return;

        SnackbarHelper.show(
          context,
          'Quest marked incomplete. 1 point removed.',
        );
      } else {
        await WeeklyQuestService.completeQuest(
          userId: user.uid,
          questId: quest.id,
        );

        if (!mounted) return;

        SnackbarHelper.show(
          context,
          '+1 Wellness Point',
        );
      }

      if (!mounted) return;

      setState(() {
        _refreshWeeklyQuests();
      });
    } catch (error) {
      if (!mounted) return;

      SnackbarHelper.show(
        context,
        'Unable to update quest.',
      );

      debugPrint(
        'Quest update error: $error',
      );
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
    final user = AuthService.currentUser;

    return Scaffold(
      // ===========================================================
      // Header
      // ===========================================================
      appBar: AppBar(
        title: const Text(
          'Wellness',
        ),
        centerTitle: true,
        actions: [
          if (user != null)
            StreamBuilder<int>(
              stream: WeeklyQuestService.wellnessPointsStream(
                user.uid,
              ),
              builder: (
                context,
                snapshot,
              ) {
                final points = snapshot.data ?? 0;

                return Padding(
                  padding: const EdgeInsets.only(
                    right: 16,
                  ),
                  child: Center(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(
                        20,
                      ),
                      onTap: _openRewards,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 11,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(
                            20,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.stars_rounded,
                              size: 17,
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Text(
                              '$points pts',
                              style: AppTextStyles.title.copyWith(
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(
                              width: 3,
                            ),
                            const Icon(
                              Icons.chevron_right,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),

      body: SafeArea(
        child: FutureBuilder<WellnessAssessment?>(
          future: _assessmentFuture,
          builder: (
            context,
            assessmentSnapshot,
          ) {
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
              builder: (
                context,
                questSnapshot,
              ) {
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

                final quests = questSnapshot.data ?? [];

                final completed = quests
                    .where(
                      (quest) => quest.isCompleted,
                    )
                    .length;

                return Padding(
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    8,
                    16,
                    100,
                  ),
                  child: Column(
                    children: [
                      // =============================================
                      // Monthly Wellness Check
                      // =============================================
                      if (assessment != null)
                        _MonthlyCheckCard(
                          assessment: assessment,
                          monthName: _monthName(
                            assessment.month,
                          ),
                          onViewTrends: _openTrends,
                        )
                      else
                        _StartAssessmentCard(
                          onTap: _openSurvey,
                        ),

                      const SizedBox(
                        height: 10,
                      ),

                      // =============================================
                      // Weekly Progress
                      // =============================================
                      _WeeklyProgressCard(
                        completed: completed,
                        total: quests.length,
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      // =============================================
                      // Weekly Quests
                      // =============================================
                      Expanded(
                        child: quests.isEmpty
                            ? _EmptyQuestState(
                                onStartAssessment: _openSurvey,
                              )
                            : Card(
                                margin: EdgeInsets.zero,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 2,
                                  ),
                                  child: ListView.separated(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: quests.length,
                                    separatorBuilder: (
                                      context,
                                      index,
                                    ) {
                                      return const Divider(
                                        height: 1,
                                      );
                                    },
                                    itemBuilder: (
                                      context,
                                      index,
                                    ) {
                                      final quest = quests[index];

                                      return _QuestRow(
                                        quest: quest,
                                        enabled: !_isUpdatingQuest,
                                        onTap: () => _toggleQuest(
                                          quest,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                      ),
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
// Monthly Wellness Check
// =====================================================================
class _MonthlyCheckCard extends StatelessWidget {
  const _MonthlyCheckCard({
    required this.assessment,
    required this.monthName,
    required this.onViewTrends,
  });

  final WellnessAssessment assessment;
  final String monthName;
  final VoidCallback onViewTrends;

  String _scoreLabel() {
    if (assessment.score <= 3) {
      return 'Low distress';
    }

    if (assessment.score <= 7) {
      return 'Moderate distress';
    }

    return 'Elevated distress';
  }

  String _scoreMeaning() {
    if (assessment.score <= 3) {
      return 'Few signs of psychological distress.';
    }

    if (assessment.score <= 7) {
      return 'Some signs of psychological distress are present.';
    }

    return 'More signs of psychological distress are present.';
  }

  Color _scoreColor() {
    if (assessment.score <= 3) {
      return Colors.green;
    }

    if (assessment.score <= 7) {
      return Colors.green;
    }

    return Colors.orange;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Monthly Wellness Check',
              style: AppTextStyles.title,
            ),

            const SizedBox(
              height: 10,
            ),

            // =====================================================
            // Score + Meaning
            // =====================================================
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '${assessment.score} / 12',
                  style: AppTextStyles.heading1.copyWith(
                    fontSize: 28,
                  ),
                ),
                const SizedBox(
                  width: 14,
                ),
                Expanded(
                  child: Text(
                    _scoreLabel(),
                    style: AppTextStyles.title.copyWith(
                      color: _scoreColor(),
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 5,
            ),

            Text(
              _scoreMeaning(),
              style: AppTextStyles.caption.copyWith(
                fontSize: 11,
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            // =====================================================
            // Date + Trends
            // =====================================================
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 15,
                ),
                const SizedBox(
                  width: 6,
                ),
                Expanded(
                  child: Text(
                    '$monthName ${assessment.year}',
                    style: AppTextStyles.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TextButton.icon(
                  onPressed: onViewTrends,
                  icon: const Icon(
                    Icons.show_chart,
                    size: 16,
                  ),
                  label: const Text(
                    'View Trends',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================================
// Weekly Progress
// =====================================================================
class _WeeklyProgressCard extends StatelessWidget {
  const _WeeklyProgressCard({
    required this.completed,
    required this.total,
  });

  final int completed;
  final int total;

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : completed / total;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 10,
        ),
        child: Row(
          children: [
            Text(
              'Weekly Progress',
              style: AppTextStyles.title.copyWith(
                fontSize: 16,
              ),
            ),
            const SizedBox(
              width: 12,
            ),
            Expanded(
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 7,
                borderRadius: BorderRadius.circular(
                  10,
                ),
              ),
            ),
            const SizedBox(
              width: 12,
            ),
            Text(
              '$completed / $total',
              style: AppTextStyles.title.copyWith(
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================================
// Quest Row
// =====================================================================
class _QuestRow extends StatelessWidget {
  const _QuestRow({
    required this.quest,
    required this.enabled,
    required this.onTap,
  });

  final HabitQuest quest;
  final bool enabled;
  final VoidCallback onTap;

  // ===========================================================
  // Category Meaning
  // ===========================================================
  String _categoryMeaning() {
    final category = quest.category.toLowerCase();

    if (category.contains('sleep')) {
      return 'Improve sleep quality';
    }

    if (category.contains('gratitude')) {
      return 'Build a positive mindset';
    }

    if (category.contains('stress')) {
      return 'Reduce daily stress';
    }

    if (category.contains('mindful')) {
      return 'Calm and reset';
    }

    if (category.contains('physical') || category.contains('movement')) {
      return 'Boost energy';
    }

    if (category.contains('confidence')) {
      return 'Build confidence';
    }

    if (category.contains('coping')) {
      return 'Handle challenges';
    }

    if (category.contains('focus')) {
      return 'Improve focus';
    }

    if (category.contains('mood')) {
      return 'Support your mood';
    }

    if (category.contains('happiness')) {
      return 'Increase positive moments';
    }

    if (category.contains('purpose')) {
      return 'Create more meaning';
    }

    if (category.contains('social')) {
      return 'Strengthen connection';
    }

    if (category.contains('self-worth')) {
      return 'Build self-appreciation';
    }

    return 'Support wellbeing';
  }

  // ===========================================================
  // Show Full Quest Details
  // ===========================================================
  void _showQuestDetails(
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quest.title,
                  style: AppTextStyles.heading2,
                ),
                const SizedBox(
                  height: 6,
                ),
                Text(
                  '${quest.category} • ${_categoryMeaning()}',
                  style: AppTextStyles.caption,
                ),
                const SizedBox(
                  height: 14,
                ),
                Text(
                  quest.description,
                  style: AppTextStyles.body,
                ),
                const SizedBox(
                  height: 18,
                ),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: enabled
                        ? () {
                            Navigator.pop(
                              context,
                            );

                            onTap();
                          }
                        : null,
                    child: Text(
                      quest.isCompleted
                          ? 'Mark as Incomplete'
                          : 'Complete Quest • +1 Point',
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

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled
          ? () => _showQuestDetails(
                context,
              )
          : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 9,
        ),
        child: Row(
          children: [
            // =====================================================
            // Quest Information
            // =====================================================
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    quest.title,
                    style: AppTextStyles.title.copyWith(
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(
                    height: 3,
                  ),
                  Text(
                    '${quest.category} • ${_categoryMeaning()}',
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
              width: 8,
            ),

            // =====================================================
            // Point Indicator
            // =====================================================
            if (!quest.isCompleted)
              Text(
                '+1',
                style: AppTextStyles.caption.copyWith(
                  fontSize: 11,
                ),
              ),

            const SizedBox(
              width: 4,
            ),

            // =====================================================
            // Completion Checkbox
            // =====================================================
            Checkbox(
              value: quest.isCompleted,
              onChanged: enabled ? (_) => onTap() : null,
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================================
// Start Assessment Card
// =====================================================================
class _StartAssessmentCard extends StatelessWidget {
  const _StartAssessmentCard({
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        child: const Padding(
          padding: EdgeInsets.all(
            16,
          ),
          child: Row(
            children: [
              Icon(
                Icons.assignment_outlined,
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Monthly Wellness Check',
                      style: AppTextStyles.title,
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    Text(
                      'Tap to complete your monthly assessment.',
                      style: AppTextStyles.caption,
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
// Empty Quest State
// =====================================================================
class _EmptyQuestState extends StatelessWidget {
  const _EmptyQuestState({
    required this.onStartAssessment,
  });

  final VoidCallback onStartAssessment;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FilledButton(
        onPressed: onStartAssessment,
        child: const Text(
          'Complete Wellness Check',
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
      child: FilledButton(
        onPressed: onRetry,
        child: const Text(
          'Try Again',
        ),
      ),
    );
  }
}
