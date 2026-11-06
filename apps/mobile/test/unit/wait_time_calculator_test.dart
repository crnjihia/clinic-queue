// path: apps/mobile/test/unit/wait_time_calculator_test.dart
import 'package:clinic_queue/core/utils/wait_time_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WaitTimeCalculator', () {
    test('calculateRollingAverageMinutes returns default (10 mins) when no history', () {
      final avg = WaitTimeCalculator.calculateRollingAverageMinutes([]);
      expect(avg, equals(WaitTimeCalculator.defaultServiceDurationMinutes));
    });

    test('calculateRollingAverageMinutes computes accurate rounded average', () {
      final completed = [
        const Duration(minutes: 8),
        const Duration(minutes: 12),
        const Duration(minutes: 10),
      ];
      final avg = WaitTimeCalculator.calculateRollingAverageMinutes(completed);
      expect(avg, equals(10));
    });

    test('calculateRollingAverageMinutes clamps between 3 and 45 minutes', () {
      final shortTimes = [const Duration(minutes: 1), const Duration(minutes: 2)];
      expect(WaitTimeCalculator.calculateRollingAverageMinutes(shortTimes), equals(3));

      final longTimes = [const Duration(minutes: 60), const Duration(minutes: 50)];
      expect(WaitTimeCalculator.calculateRollingAverageMinutes(longTimes), equals(45));
    });

    test('estimateWaitDuration multiplies people ahead by average service time', () {
      final duration = WaitTimeCalculator.estimateWaitDuration(
        peopleAhead: 3,
        averageServiceMinutes: 10,
      );
      expect(duration, equals(const Duration(minutes: 30)));

      final zeroDuration = WaitTimeCalculator.estimateWaitDuration(
        peopleAhead: 0,
        averageServiceMinutes: 10,
      );
      expect(zeroDuration, equals(Duration.zero));
    });

    test('formatDuration formats human-readable strings accurately', () {
      expect(WaitTimeCalculator.formatDuration(Duration.zero), equals('You are next'));
      expect(WaitTimeCalculator.formatDuration(const Duration(minutes: 4)), equals('Under 5 mins'));
      expect(WaitTimeCalculator.formatDuration(const Duration(minutes: 15)), equals('15 mins'));
      expect(WaitTimeCalculator.formatDuration(const Duration(minutes: 60)), equals('1 hr'));
      expect(WaitTimeCalculator.formatDuration(const Duration(minutes: 75)), equals('1 hr 15 mins'));
    });
  });
}

