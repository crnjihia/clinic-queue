// path: apps/mobile/lib/main_staging.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'app.dart';
import 'core/config/app_flavor.dart';
import 'core/config/firebase_options_staging.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppConfig.initialize(AppFlavor.staging);

  await Firebase.initializeApp(
    options: StagingFirebaseOptions.currentPlatform,
  );

  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );

  runApp(const ClinicQueueApp());
}
