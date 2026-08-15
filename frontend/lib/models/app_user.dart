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
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      avatarId: avatarId ?? this.avatarId,
      consentVersion: consentVersion ?? this.consentVersion,
      consentAcceptedAt: consentAcceptedAt ?? this.consentAcceptedAt,
    );
  }
}
