import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/auth_user_entity.dart';
import '../../domain/repositories/authentication_repository.dart';
import '../states/authentication_state.dart';
import '../events/authentication_event.dart';

/// Authentication Provider
/// Manages authentication state and handles authentication events
class AuthenticationProvider extends ChangeNotifier {
  final AuthenticationRepository _repository;
  AuthenticationState _state = const AuthenticationState.initial();
  StreamSubscription? _authSubscription;

  AuthenticationProvider({
    required AuthenticationRepository repository,
  }) : _repository = repository;

  /// Current authentication state
  AuthenticationState get state => _state;

  /// Initialize authentication provider
  Future<void> initialize() async {
    _emitState(const AuthenticationState.loading());
    
    try {
      final currentUser = await _repository.getCurrentUser();
      
      if (currentUser.isRight()) {
        final user = currentUser.fold((l) => throw Exception(l), (r) => r);
        _emitState(AuthenticationState.authenticated(user: user));
      } else {
        _emitState(const AuthenticationState.unauthenticated());
      }
    } catch (e) {
      _emitState(AuthenticationState.error(
        message: 'Failed to initialize authentication: ${e.toString()}',
      ));
    }
  }

  /// User registration
  Future<void> registerUser({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? middleName,
    String? phoneNumber,
    UserRole? role,
    UserProfile? profile,
  }) async {
    _emitState(const AuthenticationState.loading());

    try {
      final result = await _repository.registerUser(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        middleName: middleName,
        phoneNumber: phoneNumber,
        role: role,
        profile: profile,
      );

      if (result.isLeft()) {
        _emitState(AuthenticationState.error(
          message: result.fold((l) => l, (r) => 'Registration failed'),
        ));
        return;
      }

      final user = result.fold((l) => throw Exception(l), (r) => r);
      _emitState(AuthenticationState.registered(user: user));
    } catch (e) {
      _emitState(AuthenticationState.error(
        message: 'Registration failed: ${e.toString()}',
      ));
    }
  }

  /// User login
  Future<void> loginUser({
    required String identifier,
    required String password,
    bool rememberMe = false,
    String? deviceToken,
    String? deviceInfo,
  }) async {
    _emitState(const AuthenticationState.loading());

    try {
      final result = await _repository.loginUser(
        identifier: identifier,
        password: password,
        rememberMe: rememberMe,
        deviceToken: deviceToken,
        deviceInfo: deviceInfo,
      );

      if (result.isLeft()) {
        _emitState(AuthenticationState.error(
          message: result.fold((l) => l, (r) => 'Login failed'),
        ));
        return;
      }

      final authResult = result.fold((l) => throw Exception(l), (r) => r);
      
      if (authResult.requiresTwoFactor) {
        _emitState(AuthenticationState.twoFactorRequired(
          user: authResult.user,
          authResult: authResult,
        ));
      } else {
        _emitState(AuthenticationState.authenticated(user: authResult.user));
      }
    } catch (e) {
      _emitState(AuthenticationState.error(
        message: 'Login failed: ${e.toString()}',
      ));
    }
  }

  /// Verify MFA Login
  Future<void> verifyMfaCode({
    required String identifier,
    required String mfaToken,
    required String mfaCode,
  }) async {
    _emitState(state.copyWith(isLoading: true, errorMessage: null));

    try {
      final result = await _repository.verifyMfaLogin(
        identifier: identifier,
        mfaToken: mfaToken,
        mfaCode: mfaCode,
      );

      if (result.isLeft()) {
        _emitState(state.copyWith(
          isLoading: false,
          errorMessage: result.fold((l) => l, (r) => 'MFA verification failed'),
        ));
        return;
      }

      final authResult = result.fold((l) => throw Exception(l), (r) => r);
      _emitState(AuthenticationState.authenticated(user: authResult.user));
    } catch (e) {
      _emitState(state.copyWith(
        isLoading: false,
        errorMessage: 'MFA verification failed: ${e.toString()}',
      ));
    }
  }

