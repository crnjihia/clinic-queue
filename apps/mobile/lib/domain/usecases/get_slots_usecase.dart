// path: apps/mobile/lib/domain/usecases/get_slots_usecase.dart
import '../../core/result/result.dart';
import '../entities/queue_slot.dart';
import '../repositories/clinic_repository.dart';

class GetSlotsUseCase {
  final ClinicRepository _repository;

  const GetSlotsUseCase(this._repository);

  Future<Result<List<QueueSlot>>> execute(String clinicId) {
    return _repository.getSlots(clinicId);
  }
}

