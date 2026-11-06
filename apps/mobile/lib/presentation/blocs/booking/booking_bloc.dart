// path: apps/mobile/lib/presentation/blocs/booking/booking_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/book_slot_usecase.dart';
import '../../../domain/usecases/get_clinics_usecase.dart';
import '../../../domain/usecases/get_slots_usecase.dart';
import 'booking_event.dart';
import 'booking_state.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final GetClinicsUseCase _getClinicsUseCase;
  final GetSlotsUseCase _getSlotsUseCase;
  final BookSlotUseCase _bookSlotUseCase;

  BookingBloc({
    required GetClinicsUseCase getClinicsUseCase,
    required GetSlotsUseCase getSlotsUseCase,
    required BookSlotUseCase bookSlotUseCase,
  })  : _getClinicsUseCase = getClinicsUseCase,
        _getSlotsUseCase = getSlotsUseCase,
        _bookSlotUseCase = bookSlotUseCase,
        super(const BookingInitial()) {
    on<BookingClinicsLoadRequested>(_onClinicsLoadRequested);
    on<BookingSlotsLoadRequested>(_onSlotsLoadRequested);
    on<BookingSlotSelected>(_onSlotSelected);
    on<BookingSubmitted>(_onBookingSubmitted);
  }

  Future<void> _onClinicsLoadRequested(
    BookingClinicsLoadRequested event,
    Emitter<BookingState> emit,
  ) async {
    emit(const BookingLoading());
    final result = await _getClinicsUseCase.execute();

    result.fold(
      onSuccess: (clinics) => emit(BookingClinicsLoaded(clinics)),
      onError: (failure) => emit(BookingFailureState(failure.message)),
    );
  }

  Future<void> _onSlotsLoadRequested(
    BookingSlotsLoadRequested event,
    Emitter<BookingState> emit,
  ) async {
    emit(const BookingLoading());
    final result = await _getSlotsUseCase.execute(event.clinicId);

    result.fold(
      onSuccess: (slots) => emit(BookingSlotsLoaded(slots: slots)),
      onError: (failure) => emit(BookingFailureState(failure.message)),
    );
  }

  void _onSlotSelected(
    BookingSlotSelected event,
    Emitter<BookingState> emit,
  ) {
    if (state is BookingSlotsLoaded) {
      final current = state as BookingSlotsLoaded;
      emit(current.copyWith(selectedSlotId: event.slotId));
    }
  }

  Future<void> _onBookingSubmitted(
    BookingSubmitted event,
    Emitter<BookingState> emit,
  ) async {
    emit(const BookingLoading());

    final result = await _bookSlotUseCase.execute(
      clinicId: event.clinicId,
      slotId: event.slotId,
      patientId: event.patientId,
      reasonCode: event.reasonCode,
    );

    result.fold(
      onSuccess: (ticket) => emit(BookingSuccess(ticket)),
      onError: (failure) => emit(BookingFailureState(failure.message)),
    );
  }
}
