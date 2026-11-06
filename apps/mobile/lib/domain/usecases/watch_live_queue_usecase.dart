// path: apps/mobile/lib/domain/usecases/watch_live_queue_usecase.dart
import '../entities/ticket.dart';
import '../repositories/queue_repository.dart';

class WatchLiveQueueUseCase {
  final QueueRepository _repository;

  const WatchLiveQueueUseCase(this._repository);

  Stream<Ticket?> execute(String patientId) {
    return _repository.watchPatientTicket(patientId);
  }
}
