class HabitQuest {
  const HabitQuest({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.targetCount,
    this.completedDates = const [],
  });

  // ===========================================================
  // Quest Identity
  // ===========================================================
  final String id;

  // ===========================================================
  // Quest Content
  // ===========================================================
  final String title;
  final String description;

  // ===========================================================
  // Quest Category
  // ===========================================================
  final String category;

  // ===========================================================
  // Weekly Target
  // Number of separate days the quest should be completed.
  // ===========================================================
  final int targetCount;

  // ===========================================================
  // Completion Dates
  // Stores one date for each day the quest was completed.
  //
  // Example:
  // [
  //   '2026-08-20',
  //   '2026-08-22',
  // ]
  // ===========================================================
  final List<String> completedDates;

  // ===========================================================
  // Completed Count
  // Derived from the number of unique completion dates.
  // ===========================================================
  int get completedCount => completedDates.length;

  // ===========================================================
  // Is Completed
  // Returns true when the weekly target has been reached.
  // ===========================================================
  bool get isCompleted => completedCount >= targetCount;

  // ===========================================================
  // Firestore Serialization
  // ===========================================================
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'targetCount': targetCount,
      'completedDates': completedDates,
    };
  }

  // ===========================================================
  // Firestore Deserialization
  // ===========================================================
  factory HabitQuest.fromMap(
    Map<String, dynamic> map,
  ) {
    return HabitQuest(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      category: map['category'] as String? ?? '',
      targetCount: map['targetCount'] as int? ?? 1,
      completedDates: List<String>.from(
        map['completedDates'] as List<dynamic>? ?? [],
      ),
    );
  }

  // ===========================================================
  // Copy With
  // ===========================================================
  HabitQuest copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    int? targetCount,
    List<String>? completedDates,
  }) {
    return HabitQuest(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      targetCount: targetCount ?? this.targetCount,
      completedDates: completedDates ?? this.completedDates,
    );
  }
}
