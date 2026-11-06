// path: apps/mobile/lib/data/models/clinic_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/clinic.dart';

class ClinicModel {
  final String id;
  final String name;
  final String subCounty;
  final String address;
  final String openingHours;
  final int totalSlotsToday;
  final int availableSlotsToday;

  const ClinicModel({
    required this.id,
    required this.name,
    required this.subCounty,
    required this.address,
    required this.openingHours,
    required this.totalSlotsToday,
    required this.availableSlotsToday,
  });

  factory ClinicModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return ClinicModel(
      id: doc.id,
      name: (data['name'] as String?) ?? 'Clinic',
      subCounty: (data['subCounty'] as String?) ?? 'Nairobi',
      address: (data['address'] as String?) ?? '',
      openingHours: (data['openingHours'] as String?) ?? '08:00 - 17:00',
      totalSlotsToday: (data['totalSlotsToday'] as num?)?.toInt() ?? 20,
      availableSlotsToday: (data['availableSlotsToday'] as num?)?.toInt() ?? 10,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'subCounty': subCounty,
      'address': address,
      'openingHours': openingHours,
      'totalSlotsToday': totalSlotsToday,
      'availableSlotsToday': availableSlotsToday,
    };
  }

  Clinic toEntity() {
    return Clinic(
      id: id,
      name: name,
      subCounty: subCounty,
      address: address,
      openingHours: openingHours,
      totalSlotsToday: totalSlotsToday,
      availableSlotsToday: availableSlotsToday,
    );
  }
}

