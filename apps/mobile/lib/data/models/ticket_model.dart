// path: apps/mobile/lib/data/models/ticket_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/ticket.dart';

class TicketModel {
  final String id;
  final String clinicId;
  final String patientId;
  final String ticketNumber;
  final String status;
  final DateTime joinedAt;
  final DateTime? serviceStartedAt;
  final DateTime? serviceCompletedAt;
  final String reasonCode;

  const TicketModel({
    required this.id,
    required this.clinicId,
    required this.patientId,
    required this.ticketNumber,
    required this.status,
    required this.joinedAt,
    this.serviceStartedAt,
    this.serviceCompletedAt,
    required this.reasonCode,
  });

  factory TicketModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc, [
    String? explicitClinicId,
  ]) {
    final data = doc.data() ?? {};
    final joinedTimestamp = data['joinedAt'] as Timestamp?;
    final startedTimestamp = data['serviceStartedAt'] as Timestamp?;
    final completedTimestamp = data['serviceCompletedAt'] as Timestamp?;

    return TicketModel(
      id: doc.id,
      clinicId: explicitClinicId ?? (data['clinicId'] as String?) ?? '',
      patientId: (data['patientId'] as String?) ?? '',
      ticketNumber: (data['ticketNumber'] as String?) ?? 'A001',
      status: (data['status'] as String?) ?? 'waiting',
      joinedAt: joinedTimestamp?.toDate() ?? DateTime.now(),
      serviceStartedAt: startedTimestamp?.toDate(),
      serviceCompletedAt: completedTimestamp?.toDate(),
      reasonCode: (data['reasonCode'] as String?) ?? 'GENERAL_TRIAGE',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'clinicId': clinicId,
      'patientId': patientId,
      'ticketNumber': ticketNumber,
      'status': status,
      'joinedAt': Timestamp.fromDate(joinedAt),
      if (serviceStartedAt != null) 'serviceStartedAt': Timestamp.fromDate(serviceStartedAt!),
      if (serviceCompletedAt != null) 'serviceCompletedAt': Timestamp.fromDate(serviceCompletedAt!),
      'reasonCode': reasonCode,
    };
  }

  Ticket toEntity() {
    return Ticket(
      id: id,
      clinicId: clinicId,
      patientId: patientId,
      ticketNumber: ticketNumber,
      status: TicketStatus.fromString(status),
      joinedAt: joinedAt,
      serviceStartedAt: serviceStartedAt,
      serviceCompletedAt: serviceCompletedAt,
      reasonCode: reasonCode,
    );
  }
}

