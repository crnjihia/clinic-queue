// path: apps/mobile/lib/presentation/blocs/staff/staff_event.dart
import 'package:equatable/equatable.dart';
import '../../../domain/entities/ticket.dart';

abstract class StaffEvent extends Equatable {
  const StaffEvent();

  @override
  List<Object?> get props => [];
}

class StaffQueueSubscriptionRequested extends StaffEvent {
  final String clinicId;

  const StaffQueueSubscriptionRequested(this.clinicId);

  @override
  List<Object?> get props => [clinicId];
}

class StaffQueueUpdated extends StaffEvent {
  final List<Ticket> tickets;

  const StaffQueueUpdated(this.tickets);

  @override
  List<Object?> get props => [tickets];
}

class StaffCallNextRequested extends StaffEvent {
  final String clinicId;

  const StaffCallNextRequested(this.clinicId);

  @override
  List<Object?> get props => [clinicId];
}

class StaffUpdateStatusRequested extends StaffEvent {
  final String clinicId;
  final String ticketId;
  final TicketStatus newStatus;

  const StaffUpdateStatusRequested({
    required this.clinicId,
    required this.ticketId,
    required this.newStatus,
  });

  @override
  List<Object?> get props => [clinicId, ticketId, newStatus];
}
