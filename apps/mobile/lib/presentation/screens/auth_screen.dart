// path: apps/mobile/lib/presentation/screens/auth_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';
import '../../core/router/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/phone_number_formatter.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _phoneController = TextEditingController(text: '0712345678');
  String _selectedRole = 'patient';
  String? _errorMessage;

  void _handleSignIn() {
    final rawPhone = _phoneController.text.trim();
    final formatted = PhoneNumberFormatter.toE164(rawPhone);

    if (formatted == null) {
      setState(() {
        _errorMessage = 'Please enter a valid Kenyan mobile number (e.g. 0712 345 678)';
      });
      return;
    }

    setState(() {
      _errorMessage = null;
    });

    // Update global router state
    AppRouter.currentUserRole = _selectedRole;
    AppRouter.authStateListenable.value = true;

    if (_selectedRole == 'staff') {
      context.go(RouteNames.staffDashboard);
    } else {
      context.go(RouteNames.clinics);
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.local_hospital_rounded, size: 36, color: AppColors.primaryTeal),
              ),
              const SizedBox(height: 24),
              Text(
                'Clinic Queue\nFoleni wa Kliniki',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryTeal,
                      height: 1.2,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Outpatient appointments & live queue management for Nairobi health facilities.',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
              const SizedBox(height: 36),
              const Text(
                'Select Your Role',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'patient',
                    icon: Icon(Icons.person_outline),
                    label: Text('Patient'),
                  ),
                  ButtonSegment(
                    value: 'staff',
                    icon: Icon(Icons.medical_services_outlined),
                    label: Text('Clinic Staff'),
                  ),
                ],
                selected: {_selectedRole},
                onSelectionChanged: (newSelection) {
                  setState(() {
                    _selectedRole = newSelection.first;
                  });
                },
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Kenyan Mobile Number',
                  hintText: '0712 345 678 or +2547...',
                  prefixIcon: const Icon(Icons.phone_android),
                  errorText: _errorMessage,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _handleSignIn,
                child: Text(_selectedRole == 'staff' ? 'Enter Staff Portal' : 'Find Clinics & Book'),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'Firebase Auth Emulator Enabled (No SMS charges)',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

