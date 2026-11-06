// path: apps/mobile/test/blocs/queue_bloc_test.dart
import 'dart:async';
import 'package:bloc_test/bloc_test.dart';
import 'package:clinic_queue/core/result/result.dart';
import 'package:clinic_queue/domain/entities/ticket.dart';
import 'package:clinic_queue/domain/repositories/queue_repository.dart';
import 'package:clinic_queue/domain/usecases/cancel_ticket_usecase.dart';
import 'package:clinic_queue/domain/usecases/get_service_durations_usecase.dart';
import 'package:clinic_queue/domain/usecases/watch_live_queue_usecase.dart';
import 'package:clinic_queue/presentation/blocs/queue/queue_bloc.dart';
import 'package:clinic_queue/presentation/blocs/queue/queue_event.dart';
import 'package:clinic_queue/presentation/blocs/queue/queue_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockWatchLiveQueueUseCase extends Mock implements WatchLiveQueueUseCase {}

class MockGetServiceDurationsUseCase extends Mock implements GetServiceDurationsUseCase {}

class MockCancelTicketUseCase extends Mock implements CancelTicketUseCase {}

class MockQueueRepository extends Mock implements QueueRepository {}

void main() {
  group('QueueBloc', () {
    late MockWatchLiveQueueUseCase mockWatchLiveQueueUseCase;
    late MockGetServiceDurationsUseCase mockGetServiceDurationsUseCase;
    late MockCancelTicketUseCase mockCancelTicketUseCase;
    late MockQueueRepository mockQueueRepository;

    late StreamController<Ticket?> patientTicketStreamController;
    late StreamController<List<Ticket>> clinicQueueStreamController;

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
      mockWatchLiveQueueUseCase = MockWatchLiveQueueUseCase();
      mockGetServiceDurationsUseCase = MockGetServiceDurationsUseCase();
      mockCancelTicketUseCase = MockCancelTicketUseCase();
      mockQueueRepository = MockQueueRepository();

      patientTicketStreamController = StreamController<Ticket?>.broadcast();
      clinicQueueStreamController = StreamController<List<Ticket>>.broadcast();

      when(mockWatchLiveQueueUseCase.execute('patient_123'))
          .thenAnswer((_) => patientTicketStreamController.stream);

      when(mockQueueRepository.watchClinicQueue('c_mbagathi'))
          .thenAnswer((_) => clinicQueueStreamController.stream);

      when(mockGetServiceDurationsUseCase.execute('c_mbagathi'))
          .thenAnswer((_) async => const Success([Duration(minutes: 10), Duration(minutes: 8)]));
    });

    tearDown(() {
      patientTicketStreamController.close();
      clinicQueueStreamController.close();
    });

    test('initial state is QueueInitial', () {
      final bloc = QueueBloc(
        watchLiveQueueUseCase: mockWatchLiveQueueUseCase,
        getServiceDurationsUseCase: mockGetServiceDurationsUseCase,
        cancelTicketUseCase: mockCancelTicketUseCase,
        queueRepository: mockQueueRepository,
      );
      expect(bloc.state, equals(const QueueInitial()));
      bloc.close();
    });

    blocTest<QueueBloc, QueueState>(
      'emits [QueueLoading, QueueLoaded] when patient has active waiting ticket',
      build: () => QueueBloc(
        watchLiveQueueUseCase: mockWatchLiveQueueUseCase,
        getServiceDurationsUseCase: mockGetServiceDurationsUseCase,
        cancelTicketUseCase: mockCancelTicketUseCase,
        queueRepository: mockQueueRepository,
      ),
      act: (bloc) {
        bloc.add(const QueueSubscriptionRequested('patient_123'));
        patientTicketStreamController.add(testTicket);
      },
      expect: () => [
        const QueueLoading(),
        QueueLoaded(
          ticket: testTicket,
          peopleAhead: 0,
          estimatedWait: Duration.zero,
          averageServiceMinutes: 9,
        ),
      ],
    );

    blocTest<QueueBloc, QueueState>(
      'updates peopleAhead and estimatedWait when clinic queue advances',
      build: () => QueueBloc(
        watchLiveQueueUseCase: mockWatchLiveQueueUseCase,
        getServiceDurationsUseCase: mockGetServiceDurationsUseCase,
        cancelTicketUseCase: mockCancelTicketUseCase,
        queueRepository: mockQueueRepository,
      ),
      seed: () => QueueLoaded(
        ticket: testTicket,
        peopleAhead: 0,
        estimatedWait: Duration.zero,
        averageServiceMinutes: 10,
      ),
      act: (bloc) {
        // Earlier patients ahead in queue
        final earlierPatient = Ticket(
          id: 'ticket_000',
          clinicId: 'c_mbagathi',
          patientId: 'patient_000',
          ticketNumber: 'A041',
          status: TicketStatus.waiting,
          joinedAt: DateTime(2026, 11, 7, 9, 0),
          reasonCode: 'TRIAGE',
        );

        bloc.add(QueuePositionsUpdated([earlierPatient, testTicket]));
      },
      expect: () => [
        QueueLoaded(
          ticket: testTicket,
          peopleAhead: 1,
          estimatedWait: const Duration(minutes: 10),
          averageServiceMinutes: 10,
        ),
      ],
    );

    blocTest<QueueBloc, QueueState>(
      'toggles isOffline flag when QueueConnectivityChanged is dispatched',
      build: () => QueueBloc(
        watchLiveQueueUseCase: mockWatchLiveQueueUseCase,
        getServiceDurationsUseCase: mockGetServiceDurationsUseCase,
        cancelTicketUseCase: mockCancelTicketUseCase,
        queueRepository: mockQueueRepository,
      ),
      seed: () => QueueLoaded(
        ticket: testTicket,
        peopleAhead: 2,
        estimatedWait: const Duration(minutes: 20),
        averageServiceMinutes: 10,
        isOffline: false,
      ),
      act: (bloc) => bloc.add(const QueueConnectivityChanged(true)),
      expect: () => [
        QueueLoaded(
          ticket: testTicket,
          peopleAhead: 2,
          estimatedWait: const Duration(minutes: 20),
          averageServiceMinutes: 10,
          isOffline: true,
        ),
      ],
    );

    blocTest<QueueBloc, QueueState>(
      'emits [QueueCancelledState] on successful cancellation',
      setUp: () {
        when(mockCancelTicketUseCase.execute(clinicId: 'c_mbagathi', ticketId: 'ticket_001'))
            .thenAnswer((_) async => const Success(null));
      },
      build: () => QueueBloc(
        watchLiveQueueUseCase: mockWatchLiveQueueUseCase,
        getServiceDurationsUseCase: mockGetServiceDurationsUseCase,
        cancelTicketUseCase: mockCancelTicketUseCase,
        queueRepository: mockQueueRepository,
      ),
      act: (bloc) => bloc.add(
        const QueueTicketCancelRequested(clinicId: 'c_mbagathi', ticketId: 'ticket_001'),
      ),
      expect: () => [
        const QueueCancelledState(),
      ],
    );
  });
}
