// path: apps/mobile/lib/app.dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/config/app_flavor.dart';

class ClinicQueueApp extends StatelessWidget {
  const ClinicQueueApp({super.key});

  @override
  Widget build(BuildContext context) {
    final config = AppConfig.current;

    return MaterialApp(
      title: config.appTitle,
      debugShowCheckedModeBanner: config.isDev,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF006A60), // Kenyan teal healthcare primary
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF006A60),
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.system,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // English
        Locale('sw', ''), // Swahili
      ],
      home: Scaffold(
        appBar: AppBar(
          title: Text(config.appTitle),
          actions: [
            if (!config.isProd)
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Center(
                  child: Chip(
                    label: Text(
                      config.flavor.name.toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                    ),
                    backgroundColor: config.isDev ? Colors.orange.shade100 : Colors.blue.shade100,
                  ),
                ),
              ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.local_hospital_outlined, size: 64, color: Color(0xFF006A60)),
              const SizedBox(height: 16),
              Text(
                'Clinic Queue (Foleni wa Kliniki)',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'App ID: ${config.applicationId}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
