
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;


class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyAAIabppA866YJOLsfXT5NtIn01dCstPMs',
    appId: '1:92964835784:web:9388230c7a30a9a208f0fd',
    messagingSenderId: '92964835784',
    projectId: 'fernandovidal-be766',
    authDomain: 'fernandovidal-be766.firebaseapp.com',
    storageBucket: 'fernandovidal-be766.firebasestorage.app',
    measurementId: 'G-L1LDSMKS7F',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAL8ACILSjncjaYk3l9aJZtQPfu89lir6E',
    appId: '1:92964835784:android:3cfc5eccb4a1f29308f0fd',
    messagingSenderId: '92964835784',
    projectId: 'fernandovidal-be766',
    storageBucket: 'fernandovidal-be766.firebasestorage.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAAIabppA866YJOLsfXT5NtIn01dCstPMs',
    appId: '1:92964835784:web:4f7a270699c94f7708f0fd',
    messagingSenderId: '92964835784',
    projectId: 'fernandovidal-be766',
    authDomain: 'fernandovidal-be766.firebaseapp.com',
    storageBucket: 'fernandovidal-be766.firebasestorage.app',
    measurementId: 'G-865T247K71',
  );
}
