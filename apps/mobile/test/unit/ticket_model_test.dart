// path: apps/mobile/test/unit/ticket_model_test.dart
import 'package:clinic_queue/data/models/ticket_model.dart';
import 'package:clinic_queue/domain/entities/ticket.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TicketModel', () {
    final fixedJoinedTime = DateTime(2026, 11, 7, 9, 30);
    final fixedStartedTime = DateTime(2026, 11, 7, 9, 45);
    final fixedCompletedTime = DateTime(2026, 11, 7, 9, 55);

    test('correctly converts to and from Ticket domain entity', () {
      final model = TicketModel(
        id: 'ticket_123',
        clinicId: 'c_mbagathi',
        patientId: 'patient_456',
        ticketNumber: 'A042',
        status: 'called',
        joinedAt: fixedJoinedTime,
        serviceStartedAt: fixedStartedTime,
        serviceCompletedAt: fixedCompletedTime,
        reasonCode: 'TRIAGE_GENERAL',
      );

      final entity = model.toEntity();

      expect(entity.id, equals('ticket_123'));
      expect(entity.clinicId, equals('c_mbagathi'));
      expect(entity.patientId, equals('patient_456'));
      expect(entity.ticketNumber, equals('A042'));
      expect(entity.status, equals(TicketStatus.called));
      expect(entity.isCalled, isTrue);
      expect(entity.isWaiting, isFalse);
      expect(entity.consultationDuration, equals(const Duration(minutes: 10)));
    });

    test('toFirestore serializes fields with server-ready format', () {
      final model = TicketModel(
        id: 'ticket_123',
        clinicId: 'c_westlands',
        patientId: 'patient_789',
        ticketNumber: 'B012',
        status: 'waiting',
        joinedAt: fixedJoinedTime,
        reasonCode: 'IMMUNISATION',
      );

      final map = model.toFirestore();

      expect(map['clinicId'], equals('c_westlands'));
      expect(map['ticketNumber'], equals('B012'));
      expect(map['status'], equals('waiting'));
      expect(map['reasonCode'], equals('IMMUNISATION'));
    });
  });
}
