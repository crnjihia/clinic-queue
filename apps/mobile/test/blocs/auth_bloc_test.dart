// path: apps/mobile/test/blocs/auth_bloc_test.dart
import 'dart:async';
import 'package:bloc_test/bloc_test.dart';
import 'package:clinic_queue/core/errors/failures.dart';
import 'package:clinic_queue/core/result/result.dart';
import 'package:clinic_queue/domain/entities/user_profile.dart';
import 'package:clinic_queue/domain/repositories/auth_repository.dart';
import 'package:clinic_queue/domain/usecases/sign_in_usecase.dart';
import 'package:clinic_queue/presentation/blocs/auth/auth_bloc.dart';
import 'package:clinic_queue/presentation/blocs/auth/auth_event.dart';
import 'package:clinic_queue/presentation/blocs/auth/auth_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockAuthRepository extends Mock implements AuthRepository {
  final StreamController<UserProfile?> _controller = StreamController<UserProfile?>.broadcast();

  @override
  Stream<UserProfile?> get authStateChanges => _controller.stream;

  void emitUser(UserProfile? user) {
    _controller.add(user);
  }
}

class MockSignInUseCase extends Mock implements SignInUseCase {}

void main() {
  group('AuthBloc', () {
    late MockAuthRepository mockAuthRepository;
    late MockSignInUseCase mockSignInUseCase;

    const testPatient = UserProfile(
      uid: 'user_123',
      phoneNumber: '+254712345678',
      displayName: 'Patient Chris',
      role: UserRole.patient,
    );

    const testStaff = UserProfile(
      uid: 'staff_999',
      phoneNumber: '+254722000000',
      displayName: 'Nurse Wangari',
      role: UserRole.staff,
    );

    setUp(() {
      mockAuthRepository = MockAuthRepository();
      mockSignInUseCase = MockSignInUseCase();
    });

    test('initial state is AuthInitial', () {
      final bloc = AuthBloc(
        authRepository: mockAuthRepository,
        signInUseCase: mockSignInUseCase,
      );
      expect(bloc.state, equals(const AuthInitial()));
      bloc.close();
    });

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Authenticated] on successful sign-in as patient',
      setUp: () {
        when(
          mockSignInUseCase.execute(
            rawPhoneNumber: '0712345678',
            role: UserRole.patient,
          ),
        ).thenAnswer((_) async => const Success(testPatient));
      },
      build: () => AuthBloc(
        authRepository: mockAuthRepository,
        signInUseCase: mockSignInUseCase,
      ),
      act: (bloc) => bloc.add(
        const AuthSignInRequested(
          rawPhoneNumber: '0712345678',
          role: UserRole.patient,
        ),
      ),
      expect: () => [
        const AuthLoading(),
        const Authenticated(testPatient),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Authenticated] on successful sign-in as staff',
      setUp: () {
        when(
          mockSignInUseCase.execute(
            rawPhoneNumber: '0722000000',
            role: UserRole.staff,
          ),
        ).thenAnswer((_) async => const Success(testStaff));
      },
      build: () => AuthBloc(
        authRepository: mockAuthRepository,
        signInUseCase: mockSignInUseCase,
      ),
      act: (bloc) => bloc.add(
        const AuthSignInRequested(
          rawPhoneNumber: '0722000000',
          role: UserRole.staff,
        ),
      ),
      expect: () => [
        const AuthLoading(),
        const Authenticated(testStaff),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthFailureState] when sign-in fails with invalid phone format',
      setUp: () {
        when(
          mockSignInUseCase.execute(
            rawPhoneNumber: 'invalid',
            role: UserRole.patient,
          ),
        ).thenAnswer(
          (_) async => const Error(
            AuthFailure(message: 'Invalid Kenyan phone number format.'),
          ),
        );
      },
      build: () => AuthBloc(
        authRepository: mockAuthRepository,
        signInUseCase: mockSignInUseCase,
      ),
      act: (bloc) => bloc.add(
        const AuthSignInRequested(
          rawPhoneNumber: 'invalid',
          role: UserRole.patient,
        ),
      ),
      expect: () => [
        const AuthLoading(),
        const AuthFailureState('Invalid Kenyan phone number format.'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Unauthenticated] on sign-out request',
      setUp: () {
        when(mockAuthRepository.signOut()).thenAnswer((_) async => const Success(null));
      },
      build: () => AuthBloc(
        authRepository: mockAuthRepository,
        signInUseCase: mockSignInUseCase,
      ),
      act: (bloc) => bloc.add(const AuthSignOutRequested()),
      expect: () => [
        const AuthLoading(),
        const Unauthenticated(),
      ],
    );
  });
}

