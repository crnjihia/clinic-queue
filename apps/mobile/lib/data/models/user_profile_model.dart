// path: apps/mobile/lib/data/models/user_profile_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_profile.dart';

class UserProfileModel {
  final String uid;
  final String phoneNumber;
  final String displayName;
  final String role;
  final List<String> fcmTokens;

  const UserProfileModel({
    required this.uid,
    required this.phoneNumber,
    required this.displayName,
    required this.role,
    this.fcmTokens = const [],
  });

  factory UserProfileModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return UserProfileModel(
      uid: doc.id,
      phoneNumber: (data['phoneNumber'] as String?) ?? '',
      displayName: (data['displayName'] as String?) ?? 'Patient',
      role: (data['role'] as String?) ?? 'patient',
      fcmTokens: List<String>.from((data['fcmTokens'] as List<dynamic>?) ?? []),
    );
  }

  factory UserProfileModel.fromEntity(UserProfile entity) {
    return UserProfileModel(
      uid: entity.uid,
      phoneNumber: entity.phoneNumber,
      displayName: entity.displayName,
      role: entity.role.name,
      fcmTokens: entity.fcmTokens,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'phoneNumber': phoneNumber,
      'displayName': displayName,
      'role': role,
      'fcmTokens': fcmTokens,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  UserProfile toEntity() {
    return UserProfile(
      uid: uid,
      phoneNumber: phoneNumber,
      displayName: displayName,
      role: role.toLowerCase() == 'staff' ? UserRole.staff : UserRole.patient,
      fcmTokens: fcmTokens,
    );
  }
}

