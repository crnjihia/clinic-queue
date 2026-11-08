// path: apps/mobile/test/widget_test.dart
import 'package:clinic_queue/app.dart';
import 'package:clinic_queue/core/config/app_flavor.dart';
import 'package:clinic_queue/core/di/injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ClinicQueueApp renders MaterialApp.router', (WidgetTester tester) async {
    AppConfig.initialize(AppFlavor.dev);
    await configureDependencies('dev');
    await tester.pumpWidget(const ClinicQueueApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
