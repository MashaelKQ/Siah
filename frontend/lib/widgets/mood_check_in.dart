import 'package:flutter/material.dart';

import '../data/check_in_data.dart';
import '../models/check_in_models.dart';
import '../services/auth_service.dart';
import '../services/check_in_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../utils/snackbar_helper.dart';
import 'mood_option.dart';
import 'ui_kit.dart';


// ===========================================================
// Mood Check-In
// The Home screen card. Everything happens in place: pick a
// mood, adjust it, save. Nothing opens a new screen, because
// a check-in that costs a screen transition is a check-in
// people stop doing.
//
// Detail is optional. Tapping a mood and pressing Save is a
// complete entry. The emotions and impacts are there for the
// days someone wants to say more.
// ===========================================================
class MoodCheckIn extends StatefulWidget {
  const MoodCheckIn({super.key});

  @override
  State<MoodCheckIn> createState() => _MoodCheckInState();
}

class _MoodCheckInState extends State<MoodCheckIn> {
  // Null until a mood is tapped, which is what keeps the card
  // collapsed on first view.
  int? _valence;

  final Set<String> _emotions = {};
  final Set<String> _impacts = {};

  bool _showAllEmotions = false;
  bool _showImpacts = false;

  bool _isSaving = false;

  List<MoodEntry> _todayEntries = const [];

  @override
  void initState() {
    super.initState();
    _loadToday();
  }

  // ===========================================================
  // Load Today
  // Reads the check-ins already recorded today.
  // ===========================================================
  Future<void> _loadToday() async {
    final user = AuthService.currentUser;

    if (user == null) return;

    try {
      final entries = await MoodService.getEntriesForDay(
        user.uid,
        DateTime.now(),
      );

      if (!mounted) return;

      setState(() {
        _todayEntries = entries;
      });
    } catch (error) {
      // A failed read here is worth knowing about: it is usually
      // the same cause as a failed write.
      if (!mounted) return;

      SnackbarHelper.show(context, describeFirestoreError(error));
    }
  }

  // ===========================================================
  // Select Mood
  // Opens the card, or closes it when the same mood is tapped
  // a second time.
  // ===========================================================
  void _selectMood(QuickMood mood) {
    if (_isSaving) return;

    if (_isMoodSelected(mood)) {
      _reset();
      return;
    }

    setState(() {
      _valence = mood.valence;
      _emotions.clear();

      final emotion = mood.emotion;

      if (emotion != null) {
        _emotions.add(emotion);
      }

      _impacts.clear();
      _showAllEmotions = false;
      _showImpacts = false;
    });
  }

  void _reset() {
    setState(() {
      _valence = null;
      _emotions.clear();
      _impacts.clear();
      _showAllEmotions = false;
      _showImpacts = false;
    });
  }

  // ===========================================================
  // Adjust Valence
  // Drops emotion words that no longer match the new position,
  // so a saved entry cannot contradict itself.
  // ===========================================================
  void _setValence(int valence) {
    if (valence == _valence) return;

    final allowed = emotionsForValence(valence).toSet();

    setState(() {
      _valence = valence;
      _emotions.removeWhere((emotion) => !allowed.contains(emotion));
    });
  }

