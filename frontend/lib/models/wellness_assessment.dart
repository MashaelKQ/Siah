class WellnessAssessment {
  const WellnessAssessment({
    required this.id,
    required this.userId,
    required this.year,
    required this.month,
    required this.score,
    required this.answers,
    required this.completedAt,
  });

  final String id;
  final String userId;
  final int year;
  final int month;
  final int score;
  final List<int> answers;
  final DateTime completedAt;

  // ===========================================================
  // Firestore Serialization
  // Converts the assessment into data that can be stored.
  // ===========================================================
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'year': year,
      'month': month,
      'score': score,
      'answers': answers,
      'completedAt': completedAt.toIso8601String(),
    };
  }

  // ===========================================================
  // Firestore Deserialization
  // Creates a WellnessAssessment from stored Firestore data.
  // ===========================================================
  factory WellnessAssessment.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    return WellnessAssessment(
      id: id,
      userId: map['userId'] as String? ?? '',
      year: map['year'] as int? ?? 0,
      month: map['month'] as int? ?? 0,
      score: map['score'] as int? ?? 0,
      answers: List<int>.from(
        map['answers'] as List<dynamic>? ?? [],
      ),
      completedAt: DateTime.tryParse(
            map['completedAt'] as String? ?? '',
          ) ??
          DateTime.now(),
    );
  }
}
