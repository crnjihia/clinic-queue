// path: apps/mobile/lib/data/datasources/firestore_seed_datasource.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreSeedDataSource {
  final FirebaseFirestore _firestore;

  FirestoreSeedDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  static const List<Map<String, dynamic>> initialClinics = [
    {
      'id': 'c_mbagathi',
      'name': 'Mbagathi Sub-County Hospital Outpatient',
      'subCounty': 'Kibra / Langata, Nairobi',
      'address': 'Mbagathi Way, Off Langata Road',
      'openingHours': '08:00 - 17:00',
      'totalSlotsToday': 24,
      'availableSlotsToday': 12,
    },
    {
      'id': 'c_westlands',
      'name': 'Westlands Health Centre',
      'subCounty': 'Westlands, Nairobi',
      'address': 'Waiyaki Way, Next to Westlands Roundabout',
      'openingHours': '08:30 - 16:30',
      'totalSlotsToday': 16,
      'availableSlotsToday': 6,
    },
    {
      'id': 'c_mama_lucy',
      'name': 'Mama Lucy Kibaki Hospital Outpatient',
      'subCounty': 'Embakasi Central, Nairobi',
      'address': 'Kangundo Road, Kayole',
      'openingHours': '24 Hours Triage',
      'totalSlotsToday': 30,
      'availableSlotsToday': 18,
    },
  ];

  Future<void> seedIfEmpty() async {
    final existing = await _firestore.collection('clinics').limit(1).get();
    if (existing.docs.isNotEmpty) return;

    for (final clinicData in initialClinics) {
      final clinicId = clinicData['id'] as String;
      final clinicRef = _firestore.collection('clinics').doc(clinicId);

      await clinicRef.set({
        'name': clinicData['name'],
        'subCounty': clinicData['subCounty'],
        'address': clinicData['address'],
        'openingHours': clinicData['openingHours'],
        'totalSlotsToday': clinicData['totalSlotsToday'],
        'availableSlotsToday': clinicData['availableSlotsToday'],
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Seed slots for each clinic
      final slotsCollection = clinicRef.collection('slots');
      final now = DateTime.now();

      final times = [
        now.copyWith(hour: 9, minute: 0),
        now.copyWith(hour: 9, minute: 30),
        now.copyWith(hour: 10, minute: 0),
        now.copyWith(hour: 10, minute: 30),
        now.copyWith(hour: 11, minute: 0),
      ];

      for (int i = 0; i < times.length; i++) {
        final start = times[i];
        final end = start.add(const Duration(minutes: 30));
        await slotsCollection.doc('slot_0$i').set({
          'startTime': Timestamp.fromDate(start),
          'endTime': Timestamp.fromDate(end),
          'capacity': 5,
          'bookedCount': i == 2 ? 5 : i, // slot 2 full for test
        });
      }
    }
  }
}