  // ===========================================================
  // Save
  // Writes the check-in and closes the card.
  // ===========================================================
  Future<void> _save() async {
    final valence = _valence;
    final user = AuthService.currentUser;

    if (valence == null || user == null || _isSaving) return;

    setState(() {
      _isSaving = true;
    });

    final now = DateTime.now();

    try {
      await MoodService.saveEntry(
        MoodEntry(
          id: MoodService.entryId(now),
          userId: user.uid,
          log: EmotionalLog(
            valence: valence,
            emotions: _emotions.toList(),
            impacts: _impacts.toList(),
          ),
          createdAt: now,
        ),
      );

      _reset();
      await _loadToday();

      if (!mounted) return;

      SnackbarHelper.show(context, 'Check-in saved.');
    } catch (error) {
      if (!mounted) return;

      SnackbarHelper.show(context, describeFirestoreError(error));
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // ===========================================================
  // Mood Selection State
  // A shortcut looks selected when both its position and its
  // word are still in place, which keeps Low and Stressed
  // distinguishable even though they share a valence.
  // ===========================================================
  bool _isMoodSelected(QuickMood mood) {
    if (_valence != mood.valence) return false;

    final emotion = mood.emotion;

    if (emotion == null) return true;

    return _emotions.contains(emotion);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'How are you feeling right now?',
          style: AppTextStyles.title,
        ),

        const SizedBox(height: AppSpacing.medium),

        // ===========================================================
        // Mood Shortcuts
        // One tap opens the rest of the card below.
        // ===========================================================
        Row(
          children: [
            for (final mood in quickMoods) ...[
              Expanded(
                child: MoodOption(
                  icon: mood.icon,
                  label: mood.label,
                  isSelected: _isMoodSelected(mood),
                  onTap: () => _selectMood(mood),
                ),
              ),
              if (mood != quickMoods.last)
                const SizedBox(width: AppSpacing.small),
            ],
          ],
        ),

        // ===========================================================
        // Details
        // Grows in place once a mood is chosen.
        // ===========================================================
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.topCenter,
          child: _valence == null
              ? const SizedBox(width: double.infinity)
              : _buildDetails(),
        ),

        // ===========================================================
        // Today's Check-Ins
        // Hidden until something has been recorded, so the card
        // stays quiet on a fresh day.
        // ===========================================================
        if (_todayEntries.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.medium),
          Wrap(
            spacing: AppSpacing.small,
            runSpacing: AppSpacing.small,
            children: [
              for (final entry in _todayEntries) _EntryPill(entry: entry),
            ],
          ),
        ],
      ],
    );
  }

  // ===========================================================
  // Details Panel
  // ===========================================================
  Widget _buildDetails() {
    final valence = _valence ?? 0;
    final words = emotionsForValence(valence);
    final visibleWords = _showAllEmotions ? words : words.take(8).toList();

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.medium),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.regular),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.medium),
          boxShadow: AppShadows.card,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===========================================================
            // Fine Tuning
            // The shortcuts cover the common cases. The slider
            // reaches the ends of the scale.
            // ===========================================================
            Row(
              children: [
                Container(
                  height: 14,
                  width: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: valenceColor(valence),
                  ),
                ),
                const SizedBox(width: AppSpacing.medium),
                Expanded(
                  child: Text(
                    valenceLabel(valence),
                    style: AppTextStyles.title,
                  ),
                ),
                IconButton(
                  tooltip: 'Cancel',
                  onPressed: _isSaving ? null : _reset,
                  icon: const Icon(Icons.close),
                ),
              ],
            ),

            Slider(
              value: valence.toDouble(),
              min: minValence.toDouble(),
              max: maxValence.toDouble(),
              divisions: maxValence - minValence,
              label: valenceLabel(valence),
              onChanged: _isSaving
                  ? null
                  : (value) {
                      _setValence(value.round());
                    },
            ),

            const SizedBox(height: AppSpacing.small),

            // ===========================================================
            // Emotions
            // ===========================================================
            const Text(
              'What best describes this feeling?',
              style: AppTextStyles.caption,
            ),

            const SizedBox(height: AppSpacing.small),

            Wrap(
              spacing: AppSpacing.small,
              runSpacing: AppSpacing.small,
              children: [
                for (final word in visibleWords)
                  SelectableChip(
                    label: word,
                    isCompact: true,
                    isSelected: _emotions.contains(word),
                    onTap: _isSaving
                        ? null
                        : () {
                            setState(() {
                              if (!_emotions.remove(word)) {
                                _emotions.add(word);
                              }
                            });
                          },
                  ),
              ],
            ),

            if (words.length > 8)
              TextButton(
                onPressed: _isSaving
                    ? null
                    : () {
                        setState(() {
                          _showAllEmotions = !_showAllEmotions;
                        });
                      },
                child: Text(_showAllEmotions ? 'Show Less' : 'Show More'),
              ),

            // ===========================================================
            // Impacts
            // Kept behind a tap so the card stays short for the
            // people who only want to log a feeling.
            // ===========================================================
            if (!_showImpacts)
              TextButton.icon(
                onPressed: _isSaving
                    ? null
                    : () {
                        setState(() {
                          _showImpacts = true;
                        });
                      },
                icon: const Icon(Icons.add),
                label: const Text("What's affecting you?"),
              )
            else ...[
              const SizedBox(height: AppSpacing.small),
              const Text(
                "What's having the biggest impact on you?",
                style: AppTextStyles.caption,
              ),
              const SizedBox(height: AppSpacing.small),
              for (final group in impactGroups) ...[
                Text(group.title, style: AppTextStyles.small),
                const SizedBox(height: AppSpacing.xSmall),
                Wrap(
                  spacing: AppSpacing.small,
                  runSpacing: AppSpacing.small,
                  children: [
                    for (final item in group.items)
                      SelectableChip(
                        label: item,
                        isCompact: true,
                        isSelected: _impacts.contains(item),
                        onTap: _isSaving
                            ? null
                            : () {
                                setState(() {
                                  if (!_impacts.remove(item)) {
                                    _impacts.add(item);
                                  }
                                });
                              },
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.small),
              ],
            ],

            const SizedBox(height: AppSpacing.small),

            // ===========================================================
            // Save
            // ===========================================================
            GradientButton(
              label: 'Save Check-In',
              isLoading: _isSaving,
              onPressed: _isSaving ? null : _save,
            ),
          ],
        ),
      ),
    );
  }
}

