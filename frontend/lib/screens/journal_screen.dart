import 'package:flutter/material.dart';

import '../data/check_in_data.dart';
import '../models/check_in_models.dart';
import '../services/auth_service.dart';
import '../services/check_in_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../utils/snackbar_helper.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/mood_check_in.dart';
import '../widgets/ui_kit.dart';


class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final TextEditingController _journalController = TextEditingController();

  late final DateTime _today = DateTime.now();
  late final JournalPrompt _prompt = promptForDate(_today);

  EmotionalLog? _log;

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadTodayEntry();
  }

  @override
  void dispose() {
    _journalController.dispose();
    super.dispose();
  }

  // ===========================================================
  // Load Today's Entry
  // Reopens what was already written today so the screen is a
  // continuation rather than a blank page.
  // ===========================================================
  Future<void> _loadTodayEntry() async {
    final user = AuthService.currentUser;

    if (user == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final entry = await JournalService.getEntryForDay(user.uid, _today);

      if (!mounted) return;

      setState(() {
        _journalController.text = entry?.text ?? '';
        _log = entry?.log;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      SnackbarHelper.show(context, describeFirestoreError(error));
    }
  }

  // ===========================================================
  // Record Feeling
  // Opens the same check-in flow used on the Home screen and
  // attaches the result to this entry.
  // ===========================================================
  Future<void> _recordFeeling() async {
    final log = await Navigator.push<EmotionalLog>(
      context,
      MaterialPageRoute(
        builder: (context) => MoodCheckInScreen(
          initialValence: _log?.valence ?? 0,
        ),
      ),
    );

    if (log == null || !mounted) return;

    setState(() {
      _log = log;
    });
  }

  // ===========================================================
  // Save Entry
  // Writes today's reflection, replacing any earlier version
  // of the same day.
  // ===========================================================
  Future<void> _saveEntry() async {
    if (_isSaving) return;

    final user = AuthService.currentUser;

    if (user == null) return;

    final text = _journalController.text.trim();

    if (text.isEmpty) {
      SnackbarHelper.show(
        context,
        'Write something first, then save.',
      );
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isSaving = true;
    });

    final now = DateTime.now();

    try {
      await JournalService.saveEntry(
        JournalEntry(
          id: JournalService.dayId(_today),
          userId: user.uid,
          promptId: _prompt.id,
          promptText: _prompt.text,
          text: text,
          createdAt: now,
          updatedAt: now,
          log: _log,
        ),
      );

      if (!mounted) return;

      SnackbarHelper.show(context, "Today's entry has been saved.");
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
  // Current Date
  // Formats today's date without requiring an extra package.
  // ===========================================================
  String _formattedDate() {
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

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

    final weekday = weekdays[_today.weekday - 1];
    final month = months[_today.month - 1];

    return '$weekday, $month ${_today.day}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ===========================================================
      // App Bar
      // Displays the standard title for the Journal screen.
      // ===========================================================
      appBar: AppBar(
        title: const Text('Journal'),
      ),

      // ===========================================================
      // Save Action
      // Floats above the content so the text field is never
      // pushed around by it.
      // ===========================================================
      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _isLoading
          ? null
          : FloatingActionPill(
              label: "Save Today's Entry",
              icon: Icons.check,
              isLoading: _isSaving,
              onPressed: _isSaving ? null : _saveEntry,
            ),

      body: SafeArea(
        child: _isLoading
            ? const Center(child: LoadingIndicator())
            : Padding(
                padding: const EdgeInsets.all(AppSpacing.regular),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ===========================================================
                    // Journal Header
                    // Displays today's reflection title and access to all entries.
                    // ===========================================================
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            "Today's Reflection",
                            style: AppTextStyles.heading1,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const JournalHistoryScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.history),
                          label: const Text('View All'),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.xSmall),

                    Text(
                      _formattedDate(),
                      style: AppTextStyles.caption,
                    ),

                    const SizedBox(height: AppSpacing.medium),

                    // ===========================================================
                    // Today's Prompt
                    // The same question all day, chosen from the date.
                    // ===========================================================
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.regular),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(AppRadius.medium),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _prompt.category.toUpperCase(),
                            style: AppTextStyles.small,
                          ),
                          const SizedBox(height: AppSpacing.xSmall),
                          Text(
                            _prompt.text,
                            style: AppTextStyles.body,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.medium),

                    // ===========================================================
                    // Journal Entry
                    // Provides the writing area for today's reflection.
                    // ===========================================================
                    Expanded(
                      child: TextField(
                        controller: _journalController,
                        enabled: !_isSaving,
                        expands: true,
                        minLines: null,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        textAlignVertical: TextAlignVertical.top,
                        decoration: const InputDecoration(
                          hintText: 'Start writing here...',
                          alignLabelWithHint: true,
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.medium),

                    // ===========================================================
                    // Emotional Log
                    // Optional. Records how the day felt alongside
                    // what was written about it.
                    // ===========================================================
                    _EmotionalLogRow(
                      log: _log,
                      onTap: _isSaving ? null : _recordFeeling,
                    ),

                    // The save action floats over the page instead of
                    // sitting in the layout, so the writing area keeps
                    // the full height of the screen.
                    const SizedBox(height: 78),
                  ],
                ),
              ),
      ),
    );
  }
}

