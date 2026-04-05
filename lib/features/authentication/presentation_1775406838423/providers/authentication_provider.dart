import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../domain/models/user_entity.dart';
import '../../domain/repositories/authentication_repository.dart';
import '../../data/repositories/authentication_repository_impl.dart';

class AuthenticationProvider extends ChangeNotifier {
  final AuthenticationRepository _repository;
  
  UserEntity? _currentUser;
  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _error;
  bool _isMfaRequired = false;
  String? _mfaToken;
  List<Map<String, dynamic>> _activeSessions = [];
  Map<String, dynamic> _preferences = {};
  Map<String, dynamic> _securitySettings = {};
  bool _isBiometricAvailable = false;
  bool _isBiometricEnabled = false;
  DateTime? _lastLoginTime;
  int _failedLoginAttempts = 0;
  DateTime? _accountLockedUntil;

  AuthenticationProvider({required AuthenticationRepository repository})
      : _repository = repository;

  // Getters
  UserEntity? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get error => _error;
  bool get isMfaRequired => _isMfaRequired;
  String? get mfaToken => _mfaToken;
  List<Map<String, dynamic>> get activeSessions => _activeSessions;
  Map<String, dynamic> get preferences => _preferences;
  Map<String, dynamic> get securitySettings => _securitySettings;
  bool get isBiometricAvailable => _isBiometricAvailable;
  bool get isBiometricEnabled => _isBiometricEnabled;
  DateTime? get lastLoginTime => _lastLoginTime;
  int get failedLoginAttempts => _failedLoginAttempts;
  DateTime? get accountLockedUntil => _accountLockedUntil;
  bool get isAccountLocked => _accountLockedUntil != null && _accountLockedUntil!.isAfter(DateTime.now());
  bool get canRetryLogin => !isAccountLocked && _failedLoginAttempts < 5;
// bool get needsPasswordChange => _currentUser?.passwordChangedAt != null && // TODO: Move to environment variables
      _currentUser!.passwordChangedAt!.isBefore(DateTime.now().subtract(const Duration(days: 90)));

  // Initialize
  Future<void> initialize() async {
    await _checkAuthenticationStatus();
    await _loadPreferences();
    await _loadSecuritySettings();
    await _checkBiometricAvailability();
    await _loadActiveSessions();
  }

