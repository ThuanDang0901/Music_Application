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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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

  // Cấu hình Android thực tế
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDr49lT8L503gSxKZ8cU9ucmthRyDcOR98',
    appId: '1:918063011490:android:3ca03aa9fd9a108280a9fb',
    messagingSenderId: '918063011490',
    projectId: 'music-application-24b29',
    databaseURL: 'https://music-application-24b29-default-rtdb.firebaseio.com',
    storageBucket: 'music-application-24b29.firebasestorage.app',
  );

  // Cấu hình iOS thực tế
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAXcG87_QTFSye3x_L57bNujWBhC2rw8jY',
    appId: '1:918063011490:ios:228e5a5e1884b3cb80a9fb',
    messagingSenderId: '918063011490',
    projectId: 'music-application-24b29',
    databaseURL: 'https://music-application-24b29-default-rtdb.firebaseio.com',
    storageBucket: 'music-application-24b29.firebasestorage.app',
    iosBundleId: 'com.example.flutterApplication1',
  );

  // Cấu hình Web thực tế
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAXcG87_QTFSye3x_L57bNujWBhC2rw8jY',
    appId: '1:918063011490:web:d2a10b1234567890abcdef',
    messagingSenderId: '918063011490',
    projectId: 'music-application-24b29',
    authDomain: 'music-application-24b29.firebaseapp.com',
    databaseURL: 'https://music-application-24b29-default-rtdb.firebaseio.com',
    storageBucket: 'music-application-24b29.firebasestorage.app',
  );
}
