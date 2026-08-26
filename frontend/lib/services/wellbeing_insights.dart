import '../models/check_in_models.dart';

// ===========================================================
// Wellbeing Insights
//
// Turns raw check-ins into a summary and, when a pattern is
// clear enough, an early warning.
//
// Everything here is a pure function of the entries passed in.
// No Firestore, no clock, no notifications. That is deliberate:
// it makes every trigger testable without a device, a network
// or a fake user, which is the only way to be confident these
// thresholds behave the way you intend.
//
// WHAT THIS IS NOT
// This does not detect crises and must never be presented as
// if it does. It notices that several ordinary days in a row
// have been rated low. That is a prompt to check in with
// yourself, not an assessment of risk.
// ===========================================================

// ===========================================================
// Thresholds
// Gathered here so they can be tuned in one place, and so a
// test can state exactly which number it is exercising.
// ===========================================================
class AlertThresholds {
  AlertThresholds._();

  // Sustained low mood
  static const int sustainedWindowDays = 7;
  static const int sustainedMinEntries = 4;
  static const double sustainedMaxAverage = -1.0;

  // Downward shift
  static const int shiftRecentDays = 3;
  static const int shiftBaselineDays = 7;
  static const int shiftMinRecentEntries = 2;
  static const int shiftMinBaselineEntries = 3;
  static const double shiftMinDrop = 1.0;

  // Recurring pressure
  static const int pressureWindowDays = 14;
  static const int pressureMinOccurrences = 4;
  static const double pressureMinShare = 0.6;

  // Went quiet
  static const int quietDaysWithoutEntry = 5;
  static const int quietPriorWindowDays = 14;
  static const int quietMinPriorEntries = 4;

  // No alert of the same kind twice inside this window.
  static const int cooldownDays = 7;
}

enum WellbeingAlertType {
  sustainedLow,
  downwardShift,
  recurringPressure,
  wentQuiet,
}

// ===========================================================
// Wellbeing Alert
//
// Wording matters more than the maths here. Every message
// describes what the app observed, never what it concludes
// about the person, and offers one small action rather than
// an instruction.
// ===========================================================
class WellbeingAlert {
  const WellbeingAlert({
    required this.type,
    required this.title,
    required this.message,
    this.focus,
  });

  final WellbeingAlertType type;
  final String title;
  final String message;

  // The impact area involved, for recurringPressure only.
  final String? focus;

  String get id => type.name;
}

// ===========================================================
// Day Point
// One day's average valence, for the trend chart. A null
// average means no check-in that day, which is drawn as a gap
// rather than as a zero.
// ===========================================================
class DayPoint {
  const DayPoint({
    required this.date,
    required this.average,
  });

  final DateTime date;
  final double? average;
}

// ===========================================================
// Week Summary
// One calendar week of check-ins.
//
// The dashboard shows a week at a time and steps backwards
// through history, so everything here is scoped to a window
// rather than to "recently".
// ===========================================================
class WeekSummary {
  const WeekSummary({
    required this.weekStart,
    required this.days,
    required this.checkIns,
    required this.average,
    required this.topEmotions,
    required this.topImpacts,
    required this.journalEntries,
  });

  final DateTime weekStart;
  final List<DayPoint> days;
  final int checkIns;
  final double? average;
  final List<String> topEmotions;
  final List<String> topImpacts;
  final int journalEntries;

  DateTime get weekEnd => weekStart.add(const Duration(days: 6));

  int get daysLogged =>
      days.where((point) => point.average != null).length;

  bool get isEmpty => checkIns == 0;
}

class WellbeingInsights {
  WellbeingInsights._();

  // ===========================================================
  // Week Start
  // The Sunday on or before the given date.
  //
  // Change `weekStartsOn` if your users read Monday as the
  // first day; everything else follows from this one value.
  // ===========================================================
  static const int weekStartsOn = DateTime.sunday;

  static DateTime weekStartFor(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);

    final difference = (day.weekday - weekStartsOn + 7) % 7;

