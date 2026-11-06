// path: apps/mobile/lib/domain/usecases/get_service_durations_usecase.dart
import '../../core/result/result.dart';
import '../repositories/queue_repository.dart';

class GetServiceDurationsUseCase {
  final QueueRepository _repository;

  const GetServiceDurationsUseCase(this._repository);

  Future<Result<List<Duration>>> execute(String clinicId) {
    return _repository.getRecentServiceDurations(clinicId);
  }
}
