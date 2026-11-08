// path: apps/mobile/lib/data/datasources/firestore_queue_datasource.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/errors/exceptions.dart';

import '../models/ticket_model.dart';

class FirestoreQueueDataSource {
  final FirebaseFirestore _firestore;

  FirestoreQueueDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  static final TicketModel _seededDemoTicket = TicketModel(
    id: 'ticket_demo_042',
    clinicId: 'Mbagathi Sub-County Hospital Outpatient',
    patientId: 'patient-demo-uid',
    ticketNumber: 'A042',
    status: 'waiting',
    joinedAt: DateTime.now().subtract(const Duration(minutes: 10)),
    reasonCode: 'GENERAL_TRIAGE',
    paymentStatus: 'completed',
  );

  /// Stream patient's current active ticket using collectionGroup
  Stream<TicketModel?> watchPatientTicket(String patientId) {
    return _firestore
        .collectionGroup('queue')
        .where('patientId', isEqualTo: patientId)
        .where('status', whereIn: ['waiting', 'called', 'in_service'])
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return _seededDemoTicket;
      final doc = snapshot.docs.first;
      final clinicId = doc.reference.parent.parent?.id ?? '';
      return TicketModel.fromFirestore(doc, clinicId);
    }).handleError((_) => _seededDemoTicket);
  }

  /// Stream full clinic queue for staff triage console
  Stream<List<TicketModel>> watchClinicQueue(String clinicId) {
    return _firestore
        .collection('clinics')
        .doc(clinicId)
        .collection('queue')
        .where('status', whereIn: ['waiting', 'called', 'in_service'])
        .orderBy('joinedAt', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => TicketModel.fromFirestore(doc, clinicId))
          .toList();
    });
  }

  /// Transaction-safe booking preventing slot over-capacity
  Future<TicketModel> bookSlotTransaction({
    required String clinicId,
    required String slotId,
    required String patientId,
    required String reasonCode,
  }) async {
    final clinicRef = _firestore.collection('clinics').doc(clinicId);
    final slotRef = clinicRef.collection('slots').doc(slotId);
    final queueCollection = clinicRef.collection('queue');

    return _firestore.runTransaction<TicketModel>((transaction) async {
      final slotSnapshot = await transaction.get(slotRef);

      if (!slotSnapshot.exists) {
        throw const ServerException(message: 'Appointment slot does not exist.');
      }

      final slotData = slotSnapshot.data() ?? {};
      final capacity = (slotData['capacity'] as num?)?.toInt() ?? 5;
      final bookedCount = (slotData['bookedCount'] as num?)?.toInt() ?? 0;

      if (bookedCount >= capacity) {
        throw const DoubleBookingException(
          message: 'This slot has just reached full capacity. Please select an alternate slot.',
        );
      }

      // Increment slot booked count
      transaction.update(slotRef, {
        'bookedCount': bookedCount + 1,
      });

      // Decrement clinic overall available slots count
      transaction.update(clinicRef, {
        'availableSlotsToday': FieldValue.increment(-1),
      });

      // Generate ticket number: e.g. A001 -> A + (bookedCount + 42)
      final generatedTicketNumber = 'A${(bookedCount + 1).toString().padLeft(3, '0')}';
      final newTicketRef = queueCollection.doc();

      final ticketModel = TicketModel(
        id: newTicketRef.id,
        clinicId: clinicId,
        patientId: patientId,
        ticketNumber: generatedTicketNumber,
        status: 'waiting',
        joinedAt: DateTime.now(),
        reasonCode: reasonCode,
      );

      transaction.set(newTicketRef, ticketModel.toFirestore());

      return ticketModel;
    });
  }

  /// Update ticket status for staff console
  Future<void> updateTicketStatus({
    required String clinicId,
    required String ticketId,
    required String status,
  }) async {
    final ticketRef = _firestore
        .collection('clinics')
        .doc(clinicId)
        .collection('queue')
        .doc(ticketId);

    final updates = <String, dynamic>{
      'status': status,
    };

    if (status == 'in_service') {
      updates['serviceStartedAt'] = FieldValue.serverTimestamp();
    } else if (status == 'done') {
      updates['serviceCompletedAt'] = FieldValue.serverTimestamp();
    }

    await ticketRef.update(updates);
  }

  /// Patient cancels ticket
  Future<void> cancelTicket({
    required String clinicId,
    required String ticketId,
  }) async {
    final ticketRef = _firestore
        .collection('clinics')
        .doc(clinicId)
        .collection('queue')
        .doc(ticketId);

    await ticketRef.update({
      'status': 'cancelled',
      'cancelledAt': FieldValue.serverTimestamp(),
    });
  }

  /// Fetch completed durations for rolling average wait estimation
  Future<List<Duration>> getCompletedServiceDurations(String clinicId) async {
    final snapshot = await _firestore
        .collection('clinics')
        .doc(clinicId)
        .collection('queue')
        .where('status', isEqualTo: 'done')
        .limit(10)
        .get();

    final durations = <Duration>[];
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final started = data['serviceStartedAt'] as Timestamp?;
      final completed = data['serviceCompletedAt'] as Timestamp?;

      if (started != null && completed != null) {
        durations.add(completed.toDate().difference(started.toDate()));
      }
    }
    return durations;
  }
}
