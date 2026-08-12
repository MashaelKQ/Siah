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
  // Loads the signed-in user's assessment for the current month.
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
  // Opens the user's previous wellness assessment history.
  // ===========================================================
  void _openTrends() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const WellnessTrendScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ===========================================================
      // App Bar
      // Displays the standard Wellness screen title.
      // ===========================================================
      appBar: AppBar(
        title: const Text('Wellness'),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.regular),
          child: FutureBuilder<WellnessAssessment?>(
            future: _assessmentFuture,
            builder: (context, snapshot) {
              // ===========================================================
              // Loading State
              // ===========================================================
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: LoadingIndicator(),
                );
              }

              // ===========================================================
              // Error State
              // ===========================================================
              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Unable to load your wellness information.',
                        style: AppTextStyles.body,
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
                );
              }

              final assessment = snapshot.data;
              final assessmentCompleted = assessment != null;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ===========================================================
                  // Wellness Header
                  // ===========================================================
                  const Text(
                    'Your Wellness',
                    style: AppTextStyles.heading1,
                  ),

                  const SizedBox(height: AppSpacing.large),

                  // ===========================================================
                  // Wellness Score Card
                  // Combines the current score/status, survey action,
                  // and access to previous wellness trends.
                  // ===========================================================
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.regular),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ===================================================
                          // Score Card Header
                          // Displays the section title and trend history access.
                          // ===================================================
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'Current Wellness Score',
                                  style: AppTextStyles.heading2,
                                ),
                              ),
                              IconButton(
                                tooltip: 'View wellness trends',
                                onPressed: _openTrends,
                                icon: const Icon(
                                  Icons.show_chart,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: AppSpacing.medium),

                          // ===================================================
                          // Completed Assessment State
                          // ===================================================
                          if (assessmentCompleted) ...[
                            Row(
                              children: [
                                const Icon(
                                  Icons.check_circle_outline,
                                  size: 30,
                                ),
                                const SizedBox(
                                  width: AppSpacing.medium,
                                ),
                                Text(
                                  '${assessment.score}',
                                  style: AppTextStyles.heading1,
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: AppSpacing.xSmall,
                            ),
                            const Text(
                              'Completed this month',
                              style: AppTextStyles.caption,
                            ),
                            const SizedBox(
                              height: AppSpacing.medium,
                            ),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                onPressed: null,
                                icon: const Icon(
                                  Icons.check,
                                ),
                                label: const Text(
                                  'Assessment Completed',
                                ),
                              ),
                            ),
                          ]

                          // ===================================================
                          // Incomplete Assessment State
                          // ===================================================
                          else ...[
                            const Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  size: 28,
                                ),
                                SizedBox(
                                  width: AppSpacing.medium,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Not completed this month',
                                        style: AppTextStyles.title,
                                      ),
                                      SizedBox(
                                        height: AppSpacing.xSmall,
                                      ),
                                      Text(
                                        'Complete your monthly check to view your score.',
                                        style: AppTextStyles.caption,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: AppSpacing.medium,
                            ),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                onPressed: _openSurvey,
                                icon: const Icon(
                                  Icons.arrow_forward,
                                ),
                                label: const Text(
                                  'Start Assessment',
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
