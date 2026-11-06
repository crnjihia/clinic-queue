// path: apps/mobile/test/blocs/staff_bloc_test.dart
import 'dart:async';
import 'package:bloc_test/bloc_test.dart';
import 'package:clinic_queue/core/result/result.dart';
import 'package:clinic_queue/domain/entities/ticket.dart';
import 'package:clinic_queue/domain/usecases/advance_queue_usecase.dart';
import 'package:clinic_queue/domain/usecases/watch_clinic_queue_usecase.dart';
import 'package:clinic_queue/presentation/blocs/staff/staff_bloc.dart';
import 'package:clinic_queue/presentation/blocs/staff/staff_event.dart';
import 'package:clinic_queue/presentation/blocs/staff/staff_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockWatchClinicQueueUseCase extends Mock implements WatchClinicQueueUseCase {}

class MockAdvanceQueueUseCase extends Mock implements AdvanceQueueUseCase {}

void main() {
  group('StaffBloc', () {
    late MockWatchClinicQueueUseCase mockWatchClinicQueueUseCase;
    late MockAdvanceQueueUseCase mockAdvanceQueueUseCase;
    late StreamController<List<Ticket>> clinicQueueController;

    final testTicketA = Ticket(
      id: 'ticket_001',
      clinicId: 'c_mbagathi',
      patientId: 'patient_001',
      ticketNumber: 'A041',
      status: TicketStatus.waiting,
      joinedAt: DateTime(2026, 11, 7, 9, 0),
      reasonCode: 'TRIAGE',
    );

    final testTicketB = Ticket(
      id: 'ticket_002',
      clinicId: 'c_mbagathi',
      patientId: 'patient_002',
      ticketNumber: 'A042',
      status: TicketStatus.waiting,
      joinedAt: DateTime(2026, 11, 7, 9, 10),
      reasonCode: 'IMMUNISATION',
    );

    setUp(() {
      mockWatchClinicQueueUseCase = MockWatchClinicQueueUseCase();
      mockAdvanceQueueUseCase = MockAdvanceQueueUseCase();
      clinicQueueController = StreamController<List<Ticket>>.broadcast();

      when(mockWatchClinicQueueUseCase.execute('c_mbagathi'))
          .thenAnswer((_) => clinicQueueController.stream);
    });

    tearDown(() {
      clinicQueueController.close();
    });

    test('initial state is StaffInitial', () {
      final bloc = StaffBloc(
        watchClinicQueueUseCase: mockWatchClinicQueueUseCase,
        advanceQueueUseCase: mockAdvanceQueueUseCase,
      );
      expect(bloc.state, equals(const StaffInitial()));
      bloc.close();
    });

    blocTest<StaffBloc, StaffState>(
      'emits [StaffLoading, StaffQueueLoaded] when clinic queue stream emits tickets',
      build: () => StaffBloc(
        watchClinicQueueUseCase: mockWatchClinicQueueUseCase,
        advanceQueueUseCase: mockAdvanceQueueUseCase,
      ),
      act: (bloc) {
        bloc.add(const StaffQueueSubscriptionRequested('c_mbagathi'));
        clinicQueueController.add([testTicketA, testTicketB]);
      },
      expect: () => [
        const StaffLoading(),
        StaffQueueLoaded(
          waitingTickets: [testTicketA, testTicketB],
          calledTicket: null,
          inServiceTicket: null,
        ),
      ],
    );

    blocTest<StaffBloc, StaffState>(
      'advances first waiting patient to called state on StaffCallNextRequested',
      setUp: () {
        when(
          mockAdvanceQueueUseCase.execute(
            clinicId: 'c_mbagathi',
            ticketId: 'ticket_001',
            newStatus: TicketStatus.called,
          ),
        ).thenAnswer((_) async => const Success(null));
      },
      build: () => StaffBloc(
        watchClinicQueueUseCase: mockWatchClinicQueueUseCase,
        advanceQueueUseCase: mockAdvanceQueueUseCase,
      ),
      seed: () => StaffQueueLoaded(
        waitingTickets: [testTicketA, testTicketB],
        calledTicket: null,
        inServiceTicket: null,
      ),
      act: (bloc) => bloc.add(const StaffCallNextRequested('c_mbagathi')),
      expect: () => [
        StaffQueueLoaded(
          waitingTickets: [testTicketA, testTicketB],
          calledTicket: null,
          inServiceTicket: null,
          feedbackMessage: 'Called Ticket #A041 to Consultation.',
        ),
      ],
    );

    blocTest<StaffBloc, StaffState>(
      'returns feedback message when no patients are waiting to be called',
      build: () => StaffBloc(
        watchClinicQueueUseCase: mockWatchClinicQueueUseCase,
        advanceQueueUseCase: mockAdvanceQueueUseCase,
      ),
      seed: () => const StaffQueueLoaded(
        waitingTickets: [],
        calledTicket: null,
        inServiceTicket: null,
      ),
      act: (bloc) => bloc.add(const StaffCallNextRequested('c_mbagathi')),
      expect: () => [
        const StaffQueueLoaded(
          waitingTickets: [],
          calledTicket: null,
          inServiceTicket: null,
          feedbackMessage: 'No patients waiting in queue.',
        ),
      ],
    );
  });
}
