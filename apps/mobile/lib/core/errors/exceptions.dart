// path: apps/mobile/lib/core/errors/exceptions.dart
class ServerException implements Exception {
  final String message;
  final int? statusCode;

  const ServerException({required this.message, this.statusCode});

  @override
  String toString() => 'ServerException(message: $message, statusCode: $statusCode)';
}

class CacheException implements Exception {
  final String message;

  const CacheException({required this.message});

  @override
  String toString() => 'CacheException(message: $message)';
}

class NetworkException implements Exception {
  final String message;

  const NetworkException({this.message = 'No internet connection. Please check your Safaricom/Airtel data or Wi-Fi.'});

  @override
  String toString() => 'NetworkException(message: $message)';
}

class AuthException implements Exception {
  final String message;
  final String? code;

  const AuthException({required this.message, this.code});

  @override
  String toString() => 'AuthException(message: $message, code: $code)';
}

class DoubleBookingException implements Exception {
  final String message;

  const DoubleBookingException({this.message = 'This clinic slot has already been filled. Please choose another.'});

  @override
  String toString() => 'DoubleBookingException(message: $message)';
}

class QueueOperationException implements Exception {
  final String message;

  const QueueOperationException({required this.message});

  @override
  String toString() => 'QueueOperationException(message: $message)';
}

