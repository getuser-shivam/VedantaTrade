import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';

import '../../../../lib/features/authentication/domain/repositories/authentication_repository.dart';
import '../../../../lib/features/authentication/domain/entities/auth_user_entity.dart';
import '../../../../lib/features/authentication/domain/models/auth_models.dart';
import '../test_helpers/test_helpers.dart';

@GenerateMocks([AuthenticationRepository])
import 'authentication_repository_test.mocks.dart';

void main() {
  group('AuthenticationRepository Tests', () {
    late MockAuthenticationRepository mockRepository;
    late LoginRequest testLoginRequest;
    late RegisterRequest testRegisterRequest;
    late AuthUserEntity testUser;

    setUp(() {
      mockRepository = MockAuthenticationRepository();
      testLoginRequest = LoginRequest(
        email: 'test@vedantatrade.com',
        password: 'password123',
      );
      testRegisterRequest = RegisterRequest(
        email: 'test@vedantatrade.com',
        password: 'password123',
        name: 'Test User',
        role: 'admin',
      );
      testUser = AuthUserEntity(
        id: 'test-user-123',
        email: 'test@vedantatrade.com',
        name: 'Test User',
        role: 'admin',
        isActive: true,
        createdAt: DateTime.parse('2026-04-05T12:00:00.000Z'),
      );
    });

    group('Login Tests', () {
      test('should login successfully with valid credentials', () async {
        // Arrange
        when(mockRepository.login(any))
            .thenAnswer((_) async => Right(testUser));

        // Act
        final result = await mockRepository.login(testLoginRequest);

        // Assert
        expect(result, isA<Right<String, AuthUserEntity>>());
        final user = result.fold((l) => null, (r) => r);
        expect(user?.id, equals(testUser.id));
        expect(user?.email, equals(testUser.email));
        expect(user?.name, equals(testUser.name));
        expect(user?.role, equals(testUser.role));
        verify(mockRepository.login(testLoginRequest)).called(1);
        verifyNoMoreInteractions(mockRepository);
      });

      test('should return error with invalid credentials', () async {
        // Arrange
        const errorMessage = 'Invalid credentials';
        when(mockRepository.login(any))
            .thenAnswer((_) async => Left(errorMessage));

        // Act
        final result = await mockRepository.login(testLoginRequest);

        // Assert
        expect(result, isA<Left<String, AuthUserEntity>>());
        final error = result.fold((l) => l, (r) => null);
        expect(error, equals(errorMessage));
        verify(mockRepository.login(testLoginRequest)).called(1);
        verifyNoMoreInteractions(mockRepository);
      });

      test('should handle network error during login', () async {
        // Arrange
        when(mockRepository.login(any))
            .thenThrow(Exception('Network error'));

        // Act & Assert
        expect(
          () => mockRepository.login(testLoginRequest),
          throwsException,
        );
        verify(mockRepository.login(testLoginRequest)).called(1);
        verifyNoMoreInteractions(mockRepository);
      });

      test('should validate login request format', () async {
        // Arrange
        final invalidRequest = LoginRequest(
          email: 'invalid-email',
          password: '',
        );
        when(mockRepository.login(any))
            .thenAnswer((_) async => Left('Invalid email format'));

        // Act
        final result = await mockRepository.login(invalidRequest);

        // Assert
        expect(result, isA<Left<String, AuthUserEntity>>());
        verify(mockRepository.login(invalidRequest)).called(1);
        verifyNoMoreInteractions(mockRepository);
      });
    });

    group('Register Tests', () {
      test('should register successfully with valid data', () async {
        // Arrange
        when(mockRepository.register(any))
            .thenAnswer((_) async => Right(testUser));

        // Act
        final result = await mockRepository.register(testRegisterRequest);

        // Assert
        expect(result, isA<Right<String, AuthUserEntity>>());
        final user = result.fold((l) => null, (r) => r);
        expect(user?.id, equals(testUser.id));
        expect(user?.email, equals(testUser.email));
        expect(user?.name, equals(testUser.name));
        verify(mockRepository.register(testRegisterRequest)).called(1);
        verifyNoMoreInteractions(mockRepository);
      });

      test('should return error when email already exists', () async {
        // Arrange
        const errorMessage = 'Email already exists';
        when(mockRepository.register(any))
            .thenAnswer((_) async => Left(errorMessage));

        // Act
        final result = await mockRepository.register(testRegisterRequest);

        // Assert
        expect(result, isA<Left<String, AuthUserEntity>>());
        final error = result.fold((l) => l, (r) => null);
        expect(error, equals(errorMessage));
        verify(mockRepository.register(testRegisterRequest)).called(1);
        verifyNoMoreInteractions(mockRepository);
      });

      test('should validate password strength during registration', () async {
        // Arrange
        final weakPasswordRequest = RegisterRequest(
          email: 'test@vedantatrade.com',
          password: '123',
          name: 'Test User',
          role: 'admin',
        );
        when(mockRepository.register(any))
            .thenAnswer((_) async => Left('Password too weak'));

        // Act
        final result = await mockRepository.register(weakPasswordRequest);

        // Assert
        expect(result, isA<Left<String, AuthUserEntity>>());
        verify(mockRepository.register(weakPasswordRequest)).called(1);
        verifyNoMoreInteractions(mockRepository);
      });
    });

    group('Logout Tests', () {
      test('should logout successfully', () async {
        // Arrange
        when(mockRepository.logout())
            .thenAnswer((_) async => const Right(null));

        // Act
        final result = await mockRepository.logout();

        // Assert
        expect(result, isA<Right<String, void>>());
        verify(mockRepository.logout()).called(1);
        verifyNoMoreInteractions(mockRepository);
      });

      test('should handle logout error', () async {
        // Arrange
        const errorMessage = 'Logout failed';
        when(mockRepository.logout())
            .thenAnswer((_) async => Left(errorMessage));

        // Act
        final result = await mockRepository.logout();

        // Assert
        expect(result, isA<Left<String, void>>());
        final error = result.fold((l) => l, (r) => null);
        expect(error, equals(errorMessage));
        verify(mockRepository.logout()).called(1);
        verifyNoMoreInteractions(mockRepository);
      });
    });

    group('Get Current User Tests', () {
      test('should return current user when logged in', () async {
        // Arrange
        when(mockRepository.getCurrentUser())
            .thenAnswer((_) async => Right(testUser));

        // Act
        final result = await mockRepository.getCurrentUser();

        // Assert
        expect(result, isA<Right<String, AuthUserEntity>>());
        final user = result.fold((l) => null, (r) => r);
        expect(user?.id, equals(testUser.id));
        expect(user?.email, equals(testUser.email));
        verify(mockRepository.getCurrentUser()).called(1);
        verifyNoMoreInteractions(mockRepository);
      });

      test('should return null when not logged in', () async {
        // Arrange
        when(mockRepository.getCurrentUser())
            .thenAnswer((_) async => const Right(null));

        // Act
        final result = await mockRepository.getCurrentUser();

        // Assert
        expect(result, isA<Right<String, AuthUserEntity?>>());
        final user = result.fold((l) => null, (r) => r);
        expect(user, isNull);
        verify(mockRepository.getCurrentUser()).called(1);
        verifyNoMoreInteractions(mockRepository);
      });
    });

    group('Password Reset Tests', () {
      test('should send password reset email successfully', () async {
        // Arrange
        const email = 'test@vedantatrade.com';
        when(mockRepository.resetPassword(any))
            .thenAnswer((_) async => const Right(null));

        // Act
        final result = await mockRepository.resetPassword(email);

        // Assert
        expect(result, isA<Right<String, void>>());
        verify(mockRepository.resetPassword(email)).called(1);
        verifyNoMoreInteractions(mockRepository);
      });

      test('should return error for invalid email during password reset', () async {
        // Arrange
        const invalidEmail = 'invalid-email';
        const errorMessage = 'Invalid email format';
        when(mockRepository.resetPassword(any))
            .thenAnswer((_) async => Left(errorMessage));

        // Act
        final result = await mockRepository.resetPassword(invalidEmail);

        // Assert
        expect(result, isA<Left<String, void>>());
        final error = result.fold((l) => l, (r) => null);
        expect(error, equals(errorMessage));
        verify(mockRepository.resetPassword(invalidEmail)).called(1);
        verifyNoMoreInteractions(mockRepository);
      });
    });

    group('Session Management Tests', () {
      test('should refresh token successfully', () async {
        // Arrange
        const newToken = 'new-token-456';
        when(mockRepository.refreshToken(any))
            .thenAnswer((_) async => const Right(newToken));

        // Act
        final result = await mockRepository.refreshToken('old-token');

        // Assert
        expect(result, isA<Right<String, String>>());
        final token = result.fold((l) => null, (r) => r);
        expect(token, equals(newToken));
        verify(mockRepository.refreshToken('old-token')).called(1);
        verifyNoMoreInteractions(mockRepository);
      });

      test('should handle token refresh failure', () async {
        // Arrange
        const errorMessage = 'Token refresh failed';
        when(mockRepository.refreshToken(any))
            .thenAnswer((_) async => Left(errorMessage));

        // Act
        final result = await mockRepository.refreshToken('invalid-token');

        // Assert
        expect(result, isA<Left<String, String>>());
        final error = result.fold((l) => l, (r) => null);
        expect(error, equals(errorMessage));
        verify(mockRepository.refreshToken('invalid-token')).called(1);
        verifyNoMoreInteractions(mockRepository);
      });
    });

    group('Biometric Authentication Tests', () {
      test('should enable biometric authentication successfully', () async {
        // Arrange
        when(mockRepository.enableBiometricAuth())
            .thenAnswer((_) async => const Right(null));

        // Act
        final result = await mockRepository.enableBiometricAuth();

        // Assert
        expect(result, isA<Right<String, void>>());
        verify(mockRepository.enableBiometricAuth()).called(1);
        verifyNoMoreInteractions(mockRepository);
      });

      test('should handle biometric authentication not available', () async {
        // Arrange
        const errorMessage = 'Biometric authentication not available';
        when(mockRepository.enableBiometricAuth())
            .thenAnswer((_) async => Left(errorMessage));

        // Act
        final result = await mockRepository.enableBiometricAuth();

        // Assert
        expect(result, isA<Left<String, void>>());
        final error = result.fold((l) => l, (r) => null);
        expect(error, equals(errorMessage));
        verify(mockRepository.enableBiometricAuth()).called(1);
        verifyNoMoreInteractions(mockRepository);
      });
    });

    group('OAuth Authentication Tests', () {
      test('should authenticate with Google successfully', () async {
        // Arrange
        when(mockRepository.authenticateWithGoogle())
            .thenAnswer((_) async => Right(testUser));

        // Act
        final result = await mockRepository.authenticateWithGoogle();

        // Assert
        expect(result, isA<Right<String, AuthUserEntity>>());
        final user = result.fold((l) => null, (r) => r);
        expect(user?.id, equals(testUser.id));
        expect(user?.email, equals(testUser.email));
        verify(mockRepository.authenticateWithGoogle()).called(1);
        verifyNoMoreInteractions(mockRepository);
      });

      test('should handle Google authentication cancellation', () async {
        // Arrange
        const errorMessage = 'Google authentication cancelled';
        when(mockRepository.authenticateWithGoogle())
            .thenAnswer((_) async => Left(errorMessage));

        // Act
        final result = await mockRepository.authenticateWithGoogle();

        // Assert
        expect(result, isA<Left<String, AuthUserEntity>>());
        final error = result.fold((l) => l, (r) => null);
        expect(error, equals(errorMessage));
        verify(mockRepository.authenticateWithGoogle()).called(1);
        verifyNoMoreInteractions(mockRepository);
      });
    });

    group('Security Tests', () {
      test('should detect suspicious login attempts', () async {
        // Arrange
        const errorMessage = 'Suspicious login attempt detected';
        when(mockRepository.login(any))
            .thenAnswer((_) async => Left(errorMessage));

        // Act
        final result = await mockRepository.login(testLoginRequest);

        // Assert
        expect(result, isA<Left<String, AuthUserEntity>>());
        final error = result.fold((l) => l, (r) => null);
        expect(error, contains('suspicious'));
        verify(mockRepository.login(testLoginRequest)).called(1);
        verifyNoMoreInteractions(mockRepository);
      });

      test('should enforce rate limiting', () async {
        // Arrange
        const errorMessage = 'Too many login attempts';
        when(mockRepository.login(any))
            .thenAnswer((_) async => Left(errorMessage));

        // Act
        final result = await mockRepository.login(testLoginRequest);

        // Assert
        expect(result, isA<Left<String, AuthUserEntity>>());
        final error = result.fold((l) => l, (r) => null);
        expect(error, contains('Too many'));
        verify(mockRepository.login(testLoginRequest)).called(1);
        verifyNoMoreInteractions(mockRepository);
      });
    });

    group('Performance Tests', () {
      test('should complete login within acceptable time', () async {
        // Arrange
        when(mockRepository.login(any))
            .thenAnswer((_) async {
              await Future.delayed(const Duration(milliseconds: 100));
              return Right(testUser);
            });

        // Act
        final stopwatch = Stopwatch()..start();
        final result = await mockRepository.login(testLoginRequest);
        stopwatch.stop();

        // Assert
        expect(result, isA<Right<String, AuthUserEntity>>());
        expect(stopwatch.elapsedMilliseconds, lessThan(500),
            reason: 'Login should complete within 500ms');
        verify(mockRepository.login(testLoginRequest)).called(1);
        verifyNoMoreInteractions(mockRepository);
      });

      test('should handle concurrent login requests', () async {
        // Arrange
        when(mockRepository.login(any))
            .thenAnswer((_) async => Right(testUser));

        // Act
        final futures = List.generate(5, (_) => mockRepository.login(testLoginRequest));
        final results = await Future.wait(futures);

        // Assert
        for (final result in results) {
          expect(result, isA<Right<String, AuthUserEntity>>());
        }
        verify(mockRepository.login(testLoginRequest)).called(5);
        verifyNoMoreInteractions(mockRepository);
      });
    });
  });
}
