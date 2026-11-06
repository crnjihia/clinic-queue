// path: apps/mobile/lib/domain/usecases/cancel_ticket_usecase.dart
import '../../core/result/result.dart';
import '../repositories/queue_repository.dart';

class CancelTicketUseCase {
  final QueueRepository _repository;

  const CancelTicketUseCase(this._repository);

  Future<Result<void>> execute({
    required String clinicId,
    required String ticketId,
  }) {
    return _repository.cancelTicket(
      clinicId: clinicId,
      ticketId: ticketId,
    );
  }
}
