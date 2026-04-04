import 'package:dartz/dartz.dart';
import '../entities/user_entity.dart';

/// Authentication Repository Interface
/// Defines the contract for authentication data operations
abstract class AuthRepository {
  /// Login user with email and password
  Future<Either<String, UserEntity>> login(String email, String password);

  /// Register new user
  Future<Either<String, UserEntity>> register(
    String name,
    String email,
    String password,
    String phone,
  );

  /// Logout current user
  Future<Either<String, void>> logout();

  /// Reset password
  Future<Either<String, void>> resetPassword(String email);

  /// Refresh authentication token
  Future<Either<String, String>> refreshToken(String refreshToken);

  /// Get current user
  Future<Either<String, UserEntity>> getCurrentUser();

  /// Update user profile
  Future<Either<String, UserEntity>> updateProfile(UserEntity user);

  /// Change password
  Future<Either<String, void>> changePassword(
    String currentPassword,
    String newPassword,
  );

  /// Delete user account
  Future<Either<String, void>> deleteAccount();

  /// Enable/disable biometric authentication
  Future<Either<String, void>> toggleBiometricAuth(bool enabled);

  /// Check if user is authenticated
  Future<bool> isAuthenticated();

  /// Get authentication token
  Future<String?> getAuthToken();
}
