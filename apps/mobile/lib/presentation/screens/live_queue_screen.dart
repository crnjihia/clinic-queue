// path: apps/mobile/lib/presentation/screens/live_queue_screen.dart
import 'package:flutter/material.dart';
import '../widgets/network_banner.dart';
import '../widgets/queue_position_hero.dart';

class LiveQueueScreen extends StatefulWidget {
  const LiveQueueScreen({super.key});

  @override
  State<LiveQueueScreen> createState() => _LiveQueueScreenState();
}

class _LiveQueueScreenState extends State<LiveQueueScreen> {
  // Demo live queue state (driven by QueueBloc in upcoming phase)
  int _peopleAhead = 2;
  String _status = 'waiting'; // 'waiting', 'called', 'in_service', 'done'
  final bool _isOffline = false;

  void _handleCancelTicket() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Queue Ticket?'),
        content: const Text('Are you sure you want to cancel your appointment? You will lose your current position in the queue.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Keep My Place'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _status = 'cancelled';
              });
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
                const SnackBar(content: Text('Push & SMS alerts are active for Ticket #A042')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          NetworkBanner(isOffline: _isOffline),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  QueuePositionHero(
                    ticketNumber: 'A042',
                    clinicName: 'Mbagathi Sub-County Hospital',
                    peopleAhead: _peopleAhead,
                    status: _status,
                    averageServiceMinutes: 8,
                    onCancel: _handleCancelTicket,
                  ),
                  if (_peopleAhead <= 2 && _status == 'waiting')
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
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
                              'You are next! Please ensure you are in the outpatient waiting bay.',
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
      ),
    );
  }
}

