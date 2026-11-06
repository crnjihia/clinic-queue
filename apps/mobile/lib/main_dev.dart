// path: apps/mobile/lib/main_dev.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'app.dart';
import 'core/config/app_flavor.dart';
import 'core/config/firebase_options_dev.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppConfig.initialize(AppFlavor.dev);

  await Firebase.initializeApp(
    options: DevFirebaseOptions.currentPlatform,
  );

  // Hook into local Firebase Emulators when running in DEV flavor
  const emulatorHost = '127.0.0.1';
  try {
    await FirebaseAuth.instance.useAuthEmulator(emulatorHost, 9099);
    FirebaseFirestore.instance.useFirestoreEmulator(emulatorHost, 8080);
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  } catch (e) {
    debugPrint('Firebase emulator already configured or failed to connect: $e');
  }

  runApp(const ClinicQueueApp());
}
