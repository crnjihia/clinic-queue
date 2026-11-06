// path: apps/mobile/lib/data/repositories/queue_repository_impl.dart
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/result/result.dart';
import '../../domain/entities/ticket.dart';
import '../../domain/repositories/queue_repository.dart';
import '../datasources/firestore_queue_datasource.dart';

class QueueRepositoryImpl implements QueueRepository {
  final FirestoreQueueDataSource _dataSource;

  QueueRepositoryImpl(this._dataSource);

  @override
  Stream<Ticket?> watchPatientTicket(String patientId) {
    return _dataSource.watchPatientTicket(patientId).map((model) => model?.toEntity());
  }

  @override
  Stream<List<Ticket>> watchClinicQueue(String clinicId) {
    return _dataSource
        .watchClinicQueue(clinicId)
        .map((models) => models.map((m) => m.toEntity()).toList());
  }

  @override
  Future<Result<List<Duration>>> getRecentServiceDurations(String clinicId) async {
    try {
      final durations = await _dataSource.getCompletedServiceDurations(clinicId);
      return Success(durations);
    } catch (e) {
      return Error(ServerFailure(message: 'Could not calculate wait times: ${e.toString()}'));
    }
  }

  @override
  Future<Result<Ticket>> bookSlot({
    required String clinicId,
    required String slotId,
    required String patientId,
    required String reasonCode,
  }) async {
    try {
      final ticketModel = await _dataSource.bookSlotTransaction(
        clinicId: clinicId,
        slotId: slotId,
        patientId: patientId,
        reasonCode: reasonCode,
      );
      return Success(ticketModel.toEntity());
    } on DoubleBookingException catch (e) {
      return Error(DoubleBookingFailure(message: e.message));
    } catch (e) {
      return Error(ServerFailure(message: 'Booking failed: ${e.toString()}'));
    }
  }

  @override
  Future<Result<void>> updateTicketStatus({
    required String clinicId,
    required String ticketId,
    required TicketStatus newStatus,
  }) async {
    try {
      await _dataSource.updateTicketStatus(
        clinicId: clinicId,
        ticketId: ticketId,
        status: newStatus.toDbString(),
      );
      return const Success(null);
    } catch (e) {
      return Error(ServerFailure(message: 'Failed to update queue: ${e.toString()}'));
    }
  }

  @override
  Future<Result<void>> cancelTicket({
    required String clinicId,
    required String ticketId,
  }) async {
    try {
      await _dataSource.cancelTicket(
        clinicId: clinicId,
        ticketId: ticketId,
      );
      return const Success(null);
    } catch (e) {
      return Error(ServerFailure(message: 'Failed to cancel ticket: ${e.toString()}'));
    }
  }
}

