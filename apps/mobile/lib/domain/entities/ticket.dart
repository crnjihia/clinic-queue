// path: apps/mobile/lib/domain/entities/ticket.dart
import 'package:equatable/equatable.dart';
import 'payment.dart';

enum TicketStatus {
  waiting,
  called,
  inService,
  done,
  noShow,
  cancelled;

  static TicketStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'called':
        return TicketStatus.called;
      case 'in_service':
      case 'inservice':
        return TicketStatus.inService;
      case 'done':
        return TicketStatus.done;
      case 'no_show':
      case 'noshow':
        return TicketStatus.noShow;
      case 'cancelled':
        return TicketStatus.cancelled;
      case 'waiting':
      default:
        return TicketStatus.waiting;
    }
  }

  String toDbString() {
    switch (this) {
      case TicketStatus.waiting:
        return 'waiting';
      case TicketStatus.called:
        return 'called';
      case TicketStatus.inService:
        return 'in_service';
      case TicketStatus.done:
        return 'done';
      case TicketStatus.noShow:
        return 'no_show';
      case TicketStatus.cancelled:
        return 'cancelled';
    }
  }
}

class Ticket extends Equatable {
  final String id;
  final String clinicId;
  final String patientId;
  final String ticketNumber; // e.g. A042
  final TicketStatus status;
  final DateTime joinedAt;
  final DateTime? serviceStartedAt;
  final DateTime? serviceCompletedAt;
  final String reasonCode; // Minimal non-diagnostic appointment code (e.g. 'TRIAGE_GENERAL')
  final PaymentStatus paymentStatus;
  final String? mpesaCheckoutRequestId;

  const Ticket({
    required this.id,
    required this.clinicId,
    required this.patientId,
    required this.ticketNumber,
    required this.status,
    required this.joinedAt,
    this.serviceStartedAt,
    this.serviceCompletedAt,
    required this.reasonCode,
    this.paymentStatus = PaymentStatus.completed,
    this.mpesaCheckoutRequestId,
  });

  bool get isActive => status == TicketStatus.waiting || status == TicketStatus.called || status == TicketStatus.inService;
  bool get isWaiting => status == TicketStatus.waiting;
  bool get isCalled => status == TicketStatus.called;
  bool get isInService => status == TicketStatus.inService;

  Duration? get consultationDuration {
    if (serviceStartedAt != null && serviceCompletedAt != null) {
      return serviceCompletedAt!.difference(serviceStartedAt!);
    }
    return null;
  }

  @override
  List<Object?> get props => [
        id,
        clinicId,
        patientId,
        ticketNumber,
        status,
        joinedAt,
        serviceStartedAt,
        serviceCompletedAt,
        reasonCode,
        paymentStatus,
        mpesaCheckoutRequestId,
      ];
}
