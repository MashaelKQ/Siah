import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_user.dart';

class UserService {
  UserService._();

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _collection = 'users';

  // ===========================================================
  // Create User
  // Saves a new user's profile to Cloud Firestore.
  // ===========================================================
  static Future<void> createUser(AppUser user) async {
    await _firestore.collection(_collection).doc(user.id).set(user.toMap());
  }

  // ===========================================================
  // Get User
  // Retrieves a user's profile from Cloud Firestore.
  // ===========================================================
  static Future<AppUser?> getUser(String userId) async {
    final document = await _firestore.collection(_collection).doc(userId).get();

    if (!document.exists || document.data() == null) {
      return null;
    }

    return AppUser.fromMap(
      document.id,
      document.data()!,
    );
  }

  // ===========================================================
  // Update User
  // Updates an existing user's profile.
  // ===========================================================
  static Future<void> updateUser(AppUser user) async {
    await _firestore.collection(_collection).doc(user.id).update(user.toMap());
  }

  // ===========================================================
// Delete User
// Deletes the user's profile from Cloud Firestore.
// ===========================================================
  static Future<void> deleteUser(String userId) async {
    await _firestore.collection(_collection).doc(userId).delete();
  }

  // ===========================================================
  // Update Profile
  // Saves only the name and avatar, so the rest of the profile
  // cannot be overwritten by a stale copy of the document.
  // ===========================================================
  static Future<void> updateProfile({
    required String userId,
    required String name,
    required String avatarId,
  }) async {
    await _firestore.collection(_collection).doc(userId).update({
      'name': name.trim(),
      'avatarId': avatarId,
    });
  }

  // ===========================================================
  // Save Onboarding
  // Writes only the onboarding fields, so nothing else on the
  // profile can be clobbered by a stale copy of the document.
  // ===========================================================
  static Future<void> saveOnboarding({
    required String userId,
    required String ageRange,
    required String gender,
    required String occupation,
    required String weeklyHours,
    required List<String> goals,
    required List<String> reasons,
    required String note,
  }) async {
    await _firestore.collection(_collection).doc(userId).set(
      {
        'ageRange': ageRange,
        'gender': gender,
        'occupation': occupation,
        'weeklyHours': weeklyHours,
        'goals': goals,
        'reasons': reasons,
        'onboardingNote': note,
        'onboardingCompletedAt': DateTime.now().toUtc().toIso8601String(),
      },
      SetOptions(merge: true),
    );
  }
}
