// path: apps/mobile/lib/presentation/screens/auth_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/di/injection.dart';
import '../../core/router/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/entities/user_profile.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';
import '../blocs/auth/auth_state.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>(
      create: (context) => getIt<AuthBloc>(),
      child: const _AuthView(),
    );
  }
}

class _AuthView extends StatefulWidget {
  const _AuthView();

  @override
  State<_AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends State<_AuthView> {
  final TextEditingController _phoneController = TextEditingController(text: '0712345678');
  UserRole _selectedRole = UserRole.patient;

  void _onSignInPressed() {
    context.read<AuthBloc>().add(
          AuthSignInRequested(
            rawPhoneNumber: _phoneController.text.trim(),
            role: _selectedRole,
          ),
        );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            if (state.user.isStaff) {
              context.go(RouteNames.staffDashboard);
            } else {
              context.go(RouteNames.clinics);
            }
          } else if (state is AuthFailureState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.statusNoShow,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return SafeArea(
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
                  SegmentedButton<UserRole>(
                    segments: const [
                      ButtonSegment(
                        value: UserRole.patient,
                        icon: Icon(Icons.person_outline),
                        label: Text('Patient'),
                      ),
                      ButtonSegment(
                        value: UserRole.staff,
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
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: isLoading ? null : _onSignInPressed,
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(_selectedRole == UserRole.staff ? 'Enter Staff Portal' : 'Find Clinics & Book'),
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
          );
        },
      ),
    );
  }
}
