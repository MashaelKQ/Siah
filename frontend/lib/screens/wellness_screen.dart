import 'package:flutter/material.dart';

import '../models/wellness_assessment.dart';
import '../services/auth_service.dart';
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

  @override
  void initState() {
    super.initState();
    _loadAssessment();
  }

  // ===========================================================
  // Load Assessment
  // Loads the user's assessment for the current month.
  // ===========================================================
  void _loadAssessment() {
    final user = AuthService.currentUser;

    if (user == null) {
      _assessmentFuture = Future.value(null);
      return;
    }

    _assessmentFuture = WellnessService.getCurrentMonthAssessment(user.uid);
  }

  // ===========================================================
  // Open Survey
  // Opens the monthly assessment and refreshes the score
  // when the user returns.
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
      _loadAssessment();
    });
  }

  // ===========================================================
  // Open Trends
  // Opens the user's previous wellness scores and trend chart.
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
  // Converts a numeric month into a readable month name.
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wellness'),
      ),
      body: SafeArea(
        child: FutureBuilder<WellnessAssessment?>(
          future: _assessmentFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: LoadingIndicator(),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.regular),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Unable to load your wellness information.',
                        style: AppTextStyles.body,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.medium),
                      FilledButton(
                        onPressed: () {
                          setState(() {
                            _loadAssessment();
                          });
                        },
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final assessment = snapshot.data;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.regular),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Wellness',
                    style: AppTextStyles.heading1,
                  ),
                  const SizedBox(height: AppSpacing.large),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.regular),
                      child: assessment != null
                          ? _CompletedAssessmentContent(
                              assessment: assessment,
                              monthName: _monthName(
                                assessment.month,
                              ),
                              onViewTrends: _openTrends,
                            )
                          : _IncompleteAssessmentContent(
                              onStartAssessment: _openSurvey,
                              onViewTrends: _openTrends,
                            ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// =====================================================================
// Completed Assessment
// =====================================================================
class _CompletedAssessmentContent extends StatelessWidget {
  const _CompletedAssessmentContent({
    required this.assessment,
    required this.monthName,
    required this.onViewTrends,
  });

  final WellnessAssessment assessment;
  final String monthName;
  final VoidCallback onViewTrends;

  // ===========================================================
  // Score Color
  // 0–3  = Green
  // 4–7  = Blue
  // 8–12 = Yellow
  // ===========================================================
  Color _scoreColor(BuildContext context) {
    final score = assessment.score;

    if (score <= 3) {
      return Colors.green;
    }

    if (score <= 7) {
      return Theme.of(context).colorScheme.primary;
    }

    return Colors.amber.shade700;
  }

  // ===========================================================
  // Score Label
  // ===========================================================
  String _scoreLabel() {
    final score = assessment.score;

    if (score <= 3) {
      return 'Low distress';
    }

    if (score <= 7) {
      return 'Moderate distress';
    }

    return 'High distress';
  }

  // ===========================================================
  // Score Message
  // ===========================================================
  String _scoreMessage() {
    final score = assessment.score;

    if (score <= 3) {
      return 'Your responses suggest relatively few signs of psychological distress.';
    }

    if (score <= 7) {
      return 'Your responses suggest some signs of psychological distress. Continue monitoring how you feel over time.';
    }

    return 'Your responses suggest a higher level of psychological distress. Consider giving extra attention to your wellbeing and seeking support if these feelings persist.';
  }

  @override
  Widget build(BuildContext context) {
    final scoreColor = _scoreColor(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Current Wellness Score',
          style: AppTextStyles.heading2,
        ),
        const SizedBox(height: AppSpacing.large),
        Row(
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 34,
              color: scoreColor,
            ),
            const SizedBox(width: AppSpacing.medium),
            Text(
              '${assessment.score} / 12',
              style: AppTextStyles.heading1,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.medium),
        Text(
          _scoreLabel(),
          style: AppTextStyles.title.copyWith(
            color: scoreColor,
          ),
        ),
        const SizedBox(height: AppSpacing.small),
        Text(
          _scoreMessage(),
          style: AppTextStyles.caption,
        ),
        const SizedBox(height: AppSpacing.large),
        Text(
          'Completed • $monthName ${assessment.year}',
          style: AppTextStyles.caption,
        ),
        const SizedBox(height: AppSpacing.large),
        Align(
          alignment: Alignment.centerRight,
          child: IntrinsicWidth(
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 40),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: onViewTrends,
              icon: const Icon(
                Icons.show_chart,
                size: 18,
              ),
              label: const Text(
                'View Trends',
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// =====================================================================
// Incomplete Assessment
// =====================================================================
class _IncompleteAssessmentContent extends StatelessWidget {
  const _IncompleteAssessmentContent({
    required this.onStartAssessment,
    required this.onViewTrends,
  });

  final VoidCallback onStartAssessment;
  final VoidCallback onViewTrends;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Current Wellness Score',
          style: AppTextStyles.heading2,
        ),
        const SizedBox(height: AppSpacing.large),
        const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.info_outline,
              size: 28,
            ),
            SizedBox(width: AppSpacing.medium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Not completed this month',
                    style: AppTextStyles.title,
                  ),
                  SizedBox(height: AppSpacing.xSmall),
                  Text(
                    'Complete your monthly wellness check to view your current score.',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.large),
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
        const SizedBox(height: AppSpacing.medium),
        Align(
          alignment: Alignment.centerRight,
          child: IntrinsicWidth(
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 40),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: onViewTrends,
              icon: const Icon(
                Icons.show_chart,
                size: 18,
              ),
              label: const Text(
                'Previous Trends',
              ),
            ),
          ),
        ),
      ],
    );
  }
}