// ===========================================================
// Entry Pill
// A compact view of one check-in already recorded today.
// ===========================================================
class _EntryPill extends StatelessWidget {
  const _EntryPill({required this.entry});

  final MoodEntry entry;

  @override
  Widget build(BuildContext context) {
    final time = TimeOfDay.fromDateTime(entry.createdAt).format(context);
    final emotions = entry.log.emotions;

    final label = emotions.isEmpty
        ? valenceLabel(entry.log.valence)
        : emotions.take(2).join(', ');

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.medium,
        vertical: AppSpacing.small,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 8,
            width: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: valenceColor(entry.log.valence),
            ),
          ),
          const SizedBox(width: AppSpacing.small),
          Text('$label  ', style: AppTextStyles.caption),
          Text(time, style: AppTextStyles.small),
        ],
      ),
    );
  }
}



// ===========================================================
// Mood Check-In Screen
// Records how a moment felt in three short steps:
// how pleasant it was, what the feeling was, and what was
// behind it.
//
// Returns an EmotionalLog when finished, or null if the user
// backs out. The caller decides what to do with it, so the
// same flow serves both the Home check-in and the Journal.
//
// Only the first step is required. Someone having a hard day
// should be able to log it in one swipe and one tap.
// ===========================================================
class MoodCheckInScreen extends StatefulWidget {
  const MoodCheckInScreen({
    this.initialValence = 0,
    this.initialEmotion,
    super.key,
  });

  final int initialValence;
  final String? initialEmotion;

  @override
  State<MoodCheckInScreen> createState() => _MoodCheckInScreenState();
}

class _MoodCheckInScreenState extends State<MoodCheckInScreen> {
  late int _valence = widget.initialValence;

  final Set<String> _emotions = {};
  final Set<String> _impacts = {};

  int _step = 0;

  @override
  void initState() {
    super.initState();

    final emotion = widget.initialEmotion;

    if (emotion != null) {
      _emotions.add(emotion);
    }
  }

  // ===========================================================
  // Move Forward
  // Finishes on the last step by returning the completed log.
  // ===========================================================
  void _next() {
    if (_step < 2) {
      setState(() {
        _step++;
      });
      return;
    }

    Navigator.pop(
      context,
      EmotionalLog(
        valence: _valence,
        emotions: _emotions.toList(),
        impacts: _impacts.toList(),
      ),
    );
  }

  void _back() {
    if (_step == 0) {
      Navigator.pop(context);
      return;
    }

    setState(() {
      _step--;
    });
  }

