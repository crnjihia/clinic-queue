// path: apps/mobile/lib/presentation/blocs/queue/queue_state.dart
import 'package:equatable/equatable.dart';
import '../../../domain/entities/ticket.dart';

abstract class QueueState extends Equatable {
  const QueueState();

  @override
  List<Object?> get props => [];
}

class QueueInitial extends QueueState {
  const QueueInitial();
}

class QueueLoading extends QueueState {
  const QueueLoading();
}

class QueueEmpty extends QueueState {
  const QueueEmpty();
}

class QueueLoaded extends QueueState {
  final Ticket ticket;
  final int peopleAhead;
  final Duration estimatedWait;
  final int averageServiceMinutes;
  final bool isOffline;

  const QueueLoaded({
    required this.ticket,
    required this.peopleAhead,
    required this.estimatedWait,
    required this.averageServiceMinutes,
    this.isOffline = false,
  });

  QueueLoaded copyWith({
    Ticket? ticket,
    int? peopleAhead,
    Duration? estimatedWait,
    int? averageServiceMinutes,
    bool? isOffline,
  }) {
    return QueueLoaded(
      ticket: ticket ?? this.ticket,
      peopleAhead: peopleAhead ?? this.peopleAhead,
      estimatedWait: estimatedWait ?? this.estimatedWait,
      averageServiceMinutes: averageServiceMinutes ?? this.averageServiceMinutes,
      isOffline: isOffline ?? this.isOffline,
    );
  }

  @override
  List<Object?> get props => [
        ticket,
        peopleAhead,
        estimatedWait,
        averageServiceMinutes,
        isOffline,
      ];
}

class QueueCancelledState extends QueueState {
  const QueueCancelledState();
}

class QueueFailureState extends QueueState {
  final String message;

  const QueueFailureState(this.message);

  @override
  List<Object?> get props => [message];
}

