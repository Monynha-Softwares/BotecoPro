// lib/firebase_options.dart
//
// Configurações geradas manualmente para integração com Firebase.
// Atualize os valores de cada plataforma conforme o projeto for habilitado.

import 'package:firebase_core/firebase_core.dart';
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
        return windows;
      case TargetPlatform.linux:
        return linux;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions não possui configuração para esta plataforma.',
        );
    }
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

  // Valores placeholders para permitir inicialização em plataformas não configuradas.
  // Substitua pelos valores reais gerados pelo Firebase Console quando necessário.
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC_Jhl2v2c9QLHd49oSZw8TzT6URWfXNGw',
    appId: '1:431701294282:android:placeholder',
    messagingSenderId: '431701294282',
    projectId: 'boteco-pro',
    storageBucket: 'boteco-pro.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC_Jhl2v2c9QLHd49oSZw8TzT6URWfXNGw',
    appId: '1:431701294282:ios:placeholder',
    messagingSenderId: '431701294282',
    projectId: 'boteco-pro',
    storageBucket: 'boteco-pro.firebasestorage.app',
    iosBundleId: 'com.example.botecoPro',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyC_Jhl2v2c9QLHd49oSZw8TzT6URWfXNGw',
    appId: '1:431701294282:macos:placeholder',
    messagingSenderId: '431701294282',
    projectId: 'boteco-pro',
    storageBucket: 'boteco-pro.firebasestorage.app',
    iosBundleId: 'com.example.botecoPro',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyC_Jhl2v2c9QLHd49oSZw8TzT6URWfXNGw',
    appId: '1:431701294282:windows:placeholder',
    messagingSenderId: '431701294282',
    projectId: 'boteco-pro',
    storageBucket: 'boteco-pro.firebasestorage.app',
  );

  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'AIzaSyC_Jhl2v2c9QLHd49oSZw8TzT6URWfXNGw',
    appId: '1:431701294282:linux:placeholder',
    messagingSenderId: '431701294282',
    projectId: 'boteco-pro',
    storageBucket: 'boteco-pro.firebasestorage.app',
  );
}
