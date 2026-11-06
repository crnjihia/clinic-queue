// path: apps/mobile/lib/domain/usecases/advance_queue_usecase.dart
import '../../core/result/result.dart';
import '../entities/ticket.dart';
import '../repositories/queue_repository.dart';

class AdvanceQueueUseCase {
  final QueueRepository _repository;

  const AdvanceQueueUseCase(this._repository);

  Future<Result<void>> execute({
    required String clinicId,
    required String ticketId,
    required TicketStatus newStatus,
  }) {
    return _repository.updateTicketStatus(
      clinicId: clinicId,
      ticketId: ticketId,
      newStatus: newStatus,
    );
  }
}
