// test/core/services/auth_service_test.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:boteco_pro/core/models/auth_user.dart';
import 'package:boteco_pro/core/services/auth_service.dart';

// Generate mocks with: flutter pub run build_runner build
@GenerateMocks([
  FirebaseAuth,
  User,
  UserCredential,
])
import 'auth_service_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuthService', () {
    late MockFirebaseAuth mockFirebaseAuth;
    late AuthService authService;
    late MockUser mockUser;
    late MockUserCredential mockUserCredential;

    setUp(() {
      mockFirebaseAuth = MockFirebaseAuth();
      mockUser = MockUser();
      mockUserCredential = MockUserCredential();
      authService = AuthService(firebaseAuth: mockFirebaseAuth);

      // Setup mock user default behavior
      when(mockUser.uid).thenReturn('test-uid-123');
      when(mockUser.email).thenReturn('test@example.com');
      when(mockUser.displayName).thenReturn('Test User');
      when(mockUser.photoURL).thenReturn(null);
    });

    tearDown(() {
      authService.dispose();
    });

    group('signInWithEmailAndPassword', () {
      test('should return AuthUser on successful login', () async {
        // Arrange
        when(mockUserCredential.user).thenReturn(mockUser);
        when(
          mockFirebaseAuth.signInWithEmailAndPassword(
            email: anyNamed('email'),
            password: anyNamed('password'),
          ),
        ).thenAnswer((_) async => mockUserCredential);

        // Act
        final result = await authService.signInWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password123',
        );

        // Assert
        expect(result, isNotNull);
        expect(result?.id, 'test-uid-123');
        expect(result?.email, 'test@example.com');
        expect(result?.name, 'Test User');
        verify(
          mockFirebaseAuth.signInWithEmailAndPassword(
            email: 'test@example.com',
            password: 'password123',
          ),
        ).called(1);
      });

      test('should throw AuthServiceException on FirebaseAuthException',
          () async {
        // Arrange
        when(
          mockFirebaseAuth.signInWithEmailAndPassword(
            email: anyNamed('email'),
            password: anyNamed('password'),
          ),
        ).thenThrow(
          FirebaseAuthException(
            code: 'user-not-found',
            message: 'User not found',
          ),
        );

        // Act & Assert
        expect(
          () => authService.signInWithEmailAndPassword(
            email: 'test@example.com',
            password: 'wrong-password',
          ),
          throwsA(isA<AuthServiceException>()),
        );
      });
    });

    group('registerWithEmailAndPassword', () {
      test('should return AuthUser on successful registration', () async {
        // Arrange
        when(mockUserCredential.user).thenReturn(mockUser);
        when(
          mockFirebaseAuth.createUserWithEmailAndPassword(
            email: anyNamed('email'),
            password: anyNamed('password'),
          ),
        ).thenAnswer((_) async => mockUserCredential);
        when(mockUser.updateDisplayName(any)).thenAnswer((_) async => {});
        when(mockUser.reload()).thenAnswer((_) async => {});
        when(mockFirebaseAuth.currentUser).thenReturn(mockUser);

        // Act
        final result = await authService.registerWithEmailAndPassword(
          email: 'newuser@example.com',
          password: 'password123',
          name: 'New User',
        );

        // Assert
        expect(result, isNotNull);
        expect(result?.id, 'test-uid-123');
        expect(result?.email, 'test@example.com');
        verify(
          mockFirebaseAuth.createUserWithEmailAndPassword(
            email: 'newuser@example.com',
            password: 'password123',
          ),
        ).called(1);
        verify(mockUser.updateDisplayName('New User')).called(1);
      });

      test('should throw AuthServiceException on weak password', () async {
        // Arrange
        when(
          mockFirebaseAuth.createUserWithEmailAndPassword(
            email: anyNamed('email'),
            password: anyNamed('password'),
          ),
        ).thenThrow(
          FirebaseAuthException(
            code: 'weak-password',
            message: 'Password is too weak',
          ),
        );

        // Act & Assert
        expect(
          () => authService.registerWithEmailAndPassword(
            email: 'test@example.com',
            password: '123',
          ),
          throwsA(isA<AuthServiceException>()),
        );
      });
    });

    group('signOut', () {
      test('should call Firebase signOut', () async {
        // Arrange
        when(mockFirebaseAuth.signOut()).thenAnswer((_) async => {});

        // Act
        await authService.signOut();

        // Assert
        verify(mockFirebaseAuth.signOut()).called(1);
      });

      test('should throw AuthServiceException on error', () async {
        // Arrange
        when(mockFirebaseAuth.signOut()).thenThrow(
          FirebaseAuthException(
            code: 'network-error',
            message: 'Network error',
          ),
        );

        // Act & Assert
        expect(
          () => authService.signOut(),
          throwsA(isA<AuthServiceException>()),
        );
      });
    });

    group('sendPasswordResetEmail', () {
      test('should send password reset email', () async {
        // Arrange
        when(
          mockFirebaseAuth.sendPasswordResetEmail(email: anyNamed('email')),
        ).thenAnswer((_) async => {});

        // Act
        await authService.sendPasswordResetEmail('test@example.com');

        // Assert
        verify(
          mockFirebaseAuth.sendPasswordResetEmail(email: 'test@example.com'),
        ).called(1);
      });

      test('should throw AuthServiceException on invalid email', () async {
        // Arrange
        when(
          mockFirebaseAuth.sendPasswordResetEmail(email: anyNamed('email')),
        ).thenThrow(
          FirebaseAuthException(
            code: 'invalid-email',
            message: 'Invalid email',
          ),
        );

        // Act & Assert
        expect(
          () => authService.sendPasswordResetEmail('invalid-email'),
          throwsA(isA<AuthServiceException>()),
        );
      });
    });

    group('getCurrentUser', () {
      test('should return AuthUser when user is signed in', () async {
        // Arrange
        when(mockFirebaseAuth.currentUser).thenReturn(mockUser);

        // Act
        final result = await authService.getCurrentUser();

        // Assert
        expect(result, isNotNull);
        expect(result?.id, 'test-uid-123');
        expect(result?.email, 'test@example.com');
      });

      test('should return null when user is not signed in', () async {
        // Arrange
        when(mockFirebaseAuth.currentUser).thenReturn(null);

        // Act
        final result = await authService.getCurrentUser();

        // Assert
        expect(result, isNull);
      });
    });

    group('authStateChanges', () {
      test('should emit AuthUser when user signs in', () async {
        // Arrange
        final controller = StreamController<User?>();
        when(mockFirebaseAuth.authStateChanges())
            .thenAnswer((_) => controller.stream);

        // Act
        final stream = authService.authStateChanges;
        controller.add(mockUser);

        // Assert
        await expectLater(
          stream,
          emits(isA<AuthUser>()),
        );

        controller.close();
      });

      test('should emit null when user signs out', () async {
        // Arrange
        final controller = StreamController<User?>();
        when(mockFirebaseAuth.authStateChanges())
            .thenAnswer((_) => controller.stream);

        // Act
        final stream = authService.authStateChanges;
        controller.add(null);

        // Assert
        await expectLater(
          stream,
          emits(null),
        );

        controller.close();
      });
    });
  });
}
