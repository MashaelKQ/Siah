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

class WellbeingDashboard extends StatefulWidget {
  const WellbeingDashboard({super.key});

  @override
  State<WellbeingDashboard> createState() => _WellbeingDashboardState();
}

class _WellbeingDashboardState extends State<WellbeingDashboard> {
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

    _currentWeekStart = WellbeingInsights.weekStartFor(
      DateTime.now(),
    );

    _viewedWeekStart = _currentWeekStart;

    _load();
  }

  Future<void> _load() async {
    final user = AuthService.currentUser;

    if (user == null) {
      setState(() {
        _isLoading = false;
      });
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

      final alerts = WellbeingInsights.detectAlerts(
        moods: moods,
        now: now,
      );

      if (!mounted) return;

      setState(() {
        _moods = moods;
        _journals = journals;
        _alerts = alerts;
        _streak = WellbeingInsights.currentStreak(
          moods,
          now,
        );
        _isLoading = false;
        _error = null;
      });

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

  bool get _canGoBack {
    final earliest = _currentWeekStart.subtract(
      const Duration(
        days: _historyDays,
      ),
    );

    return _viewedWeekStart.isAfter(earliest);
  }

  bool get _canGoForward {
    return _viewedWeekStart.isBefore(_currentWeekStart);
  }

  void _shiftWeek(int weeks) {
    setState(() {
      _viewedWeekStart = _viewedWeekStart.add(
        Duration(
          days: weeks * 7,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const _Panel(
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: 20,
          ),
          child: Center(
            child: LoadingIndicator(),
          ),
        ),
      );
    }

    final error = _error;

    if (error != null) {
      return _Panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              error,
              style: AppTextStyles.body,
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                });

                _load();
              },
              child: const Text(
                'Try Again',
              ),
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
          _AlertBanner(
            alert: alert,
          ),
          const SizedBox(
            height: 8,
          ),
        ],
        _Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===============================================
              // Week Header
              // ===============================================
              _WeekHeader(
                label: _weekLabel(
                  week.weekStart,
                ),
                canGoBack: _canGoBack,
                canGoForward: _canGoForward,
                onBack: () => _shiftWeek(-1),
                onForward: () => _shiftWeek(1),
              ),

              const SizedBox(
                height: 10,
              ),

              // ===============================================
              // Compact Weekly Chart
              // ===============================================
              SizedBox(
                height: 68,
                child: _WeekChart(
                  days: week.days,
                ),
              ),

              const SizedBox(
                height: 8,
              ),

              if (week.isEmpty)
                Text(
                  isCurrentWeek
                      ? 'No check-ins yet this week.'
                      : 'No check-ins that week.',
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 11,
                  ),
                )
              else ...[
                // =============================================
                // Compact Summary
                // =============================================
                Text(
                  'Average: '
                  '${valenceLabel(
                    week.average!.round(),
                  )} • '
                  '${week.daysLogged} '
                  '${week.daysLogged == 1 ? 'day' : 'days'}',
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 11,
                  ),
                ),

                const SizedBox(
                  height: 9,
                ),

                // =============================================
                // Statistics
                // =============================================
                Row(
                  children: [
                    _CompactStat(
                      label: 'Check-ins',
                      value: '${week.checkIns}',
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    _CompactStat(
                      label: 'Journal',
                      value: '${week.journalEntries}',
                    ),
                    if (isCurrentWeek) ...[
                      const SizedBox(
                        width: 8,
                      ),
                      _CompactStat(
                        label: 'Streak',
                        value: '$_streak',
                      ),
                    ],
                  ],
                ),

                if (week.topEmotions.isNotEmpty) ...[
                  const SizedBox(
                    height: 9,
                  ),
                  Row(
                    children: [
                      Text(
                        'Most felt: ',
                        style: AppTextStyles.small.copyWith(
                          fontSize: 10,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          week.topEmotions.take(2).join(
                                ' · ',
                              ),
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ],
          ),
        ),
      ],
    );
  }

  String _weekLabel(
    DateTime start,
  ) {
    if (start == _currentWeekStart) {
      return 'This week';
    }

    final weeksBack = _currentWeekStart
            .difference(
              start,
            )
            .inDays ~/
        7;

    if (weeksBack == 1) {
      return 'Last week';
    }

    final end = start.add(
      const Duration(
        days: 6,
      ),
    );

    return '${_shortDate(start)} – ${_shortDate(end)}';
  }

  String _shortDate(
    DateTime date,
  ) {
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

// =====================================================================
// Week Header
// =====================================================================
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
          child: Text(
            label,
            style: AppTextStyles.heading2.copyWith(
              fontSize: 19,
            ),
          ),
        ),
        _ArrowButton(
          icon: Icons.chevron_left,
          tooltip: 'Previous week',
          onTap: canGoBack ? onBack : null,
        ),
        const SizedBox(
          width: 5,
        ),
        _ArrowButton(
          icon: Icons.chevron_right,
          tooltip: 'Next week',
          onTap: canGoForward ? onForward : null,
        ),
      ],
    );
  }
}

