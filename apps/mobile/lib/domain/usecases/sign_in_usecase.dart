// path: apps/mobile/lib/domain/usecases/sign_in_usecase.dart
import '../../core/errors/failures.dart';
import '../../core/result/result.dart';
import '../../core/utils/phone_number_formatter.dart';
import '../entities/user_profile.dart';
import '../repositories/auth_repository.dart';

class SignInUseCase {
  final AuthRepository _repository;

  const SignInUseCase(this._repository);

  Future<Result<UserProfile>> execute({
    required String rawPhoneNumber,
    required UserRole role,
  }) async {
    final e164 = PhoneNumberFormatter.toE164(rawPhoneNumber);
    if (e164 == null) {
      return const Error(
        AuthFailure(
          message: 'Invalid Kenyan phone number format. Please enter a valid number (e.g. 0712 345 678 or +2547...).',
        ),
      );
    }

    return _repository.signInWithPhoneNumber(
      phoneNumber: e164,
      role: role,
    );
  }
}

