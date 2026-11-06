// path: apps/mobile/lib/presentation/screens/ticket_confirmation_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/route_names.dart';
import '../../core/theme/app_colors.dart';

class TicketConfirmationScreen extends StatelessWidget {
  final String ticketNumber;
  final String clinicName;

  const TicketConfirmationScreen({
    super.key,
    required this.ticketNumber,
    required this.clinicName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Confirmed'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFFE8F5E9),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, size: 54, color: AppColors.statusDone),
            ),
            const SizedBox(height: 24),
            Text(
              'Your Queue Ticket is Ready!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              clinicName,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer.withOpacity(0.4),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primaryTeal.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  const Text('TICKET NUMBER', style: TextStyle(letterSpacing: 1.5, fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                    ticketNumber,
                    style: const TextStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primaryTeal,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'You will receive an Africa\'s Talking SMS / WhatsApp alert when your turn is approaching.',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () => context.go(RouteNames.liveQueue),
              icon: const Icon(Icons.track_changes),
              label: const Text('Track Live Queue Status'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.go(RouteNames.clinics),
              child: const Text('Back to Clinic Directory'),
            ),
          ],
        ),
      ),
    );
  }
}

