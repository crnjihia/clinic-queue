// path: apps/mobile/lib/data/repositories/clinic_repository_impl.dart
import 'package:cloud_firestore/cloud_firestore.dart';

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

  static final List<Clinic> _fallbackClinics = [
    const Clinic(
      id: 'c_mbagathi',
      name: 'Mbagathi Sub-County Hospital Outpatient',
      subCounty: 'Kibra / Langata, Nairobi',
      address: 'Mbagathi Way, Off Langata Road',
      openingHours: '08:00 - 17:00',
      totalSlotsToday: 24,
      availableSlotsToday: 12,
    ),
    const Clinic(
      id: 'c_westlands',
      name: 'Westlands Health Centre',
      subCounty: 'Westlands, Nairobi',
      address: 'Waiyaki Way, Next to Westlands Roundabout',
      openingHours: '08:30 - 16:30',
      totalSlotsToday: 16,
      availableSlotsToday: 6,
    ),
    const Clinic(
      id: 'c_mama_lucy',
      name: 'Mama Lucy Kibaki Hospital Outpatient',
      subCounty: 'Embakasi Central, Nairobi',
      address: 'Kangundo Road, Kayole',
      openingHours: '24 Hours Triage',
      totalSlotsToday: 30,
      availableSlotsToday: 18,
    ),
  ];

  @override
  Future<Result<List<Clinic>>> getClinics() async {
    try {
      await _seedDataSource.seedIfEmpty();

      final snapshot = await _firestore
          .collection('clinics')
          .get(const GetOptions(source: Source.cache));

      if (snapshot.docs.isNotEmpty) {
        final clinics = snapshot.docs
            .map((doc) => ClinicModel.fromFirestore(doc).toEntity())
            .toList();
        return Success(clinics);
      }

      final serverSnapshot = await _firestore.collection('clinics').get();
      if (serverSnapshot.docs.isNotEmpty) {
        final clinics = serverSnapshot.docs
            .map((doc) => ClinicModel.fromFirestore(doc).toEntity())
            .toList();
        return Success(clinics);
      }

      return Success(_fallbackClinics);
    } catch (_) {
      // Fallback to static seed data when Firestore emulator is unreachable
      return Success(_fallbackClinics);
    }
  }

  @override
  Future<Result<Clinic>> getClinicById(String clinicId) async {
    try {
      final doc = await _firestore.collection('clinics').doc(clinicId).get();
      if (!doc.exists) {
        final fallback = _fallbackClinics.firstWhere(
          (c) => c.id == clinicId,
          orElse: () => _fallbackClinics.first,
        );
        return Success(fallback);
      }
      return Success(ClinicModel.fromFirestore(doc).toEntity());
    } catch (_) {
      final fallback = _fallbackClinics.firstWhere(
        (c) => c.id == clinicId,
        orElse: () => _fallbackClinics.first,
      );
      return Success(fallback);
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

      if (snapshot.docs.isNotEmpty) {
        final slots = snapshot.docs
            .map((doc) => QueueSlotModel.fromFirestore(doc, clinicId).toEntity())
            .toList();
        return Success(slots);
      }
    } catch (_) {
      // Fallback slots
    }

    final now = DateTime.now();
    final fallbackSlots = List.generate(5, (i) {
      final start = now.copyWith(hour: 8 + i, minute: 0);
      return QueueSlot(
        id: 'slot_0$i',
        clinicId: clinicId,
        startTime: start,
        endTime: start.add(const Duration(minutes: 30)),
        capacity: 5,
        bookedCount: i == 1 ? 5 : i,
      );
    });

    return Success(fallbackSlots);
  }
}
