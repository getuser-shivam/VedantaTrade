import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/auth_user_entity.dart';
import '../../domain/repositories/authentication_repository.dart';
import '../states/authentication_state.dart';
import '../events/authentication_event.dart';
import '../../data/services/jwt_service.dart';
import '../../data/services/oauth_service.dart';
import '../../data/services/account_security_service.dart';
import '../../data/services/mfa_service.dart';

/// Enhanced Authentication Provider
/// Manages authentication state with comprehensive security features
class EnhancedAuthenticationProvider extends ChangeNotifier {
  final AuthenticationRepository _repository;
  final JWTService _jwtService = JWTService();
  final OAuthService _oauthService = OAuthService();
  final AccountSecurityService _securityService = AccountSecurityService();
  final MFAService _mfaService = MFAService();
  
  AuthenticationState _state = const AuthenticationState.initial();
  StreamSubscription? _authSubscription;
  Timer? _tokenRefreshTimer;
  Timer? _sessionCheckTimer;
  
  EnhancedAuthenticationProvider({
    required AuthenticationRepository repository,
  }) : _repository = repository;

  /// Current authentication state
  AuthenticationState get state => _state;

  /// Getters for convenience
  bool get isLoading => _state.isLoading;
  bool get isAuthenticated => _state.isAuthenticated;
  bool get isUnauthenticated => _state.isUnauthenticated;
  bool get hasError => _state.hasError;
  AuthUserEntity? get user => _state.user;
  String? get error => _state.error;

  /// Initialize authentication provider
  Future<void> initialize() async {
    _emitState(const AuthenticationState.loading());
    
    try {
      // Check if we have valid tokens
      final hasValidToken = await _jwtService.isAccessTokenValid();
      
      if (hasValidToken) {
        // Get user from token
        final tokenInfo = await _jwtService.getUserFromToken();
        if (tokenInfo != null) {
          final userId = tokenInfo['userId'];
          
          // Get full user data
          final userResult = await _repository.getCurrentUser();
          if (userResult.isRight()) {
            final user = userResult.fold((l) => throw Exception(l), (r) => r);
            _emitState(AuthenticationState.authenticated(user: user));
            
            // Start token refresh timer
            _startTokenRefreshTimer();
            _startSessionCheckTimer();
            return;
          }
        }
      }
      
      // No valid session
      _emitState(const AuthenticationState.unauthenticated());
    } catch (e) {
      _emitState(AuthenticationState.error(
        message: 'Failed to initialize authentication: ${e.toString()}',
      ));
    }
  }

  /// Enhanced user registration with security checks
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
      // Check rate limiting
      final rateLimit = await _securityService.checkRateLimit(email, 'register');
      if (rateLimit.isLimited) {
        _emitState(AuthenticationState.error(
          message: 'Too many registration attempts. Please try again later.',
        ));
        return;
      }

      // Check password strength
      final passwordStrength = _securityService.checkPasswordStrength(password);
      if (passwordStrength.level.index < PasswordStrengthLevel.fair.index) {
        _emitState(AuthenticationState.error(
          message: 'Password is too weak. Please choose a stronger password.',
        ));
        return;
      }

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

  /// Enhanced user login with security features
  Future<void> loginUser({
    required String identifier,
    required String password,
    bool rememberMe = false,
    String? deviceToken,
    String? deviceInfo,
  }) async {
    _emitState(const AuthenticationState.loading());

    try {
      // Check account lock status
      final lockStatus = await _securityService.checkAccountLockStatus(identifier);
      if (lockStatus.isLocked) {
        _emitState(AuthenticationState.error(
          message: 'Account is locked. ${lockStatus.lockReason ?? 'Please try again later.'}',
        ));
        return;
      }

      // Check rate limiting
      final rateLimit = await _securityService.checkRateLimit(identifier, 'login');
      if (rateLimit.isLimited) {
        _emitState(AuthenticationState.error(
          message: 'Too many login attempts. Please try again later.',
        ));
        return;
      }

      final result = await _repository.loginUser(
        identifier: identifier,
        password: password,
        rememberMe: rememberMe,
        deviceToken: deviceToken,
        deviceInfo: deviceInfo,
      );

      if (result.isLeft()) {
        // Record failed attempt
        await _securityService.recordFailedAttempt(identifier);
        
        _emitState(AuthenticationState.error(
          message: result.fold((l) => l, (r) => 'Login failed'),
        ));
        return;
      }

      final authResult = result.fold((l) => throw Exception(l), (r) => r);

      // Check if MFA is required
      if (authResult.requiresTwoFactor) {
        _emitState(AuthenticationState.mfaRequired(
          user: authResult.user,
          mfaToken: authResult.accessToken, // Use as MFA token
        ));
        return;
      }

      // Successful login
      await _jwtService.storeTokens(
        accessToken: authResult.accessToken,
        refreshToken: authResult.refreshToken,
        userId: authResult.user.id,
        expiresAt: authResult.expiresAt,
      );

      // Record successful attempt
      await _securityService.recordSuccessfulAttempt(identifier);

      _emitState(AuthenticationState.authenticated(user: authResult.user));
      
      // Start timers
      _startTokenRefreshTimer();
      _startSessionCheckTimer();
    } catch (e) {
      _emitState(AuthenticationState.error(
        message: 'Login failed: ${e.toString()}',
      ));
    }
  }