    return day.subtract(Duration(days: difference));
  }

  // ===========================================================
  // Week Summary
  // Everything the dashboard shows for one week.
  // ===========================================================
  static WeekSummary weekSummary({
    required List<MoodEntry> moods,
    required List<JournalEntry> journals,
    required DateTime weekStart,
  }) {
    final start = DateTime(
      weekStart.year,
      weekStart.month,
      weekStart.day,
    );

    final end = start.add(const Duration(days: 7));

    final inWeek = moods
        .where((entry) =>
            !entry.createdAt.isBefore(start) &&
            entry.createdAt.isBefore(end))
        .toList();

    final journalsInWeek = journals
        .where((entry) =>
            !entry.createdAt.isBefore(start) &&
            entry.createdAt.isBefore(end))
        .length;

    return WeekSummary(
      weekStart: start,
      days: _daysBetween(inWeek, start, 7),
      checkIns: inWeek.length,
      average: _average(inWeek),
      topEmotions: _mostCommon(
        inWeek.expand((entry) => entry.log.emotions),
        limit: 3,
      ),
      topImpacts: _mostCommon(
        inWeek.expand((entry) => entry.log.impacts),
        limit: 3,
      ),
      journalEntries: journalsInWeek,
    );
  }

  // ===========================================================
  // Current Streak
  // Consecutive days ending today or yesterday.
  // ===========================================================
  static int currentStreak(List<MoodEntry> moods, DateTime now) {
    return _streak(moods, DateTime(now.year, now.month, now.day));
  }

  // ===========================================================
  // Detect Alerts
  //
  // Order matters: the first match wins for any given run, so
  // the user gets one clear message rather than four at once.
  // Four notifications about the same bad week is not four
  // times as helpful.
  // ===========================================================
  static List<WellbeingAlert> detectAlerts({
    required List<MoodEntry> moods,
    required DateTime now,
  }) {
    final today = DateTime(now.year, now.month, now.day);

    final checks = [
      () => _sustainedLow(moods, today),
      () => _downwardShift(moods, today),
      () => _recurringPressure(moods, today),
      () => _wentQuiet(moods, today),
    ];

    for (final check in checks) {
      final alert = check();

      if (alert != null) return [alert];
    }

    return const [];
  }

  // ===========================================================
  // Trigger 1 — Sustained Low
  // Several days in a row rated unpleasant. Requires four
  // check-ins so one bad Tuesday cannot set it off.
  // ===========================================================
  static WellbeingAlert? _sustainedLow(
    List<MoodEntry> moods,
    DateTime today,
  ) {
    final window = _within(moods, today, AlertThresholds.sustainedWindowDays);

    if (window.length < AlertThresholds.sustainedMinEntries) return null;

    final average = _average(window);

    if (average == null) return null;
    if (average > AlertThresholds.sustainedMaxAverage) return null;

    return const WellbeingAlert(
      type: WellbeingAlertType.sustainedLow,
      title: 'This week has been heavy',
      message:
          'Most of your check-ins this week have been on the unpleasant '
          'side. That is worth paying attention to, not worrying about. '
          'Is there one small thing that usually helps?',
    );
  }

  // ===========================================================
  // Trigger 2 — Downward Shift
  // A clear drop against the person's own recent baseline,
  // which catches someone falling from good to average as well
  // as average to low.
  // ===========================================================
  static WellbeingAlert? _downwardShift(
    List<MoodEntry> moods,
    DateTime today,
  ) {
    final recent = _within(moods, today, AlertThresholds.shiftRecentDays);

    final baseline = _between(
      moods,
      today,
      fromDaysAgo: AlertThresholds.shiftRecentDays +
          AlertThresholds.shiftBaselineDays,
      toDaysAgo: AlertThresholds.shiftRecentDays,
    );

    if (recent.length < AlertThresholds.shiftMinRecentEntries) return null;
    if (baseline.length < AlertThresholds.shiftMinBaselineEntries) return null;

    final recentAverage = _average(recent);
    final baselineAverage = _average(baseline);

    if (recentAverage == null || baselineAverage == null) return null;

    final drop = baselineAverage - recentAverage;

    if (drop < AlertThresholds.shiftMinDrop) return null;

    return const WellbeingAlert(
      type: WellbeingAlertType.downwardShift,
      title: 'Something shifted recently',
      message:
          'The last few days have been rated lower than your usual. '
          'Sometimes naming what changed is enough to see it clearly.',
    );
  }

  // ===========================================================
  // Trigger 3 — Recurring Pressure
  // The same part of life attached to most difficult days. The
  // most useful of the four, because it points somewhere.
  // ===========================================================
  static WellbeingAlert? _recurringPressure(
    List<MoodEntry> moods,
    DateTime today,
  ) {
    final window = _within(moods, today, AlertThresholds.pressureWindowDays);

    final difficult =
        window.where((entry) => entry.log.valence < 0).toList();

    if (difficult.length < AlertThresholds.pressureMinOccurrences) return null;

    final counts = <String, int>{};

    for (final entry in difficult) {
      for (final impact in entry.log.impacts.toSet()) {
        counts[impact] = (counts[impact] ?? 0) + 1;
      }
    }

    if (counts.isEmpty) return null;

    final ranked = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final top = ranked.first;
    final share = top.value / difficult.length;

    if (top.value < AlertThresholds.pressureMinOccurrences) return null;
    if (share < AlertThresholds.pressureMinShare) return null;

    return WellbeingAlert(
      type: WellbeingAlertType.recurringPressure,
      title: '${top.key} keeps coming up',
      message:
          'You have linked ${top.key.toLowerCase()} to most of your harder '
          'days over the last two weeks. Naming a pattern is the part that '
          'makes it possible to do something about it.',
      focus: top.key,
    );
  }

  // ===========================================================
  // Trigger 4 — Went Quiet
  // Someone who was checking in regularly and stopped. Silence
  // is a weak signal on its own, so this only fires for people
  // who had an established habit.
  // ===========================================================
  static WellbeingAlert? _wentQuiet(
    List<MoodEntry> moods,
    DateTime today,
  ) {
    if (moods.isEmpty) return null;

    final latest = moods
        .map((entry) => entry.createdAt)
        .reduce((a, b) => a.isAfter(b) ? a : b);

    final daysSince = today
        .difference(DateTime(latest.year, latest.month, latest.day))
        .inDays;

    if (daysSince < AlertThresholds.quietDaysWithoutEntry) return null;

    final prior = _between(
      moods,
      today,
      fromDaysAgo: daysSince + AlertThresholds.quietPriorWindowDays,
      toDaysAgo: daysSince,
    );

    if (prior.length < AlertThresholds.quietMinPriorEntries) return null;

    return const WellbeingAlert(
      type: WellbeingAlertType.wentQuiet,
      title: 'It has been a few days',
      message:
          'You were checking in regularly and then stopped. No pressure '
          'either way, but the door is open whenever you want it.',
    );
  }

  // ===========================================================
  // Helpers
  // ===========================================================

  static List<MoodEntry> _within(
    List<MoodEntry> moods,
    DateTime today,
    int days,
  ) {
    final from = today.subtract(Duration(days: days - 1));

    return moods
        .where((entry) => !entry.createdAt.isBefore(from))
        .toList();
  }

  static List<MoodEntry> _between(
    List<MoodEntry> moods,
    DateTime today, {
    required int fromDaysAgo,
    required int toDaysAgo,
  }) {
    final from = today.subtract(Duration(days: fromDaysAgo - 1));
    final to = today.subtract(Duration(days: toDaysAgo - 1));

    return moods
        .where((entry) =>
            !entry.createdAt.isBefore(from) && entry.createdAt.isBefore(to))
        .toList();
  }

  static double? _average(List<MoodEntry> moods) {
    if (moods.isEmpty) return null;

    final total = moods.fold<int>(
      0,
      (sum, entry) => sum + entry.log.valence,
    );

    return total / moods.length;
  }

  static List<DayPoint> _daysBetween(
    List<MoodEntry> moods,
    DateTime start,
    int days,
  ) {
    final points = <DayPoint>[];

    for (var offset = 0; offset < days; offset++) {
      final day = start.add(Duration(days: offset));

      final onDay = moods.where((entry) {
        final created = entry.createdAt;

        return created.year == day.year &&
            created.month == day.month &&
            created.day == day.day;
      }).toList();

      points.add(
        DayPoint(
          date: day,
          average: _average(onDay),
        ),
      );
    }

    return points;
  }

  static List<String> _mostCommon(
    Iterable<String> values, {
    required int limit,
  }) {
    final counts = <String, int>{};

    for (final value in values) {
      counts[value] = (counts[value] ?? 0) + 1;
    }

    final ranked = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return ranked.take(limit).map((entry) => entry.key).toList();
  }

  // ===========================================================
  // Streak
  // Consecutive days ending today or yesterday. Allowing
  // yesterday means the streak does not appear broken simply
  // because it is nine in the morning.
  // ===========================================================
  static int _streak(List<MoodEntry> moods, DateTime today) {
    if (moods.isEmpty) return 0;

    final days = moods
        .map((entry) => DateTime(
              entry.createdAt.year,
              entry.createdAt.month,
              entry.createdAt.day,
            ))
        .toSet();

    var cursor = today;

    if (!days.contains(cursor)) {
      cursor = today.subtract(const Duration(days: 1));

      if (!days.contains(cursor)) return 0;
    }

    var streak = 0;

    while (days.contains(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    return streak;
  }
}
