import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'wellbeing_insights.dart';

// ===========================================================
// Notification Service
//
// Two jobs: a daily reminder to check in, and the occasional
// wellbeing alert.
//
// Restraint is the whole design here. An app that notifies
// often gets its notifications switched off, and then it
// cannot reach the person on the day it matters. So:
//
//   - at most one alert of a given kind every seven days
//   - nothing between 21:00 and 08:00
//   - a single daily reminder, which the user chooses or turns
//     off entirely
//
// Scheduling is inexact on purpose. Exact alarms need a
// special Android permission and a reminder that lands a few
// minutes late is fine.
// ===========================================================
class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static bool _isReady = false;

  static const int _reminderId = 1001;
  static const int _alertId = 2001;

  static const AndroidNotificationDetails _reminderChannel =
      AndroidNotificationDetails(
    'siah_reminders',
    'Check-in reminders',
    channelDescription: 'A daily nudge to record how you are feeling.',
    importance: Importance.defaultImportance,
    priority: Priority.defaultPriority,
  );

  // Alerts use a separate channel so someone can silence the
  // daily reminder without losing these, or the other way
  // round. One channel for everything removes that choice.
  static const AndroidNotificationDetails _alertChannel =
      AndroidNotificationDetails(
    'siah_wellbeing',
    'Wellbeing notices',
    channelDescription:
        'Occasional notes when your check-ins show a pattern.',
    importance: Importance.defaultImportance,
    priority: Priority.defaultPriority,
  );

  // ===========================================================
  // Initialize
  // Safe to call more than once.
  // ===========================================================
  static Future<void> initialize() async {
    if (_isReady) return;

    tz_data.initializeTimeZones();

    final timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Permission is requested later, on a screen where the user
    // has context for why. Asking at launch gets a reflexive no.
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
        macOS: iosSettings,
      ),
    );

    _isReady = true;
  }

  // ===========================================================
  // Request Permission
  // Returns false when the user declines, so the caller can
  // leave the toggle switched off rather than lying about it.
  // ===========================================================
  static Future<bool> requestPermission() async {
    await initialize();

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (android != null) {
      return await android.requestNotificationsPermission() ?? false;
    }

    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();

    if (ios != null) {
      return await ios.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    }

    return false;
  }

  // ===========================================================
  // Daily Reminder
  // One repeating notification at the chosen hour.
  // ===========================================================
  static Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
  }) async {
    await initialize();
    await cancelDailyReminder();

    await _plugin.zonedSchedule(
      _reminderId,
      'How are you feeling?',
      'A moment to check in with yourself.',
      _nextOccurrence(hour, minute),
      const NotificationDetails(
        android: _reminderChannel,
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> cancelDailyReminder() async {
    await initialize();
    await _plugin.cancel(_reminderId);
  }

  // ===========================================================
  // Maybe Show Alert
  //
  // The gatekeeper. Everything that decides whether a person is
  // interrupted lives here rather than in the UI, so there is
  // one place to audit.
  //
  // Returns true when a notification was actually shown.
  // ===========================================================
  static Future<bool> maybeShowAlert({
    required String userId,
    required WellbeingAlert alert,
    DateTime? now,
  }) async {
    final moment = now ?? DateTime.now();

    if (_isQuietHours(moment)) return false;
    if (await _isInCooldown(userId, alert, moment)) return false;

    await initialize();

    await _plugin.show(
      _alertId,
      alert.title,
      alert.message,
      const NotificationDetails(
        android: _alertChannel,
        iOS: DarwinNotificationDetails(),
      ),
    );

    await _recordAlertShown(userId, alert, moment);

    return true;
  }

  // ===========================================================
  // Quiet Hours
  // Nothing lands overnight. A notification at 03:00 about a
  // difficult week helps nobody.
  // ===========================================================
  static bool _isQuietHours(DateTime moment) {
    return moment.hour >= 21 || moment.hour < 8;
  }

  // ===========================================================
  // Cooldown
  //
  // Stored as a field on the user document rather than in a new
  // subcollection, so this needs no extra Firestore rule.
  // ===========================================================
  static Future<bool> _isInCooldown(
    String userId,
    WellbeingAlert alert,
    DateTime moment,
  ) async {
    try {
      final document =
          await _firestore.collection('users').doc(userId).get();

      final data = document.data();

      if (data == null) return false;

      final shown = data['alertsLastShown'] as Map<String, dynamic>?;

      if (shown == null) return false;

      final last = DateTime.tryParse(shown[alert.id] as String? ?? '');

      if (last == null) return false;

      return moment.difference(last).inDays < AlertThresholds.cooldownDays;
    } catch (error) {
      // If the check fails, stay quiet. Failing towards not
      // interrupting someone is the safer direction.
      debugPrint('Alert cooldown check failed: $error');
      return true;
    }
  }

  static Future<void> _recordAlertShown(
    String userId,
    WellbeingAlert alert,
    DateTime moment,
  ) async {
    try {
      await _firestore.collection('users').doc(userId).set(
        {
          'alertsLastShown': {
            alert.id: moment.toIso8601String(),
          },
        },
        SetOptions(merge: true),
      );
    } catch (error) {
      debugPrint('Could not record alert: $error');
    }
  }

  // ===========================================================
  // Next Occurrence
  // The next time today or tomorrow that matches the hour.
  // ===========================================================
  static tz.TZDateTime _nextOccurrence(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);

    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    return scheduled;
  }

  // ===========================================================
  // Test Notification
  // Fires in a few seconds, bypassing quiet hours and cooldown,
  // so permissions and channels can be verified at any time of
  // day. Debug builds only.
  // ===========================================================
  static Future<void> showTestNotification() async {
    if (!kDebugMode) return;

    await initialize();

    await _plugin.zonedSchedule(
      9999,
      'Test notification',
      'If you can see this, notifications are working.',
      tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
      const NotificationDetails(
        android: _alertChannel,
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  // ===========================================================
  // Clear Cooldowns
  // Lets a tester fire the same alert repeatedly instead of
  // waiting a week between runs. Debug builds only.
  // ===========================================================
  static Future<void> clearCooldowns(String userId) async {
    if (!kDebugMode) return;

    await _firestore.collection('users').doc(userId).set(
      {'alertsLastShown': <String, dynamic>{}},
      SetOptions(merge: true),
    );
  }
}
