// path: apps/mobile/lib/presentation/screens/live_queue_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/di/injection.dart';
import '../blocs/queue/queue_bloc.dart';
import '../blocs/queue/queue_event.dart';
import '../blocs/queue/queue_state.dart';
import '../widgets/network_banner.dart';
import '../widgets/queue_position_hero.dart';

class LiveQueueScreen extends StatelessWidget {
  final String patientId;

  const LiveQueueScreen({
    super.key,
    this.patientId = 'patient-demo-uid',
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<QueueBloc>(
      create: (context) => getIt<QueueBloc>()..add(QueueSubscriptionRequested(patientId)),
      child: const _LiveQueueView(),
    );
  }
}

class _LiveQueueView extends StatelessWidget {
  const _LiveQueueView();

  void _showCancelDialog(BuildContext context, String clinicId, String ticketId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Queue Ticket?'),
        content: const Text(
          'Are you sure you want to cancel your appointment? You will lose your current position in the queue.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Keep My Place'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<QueueBloc>().add(
                    QueueTicketCancelRequested(clinicId: clinicId, ticketId: ticketId),
                  );
            },
            child: const Text('Confirm Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Queue Status'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Push & SMS alerts are active for your appointment.')),
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<QueueBloc, QueueState>(
        listener: (context, state) {
          if (state is QueueCancelledState) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Your appointment ticket was cancelled.')),
            );
          } else if (state is QueueFailureState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          if (state is QueueLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is QueueEmpty || state is QueueCancelledState) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.confirmation_number_outlined, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      'No Active Queue Ticket',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'You do not have an active outpatient appointment. Select a clinic from the directory to book a slot.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is QueueLoaded) {
            final isNext = state.peopleAhead <= 2 && state.ticket.isWaiting;

            return Column(
              children: [
                NetworkBanner(
                  isOffline: state.isOffline,
                  message: 'Offline mode active. Showing last known queue updates from local cache.',
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        QueuePositionHero(
                          ticketNumber: state.ticket.ticketNumber,
                          clinicName: state.ticket.clinicId,
                          peopleAhead: state.peopleAhead,
                          status: state.ticket.status.name,
                          averageServiceMinutes: state.averageServiceMinutes,
                          onCancel: () => _showCancelDialog(
                            context,
                            state.ticket.clinicId,
                            state.ticket.id,
                          ),
                        ),
                        if (isNext)
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.blue.shade200),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.info_outline, color: Colors.blue),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'You are next! Please make your way to the consultation waiting bay.',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue.shade900,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
