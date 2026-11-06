// path: apps/mobile/lib/domain/entities/user_profile.dart
import 'package:equatable/equatable.dart';

enum UserRole {
  patient,
  staff,
}

class UserProfile extends Equatable {
  final String uid;
  final String phoneNumber;
  final String displayName;
  final UserRole role;
  final List<String> fcmTokens;

  const UserProfile({
    required this.uid,
    required this.phoneNumber,
    required this.displayName,
    required this.role,
    this.fcmTokens = const [],
  });

  bool get isStaff => role == UserRole.staff;
  bool get isPatient => role == UserRole.patient;

  UserProfile copyWith({
    String? displayName,
    UserRole? role,
    List<String>? fcmTokens,
  }) {
    return UserProfile(
      uid: uid,
      phoneNumber: phoneNumber,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      fcmTokens: fcmTokens ?? this.fcmTokens,
    );
  }

  @override
  List<Object?> get props => [uid, phoneNumber, displayName, role, fcmTokens];
}