  /// OAuth login
  Future<void> loginWithOAuth({
    required OAuthProvider provider,
    required String accessToken,
    String? deviceToken,
    String? deviceInfo,
  }) async {
    _emitState(const AuthenticationState.loading());

    try {
      final result = await _repository.loginWithOAuth(
        provider: provider,
        accessToken: accessToken,
        deviceToken: deviceToken,
        deviceInfo: deviceInfo,
      );

      if (result.isLeft()) {
        _emitState(AuthenticationState.error(
          message: result.fold((l) => l, (r) => 'OAuth login failed'),
        ));
        return;
      }

      final authResult = result.fold((l) => throw Exception(l), (r) => r);
      _emitState(AuthenticationState.authenticated(user: authResult.user));
    } catch (e) {
      _emitState(AuthenticationState.error(
        message: 'OAuth login failed: ${e.toString()}',
      ));
    }
  }

  /// Email verification
  Future<void> verifyEmail({
    required String email,
    required String verificationCode,
  }) async {
    _emitState(const AuthenticationState.loading());

    try {
      final result = await _repository.verifyEmail(
        email: email,
        verificationCode: verificationCode,
      );

      if (result.isLeft()) {
        _emitState(AuthenticationState.error(
          message: result.fold((l) => l, (r) => 'Email verification failed'),
        ));
        return;
      }

      final user = result.fold((l) => throw Exception(l), (r) => r);
      _emitState(AuthenticationState.authenticated(user: user));
    } catch (e) {
      _emitState(AuthenticationState.error(
        message: 'Email verification failed: ${e.toString()}',
      ));
    }
  }

  /// Phone verification
  Future<void> verifyPhone({
    required String phoneNumber,
    required String verificationCode,
  }) async {
    _emitState(const AuthenticationState.loading());

    try {
      final result = await _repository.verifyPhone(
        phoneNumber: phoneNumber,
        verificationCode: verificationCode,
      );

      if (result.isLeft()) {
        _emitState(AuthenticationState.error(
          message: result.fold((l) => l, (r) => 'Phone verification failed'),
        ));
        return;
      }

      final user = result.fold((l) => throw Exception(l), (r) => r);
      _emitState(AuthenticationState.authenticated(user: user));
    } catch (e) {
      _emitState(AuthenticationState.error(
        message: 'Phone verification failed: ${e.toString()}',
      ));
    }
  }

  /// Password reset request
  Future<void> requestPasswordReset({
    required String identifier,
    PasswordResetMethod method = PasswordResetMethod.email,
  }) async {
    _emitState(const AuthenticationState.loading());

    try {
      final result = await _repository.requestPasswordReset(
        identifier: identifier,
        method: method,
      );

      if (result.isLeft()) {
        _emitState(AuthenticationState.error(
          message: result.fold((l) => l, (r) => 'Password reset request failed'),
        ));
        return;
      }

      _emitState(const AuthenticationState.passwordResetSent());
    } catch (e) {
      _emitState(AuthenticationState.error(
        message: 'Password reset request failed: ${e.toString()}',
      ));
    }
  }

  /// Password reset
  Future<void> resetPassword({
    required String identifier,
    required String verificationCode,
    required String newPassword,
  }) async {
    _emitState(const AuthenticationState.loading());

    try {
      final result = await _repository.resetPassword(
        identifier: identifier,
        verificationCode: verificationCode,
        newPassword: newPassword,
      );

      if (result.isLeft()) {
        _emitState(AuthenticationState.error(
          message: result.fold((l) => l, (r) => 'Password reset failed'),
        ));
        return;
      }

      _emitState(const AuthenticationState.passwordResetSuccess());
    } catch (e) {
      _emitState(AuthenticationState.error(
        message: 'Password reset failed: ${e.toString()}',
      ));
    }
  }

