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
    apiKey: 'AIzaSyDCxMT_ouWkmcSNw015ANi-MwvsDryHqlE',
    appId: '1:564436165702:web:e5835d1939d8122cab9647',
    messagingSenderId: '564436165702',
    projectId: 'allmahgame',
    authDomain: 'allmahgame.firebaseapp.com',
    storageBucket: 'allmahgame.firebasestorage.app',
    measurementId: 'G-STJQ93CRJL',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDCxMT_ouWkmcSNw015ANi-MwvsDryHqlE',
    appId: '1:564436165702:android:YOUR_ANDROID_APP_ID',
    messagingSenderId: '564436165702',
    projectId: 'allmahgame',
    storageBucket: 'allmahgame.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDCxMT_ouWkmcSNw015ANi-MwvsDryHqlE',
    appId: '1:564436165702:ios:YOUR_IOS_APP_ID',
    messagingSenderId: '564436165702',
    projectId: 'allmahgame',
    storageBucket: 'allmahgame.firebasestorage.app',
    iosBundleId: 'com.example.triviaGame',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDCxMT_ouWkmcSNw015ANi-MwvsDryHqlE',
    appId: '1:564436165702:ios:YOUR_IOS_APP_ID',
    messagingSenderId: '564436165702',
    projectId: 'allmahgame',
    storageBucket: 'allmahgame.firebasestorage.app',
    iosBundleId: 'com.example.triviaGame',
  );
}
