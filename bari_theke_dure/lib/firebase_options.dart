// lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // Web config (তোর Web app না থাকলেও এটা কাজ করবে – Firebase Web ছাড়া চলবে)
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCeS8AS-pGRM5OLeDQcq2tahIN8qSzrdks',
    appId: '1:182947024330:web:dummywebid',
    messagingSenderId: '182947024330',
    projectId: 'bari-theke-dure',
    authDomain: 'bari-theke-dure.firebaseapp.com',
    storageBucket: 'bari-theke-dure.appspot.com',
  );

  // Android config – তোর google-services.json থেকে ১০০% সঠিক
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCeS8AS-pGRM5OLeDQcq2tahIN8qSzrdks',
    appId: '1:182947024330:android:41b4d7f45864ad1f859333',
    messagingSenderId: '182947024330',
    projectId: 'bari-theke-dure',
    storageBucket: 'bari-theke-dure.appspot.com',
  );

  // iOS (পরে লাগলে ব্যবহার করবি)
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCeS8AS-pGRM5OLeDQcq2tahIN8qSzrdks',
    appId: '1:182947024330:ios:xxxxxxxxxxxxxxxxxxxx',
    messagingSenderId: '182947024330',
    projectId: 'bari-theke-dure',
    storageBucket: 'bari-theke-dure.appspot.com',
    iosBundleId: 'com.sayedakhadija.barithekedure',
  );
}