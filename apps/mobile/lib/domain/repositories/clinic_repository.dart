// path: apps/mobile/lib/domain/repositories/clinic_repository.dart
import '../../core/result/result.dart';
import '../entities/clinic.dart';
import '../entities/queue_slot.dart';

abstract class ClinicRepository {
  /// Fetch all available clinics in Nairobi
  Future<Result<List<Clinic>>> getClinics();

  /// Fetch specific clinic details
  Future<Result<Clinic>> getClinicById(String clinicId);

  /// Fetch available appointment time slots for a given clinic
  Future<Result<List<QueueSlot>>> getSlots(String clinicId);
}

