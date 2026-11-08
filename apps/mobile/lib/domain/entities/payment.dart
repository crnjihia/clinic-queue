// path: apps/mobile/lib/domain/entities/payment.dart
import 'package:equatable/equatable.dart';

enum PaymentStatus {
  pending,
  completed,
  failed;

  static PaymentStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return PaymentStatus.completed;
      case 'failed':
        return PaymentStatus.failed;
      case 'pending':
      default:
        return PaymentStatus.pending;
    }
  }

  String toDbString() {
    switch (this) {
      case PaymentStatus.pending:
        return 'pending';
      case PaymentStatus.completed:
        return 'completed';
      case PaymentStatus.failed:
        return 'failed';
    }
  }
}

class Payment extends Equatable {
  final String id;
  final String ticketId;
  final String clinicId;
  final String patientId;
  final double amount; // KES
  final String phoneNumber;
  final String checkoutRequestId;
  final String merchantRequestId;
  final PaymentStatus status;
  final String? mpesaReceiptNumber;
  final DateTime createdAt;
  final String? failureReason;

  const Payment({
    required this.id,
    required this.ticketId,
    required this.clinicId,
    required this.patientId,
    required this.amount,
    required this.phoneNumber,
    required this.checkoutRequestId,
    required this.merchantRequestId,
    required this.status,
    this.mpesaReceiptNumber,
    required this.createdAt,
    this.failureReason,
  });

  bool get isCompleted => status == PaymentStatus.completed;
  bool get isPending => status == PaymentStatus.pending;
  bool get isFailed => status == PaymentStatus.failed;

  @override
  List<Object?> get props => [
        id,
        ticketId,
        clinicId,
        patientId,
        amount,
        phoneNumber,
        checkoutRequestId,
        merchantRequestId,
        status,
        mpesaReceiptNumber,
        createdAt,
        failureReason,
      ];
}
