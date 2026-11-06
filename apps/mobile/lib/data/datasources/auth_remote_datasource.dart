// path: apps/mobile/lib/data/datasources/auth_remote_datasource.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/errors/exceptions.dart';
import '../models/user_profile_model.dart';

class AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthRemoteDataSource({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<UserProfileModel?> get authStateChanges {
    return _firebaseAuth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      return getUserProfile(user.uid);
    });
  }

  Future<UserProfileModel?> getUserProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserProfileModel.fromFirestore(doc);
  }

  Future<UserProfileModel> signInWithPhone({
    required String phoneNumber,
    required String role,
  }) async {
    try {
      // In Firebase Emulator / Dev mode, use anonymous or simulated sign in
      UserCredential credential;
      if (_firebaseAuth.currentUser != null) {
        credential = await _firebaseAuth.signInAnonymously();
      } else {
        credential = await _firebaseAuth.signInAnonymously();
      }

      final uid = credential.user?.uid ?? 'demo-user-${DateTime.now().millisecondsSinceEpoch}';
      final userRef = _firestore.collection('users').doc(uid);
      final existingDoc = await userRef.get();

      UserProfileModel profile;
      if (existingDoc.exists) {
        profile = UserProfileModel.fromFirestore(existingDoc);
      } else {
        profile = UserProfileModel(
          uid: uid,
          phoneNumber: phoneNumber,
          displayName: role == 'staff' ? 'Clinic Nurse / Officer' : 'Patient',
          role: role,
          fcmTokens: const [],
        );
        await userRef.set(profile.toFirestore());
      }

      return profile;
    } catch (e) {
      throw AuthException(message: 'Sign-in failed: ${e.toString()}');
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<void> registerFcmToken({
    required String uid,
    required String token,
  }) async {
    await _firestore.collection('users').doc(uid).update({
      'fcmTokens': FieldValue.arrayUnion([token]),
    });
  }
}