// =====================================================================
// Arrow
// =====================================================================
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
            height: 32,
            width: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isEnabled
                  ? AppColors.surfaceMuted
                  : AppColors.surfaceMuted.withValues(
                      alpha: 0.4,
                    ),
            ),
            child: Icon(
              icon,
              size: 18,
              color: isEnabled
                  ? AppColors.textPrimary
                  : AppColors.textSecondary.withValues(
                      alpha: 0.4,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

// =====================================================================
// Week Chart
// =====================================================================
class _WeekChart extends StatelessWidget {
  const _WeekChart({
    required this.days,
  });

  final List<DayPoint> days;

  static const List<String> _initials = [
    'M',
    'T',
    'W',
    'T',
    'F',
    'S',
    'S',
  ];

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

// =====================================================================
// Chart Bar
// =====================================================================
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

    final fraction = average == null ? null : (average + 2) / 4;

    final today = DateTime.now();

    final isToday = point.date.year == today.year &&
        point.date.month == today.month &&
        point.date.day == today.day;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(
          height: 45,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedContainer(
              duration: const Duration(
                milliseconds: 220,
              ),
              curve: Curves.easeOut,
              width: 18,
              height: fraction == null ? 5 : 7 + (34 * fraction),
              decoration: BoxDecoration(
                color: average == null
                    ? AppColors.border
                    : valenceColor(
                        average.round(),
                      ),
                borderRadius: BorderRadius.circular(
                  AppRadius.pill,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        Text(
          initial,
          style: AppTextStyles.small.copyWith(
            fontSize: 10,
            letterSpacing: 0,
            fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
            color: isToday ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

// =====================================================================
// Compact Stat
// =====================================================================
class _CompactStat extends StatelessWidget {
  const _CompactStat({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 7,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(
            10,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.small.copyWith(
                fontSize: 9,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(
              height: 1,
            ),
            Text(
              value,
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
// Alert Banner
// =====================================================================
class _AlertBanner extends StatelessWidget {
  const _AlertBanner({
    required this.alert,
  });

  final WellbeingAlert alert;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        12,
      ),
      decoration: BoxDecoration(
        color: AppColors.yellow40,
        borderRadius: BorderRadius.circular(
          AppRadius.medium,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            alert.title,
            style: AppTextStyles.title,
          ),
          const SizedBox(
            height: 4,
          ),
          Text(
            alert.message,
            style: AppTextStyles.body,
          ),
          const SizedBox(
            height: 6,
          ),
          const Text(
            'If this has been going on for a while, talking to someone you trust or a professional is worth more than any app.',
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// Panel
// =====================================================================
class _Panel extends StatelessWidget {
  const _Panel({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        14,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          AppRadius.medium,
        ),
        boxShadow: AppShadows.card,
      ),
      child: child,
    );
  }
}
