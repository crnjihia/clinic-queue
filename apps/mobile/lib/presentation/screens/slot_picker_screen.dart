// path: apps/mobile/lib/presentation/screens/slot_picker_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/di/injection.dart';
import '../../core/router/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../blocs/booking/booking_bloc.dart';
import '../blocs/booking/booking_event.dart';
import '../blocs/booking/booking_state.dart';

class SlotPickerScreen extends StatelessWidget {
  final String clinicId;
  final String clinicName;

  const SlotPickerScreen({
    super.key,
    required this.clinicId,
    required this.clinicName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BookingBloc>(
      create: (context) => getIt<BookingBloc>()..add(BookingSlotsLoadRequested(clinicId)),
      child: _SlotPickerView(clinicId: clinicId, clinicName: clinicName),
    );
  }
}

class _SlotPickerView extends StatefulWidget {
  final String clinicId;
  final String clinicName;

  const _SlotPickerView({
    required this.clinicId,
    required this.clinicName,
  });

  @override
  State<_SlotPickerView> createState() => _SlotPickerViewState();
}

class _SlotPickerViewState extends State<_SlotPickerView> {
  String? _selectedSlotId;
  final TextEditingController _reasonController = TextEditingController(text: 'General Triage Consultation');

  void _onConfirmBooking(BuildContext context) {
    if (_selectedSlotId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an appointment time slot.')),
      );
      return;
    }

    context.read<BookingBloc>().add(
          BookingSubmitted(
            clinicId: widget.clinicId,
            slotId: _selectedSlotId!,
            patientId: 'patient-demo-uid',
            reasonCode: _reasonController.text.trim(),
          ),
        );
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('hh:mm a');

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.clinicName),
      ),
      body: BlocConsumer<BookingBloc, BookingState>(
        listener: (context, state) {
          if (state is BookingSuccess) {
            context.push(
              '${RouteNames.ticketConfirmation}?ticket=${state.ticket.ticketNumber}&clinic=${Uri.encodeComponent(widget.clinicName)}',
            );
          } else if (state is BookingFailureState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.statusNoShow,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is BookingLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is BookingSlotsLoaded) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select Available Time Slot',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  if (state.slots.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32.0),
                      child: Center(child: Text('No slots scheduled for today.')),
                    )
                  else
                    ...state.slots.map((slot) {
                      final isSelected = _selectedSlotId == slot.id;
                      final isFull = !slot.isAvailable;
                      final timeRange = '${timeFormat.format(slot.startTime)} - ${timeFormat.format(slot.endTime)}';

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
                            timeRange,
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isFull ? Colors.grey : null,
                            ),
                          ),
                          trailing: isFull
                              ? const Text('Full', style: TextStyle(color: Colors.red, fontSize: 12))
                              : Radio<String>(
                                  value: slot.id,
                                  groupValue: _selectedSlotId,
                                  onChanged: (val) => setState(() => _selectedSlotId = val),
                                ),
                          onTap: isFull ? null : () => setState(() => _selectedSlotId = slot.id),
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
                    onPressed: () => _onConfirmBooking(context),
                    child: const Text('Confirm Appointment & Join Queue'),
                  ),
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
