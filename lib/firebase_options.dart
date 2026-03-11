// File: lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDMg80q7p8crgqyWDovkziOUGsZvj8P3TE',
    appId: '1:734328470370:web:bd21f91aa1c086090f8a3b',
    messagingSenderId: '734328470370',
    projectId: 'ds-dev-test-c09e0',
    authDomain: 'ds-dev-test-c09e0.firebaseapp.com',
    storageBucket: 'ds-dev-test-c09e0.firebasestorage.app',
    measurementId: 'G-FKKCDD9XNJ',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDMg80q7p8crgqyWDovkziOUGsZvj8P3TE',
    appId: '1:734328470370:android:c2bf768781ae92b60f8a3b',
    messagingSenderId: '734328470370',
    projectId: 'ds-dev-test-c09e0',
    storageBucket: 'ds-dev-test-c09e0.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDMg80q7p8crgqyWDovkziOUGsZvj8P3TE',
    appId: '1:734328470370:ios:REPLACE_WITH_IOS_APP_ID',
    messagingSenderId: '734328470370',
    projectId: 'ds-dev-test-c09e0',
    storageBucket: 'ds-dev-test-c09e0.firebasestorage.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDMg80q7p8crgqyWDovkziOUGsZvj8P3TE',
    appId: '1:734328470370:ios:REPLACE_WITH_IOS_APP_ID',
    messagingSenderId: '734328470370',
    projectId: 'ds-dev-test-c09e0',
    storageBucket: 'ds-dev-test-c09e0.firebasestorage.app',
  );

  // Use Web config for Windows as it's the standard fallback if native windows app id isn't set up
  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDMg80q7p8crgqyWDovkziOUGsZvj8P3TE',
    appId: '1:734328470370:web:bd21f91aa1c086090f8a3b',
    messagingSenderId: '734328470370',
    projectId: 'ds-dev-test-c09e0',
    authDomain: 'ds-dev-test-c09e0.firebaseapp.com',
    storageBucket: 'ds-dev-test-c09e0.firebasestorage.app',
    measurementId: 'G-FKKCDD9XNJ',
  );
}
