// path: apps/mobile/test/unit/payment_model_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:clinic_queue/data/models/payment_model.dart';
import 'package:clinic_queue/domain/entities/payment.dart';

void main() {
  group('PaymentModel & Payment Entity Tests', () {
    final now = DateTime.now();
    final model = PaymentModel(
      id: 'pay_123',
      ticketId: 't_001',
      clinicId: 'c_nairobi',
      patientId: 'p_chris',
      amount: 500.0,
      phoneNumber: '+254712345678',
      checkoutRequestId: 'ws_CO_987654321',
      merchantRequestId: 'MERCHANT_123',
      status: 'completed',
      mpesaReceiptNumber: 'QKH1234567',
      createdAt: now,
    );

    test('should map PaymentModel to Payment entity accurately', () {
      final entity = model.toEntity();

      expect(entity.id, equals('pay_123'));
      expect(entity.amount, equals(500.0));
      expect(entity.status, equals(PaymentStatus.completed));
      expect(entity.isCompleted, isTrue);
      expect(entity.isPending, isFalse);
      expect(entity.mpesaReceiptNumber, equals('QKH1234567'));
    });

    test('should parse PaymentStatus correctly from String', () {
      expect(PaymentStatus.fromString('pending'), equals(PaymentStatus.pending));
      expect(PaymentStatus.fromString('completed'), equals(PaymentStatus.completed));
      expect(PaymentStatus.fromString('failed'), equals(PaymentStatus.failed));
      expect(PaymentStatus.fromString('unknown'), equals(PaymentStatus.pending));
    });
  });
}
