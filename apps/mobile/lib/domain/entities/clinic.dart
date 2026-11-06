// path: apps/mobile/lib/domain/entities/clinic.dart
import 'package:equatable/equatable.dart';

class Clinic extends Equatable {
  final String id;
  final String name;
  final String subCounty;
  final String address;
  final String openingHours;
  final int totalSlotsToday;
  final int availableSlotsToday;

  const Clinic({
    required this.id,
    required this.name,
    required this.subCounty,
    required this.address,
    required this.openingHours,
    required this.totalSlotsToday,
    required this.availableSlotsToday,
  });

  bool get isFullyBooked => availableSlotsToday <= 0;

  @override
  List<Object?> get props => [
        id,
        name,
        subCounty,
        address,
        openingHours,
        totalSlotsToday,
        availableSlotsToday,
      ];
}
