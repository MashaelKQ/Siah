import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/habit_quest.dart';

class WeeklyQuestService {
  WeeklyQuestService._();

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ===========================================================
  // Weekly Quest Collection
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
  // User Document
  // ===========================================================
  static DocumentReference<Map<String, dynamic>> _userDocument(
    String userId,
  ) {
    return _firestore.collection('users').doc(userId);
  }

  // ===========================================================
  // Week ID
  // Example: 2026-W34
  // ===========================================================
  static String weekId(DateTime date) {
    final firstDayOfYear = DateTime(
      date.year,
      1,
      1,
    );

    final daysSinceStart = date.difference(firstDayOfYear).inDays;

    final weekNumber = ((daysSinceStart + firstDayOfYear.weekday - 1) ~/ 7) + 1;

    final paddedWeek = weekNumber.toString().padLeft(
          2,
          '0',
        );

    return '${date.year}-W$paddedWeek';
  }

  // ===========================================================
  // Save Weekly Quest Plan
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
  // Get Current Weekly Plan
  // ===========================================================
  static Future<List<HabitQuest>> getCurrentWeeklyPlan(
    String userId,
  ) async {
    final id = weekId(
      DateTime.now(),
    );

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
  // Complete Quest
  // Each quest can only be completed once per week.
  // Awards +1 Wellness Point.
  // ===========================================================
  static Future<void> completeQuest({
    required String userId,
    required String questId,
  }) async {
    final weeklyReference = _weeklyQuests(userId).doc(
      weekId(DateTime.now()),
    );

    final userReference = _userDocument(userId);

    await _firestore.runTransaction(
      (transaction) async {
        final weeklySnapshot = await transaction.get(
          weeklyReference,
        );

        final data = weeklySnapshot.data();

        if (!weeklySnapshot.exists || data == null) {
          return;
        }

        final questData = data['quests'] as List<dynamic>? ?? [];

        bool newlyCompleted = false;

        final updatedQuests = questData.map(
          (item) {
            final map = Map<String, dynamic>.from(
              item as Map,
            );

            if (map['id'] != questId) {
              return map;
            }

            final alreadyCompleted = map['isCompleted'] as bool? ?? false;

            if (!alreadyCompleted) {
              map['isCompleted'] = true;
              newlyCompleted = true;
            }

            return map;
          },
        ).toList();

        if (!newlyCompleted) {
          return;
        }

        transaction.update(
          weeklyReference,
          {
            'quests': updatedQuests,
          },
        );

        transaction.set(
          userReference,
          {
            'wellnessPoints': FieldValue.increment(1),
          },
          SetOptions(
            merge: true,
          ),
        );
      },
    );
  }

  // ===========================================================
  // Undo Quest
  // Marks the quest incomplete and removes 1 point.
  // ===========================================================
  static Future<void> undoQuest({
    required String userId,
    required String questId,
  }) async {
    final weeklyReference = _weeklyQuests(userId).doc(
      weekId(DateTime.now()),
    );

    final userReference = _userDocument(userId);

    await _firestore.runTransaction(
      (transaction) async {
        final weeklySnapshot = await transaction.get(
          weeklyReference,
        );

        final userSnapshot = await transaction.get(
          userReference,
        );

        final data = weeklySnapshot.data();

        if (!weeklySnapshot.exists || data == null) {
          return;
        }

        final questData = data['quests'] as List<dynamic>? ?? [];

        bool wasCompleted = false;

        final updatedQuests = questData.map(
          (item) {
            final map = Map<String, dynamic>.from(
              item as Map,
            );

            if (map['id'] != questId) {
              return map;
            }

            final completed = map['isCompleted'] as bool? ?? false;

            if (completed) {
              map['isCompleted'] = false;
              wasCompleted = true;
            }

            return map;
          },
        ).toList();

        if (!wasCompleted) {
          return;
        }

        transaction.update(
          weeklyReference,
          {
            'quests': updatedQuests,
          },
        );

        final currentPoints =
            userSnapshot.data()?['wellnessPoints'] as int? ?? 0;

        transaction.set(
          userReference,
          {
            'wellnessPoints': currentPoints > 0 ? currentPoints - 1 : 0,
          },
          SetOptions(
            merge: true,
          ),
        );
      },
    );
  }

  // ===========================================================
  // Wellness Points Stream
  // Keeps the points indicator updated live.
  // ===========================================================
  static Stream<int> wellnessPointsStream(
    String userId,
  ) {
    return _userDocument(userId).snapshots().map(
      (snapshot) {
        return snapshot.data()?['wellnessPoints'] as int? ?? 0;
      },
    );
  }

  // ===========================================================
  // Redeem Reward
  //
  // Checks the user's current Wellness Points.
  // If the user has enough:
  // - deducts the required points
  // - stores a redemption record in Firestore
  //
  // Returns:
  // true  = redemption successful
  // false = not enough points
  // ===========================================================
  static Future<bool> redeemReward({
    required String userId,
    required String rewardId,
    required String rewardTitle,
    required int pointsRequired,
  }) async {
    final userReference = _userDocument(userId);

    final redemptionReference = userReference
        .collection(
          'reward_redemptions',
        )
        .doc();

    return _firestore.runTransaction<bool>(
      (transaction) async {
        final userSnapshot = await transaction.get(
          userReference,
        );

        final currentPoints =
            userSnapshot.data()?['wellnessPoints'] as int? ?? 0;

        // Not enough points
        if (currentPoints < pointsRequired) {
          return false;
        }

        // Deduct Wellness Points
        transaction.set(
          userReference,
          {
            'wellnessPoints': currentPoints - pointsRequired,
          },
          SetOptions(
            merge: true,
          ),
        );

        // Save reward redemption history
        transaction.set(
          redemptionReference,
          {
            'rewardId': rewardId,
            'rewardTitle': rewardTitle,
            'pointsUsed': pointsRequired,
            'redeemedAt': FieldValue.serverTimestamp(),
            'status': 'redeemed',
          },
        );

        return true;
      },
    );
  }
}
