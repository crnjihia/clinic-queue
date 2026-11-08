// path: apps/mobile/lib/core/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/screens/auth_screen.dart';
import '../../presentation/screens/clinic_list_screen.dart';
import '../../presentation/screens/live_queue_screen.dart';
import '../../presentation/screens/settings_screen.dart';
import '../../presentation/screens/slot_picker_screen.dart';
import '../../presentation/screens/staff_dashboard_screen.dart';
import '../../presentation/screens/ticket_confirmation_screen.dart';
import 'route_names.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'rootNav');
final GlobalKey<NavigatorState> shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shellNav');

class AppRouter {
  static final ValueNotifier<bool> authStateListenable = ValueNotifier<bool>(true);
  static String currentUserRole = 'patient'; // 'patient' or 'staff'

  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: RouteNames.clinics,
    refreshListenable: authStateListenable,
    redirect: (context, state) {
      final isAuthenticated = authStateListenable.value;
      final isAuthRoute = state.matchedLocation == RouteNames.auth;

      if (!isAuthenticated && !isAuthRoute) {
        return RouteNames.auth;
      }

      if (isAuthenticated && isAuthRoute) {
        return currentUserRole == 'staff' ? RouteNames.staffDashboard : RouteNames.clinics;
      }

      if (state.matchedLocation.startsWith(RouteNames.staffDashboard) && currentUserRole != 'staff') {
        return RouteNames.clinics; // Guard: patients cannot enter staff portal
      }

      return null;
    },
    routes: [
      GoRoute(
        path: RouteNames.auth,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const AuthScreen(),
      ),
      ShellRoute(
        navigatorKey: shellNavigatorKey,
        builder: (context, state, child) {
          return _ScaffoldWithNavBar(child: child);
        },
        routes: [
          GoRoute(
            path: RouteNames.clinics,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ClinicListScreen(),
            ),
          ),
          GoRoute(
            path: RouteNames.liveQueue,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: LiveQueueScreen(),
            ),
          ),
          GoRoute(
            path: RouteNames.staffDashboard,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: StaffDashboardScreen(),
            ),
          ),
          GoRoute(
            path: RouteNames.settings,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SettingsScreen(),
            ),
          ),
        ],
      ),
      GoRoute(
        path: RouteNames.slotPicker,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final clinicId = state.pathParameters['clinicId'] ?? '';
          final clinicName = state.uri.queryParameters['name'] ?? 'Nairobi Clinic';
          return SlotPickerScreen(clinicId: clinicId, clinicName: clinicName);
        },
      ),
      GoRoute(
        path: RouteNames.ticketConfirmation,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final ticketNumber = state.uri.queryParameters['ticket'] ?? 'A001';
          final clinicName = state.uri.queryParameters['clinic'] ?? 'Clinic';
          return TicketConfirmationScreen(
            ticketNumber: ticketNumber,
            clinicName: clinicName,
          );
        },
      ),
    ],
  );
}

class _ScaffoldWithNavBar extends StatelessWidget {
  final Widget child;

  const _ScaffoldWithNavBar({required this.child});

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith(RouteNames.clinics)) return 0;
    if (location.startsWith(RouteNames.liveQueue)) return 1;
    if (location.startsWith(RouteNames.staffDashboard)) return 2;
    if (location.startsWith(RouteNames.settings)) return isStaff ? 3 : 2;
    return 0;
  }

  bool get isStaff => AppRouter.currentUserRole == 'staff';

  void _onItemTapped(int index, BuildContext context) {
    if (isStaff) {
      switch (index) {
        case 0:
          context.go(RouteNames.clinics);
          break;
        case 1:
          context.go(RouteNames.liveQueue);
          break;
        case 2:
          context.go(RouteNames.staffDashboard);
          break;
        case 3:
          context.go(RouteNames.settings);
          break;
      }
    } else {
      switch (index) {
        case 0:
          context.go(RouteNames.clinics);
          break;
        case 1:
          context.go(RouteNames.liveQueue);
          break;
        case 2:
          context.go(RouteNames.settings);
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _calculateSelectedIndex(context),
        onDestinationSelected: (index) => _onItemTapped(index, context),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.local_hospital_outlined),
            selectedIcon: Icon(Icons.local_hospital),
            label: 'Clinics',
          ),
          const NavigationDestination(
            icon: Icon(Icons.confirmation_number_outlined),
            selectedIcon: Icon(Icons.confirmation_number),
            label: 'My Ticket',
          ),
          if (isStaff)
            const NavigationDestination(
              icon: Icon(Icons.medical_services_outlined),
              selectedIcon: Icon(Icons.medical_services),
              label: 'Staff Portal',
            ),
          const NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
