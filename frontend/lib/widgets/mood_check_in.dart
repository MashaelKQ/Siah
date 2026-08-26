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

class MoodCheckIn extends StatefulWidget {
  const MoodCheckIn({
    super.key,
  });

  @override
  State<MoodCheckIn> createState() => _MoodCheckInState();
}

class _MoodCheckInState extends State<MoodCheckIn> {
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

  Future<void> _loadToday() async {
    final user = AuthService.currentUser;

    if (user == null) {
      return;
    }

    try {
      final entries = await MoodService.getEntriesForDay(
        user.uid,
        DateTime.now(),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _todayEntries = entries;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      SnackbarHelper.show(
        context,
        describeFirestoreError(
          error,
        ),
      );
    }
  }

  void _selectMood(
    QuickMood mood,
  ) {
    if (_isSaving) {
      return;
    }

    if (_isMoodSelected(
      mood,
    )) {
      _reset();
      return;
    }

    setState(() {
      _valence = mood.valence;

      _emotions.clear();

      final emotion = mood.emotion;

      if (emotion != null) {
        _emotions.add(
          emotion,
        );
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

  void _setValence(
    int valence,
  ) {
    if (valence == _valence) {
      return;
    }

    final allowed = emotionsForValence(
      valence,
    ).toSet();

    setState(() {
      _valence = valence;

      _emotions.removeWhere(
        (emotion) => !allowed.contains(
          emotion,
        ),
      );
    });
  }

  Future<void> _save() async {
    final valence = _valence;

    final user = AuthService.currentUser;

    if (valence == null || user == null || _isSaving) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final now = DateTime.now();

    try {
      await MoodService.saveEntry(
        MoodEntry(
          id: MoodService.entryId(
            now,
          ),
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

      if (!mounted) {
        return;
      }

      SnackbarHelper.show(
        context,
        'Check-in saved.',
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      SnackbarHelper.show(
        context,
        describeFirestoreError(
          error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  bool _isMoodSelected(
    QuickMood mood,
  ) {
    if (_valence != mood.valence) {
      return false;
    }

    final emotion = mood.emotion;

    if (emotion == null) {
      return true;
    }

    return _emotions.contains(
      emotion,
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How are you feeling right now?',
          style: AppTextStyles.title.copyWith(
            fontSize: 17,
          ),
        ),

        const SizedBox(
          height: 8,
        ),

        // ===========================================================
        // Mood Options
        // ===========================================================
        Row(
          children: [
            for (final mood in quickMoods) ...[
              Expanded(
                child: MoodOption(
                  icon: mood.icon,
                  label: mood.label,
                  isSelected: _isMoodSelected(
                    mood,
                  ),
                  onTap: () => _selectMood(
                    mood,
                  ),
                ),
              ),
              if (mood != quickMoods.last)
                const SizedBox(
                  width: 6,
                ),
            ],
          ],
        ),

        // ===========================================================
        // Optional Details
        // ===========================================================
        AnimatedSize(
          duration: const Duration(
            milliseconds: 200,
          ),
          alignment: Alignment.topCenter,
          child: _valence == null ? const SizedBox.shrink() : _buildDetails(),
        ),

        // ===========================================================
        // Latest Today's Check-In
        // ===========================================================
        if (_todayEntries.isNotEmpty) ...[
          const SizedBox(
            height: 7,
          ),
          _CompactLatestEntry(
            entry: _todayEntries.first,
          ),
        ],
      ],
    );
  }

  Widget _buildDetails() {
    final valence = _valence ?? 0;

    final words = emotionsForValence(
      valence,
    );

    final visibleWords = _showAllEmotions ? words : words.take(8).toList();

    return Padding(
      padding: const EdgeInsets.only(
        top: 8,
      ),
      child: Container(
        padding: const EdgeInsets.all(
          12,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(
            AppRadius.medium,
          ),
          boxShadow: AppShadows.card,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  height: 12,
                  width: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: valenceColor(
                      valence,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: Text(
                    valenceLabel(
                      valence,
                    ),
                    style: AppTextStyles.title.copyWith(
                      fontSize: 16,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Cancel',
                  visualDensity: VisualDensity.compact,
                  onPressed: _isSaving ? null : _reset,
                  icon: const Icon(
                    Icons.close,
                    size: 19,
                  ),
                ),
              ],
            ),
            Slider(
              value: valence.toDouble(),
              min: minValence.toDouble(),
              max: maxValence.toDouble(),
              divisions: maxValence - minValence,
              label: valenceLabel(
                valence,
              ),
              onChanged: _isSaving
                  ? null
                  : (value) {
                      _setValence(
                        value.round(),
                      );
                    },
            ),
            const SizedBox(
              height: 4,
            ),
            Text(
              'What best describes this feeling?',
              style: AppTextStyles.caption.copyWith(
                fontSize: 11,
              ),
            ),
            const SizedBox(
              height: 6,
            ),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final word in visibleWords)
                  SelectableChip(
                    label: word,
                    isCompact: true,
                    isSelected: _emotions.contains(
                      word,
                    ),
                    onTap: _isSaving
                        ? null
                        : () {
                            setState(
                              () {
                                if (!_emotions.remove(
                                  word,
                                )) {
                                  _emotions.add(
                                    word,
                                  );
                                }
                              },
                            );
                          },
                  ),
              ],
            ),
            if (words.length > 8)
              TextButton(
                onPressed: _isSaving
                    ? null
                    : () {
                        setState(
                          () {
                            _showAllEmotions = !_showAllEmotions;
                          },
                        );
                      },
                child: Text(
                  _showAllEmotions ? 'Show Less' : 'Show More',
                ),
              ),
            if (!_showImpacts)
              TextButton.icon(
                onPressed: _isSaving
                    ? null
                    : () {
                        setState(
                          () {
                            _showImpacts = true;
                          },
                        );
                      },
                icon: const Icon(
                  Icons.add,
                  size: 18,
                ),
                label: const Text(
                  "What's affecting you?",
                ),
              )
            else ...[
              const SizedBox(
                height: 4,
              ),
              Text(
                "What's having the biggest impact on you?",
                style: AppTextStyles.caption.copyWith(
                  fontSize: 11,
                ),
              ),
              const SizedBox(
                height: 6,
              ),
              for (final group in impactGroups) ...[
                Text(
                  group.title,
                  style: AppTextStyles.small,
                ),
                const SizedBox(
                  height: 4,
                ),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final item in group.items)
                      SelectableChip(
                        label: item,
                        isCompact: true,
                        isSelected: _impacts.contains(
                          item,
                        ),
                        onTap: _isSaving
                            ? null
                            : () {
                                setState(
                                  () {
                                    if (!_impacts.remove(
                                      item,
                                    )) {
                                      _impacts.add(
                                        item,
                                      );
                                    }
                                  },
                                );
                              },
                      ),
                  ],
                ),
                const SizedBox(
                  height: 6,
                ),
              ],
            ],
            const SizedBox(
              height: 6,
            ),
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

// =====================================================================
// Latest Entry
// =====================================================================
class _CompactLatestEntry extends StatelessWidget {
  const _CompactLatestEntry({
    required this.entry,
  });

  final MoodEntry entry;

  @override
  Widget build(
    BuildContext context,
  ) {
    final time = TimeOfDay.fromDateTime(
      entry.createdAt,
    ).format(context);

    final emotions = entry.log.emotions;

    final label = emotions.isEmpty
        ? valenceLabel(
            entry.log.valence,
          )
        : emotions.first;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          AppRadius.pill,
        ),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 7,
            width: 7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: valenceColor(
                entry.log.valence,
              ),
            ),
          ),
          const SizedBox(
            width: 6,
          ),
          Text(
            '$label • $time',
            style: AppTextStyles.caption.copyWith(
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// Full Mood Check-In Screen
// =====================================================================
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
      _emotions.add(
        emotion,
      );
    }
  }

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
      Navigator.pop(
        context,
      );

      return;
    }

    setState(() {
      _step--;
    });
  }

  void _setValence(
    int valence,
  ) {
    if (valence == _valence) {
      return;
    }

    final allowed = emotionsForValence(
      valence,
    ).toSet();

    setState(() {
      _valence = valence;

      _emotions.removeWhere(
        (emotion) => !allowed.contains(
          emotion,
        ),
      );
    });
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: _back,
          icon: const Icon(
            Icons.arrow_back,
          ),
        ),
        title: Text(
          'Step ${_step + 1} of 3',
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(
                  AppSpacing.regular,
                ),
                child: switch (_step) {
                  0 => _buildValenceStep(),
                  1 => _buildEmotionStep(),
                  _ => _buildImpactStep(),
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(
                AppSpacing.regular,
              ),
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

  Widget _buildValenceStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'How are you feeling right now?',
          style: AppTextStyles.heading1,
        ),
        const SizedBox(
          height: AppSpacing.xLarge,
        ),
        Center(
          child: AnimatedContainer(
            duration: const Duration(
              milliseconds: 250,
            ),
            curve: Curves.easeOut,
            height: 150,
            width: 150,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: valenceColor(
                _valence,
              ).withValues(
                alpha: 0.22,
              ),
            ),
            child: Container(
              height: 56,
              width: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: valenceColor(
                  _valence,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(
          height: AppSpacing.large,
        ),
        Center(
          child: Text(
            valenceLabel(
              _valence,
            ),
            style: AppTextStyles.heading2,
          ),
        ),
        const SizedBox(
          height: AppSpacing.large,
        ),
        Slider(
          value: _valence.toDouble(),
          min: minValence.toDouble(),
          max: maxValence.toDouble(),
          divisions: maxValence - minValence,
          label: valenceLabel(
            _valence,
          ),
          onChanged: (value) {
            _setValence(
              value.round(),
            );
          },
        ),
        const Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.regular,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Very Unpleasant',
                style: AppTextStyles.small,
              ),
              Text(
                'Very Pleasant',
                style: AppTextStyles.small,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmotionStep() {
    final words = emotionsForValence(
      _valence,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'What best describes this feeling?',
          style: AppTextStyles.heading1,
        ),
        const SizedBox(
          height: AppSpacing.small,
        ),
        const Text(
          'Choose as many as fit, or none.',
          style: AppTextStyles.caption,
        ),
        const SizedBox(
          height: AppSpacing.large,
        ),
        Wrap(
          spacing: AppSpacing.small,
          runSpacing: AppSpacing.small,
          children: [
            for (final word in words)
              SelectableChip(
                label: word,
                isSelected: _emotions.contains(
                  word,
                ),
                onTap: () {
                  setState(() {
                    if (!_emotions.remove(
                      word,
                    )) {
                      _emotions.add(
                        word,
                      );
                    }
                  });
                },
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildImpactStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "What's having the biggest impact on you?",
          style: AppTextStyles.heading1,
        ),
        const SizedBox(
          height: AppSpacing.small,
        ),
        const Text(
          'This is what turns single check-ins into patterns.',
          style: AppTextStyles.caption,
        ),
        const SizedBox(
          height: AppSpacing.large,
        ),
        for (final group in impactGroups) ...[
          Text(
            group.title,
            style: AppTextStyles.title,
          ),
          const SizedBox(
            height: AppSpacing.small,
          ),
          Wrap(
            spacing: AppSpacing.small,
            runSpacing: AppSpacing.small,
            children: [
              for (final item in group.items)
                SelectableChip(
                  label: item,
                  isSelected: _impacts.contains(
                    item,
                  ),
                  onTap: () {
                    setState(() {
                      if (!_impacts.remove(
                        item,
                      )) {
                        _impacts.add(
                          item,
                        );
                      }
                    });
                  },
                ),
            ],
          ),
          const SizedBox(
            height: AppSpacing.large,
          ),
        ],
      ],
    );
  }
}
