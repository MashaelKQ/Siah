import 'package:flutter/material.dart';

import '../data/onboarding_data.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../utils/snackbar_helper.dart';
import '../widgets/ui_kit.dart';

// ===========================================================
// Onboarding Screen
//
// Three short steps after the account is created: who you are,
// what you want from this, and why now.
//
// Length is the design constraint. Every extra question loses
// people, and someone who downloaded a wellbeing app on a hard
// day has the least patience for a form. So: three screens,
// one question type each, and only the age range is required.
//
// The goals and reasons are not analytics. They are read back
// to the user later, which is the only honest reason to ask
// someone to fill in a form about themselves.
// ===========================================================
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({
    required this.onCompleted,
    super.key,
  });

  final VoidCallback onCompleted;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _noteController = TextEditingController();

  String? _ageRange;
  String? _gender;
  String? _occupation;
  String? _weeklyHours;

  final Set<String> _goals = {};
  final Set<String> _reasons = {};

  int _step = 0;
  bool _isSaving = false;

  @override
  void dispose() {
    _pageController.dispose();
    _noteController.dispose();

    super.dispose();
  }

  bool get _canContinue {
    // Only the first step gates progress, and only on the one
    // question the app genuinely needs.
    if (_step == 0) return _ageRange != null;

    return true;
  }

  void _next() {
    if (_step < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
      return;
    }

    _finish();
  }

  void _back() {
    if (_step == 0) return;

    _pageController.previousPage(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  // ===========================================================
  // Finish
  // Saves the answers and hands control back to the gate.
  // ===========================================================
  Future<void> _finish() async {
    if (_isSaving) return;

    final user = AuthService.currentUser;

    if (user == null) return;

    setState(() {
      _isSaving = true;
    });

    try {
      await UserService.saveOnboarding(
        userId: user.uid,
        ageRange: _ageRange ?? optOut,
        gender: _gender ?? optOut,
        occupation: _occupation ?? optOut,
        weeklyHours: _weeklyHours ?? optOut,
        goals: _goals.toList(),
        reasons: _reasons.toList(),
        note: _noteController.text.trim(),
      );

      if (!mounted) return;

      widget.onCompleted();
    } catch (error) {
      if (!mounted) return;

      SnackbarHelper.show(
        context,
        'Your answers could not be saved. Check your connection.',
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
    return Scaffold(
      appBar: AppBar(
        leading: _step == 0
            ? null
            : IconButton(
                onPressed: _isSaving ? null : _back,
                icon: const Icon(Icons.arrow_back),
              ),
        title: Text('Step ${_step + 1} of 3'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ===========================================================
            // Progress
            // ===========================================================
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.regular,
              ),
              child: Row(
                children: [
                  for (var index = 0; index < 3; index++) ...[
                    Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        height: 4,
                        decoration: BoxDecoration(
                          color: index <= _step
                              ? AppColors.textPrimary
                              : AppColors.surfaceMuted,
                          borderRadius:
                              BorderRadius.circular(AppRadius.pill),
                        ),
                      ),
                    ),
                    if (index < 2) const SizedBox(width: 6),
                  ],
                ],
              ),
            ),

            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    _step = index;
                  });
                },
                children: [
                  _buildAboutYou(),
                  _buildGoals(),
                  _buildReasons(),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(AppSpacing.regular),
              child: GradientButton(
                label: _step == 2 ? 'Finish' : 'Continue',
                isLoading: _isSaving,
                onPressed: _canContinue && !_isSaving ? _next : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================
  // Step One — About You
  // ===========================================================
  Widget _buildAboutYou() {
    return _StepBody(
      title: 'A little about you',
      subtitle:
          'This helps the app make sense of your patterns. Only the age '
          'range is required, and every question has a way to skip it.',
      children: [
        _Question(
          label: 'Age range',
          isRequired: true,
          options: ageRanges,
          selected: _ageRange,
          onSelect: (value) => setState(() => _ageRange = value),
        ),
        _Question(
          label: 'Gender',
          options: genderOptions,
          selected: _gender,
          onSelect: (value) => setState(() => _gender = value),
        ),
        _Question(
          label: 'Current situation',
          options: occupationOptions,
          selected: _occupation,
          onSelect: (value) => setState(() => _occupation = value),
        ),
        _Question(
          label: 'Typical work or study week',
          options: weeklyHoursOptions,
          selected: _weeklyHours,
          onSelect: (value) => setState(() => _weeklyHours = value),
        ),
      ],
    );
  }

  // ===========================================================
  // Step Two — Goals
  // ===========================================================
  Widget _buildGoals() {
    return _StepBody(
      title: 'What would you like to get out of this?',
      subtitle: 'Pick as many as fit, or none. You can change these later.',
      children: [
        Wrap(
          spacing: AppSpacing.small,
          runSpacing: AppSpacing.small,
          children: [
            for (final goal in goalOptions)
              SelectableChip(
                label: goal,
                isCompact: true,
                isSelected: _goals.contains(goal),
                onTap: () {
                  setState(() {
                    if (!_goals.remove(goal)) _goals.add(goal);
                  });
                },
              ),
          ],
        ),
      ],
    );
  }

  // ===========================================================
  // Step Three — Reasons
  // ===========================================================
  Widget _buildReasons() {
    return _StepBody(
      title: 'What brought you here?',
      subtitle: 'Honest answers are more useful than tidy ones.',
      children: [
        Wrap(
          spacing: AppSpacing.small,
          runSpacing: AppSpacing.small,
          children: [
            for (final reason in reasonOptions)
              SelectableChip(
                label: reason,
                isCompact: true,
                isSelected: _reasons.contains(reason),
                onTap: () {
                  setState(() {
                    if (!_reasons.remove(reason)) _reasons.add(reason);
                  });
                },
              ),
          ],
        ),

        const SizedBox(height: AppSpacing.large),

        const Text(
          'Anything else? (optional)',
          style: AppTextStyles.small,
        ),

        const SizedBox(height: AppSpacing.small),

        TextField(
          controller: _noteController,
          enabled: !_isSaving,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'In your own words...',
          ),
        ),
      ],
    );
  }
}

// ===========================================================
// Step Body
// Shared layout so all three steps sit identically.
// ===========================================================
class _StepBody extends StatelessWidget {
  const _StepBody({
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.regular),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.large),
          Text(title, style: AppTextStyles.heading1),
          const SizedBox(height: AppSpacing.small),
          Text(subtitle, style: AppTextStyles.caption),
          const SizedBox(height: AppSpacing.xLarge),
          ...children,
        ],
      ),
    );
  }
}

// ===========================================================
// Question
// One single-choice question. Tapping the chosen option again
// clears it, so an accidental tap is not permanent.
// ===========================================================
class _Question extends StatelessWidget {
  const _Question({
    required this.label,
    required this.options,
    required this.selected,
    required this.onSelect,
    this.isRequired = false,
  });

  final String label;
  final List<String> options;
  final String? selected;
  final ValueChanged<String?> onSelect;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label, style: AppTextStyles.title),
              if (isRequired)
                Text(
                  ' *',
                  style: AppTextStyles.title.copyWith(
                    color: AppColors.error,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.medium),
          Wrap(
            spacing: AppSpacing.small,
            runSpacing: AppSpacing.small,
            children: [
              for (final option in options)
                SelectableChip(
                  label: option,
                  isCompact: true,
                  isSelected: selected == option,
                  onTap: () {
                    onSelect(selected == option ? null : option);
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }
}
