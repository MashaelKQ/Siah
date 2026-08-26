import 'package:flutter/material.dart';

import '../data/check_in_data.dart';
import '../models/check_in_models.dart';
import '../services/auth_service.dart';
import '../services/check_in_service.dart';
import '../services/notification_service.dart';
import '../services/wellbeing_insights.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'loading_indicator.dart';

// ===========================================================
// Wellbeing Dashboard
//
// A week at a time, with an arrow back through history.
//
// Everything is loaded once and sliced per week in memory.
// Paging back is then instant, which matters: a spinner on
// every arrow tap makes people stop tapping it.
// ===========================================================
class WellbeingDashboard extends StatefulWidget {
  const WellbeingDashboard({super.key});

  @override
  State<WellbeingDashboard> createState() => _WellbeingDashboardState();
}

class _WellbeingDashboardState extends State<WellbeingDashboard> {
  // How far back the arrows can reach.
  static const int _historyDays = 120;

  List<MoodEntry> _moods = const [];
  List<JournalEntry> _journals = const [];
  List<WellbeingAlert> _alerts = const [];

  late DateTime _currentWeekStart;
  late DateTime _viewedWeekStart;

  int _streak = 0;

  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();

    _currentWeekStart = WellbeingInsights.weekStartFor(DateTime.now());
    _viewedWeekStart = _currentWeekStart;

    _load();
  }

  // ===========================================================
  // Load
  // ===========================================================
  Future<void> _load() async {
    final user = AuthService.currentUser;

    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final moods = await MoodService.getRecentEntries(
        user.uid,
        days: _historyDays,
      );

      final journals = await JournalService.getRecentEntries(
        user.uid,
        limit: 200,
      );

      final now = DateTime.now();

      final alerts = WellbeingInsights.detectAlerts(moods: moods, now: now);

      if (!mounted) return;

      setState(() {
        _moods = moods;
        _journals = journals;
        _alerts = alerts;
        _streak = WellbeingInsights.currentStreak(moods, now);
        _isLoading = false;
        _error = null;
      });

      // The banner is already on screen by now. A notification
      // only adds value when the app is closed, so it is fired
      // separately and is often suppressed.
      for (final alert in alerts) {
        await NotificationService.maybeShowAlert(
          userId: user.uid,
          alert: alert,
        );
      }
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _error = describeFirestoreError(error);
      });
    }
  }

  // ===========================================================
  // Week Navigation
  // ===========================================================
  bool get _canGoBack {
    final earliest = _currentWeekStart.subtract(
      const Duration(days: _historyDays),
    );

    return _viewedWeekStart.isAfter(earliest);
  }

  bool get _canGoForward => _viewedWeekStart.isBefore(_currentWeekStart);

  void _shiftWeek(int weeks) {
    setState(() {
      _viewedWeekStart = _viewedWeekStart.add(Duration(days: weeks * 7));
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const _Panel(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.xLarge),
          child: Center(child: LoadingIndicator()),
        ),
      );
    }

    final error = _error;

    if (error != null) {
      return _Panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(error, style: AppTextStyles.body),
            const SizedBox(height: AppSpacing.medium),
            OutlinedButton(
              onPressed: () {
                setState(() => _isLoading = true);
                _load();
              },
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    final week = WellbeingInsights.weekSummary(
      moods: _moods,
      journals: _journals,
      weekStart: _viewedWeekStart,
    );

    final isCurrentWeek = _viewedWeekStart == _currentWeekStart;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final alert in _alerts) ...[
          _AlertBanner(alert: alert),
          const SizedBox(height: AppSpacing.medium),
        ],

        _Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _WeekHeader(
                label: _weekLabel(week.weekStart),
                canGoBack: _canGoBack,
                canGoForward: _canGoForward,
                onBack: () => _shiftWeek(-1),
                onForward: () => _shiftWeek(1),
              ),

              const SizedBox(height: AppSpacing.large),

              SizedBox(
                height: 108,
                child: _WeekChart(days: week.days),
              ),

              const SizedBox(height: AppSpacing.large),

              if (week.isEmpty)
                Text(
                  isCurrentWeek
                      ? 'No check-ins yet this week.'
                      : 'No check-ins that week.',
                  style: AppTextStyles.caption,
                )
              else ...[
                Text(
                  'Averaging '
                  '${valenceLabel(week.average!.round()).toLowerCase()} '
                  'across ${week.daysLogged} '
                  '${week.daysLogged == 1 ? 'day' : 'days'}.',
                  style: AppTextStyles.caption,
                ),

                const SizedBox(height: AppSpacing.large),

                Row(
                  children: [
                    _Stat(
                      label: 'Check-ins',
                      value: '${week.checkIns}',
                      caption: week.checkIns == 1 ? 'entry' : 'entries',
                    ),
                    _Stat(
                      label: 'Journal',
                      value: '${week.journalEntries}',
                      caption: week.journalEntries == 1 ? 'entry' : 'entries',
                    ),

                    // The streak describes now, not the week being
                    // viewed, so it is hidden while looking back
                    // rather than showing a number that belongs to
                    // a different date.
                    if (isCurrentWeek)
                      _Stat(
                        label: 'Streak',
                        value: '$_streak',
                        caption: _streak == 1 ? 'day' : 'days',
                      )
                    else
                      const Spacer(),
                  ],
                ),

                if (week.topEmotions.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.large),
                  const Text('Most felt', style: AppTextStyles.small),
                  const SizedBox(height: AppSpacing.xSmall),
                  Text(
                    week.topEmotions.join(' · '),
                    style: AppTextStyles.body,
                  ),
                ],

                if (week.topImpacts.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.medium),
                  const Text('Most influential', style: AppTextStyles.small),
                  const SizedBox(height: AppSpacing.xSmall),
                  Text(
                    week.topImpacts.join(' · '),
                    style: AppTextStyles.body,
                  ),
                ],
              ],
            ],
          ),
        ),
      ],
    );
  }

  // ===========================================================
  // Week Label
  // ===========================================================
  String _weekLabel(DateTime start) {
    if (start == _currentWeekStart) return 'This week';

    final weeksBack = _currentWeekStart.difference(start).inDays ~/ 7;

    if (weeksBack == 1) return 'Last week';

    final end = start.add(const Duration(days: 6));

    return '${_shortDate(start)} – ${_shortDate(end)}';
  }

  String _shortDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${months[date.month - 1]} ${date.day}';
  }
}