// ===========================================================
// Emotional Log Row
// Invites a check-in when nothing is attached, and shows what
// was recorded once there is.
// ===========================================================
class _EmotionalLogRow extends StatelessWidget {
  const _EmotionalLogRow({
    required this.log,
    required this.onTap,
  });

  final EmotionalLog? log;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final currentLog = log;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.regular),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.medium),
          boxShadow: AppShadows.card,
        ),
        child: currentLog == null
            ? const Row(
                children: [
                  Icon(Icons.add_circle_outline,
                      color: AppColors.textSecondary),
                  SizedBox(width: AppSpacing.medium),
                  Expanded(
                    child: Text(
                      'Add how you felt',
                      style: AppTextStyles.body,
                    ),
                  ),
                  Icon(Icons.chevron_right),
                ],
              )
            : Row(
                children: [
                  Container(
                    height: 12,
                    width: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: valenceColor(currentLog.valence),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.medium),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentLog.emotions.isEmpty
                              ? valenceLabel(currentLog.valence)
                              : currentLog.emotions.join(', '),
                          style: AppTextStyles.body,
                        ),
                        if (currentLog.impacts.isNotEmpty)
                          Text(
                            currentLog.impacts.join(', '),
                            style: AppTextStyles.caption,
                          ),
                      ],
                    ),
                  ),
                  const Icon(Icons.edit_outlined),
                ],
              ),
      ),
    );
  }
}



// ===========================================================
// Journal History Screen
// Every entry the user has written, newest first.
// ===========================================================
class JournalHistoryScreen extends StatefulWidget {
  const JournalHistoryScreen({super.key});

  @override
  State<JournalHistoryScreen> createState() => _JournalHistoryScreenState();
}

class _JournalHistoryScreenState extends State<JournalHistoryScreen> {
  Future<List<JournalEntry>>? _entriesFuture;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  void _loadEntries() {
    final user = AuthService.currentUser;

    if (user == null) {
      _entriesFuture = Future.value(const []);
      return;
    }

    _entriesFuture = JournalService.getRecentEntries(user.uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Entries'),
      ),
      body: SafeArea(
        child: FutureBuilder<List<JournalEntry>>(
          future: _entriesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: LoadingIndicator());
            }

            if (snapshot.hasError) {
              return _buildMessage(
                title: 'Your entries could not be loaded',
                body: 'Check your connection and try again.',
                actionLabel: 'Try Again',
                onAction: () {
                  setState(_loadEntries);
                },
              );
            }

            final entries = snapshot.data ?? const [];

            if (entries.isEmpty) {
              return _buildMessage(
                title: 'Nothing here yet',
                body: 'Your saved reflections will appear here.',
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.regular),
              itemCount: entries.length,
              separatorBuilder: (context, index) {
                return const SizedBox(height: AppSpacing.medium);
              },
              itemBuilder: (context, index) {
                return _EntryCard(entry: entries[index]);
              },
            );
          },
        ),
      ),
    );
  }

  // ===========================================================
  // Message
  // Shared layout for the empty and error states.
  // ===========================================================
  Widget _buildMessage({
    required String title,
    required String body,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: AppTextStyles.heading2),
            const SizedBox(height: AppSpacing.small),
            Text(
              body,
              style: AppTextStyles.body,
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null) ...[
              const SizedBox(height: AppSpacing.medium),
              FilledButton(
                onPressed: onAction,
                child: Text(actionLabel),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ===========================================================
// Entry Card
// One past reflection, with the feeling recorded beside it.
// ===========================================================
class _EntryCard extends StatelessWidget {
  const _EntryCard({required this.entry});

  final JournalEntry entry;

  @override
  Widget build(BuildContext context) {
    final log = entry.log;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.regular),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (log != null) ...[
                Container(
                  height: 10,
                  width: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: valenceColor(log.valence),
                  ),
                ),
                const SizedBox(width: AppSpacing.small),
              ],
              Expanded(
                child: Text(
                  entry.id,
                  style: AppTextStyles.title,
                ),
              ),
            ],
          ),

          if (entry.promptText.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xSmall),
            Text(
              entry.promptText,
              style: AppTextStyles.small,
            ),
          ],

          const SizedBox(height: AppSpacing.small),

          Text(
            entry.text,
            style: AppTextStyles.body,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),

          if (log != null && log.emotions.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.small),
            Text(
              log.emotions.join(', '),
              style: AppTextStyles.caption,
            ),
          ],
        ],
      ),
    );
  }
}
