// path: apps/mobile/lib/domain/usecases/book_slot_usecase.dart
import '../../core/errors/failures.dart';
import '../../core/result/result.dart';
import '../entities/ticket.dart';
import '../repositories/queue_repository.dart';

class BookSlotUseCase {
  final QueueRepository _repository;

  const BookSlotUseCase(this._repository);

  Future<Result<Ticket>> execute({
    required String clinicId,
    required String slotId,
    required String patientId,
    required String reasonCode,
  }) async {
    if (clinicId.isEmpty || slotId.isEmpty || patientId.isEmpty) {
      return const Error(
        ServerFailure(message: 'Clinic, slot, and patient IDs are required to reserve a queue position.'),
      );
    }

    return _repository.bookSlot(
      clinicId: clinicId,
      slotId: slotId,
      patientId: patientId,
      reasonCode: reasonCode.isEmpty ? 'GENERAL_TRIAGE' : reasonCode,
    );
  }
}

