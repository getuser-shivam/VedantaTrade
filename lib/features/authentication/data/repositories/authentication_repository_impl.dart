import 'dart:convert';
import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/auth_user_entity.dart';
import '../../domain/repositories/authentication_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/auth_models.dart';
import '../../../shared/security/security_manager.dart';
import '../../../shared/utils/app_utils.dart';

/// Authentication Repository Implementation
/// Concrete implementation of AuthenticationRepository with comprehensive security features
class AuthenticationRepositoryImpl implements AuthenticationRepository {
  final AuthLocalDataSource _localDataSource;
  final AuthRemoteDataSource _remoteDataSource;
  final SecurityManager _securityManager;
  final AppUtils _appUtils;

  AuthenticationRepositoryImpl({
    required AuthLocalDataSource localDataSource,
    required AuthRemoteDataSource remoteDataSource,
    required SecurityManager securityManager,
    required AppUtils appUtils,
  })  : _localDataSource = localDataSource,
        _remoteDataSource = remoteDataSource,
        _securityManager = securityManager,
        _appUtils = appUtils;

  @override
  Future<Either<String, AuthUserEntity>> registerUser({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? middleName,
    String? phoneNumber,
    UserRole? role,
    UserProfile? profile,
  }) async {
    try {
      // Validate input
      final validationResult = _validateRegistrationInput(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
      );

      if (validationResult != null) {
        return Left(validationResult);
      }

      // Check if user already exists
      final existingUser = await _remoteDataSource.checkUserExists(email, phoneNumber);
      if (existingUser.isLeft()) {
        return Left(existingUser.fold((l) => l, (r) => 'User already exists'));
      }

      // Hash password with salt
      final salt = _securityManager.generateSalt();
      final hashedPassword = _securityManager.hashPassword(password, salt);

      // Create user data
      final userData = {
        'email': email.toLowerCase().trim(),
        'password': hashedPassword,
        'salt': salt,
        'firstName': firstName.trim(),
        'lastName': lastName.trim(),
        'middleName': middleName?.trim(),
        'phoneNumber': phoneNumber?.trim(),
        'role': role?.name ?? 'user',
        'status': UserStatus.pendingEmailVerification.name,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'preferences': const UserPreferences().toJson(),
        'securitySettings': const SecuritySettings(
          twoFactorEnabled: false,
          twoFactorMethod: TwoFactorMethod.none,
          sessionTimeoutEnabled: true,
          sessionTimeoutMinutes: 30,
          ipWhitelistEnabled: false,
          whitelistedIps: [],
          deviceTrackingEnabled: true,
          maxConcurrentSessions: 3,
          passwordComplexityEnabled: true,
          passwordMinLength: 8,
          passwordHistoryCount: 5,
          loginAttemptLimitEnabled: true,
          maxLoginAttempts: 5,
          lockoutDurationMinutes: 15,
          suspiciousActivityDetection: true,
        ).toJson(),
      };

      if (profile != null) {
        userData['profile'] = profile!.toJson();
      }

      // Register user
      final result = await _remoteDataSource.registerUser(userData);
      
      if (result.isLeft()) {
        return Left(result.fold((l) => l, (r) => 'Registration failed'));
      }

      // Send email verification
      await _sendEmailVerification(email);

      // Create user entity
      final user = AuthUserEntity.fromJson(result.fold((l) => {}, (r) => r));
      
      return Right(user);
    } catch (e) {
      return Left('Registration failed: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, AuthResult>> loginUser({
    required String identifier,
    required String password,
    bool rememberMe = false,
    String? deviceToken,
    String? deviceInfo,
  }) async {
    try {
      // Check rate limiting
      final rateLimitStatus = await _checkRateLimit(identifier, 'login');
      if (rateLimitStatus.isLimited) {
        return Left('Too many login attempts. Please try again later.');
      }

      // Get user by identifier
      final userResult = await _remoteDataSource.getUserByIdentifier(identifier);
      
      if (userResult.isLeft()) {
        await _reportLoginAttempt(identifier, false, 'User not found');
        return Left('Invalid credentials');
      }

      final user = userResult.fold((l) => throw Exception(l), (r) => r);

      // Check account status
      if (user.status != UserStatus.active) {
        await _reportLoginAttempt(identifier, false, 'Account not active');
        return Left('Account is not active. Please verify your email.');
      }

      // Check if account is locked
      final lockStatus = await checkAccountLockStatus(identifier);
      if (lockStatus.isLocked) {
        return Left('Account is locked. Please try again later.');
      }

      // Verify password
      final isPasswordValid = await _securityManager.verifyPassword(
        password,
        user.metadata['password'] as String,
        user.metadata['salt'] as String,
      );

      if (!isPasswordValid) {
        await _reportLoginAttempt(identifier, false, 'Invalid password');
        return Left('Invalid credentials');
      }

      // Check two-factor authentication
      if (user.isTwoFactorEnabled) {
        final twoFactorResult = await _handleTwoFactorAuthentication(user);
        if (twoFactorResult.isLeft()) {
          return twoFactorResult;
        }
        return twoFactorResult.fold((l) => Left(l), (r) => Right(r));
      }

      // Create session
      final session = await _createUserSession(user, deviceToken, deviceInfo);

      // Generate tokens
      final accessToken = await _securityManager.generateJWTToken(user, session.id);
      final refreshToken = await _securityManager.generateRefreshToken(user.id);

      // Update last login
      await _updateLastLogin(user.id);

      // Cache user session
      await _localDataSource.cacheAuthResult(AuthResult(
        user: user,
        accessToken: accessToken,
        refreshToken: refreshToken,
        sessionId: session.id,
        expiresAt: DateTime.now().add(const Duration(hours: 24)),
        session: session,
        requiresTwoFactor: false,
      ));

      // Report successful login
      await _reportLoginAttempt(identifier, true);

      return Right(AuthResult(
        user: user,
        accessToken: accessToken,
        refreshToken: refreshToken,
        sessionId: session.id,
        expiresAt: DateTime.now().add(const Duration(hours: 24)),
        session: session,
        requiresTwoFactor: false,
      ));
    } catch (e) {
      return Left('Login failed: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, AuthResult>> loginWithOAuth({
    required OAuthProvider provider,
    required String accessToken,
    String? deviceToken,
    String? deviceInfo,
  }) async {
    try {
      // Verify OAuth token
      final oauthResult = await _remoteDataSource.verifyOAuthToken(provider, accessToken);
      
      if (oauthResult.isLeft()) {
        return Left('OAuth verification failed');
      }

      final oauthData = oauthResult.fold((l) => {}, (r) => r);

      // Get or create user
      final userResult = await _remoteDataSource.getOrCreateOAuthUser(
        provider,
        oauthData,
      );

      if (userResult.isLeft()) {
        return Left('OAuth user creation failed');
      }

      final user = userResult.fold((l) => throw Exception(l), (r) => r);

      // Create session
      final session = await _createUserSession(user, deviceToken, deviceInfo);

      // Generate tokens
      final appAccessToken = await _securityManager.generateJWTToken(user, session.id);
      final appRefreshToken = await _securityManager.generateRefreshToken(user.id);

      // Update last login
      await _updateLastLogin(user.id);

      // Cache user session
      await _localDataSource.cacheAuthResult(AuthResult(
        user: user,
        accessToken: appAccessToken,
        refreshToken: appRefreshToken,
        sessionId: session.id,
        expiresAt: DateTime.now().add(const Duration(hours: 24)),
        session: session,
        requiresTwoFactor: false,
      ));

      return Right(AuthResult(
        user: user,
        accessToken: appAccessToken,
        refreshToken: appRefreshToken,
        sessionId: session.id,
        expiresAt: DateTime.now().add(const Duration(hours: 24)),
        session: session,
        requiresTwoFactor: false,
      ));
    } catch (e) {
      return Left('OAuth login failed: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, void>> sendEmailVerification(String email) async {
    try {
      final verificationCode = _appUtils.generateUniqueId().substring(0, 6);
      final expiryTime = DateTime.now().add(const Duration(hours: 24));

      await _localDataSource.cacheVerificationCode(email, verificationCode, expiryTime);
      
      final result = await _remoteDataSource.sendEmailVerification(email, verificationCode);
      
      if (result.isLeft()) {
        return Left('Failed to send email verification');
      }

      return const Right(null);
    } catch (e) {
      return Left('Email verification failed: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, AuthUserEntity>> verifyEmail({
    required String email,
    required String verificationCode,
  }) async {
    try {
      final cachedCode = await _localDataSource.getVerificationCode(email);
      
      if (cachedCode == null || cachedCode!.code != verificationCode) {
        return Left('Invalid verification code');
      }

      if (DateTime.now().isAfter(cachedCode!.expiryTime)) {
        return Left('Verification code expired');
      }

      // Update user status
      final userResult = await _remoteDataSource.getUserByEmail(email);
      if (userResult.isLeft()) {
        return Left('User not found');
      }

      final user = userResult.fold((l) => throw Exception(l), (r) => r);
      
      final updatedUser = user.copyWith(
        status: UserStatus.active,
        isEmailVerified: true,
        emailVerifiedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final updateResult = await _remoteDataSource.updateUser(updatedUser);
      
      if (updateResult.isLeft()) {
        return Left('Failed to verify email');
      }

      // Clear verification code
      await _localDataSource.clearVerificationCode(email);

      return Right(updatedUser);
    } catch (e) {
      return Left('Email verification failed: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, void>> requestPasswordReset({
    required String identifier,
    PasswordResetMethod method = PasswordResetMethod.email,
  }) async {
    try {
      final userResult = await _remoteDataSource.getUserByIdentifier(identifier);
      
      if (userResult.isLeft()) {
        // Don't reveal if user exists
        return const Right(null);
      }

      final user = userResult.fold((l) => throw Exception(l), (r) => r);

      String resetCode = _appUtils.generateUniqueId().substring(0, 8);
      String resetToken = _securityManager.generateSecureToken();

      final resetData = {
        'userId': user.id,
        'resetCode': _securityManager.hashPassword(resetCode, user.metadata['salt']),
        'resetToken': resetToken,
        'expiresAt': DateTime.now().add(const Duration(hours: 1)).toIso8601String(),
      };

      await _localDataSource.cachePasswordReset(resetData);

      final result = await _remoteDataSource.sendPasswordReset(
        method == PasswordResetMethod.email ? user.email : user.phoneNumber!,
        resetCode,
      );

      if (result.isLeft()) {
        return Left('Failed to send password reset');
      }

      return const Right(null);
    } catch (e) {
      return Left('Password reset failed: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, void>> resetPassword({
    required String identifier,
    required String verificationCode,
    required String newPassword,
  }) async {
    try {
      final resetData = await _localDataSource.getPasswordReset(identifier);
      
      if (resetData == null) {
        return Left('Password reset not found or expired');
      }

      if (DateTime.now().isAfter(DateTime.parse(resetData!['expiresAt']))) {
        return Left('Password reset expired');
      }

      final userResult = await _remoteDataSource.getUserByIdentifier(identifier);
      if (userResult.isLeft()) {
        return Left('User not found');
      }

      final user = userResult.fold((l) => throw Exception(l), (r) => r);

      // Verify reset code
      final isCodeValid = await _securityManager.verifyPassword(
        verificationCode,
        resetData!['resetCode'],
        user.metadata['salt'],
      );

      if (!isCodeValid) {
        return Left('Invalid reset code');
      }

      // Validate new password
      final passwordStrength = await checkPasswordStrength(newPassword);
      if (passwordStrength.level.index < PasswordStrengthLevel.fair.index) {
        return Left('Password is too weak');
      }

      // Hash new password
      final newSalt = _securityManager.generateSalt();
      final hashedPassword = _securityManager.hashPassword(newPassword, newSalt);

      // Update user password
      final updatedUser = user.copyWith(
        metadata: {
          ...user.metadata,
          'password': hashedPassword,
          'salt': newSalt,
        },
        passwordChangedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final updateResult = await _remoteDataSource.updateUser(updatedUser);
      
      if (updateResult.isLeft()) {
        return Left('Failed to reset password');
      }

      // Clear reset data
      await _localDataSource.clearPasswordReset(identifier);

      return const Right(null);
    } catch (e) {
      return Left('Password reset failed: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, void>> enableTwoFactor({
    required String userId,
    required String verificationCode,
    required TwoFactorMethod method,
  }) async {
    try {
      final userResult = await _remoteDataSource.getUserById(userId);
      if (userResult.isLeft()) {
        return Left('User not found');
      }

      final user = userResult.fold((l) => throw Exception(l), (r) => r);

      // Verify verification code
      final cachedCode = await _localDataSource.getVerificationCode(
        method == TwoFactorMethod.email ? user.email : user.phoneNumber!,
      );

      if (cachedCode == null || cachedCode!.code != verificationCode) {
        return Left('Invalid verification code');
      }

      // Update user security settings
      final updatedSecuritySettings = user.securitySettings.copyWith(
        twoFactorEnabled: true,
        twoFactorMethod: method,
      );

      final updatedUser = user.copyWith(
        securitySettings: updatedSecuritySettings,
        updatedAt: DateTime.now(),
      );

      final updateResult = await _remoteDataSource.updateUser(updatedUser);
      
      if (updateResult.isLeft()) {
        return Left('Failed to enable two-factor authentication');
      }

      // Clear verification code
      await _localDataSource.clearVerificationCode(
        method == TwoFactorMethod.email ? user.email : user.phoneNumber!,
      );

      return const Right(null);
    } catch (e) {
      return Left('Failed to enable two-factor authentication: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, AuthUserEntity>> getCurrentUser() async {
    try {
      final cachedResult = await _localDataSource.getCachedAuthResult();
      
      if (cachedResult == null) {
        return Left('No authenticated user');
      }

      // Check if token is still valid
      if (cachedResult!.isTokenExpired) {
        // Try to refresh token
        final refreshResult = await refreshToken(cachedResult!.refreshToken);
        
        if (refreshResult.isLeft()) {
          return Left('Session expired');
        }

        return refreshResult.fold((l) => Left(l), (r) => Right(r.user));
      }

      return Right(cachedResult!.user);
    } catch (e) {
      return Left('Failed to get current user: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, void>> logout({
    String? sessionId,
    bool logoutAllDevices = false,
  }) async {
    try {
      final cachedResult = await _localDataSource.getCachedAuthResult();
      
      if (cachedResult == null) {
        return const Right(null);
      }

      // Terminate session(s)
      if (logoutAllDevices) {
        await _remoteDataSource.terminateAllSessions(cachedResult!.user.id);
      } else {
        final targetSessionId = sessionId ?? cachedResult!.sessionId;
        await _remoteDataSource.terminateSession(cachedResult!.user.id, targetSessionId);
      }

      // Clear local cache
      await _localDataSource.clearAuthCache();

      return const Right(null);
    } catch (e) {
      return Left('Logout failed: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, PasswordStrength>> checkPasswordStrength(String password) async {
    try {
      final strength = _securityManager.calculatePasswordStrength(password);
      return Right(strength);
    } catch (e) {
      return Left('Password strength check failed: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, AccountLockStatus>> checkAccountLockStatus(String identifier) async {
    try {
      final userResult = await _remoteDataSource.getUserByIdentifier(identifier);
      
      if (userResult.isLeft()) {
        return const Right(AccountLockStatus(
          isLocked: false,
          failedAttempts: 0,
          maxAttempts: 5,
          remainingAttempts: 5,
        ));
      }

      final user = userResult.fold((l) => throw Exception(l), (r) => r);
      final securitySettings = user.securitySettings;

      // Get recent failed attempts
      final failedAttempts = await _localDataSource.getFailedAttempts(identifier);
      final recentAttempts = failedAttempts
          .where((attempt) => DateTime.now().difference(attempt.timestamp).inMinutes < 15)
          .toList();

      final isLocked = securitySettings.shouldLockAccount(recentAttempts.length);
      final lockedUntil = isLocked 
          ? DateTime.now().add(securitySettings.lockoutDuration)
          : null;

      return Right(AccountLockStatus(
        isLocked: isLocked,
        lockedUntil: lockedUntil,
        failedAttempts: recentAttempts.length,
        maxAttempts: securitySettings.maxLoginAttempts,
        remainingAttempts: isLocked ? 0 : securitySettings.maxLoginAttempts - recentAttempts.length,
        lastAttemptAt: recentAttempts.isNotEmpty ? recentAttempts.last.timestamp : null,
      ));
    } catch (e) {
      return Left('Failed to check account lock status: ${e.toString()}');
    }
  }

  // Private helper methods

  String? _validateRegistrationInput({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phoneNumber,
  }) {
    // Email validation
    if (!_appUtils.isValidEmail(email)) {
      return 'Invalid email format';
    }

    // Password validation
    if (!_appUtils.isStrongPassword(password)) {
      return 'Password is too weak';
    }

    // Name validation
    if (firstName.trim().length < 2 || lastName.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }

    // Phone validation (if provided)
    if (phoneNumber != null && !_appUtils.isValidPhoneNumber(phoneNumber!)) {
      return 'Invalid phone number format';
    }

    return null;
  }

  Future<void> _sendEmailVerification(String email) async {
    final verificationCode = _appUtils.generateUniqueId().substring(0, 6);
    final expiryTime = DateTime.now().add(const Duration(hours: 24));

    await _localDataSource.cacheVerificationCode(email, verificationCode, expiryTime);
    await _remoteDataSource.sendEmailVerification(email, verificationCode);
  }

  Future<Either<String, AuthResult>> _handleTwoFactorAuthentication(AuthUserEntity user) async {
    try {
      // For now, return error - in real implementation, this would
      // show 2FA screen and wait for user input
      return Left('Two-factor authentication required');
    } catch (e) {
      return Left('Two-factor authentication failed: ${e.toString()}');
    }
  }

  Future<UserSession> _createUserSession(
    AuthUserEntity user,
    String? deviceToken,
    String? deviceInfo,
  ) async {
    final session = UserSession(
      id: _appUtils.generateUniqueId(),
      userId: user.id,
      deviceType: 'mobile', // Would be detected from device info
      deviceName: deviceInfo ?? 'Unknown Device',
      deviceOs: 'Android', // Would be detected
      ipAddress: '192.168.1.1', // Would be detected
      location: 'Kathmandu, Nepal', // Would be detected
      createdAt: DateTime.now(),
      lastAccessAt: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(hours: 24)),
      isActive: true,
      isPrimary: true,
      userAgent: deviceInfo,
    );

    await _remoteDataSource.createSession(session);
    return session;
  }

  Future<void> _updateLastLogin(String userId) async {
    final updateData = {
      'lastLoginAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };

    await _remoteDataSource.updateUserLastLogin(userId, updateData);
  }

  Future<void> _reportLoginAttempt(
    String identifier,
    bool success,
    String? failureReason,
  ) async {
    final attempt = {
      'identifier': identifier,
      'success': success,
      'failureReason': failureReason,
      'timestamp': DateTime.now().toIso8601String(),
      'ipAddress': '192.168.1.1', // Would be detected
      'userAgent': 'VedantaTrade App', // Would be detected
    };

    await _localDataSource.addFailedAttempt(attempt);
    await _remoteDataSource.reportLoginAttempt(attempt);
  }

  Future<RateLimitStatus> _checkRateLimit(String identifier, String action) async {
    final attempts = await _localDataSource.getFailedAttempts(identifier);
    final recentAttempts = attempts
        .where((attempt) => DateTime.now().difference(attempt.timestamp).inMinutes < 15)
        .toList();

    final maxAttempts = 5; // Could be configurable
    final isLimited = recentAttempts.length >= maxAttempts;

    return RateLimitStatus(
      isLimited: isLimited,
      remainingAttempts: isLimited ? 0 : maxAttempts - recentAttempts.length,
      maxAttempts: maxAttempts,
      resetAt: isLimited ? DateTime.now().add(const Duration(minutes: 15)) : null,
      resetIn: isLimited ? const Duration(minutes: 15) : null,
    );
  }

  @override
  Future<Either<String, AuthResult>> refreshToken(String refreshToken) async {
    try {
      // Verify refresh token
      final tokenData = await _securityManager.verifyRefreshToken(refreshToken);
      
      if (tokenData == null) {
        return Left('Invalid refresh token');
      }

      final userResult = await _remoteDataSource.getUserById(tokenData!['userId']);
      if (userResult.isLeft()) {
        return Left('User not found');
      }

      final user = userResult.fold((l) => throw Exception(l), (r) => r);

      // Generate new tokens
      final newAccessToken = await _securityManager.generateJWTToken(user, tokenData!['sessionId']);
      final newRefreshToken = await _securityManager.generateRefreshToken(user.id);

      // Update session
      await _remoteDataSource.updateSessionLastAccess(tokenData!['sessionId']);

      return Right(AuthResult(
        user: user,
        accessToken: newAccessToken,
        refreshToken: newRefreshToken,
        sessionId: tokenData!['sessionId'],
        expiresAt: DateTime.now().add(const Duration(hours: 24)),
        session: UserSession(id: tokenData!['sessionId'], userId: user.id, deviceType: '', deviceName: '', deviceOs: '', ipAddress: '', location: '', createdAt: DateTime.now(), lastAccessAt: DateTime.now(), expiresAt: DateTime.now().add(const Duration(hours: 24)), isActive: true, isPrimary: true),
      ));
    } catch (e) {
      return Left('Token refresh failed: ${e.toString()}');
    }
  }

  // Implement other required methods...
  @override
  Future<Either<String, AuthUserEntity>> registerWithEmail({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? middleName,
  }) async {
    return registerUser(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      middleName: middleName,
    );
  }

  @override
  Future<Either<String, AuthUserEntity>> registerWithPhone({
    required String phoneNumber,
    required String password,
    required String firstName,
    required String lastName,
    String? middleName,
  }) async {
    return registerUser(
      email: '${phoneNumber}@vedantatrade.com', // Temporary email for phone registration
      password: password,
      firstName: firstName,
      lastName: lastName,
      middleName: middleName,
      phoneNumber: phoneNumber,
    );
  }

  @override
  Future<Either<String, AuthResult>> loginWithEmail({
    required String email,
    required String password,
    bool rememberMe = false,
    String? deviceToken,
    String? deviceInfo,
  }) async {
    return loginUser(
      identifier: email,
      password: password,
      rememberMe: rememberMe,
      deviceToken: deviceToken,
      deviceInfo: deviceInfo,
    );
  }

  @override
  Future<Either<String, AuthResult>> loginWithPhone({
    required String phoneNumber,
    required String password,
    bool rememberMe = false,
    String? deviceToken,
    String? deviceInfo,
  }) async {
    return loginUser(
      identifier: phoneNumber,
      password: password,
      rememberMe: rememberMe,
      deviceToken: deviceToken,
      deviceInfo: deviceInfo,
    );
  }

  @override
  Future<Either<String, AuthResult>> loginWithBiometric({
    required String userId,
    String? deviceToken,
    String? deviceInfo,
  }) async {
    // Implementation would depend on biometric authentication
    return Left('Biometric authentication not implemented');
  }

  @override
  Future<Either<String, void>> sendPhoneVerification(String phoneNumber) async {
    // Similar to email verification but for phone
    return Left('Phone verification not implemented');
  }

  @override
  Future<Either<String, AuthUserEntity>> verifyPhone({
    required String phoneNumber,
    required String verificationCode,
  }) async {
    return Left('Phone verification not implemented');
  }

  @override
  Future<Either<String, void>> resendEmailVerification(String email) async {
    return sendEmailVerification(email);
  }

  @override
  Future<Either<String, void>> resendPhoneVerification(String phoneNumber) async {
    return Left('Phone verification not implemented');
  }

  @override
  Future<Either<String, void>> changePassword({
    required String userId,
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final userResult = await _remoteDataSource.getUserById(userId);
      if (userResult.isLeft()) {
        return Left('User not found');
      }

      final user = userResult.fold((l) => throw Exception(l), (r) => r);

      // Verify current password
      final isCurrentPasswordValid = await _securityManager.verifyPassword(
        currentPassword,
        user.metadata['password'],
        user.metadata['salt'],
      );

      if (!isCurrentPasswordValid) {
        return Left('Current password is incorrect');
      }

      // Validate new password
      final passwordStrength = await checkPasswordStrength(newPassword);
      if (passwordStrength.level.index < PasswordStrengthLevel.fair.index) {
        return Left('New password is too weak');
      }

      // Hash new password
      final newSalt = _securityManager.generateSalt();
      final hashedPassword = _securityManager.hashPassword(newPassword, newSalt);

      // Update user password
      final updatedUser = user.copyWith(
        metadata: {
          ...user.metadata,
          'password': hashedPassword,
          'salt': newSalt,
        },
        passwordChangedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final updateResult = await _remoteDataSource.updateUser(updatedUser);
      
      if (updateResult.isLeft()) {
        return Left('Failed to change password');
      }

      return const Right(null);
    } catch (e) {
      return Left('Password change failed: ${e.toString()}');
    }
  }

  // Additional method implementations would go here...
  @override
  Future<Either<String, void>> setupTwoFactor({
    required String userId,
    required TwoFactorMethod method,
    String? phoneNumber,
    String? email,
  }) async {
    return Left('Two-factor setup not fully implemented');
  }

  @override
  Future<Either<String, void>> disableTwoFactor({
    required String userId,
    required String currentPassword,
    required String twoFactorCode,
  }) async {
    return Left('Two-factor disable not fully implemented');
  }

  @override
  Future<Either<String, List<String>>> generateBackupCodes(String userId) async {
    return Left('Backup codes not implemented');
  }

  @override
  Future<Either<String, AuthResult>> verifyBackupCode({
    required String userId,
    required String backupCode,
  }) async {
    return Left('Backup code verification not implemented');
  }

  @override
  Future<Either<String, AuthUserEntity>> updateProfile({
    required String userId,
    String? firstName,
    String? lastName,
    String? middleName,
    String? phoneNumber,
    String? profileImageUrl,
    UserProfile? profile,
  }) async {
    return Left('Profile update not implemented');
  }

  @override
  Future<Either<String, void>> updatePreferences({
    required String userId,
    required UserPreferences preferences,
  }) async {
    return Left('Preferences update not implemented');
  }

  @override
  Future<Either<String, void>> updateSecuritySettings({
    required String userId,
    required SecuritySettings securitySettings,
  }) async {
    return Left('Security settings update not implemented');
  }

  @override
  Future<Either<String, List<UserSession>>> getUserSessions(String userId) async {
    return Left('Sessions retrieval not implemented');
  }

  @override
  Future<Either<String, void>> terminateSession({
    required String userId,
    required String sessionId,
  }) async {
    return Left('Session termination not implemented');
  }

  @override
  Future<Either<String, void>> terminateAllSessions(String userId) async {
    return Left('All sessions termination not implemented');
  }

  @override
  Future<Either<String, void>> addDeviceToWhitelist({
    required String userId,
    required String deviceInfo,
    required String ipAddress,
  }) async {
    return Left('Device whitelisting not implemented');
  }

  @override
  Future<Either<String, void>> removeDeviceFromWhitelist({
    required String userId,
    required String deviceId,
  }) async {
    return Left('Device removal from whitelist not implemented');
  }

  @override
  Future<Either<String, List<SecurityAuditEntry>>> getSecurityAuditLog({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int limit = 50,
  }) async {
    return Left('Security audit log not implemented');
  }

  @override
  Future<Either<String, void>> reportSuspiciousActivity({
    required String userId,
    required String activity,
    String? description,
    Map<String, dynamic>? metadata,
  }) async {
    return Left('Suspicious activity reporting not implemented');
  }

  @override
  Future<Either<String, bool>> validateSession(String sessionId) async {
    return Left('Session validation not implemented');
  }

  @override
  Future<Either<String, AuthUserEntity>> refreshUserData(String userId) async {
    return Left('User data refresh not implemented');
  }

  @override
  Future<Either<String, List<OAuthProvider>>> getAvailableOAuthProviders() async {
    return const Right([
      OAuthProvider.google,
      OAuthProvider.facebook,
      OAuthProvider.apple,
      OAuthProvider.microsoft,
    ]);
  }

  @override
  Future<Either<String, void>> linkOAuthAccount({
    required String userId,
    required OAuthProvider provider,
    required String accessToken,
  }) async {
    return Left('OAuth linking not implemented');
  }

  @override
  Future<Either<String, void>> unlinkOAuthAccount({
    required String userId,
    required OAuthProvider provider,
  }) async {
    return Left('OAuth unlinking not implemented');
  }

  @override
  Future<Either<String, List<SecurityQuestion>>> getSecurityQuestions() async {
    return Left('Security questions not implemented');
  }

  @override
  Future<Either<String, void>> setSecurityQuestions({
    required String userId,
    required List<SecurityQuestionAnswer> answers,
  }) async {
    return Left('Security questions not implemented');
  }

  @override
  Future<Either<String, bool>> verifySecurityQuestions({
    required String userId,
    required List<SecurityQuestionAnswer> answers,
  }) async {
    return Left('Security questions verification not implemented');
  }

  @override
  Future<Either<String, List<AuthHistoryEntry>>> getAuthHistory({
    required String userId,
    int page = 1,
    int limit = 20,
  }) async {
    return Left('Auth history not implemented');
  }

  @override
  Future<Either<String, void>> clearAuthHistory(String userId) async {
    return Left('Auth history clearing not implemented');
  }

  @override
  Future<Either<String, DeviceInfo>> getDeviceInfo(String deviceId) async {
    return Left('Device info not implemented');
  }

  @override
  Future<Either<String, void>> updateDeviceInfo({
    required String deviceId,
    required DeviceInfo deviceInfo,
  }) async {
    return Left('Device info update not implemented');
  }

  @override
  Future<Either<String, RateLimitStatus>> checkRateLimit(String identifier, String action) async {
    return _checkRateLimit(identifier, action);
  }

  @override
  Future<Either<String, void>> reportLoginAttempt({
    required String identifier,
    required bool success,
    String? ipAddress,
    String? userAgent,
    String? failureReason,
  }) async {
    await _reportLoginAttempt(identifier, success, failureReason);
    return const Right(null);
  }

  @override
  Future<Either<String, List<SecurityRecommendation>>> getSecurityRecommendations(String userId) async {
    return Left('Security recommendations not implemented');
  }

  @override
  Future<Either<String, void>> enableAccountRecovery({
    required String userId,
    AccountRecoveryMethod method,
    String? recoveryEmail,
    String? recoveryPhone,
  }) async {
    return Left('Account recovery not implemented');
  }

  @override
  Future<Either<String, bool>> testAccountRecovery({
    required String userId,
    required String recoveryCode,
  }) async {
    return Left('Account recovery not implemented');
  }

  @override
  Future<Either<String, AuthUserEntity>> completeAccountRecovery({
    required String userId,
    required String recoveryCode,
    required String newPassword,
  }) async {
    return Left('Account recovery not implemented');
  }
}
