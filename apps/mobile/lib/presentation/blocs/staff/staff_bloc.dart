// path: apps/mobile/lib/presentation/blocs/staff/staff_bloc.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/ticket.dart';
import '../../../domain/usecases/advance_queue_usecase.dart';
import '../../../domain/usecases/watch_clinic_queue_usecase.dart';
import 'staff_event.dart';
import 'staff_state.dart';

class StaffBloc extends Bloc<StaffEvent, StaffState> {
  final WatchClinicQueueUseCase _watchClinicQueueUseCase;
  final AdvanceQueueUseCase _advanceQueueUseCase;

  StreamSubscription<List<Ticket>>? _queueSubscription;

  StaffBloc({
    required WatchClinicQueueUseCase watchClinicQueueUseCase,
    required AdvanceQueueUseCase advanceQueueUseCase,
  })  : _watchClinicQueueUseCase = watchClinicQueueUseCase,
        _advanceQueueUseCase = advanceQueueUseCase,
        super(const StaffInitial()) {
    on<StaffQueueSubscriptionRequested>(_onSubscriptionRequested);
    on<StaffQueueUpdated>(_onQueueUpdated);
    on<StaffCallNextRequested>(_onCallNextRequested);
    on<StaffUpdateStatusRequested>(_onUpdateStatusRequested);
  }

  Future<void> _onSubscriptionRequested(
    StaffQueueSubscriptionRequested event,
    Emitter<StaffState> emit,
  ) async {
    emit(const StaffLoading());
    await _queueSubscription?.cancel();

    _queueSubscription = _watchClinicQueueUseCase.execute(event.clinicId).listen((tickets) {
      add(StaffQueueUpdated(tickets));
    });
  }

  void _onQueueUpdated(
    StaffQueueUpdated event,
    Emitter<StaffState> emit,
  ) {
    final all = event.tickets;
    final waiting = all.where((t) => t.status == TicketStatus.waiting).toList();
    final calledList = all.where((t) => t.status == TicketStatus.called).toList();
    final inServiceList = all.where((t) => t.status == TicketStatus.inService).toList();

    emit(
      StaffQueueLoaded(
        waitingTickets: waiting,
        calledTicket: calledList.isNotEmpty ? calledList.first : null,
        inServiceTicket: inServiceList.isNotEmpty ? inServiceList.first : null,
      ),
    );
  }

  Future<void> _onCallNextRequested(
    StaffCallNextRequested event,
    Emitter<StaffState> emit,
  ) async {
    if (state is StaffQueueLoaded) {
      final current = state as StaffQueueLoaded;
      if (current.waitingTickets.isEmpty) {
        emit(current.copyWith(feedbackMessage: 'No patients waiting in queue.'));
        return;
      }

      final nextTicket = current.waitingTickets.first;
      final result = await _advanceQueueUseCase.execute(
        clinicId: event.clinicId,
        ticketId: nextTicket.id,
        newStatus: TicketStatus.called,
      );

      result.fold(
        onSuccess: (_) {
          emit(current.copyWith(feedbackMessage: 'Called Ticket #${nextTicket.ticketNumber} to Consultation.'));
        },
        onError: (failure) {
          emit(StaffFailureState(failure.message));
        },
      );
    }
  }

  Future<void> _onUpdateStatusRequested(
    StaffUpdateStatusRequested event,
    Emitter<StaffState> emit,
  ) async {
    final result = await _advanceQueueUseCase.execute(
      clinicId: event.clinicId,
      ticketId: event.ticketId,
      newStatus: event.newStatus,
    );

    result.fold(
      onSuccess: (_) {
        if (state is StaffQueueLoaded) {
          final current = state as StaffQueueLoaded;
          emit(current.copyWith(feedbackMessage: 'Status updated to ${event.newStatus.name}.'));
        }
      },
      onError: (failure) {
        emit(StaffFailureState(failure.message));
      },
    );
  }

  @override
  Future<void> close() {
    _queueSubscription?.cancel();
    return super.close();
  }
}
