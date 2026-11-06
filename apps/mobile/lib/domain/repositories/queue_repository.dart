// path: apps/mobile/lib/domain/repositories/queue_repository.dart
import '../../core/result/result.dart';
import '../entities/ticket.dart';

abstract class QueueRepository {
  /// Stream active ticket for a given patient with live position changes
  Stream<Ticket?> watchPatientTicket(String patientId);

  /// Stream full clinic queue for staff triage console
  Stream<List<Ticket>> watchClinicQueue(String clinicId);

  /// Fetch completed tickets to calculate rolling average service duration
  Future<Result<List<Duration>>> getRecentServiceDurations(String clinicId);

  /// Atomically book slot and generate queue ticket (prevents double-booking)
  Future<Result<Ticket>> bookSlot({
    required String clinicId,
    required String slotId,
    required String patientId,
    required String reasonCode,
  });

  /// Staff action: advance ticket status (called, in_service, done, no_show)
  Future<Result<void>> updateTicketStatus({
    required String clinicId,
    required String ticketId,
    required TicketStatus newStatus,
  });

  /// Patient action: cancel waiting ticket
  Future<Result<void>> cancelTicket({
    required String clinicId,
    required String ticketId,
  });
}

