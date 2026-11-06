// path: apps/mobile/lib/domain/repositories/auth_repository.dart
import '../../core/result/result.dart';
import '../entities/user_profile.dart';

abstract class AuthRepository {
  /// Stream of the current user profile, null if unauthenticated
  Stream<UserProfile?> get authStateChanges;

  /// Returns current authenticated user or null
  Future<UserProfile?> getCurrentUser();

  /// Sign in with a verified Kenyan mobile number or test emulator credential
  Future<Result<UserProfile>> signInWithPhoneNumber({
    required String phoneNumber,
    required UserRole role,
  });

  /// Sign out
  Future<Result<void>> signOut();

  /// Register or update device FCM token for push alerts
  Future<Result<void>> registerFcmToken(String token);
}

