// path: apps/mobile/lib/presentation/blocs/auth/auth_event.dart
import 'package:equatable/equatable.dart';
import '../../../domain/entities/user_profile.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

class AuthUserChanged extends AuthEvent {
  final UserProfile? user;

  const AuthUserChanged(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthSignInRequested extends AuthEvent {
  final String rawPhoneNumber;
  final UserRole role;

  const AuthSignInRequested({
    required this.rawPhoneNumber,
    required this.role,
  });

  @override
  List<Object?> get props => [rawPhoneNumber, role];
}

class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}

