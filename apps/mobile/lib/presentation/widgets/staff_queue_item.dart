// path: apps/mobile/lib/presentation/widgets/staff_queue_item.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/entities/ticket.dart';

class StaffQueueItem extends StatelessWidget {
  final Ticket ticket;
  final VoidCallback onCall;
  final VoidCallback onStartService;
  final VoidCallback onComplete;
  final VoidCallback onNoShow;

  const StaffQueueItem({
    super.key,
    required this.ticket,
    required this.onCall,
    required this.onStartService,
    required this.onComplete,
    required this.onNoShow,
  });

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat('hh:mm a').format(ticket.joinedAt);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.secondaryContainer,
                      child: Text(
                        ticket.ticketNumber,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: AppColors.primaryTeal,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ticket.reasonCode,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        Text(
                          'Joined at $timeStr',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: ticket.isWaiting
                        ? Colors.orange.shade50
                        : ticket.isCalled
                            ? Colors.blue.shade50
                            : Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    ticket.status.name.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: ticket.isWaiting
                          ? Colors.orange.shade800
                          : ticket.isCalled
                              ? Colors.blue.shade800
                              : Colors.green.shade800,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (ticket.isWaiting) ...[
                  OutlinedButton(
                    onPressed: onNoShow,
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.red.shade700),
                    child: const Text('No Show'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: onCall,
                    icon: const Icon(Icons.campaign, size: 16),
                    label: const Text('Call'),
                  ),
                ] else if (ticket.isCalled) ...[
                  OutlinedButton(
                    onPressed: onNoShow,
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.red.shade700),
                    child: const Text('No Show'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: onStartService,
                    icon: const Icon(Icons.play_arrow, size: 16),
                    label: const Text('Start Service'),
                  ),
                ] else if (ticket.isInService) ...[
                  ElevatedButton.icon(
                    onPressed: onComplete,
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.statusDone),
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Mark Done'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
