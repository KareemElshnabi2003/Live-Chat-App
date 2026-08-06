import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Web platform is not configured.');
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError('DefaultFirebaseOptions are not supported for this platform.');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDh9ayCGep3CzL9euNCGnHzaRx3cS_UUDg',
    appId: '1:273991677038:android:f1db26a3e98a9fe323a27f',
    messagingSenderId: '273991677038',
    projectId: 'ngoum-cf658',
    storageBucket: 'ngoum-cf658.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBAnhPEUNTNb_xdro70ZGCyJbis-F3fSrY',
    appId: '1:273991677038:ios:b607b40051b7b91c23a27f',
    messagingSenderId: '273991677038',
    projectId: 'ngoum-cf658',
    storageBucket: 'ngoum-cf658.firebasestorage.app',
    iosBundleId: 'com.liveChat.app',
  );
}