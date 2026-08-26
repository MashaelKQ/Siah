class AppUser {
  // ===========================================================
  // Constructor
  // Represents a user's profile stored in Cloud Firestore.
  // ===========================================================
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.createdAt,
    this.avatarId = '',
    this.consentVersion = '',
    this.consentAcceptedAt,
    this.ageRange = '',
    this.gender = '',
    this.occupation = '',
    this.weeklyHours = '',
    this.goals = const [],
    this.reasons = const [],
    this.onboardingNote = '',
    this.onboardingCompletedAt,
  });

  // ===========================================================
  // User Properties
  // ===========================================================
  final String id;
  final String name;
  final String email;
  final DateTime createdAt;

  // ===========================================================
  // Profile Appearance
  // The id of the chosen preset avatar. Empty means the default.
  // ===========================================================
  final String avatarId;

  // ===========================================================
  // Consent Record
  // The version of the privacy rules the user accepted, and when.
  // ===========================================================
  final String consentVersion;
  final DateTime? consentAcceptedAt;

  // ===========================================================
  // Onboarding
  // Answers given once, after the account is created.
  //
  // Every demographic field can hold 'Prefer not to say', which
  // is a real answer and stored as one. onboardingCompletedAt
  // being null is what sends a user through the questions.
  // ===========================================================
  final String ageRange;
  final String gender;
  final String occupation;
  final String weeklyHours;
  final List<String> goals;
  final List<String> reasons;
  final String onboardingNote;
  final DateTime? onboardingCompletedAt;

  bool get hasCompletedOnboarding => onboardingCompletedAt != null;

  // ===========================================================
  // Firestore Serialization
  // Converts the object into a Firestore document.
  // ===========================================================
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'createdAt': createdAt.toIso8601String(),
      'avatarId': avatarId,
      'consentVersion': consentVersion,
      'consentAcceptedAt': consentAcceptedAt?.toIso8601String(),
      'ageRange': ageRange,
      'gender': gender,
      'occupation': occupation,
      'weeklyHours': weeklyHours,
      'goals': goals,
      'reasons': reasons,
      'onboardingNote': onboardingNote,
      'onboardingCompletedAt': onboardingCompletedAt?.toIso8601String(),
    };
  }

  // ===========================================================
  // Firestore Deserialization
  // Creates an AppUser from Firestore data.
  // ===========================================================
  factory AppUser.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    return AppUser(
      id: id,
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      createdAt: DateTime.tryParse(
            map['createdAt'] as String? ?? '',
          ) ??
          DateTime.now(),
      avatarId: map['avatarId'] as String? ?? '',
      consentVersion: map['consentVersion'] as String? ?? '',
      consentAcceptedAt: DateTime.tryParse(
        map['consentAcceptedAt'] as String? ?? '',
      ),
      ageRange: map['ageRange'] as String? ?? '',
      gender: map['gender'] as String? ?? '',
      occupation: map['occupation'] as String? ?? '',
      weeklyHours: map['weeklyHours'] as String? ?? '',
      goals: List<String>.from(map['goals'] as List<dynamic>? ?? []),
      reasons: List<String>.from(map['reasons'] as List<dynamic>? ?? []),
      onboardingNote: map['onboardingNote'] as String? ?? '',
      onboardingCompletedAt: DateTime.tryParse(
        map['onboardingCompletedAt'] as String? ?? '',
      ),
    );
  }

  // ===========================================================
  // Copy With
  // Creates a modified copy of the current user.
  // ===========================================================
  AppUser copyWith({
    String? id,
    String? name,
    String? email,
    DateTime? createdAt,
    String? avatarId,
    String? consentVersion,
    DateTime? consentAcceptedAt,
    String? ageRange,
    String? gender,
    String? occupation,
    String? weeklyHours,
    List<String>? goals,
    List<String>? reasons,
    String? onboardingNote,
    DateTime? onboardingCompletedAt,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      avatarId: avatarId ?? this.avatarId,
      consentVersion: consentVersion ?? this.consentVersion,
      consentAcceptedAt: consentAcceptedAt ?? this.consentAcceptedAt,
      ageRange: ageRange ?? this.ageRange,
      gender: gender ?? this.gender,
      occupation: occupation ?? this.occupation,
      weeklyHours: weeklyHours ?? this.weeklyHours,
      goals: goals ?? this.goals,
      reasons: reasons ?? this.reasons,
      onboardingNote: onboardingNote ?? this.onboardingNote,
      onboardingCompletedAt:
          onboardingCompletedAt ?? this.onboardingCompletedAt,
    );
  }
}
