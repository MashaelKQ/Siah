import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/wellness_assessment.dart';

class WellnessService {
  WellnessService._();

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ===========================================================
  // Assessment Collection
  // Returns the monthly wellness assessment collection
  // belonging to a specific user.
  // ===========================================================
  static CollectionReference<Map<String, dynamic>> _assessments(
    String userId,
  ) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('wellness_assessments');
  }

  // ===========================================================
  // Monthly Assessment ID
  // Creates a predictable document ID such as "2026-08".
  // This ensures one assessment per user per month.
  // ===========================================================
  static String monthlyAssessmentId(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');

    return '${date.year}-$month';
  }

  // ===========================================================
  // Save Assessment
  // Creates or updates the user's assessment for a given month.
  // ===========================================================
  static Future<void> saveAssessment(
    WellnessAssessment assessment,
  ) async {
    await _assessments(assessment.userId)
        .doc(assessment.id)
        .set(assessment.toMap());
  }

  // ===========================================================
  // Current Month Assessment
  // Retrieves this month's completed assessment if it exists.
  // ===========================================================
  static Future<WellnessAssessment?> getCurrentMonthAssessment(
    String userId,
  ) async {
    final now = DateTime.now();
    final assessmentId = monthlyAssessmentId(now);

    final document = await _assessments(userId).doc(assessmentId).get();

    final data = document.data();

    if (!document.exists || data == null) {
      return null;
    }

    return WellnessAssessment.fromMap(
      document.id,
      data,
    );
  }

  // ===========================================================
  // Latest Assessment
  // Retrieves the most recently completed wellness assessment.
  // ===========================================================
  static Future<WellnessAssessment?> getLatestAssessment(
    String userId,
  ) async {
    final snapshot = await _assessments(userId)
        .orderBy('completedAt', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      return null;
    }

    final document = snapshot.docs.first;

    return WellnessAssessment.fromMap(
      document.id,
      document.data(),
    );
  }

  // ===========================================================
  // Assessment Trend
  // Retrieves all assessments in chronological order.
  // Used later for yearly and all-time trend views.
  // ===========================================================
  static Future<List<WellnessAssessment>> getAssessmentTrend(
    String userId,
  ) async {
    final snapshot = await _assessments(userId).orderBy('completedAt').get();

    return snapshot.docs
        .map(
          (document) => WellnessAssessment.fromMap(
            document.id,
            document.data(),
          ),
        )
        .toList();
  }
}
