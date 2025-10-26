// lib/core/providers/auth_provider.dart

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/auth_user.dart';
import '../services/auth_service.dart';

/// AuthProvider - Gerenciador de Estado de Autenticação
///
/// IMPLEMENTAÇÃO ATUAL:
/// - Usa SharedPreferences como fallback (desenvolvimento)
/// - Persiste usuário localmente
/// - Gerencia estado de autenticação com ChangeNotifier
/// - Pronto para migração para Firebase
///
/// ESTRATÉGIA DE MIGRAÇÃO PARA FIREBASE:
///
/// 1. Adicionar dependências no pubspec.yaml:
/// ```yaml
/// dependencies:
///   firebase_core: ^2.24.0
///   firebase_auth: ^4.15.0
///   google_sign_in: ^6.1.5
/// ```
///
/// 2. Inicializar Firebase no main.dart:
/// ```dart
/// import 'package:firebase_core/firebase_core.dart';
///
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   await Firebase.initializeApp();
///   runApp(const MyApp());
/// }
/// ```
///
/// 3. Trocar flag useFirebase para true
///
/// 4. Descomentar imports do Firebase no topo deste arquivo
///
/// 5. Implementar métodos seguindo os exemplos comentados abaixo
///
/// INTEGRAÇÃO COM AuthService:
/// - Este Provider pode chamar AuthService para lógica de autenticação
/// - AuthService conterá a implementação Firebase
/// - AuthProvider gerencia o estado da UI
///
/// USO NO APP:
/// ```dart
/// // Wrap o app com Provider no main.dart:
/// MultiProvider(
///   providers: [
///     ChangeNotifierProvider(create: (_) => AuthProvider()),
///   ],
///   child: MyApp(),
/// )
///
/// // Usar em widgets:
/// final authProvider = context.watch<AuthProvider>();
/// if (authProvider.isSignedIn) {
///   // Usuário autenticado
/// }
///
/// // Fazer login:
/// await context.read<AuthProvider>().signInWithEmail(email, password);
/// ```
///
/// Future-ready AuthProvider with a SharedPreferences fallback.
///
/// To replace the fallback with Firebase, uncomment the Firebase imports
/// and replace the implementation in each method with the commented examples.
///
/// Example Firebase usage (commented below):
///
/// import 'package:firebase_auth/firebase_auth.dart';
/// import 'package:google_sign_in/google_sign_in.dart';
///
/// // Sign in with email:
/// // final userCredential = await FirebaseAuth.instance
/// //     .signInWithEmailAndPassword(email: email, password: password);
/// // final fbUser = userCredential.user;
/// // _user = _toAuthUserFromFirebaseUser(fbUser);
///
/// // Sign out:
/// // await FirebaseAuth.instance.signOut();
///
/// // Google Sign-In:
/// // final googleUser = await GoogleSignIn().signIn();
/// // final googleAuth = await googleUser!.authentication;
/// // final credential = GoogleAuthProvider.credential(
/// //   accessToken: googleAuth.accessToken,
/// //   idToken: googleAuth.idToken,
/// // );
/// // final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

class AuthProvider extends ChangeNotifier {
  static const String _authUserKey = 'auth_user';

  AuthProvider({AuthService? authService})
      : _authService = authService ?? AuthService();

  AuthUser? _user;
  bool _initialized = false;
  final AuthService _authService;

  // Toggle this to true and implement Firebase code to switch to Firebase auth.
  // (Left false by default so app remains functional without Firebase packages)
  final bool useFirebase = false;

  AuthUser? get user => _user;
  bool get isSignedIn => _user != null;
  bool get initialized => _initialized;

