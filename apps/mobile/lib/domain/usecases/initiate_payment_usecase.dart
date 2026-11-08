// path: apps/mobile/lib/domain/usecases/initiate_payment_usecase.dart
import 'package:injectable/injectable.dart';
import '../../core/result/result.dart';
import '../entities/payment.dart';
import '../repositories/payment_repository.dart';

@lazySingleton
class InitiatePaymentUseCase {
  final PaymentRepository _repository;

  InitiatePaymentUseCase(this._repository);

  Future<Result<Payment>> call({
    required String ticketId,
    required String clinicId,
    required String patientId,
    required double amount,
    required String phoneNumber,
  }) {
    return _repository.initiateStkPush(
      ticketId: ticketId,
      clinicId: clinicId,
      patientId: patientId,
      amount: amount,
      phoneNumber: phoneNumber,
    );
  }
}
