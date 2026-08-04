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
}
