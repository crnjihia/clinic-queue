// path: apps/mobile/lib/domain/usecases/get_clinics_usecase.dart
import '../../core/result/result.dart';
import '../entities/clinic.dart';
import '../repositories/clinic_repository.dart';

class GetClinicsUseCase {
  final ClinicRepository _repository;

  const GetClinicsUseCase(this._repository);

  Future<Result<List<Clinic>>> execute() {
    return _repository.getClinics();
  }
}

