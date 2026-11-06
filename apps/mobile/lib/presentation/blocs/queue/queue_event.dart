// path: apps/mobile/lib/presentation/blocs/queue/queue_event.dart
import 'package:equatable/equatable.dart';
import '../../../domain/entities/ticket.dart';

abstract class QueueEvent extends Equatable {
  const QueueEvent();

  @override
  List<Object?> get props => [];
}

class QueueSubscriptionRequested extends QueueEvent {
  final String patientId;

  const QueueSubscriptionRequested(this.patientId);

  @override
  List<Object?> get props => [patientId];
}

class QueueTicketUpdated extends QueueEvent {
  final Ticket? ticket;

  const QueueTicketUpdated(this.ticket);

  @override
  List<Object?> get props => [ticket];
}

class QueuePositionsUpdated extends QueueEvent {
  final List<Ticket> waitingTickets;

  const QueuePositionsUpdated(this.waitingTickets);

  @override
  List<Object?> get props => [waitingTickets];
}

class QueueConnectivityChanged extends QueueEvent {
  final bool isOffline;

  const QueueConnectivityChanged(this.isOffline);

  @override
  List<Object?> get props => [isOffline];
}

class QueueTicketCancelRequested extends QueueEvent {
  final String clinicId;
  final String ticketId;

  const QueueTicketCancelRequested({
    required this.clinicId,
    required this.ticketId,
  });

  @override
  List<Object?> get props => [clinicId, ticketId];
}
