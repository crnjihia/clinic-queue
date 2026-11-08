// path: apps/mobile/lib/data/datasources/mpesa_remote_datasource.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import '../../core/utils/phone_number_formatter.dart';
import '../models/payment_model.dart';

abstract class MpesaRemoteDataSource {
  Future<PaymentModel> initiateStkPush({
    required String ticketId,
    required String clinicId,
    required String patientId,
    required double amount,
    required String phoneNumber,
  });

  Stream<PaymentModel> watchPaymentStatus(String paymentId);
}

@LazySingleton(as: MpesaRemoteDataSource)
class MpesaRemoteDataSourceImpl implements MpesaRemoteDataSource {
  final FirebaseFirestore _firestore;

  MpesaRemoteDataSourceImpl(this._firestore);

  @override
  Future<PaymentModel> initiateStkPush({
    required String ticketId,
    required String clinicId,
    required String patientId,
    required double amount,
    required String phoneNumber,
  }) async {
    final formattedPhone = PhoneNumberFormatter.toE164(phoneNumber) ?? phoneNumber;
    final mockCheckoutId = 'ws_CO_${DateTime.now().millisecondsSinceEpoch}';
    final mockMerchantId = 'MOCK_MERCHANT_${DateTime.now().millisecondsSinceEpoch}';

    final paymentDocRef = _firestore.collection('payments').doc();

    final model = PaymentModel(
      id: paymentDocRef.id,
      ticketId: ticketId,
      clinicId: clinicId,
      patientId: patientId,
      amount: amount,
      phoneNumber: formattedPhone,
      checkoutRequestId: mockCheckoutId,
      merchantRequestId: mockMerchantId,
      status: 'pending',
      createdAt: DateTime.now(),
    );

    await paymentDocRef.set(model.toFirestore());

    return model;
  }

  @override
  Stream<PaymentModel> watchPaymentStatus(String paymentId) {
    return _firestore
        .collection('payments')
        .doc(paymentId)
        .snapshots()
        .map((doc) => PaymentModel.fromFirestore(doc));
  }
}
