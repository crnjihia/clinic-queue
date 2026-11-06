// path: apps/mobile/lib/core/config/firebase_options_dev.dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

class DevFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'demo-api-key-web-dev',
    appId: '1:100000000000:web:dev000000000001',
    messagingSenderId: '100000000000',
    projectId: 'clinic-queue-dev',
    authDomain: 'clinic-queue-dev.firebaseapp.com',
    storageBucket: 'clinic-queue-dev.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'demo-api-key-android-dev',
    appId: '1:100000000000:android:dev00000000002',
    messagingSenderId: '100000000000',
    projectId: 'clinic-queue-dev',
    storageBucket: 'clinic-queue-dev.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'demo-api-key-ios-dev',
    appId: '1:100000000000:ios:dev000000000003',
    messagingSenderId: '100000000000',
    projectId: 'clinic-queue-dev',
    storageBucket: 'clinic-queue-dev.appspot.com',
    iosBundleId: 'com.clinicqueue.dev',
  );
}
