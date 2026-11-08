// path: apps/mobile/lib/data/models/payment_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/payment.dart';

class PaymentModel {
  final String id;
  final String ticketId;
  final String clinicId;
  final String patientId;
  final double amount;
  final String phoneNumber;
  final String checkoutRequestId;
  final String merchantRequestId;
  final String status;
  final String? mpesaReceiptNumber;
  final DateTime createdAt;
  final String? failureReason;

  const PaymentModel({
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

  factory PaymentModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final createdTimestamp = data['createdAt'] as Timestamp?;

    return PaymentModel(
      id: doc.id,
      ticketId: (data['ticketId'] as String?) ?? '',
      clinicId: (data['clinicId'] as String?) ?? '',
      patientId: (data['patientId'] as String?) ?? '',
      amount: ((data['amount'] as num?) ?? 0).toDouble(),
      phoneNumber: (data['phoneNumber'] as String?) ?? '',
      checkoutRequestId: (data['checkoutRequestId'] as String?) ?? '',
      merchantRequestId: (data['merchantRequestId'] as String?) ?? '',
      status: (data['status'] as String?) ?? 'pending',
      mpesaReceiptNumber: data['mpesaReceiptNumber'] as String?,
      createdAt: createdTimestamp?.toDate() ?? DateTime.now(),
      failureReason: data['failureReason'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'ticketId': ticketId,
      'clinicId': clinicId,
      'patientId': patientId,
      'amount': amount,
      'phoneNumber': phoneNumber,
      'checkoutRequestId': checkoutRequestId,
      'merchantRequestId': merchantRequestId,
      'status': status,
      if (mpesaReceiptNumber != null) 'mpesaReceiptNumber': mpesaReceiptNumber,
      'createdAt': Timestamp.fromDate(createdAt),
      if (failureReason != null) 'failureReason': failureReason,
    };
  }

  Payment toEntity() {
    return Payment(
      id: id,
      ticketId: ticketId,
      clinicId: clinicId,
      patientId: patientId,
      amount: amount,
      phoneNumber: phoneNumber,
      checkoutRequestId: checkoutRequestId,
      merchantRequestId: merchantRequestId,
      status: PaymentStatus.fromString(status),
      mpesaReceiptNumber: mpesaReceiptNumber,
      createdAt: createdAt,
      failureReason: failureReason,
    );
  }
}
