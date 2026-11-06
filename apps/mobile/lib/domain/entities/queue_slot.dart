// path: apps/mobile/lib/domain/entities/queue_slot.dart
import 'package:equatable/equatable.dart';

class QueueSlot extends Equatable {
  final String id;
  final String clinicId;
  final DateTime startTime;
  final DateTime endTime;
  final int capacity;
  final int bookedCount;

  const QueueSlot({
    required this.id,
    required this.clinicId,
    required this.startTime,
    required this.endTime,
    required this.capacity,
    required this.bookedCount,
  });

  bool get isAvailable => bookedCount < capacity;
  int get remainingCapacity => (capacity - bookedCount).clamp(0, capacity);

  @override
  List<Object?> get props => [
        id,
        clinicId,
        startTime,
        endTime,
        capacity,
        bookedCount,
      ];
}

