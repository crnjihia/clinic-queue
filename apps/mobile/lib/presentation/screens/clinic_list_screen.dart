// path: apps/mobile/lib/presentation/screens/clinic_list_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/route_names.dart';
import '../widgets/clinic_card.dart';
import '../widgets/network_banner.dart';

class ClinicListScreen extends StatefulWidget {
  const ClinicListScreen({super.key});

  @override
  State<ClinicListScreen> createState() => _ClinicListScreenState();
}

class _ClinicListScreenState extends State<ClinicListScreen> {
  final TextEditingController _searchController = TextEditingController();

  static const List<Map<String, dynamic>> _allClinics = [
    {
      'id': 'c_mbagathi',
      'name': 'Mbagathi Sub-County Hospital Outpatient',
      'subCounty': 'Kibra / Langata, Nairobi',
      'openingHours': '08:00 - 17:00',
      'availableSlots': 12,
    },
    {
      'id': 'c_westlands',
      'name': 'Westlands Health Centre',
      'subCounty': 'Westlands, Nairobi',
      'openingHours': '08:30 - 16:30',
      'availableSlots': 6,
    },
    {
      'id': 'c_mama_lucy',
      'name': 'Mama Lucy Kibaki Hospital Outpatient',
      'subCounty': 'Embakasi Central, Nairobi',
      'openingHours': '24 Hours Triage',
      'availableSlots': 18,
    },
    {
      'id': 'c_eastleigh',
      'name': 'Eastleigh Community Health Hub',
      'subCounty': 'Kamukunji, Nairobi',
      'openingHours': '09:00 - 16:00',
      'availableSlots': 0, // Fully booked test
    },
  ];

  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _allClinics.where((c) {
      final name = c['name'].toString().toLowerCase();
      final sub = c['subCounty'].toString().toLowerCase();
      final q = _searchQuery.toLowerCase();
      return name.contains(q) || sub.contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nairobi Health Facilities'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {});
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const NetworkBanner(isOffline: false),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          Expanded(
            child: filtered.isEmpty
                ? const Center(
                    child: Text('No clinics found matching your search.'),
                  )
                : ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final clinic = filtered[index];
                      return ClinicCard(
                        id: clinic['id'] as String,
                        name: clinic['name'] as String,
                        subCounty: clinic['subCounty'] as String,
                        openingHours: clinic['openingHours'] as String,
                        availableSlots: clinic['availableSlots'] as int,
                        onTap: () {
                          context.push(
                            '${RouteNames.slotPickerPath(clinic['id'] as String)}?name=${Uri.encodeComponent(clinic['name'] as String)}',
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

