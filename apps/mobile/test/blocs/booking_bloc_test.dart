// path: apps/mobile/test/blocs/booking_bloc_test.dart
import 'package:bloc_test/bloc_test.dart';
import 'package:clinic_queue/core/errors/failures.dart';
import 'package:clinic_queue/core/result/result.dart';
import 'package:clinic_queue/domain/entities/clinic.dart';
import 'package:clinic_queue/domain/entities/queue_slot.dart';
import 'package:clinic_queue/domain/entities/ticket.dart';
import 'package:clinic_queue/domain/usecases/book_slot_usecase.dart';
import 'package:clinic_queue/domain/usecases/get_clinics_usecase.dart';
import 'package:clinic_queue/domain/usecases/get_slots_usecase.dart';
import 'package:clinic_queue/presentation/blocs/booking/booking_bloc.dart';
import 'package:clinic_queue/presentation/blocs/booking/booking_event.dart';
import 'package:clinic_queue/presentation/blocs/booking/booking_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockGetClinicsUseCase extends Mock implements GetClinicsUseCase {}

class MockGetSlotsUseCase extends Mock implements GetSlotsUseCase {}

class MockBookSlotUseCase extends Mock implements BookSlotUseCase {}

void main() {
  group('BookingBloc', () {
    late MockGetClinicsUseCase mockGetClinicsUseCase;
    late MockGetSlotsUseCase mockGetSlotsUseCase;
    late MockBookSlotUseCase mockBookSlotUseCase;

    const testClinic = Clinic(
      id: 'c_mbagathi',
      name: 'Mbagathi Hospital',
      subCounty: 'Kibra, Nairobi',
      address: 'Mbagathi Way',
      openingHours: '08:00 - 17:00',
      totalSlotsToday: 20,
      availableSlotsToday: 10,
    );

    final testSlot = QueueSlot(
      id: 'slot_1',
      clinicId: 'c_mbagathi',
      startTime: DateTime(2026, 11, 7, 9, 0),
      endTime: DateTime(2026, 11, 7, 9, 30),
      capacity: 5,
      bookedCount: 2,
    );

    final testTicket = Ticket(
      id: 'ticket_001',
      clinicId: 'c_mbagathi',
      patientId: 'patient_123',
      ticketNumber: 'A042',
      status: TicketStatus.waiting,
      joinedAt: DateTime(2026, 11, 7, 9, 5),
      reasonCode: 'TRIAGE_GENERAL',
    );

    setUp(() {
      mockGetClinicsUseCase = MockGetClinicsUseCase();
      mockGetSlotsUseCase = MockGetSlotsUseCase();
      mockBookSlotUseCase = MockBookSlotUseCase();
    });

    test('initial state is BookingInitial', () {
      final bloc = BookingBloc(
        getClinicsUseCase: mockGetClinicsUseCase,
        getSlotsUseCase: mockGetSlotsUseCase,
        bookSlotUseCase: mockBookSlotUseCase,
      );
      expect(bloc.state, equals(const BookingInitial()));
      bloc.close();
    });

    blocTest<BookingBloc, BookingState>(
      'emits [BookingLoading, BookingClinicsLoaded] when clinics are retrieved',
      setUp: () {
        when(mockGetClinicsUseCase.execute())
            .thenAnswer((_) async => const Success([testClinic]));
      },
      build: () => BookingBloc(
        getClinicsUseCase: mockGetClinicsUseCase,
        getSlotsUseCase: mockGetSlotsUseCase,
        bookSlotUseCase: mockBookSlotUseCase,
      ),
      act: (bloc) => bloc.add(const BookingClinicsLoadRequested()),
      expect: () => [
        const BookingLoading(),
        const BookingClinicsLoaded([testClinic]),
      ],
    );

    blocTest<BookingBloc, BookingState>(
      'emits [BookingLoading, BookingSlotsLoaded] when slots are retrieved',
      setUp: () {
        when(mockGetSlotsUseCase.execute('c_mbagathi'))
            .thenAnswer((_) async => Success([testSlot]));
      },
      build: () => BookingBloc(
        getClinicsUseCase: mockGetClinicsUseCase,
        getSlotsUseCase: mockGetSlotsUseCase,
        bookSlotUseCase: mockBookSlotUseCase,
      ),
      act: (bloc) => bloc.add(const BookingSlotsLoadRequested('c_mbagathi')),
      expect: () => [
        const BookingLoading(),
        BookingSlotsLoaded(slots: [testSlot]),
      ],
    );

    blocTest<BookingBloc, BookingState>(
      'emits [BookingLoading, BookingSuccess] on successful atomic booking transaction',
      setUp: () {
        when(
          mockBookSlotUseCase.execute(
            clinicId: 'c_mbagathi',
            slotId: 'slot_1',
            patientId: 'patient_123',
            reasonCode: 'TRIAGE_GENERAL',
          ),
        ).thenAnswer((_) async => Success(testTicket));
      },
      build: () => BookingBloc(
        getClinicsUseCase: mockGetClinicsUseCase,
        getSlotsUseCase: mockGetSlotsUseCase,
        bookSlotUseCase: mockBookSlotUseCase,
      ),
      act: (bloc) => bloc.add(
        const BookingSubmitted(
          clinicId: 'c_mbagathi',
          slotId: 'slot_1',
          patientId: 'patient_123',
          reasonCode: 'TRIAGE_GENERAL',
        ),
      ),
      expect: () => [
        const BookingLoading(),
        BookingSuccess(testTicket),
      ],
    );

    blocTest<BookingBloc, BookingState>(
      'emits [BookingLoading, BookingFailureState] on DoubleBookingFailure',
      setUp: () {
        when(
          mockBookSlotUseCase.execute(
            clinicId: 'c_mbagathi',
            slotId: 'slot_1',
            patientId: 'patient_123',
            reasonCode: 'TRIAGE_GENERAL',
          ),
        ).thenAnswer(
          (_) async => const Error(
            DoubleBookingFailure(message: 'This slot has just reached full capacity.'),
          ),
        );
      },
      build: () => BookingBloc(
        getClinicsUseCase: mockGetClinicsUseCase,
        getSlotsUseCase: mockGetSlotsUseCase,
        bookSlotUseCase: mockBookSlotUseCase,
      ),
      act: (bloc) => bloc.add(
        const BookingSubmitted(
          clinicId: 'c_mbagathi',
          slotId: 'slot_1',
          patientId: 'patient_123',
          reasonCode: 'TRIAGE_GENERAL',
        ),
      ),
      expect: () => [
        const BookingLoading(),
        const BookingFailureState('This slot has just reached full capacity.'),
      ],
    );
  });
}

