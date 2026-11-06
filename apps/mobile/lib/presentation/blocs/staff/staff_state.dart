// path: apps/mobile/lib/presentation/blocs/staff/staff_state.dart
import 'package:equatable/equatable.dart';
import '../../../domain/entities/ticket.dart';

abstract class StaffState extends Equatable {
  const StaffState();

  @override
  List<Object?> get props => [];
}

class StaffInitial extends StaffState {
  const StaffInitial();
}

class StaffLoading extends StaffState {
  const StaffLoading();
}

class StaffQueueLoaded extends StaffState {
  final List<Ticket> waitingTickets;
  final Ticket? calledTicket;
  final Ticket? inServiceTicket;
  final String? feedbackMessage;

  const StaffQueueLoaded({
    required this.waitingTickets,
    this.calledTicket,
    this.inServiceTicket,
    this.feedbackMessage,
  });

  StaffQueueLoaded copyWith({
    List<Ticket>? waitingTickets,
    Ticket? calledTicket,
    Ticket? inServiceTicket,
    String? feedbackMessage,
  }) {
    return StaffQueueLoaded(
      waitingTickets: waitingTickets ?? this.waitingTickets,
      calledTicket: calledTicket ?? this.calledTicket,
      inServiceTicket: inServiceTicket ?? this.inServiceTicket,
      feedbackMessage: feedbackMessage,
    );
  }

  @override
  List<Object?> get props => [
        waitingTickets,
        calledTicket,
        inServiceTicket,
        feedbackMessage,
      ];
}

class StaffFailureState extends StaffState {
  final String message;

  const StaffFailureState(this.message);

  @override
  List<Object?> get props => [message];
}
