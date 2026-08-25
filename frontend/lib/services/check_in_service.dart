import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/check_in_models.dart';

// ===========================================================
// Describe Firestore Error
// Turns a thrown error into a sentence that names the actual
// cause.
//
// A single "check your connection" message cannot tell a rules
// rejection apart from a dead network, which are the two most
// common failures and have completely different fixes.
//
// In debug builds the raw code is appended, so what you see on
// screen is enough to diagnose without reading logs.
// ===========================================================
String describeFirestoreError(Object error) {
  if (error is! FirebaseException) {
    return 'Something went wrong. Please try again.';
  }

  final message = switch (error.code) {
    'permission-denied' =>
      'Saving was blocked by your Firestore security rules.',
    'unavailable' =>
      'Could not reach the database. Check the device connection.',
    'unauthenticated' => 'Your session has expired. Sign in again.',
    'not-found' => 'That record no longer exists.',
    'failed-precondition' =>
      'This query needs a Firestore index that does not exist yet.',
    'resource-exhausted' => 'The project has exceeded its Firestore quota.',
    _ => 'Saving failed. Please try again.',
  };

  if (kDebugMode) {
    return '$message  [${error.code}]';
  }

  return message;
}



class MoodService {
  MoodService._();

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ===========================================================
  // Mood Collection
  // The check-ins belonging to one user.
  // ===========================================================
  static CollectionReference<Map<String, dynamic>> _entries(
    String userId,
  ) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('mood_entries');
  }

  // ===========================================================
  // Day Id
  // Formats a date as "2026-08-15".
  //
  // Dates are handled in the device's local time so a day ends
  // at the user's midnight, not at UTC midnight.
  // ===========================================================
  static String dayId(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '${date.year}-$month-$day';
  }

  // ===========================================================
  // Entry Id
  // The full timestamp, which keeps entries in order and unique.
  // ===========================================================
  static String entryId(DateTime date) => date.toIso8601String();

  // ===========================================================
  // Save Entry
  // ===========================================================
  static Future<void> saveEntry(MoodEntry entry) async {
    await _entries(entry.userId).doc(entry.id).set(entry.toMap());
  }

  // ===========================================================
  // Entries For Day
  // Reads every check-in recorded on one date.
  //
  // Timestamps are stored as text, so a range between the start
  // of the day and the start of the next one selects the day
  // without needing a composite index.
  // ===========================================================
  static Future<List<MoodEntry>> getEntriesForDay(
    String userId,
    DateTime date,
  ) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));

    final snapshot = await _entries(userId)
        .where('createdAt', isGreaterThanOrEqualTo: start.toIso8601String())
        .where('createdAt', isLessThan: end.toIso8601String())
        .orderBy('createdAt')
        .get();

    return snapshot.docs
        .map((document) => MoodEntry.fromMap(document.id, document.data()))
        .toList();
  }

  // ===========================================================
  // Recent Entries
  // Reads the check-ins from the last given number of days,
  // newest first.
  // ===========================================================
  static Future<List<MoodEntry>> getRecentEntries(
    String userId, {
    int days = 30,
  }) async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: days - 1));

    final snapshot = await _entries(userId)
        .where('createdAt', isGreaterThanOrEqualTo: start.toIso8601String())
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((document) => MoodEntry.fromMap(document.id, document.data()))
        .toList();
  }

  // ===========================================================
  // Delete Entry
  // ===========================================================
  static Future<void> deleteEntry({
    required String userId,
    required String entryId,
  }) async {
    await _entries(userId).doc(entryId).delete();
  }
}



class JournalService {
  JournalService._();

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ===========================================================
  // Journal Collection
  // The entries belonging to one user.
  // ===========================================================
  static CollectionReference<Map<String, dynamic>> _entries(
    String userId,
  ) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('journal_entries');
  }

  // ===========================================================
  // Day Id
  // One entry per day, named "2026-08-15", so saving again
  // updates today's entry instead of creating a duplicate.
  // ===========================================================
  static String dayId(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '${date.year}-$month-$day';
  }

  // ===========================================================
  // Save Entry
  // ===========================================================
  static Future<void> saveEntry(JournalEntry entry) async {
    await _entries(entry.userId).doc(entry.id).set(entry.toMap());
  }

  // ===========================================================
  // Entry For Day
  // Returns null when nothing has been written for that date.
  // ===========================================================
  static Future<JournalEntry?> getEntryForDay(
    String userId,
    DateTime date,
  ) async {
    final document = await _entries(userId).doc(dayId(date)).get();

    final data = document.data();

    if (!document.exists || data == null) {
      return null;
    }

    return JournalEntry.fromMap(document.id, data);
  }

  // ===========================================================
  // Recent Entries
  // Newest first, for the history list.
  // ===========================================================
  static Future<List<JournalEntry>> getRecentEntries(
    String userId, {
    int limit = 50,
  }) async {
    final snapshot = await _entries(userId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs
        .map((document) => JournalEntry.fromMap(document.id, document.data()))
        .toList();
  }

  // ===========================================================
  // Delete Entry
  // ===========================================================
  static Future<void> deleteEntry({
    required String userId,
    required String entryId,
  }) async {
    await _entries(userId).doc(entryId).delete();
  }
}
