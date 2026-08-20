import 'package:flutter/material.dart';

import '../data/wellness_questions.dart';
import '../models/wellness_assessment.dart';
import '../services/auth_service.dart';
import '../services/weekly_quest_service.dart';
import '../services/wellness_quest_service.dart';
import '../services/wellness_service.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../utils/snackbar_helper.dart';
import '../widgets/loading_indicator.dart';

class WellnessSurveyScreen extends StatefulWidget {
  const WellnessSurveyScreen({super.key});

  @override
  State<WellnessSurveyScreen> createState() => _WellnessSurveyScreenState();
}

class _WellnessSurveyScreenState extends State<WellnessSurveyScreen> {
  // ===========================================================
  // Survey State
  // Stores one selected response for each GHQ-12 question.
  // ===========================================================
  final List<int?> _answers = List<int?>.filled(wellnessQuestions.length, null);

  int _currentQuestionIndex = 0;
  bool _isSaving = false;

  // ===========================================================
  // Select Answer
  // ===========================================================
  void _selectAnswer(int value) {
    setState(() {
      _answers[_currentQuestionIndex] = value;
    });
  }

  // ===========================================================
  // Previous Question
  // ===========================================================
  void _previousQuestion() {
    if (_currentQuestionIndex == 0) return;

    setState(() {
      _currentQuestionIndex--;
    });
  }

  // ===========================================================
  // Next Question
  // ===========================================================
  void _nextQuestion() {
    if (_answers[_currentQuestionIndex] == null) {
      SnackbarHelper.show(
        context,
        'Please select an answer before continuing.',
      );
      return;
    }

    if (_currentQuestionIndex == wellnessQuestions.length - 1) {
      _submitAssessment();
      return;
    }

    setState(() {
      _currentQuestionIndex++;
    });
  }

  // ===========================================================
  // Calculate Score
  // Uses GHQ binary scoring: 0, 0, 1, 1.
  // Total score range: 0 to 12.
  // ===========================================================
  int _calculateScore() {
    int total = 0;

    for (int index = 0; index < _answers.length; index++) {
      final selectedOption = _answers[index];

      if (selectedOption != null) {
        total += wellnessQuestions[index].scores[selectedOption];
      }
    }

    return total;
  }

  // ===========================================================
  // Submit Assessment
  // Saves the monthly GHQ assessment and generates the
  // user's personalized weekly wellness quest plan.
  // ===========================================================
  Future<void> _submitAssessment() async {
    if (_isSaving) return;

    if (_answers.any((answer) => answer == null)) {
      SnackbarHelper.show(
        context,
        'Please answer all questions before submitting.',
      );
      return;
    }

    final user = AuthService.currentUser;

    if (user == null) {
      SnackbarHelper.show(
        context,
        'No signed-in user was found.',
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final now = DateTime.now();

      final selectedAnswers = _answers.cast<int>();

      // ===========================================================
      // Monthly Wellness Assessment
      // ===========================================================
      final assessment = WellnessAssessment(
        id: WellnessService.monthlyAssessmentId(now),
        userId: user.uid,
        year: now.year,
        month: now.month,
        score: _calculateScore(),
        answers: selectedAnswers,
        completedAt: DateTime.now().toUtc(),
      );

      await WellnessService.saveAssessment(assessment);

      // ===========================================================
      // Weekly Quest Generation
      // Generates personalized quests based on the individual
      // GHQ responses, not only the final score.
      // ===========================================================
      final weeklyQuests = WellnessQuestService.generateWeeklyQuests(
        selectedAnswers,
      );

      // ===========================================================
      // Save Weekly Quest Plan
      // Stores the plan once for the current week.
      // ===========================================================
      await WeeklyQuestService.saveWeeklyPlan(
        userId: user.uid,
        sourceAssessmentId: assessment.id,
        quests: weeklyQuests,
      );

      if (!mounted) return;

      Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;

      SnackbarHelper.show(
        context,
        'Unable to save your assessment. Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = wellnessQuestions[_currentQuestionIndex];

    final currentAnswer = _answers[_currentQuestionIndex];

    final progress = (_currentQuestionIndex + 1) / wellnessQuestions.length;

    final isLastQuestion =
        _currentQuestionIndex == wellnessQuestions.length - 1;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Monthly Wellness Check'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.regular),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===========================================================
              // Survey Progress
              // ===========================================================
              Text(
                'Question ${_currentQuestionIndex + 1} '
                'of ${wellnessQuestions.length}',
                style: AppTextStyles.caption,
              ),

              const SizedBox(height: AppSpacing.small),

              LinearProgressIndicator(
                value: progress,
              ),

              const SizedBox(height: AppSpacing.large),

              // ===========================================================
              // Survey Context
              // ===========================================================
              if (_currentQuestionIndex == 0) ...[
                const Text(
                  'Have you recently...',
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: AppSpacing.small),
              ],

              // ===========================================================
              // Current Question
              // ===========================================================
              Text(
                currentQuestion.text,
                style: AppTextStyles.heading2,
              ),

              const SizedBox(height: AppSpacing.large),

              // ===========================================================
              // Answer Options
              // ===========================================================
              Expanded(
                child: RadioGroup<int>(
                  groupValue: currentAnswer,
                  onChanged: (value) {
                    if (_isSaving || value == null) return;

                    _selectAnswer(value);
                  },
                  child: ListView.separated(
                    itemCount: currentQuestion.options.length,
                    separatorBuilder: (context, index) {
                      return const SizedBox(
                        height: AppSpacing.small,
                      );
                    },
                    itemBuilder: (context, index) {
                      final isSelected = currentAnswer == index;

                      return Card(
                        child: RadioListTile<int>(
                          value: index,
                          enabled: !_isSaving,
                          title: Text(
                            currentQuestion.options[index],
                          ),
                          selected: isSelected,
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.medium),

              // ===========================================================
              // Survey Navigation
              // ===========================================================
              Row(
                children: [
                  if (_currentQuestionIndex > 0) ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isSaving ? null : _previousQuestion,
                        child: const Text('Previous'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.small),
                  ],
                  Expanded(
                    child: FilledButton(
                      onPressed: _isSaving ? null : _nextQuestion,
                      child: _isSaving
                          ? const LoadingIndicator()
                          : Text(
                              isLastQuestion ? 'Submit Assessment' : 'Next',
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
