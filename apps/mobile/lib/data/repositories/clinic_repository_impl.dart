// path: apps/mobile/lib/data/repositories/clinic_repository_impl.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/errors/failures.dart';
import '../../core/result/result.dart';
import '../../domain/entities/clinic.dart';
import '../../domain/entities/queue_slot.dart';
import '../../domain/repositories/clinic_repository.dart';
import '../datasources/firestore_seed_datasource.dart';
import '../models/clinic_model.dart';
import '../models/queue_slot_model.dart';

class ClinicRepositoryImpl implements ClinicRepository {
  final FirebaseFirestore _firestore;
  final FirestoreSeedDataSource _seedDataSource;

  ClinicRepositoryImpl({
    FirebaseFirestore? firestore,
    FirestoreSeedDataSource? seedDataSource,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _seedDataSource = seedDataSource ?? FirestoreSeedDataSource(firestore: firestore);

  @override
  Future<Result<List<Clinic>>> getClinics() async {
    try {
      await _seedDataSource.seedIfEmpty();

      final snapshot = await _firestore.collection('clinics').get();
      final clinics = snapshot.docs
          .map((doc) => ClinicModel.fromFirestore(doc).toEntity())
          .toList();

      return Success(clinics);
    } catch (e) {
      return Error(ServerFailure(message: 'Failed to load clinics: ${e.toString()}'));
    }
  }

  @override
  Future<Result<Clinic>> getClinicById(String clinicId) async {
    try {
      final doc = await _firestore.collection('clinics').doc(clinicId).get();
      if (!doc.exists) {
        return const Error(ServerFailure(message: 'Clinic not found'));
      }
      return Success(ClinicModel.fromFirestore(doc).toEntity());
    } catch (e) {
      return Error(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<List<QueueSlot>>> getSlots(String clinicId) async {
    try {
      final snapshot = await _firestore
          .collection('clinics')
          .doc(clinicId)
          .collection('slots')
          .orderBy('startTime')
          .get();

      final slots = snapshot.docs
          .map((doc) => QueueSlotModel.fromFirestore(doc, clinicId).toEntity())
          .toList();

      return Success(slots);
    } catch (e) {
      return Error(ServerFailure(message: 'Failed to load slots: ${e.toString()}'));
    }
  }
}

