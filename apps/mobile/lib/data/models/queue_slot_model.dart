// path: apps/mobile/lib/data/models/queue_slot_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/queue_slot.dart';

class QueueSlotModel {
  final String id;
  final String clinicId;
  final DateTime startTime;
  final DateTime endTime;
  final int capacity;
  final int bookedCount;

  const QueueSlotModel({
    required this.id,
    required this.clinicId,
    required this.startTime,
    required this.endTime,
    required this.capacity,
    required this.bookedCount,
  });

  factory QueueSlotModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
    String clinicId,
  ) {
    final data = doc.data() ?? {};
    final startTimestamp = data['startTime'] as Timestamp?;
    final endTimestamp = data['endTime'] as Timestamp?;

    return QueueSlotModel(
      id: doc.id,
      clinicId: clinicId,
      startTime: startTimestamp?.toDate() ?? DateTime.now(),
      endTime: endTimestamp?.toDate() ?? DateTime.now().add(const Duration(minutes: 30)),
      capacity: (data['capacity'] as num?)?.toInt() ?? 5,
      bookedCount: (data['bookedCount'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'capacity': capacity,
      'bookedCount': bookedCount,
    };
  }

  QueueSlot toEntity() {
    return QueueSlot(
      id: id,
      clinicId: clinicId,
      startTime: startTime,
      endTime: endTime,
      capacity: capacity,
      bookedCount: bookedCount,
    );
  }
}
