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
  final String paymentStatus;
  final VoidCallback onCancel;

  const QueuePositionHero({
    super.key,
    required this.ticketNumber,
    required this.clinicName,
    required this.peopleAhead,
    required this.status,
    required this.averageServiceMinutes,
    this.paymentStatus = 'completed',
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
    final isPaid = paymentStatus.toLowerCase() == 'completed';

    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: statusColor.withOpacity(0.4), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        clinicName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            'Your Queue Ticket',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isPaid ? Colors.green.shade100 : Colors.amber.shade100,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              isPaid ? 'M-PESA PAID' : 'PAYMENT PENDING',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: isPaid ? Colors.green.shade900 : Colors.amber.shade900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              ticketNumber,
              style: TextStyle(
                fontSize: 44,
                fontWeight: FontWeight.w900,
                color: statusColor,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      '$peopleAhead',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'People Ahead',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                    ),
                  ],
                ),
                Container(height: 32, width: 1, color: Colors.grey.shade300),
                Column(
                  children: [
                    Text(
                      WaitTimeCalculator.formatDuration(waitDuration),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Estimated Wait',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (status == 'waiting')
              OutlinedButton.icon(
                onPressed: onCancel,
                icon: const Icon(Icons.cancel_outlined, size: 16),
                label: const Text('Cancel My Ticket', style: TextStyle(fontSize: 13)),
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
