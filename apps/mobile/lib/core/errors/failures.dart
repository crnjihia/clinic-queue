// path: apps/mobile/lib/core/errors/failures.dart
import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure({required String message, this.statusCode}) : super(message);

  @override
  List<Object?> get props => [message, statusCode];
}

class CacheFailure extends Failure {
  const CacheFailure({required String message}) : super(message);
}

class NetworkFailure extends Failure {
  const NetworkFailure({
    String message = 'Network unavailable. Showing offline cached queue data.',
  }) : super(message);
}

class AuthFailure extends Failure {
  final String? code;

  const AuthFailure({required String message, this.code}) : super(message);

  @override
  List<Object?> get props => [message, code];
}

class DoubleBookingFailure extends Failure {
  const DoubleBookingFailure({
    String message = 'The selected appointment slot was just booked by another patient.',
  }) : super(message);
}

class QueueOperationFailure extends Failure {
  const QueueOperationFailure({required String message}) : super(message);
}

