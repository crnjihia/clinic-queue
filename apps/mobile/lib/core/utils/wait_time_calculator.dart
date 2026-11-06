// path: apps/mobile/lib/core/utils/wait_time_calculator.dart
class WaitTimeCalculator {
  WaitTimeCalculator._();

  static const int defaultServiceDurationMinutes = 10;

  /// Calculates the rolling average service time in minutes from a list of completed durations.
  /// If no history is provided, falls back to [defaultServiceDurationMinutes].
  static int calculateRollingAverageMinutes(List<Duration> completedDurations) {
    if (completedDurations.isEmpty) {
      return defaultServiceDurationMinutes;
    }

    final totalMinutes = completedDurations.fold<int>(
      0,
      (sum, duration) => sum + duration.inMinutes,
    );

    final average = (totalMinutes / completedDurations.length).round();
    // Clamp between a realistic 3 minutes and 45 minutes
    return average.clamp(3, 45);
  }

  /// Calculates estimated wait duration given position ahead (0 = you are next).
  static Duration estimateWaitDuration({
    required int peopleAhead,
    int averageServiceMinutes = defaultServiceDurationMinutes,
  }) {
    if (peopleAhead <= 0) {
      return Duration.zero;
    }
    return Duration(minutes: peopleAhead * averageServiceMinutes);
  }

  /// Formats wait duration into a readable localized human string.
  /// e.g. "15 mins", "1 hr 10 mins", "Under 5 mins"
  static String formatDuration(Duration duration) {
    if (duration == Duration.zero) {
      return 'You are next';
    }

    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0 && minutes > 0) {
      return '$hours hr $minutes mins';
    } else if (hours > 0) {
      return '$hours hr';
    } else if (minutes < 5) {
      return 'Under 5 mins';
    } else {
      return '$minutes mins';
    }
  }
}

