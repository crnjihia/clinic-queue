// path: apps/mobile/lib/presentation/blocs/auth/auth_bloc.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/router/app_router.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/usecases/sign_in_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final SignInUseCase _signInUseCase;
  StreamSubscription<dynamic>? _authSubscription;

  AuthBloc({
    required AuthRepository authRepository,
    required SignInUseCase signInUseCase,
  })  : _authRepository = authRepository,
        _signInUseCase = signInUseCase,
        super(const AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthUserChanged>(_onAuthUserChanged);
    on<AuthSignInRequested>(_onAuthSignInRequested);
    on<AuthSignOutRequested>(_onAuthSignOutRequested);

    _authSubscription = _authRepository.authStateChanges.listen((user) {
      add(AuthUserChanged(user));
    });
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final user = await _authRepository.getCurrentUser();
    if (user != null) {
      _syncRouter(user.role.name, true);
      emit(Authenticated(user));
    } else {
      _syncRouter('patient', false);
      emit(const Unauthenticated());
    }
  }

  void _onAuthUserChanged(
    AuthUserChanged event,
    Emitter<AuthState> emit,
  ) {
    if (event.user != null) {
      _syncRouter(event.user!.role.name, true);
      emit(Authenticated(event.user!));
    } else {
      _syncRouter('patient', false);
      emit(const Unauthenticated());
    }
  }

  Future<void> _onAuthSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _signInUseCase.execute(
      rawPhoneNumber: event.rawPhoneNumber,
      role: event.role,
    );

    result.fold(
      onSuccess: (user) {
        _syncRouter(user.role.name, true);
        emit(Authenticated(user));
      },
      onError: (failure) {
        emit(AuthFailureState(failure.message));
      },
    );
  }

  Future<void> _onAuthSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    await _authRepository.signOut();
    _syncRouter('patient', false);
    emit(const Unauthenticated());
  }

  void _syncRouter(String role, bool isAuthenticated) {
    AppRouter.currentUserRole = role;
    AppRouter.authStateListenable.value = isAuthenticated;
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}

