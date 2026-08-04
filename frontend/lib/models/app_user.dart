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
  });

  // ===========================================================
  // User Properties
  // ===========================================================
  final String id;
  final String name;
  final String email;
  final DateTime createdAt;

  // ===========================================================
  // Firestore Serialization
  // Converts the object into a Firestore document.
  // ===========================================================
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'createdAt': createdAt.toIso8601String(),
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
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
