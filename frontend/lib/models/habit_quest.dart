class HabitQuest {
  const HabitQuest({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.isCompleted = false,
  });

  final String id;
  final String title;
  final String description;
  final String category;

  final bool isCompleted;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'isCompleted': isCompleted,
    };
  }

  factory HabitQuest.fromMap(
    Map<String, dynamic> map,
  ) {
    return HabitQuest(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      category: map['category'] as String? ?? 'wellbeing',
      isCompleted: map['isCompleted'] as bool? ?? false,
    );
  }

  factory HabitQuest.fromGemini(
    Map<String, dynamic> map,
    int index,
  ) {
    return HabitQuest(
      id: 'gemini_${DateTime.now().millisecondsSinceEpoch}_$index',
      title: map['title'] as String? ?? 'Wellness Quest',
      description: map['description'] as String? ?? '',
      category: map['category'] as String? ?? 'wellbeing',
      isCompleted: false,
    );
  }

  HabitQuest copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    bool? isCompleted,
  }) {
    return HabitQuest(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