  /// Change password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (_state.user == null) {
      _emitState(const AuthenticationState.error(
        message: 'No authenticated user',
      ));
      return;
    }

    _emitState(const AuthenticationState.loading());

    try {
      final result = await _repository.changePassword(
        userId: _state.user!.id,
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      if (result.isLeft()) {
        _emitState(AuthenticationState.error(
          message: result.fold((l) => l, (r) => 'Password change failed'),
        ));
        return;
      }

      _emitState(const AuthenticationState.passwordChanged());
    } catch (e) {
      _emitState(AuthenticationState.error(
        message: 'Password change failed: ${e.toString()}',
      ));
    }
  }

  /// Enable two-factor authentication
  Future<void> enableTwoFactor({
    required String verificationCode,
    required TwoFactorMethod method,
  }) async {
    if (_state.user == null) {
      _emitState(const AuthenticationState.error(
        message: 'No authenticated user',
      ));
      return;
    }

    _emitState(const AuthenticationState.loading());

    try {
      final result = await _repository.enableTwoFactor(
        userId: _state.user!.id,
        verificationCode: verificationCode,
        method: method,
      );

      if (result.isLeft()) {
        _emitState(AuthenticationState.error(
          message: result.fold((l) => l, (r) => 'Failed to enable two-factor authentication'),
        ));
        return;
      }

      // Refresh user data
      await initialize();
    } catch (e) {
      _emitState(AuthenticationState.error(
        message: 'Failed to enable two-factor authentication: ${e.toString()}',
      ));
    }
  }

  /// Disable two-factor authentication
  Future<void> disableTwoFactor({
    required String currentPassword,
    required String twoFactorCode,
  }) async {
    if (_state.user == null) {
      _emitState(const AuthenticationState.error(
        message: 'No authenticated user',
      ));
      return;
    }

    _emitState(const AuthenticationState.loading());

    try {
      final result = await _repository.disableTwoFactor(
        userId: _state.user!.id,
        currentPassword: currentPassword,
        twoFactorCode: twoFactorCode,
      );

      if (result.isLeft()) {
        _emitState(AuthenticationState.error(
          message: result.fold((l) => l, (r) => 'Failed to disable two-factor authentication'),
        ));
        return;
      }

      // Refresh user data
      await initialize();
    } catch (e) {
      _emitState(AuthenticationState.error(
        message: 'Failed to disable two-factor authentication: ${e.toString()}',
      ));
    }
  }

  /// Logout
  Future<void> logout({
    String? sessionId,
    bool logoutAllDevices = false,
  }) async {
    _emitState(const AuthenticationState.loading());

    try {
      final result = await _repository.logout(
        sessionId: sessionId,
        logoutAllDevices: logoutAllDevices,
      );

      if (result.isLeft()) {
        _emitState(AuthenticationState.error(
          message: result.fold((l) => l, (r) => 'Logout failed'),
        ));
        return;
      }

      _emitState(const AuthenticationState.unauthenticated());
    } catch (e) {
      _emitState(AuthenticationState.error(
        message: 'Logout failed: ${e.toString()}',
      ));
    }
  }

  /// Update user profile
  Future<void> updateProfile({
    String? firstName,
    String? lastName,
    String? middleName,
    String? phoneNumber,
    String? profileImageUrl,
    UserProfile? profile,
  }) async {
    if (_state.user == null) {
      _emitState(const AuthenticationState.error(
        message: 'No authenticated user',
      ));
      return;
    }

    _emitState(const AuthenticationState.loading());

    try {
      final result = await _repository.updateProfile(
        userId: _state.user!.id,
        firstName: firstName,
        lastName: lastName,
        middleName: middleName,
        phoneNumber: phoneNumber,
        profileImageUrl: profileImageUrl,
        profile: profile,
      );

      if (result.isLeft()) {
        _emitState(AuthenticationState.error(
          message: result.fold((l) => l, (r) => 'Profile update failed'),
        ));
        return;
      }

      final updatedUser = result.fold((l) => throw Exception(l), (r) => r);
      _emitState(AuthenticationState.authenticated(user: updatedUser));
    } catch (e) {
      _emitState(AuthenticationState.error(
        message: 'Profile update failed: ${e.toString()}',
      ));
    }
  }

  /// Check password strength
  Future<void> checkPasswordStrength(String password) async {
    try {
// final result = await _repository.checkPasswordStrength(password); // TODO: Move to environment variables
      
      if (result.isLeft()) {
        _emitState(AuthenticationState.error(
// message: result.fold((l) => l, (r) => 'Failed to check password strength'), // TODO: Move to environment variables
        ));
        return;
      }

      final strength = result.fold((l) => throw Exception(l), (r) => r);
      _emitState(AuthenticationState.passwordStrengthChecked(strength: strength));
    } catch (e) {
      _emitState(AuthenticationState.error(
        message: 'Password strength check failed: ${e.toString()}',
      ));
    }
  }

  /// Send email verification
  Future<void> sendEmailVerification(String email) async {
    try {
      final result = await _repository.sendEmailVerification(email);
      
      if (result.isLeft()) {
        _emitState(AuthenticationState.error(
          message: result.fold((l) => l, (r) => 'Failed to send email verification'),
        ));
        return;
      }

      _emitState(const AuthenticationState.emailVerificationSent());
    } catch (e) {
      _emitState(AuthenticationState.error(
        message: 'Email verification failed: ${e.toString()}',
      ));
    }
  }

  /// Check account lock status
  Future<void> checkAccountLockStatus(String identifier) async {
    try {
      final result = await _repository.checkAccountLockStatus(identifier);
      
      if (result.isLeft()) {
        _emitState(AuthenticationState.error(
          message: result.fold((l) => l, (r) => 'Failed to check account lock status'),
        ));
        return;
      }

      final lockStatus = result.fold((l) => throw Exception(l), (r) => r);
      _emitState(AuthenticationState.accountLockStatusChecked(lockStatus: lockStatus));
    } catch (e) {
      _emitState(AuthenticationState.error(
        message: 'Account lock status check failed: ${e.toString()}',
      ));
    }
  }

  /// Clear error state
  void clearError() {
    if (_state.isError) {
      _emitState(const AuthenticationState.unauthenticated());
    }
  }

  /// Clear success state
  void clearSuccess() {
    if (_state.isAuthenticated || _state.isRegistered) {
      _emitState(const AuthenticationState.unauthenticated());
    }
  }

  /// Reset to initial state
  void reset() {
    _emitState(const AuthenticationState.initial());
  }

  /// Emit new state
  void _emitState(AuthenticationState newState) {
    _state = newState;
    notifyListeners();
  }

  /// Get current user
  AuthUserEntity? get currentUser => _state.user;

  /// Check if user is authenticated
  bool get isAuthenticated => _state.isAuthenticated;

  /// Check if user is loading
  bool get isLoading => _state.isLoading;

  /// Check if there's an error
  bool get hasError => _state.isError;

  /// Get error message
  String? get errorMessage => _state.errorMessage;

  /// Check if two-factor is required
  bool get isTwoFactorRequired => _state.isTwoFactorRequired;

  /// Get auth result for two-factor
  AuthResult? get twoFactorAuthResult => _state.twoFactorAuthResult;

  /// Check if password reset was sent
  bool get isPasswordResetSent => _state.isPasswordResetSent;

  /// Check if password was reset successfully
  bool get isPasswordResetSuccess => _state.isPasswordResetSuccess;

  /// Check if password was changed
  bool get isPasswordChanged => _state.isPasswordChanged;

  /// Check if email verification was sent
  bool get isEmailVerificationSent => _state.isEmailVerificationSent;

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
