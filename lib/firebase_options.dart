// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyDLIAzItYUnv2fcR0VGGYZ5Z5ZFUSf2mf0',
    appId: '1:1081417993388:web:bdccd2bb36b8c6dcabe309',
    messagingSenderId: '1081417993388',
    projectId: 'studai-d4e72',
    authDomain: 'studai-d4e72.firebaseapp.com',
    storageBucket: 'studai-d4e72.appspot.com',
    measurementId: 'G-7J5DY9LRMS',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAYX4E2zHqEBFMFKNJ58-WLZPp5qylDV-8',
    appId: '1:1081417993388:android:e548aa3fa2ab8912abe309',
    messagingSenderId: '1081417993388',
    projectId: 'studai-d4e72',
    storageBucket: 'studai-d4e72.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBhmwBSjwhjRQdA1bEPmsMjiF51DgI5nhA',
    appId: '1:1081417993388:ios:276e4d87270baae0abe309',
    messagingSenderId: '1081417993388',
    projectId: 'studai-d4e72',
    storageBucket: 'studai-d4e72.appspot.com',
    iosClientId: '1081417993388-6qe9prskg26h2r58shkhec2qtbhcn8ql.apps.googleusercontent.com',
    iosBundleId: 'com.example.logintest',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBhmwBSjwhjRQdA1bEPmsMjiF51DgI5nhA',
    appId: '1:1081417993388:ios:3bccc1f50d02e527abe309',
    messagingSenderId: '1081417993388',
    projectId: 'studai-d4e72',
    storageBucket: 'studai-d4e72.appspot.com',
    iosClientId: '1081417993388-9sl4fffdbpvjs4d3gtah5q4e9g2shse0.apps.googleusercontent.com',
    iosBundleId: 'com.example.logintest.RunnerTests',
  );
}