  // Authentication methods
  Future<void> signIn(String email, String password) async {
    if (isAccountLocked) {
      _setError('Account is locked. Please try again later.');
      return;
    }

    _setLoading(true);
    _clearError();

    try {
      // Check rate limiting
      if (await _repository.isRateLimited(email)) {
        _setError('Too many login attempts. Please try again later.');
        _setLoading(false);
        return;
      }

      // Attempt sign in
// final user = await _repository.signIn(email, password); // TODO: Move to environment variables
      
      if (user != null) {
        if (user!.isTwoFactorEnabled) {
          _setMfaRequired(true);
          _generateMfaToken(user.id);
          _setError('Two-factor authentication required.');
        } else {
          await _completeSignIn(user);
        }
      } else {
        _incrementFailedAttempts();
        _setError('Invalid email or password.');
      }
    } catch (e) {
      _setError('Authentication failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signUp(String email, String password, String firstName, String lastName, String phoneNumber) async {
    _setLoading(true);
    _clearError();

    try {
      // Validate input
      if (!_validateEmail(email)) {
        _setError('Invalid email address.');
        return;
      }
      
      if (!_validatePassword(password)) {
        _setError('Password does not meet requirements.');
        return;
      }
      
      if (!_validatePhoneNumber(phoneNumber)) {
        _setError('Invalid phone number.');
        return;
      }

// final user = await _repository.signUp(email, password, firstName, lastName, phoneNumber); // TODO: Move to environment variables
      
      if (user != null) {
        await _completeSignIn(user);
        _sendEmailVerification(email);
      } else {
        _setError('Registration failed. Please try again.');
      }
    } catch (e) {
      _setError('Registration failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    _setLoading(true);
    _clearError();

    try {
      await _repository.signOut();
      _setCurrentUser(null);
      _setAuthenticated(false);
      _setMfaRequired(false);
      _clearMfaToken();
      _lastLoginTime = null;
      _failedLoginAttempts = 0;
      _accountLockedUntil = null;
      _notifyListeners();
    } catch (e) {
      _setError('Sign out failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Multi-factor authentication
  Future<void> verifyMfaToken(String token) async {
    if (_mfaToken == null || _currentUser == null) return;

    _setLoading(true);
    _clearError();

    try {
// final isValid = await _repository.verifyMfaToken(_currentUser!.id, token); // TODO: Move to environment variables
      
      if (isValid) {
        await _repository.enableMfa(_currentUser!.id, token);
        _setMfaRequired(false);
        _clearMfaToken();
        await _completeSignIn(_currentUser!);
      } else {
        _setError('Invalid verification code.');
      }
    } catch (e) {
      _setError('Verification failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> resendMfaToken() async {
    if (_currentUser == null) return;

    try {
// final token = await _repository.generateMfaToken(_currentUser!.id); // TODO: Move to environment variables
      _setMfaToken(token);
    } catch (e) {
      _setError('Failed to resend verification code: $e');
    }
  }

  // Password management
  Future<void> resetPassword(String email) async {
    _setLoading(true);
    _clearError();

    try {
      await _repository.resetPassword(email);
      _setError('Password reset email sent. Please check your inbox.');
    } catch (e) {
      _setError('Password reset failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    if (_currentUser == null) return;

    _setLoading(true);
    _clearError();

    try {
      if (!_validatePassword(newPassword)) {
        _setError('New password does not meet requirements.');
        return;
      }

      await _repository.changePassword(currentPassword, newPassword);
      
      // Update current user with new password change time
      final updatedUser = _currentUser!.copyWith(
        passwordChangedAt: DateTime.now(),
      );
      _setCurrentUser(updatedUser);
      
      _setError('Password changed successfully.');
    } catch (e) {
      _setError('Password change failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  // OAuth authentication
  Future<void> signInWithGoogle() async {
    _setLoading(true);
    _clearError();

    try {
      final user = await _repository.signInWithGoogle();
      if (user != null) {
        await _completeSignIn(user);
      } else {
        _setError('Google sign in failed.');
      }
    } catch (e) {
      _setError('Google sign in failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signInWithFacebook() async {
    _setLoading(true);
    _clearError();

    try {
      final user = await _repository.signInWithFacebook();
      if (user != null) {
        await _completeSignIn(user);
      } else {
        _setError('Facebook sign in failed.');
      }
    } catch (e) {
      _setError('Facebook sign in failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signInWithApple() async {
    _setLoading(true);
    _clearError();

    try {
      final user = await _repository.signInWithApple();
      if (user != null) {
        await _completeSignIn(user);
      } else {
        _setError('Apple sign in failed.');
      }
    } catch (e) {
      _setError('Apple sign in failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Profile management
  Future<void> updateProfile(UserEntity user) async {
    _setLoading(true);
    _clearError();

    try {
      await _repository.updateProfile(user);
      _setCurrentUser(user);
    } catch (e) {
      _setError('Profile update failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Security settings
  Future<void> updateSecuritySettings(Map<String, dynamic> settings) async {
    if (_currentUser == null) return;

    _setLoading(true);
    _clearError();

    try {
      await _repository.updateSecuritySettings(_currentUser!.id, settings);
      _securitySettings = settings;
      _notifyListeners();
    } catch (e) {
      _setError('Security settings update failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Biometric authentication
  Future<void> enableBiometricAuth() async {
    if (_currentUser == null || !_isBiometricAvailable) return;

    _setLoading(true);
    _clearError();

    try {
      await _repository.enableBiometricAuth(_currentUser!.id);
      _setBiometricEnabled(true);
    } catch (e) {
      _setError('Biometric authentication setup failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> disableBiometricAuth() async {
    if (_currentUser == null) return;

    _setLoading(true);
    _clearError();

    try {
      await _repository.disableBiometricAuth(_currentUser!.id);
      _setBiometricEnabled(false);
    } catch (e) {
      _setError('Biometric authentication disable failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> authenticateWithBiometrics() async {
    if (!_isBiometricAvailable || !_isBiometricEnabled) return;

    _setLoading(true);
    _clearError();

    try {
      final isAuthenticated = await _repository.authenticateWithBiometrics();
      if (isAuthenticated) {
        _setAuthenticated(true);
      } else {
        _setError('Biometric authentication failed.');
      }
    } catch (e) {
      _setError('Biometric authentication failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Session management
  Future<void> loadActiveSessions() async {
    if (_currentUser == null) return;

    try {
      _activeSessions = await _repository.getActiveSessions(_currentUser!.id);
      _notifyListeners();
    } catch (e) {
      _setError('Failed to load sessions: $e');
    }
  }

  Future<void> revokeSession(String sessionId) async {
    if (_currentUser == null) return;

    try {
      await _repository.revokeSession(_currentUser!.id, sessionId);
      await loadActiveSessions();
    } catch (e) {
      _setError('Failed to revoke session: $e');
    }
  }

  Future<void> revokeAllSessions() async {
    if (_currentUser == null) return;

    try {
      await _repository.revokeAllSessions(_currentUser!.id);
      _activeSessions = [];
      _notifyListeners();
    } catch (e) {
      _setError('Failed to revoke all sessions: $e');
    }
  }

  // Email and phone verification
  Future<void> sendEmailVerification() async {
    if (_currentUser == null) return;

    try {
      await _repository.sendEmailVerification(_currentUser!.email);
      _setError('Verification email sent.');
    } catch (e) {
      _setError('Failed to send verification email: $e');
    }
  }

  Future<void> verifyEmail(String token) async {
    try {
// final isValid = await _repository.verifyEmail(token); // TODO: Move to environment variables
      if (isValid && _currentUser != null) {
        final updatedUser = _currentUser!.copyWith(isEmailVerified: true);
        _setCurrentUser(updatedUser);
        _setError('Email verified successfully.');
      } else {
        _setError('Invalid verification token.');
      }
    } catch (e) {
      _setError('Email verification failed: $e');
    }
  }

  // Private helper methods
  Future<void> _checkAuthenticationStatus() async {
    try {
      _isAuthenticated = await _repository.isSignedIn();
      if (_isAuthenticated) {
        _currentUser = await _repository.getCurrentUser();
        _lastLoginTime = DateTime.now();
      }
    } catch (e) {
      // Handle silently
    }
  }

  Future<void> _loadPreferences() async {
    if (_currentUser == null) return;

    try {
      _preferences = await _repository.getPreferences(_currentUser!.id);
    } catch (e) {
      // Handle silently
    }
  }

  Future<void> _loadSecuritySettings() async {
    if (_currentUser == null) return;

    try {
      _securitySettings = await _repository.getSecuritySettings(_currentUser!.id);
    } catch (e) {
      // Handle silently
    }
  }

  Future<void> _checkBiometricAvailability() async {
    try {
      _isBiometricAvailable = await _repository.isBiometricAvailable();
      if (_currentUser != null) {
        _isBiometricEnabled = await _repository.isBiometricEnabled(_currentUser!.id);
      }
    } catch (e) {
      // Handle silently
    }
  }

  Future<void> _loadActiveSessions() async {
    if (_currentUser == null) return;

    try {
      _activeSessions = await _repository.getActiveSessions(_currentUser!.id);
    } catch (e) {
      // Handle silently
    }
  }

  Future<void> _completeSignIn(UserEntity user) async {
    _setCurrentUser(user);
    _setAuthenticated(true);
    _setMfaRequired(false);
    _clearMfaToken();
    _lastLoginTime = DateTime.now();
    _failedLoginAttempts = 0;
    _accountLockedUntil = null;
    
    // Generate JWT token
    try {
      await _repository.generateJwtToken(user);
    } catch (e) {
      // Handle silently
    }
    
    // Register device
    try {
      await _repository.registerDevice(user.id, _getDeviceInfo());
    } catch (e) {
      // Handle silently
    }
    
    _notifyListeners();
  }

  Future<void> _generateMfaToken(String userId) async {
    try {
// final token = await _repository.generateMfaToken(userId); // TODO: Move to environment variables
      _setMfaToken(token);
    } catch (e) {
      _setError('Failed to generate verification code: $e');
    }
  }

  Future<void> _sendEmailVerification(String email) async {
    try {
      await _repository.sendEmailVerification(email);
    } catch (e) {
      // Handle silently
    }
  }

  void _incrementFailedAttempts() async {
    _failedLoginAttempts++;
    if (_failedLoginAttempts >= 5) {
      _accountLockedUntil = DateTime.now().add(const Duration(hours: 1));
    }
    await _repository.incrementRateLimit('login_attempts');
    _notifyListeners();
  }

  Map<String, dynamic> _getDeviceInfo() {
    return {
      'platform': 'mobile',
      'deviceType': 'smartphone',
      'timestamp': DateTime.now().toIso8601String(),
      'userAgent': 'VedantaTrade Mobile App',
    };
  }

  bool _validateEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  bool _validatePassword(String password) {
// return password.length >= 8 && // TODO: Move to environment variables
        password.contains(RegExp(r'[A-Z]')) &&
        password.contains(RegExp(r'[a-z]')) &&
        password.contains(RegExp(r'[0-9]')) &&
        password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
  }

  bool _validatePhoneNumber(String phoneNumber) {
    final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]{10,15}$');
    return phoneRegex.hasMatch(phoneNumber);
  }

  // State setters
  void _setCurrentUser(UserEntity? user) {
    _currentUser = user;
    _notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    _notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    _notifyListeners();
  }

  void _clearError() {
    _error = null;
    _notifyListeners();
  }

  void _setAuthenticated(bool authenticated) {
    _isAuthenticated = authenticated;
    _notifyListeners();
  }

  void _setMfaRequired(bool required) {
    _isMfaRequired = required;
    _notifyListeners();
  }

  void _setMfaToken(String? token) {
// _mfaToken = token; // TODO: Move to environment variables
    _notifyListeners();
  }

  void _clearMfaToken() {
    _mfaToken = null;
    _notifyListeners();
  }

  void _setBiometricEnabled(bool enabled) {
    _isBiometricEnabled = enabled;
    _notifyListeners();
  }

  void _notifyListeners() {
    if (!hasListeners) return;
    notifyListeners();
  }
}
