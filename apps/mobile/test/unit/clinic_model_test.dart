// path: apps/mobile/test/unit/clinic_model_test.dart
import 'package:clinic_queue/data/models/clinic_model.dart';
import 'package:clinic_queue/data/models/queue_slot_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ClinicModel & QueueSlotModel', () {
    test('ClinicModel maps accurately to Clinic domain entity', () {
      const model = ClinicModel(
        id: 'c_mama_lucy',
        name: 'Mama Lucy Kibaki Hospital Outpatient',
        subCounty: 'Embakasi Central, Nairobi',
        address: 'Kangundo Road',
        openingHours: '24 Hours Triage',
        totalSlotsToday: 30,
        availableSlotsToday: 5,
      );

      final entity = model.toEntity();

      expect(entity.id, equals('c_mama_lucy'));
      expect(entity.name, equals('Mama Lucy Kibaki Hospital Outpatient'));
      expect(entity.subCounty, equals('Embakasi Central, Nairobi'));
      expect(entity.isFullyBooked, isFalse);
    });

    test('QueueSlotModel calculates availability and remaining capacity', () {
      final now = DateTime.now();
      final slotModel = QueueSlotModel(
        id: 'slot_1',
        clinicId: 'c_mbagathi',
        startTime: now,
        endTime: now.add(const Duration(minutes: 30)),
        capacity: 10,
        bookedCount: 8,
      );

      final entity = slotModel.toEntity();

      expect(entity.isAvailable, isTrue);
      expect(entity.remainingCapacity, equals(2));
    });
  });
}

