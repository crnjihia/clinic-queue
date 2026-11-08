// path: apps/mobile/lib/presentation/screens/clinic_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/di/injection.dart';
import '../../core/router/route_names.dart';
import '../blocs/booking/booking_bloc.dart';
import '../blocs/booking/booking_event.dart';
import '../blocs/booking/booking_state.dart';
import '../widgets/clinic_card.dart';
import '../widgets/network_banner.dart';

class ClinicListScreen extends StatelessWidget {
  const ClinicListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BookingBloc>(
      create: (context) => getIt<BookingBloc>()..add(const BookingClinicsLoadRequested()),
      child: const _ClinicListView(),
    );
  }
}

class _ClinicListView extends StatefulWidget {
  const _ClinicListView();

  @override
  State<_ClinicListView> createState() => _ClinicListViewState();
}

class _ClinicListViewState extends State<_ClinicListView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedSubCounty = 'All';

  final List<String> _subCounties = ['All', 'Kibra', 'Westlands', 'Embakasi'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nairobi Health Facilities'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Clinics',
            onPressed: () {
              context.read<BookingBloc>().add(const BookingClinicsLoadRequested());
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'App Settings',
            onPressed: () => context.push(RouteNames.settings),
          ),
        ],
      ),
      body: Column(
        children: [
          const NetworkBanner(isOffline: false),
          // Search Input
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Search clinic or sub-county...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          // Sub-County Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: _subCounties.map((county) {
                final isSelected = _selectedSubCounty == county;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(county),
                    selected: isSelected,
                    onSelected: (val) => setState(() => _selectedSubCounty = county),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: BlocBuilder<BookingBloc, BookingState>(
              builder: (context, state) {
                if (state is BookingLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is BookingFailureState) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 48, color: Colors.red),
                          const SizedBox(height: 12),
                          Text(state.message, textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => context.read<BookingBloc>().add(const BookingClinicsLoadRequested()),
                            child: const Text('Try Again'),
                          ),
                        ],
                      ),
                    ),
                  );
                } else if (state is BookingClinicsLoaded) {
                  final filtered = state.clinics.where((c) {
                    final name = c.name.toLowerCase();
                    final sub = c.subCounty.toLowerCase();
                    final q = _searchQuery.toLowerCase();
                    final matchesQuery = name.contains(q) || sub.contains(q);
                    final matchesCounty = _selectedSubCounty == 'All' || sub.contains(_selectedSubCounty.toLowerCase());
                    return matchesQuery && matchesCounty;
                  }).toList();

                  if (filtered.isEmpty) {
                    return const Center(
                      child: Text('No clinics found matching your filter.'),
                    );
                  }

                  return ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final clinic = filtered[index];
                      return ClinicCard(
                        id: clinic.id,
                        name: clinic.name,
                        subCounty: clinic.subCounty,
                        openingHours: clinic.openingHours,
                        availableSlots: clinic.availableSlotsToday,
                        onTap: () {
                          context.push(
                            '${RouteNames.slotPickerPath(clinic.id)}?name=${Uri.encodeComponent(clinic.name)}',
                          );
                        },
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
