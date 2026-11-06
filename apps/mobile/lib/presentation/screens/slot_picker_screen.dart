// path: apps/mobile/lib/presentation/screens/slot_picker_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/route_names.dart';
import '../../core/theme/app_colors.dart';

class SlotPickerScreen extends StatefulWidget {
  final String clinicId;
  final String clinicName;

  const SlotPickerScreen({
    super.key,
    required this.clinicId,
    required this.clinicName,
  });

  @override
  State<SlotPickerScreen> createState() => _SlotPickerScreenState();
}

class _SlotPickerScreenState extends State<SlotPickerScreen> {
  String? _selectedSlotId;
  final TextEditingController _reasonController = TextEditingController(text: 'General Triage Consultation');
  bool _isSubmitting = false;

  final List<Map<String, String>> _slots = const [
    {'id': 'slot_0900', 'time': '09:00 AM - 09:30 AM', 'status': 'available'},
    {'id': 'slot_0930', 'time': '09:30 AM - 10:00 AM', 'status': 'available'},
    {'id': 'slot_1000', 'time': '10:00 AM - 10:30 AM', 'status': 'full'},
    {'id': 'slot_1030', 'time': '10:30 AM - 11:00 AM', 'status': 'available'},
    {'id': 'slot_1100', 'time': '11:00 AM - 11:30 AM', 'status': 'available'},
  ];

  Future<void> _handleConfirmBooking() async {
    if (_selectedSlotId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an appointment time slot.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    // Navigate to ticket confirmation
    context.push(
      '${RouteNames.ticketConfirmation}?ticket=A042&clinic=${Uri.encodeComponent(widget.clinicName)}',
    );
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.clinicName),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Available Time Slot',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ..._slots.map((slot) {
              final isSelected = _selectedSlotId == slot['id'];
              final isFull = slot['status'] == 'full';

              return Card(
                color: isSelected ? AppColors.secondaryContainer : null,
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isSelected ? AppColors.primaryTeal : Colors.grey.shade300,
                  ),
                ),
                child: ListTile(
                  enabled: !isFull,
                  leading: Icon(
                    Icons.schedule,
                    color: isFull ? Colors.grey : AppColors.primaryTeal,
                  ),
                  title: Text(
                    slot['time']!,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isFull ? Colors.grey : null,
                    ),
                  ),
                  trailing: isFull
                      ? const Text('Full', style: TextStyle(color: Colors.red, fontSize: 12))
                      : Radio<String>(
                          value: slot['id']!,
                          groupValue: _selectedSlotId,
                          onChanged: (val) => setState(() => _selectedSlotId = val),
                        ),
                  onTap: isFull ? null : () => setState(() => _selectedSlotId = slot['id']),
                ),
              );
            }),
            const SizedBox(height: 20),
            const Text(
              'Consultation Reason (Minimal Non-Diagnostic)',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _reasonController,
              decoration: InputDecoration(
                hintText: 'e.g. Immunisation, Routine Triage, Dental Check',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _handleConfirmBooking,
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Confirm Appointment & Join Queue'),
            ),
          ],
        ),
      ),
    );
  }
}

