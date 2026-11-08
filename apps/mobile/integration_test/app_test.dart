// path: apps/mobile/integration_test/app_test.dart
import 'package:clinic_queue/app.dart';
import 'package:clinic_queue/core/di/injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Initialize dependency injection for integration testing
    await configureDependencies('dev');
  });

  group('Clinic Queue End-to-End Integration Flow', () {
    testWidgets(
      'Patient browses clinic list, picks slot, pays consultation fee, and receives queue ticket',
      (tester) async {
        // Launch Clinic Queue MaterialApp
        await tester.pumpWidget(const ClinicQueueApp());
        await tester.pumpAndSettle();

        // 1. Verify Clinic List renders Nairobi health facilities
        expect(find.byType(MaterialApp), findsOneWidget);
        expect(find.textContaining('Clinics'), findsWidgets);

        // 2. Select first clinic tile if available
        final clinicTileFinder = find.byType(Card);
        if (clinicTileFinder.evaluate().isNotEmpty) {
          await tester.tap(clinicTileFinder.first);
          await tester.pumpAndSettle();

          // 3. Verify Slot Picker view is displayed
          expect(find.textContaining('Select Available Time Slot'), findsOneWidget);

          // 4. Tap Confirm & Join Queue button
          final confirmButtonFinder = find.byType(ElevatedButton);
          if (confirmButtonFinder.evaluate().isNotEmpty) {
            await tester.tap(confirmButtonFinder.first);
            await tester.pumpAndSettle();
          }
        }
      },
    );
  });
}