  /// Initialize provider (load persisted user if any).
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_authUserKey);
    if (raw != null) {
      try {
        final Map<String, dynamic> json =
            jsonDecode(raw) as Map<String, dynamic>;
        final persistedUser = AuthUser.fromJson(json);
        final storedUser = await _authService.getUserById(persistedUser.id);
        if (storedUser != null) {
          _user = storedUser;
        } else {
          _user = null;
          await prefs.remove(_authUserKey);
        }
      } catch (_) {
        _user = null;
        await prefs.remove(_authUserKey);
      }
    }
    _initialized = true;
    notifyListeners();
  }

  /// Sign in with email/password.
  ///
  /// Future implementation using Firebase is shown in file comments.
  /// Current fallback persists a minimal user to SharedPreferences.
  Future<AuthUser?> signInWithEmail(String email, String password) async {
    if (useFirebase) {
      // TODO: Replace with FirebaseAuth implementation.
      // final userCredential = await FirebaseAuth.instance
      //     .signInWithEmailAndPassword(email: email, password: password);
      // final fbUser = userCredential.user;
      // _user = _authUserFromFirebaseUser(fbUser);
      // await _persistUser();
      // notifyListeners();
      // return _user;
      throw UnimplementedError('Firebase integration not enabled.');
    }

    final authUser = await _authService.signInWithEmail(
      email: email,
      password: password,
    );
    _user = authUser;
    await _persistUser();
    notifyListeners();
    return _user;
  }

  /// Register with email/password.
  Future<AuthUser?> signUpWithEmail(String email, String password,
      {String? name}) async {
    if (useFirebase) {
      // TODO: Replace with FirebaseAuth implementation.
      // final userCredential = await FirebaseAuth.instance
      //     .createUserWithEmailAndPassword(email: email, password: password);
      // _user = _authUserFromFirebaseUser(userCredential.user);
      // await _persistUser();
      // notifyListeners();
      // return _user;
      throw UnimplementedError('Firebase integration not enabled.');
    }

    final newUser = await _authService.signUpWithEmail(
      email: email,
      password: password,
      name: name,
    );
    _user = newUser;
    await _persistUser();
    notifyListeners();
    return _user;
  }

  /// Sign in with Google (placeholder).
  Future<AuthUser?> signInWithGoogle() async {
    if (useFirebase) {
      // TODO: Replace with Google Sign-In + Firebase credential flow.
      // final googleUser = await GoogleSignIn().signIn();
      // final googleAuth = await googleUser!.authentication;
      // final credential = GoogleAuthProvider.credential(
      //   accessToken: googleAuth.accessToken,
      //   idToken: googleAuth.idToken,
      // );
      // final userCredential =
      //     await FirebaseAuth.instance.signInWithCredential(credential);
      // _user = _authUserFromFirebaseUser(userCredential.user);
      // await _persistUser();
      // notifyListeners();
      // return _user;
      throw UnimplementedError('Firebase integration not enabled.');
    }

    // Fallback: not supported without Firebase; throw to make developer aware.
    throw UnimplementedError('Google Sign-In requires Firebase integration.');
  }

  /// Send password reset (placeholder).
  Future<void> sendPasswordReset(String email) async {
    if (useFirebase) {
      // TODO: Replace with FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      throw UnimplementedError('Firebase integration not enabled.');
    }

    await _authService.requestPasswordReset(email: email);
  }

  /// Sign out current user.
  Future<void> signOut() async {
    if (useFirebase) {
      // TODO: Replace with FirebaseAuth sign out flows.
      // await FirebaseAuth.instance.signOut();
      throw UnimplementedError('Firebase integration not enabled.');
    }

    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authUserKey);
    notifyListeners();
  }

  Future<void> _persistUser() async {
    final prefs = await SharedPreferences.getInstance();
    if (_user == null) {
      await prefs.remove(_authUserKey);
      return;
    }
    final raw = jsonEncode(_user!.toJson());
    await prefs.setString(_authUserKey, raw);
  }

  // Helper for converting a Firebase User (when migrating) to AuthUser.
  // Uncomment when using Firebase:
  //
  // AuthUser _authUserFromFirebaseUser(User? fbUser) {
  //   if (fbUser == null) {
  //     throw StateError('Firebase user is null');
  //   }
  //   return AuthUser(
  //     id: fbUser.uid,
  //     email: fbUser.email,
  //     name: fbUser.displayName,
  //     photoUrl: fbUser.photoURL,
  //   );
  // }
}
