// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
    apiKey: 'AIzaSyDsY-d0Do__Tg_SuOUbBOS_JfMGQWl4WF8',
    appId: '1:364549358696:web:724812d57c5a86e22ee7dd',
    messagingSenderId: '364549358696',
    projectId: 'smart-virtual-refrigerator',
    authDomain: 'smart-virtual-refrigerator.firebaseapp.com',
    storageBucket: 'smart-virtual-refrigerator.firebasestorage.app',
    measurementId: 'G-J5J6R9GBT6',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB0L6tZgm_t22ub16W5RlJr1vd4K1O6qFk',
    appId: '1:364549358696:android:d8c94ea737b611412ee7dd',
    messagingSenderId: '364549358696',
    projectId: 'smart-virtual-refrigerator',
    storageBucket: 'smart-virtual-refrigerator.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBjy-IFyDyb5zm2vnlOo2wKflVD7z1UIlY',
    appId: '1:364549358696:ios:f4417f41f67db0722ee7dd',
    messagingSenderId: '364549358696',
    projectId: 'smart-virtual-refrigerator',
    storageBucket: 'smart-virtual-refrigerator.firebasestorage.app',
    iosBundleId: 'com.example.smartVirtualRefrigerator',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBjy-IFyDyb5zm2vnlOo2wKflVD7z1UIlY',
    appId: '1:364549358696:ios:f4417f41f67db0722ee7dd',
    messagingSenderId: '364549358696',
    projectId: 'smart-virtual-refrigerator',
    storageBucket: 'smart-virtual-refrigerator.firebasestorage.app',
    iosBundleId: 'com.example.smartVirtualRefrigerator',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDsY-d0Do__Tg_SuOUbBOS_JfMGQWl4WF8',
    appId: '1:364549358696:web:9df525eca50790f12ee7dd',
    messagingSenderId: '364549358696',
    projectId: 'smart-virtual-refrigerator',
    authDomain: 'smart-virtual-refrigerator.firebaseapp.com',
    storageBucket: 'smart-virtual-refrigerator.firebasestorage.app',
    measurementId: 'G-QBZJB7GFLL',
  );

}