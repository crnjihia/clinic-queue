// path: apps/mobile/lib/core/config/firebase_options_prod.dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

class ProdFirebaseOptions {
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
    apiKey: 'demo-api-key-web-prod',
    appId: '1:300000000000:web:prod000000000001',
    messagingSenderId: '300000000000',
    projectId: 'clinic-queue-prod',
    authDomain: 'clinic-queue-prod.firebaseapp.com',
    storageBucket: 'clinic-queue-prod.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'demo-api-key-android-prod',
    appId: '1:300000000000:android:prod0000000002',
    messagingSenderId: '300000000000',
    projectId: 'clinic-queue-prod',
    storageBucket: 'clinic-queue-prod.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'demo-api-key-ios-prod',
    appId: '1:300000000000:ios:prod000000000003',
    messagingSenderId: '300000000000',
    projectId: 'clinic-queue-prod',
    storageBucket: 'clinic-queue-prod.appspot.com',
    iosBundleId: 'com.clinicqueue.prod',
  );
}
