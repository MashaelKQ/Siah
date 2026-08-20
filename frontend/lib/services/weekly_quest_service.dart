import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/habit_quest.dart';

class WeeklyQuestService {
  WeeklyQuestService._();

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ===========================================================
  // Weekly Quest Collection
  // Returns the weekly quest collection for a specific user.
  // ===========================================================
  static CollectionReference<Map<String, dynamic>> _weeklyQuests(
    String userId,
  ) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('weekly_quests');
  }

  // ===========================================================
  // Week ID
  // Creates a stable ID for the current week.
  // Example: 2026-W34
  // ===========================================================
  static String weekId(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);

    final daysSinceStart = date.difference(firstDayOfYear).inDays;

    final weekNumber = ((daysSinceStart + firstDayOfYear.weekday - 1) ~/ 7) + 1;

    final paddedWeek = weekNumber.toString().padLeft(2, '0');

    return '${date.year}-W$paddedWeek';
  }

  // ===========================================================
  // Date ID
  // Creates a stable date value such as 2026-08-20.
  // ===========================================================
  static String dateId(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');

    final day = date.day.toString().padLeft(2, '0');

    return '${date.year}-$month-$day';
  }

  // ===========================================================
  // Save Weekly Plan
  // Stores the generated quest plan for the current week.
  // ===========================================================
  static Future<void> saveWeeklyPlan({
    required String userId,
    required String sourceAssessmentId,
    required List<HabitQuest> quests,
  }) async {
    final now = DateTime.now();
    final id = weekId(now);

    await _weeklyQuests(userId).doc(id).set(
      {
        'weekId': id,
        'sourceAssessmentId': sourceAssessmentId,
        'createdAt': now.toUtc().toIso8601String(),
        'quests': quests
            .map(
              (quest) => quest.toMap(),
            )
            .toList(),
      },
    );
  }

  // ===========================================================
  // Current Weekly Plan
  // Loads the user's quest plan for the current week.
  // ===========================================================
  static Future<List<HabitQuest>> getCurrentWeeklyPlan(
    String userId,
  ) async {
    final id = weekId(DateTime.now());

    final document = await _weeklyQuests(userId).doc(id).get();

    final data = document.data();

    if (!document.exists || data == null) {
      return [];
    }

    final questData = data['quests'] as List<dynamic>? ?? [];

    return questData
        .map(
          (item) => HabitQuest.fromMap(
            Map<String, dynamic>.from(
              item as Map,
            ),
          ),
        )
        .toList();
  }

  // ===========================================================
  // Complete Quest Today
  // Adds today's date once and prevents exceeding the
  // weekly target.
  // ===========================================================
  static Future<void> completeQuestToday({
    required String userId,
    required String questId,
  }) async {
    final weekDocumentId = weekId(DateTime.now());

    final today = dateId(DateTime.now());

    final reference = _weeklyQuests(userId).doc(weekDocumentId);

    await _firestore.runTransaction(
      (transaction) async {
        final snapshot = await transaction.get(reference);

        final data = snapshot.data();

        if (!snapshot.exists || data == null) {
          return;
        }

        final questData = data['quests'] as List<dynamic>? ?? [];

        final updatedQuests = questData.map(
          (item) {
            final map = Map<String, dynamic>.from(
              item as Map,
            );

            if (map['id'] != questId) {
              return map;
            }

            final targetCount = map['targetCount'] as int? ?? 1;

            final completedDates = List<String>.from(
              map['completedDates'] as List<dynamic>? ?? [],
            );

            if (completedDates.contains(today)) {
              return map;
            }

            if (completedDates.length >= targetCount) {
              return map;
            }

            completedDates.add(today);

            map['completedDates'] = completedDates;

            return map;
          },
        ).toList();

        transaction.update(
          reference,
          {
            'quests': updatedQuests,
          },
        );
      },
    );
  }

  // ===========================================================
  // Undo Quest Today
  // Removes today's completion if the user wants to undo it.
  // ===========================================================
  static Future<void> undoQuestToday({
    required String userId,
    required String questId,
  }) async {
    final weekDocumentId = weekId(DateTime.now());

    final today = dateId(DateTime.now());

    final reference = _weeklyQuests(userId).doc(weekDocumentId);

    await _firestore.runTransaction(
      (transaction) async {
        final snapshot = await transaction.get(reference);

        final data = snapshot.data();

        if (!snapshot.exists || data == null) {
          return;
        }

        final questData = data['quests'] as List<dynamic>? ?? [];

        final updatedQuests = questData.map(
          (item) {
            final map = Map<String, dynamic>.from(
              item as Map,
            );

            if (map['id'] != questId) {
              return map;
            }

            final completedDates = List<String>.from(
              map['completedDates'] as List<dynamic>? ?? [],
            );

            completedDates.remove(today);

            map['completedDates'] = completedDates;

            return map;
          },
        ).toList();

        transaction.update(
          reference,
          {
            'quests': updatedQuests,
          },
        );
      },
    );
  }
}
