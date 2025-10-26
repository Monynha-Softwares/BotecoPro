// lib/firebase_options.dart

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }

    throw UnsupportedError(
      'FirebaseOptions não configurado para ${defaultTargetPlatform.name}. Execute flutterfire configure.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC_Jhl2v2c9QLHd49oSZw8TzT6URWfXNGw',
    appId: '1:431701294282:web:781a5858396ff158ffc833',
    messagingSenderId: '431701294282',
    projectId: 'boteco-pro',
    authDomain: 'boteco-pro.firebaseapp.com',
    storageBucket: 'boteco-pro.firebasestorage.app',
    measurementId: 'G-ECTQ0X927S',
  );
}
