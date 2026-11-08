// path: apps/mobile/lib/presentation/blocs/booking/booking_event.dart
import 'package:equatable/equatable.dart';

abstract class BookingEvent extends Equatable {
  const BookingEvent();

  @override
  List<Object?> get props => [];
}

class BookingClinicsLoadRequested extends BookingEvent {
  const BookingClinicsLoadRequested();
}

class BookingSlotsLoadRequested extends BookingEvent {
  final String clinicId;

  const BookingSlotsLoadRequested(this.clinicId);

  @override
  List<Object?> get props => [clinicId];
}

class BookingSlotSelected extends BookingEvent {
  final String slotId;

  const BookingSlotSelected(this.slotId);

  @override
  List<Object?> get props => [slotId];
}

class BookingSubmitted extends BookingEvent {
  final String clinicId;
  final String slotId;
  final String patientId;
  final String reasonCode;

  const BookingSubmitted({
    required this.clinicId,
    required this.slotId,
    required this.patientId,
    required this.reasonCode,
  });

  @override
  List<Object?> get props => [clinicId, slotId, patientId, reasonCode];
}

