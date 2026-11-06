// path: apps/mobile/lib/presentation/widgets/queue_position_hero.dart
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/wait_time_calculator.dart';

class QueuePositionHero extends StatelessWidget {
  final String ticketNumber;
  final String clinicName;
  final int peopleAhead;
  final String status;
  final int averageServiceMinutes;
  final VoidCallback onCancel;

  const QueuePositionHero({
    super.key,
    required this.ticketNumber,
    required this.clinicName,
    required this.peopleAhead,
    required this.status,
    required this.averageServiceMinutes,
    required this.onCancel,
  });

  Color _getStatusColor() {
    switch (status.toLowerCase()) {
      case 'called':
        return AppColors.statusCalled;
      case 'in_service':
        return AppColors.statusInService;
      case 'done':
        return AppColors.statusDone;
      case 'waiting':
        return AppColors.statusWaiting;
      default:
        return AppColors.statusCancelled;
    }
  }

  @override
  Widget build(BuildContext context) {
    final waitDuration = WaitTimeCalculator.estimateWaitDuration(
      peopleAhead: peopleAhead,
      averageServiceMinutes: averageServiceMinutes,
    );
    final statusColor = _getStatusColor();

    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: statusColor.withOpacity(0.4), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      clinicName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Your Queue Ticket',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              ticketNumber,
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w900,
                color: statusColor,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      '$peopleAhead',
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'People Ahead',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
                Container(height: 36, width: 1, color: Colors.grey.shade300),
                Column(
                  children: [
                    Text(
                      WaitTimeCalculator.formatDuration(waitDuration),
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Estimated Wait',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (status == 'waiting')
              OutlinedButton.icon(
                onPressed: onCancel,
                icon: const Icon(Icons.cancel_outlined, size: 18),
                label: const Text('Cancel My Ticket'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red.shade700,
                  side: BorderSide(color: Colors.red.shade200),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

