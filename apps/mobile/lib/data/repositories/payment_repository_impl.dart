// path: apps/mobile/lib/data/repositories/payment_repository_impl.dart
import 'package:injectable/injectable.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/result/result.dart';
import '../../domain/entities/payment.dart';
import '../../domain/repositories/payment_repository.dart';
import '../datasources/mpesa_remote_datasource.dart';

@LazySingleton(as: PaymentRepository)
class PaymentRepositoryImpl implements PaymentRepository {
  final MpesaRemoteDataSource _remoteDataSource;

  PaymentRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<Payment>> initiateStkPush({
    required String ticketId,
    required String clinicId,
    required String patientId,
    required double amount,
    required String phoneNumber,
  }) async {
    try {
      final model = await _remoteDataSource.initiateStkPush(
        ticketId: ticketId,
        clinicId: clinicId,
        patientId: patientId,
        amount: amount,
        phoneNumber: phoneNumber,
      );
      return Success(model.toEntity());
    } on ServerException catch (e) {
      return Error(ServerFailure(message: e.message));
    } catch (e) {
      return Error(ServerFailure(message: e.toString()));
    }
  }

  @override
  Stream<Payment> watchPaymentStatus(String paymentId) {
    return _remoteDataSource
        .watchPaymentStatus(paymentId)
        .map((model) => model.toEntity());
  }
}
