// path: apps/mobile/lib/app.dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/config/app_flavor.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);

class ClinicQueueApp extends StatelessWidget {
  const ClinicQueueApp({super.key});

  @override
  Widget build(BuildContext context) {
    final config = AppConfig.current;

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentThemeMode, child) {
        return MaterialApp.router(
          title: config.appTitle,
          debugShowCheckedModeBanner: config.isDev,
          routerConfig: AppRouter.router,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: currentThemeMode,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''),
            Locale('sw', ''),
          ],
        );
      },
    );
  }
}
