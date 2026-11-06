// path: apps/mobile/lib/core/config/firebase_options_staging.dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

class StagingFirebaseOptions {
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
    apiKey: 'demo-api-key-web-staging',
    appId: '1:200000000000:web:staging000000001',
    messagingSenderId: '200000000000',
    projectId: 'clinic-queue-staging',
    authDomain: 'clinic-queue-staging.firebaseapp.com',
    storageBucket: 'clinic-queue-staging.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'demo-api-key-android-staging',
    appId: '1:200000000000:android:staging00000002',
    messagingSenderId: '200000000000',
    projectId: 'clinic-queue-staging',
    storageBucket: 'clinic-queue-staging.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'demo-api-key-ios-staging',
    appId: '1:200000000000:ios:staging000000003',
    messagingSenderId: '200000000000',
    projectId: 'clinic-queue-staging',
    storageBucket: 'clinic-queue-staging.appspot.com',
    iosBundleId: 'com.clinicqueue.staging',
  );
}
