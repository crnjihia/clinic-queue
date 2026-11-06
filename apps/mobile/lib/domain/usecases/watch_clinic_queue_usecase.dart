// path: apps/mobile/lib/domain/usecases/watch_clinic_queue_usecase.dart
import '../entities/ticket.dart';
import '../repositories/queue_repository.dart';

class WatchClinicQueueUseCase {
  final QueueRepository _repository;

  const WatchClinicQueueUseCase(this._repository);

  Stream<List<Ticket>> execute(String clinicId) {
    return _repository.watchClinicQueue(clinicId);
  }
}