// ===========================================================
// Week Header
// Title with the two arrows. A disabled arrow stays in place
// rather than disappearing, so the controls do not shift
// position as you page through.
// ===========================================================
class _WeekHeader extends StatelessWidget {
  const _WeekHeader({
    required this.label,
    required this.canGoBack,
    required this.canGoForward,
    required this.onBack,
    required this.onForward,
  });

  final String label;
  final bool canGoBack;
  final bool canGoForward;
  final VoidCallback onBack;
  final VoidCallback onForward;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(label, style: AppTextStyles.heading2),
        ),
        _ArrowButton(
          icon: Icons.chevron_left,
          tooltip: 'Previous week',
          onTap: canGoBack ? onBack : null,
        ),
        const SizedBox(width: AppSpacing.xSmall),
        _ArrowButton(
          icon: Icons.chevron_right,
          tooltip: 'Next week',
          onTap: canGoForward ? onForward : null,
        ),
      ],
    );
  }
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isEnabled = onTap != null;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Container(
            height: 36,
            width: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isEnabled
                  ? AppColors.surfaceMuted
                  : AppColors.surfaceMuted.withValues(alpha: 0.4),
            ),
            child: Icon(
              icon,
              size: 20,
              color: isEnabled
                  ? AppColors.textPrimary
                  : AppColors.textSecondary.withValues(alpha: 0.4),
            ),
          ),
        ),
      ),
    );
  }
}

// ===========================================================
// Week Chart
// Seven bars with weekday initials.
//
// A day with no check-in is a short grey stub rather than a
// zero-height or neutral bar. Drawing a missing day as neutral
// would invent data the person never entered.
// ===========================================================
class _WeekChart extends StatelessWidget {
  const _WeekChart({required this.days});

  final List<DayPoint> days;

  // Indexed by DateTime.weekday, which starts at Monday = 1.
  static const List<String> _initials = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (final point in days)
          Expanded(
            child: _Bar(
              point: point,
              initial: _initials[point.date.weekday - 1],
            ),
          ),
      ],
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({
    required this.point,
    required this.initial,
  });

  final DayPoint point;
  final String initial;

  @override
  Widget build(BuildContext context) {
    final average = point.average;

    // -2..2 mapped onto a 0..1 height.
    final fraction = average == null ? null : (average + 2) / 4;

    final today = DateTime.now();

    final isToday = point.date.year == today.year &&
        point.date.month == today.month &&
        point.date.day == today.day;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(
          height: 78,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              width: 20,
              height: fraction == null ? 6 : 10 + (66 * fraction),
              decoration: BoxDecoration(
                color: average == null
                    ? AppColors.border
                    : valenceColor(average.round()),
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          initial,
          style: AppTextStyles.small.copyWith(
            fontSize: 11,
            letterSpacing: 0,
            fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
            color: isToday ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

// ===========================================================
// Alert Banner
//
// Deliberately not red and not an error icon. This is an
// observation, and dressing it as a warning makes a hard week
// feel like a diagnosis.
// ===========================================================
class _AlertBanner extends StatelessWidget {
  const _AlertBanner({required this.alert});

  final WellbeingAlert alert;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.regular),
      decoration: BoxDecoration(
        color: AppColors.yellow40,
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(alert.title, style: AppTextStyles.title),
          const SizedBox(height: AppSpacing.xSmall),
          Text(alert.message, style: AppTextStyles.body),
          const SizedBox(height: AppSpacing.small),
          const Text(
            'If this has been going on for a while, talking to someone you '
            'trust or a professional is worth more than any app.',
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.label,
    required this.value,
    required this.caption,
  });

  final String label;
  final String value;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.small),
          const SizedBox(height: 2),
          Text(value, style: AppTextStyles.heading2),
          Text(caption, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.regular),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        boxShadow: AppShadows.card,
      ),
      child: child,
    );
  }
}
