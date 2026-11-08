// path: apps/mobile/lib/presentation/blocs/queue/queue_bloc.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/wait_time_calculator.dart';
import '../../../domain/entities/ticket.dart';
import '../../../domain/repositories/queue_repository.dart';
import '../../../domain/usecases/cancel_ticket_usecase.dart';
import '../../../domain/usecases/get_service_durations_usecase.dart';
import '../../../domain/usecases/watch_live_queue_usecase.dart';
import 'queue_event.dart';
import 'queue_state.dart';

class QueueBloc extends Bloc<QueueEvent, QueueState> {
  final WatchLiveQueueUseCase _watchLiveQueueUseCase;
  final GetServiceDurationsUseCase _getServiceDurationsUseCase;
  final CancelTicketUseCase _cancelTicketUseCase;
  final QueueRepository _queueRepository;

  StreamSubscription<Ticket?>? _patientTicketSub;
  StreamSubscription<List<Ticket>>? _clinicQueueSub;

  int _cachedAverageServiceMinutes = WaitTimeCalculator.defaultServiceDurationMinutes;

  QueueBloc({
    required WatchLiveQueueUseCase watchLiveQueueUseCase,
    required GetServiceDurationsUseCase getServiceDurationsUseCase,
    required CancelTicketUseCase cancelTicketUseCase,
    required QueueRepository queueRepository,
  })  : _watchLiveQueueUseCase = watchLiveQueueUseCase,
        _getServiceDurationsUseCase = getServiceDurationsUseCase,
        _cancelTicketUseCase = cancelTicketUseCase,
        _queueRepository = queueRepository,
        super(const QueueInitial()) {
    on<QueueSubscriptionRequested>(_onSubscriptionRequested);
    on<QueueTicketUpdated>(_onTicketUpdated);
    on<QueuePositionsUpdated>(_onPositionsUpdated);
    on<QueueConnectivityChanged>(_onConnectivityChanged);
    on<QueueTicketCancelRequested>(_onTicketCancelRequested);
  }

  Future<void> _onSubscriptionRequested(
    QueueSubscriptionRequested event,
    Emitter<QueueState> emit,
  ) async {
    emit(const QueueLoading());

    await _patientTicketSub?.cancel();
    _patientTicketSub = _watchLiveQueueUseCase.execute(event.patientId).listen(
      (ticket) {
        add(QueueTicketUpdated(ticket));
      },
      onError: (dynamic error) {
        // If offline, Firestore persistence emits cached snapshots or triggers offline state
        add(const QueueConnectivityChanged(true));
      },
    );
  }

  Future<void> _onTicketUpdated(
    QueueTicketUpdated event,
    Emitter<QueueState> emit,
  ) async {
    final ticket = event.ticket;

    if (ticket == null || !ticket.isActive) {
      if (ticket != null && ticket.status == TicketStatus.cancelled) {
        emit(const QueueCancelledState());
      } else {
        emit(const QueueEmpty());
      }
      await _clinicQueueSub?.cancel();
      return;
    }

    // Load rolling average durations for clinic
    final durationsResult = await _getServiceDurationsUseCase.execute(ticket.clinicId);
    durationsResult.fold(
      onSuccess: (durations) {
        _cachedAverageServiceMinutes = WaitTimeCalculator.calculateRollingAverageMinutes(durations);
      },
      onError: (_) {
        // Fall back to default duration
      },
    );

    // Subscribe to clinic queue to calculate exact people ahead
    await _clinicQueueSub?.cancel();
    _clinicQueueSub = _queueRepository.watchClinicQueue(ticket.clinicId).listen((waitingList) {
      add(QueuePositionsUpdated(waitingList));
    });

    final currentOffline = state is QueueLoaded ? (state as QueueLoaded).isOffline : false;

    emit(
      QueueLoaded(
        ticket: ticket,
        peopleAhead: 0,
        estimatedWait: Duration.zero,
        averageServiceMinutes: _cachedAverageServiceMinutes,
        isOffline: currentOffline,
      ),
    );
  }

  void _onPositionsUpdated(
    QueuePositionsUpdated event,
    Emitter<QueueState> emit,
  ) {
    if (state is QueueLoaded) {
      final current = state as QueueLoaded;
      final waitingList = event.waitingTickets;

      // Find position ahead
      final myIndex = waitingList.indexWhere((t) => t.id == current.ticket.id);
      final peopleAhead = myIndex < 0 ? 0 : myIndex;

      final waitDuration = WaitTimeCalculator.estimateWaitDuration(
        peopleAhead: peopleAhead,
        averageServiceMinutes: current.averageServiceMinutes,
      );

      emit(
        current.copyWith(
          peopleAhead: peopleAhead,
          estimatedWait: waitDuration,
        ),
      );
    }
  }

  void _onConnectivityChanged(
    QueueConnectivityChanged event,
    Emitter<QueueState> emit,
  ) {
    if (state is QueueLoaded) {
      final current = state as QueueLoaded;
      emit(current.copyWith(isOffline: event.isOffline));
    }
  }

  Future<void> _onTicketCancelRequested(
    QueueTicketCancelRequested event,
    Emitter<QueueState> emit,
  ) async {
    final result = await _cancelTicketUseCase.execute(
      clinicId: event.clinicId,
      ticketId: event.ticketId,
    );

    result.fold(
      onSuccess: (_) => emit(const QueueCancelledState()),
      onError: (failure) => emit(QueueFailureState(failure.message)),
    );
  }

  @override
  Future<void> close() {
    _patientTicketSub?.cancel();
    _clinicQueueSub?.cancel();
    return super.close();
  }
}

