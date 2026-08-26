import 'package:flutter/material.dart';

import '../data/wellness_questions.dart';
import '../models/wellness_assessment.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/weekly_quest_service.dart';
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
  final List<int?> _answers = List<int?>.filled(
    wellnessQuestions.length,
    null,
  );

  int _currentQuestionIndex = 0;
  bool _isSaving = false;

  void _selectAnswer(int value) {
    setState(() {
      _answers[_currentQuestionIndex] = value;
    });
  }

  void _previousQuestion() {
    if (_currentQuestionIndex == 0) return;

    setState(() {
      _currentQuestionIndex--;
    });
  }

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

  Map<String, dynamic> _buildGhQAnswers(
    List<int> selectedAnswers,
  ) {
    final ghqAnswers = <String, dynamic>{};

    for (int index = 0; index < wellnessQuestions.length; index++) {
      final question = wellnessQuestions[index];
      final selectedOption = selectedAnswers[index];

      ghqAnswers['q${index + 1}'] = {
        'question': question.text,
        'answer': question.options[selectedOption],
        'score': question.scores[selectedOption],
      };
    }

    return ghqAnswers;
  }

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

      final score = _calculateScore();

      final assessment = WellnessAssessment(
        id: WellnessService.monthlyAssessmentId(
          now,
        ),
        userId: user.uid,
        year: now.year,
        month: now.month,
        score: score,
        answers: selectedAnswers,
        completedAt: DateTime.now().toUtc(),
      );

      await WellnessService.saveAssessment(
        assessment,
      );

      final ghqAnswers = _buildGhQAnswers(selectedAnswers);

      final weeklyQuests = await ApiService.generateWeeklyQuests(
        ghqScore: score,
        ghqAnswers: ghqAnswers,
        language: 'English',
      );

      await WeeklyQuestService.saveWeeklyPlan(
        userId: user.uid,
        sourceAssessmentId: assessment.id,
        quests: weeklyQuests,
      );

      if (!mounted) return;

      SnackbarHelper.show(
        context,
        'Assessment saved and weekly quests generated.',
      );

      Navigator.pop(context);
    } catch (error) {
      if (!mounted) return;

      SnackbarHelper.show(
        context,
        'Unable to save your assessment or generate quests. Please try again.',
      );

      debugPrint(
        'Wellness assessment error: $error',
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
        title: const Text(
          'Monthly Wellness Check',
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(
            AppSpacing.regular,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Question '
                '${_currentQuestionIndex + 1} '
                'of ${wellnessQuestions.length}',
                style: AppTextStyles.caption,
              ),
              const SizedBox(
                height: AppSpacing.small,
              ),
              LinearProgressIndicator(
                value: progress,
              ),
              const SizedBox(
                height: AppSpacing.large,
              ),
              if (_currentQuestionIndex == 0) ...[
                const Text(
                  'Have you recently...',
                  style: AppTextStyles.caption,
                ),
                const SizedBox(
                  height: AppSpacing.small,
                ),
              ],
              Text(
                currentQuestion.text,
                style: AppTextStyles.heading2,
              ),
              const SizedBox(
                height: AppSpacing.large,
              ),
              Expanded(
                child: RadioGroup<int>(
                  groupValue: currentAnswer,
                  onChanged: (value) {
                    if (_isSaving || value == null) {
                      return;
                    }

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
              const SizedBox(
                height: AppSpacing.medium,
              ),
              Row(
                children: [
                  if (_currentQuestionIndex > 0) ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isSaving ? null : _previousQuestion,
                        child: const Text('Previous'),
                      ),
                    ),
                    const SizedBox(
                      width: AppSpacing.small,
                    ),
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
