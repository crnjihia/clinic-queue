// path: apps/mobile/lib/presentation/screens/staff_dashboard_screen.dart
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class StaffDashboardScreen extends StatefulWidget {
  const StaffDashboardScreen({super.key});

  @override
  State<StaffDashboardScreen> createState() => _StaffDashboardScreenState();
}

class _StaffDashboardScreenState extends State<StaffDashboardScreen> {
  String? _currentlyCalled = 'A041';
  final List<Map<String, String>> _waitingQueue = [
    {'ticket': 'A042', 'reason': 'General Triage', 'time': '09:12 AM'},
    {'ticket': 'A043', 'reason': 'Child Immunisation', 'time': '09:18 AM'},
    {'ticket': 'A044', 'reason': 'Prescription Refill', 'time': '09:25 AM'},
  ];

  void _callNextPatient() {
    if (_waitingQueue.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No more patients waiting in queue.')),
      );
      return;
    }

    setState(() {
      final next = _waitingQueue.removeAt(0);
      _currentlyCalled = next['ticket'];
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Called patient #$_currentlyCalled to Consultation Room 2'),
        backgroundColor: AppColors.primaryTeal,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Triage Console'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
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
                      'CURRENTLY IN CONSULTATION',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.2),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _currentlyCalled ?? 'None',
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryTeal,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _callNextPatient,
                      icon: const Icon(Icons.campaign),
                      label: const Text('Call Next Patient'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Waiting Bay (${_waitingQueue.length})',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Room 2',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_waitingQueue.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32.0),
                child: Center(child: Text('No patients waiting.')),
              )
            else
              ..._waitingQueue.map((patient) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.secondaryContainer,
                      child: Text(
                        patient['ticket']!,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primaryTeal),
                      ),
                    ),
                    title: Text(patient['reason']!, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text('Joined at ${patient['time']}'),
                    trailing: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _waitingQueue.remove(patient);
                          _currentlyCalled = patient['ticket'];
                        });
                      },
                      child: const Text('Call'),
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