  /// OAuth login
  Future<void> loginWithOAuth(OAuthProvider provider) async {
    _emitState(const AuthenticationState.loading());

    try {
      final result = await _oauthService.initiateOAuth(provider);
      
      if (!result.success) {
        _emitState(AuthenticationState.error(
          message: result.error ?? 'OAuth login failed',
        ));
        return;
      }

      // OAuth requires redirect - state will be handled by callback
      _emitState(AuthenticationState.oauthPending(
        provider: provider,
        state: result.state,
      ));
    } catch (e) {
      _emitState(AuthenticationState.error(
        message: 'OAuth login failed: ${e.toString()}',
      ));
    }
  }

  /// Handle OAuth callback
  Future<void> handleOAuthCallback(Map<String, String> params) async {
    _emitState(const AuthenticationState.loading());

    try {
      final result = await _oauthService.handleOAuthCallback(params);
      
      if (!result.success) {
        _emitState(AuthenticationState.error(
          message: result.error ?? 'OAuth callback failed',
        ));
        return;
      }

      // Store tokens
      if (result.accessToken != null && result.user != null) {
        await _jwtService.storeTokens(
          accessToken: result.accessToken!,
          refreshToken: result.refreshToken ?? '',
          userId: result.user!.id,
          expiresAt: result.expiresAt ?? DateTime.now().add(const Duration(hours: 1)),
        );

        _emitState(AuthenticationState.authenticated(user: result.user!));
        
        // Start timers
        _startTokenRefreshTimer();
        _startSessionCheckTimer();
      }
    } catch (e) {
      _emitState(AuthenticationState.error(
        message: 'OAuth callback failed: ${e.toString()}',
      ));
    }
  }

  /// Verify MFA code
  Future<void> verifyMFACode({
    required String mfaToken,
    required String verificationCode,
  }) async {
    _emitState(const AuthenticationState.loading());

    try {
      final result = await _mfaService.verifyMFACode(
        mfaToken: mfaToken,
        verificationCode: verificationCode,
      );

      if (!result.success) {
        _emitState(AuthenticationState.error(
          message: result.error ?? 'Invalid verification code',
        ));
        return;
      }

      // Store tokens from MFA verification
      if (result.accessToken != null && result.user != null) {
        await _jwtService.storeTokens(
          accessToken: result.accessToken!,
          refreshToken: result.refreshToken ?? '',
          userId: result.user!.id,
          expiresAt: result.expiresAt ?? DateTime.now().add(const Duration(hours: 1)),
        );

        _emitState(AuthenticationState.authenticated(user: result.user!));
        
        // Start timers
        _startTokenRefreshTimer();
        _startSessionCheckTimer();
      }
    } catch (e) {
      _emitState(AuthenticationState.error(
        message: 'MFA verification failed: ${e.toString()}',
      ));
    }
  }

  /// Setup MFA
  Future<void> setupMFA(String userId) async {
    _emitState(const AuthenticationState.loading());

    try {
      final result = await _mfaService.generateMFASecret(userId);
      
      if (!result.success) {
        _emitState(AuthenticationState.error(
          message: result.error ?? 'Failed to setup MFA',
        ));
        return;
      }

      _emitState(AuthenticationState.mfaSetup(
        secret: result.secret!,
        qrCode: result.qrCode!,
        backupCodes: result.backupCodes ?? [],
      ));
    } catch (e) {
      _emitState(AuthenticationState.error(
        message: 'MFA setup failed: ${e.toString()}',
      ));
    }
  }

  /// Enable MFA
  Future<void> enableMFA({
    required String userId,
    required String verificationCode,
    TwoFactorMethod method = TwoFactorMethod.authenticatorApp,
  }) async {
    _emitState(const AuthenticationState.loading());

    try {
      final result = await _mfaService.enableMFA(
        userId: userId,
        verificationCode: verificationCode,
        method: method,
      );

      if (!result.success) {
        _emitState(AuthenticationState.error(
          message: result.error ?? 'Failed to enable MFA',
        ));
        return;
      }

      // Refresh user data
      await refreshUserData();
      _emitState(AuthenticationState.mfaEnabled());
    } catch (e) {
      _emitState(AuthenticationState.error(
        message: 'Failed to enable MFA: ${e.toString()}',
      ));
    }
  }

