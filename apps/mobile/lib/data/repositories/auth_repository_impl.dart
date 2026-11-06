// path: apps/mobile/lib/data/repositories/auth_repository_impl.dart
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/result/result.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _dataSource;

  AuthRepositoryImpl(this._dataSource);

  @override
  Stream<UserProfile?> get authStateChanges =>
      _dataSource.authStateChanges.map((model) => model?.toEntity());

  @override
  Future<UserProfile?> getCurrentUser() async {
    // Handled reactively or via authStateChanges
    return null;
  }

  @override
  Future<Result<UserProfile>> signInWithPhoneNumber({
    required String phoneNumber,
    required UserRole role,
  }) async {
    try {
      final model = await _dataSource.signInWithPhone(
        phoneNumber: phoneNumber,
        role: role.name,
      );
      return Success(model.toEntity());
    } on AuthException catch (e) {
      return Error(AuthFailure(message: e.message, code: e.code));
    } catch (e) {
      return Error(ServerFailure(message: 'Authentication failed: ${e.toString()}'));
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _dataSource.signOut();
      return const Success(null);
    } catch (e) {
      return Error(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> registerFcmToken(String token) async {
    return const Success(null);
  }
}

