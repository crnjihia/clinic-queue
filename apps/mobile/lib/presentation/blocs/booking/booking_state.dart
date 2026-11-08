// path: apps/mobile/lib/presentation/blocs/booking/booking_state.dart
import 'package:equatable/equatable.dart';
import '../../../domain/entities/clinic.dart';
import '../../../domain/entities/queue_slot.dart';
import '../../../domain/entities/ticket.dart';

abstract class BookingState extends Equatable {
  const BookingState();

  @override
  List<Object?> get props => [];
}

class BookingInitial extends BookingState {
  const BookingInitial();
}

class BookingLoading extends BookingState {
  const BookingLoading();
}

class BookingClinicsLoaded extends BookingState {
  final List<Clinic> clinics;

  const BookingClinicsLoaded(this.clinics);

  @override
  List<Object?> get props => [clinics];
}

class BookingSlotsLoaded extends BookingState {
  final List<QueueSlot> slots;
  final String? selectedSlotId;

  const BookingSlotsLoaded({
    required this.slots,
    this.selectedSlotId,
  });

  BookingSlotsLoaded copyWith({
    List<QueueSlot>? slots,
    String? selectedSlotId,
  }) {
    return BookingSlotsLoaded(
      slots: slots ?? this.slots,
      selectedSlotId: selectedSlotId ?? this.selectedSlotId,
    );
  }

  @override
  List<Object?> get props => [slots, selectedSlotId];
}

class BookingSuccess extends BookingState {
  final Ticket ticket;

  const BookingSuccess(this.ticket);

  @override
  List<Object?> get props => [ticket];
}

class BookingFailureState extends BookingState {
  final String message;

  const BookingFailureState(this.message);

  @override
  List<Object?> get props => [message];
}

