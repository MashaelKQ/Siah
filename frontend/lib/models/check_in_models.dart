// ===========================================================
// Check-In Models
// The three pieces of data the mood and journal features
// store: a feeling, a mood entry, and a journal entry.
//
// Kept in one file because they are always used together
// and none of them is large.
// ===========================================================

// ===========================================================
// Emotional Log
// A single record of how something felt.
//
// Used on its own for a mood check-in, and attached to a
// journal entry so writing and feeling are stored together.
// ===========================================================
class EmotionalLog {
  const EmotionalLog({
    required this.valence,
    this.emotions = const [],
    this.impacts = const [],
  });

  // ===========================================================
  // Valence
  // How pleasant the moment felt, from -2 to 2.
  // ===========================================================
  final int valence;

  // ===========================================================
  // Emotions
  // The words the user chose for the feeling.
  // ===========================================================
  final List<String> emotions;

  // ===========================================================
  // Impacts
  // The parts of life the user said were affecting them.
  // ===========================================================
  final List<String> impacts;

  Map<String, dynamic> toMap() {
    return {
      'valence': valence,
      'emotions': emotions,
      'impacts': impacts,
    };
  }

  factory EmotionalLog.fromMap(Map<String, dynamic> map) {
    return EmotionalLog(
      valence: map['valence'] as int? ?? 0,
      emotions: List<String>.from(
        map['emotions'] as List<dynamic>? ?? [],
      ),
      impacts: List<String>.from(
        map['impacts'] as List<dynamic>? ?? [],
      ),
    );
  }

  EmotionalLog copyWith({
    int? valence,
    List<String>? emotions,
    List<String>? impacts,
  }) {
    return EmotionalLog(
      valence: valence ?? this.valence,
      emotions: emotions ?? this.emotions,
      impacts: impacts ?? this.impacts,
    );
  }
}


// ===========================================================
// Mood Entry
// One check-in, stored with the moment it was recorded.
//
// Several entries a day are allowed on purpose. Feelings
// change through a day, and one forced entry would hide the
// change, which is the part worth seeing.
// ===========================================================
class MoodEntry {
  const MoodEntry({
    required this.id,
    required this.userId,
    required this.log,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final EmotionalLog log;
  final DateTime createdAt;

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      ...log.toMap(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory MoodEntry.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    return MoodEntry(
      id: id,
      userId: map['userId'] as String? ?? '',
      log: EmotionalLog.fromMap(map),
      createdAt: DateTime.tryParse(
            map['createdAt'] as String? ?? '',
          ) ??
          DateTime.now(),
    );
  }
}


// ===========================================================
// Journal Entry
// One day's reflection.
//
// The prompt text is stored alongside the id so an old entry
// still reads correctly if the prompt list is ever edited.
//
// The emotional log is optional. Writing without recording a
// feeling is a normal thing to want to do.
// ===========================================================
class JournalEntry {
  const JournalEntry({
    required this.id,
    required this.userId,
    required this.promptId,
    required this.promptText,
    required this.text,
    required this.createdAt,
    required this.updatedAt,
    this.log,
  });

  final String id;
  final String userId;
  final String promptId;
  final String promptText;
  final String text;
  final DateTime createdAt;
  final DateTime updatedAt;
  final EmotionalLog? log;

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'promptId': promptId,
      'promptText': promptText,
      'text': text,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'log': log?.toMap(),
    };
  }

  factory JournalEntry.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    final logData = map['log'] as Map<String, dynamic>?;

    return JournalEntry(
      id: id,
      userId: map['userId'] as String? ?? '',
      promptId: map['promptId'] as String? ?? '',
      promptText: map['promptText'] as String? ?? '',
      text: map['text'] as String? ?? '',
      createdAt: DateTime.tryParse(
            map['createdAt'] as String? ?? '',
          ) ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(
            map['updatedAt'] as String? ?? '',
          ) ??
          DateTime.now(),
      log: logData == null ? null : EmotionalLog.fromMap(logData),
    );
  }

  JournalEntry copyWith({
    String? text,
    EmotionalLog? log,
    DateTime? updatedAt,
  }) {
    return JournalEntry(
      id: id,
      userId: userId,
      promptId: promptId,
      promptText: promptText,
      text: text ?? this.text,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      log: log ?? this.log,
    );
  }
}