  /// Password reset
  Future<void> resetPassword({
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
          message: result.fold((l) => l, (r) => 'Password reset failed'),
        ));
        return;
      }

      _emitState(AuthenticationState.passwordResetSent());
    } catch (e) {
      _emitState(AuthenticationState.error(
        message: 'Password reset failed: ${e.toString()}',
      ));
    }
  }

  /// Logout
  Future<void> logout({bool logoutAllDevices = false}) async {
    _emitState(const AuthenticationState.loading());

    try {
      // Call server logout
      final token = await _jwtService.getAccessToken();
      if (token != null) {
        await _repository.logout(
          sessionId: null,
          logoutAllDevices: logoutAllDevices,
        );
      }

      // Clear local tokens
      await _jwtService.clearTokens();

      // Stop timers
      _stopTimers();

      _emitState(const AuthenticationState.unauthenticated());
    } catch (e) {
      // Even if server logout fails, clear local state
      await _jwtService.clearTokens();
      _stopTimers();
      _emitState(const AuthenticationState.unauthenticated());
    }
  }

  /// Refresh user data
  Future<void> refreshUserData() async {
    try {
      final result = await _repository.getCurrentUser();
      if (result.isRight()) {
        final user = result.fold((l) => throw Exception(l), (r) => r);
        
        if (_state.isAuthenticated) {
          _emitState(AuthenticationState.authenticated(user: user));
        }
      }
    } catch (e) {
      // Don't emit error for refresh failures
    }
  }

  /// Check if user has permission
  Future<bool> hasPermission(String permission) async {
    return await _jwtService.hasPermission(permission);
  }

  /// Check if user has role
  Future<bool> hasRole(String role) async {
    return await _jwtService.hasRole(role);
  }

  /// Get available OAuth providers
  Future<List<OAuthProvider>> getAvailableOAuthProviders() async {
    return await _oauthService.getAvailableProviders();
  }

  /// Get security recommendations
  Future<List<SecurityRecommendation>> getSecurityRecommendations() async {
    if (!isAuthenticated || user == null) return [];
    return await _securityService.getSecurityRecommendations(user!.id);
  }

  /// Get security audit log
  Future<List<SecurityAuditEntry>> getSecurityAuditLog() async {
    if (!isAuthenticated || user == null) return [];
    return await _securityService.getSecurityAuditLog(userId: user!.id);
  }

  /// Generate backup codes
  Future<List<String>?> generateBackupCodes() async {
    if (!isAuthenticated || user == null) return null;
    return await _securityService.generateBackupCodes(user!.id);
  }

  /// Check password strength
  PasswordStrength checkPasswordStrength(String password) {
    return _securityService.checkPasswordStrength(password);
  }

  /// Start token refresh timer
  void _startTokenRefreshTimer() {
    _stopTokenRefreshTimer();
    
    _tokenRefreshTimer = Timer.periodic(const Duration(minutes: 5), (timer) async {
      final shouldRefresh = await _jwtService.shouldRefreshToken();
      if (shouldRefresh) {
        await _refreshToken();
      }
    });
  }

  /// Start session check timer
  void _startSessionCheckTimer() {
    _stopSessionCheckTimer();
    
    _sessionCheckTimer = Timer.periodic(const Duration(minutes: 10), (timer) async {
      final isValid = await _jwtService.validateTokenWithServer();
      if (!isValid && isAuthenticated) {
        await logout();
      }
    });
  }

  /// Refresh token
  Future<void> _refreshToken() async {
    try {
      final result = await _jwtService.refreshAccessToken();
      if (result != null && result['success'] == true) {
        // Token refreshed successfully
        return;
      }
      
      // Token refresh failed, logout
      await logout();
    } catch (e) {
      await logout();
    }
  }

  /// Stop all timers
  void _stopTimers() {
    _stopTokenRefreshTimer();
    _stopSessionCheckTimer();
  }

  /// Stop token refresh timer
  void _stopTokenRefreshTimer() {
    _tokenRefreshTimer?.cancel();
    _tokenRefreshTimer = null;
  }

  /// Stop session check timer
  void _stopSessionCheckTimer() {
    _sessionCheckTimer?.cancel();
    _sessionCheckTimer = null;
  }

  /// Emit new state
  void _emitState(AuthenticationState newState) {
    _state = newState;
    notifyListeners();
  }

  @override
  void dispose() {
    _stopTimers();
    _authSubscription?.cancel();
    super.dispose();
  }
}
