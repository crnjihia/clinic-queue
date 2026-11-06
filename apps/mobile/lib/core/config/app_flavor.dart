// path: apps/mobile/lib/core/config/app_flavor.dart
enum AppFlavor {
  dev,
  staging,
  prod,
}

class AppConfig {
  final AppFlavor flavor;
  final String appTitle;
  final String applicationId;
  final bool useEmulator;
  final String emulatorHost;

  const AppConfig({
    required this.flavor,
    required this.appTitle,
    required this.applicationId,
    required this.useEmulator,
    required this.emulatorHost,
  });

  static late final AppConfig current;

  static void initialize(AppFlavor flavor) {
    switch (flavor) {
      case AppFlavor.dev:
        current = const AppConfig(
          flavor: AppFlavor.dev,
          appTitle: 'Clinic Queue (Dev)',
          applicationId: 'com.clinicqueue.dev',
          useEmulator: true,
          emulatorHost: '127.0.0.1',
        );
        break;
      case AppFlavor.staging:
        current = const AppConfig(
          flavor: AppFlavor.staging,
          appTitle: 'Clinic Queue (Staging)',
          applicationId: 'com.clinicqueue.staging',
          useEmulator: false,
          emulatorHost: '',
        );
        break;
      case AppFlavor.prod:
        current = const AppConfig(
          flavor: AppFlavor.prod,
          appTitle: 'Clinic Queue',
          applicationId: 'com.clinicqueue.prod',
          useEmulator: false,
          emulatorHost: '',
        );
        break;
    }
  }

  bool get isDev => flavor == AppFlavor.dev;
  bool get isStaging => flavor == AppFlavor.staging;
  bool get isProd => flavor == AppFlavor.prod;
}
