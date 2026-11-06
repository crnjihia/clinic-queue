// path: apps/mobile/lib/presentation/screens/staff_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/di/injection.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/entities/ticket.dart';
import '../blocs/staff/staff_bloc.dart';
import '../blocs/staff/staff_event.dart';
import '../blocs/staff/staff_state.dart';
import '../widgets/staff_queue_item.dart';

class StaffDashboardScreen extends StatelessWidget {
  final String clinicId;

  const StaffDashboardScreen({
    super.key,
    this.clinicId = 'c_mbagathi',
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<StaffBloc>(
      create: (context) => getIt<StaffBloc>()..add(StaffQueueSubscriptionRequested(clinicId)),
      child: _StaffDashboardView(clinicId: clinicId),
    );
  }
}

class _StaffDashboardView extends StatelessWidget {
  final String clinicId;

  const _StaffDashboardView({required this.clinicId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Triage Console'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<StaffBloc>().add(StaffQueueSubscriptionRequested(clinicId));
            },
          ),
        ],
      ),
      body: BlocConsumer<StaffBloc, StaffState>(
        listener: (context, state) {
          if (state is StaffQueueLoaded && state.feedbackMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.feedbackMessage!),
                backgroundColor: AppColors.primaryTeal,
              ),
            );
          } else if (state is StaffFailureState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          if (state is StaffLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is StaffQueueLoaded) {
            final calledTicket = state.calledTicket;
            final inServiceTicket = state.inServiceTicket;
            final waitingTickets = state.waitingTickets;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Active consultation card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Card(
                      color: AppColors.primaryContainer.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: AppColors.primaryTeal),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            const Text(
                              'CURRENTLY IN CONSULTATION / CALLED',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              inServiceTicket != null
                                  ? inServiceTicket.ticketNumber
                                  : calledTicket != null
                                      ? calledTicket.ticketNumber
                                      : 'No Patient',
                              style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primaryTeal,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              inServiceTicket != null
                                  ? 'In Service (${inServiceTicket.reasonCode})'
                                  : calledTicket != null
                                      ? 'Called (${calledTicket.reasonCode})'
                                      : 'Waiting for staff to advance',
                              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () {
                                context.read<StaffBloc>().add(StaffCallNextRequested(clinicId));
                              },
                              icon: const Icon(Icons.campaign),
                              label: const Text('Call Next Patient in Queue'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Waiting Bay (${waitingTickets.length})',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Room 2',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (waitingTickets.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40.0),
                      child: Center(
                        child: Text('No patients currently waiting in queue.'),
                      ),
                    )
                  else
                    ...waitingTickets.map((ticket) {
                      return StaffQueueItem(
                        ticket: ticket,
                        onCall: () {
                          context.read<StaffBloc>().add(
                                StaffUpdateStatusRequested(
                                  clinicId: clinicId,
                                  ticketId: ticket.id,
                                  newStatus: TicketStatus.called,
                                ),
                              );
                        },
                        onStartService: () {
                          context.read<StaffBloc>().add(
                                StaffUpdateStatusRequested(
                                  clinicId: clinicId,
                                  ticketId: ticket.id,
                                  newStatus: TicketStatus.inService,
                                ),
                              );
                        },
                        onComplete: () {
                          context.read<StaffBloc>().add(
                                StaffUpdateStatusRequested(
                                  clinicId: clinicId,
                                  ticketId: ticket.id,
                                  newStatus: TicketStatus.done,
                                ),
                              );
                        },
                        onNoShow: () {
                          context.read<StaffBloc>().add(
                                StaffUpdateStatusRequested(
                                  clinicId: clinicId,
                                  ticketId: ticket.id,
                                  newStatus: TicketStatus.noShow,
                                ),
                              );
                        },
                      );
                    }),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
