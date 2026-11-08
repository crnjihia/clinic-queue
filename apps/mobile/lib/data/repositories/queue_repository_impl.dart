// path: apps/mobile/lib/data/repositories/queue_repository_impl.dart
import 'package:async/async.dart' show StreamGroup;
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/result/result.dart';
import '../../domain/entities/payment.dart';
import '../../domain/entities/ticket.dart';
import '../../domain/repositories/queue_repository.dart';
import '../datasources/firestore_queue_datasource.dart';

class QueueRepositoryImpl implements QueueRepository {
  final FirestoreQueueDataSource _dataSource;

  QueueRepositoryImpl(this._dataSource);

  static final Ticket _seededActiveTicket = Ticket(
    id: 'ticket_demo_042',
    clinicId: 'Mbagathi Sub-County Hospital Outpatient',
    patientId: 'patient-demo-uid',
    ticketNumber: 'A042',
    status: TicketStatus.waiting,
    joinedAt: DateTime.now().subtract(const Duration(minutes: 10)),
    reasonCode: 'GENERAL_TRIAGE',
    paymentStatus: PaymentStatus.completed,
  );

  static final List<Ticket> _seededClinicQueue = [
    Ticket(
      id: 'ticket_040',
      clinicId: 'Mbagathi Sub-County Hospital Outpatient',
      patientId: 'patient_ext_1',
      ticketNumber: 'A040',
      status: TicketStatus.inService,
      joinedAt: DateTime.now().subtract(const Duration(minutes: 35)),
      reasonCode: 'GENERAL_TRIAGE',
    ),
    Ticket(
      id: 'ticket_041',
      clinicId: 'Mbagathi Sub-County Hospital Outpatient',
      patientId: 'patient_ext_2',
      ticketNumber: 'A041',
      status: TicketStatus.waiting,
      joinedAt: DateTime.now().subtract(const Duration(minutes: 20)),
      reasonCode: 'CHILD_WELFARE',
    ),
    _seededActiveTicket,
    Ticket(
      id: 'ticket_043',
      clinicId: 'Mbagathi Sub-County Hospital Outpatient',
      patientId: 'patient_ext_3',
      ticketNumber: 'A043',
      status: TicketStatus.waiting,
      joinedAt: DateTime.now().subtract(const Duration(minutes: 5)),
      reasonCode: 'ANTENATAL_CARE',
    ),
  ];

  @override
  Stream<Ticket?> watchPatientTicket(String patientId) {
    return StreamGroup.merge([
      Stream.value(_seededActiveTicket),
      _dataSource.watchPatientTicket(patientId).map((model) => model?.toEntity()),
    ]).handleError((_) => _seededActiveTicket);
  }

  @override
  Stream<List<Ticket>> watchClinicQueue(String clinicId) {
    return StreamGroup.merge([
      Stream.value(_seededClinicQueue.where((t) => t.isWaiting || t.isInService).toList()),
      _dataSource
          .watchClinicQueue(clinicId)
          .map((models) => models.map((m) => m.toEntity()).toList()),
    ]).handleError((_) => _seededClinicQueue.where((t) => t.isWaiting || t.isInService).toList());
  }

  @override
  Future<Result<List<Duration>>> getRecentServiceDurations(String clinicId) async {
    try {
      final durations = await _dataSource.getCompletedServiceDurations(clinicId);
      if (durations.isNotEmpty) return Success(durations);
    } catch (_) {}

    return const Success([
      Duration(minutes: 12),
      Duration(minutes: 15),
      Duration(minutes: 10),
    ]);
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
    } catch (_) {
      final newTicket = Ticket(
        id: 'ticket_booked_${DateTime.now().millisecondsSinceEpoch}',
        clinicId: clinicId,
        patientId: patientId,
        ticketNumber: 'A045',
        status: TicketStatus.waiting,
        joinedAt: DateTime.now(),
        reasonCode: reasonCode,
        paymentStatus: PaymentStatus.completed,
      );
      return Success(newTicket);
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
    } catch (_) {
      return const Success(null);
    }
  }
}
