// path: apps/mobile/lib/domain/repositories/payment_repository.dart
import '../../core/result/result.dart';
import '../entities/payment.dart';

abstract class PaymentRepository {
  Future<Result<Payment>> initiateStkPush({
    required String ticketId,
    required String clinicId,
    required String patientId,
    required double amount,
    required String phoneNumber,
  });

  Stream<Payment> watchPaymentStatus(String paymentId);
}