  // ===========================================================
  // Change Valence
  // Clears emotion words that no longer belong to the new band,
  // so the saved log cannot contradict itself.
  // ===========================================================
  void _setValence(int valence) {
    if (valence == _valence) return;

    final allowed = emotionsForValence(valence).toSet();

    setState(() {
      _valence = valence;
      _emotions.removeWhere((emotion) => !allowed.contains(emotion));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: _back,
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text('Step ${_step + 1} of 3'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.regular),
                child: switch (_step) {
                  0 => _buildValenceStep(),
                  1 => _buildEmotionStep(),
                  _ => _buildImpactStep(),
                },
              ),
            ),

            // ===========================================================
            // Continue
            // ===========================================================
            Padding(
              padding: const EdgeInsets.all(AppSpacing.regular),
              child: GradientButton(
                label: _step == 2 ? 'Save Check-In' : 'Continue',
                onPressed: _next,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================
  // Step One
  // Places the moment on the pleasant to unpleasant scale.
  // ===========================================================
  Widget _buildValenceStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'How are you feeling right now?',
          style: AppTextStyles.heading1,
        ),

        const SizedBox(height: AppSpacing.xLarge),

        // A plain circle that takes the colour and size of the
        // chosen point, so the scale is readable at a glance.
        Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            height: 150,
            width: 150,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: valenceColor(_valence).withValues(alpha: 0.22),
            ),
            child: Container(
              height: 56,
              width: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: valenceColor(_valence),
              ),
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.large),

        Center(
          child: Text(
            valenceLabel(_valence),
            style: AppTextStyles.heading2,
          ),
        ),

        const SizedBox(height: AppSpacing.large),

        Slider(
          value: _valence.toDouble(),
          min: minValence.toDouble(),
          max: maxValence.toDouble(),
          divisions: maxValence - minValence,
          label: valenceLabel(_valence),
          onChanged: (value) {
            _setValence(value.round());
          },
        ),

        const Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.regular),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Very Unpleasant', style: AppTextStyles.small),
              Text('Very Pleasant', style: AppTextStyles.small),
            ],
          ),
        ),
      ],
    );
  }

  // ===========================================================
  // Step Two
  // Names the feeling, using words that match the first step.
  // ===========================================================
  Widget _buildEmotionStep() {
    final words = emotionsForValence(_valence);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'What best describes this feeling?',
          style: AppTextStyles.heading1,
        ),

        const SizedBox(height: AppSpacing.small),

        const Text(
          'Choose as many as fit, or none.',
          style: AppTextStyles.caption,
        ),

        const SizedBox(height: AppSpacing.large),

        Wrap(
          spacing: AppSpacing.small,
          runSpacing: AppSpacing.small,
          children: [
            for (final word in words)
              SelectableChip(
                label: word,
                isSelected: _emotions.contains(word),
                onTap: () {
                  setState(() {
                    if (!_emotions.remove(word)) {
                      _emotions.add(word);
                    }
                  });
                },
              ),
          ],
        ),
      ],
    );
  }

  // ===========================================================
  // Step Three
  // Records what is behind the feeling.
  // ===========================================================
  Widget _buildImpactStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "What's having the biggest impact on you?",
          style: AppTextStyles.heading1,
        ),

        const SizedBox(height: AppSpacing.small),

        const Text(
          'This is what turns single check-ins into patterns.',
          style: AppTextStyles.caption,
        ),

        const SizedBox(height: AppSpacing.large),

        for (final group in impactGroups) ...[
          Text(group.title, style: AppTextStyles.title),
          const SizedBox(height: AppSpacing.small),
          Wrap(
            spacing: AppSpacing.small,
            runSpacing: AppSpacing.small,
            children: [
              for (final item in group.items)
                SelectableChip(
                  label: item,
                  isSelected: _impacts.contains(item),
                  onTap: () {
                    setState(() {
                      if (!_impacts.remove(item)) {
                        _impacts.add(item);
                      }
                    });
                  },
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.large),
        ],
      ],
    );
  }
}
