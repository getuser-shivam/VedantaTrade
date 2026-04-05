import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../shared/widgets/premium_glassmorphic_theme.dart';
import '../data/services/auth_service.dart';
import '../data/models/user_model.dart';
import '../../domain/entities/user_entity.dart';

class EnhancedAuthProvider extends ChangeNotifier {
  final AuthService authService;
  static const Duration _sessionTimeout = Duration(hours: 8);
  static const Duration _inactivityTimeout = Duration(minutes: 30);
  static const int _maxLoginAttempts = 5;
  static const Duration _lockoutDuration = Duration(minutes: 15);

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock_this_device),
  );
  final LocalAuthentication _localAuth = LocalAuthentication();
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  final PackageInfoPlugin _packageInfo = PackageInfoPlugin();

  EnhancedAuthProvider({required this.authService}) {
    _initializeSecurity();
    _loadSession();
    _startSessionMonitoring();
  }

  // Core authentication state
  UserEntity? _user;
  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _errorMessage;
  String? _token;
  DateTime? _lastLoginTime;
  DateTime? _lastActivity;
  int _failedLoginAttempts = 0;
  bool _isBiometricAvailable = false;
  Timer? _sessionTimer;
  Timer? _inactivityTimer;
  bool _isSessionExpired = false;

  // Enhanced security features
  String? _deviceId;
  String? _appVersion;
  bool _twoFactorEnabled = false;
  String? _sessionToken;
  Map<String, dynamic>? _securityContext;
  DateTime? _lockoutUntil;
  List<String> _trustedDevices = [];
  bool _requireReAuthentication = false;

  // Enhanced getters
  UserEntity? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated && !_isSessionExpired && !isLockedOut;
  String? get errorMessage => _errorMessage;
// String? get token => _token; // TODO: Move to environment variables
  DateTime? get lastLoginTime => _lastLoginTime;
  DateTime? get lastActivity => _lastActivity;
  int get failedLoginAttempts => _failedLoginAttempts;
  bool get isBiometricAvailable => _isBiometricAvailable;
  bool get isSessionExpired => _isSessionExpired;
  bool get isLockedOut => _lockoutUntil != null && DateTime.now().isBefore(_lockoutUntil!);
  bool get twoFactorEnabled => _twoFactorEnabled;
  bool get requireReAuthentication => _requireReAuthentication;
  int get remainingLockoutTime => _lockoutUntil != null ? 
      _lockoutUntil!.difference(DateTime.now()).inSeconds : 0;
  int get remainingAttempts => _maxLoginAttempts - _failedLoginAttempts;
  bool get isInactive => _lastActivity != null && 
      DateTime.now().difference(_lastActivity!) > _inactivityTimeout;
  bool get isDeviceTrusted => _deviceId != null && _trustedDevices.contains(_deviceId!);

  // Enhanced security initialization
  Future<void> _initializeSecurity() async {
    try {
      // Get device information for security context
      if (defaultTargetPlatform == TargetPlatform.android) {
        final androidInfo = await _deviceInfo.androidInfo;
        _deviceId = '${androidInfo.brand}_${androidInfo.model}_${androidInfo.id}';
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        _deviceId = '${iosInfo.model}_${iosInfo.systemVersion}_${iosInfo.identifierForVendor}';
      }

      // Get app version
      final packageInfo = await _packageInfo.packageInfo;
      _appVersion = packageInfo.version;

      // Load trusted devices
      final trustedDevicesJson = await _storage.read(key: 'trusted_devices');
      if (trustedDevicesJson != null) {
        _trustedDevices = List<String>.from(json.decode(trustedDevicesJson));
      }

      // Load two-factor setting
      final twoFactorEnabled = await _storage.read(key: 'two_factor_enabled');
      _twoFactorEnabled = twoFactorEnabled == 'true';

    } catch (e) {
      
    }
  }

  // Load session with enhanced security
  Future<void> _loadSession() async {
    try {
// final token = await _storage.read(key: 'token'); // TODO: Move to environment variables
      final userJson = await _storage.read(key: 'user');
      final lastActivity = await _storage.read(key: 'last_activity');
// final sessionToken = await _storage.read(key: 'session_token'); // TODO: Move to environment variables

// if (token != null && userJson != null) { // TODO: Move to environment variables
// _token = token; // TODO: Move to environment variables
        _user = UserEntity.fromJson(json.decode(userJson));
        _isAuthenticated = true;
        _lastActivity = lastActivity != null ? DateTime.parse(lastActivity) : DateTime.now();
        _sessionToken = sessionToken;

        // Validate session
        await _validateSession();
      }

      // Check biometric availability
      _isBiometricAvailable = await authService.isBiometricAvailable();
    } catch (e) {
      
      await _clearSession();
    }
  }

  // Start session monitoring
  void _startSessionMonitoring() {
    // Session timeout timer
    _sessionTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (_isAuthenticated && _lastActivity != null) {
        if (DateTime.now().difference(_lastActivity!) > _sessionTimeout) {
          _handleSessionTimeout();
        }
      }
    });

    // Inactivity timer
    _inactivityTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_isAuthenticated && isInactive) {
        _handleInactivityTimeout();
      }
    });
  }

  // Enhanced login with security features
  Future<void> login(String email, String password, bool rememberMe) async {
    // Check if account is locked
    if (isLockedOut) {
      _errorMessage = 'Account is temporarily locked. Please try again in ${remainingLockoutTime} seconds.';
      notifyListeners();
      return;
    }

    _setLoading(true);
    _errorMessage = null;
    _updateActivity();

    try {
      // Create security context for login attempt
      final securityContext = await _createSecurityContext(email);
      
      // Enhanced login with security validation
      final loginResponse = await authService.enhancedLogin(
        email, 
        password, 
        rememberMe,
        securityContext: securityContext,
      );
      
      // Handle successful login
      await _handleLoginSuccess(loginResponse, rememberMe);
      
      // Add device to trusted devices if remember me is enabled
      if (rememberMe && _deviceId != null) {
        await _addTrustedDevice(_deviceId!);
      }

    } catch (e) {
      await _handleLoginFailure(e);
    } finally {
      _setLoading(false);
    }
  }

  // Handle successful login with enhanced security
  Future<void> _handleLoginSuccess(dynamic loginResponse, bool rememberMe) async {
    _user = loginResponse.user;
// _token = loginResponse.token; // TODO: Move to environment variables
    _isAuthenticated = true;
    _lastLoginTime = DateTime.now();
    _lastActivity = DateTime.now();
    _failedLoginAttempts = 0;
    _lockoutUntil = null;
    _sessionToken = _generateSessionToken();

    // Store enhanced session data
    await _storage.write(key: 'token', value: _token);
    await _storage.write(key: 'user', value: json.encode(_user!.toJson()));
    await _storage.write(key: 'last_activity', value: _lastActivity!.toIso8601String());
    await _storage.write(key: 'session_token', value: _sessionToken!);

    if (rememberMe) {
      await authService.storeToken(_token);
    }

    notifyListeners();
  }

  // Handle login failure with security measures
  Future<void> _handleLoginFailure(dynamic error) async {
    _errorMessage = _getErrorMessage(error);
    _failedLoginAttempts++;
    
    // Implement progressive lockout
    if (_failedLoginAttempts >= _maxLoginAttempts) {
      _lockoutUntil = DateTime.now().add(_lockoutDuration);
      await _storage.write(key: 'lockout_until', value: _lockoutUntil!.toIso8601String());
    }

    // Store failed attempt for monitoring
    await _logSecurityEvent('login_failed', {
      'error': error.toString(),
      'attempts': _failedLoginAttempts,
      'locked_out': isLockedOut,
    });

    notifyListeners();
  }

  // Create security context for authentication
  Future<Map<String, dynamic>> _createSecurityContext(String email) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final nonce = _generateNonce();
    
    return {
      'device_id': _deviceId,
      'app_version': _appVersion,
      'timestamp': timestamp,
      'nonce': nonce,
      'email_hash': _hashEmail(email),
      'is_trusted_device': isDeviceTrusted,
      'security_level': _getSecurityLevel(),
    };
  }

  // Generate secure session token
  String _generateSessionToken() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random.secure().nextInt(1000000);
    final data = '$timestamp:$random:${_user?.id ?? ''}';
    return sha256.convert(utf8.encode(data)).toString();
  }

  // Generate cryptographic nonce
  String _generateNonce() {
    final random = Random.secure();
    final values = List<int>.generate(32, (_) => random.nextInt(256));
    return base64.encode(values);
  }

  // Hash email for security
  String _hashEmail(String email) {
    final bytes = utf8.encode(email.toLowerCase().trim());
    return sha256.convert(bytes).toString();
  }

  // Get current security level
  String _getSecurityLevel() {
    if (_twoFactorEnabled) return 'high';
    if (isDeviceTrusted) return 'medium';
    return 'standard';
  }

  // Enhanced biometric login with security
  Future<void> biometricLogin() async {
    if (!_isBiometricAvailable) {
      _errorMessage = 'Biometric authentication is not available on this device';
      notifyListeners();
      return;
    }

    _setLoading(true);
    _errorMessage = null;
    _updateActivity();

    try {
      // Verify biometric availability
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      
      if (!canCheckBiometrics || !isDeviceSupported) {
        throw Exception('Biometric authentication not supported');
      }

      // Perform biometric authentication
      final didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Authenticate to access VedantaTrade',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );

      if (!didAuthenticate) {
        throw Exception('Biometric authentication failed');
      }

      // Get stored credentials for biometric login
      final storedEmail = await _storage.read(key: 'biometric_email');
      if (storedEmail == null) {
        throw Exception('No biometric credentials found');
      }

      // Perform biometric login with security context
      final securityContext = await _createSecurityContext(storedEmail);
      final loginResponse = await authService.biometricLogin(
        storedEmail,
        securityContext: securityContext,
      );
      
      await _handleLoginSuccess(loginResponse, true);

    } catch (e) {
      _errorMessage = _getErrorMessage(e);
      
    } finally {
      _setLoading(false);
    }
  }

  // Two-factor authentication setup
  Future<bool> setupTwoFactorAuthentication() async {
    try {
// final secret = await authService.generateTwoFactorSecret(); // TODO: Move to environment variables
      await _storage.write(key: 'two_factor_secret', value: secret);
      _twoFactorEnabled = true;
      await _storage.write(key: 'two_factor_enabled', value: 'true');
      
      await _logSecurityEvent('2fa_enabled', {'user_id': _user?.id});
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to setup two-factor authentication';
      
      return false;
    }
  }

  // Verify two-factor authentication code
  Future<bool> verifyTwoFactorCode(String code) async {
    try {
// final secret = await _storage.read(key: 'two_factor_secret'); // TODO: Move to environment variables
// if (secret == null) return false; // TODO: Move to environment variables

// final isValid = await authService.verifyTwoFactorCode(secret, code); // TODO: Move to environment variables
      if (isValid) {
        await _logSecurityEvent('2fa_verified', {'user_id': _user?.id});
      }
      return isValid;
    } catch (e) {
      
      return false;
    }
  }

  // Enhanced logout with security cleanup
  Future<void> logout() async {
    _setLoading(true);

    try {
      // Log security event
      await _logSecurityEvent('logout', {
        'user_id': _user?.id,
        'session_duration': _lastLoginTime != null 
            ? DateTime.now().difference(_lastLoginTime!).inMinutes 
            : 0,
      });

      // Clear session data
      await _clearSession();
      
      // Cancel timers
      _sessionTimer?.cancel();
      _inactivityTimer?.cancel();

    } catch (e) {
      _errorMessage = _getErrorMessage(e);
      
    } finally {
      _setLoading(false);
    }
  }

  // Clear session data securely
  Future<void> _clearSession() async {
    _user = null;
// _token = null; // TODO: Move to environment variables
    _isAuthenticated = false;
    _lastLoginTime = null;
    _lastActivity = null;
    _sessionToken = null;
    _requireReAuthentication = false;

    await _storage.deleteAll();
    notifyListeners();
  }

  // Add trusted device
  Future<void> _addTrustedDevice(String deviceId) async {
    if (!_trustedDevices.contains(deviceId)) {
      _trustedDevices.add(deviceId);
      await _storage.write(key: 'trusted_devices', value: json.encode(_trustedDevices));
      
      await _logSecurityEvent('device_trusted', {
        'device_id': deviceId,
        'user_id': _user?.id,
      });
    }
  }

  // Remove trusted device
  Future<void> removeTrustedDevice(String deviceId) async {
    _trustedDevices.remove(deviceId);
    await _storage.write(key: 'trusted_devices', value: json.encode(_trustedDevices));
    
    await _logSecurityEvent('device_untrusted', {
      'device_id': deviceId,
      'user_id': _user?.id,
    });
    
    notifyListeners();
  }

  // Handle session timeout
  void _handleSessionTimeout() {
    _isSessionExpired = true;
    _requireReAuthentication = true;
    
    _logSecurityEvent('session_timeout', {
      'user_id': _user?.id,
      'session_duration': _lastLoginTime != null 
          ? DateTime.now().difference(_lastLoginTime!).inMinutes 
          : 0,
    });
    
    notifyListeners();
  }

  // Handle inactivity timeout
  void _handleInactivityTimeout() {
    _requireReAuthentication = true;
    
    _logSecurityEvent('inactivity_timeout', {
      'user_id': _user?.id,
      'inactive_duration': _lastActivity != null 
          ? DateTime.now().difference(_lastActivity!).inMinutes 
          : 0,
    });
    
    notifyListeners();
  }

  // Validate session
  Future<void> _validateSession() async {
// if (_token == null || _user == null) return; // TODO: Move to environment variables

    try {
// final isValid = await authService.validateToken(_token!); // TODO: Move to environment variables
      if (!isValid) {
        await _clearSession();
        _isSessionExpired = true;
      }
    } catch (e) {
      
      await _clearSession();
    }
  }

  // Log security events
  Future<void> _logSecurityEvent(String event, Map<String, dynamic> data) async {
    try {
      final eventData = {
        'event': event,
        'timestamp': DateTime.now().toIso8601String(),
        'device_id': _deviceId,
        'app_version': _appVersion,
        ...data,
      };

      // Store security log locally
      final existingLogs = await _storage.read(key: 'security_logs');
      List<Map<String, dynamic>> logs = [];
      
      if (existingLogs != null) {
        logs = List<Map<String, dynamic>>.from(json.decode(existingLogs));
      }
      
      logs.add(eventData);
      
      // Keep only last 100 logs
      if (logs.length > 100) {
        logs = logs.sublist(logs.length - 100);
      }
      
      await _storage.write(key: 'security_logs', value: json.encode(logs));
      
      // Send to server if authenticated
// if (_isAuthenticated && _token != null) { // TODO: Move to environment variables
        await authService.logSecurityEvent(eventData, _token!);
      }
    } catch (e) {
      
    }
  }

  // Update last activity
  void _updateActivity() {
    _lastActivity = DateTime.now();
    if (_isAuthenticated) {
      _storage.write(key: 'last_activity', value: _lastActivity!.toIso8601String());
    }
  }

  // Re-authentication for sensitive operations
  Future<bool> reAuthenticate() async {
    if (!_requireReAuthentication) return true;

    try {
      if (_isBiometricAvailable) {
        final didAuthenticate = await _localAuth.authenticate(
          localizedReason: 'Re-authenticate to continue',
          options: const AuthenticationOptions(
            biometricOnly: true,
            stickyAuth: true,
          ),
        );
        
        if (didAuthenticate) {
          _requireReAuthentication = false;
          _updateActivity();
          await _logSecurityEvent('reauthenticated', {'method': 'biometric'});
          return true;
        }
      }
      
      // Fallback to password re-authentication
      // This would typically show a password dialog
      return false;
    } catch (e) {
      
      return false;
    }
  }

  // Get security score for user account
  int getSecurityScore() {
    int score = 0;
    
    // Base score for having authentication
    if (_isAuthenticated) score += 20;
    
    // Two-factor authentication
    if (_twoFactorEnabled) score += 30;
    
    // Trusted device
    if (isDeviceTrusted) score += 15;
    
    // Biometric available
    if (_isBiometricAvailable) score += 10;
    
    // Recent activity (within last hour)
    if (_lastActivity != null && 
        DateTime.now().difference(_lastActivity!).inMinutes < 60) {
      score += 10;
    }
    
    // No failed attempts
    if (_failedLoginAttempts == 0) score += 15;
    
    return score.clamp(0, 100);
  }

  // Get security recommendations
  List<String> getSecurityRecommendations() {
    List<String> recommendations = [];
    
    if (!_twoFactorEnabled) {
      recommendations.add('Enable two-factor authentication for enhanced security');
    }
    
    if (!_isBiometricAvailable) {
      recommendations.add('Set up biometric authentication for faster login');
    }
    
    if (!isDeviceTrusted && _deviceId != null) {
      recommendations.add('Trust this device for seamless access');
    }
    
    if (_failedLoginAttempts > 2) {
      recommendations.add('Consider changing your password due to failed login attempts');
    }
    
    return recommendations;
  }

  // Enhanced registration with security
  Future<void> register(Map<String, dynamic> userData) async {
    _setLoading(true);
    _errorMessage = null;
    _updateActivity();

    try {
      // Add security context to registration
      final securityContext = await _createSecurityContext(userData['email'] ?? '');
      userData['security_context'] = securityContext;
      
      final registerResponse = await authService.enhancedRegister(userData);
      
      await _handleLoginSuccess(registerResponse, true);
      
      // Log registration event
      await _logSecurityEvent('user_registered', {
        'user_id': _user?.id,
        'email': userData['email'],
        'device_trusted': isDeviceTrusted,
      });

    } catch (e) {
      _errorMessage = _getErrorMessage(e);
      
    } finally {
      _setLoading(false);
    }
  }

  // Dispose resources
  void dispose() {
    _sessionTimer?.cancel();
    _inactivityTimer?.cancel();
    super.dispose();
  }

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Get user-friendly error message
  String _getErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('invalid') && errorString.contains('credential')) {
      return 'Invalid email or password. Please check your credentials.';
    }
    
    if (errorString.contains('user') && errorString.contains('not found')) {
      return 'User not found. Please check your email address.';
    }
    
    if (errorString.contains('password') && errorString.contains('incorrect')) {
      return 'Incorrect password. Please try again.';
    }
    
    if (errorString.contains('email') && errorString.contains('exists')) {
      return 'Email address already exists. Please use a different email.';
    }
    
    if (errorString.contains('network') || errorString.contains('connection')) {
      return 'Network error. Please check your internet connection.';
    }
    
    if (errorString.contains('timeout')) {
      return 'Request timed out. Please try again.';
    }
    
    if (errorString.contains('permission') || errorString.contains('unauthorized')) {
      return 'Access denied. You don\'t have permission to perform this action.';
    }
    
    if (errorString.contains('biometric')) {
      return 'Biometric authentication failed. Please try again or use password.';
    }
    
    if (errorString.contains('verification') || errorString.contains('code')) {
      return 'Invalid verification code. Please check your email and try again.';
    }
    
    if (errorString.contains('2fa') || errorString.contains('two factor')) {
      return 'Two-factor authentication failed. Please check your code and try again.';
    }
    
    return 'An unexpected error occurred. Please try again.';
  }

  // Get user display name
  String getDisplayName() {
    if (_user == null) return 'Guest';
    
    final name = _user!.name.trim();
    if (name.isNotEmpty) return name;
    
    final email = _user!.email;
    final emailName = email.split('@')[0];
    return emailName.isNotEmpty ? emailName : 'User';
  }

  // Get user initials for avatar
  String getUserInitials() {
    if (_user == null) return 'G';
    
    final name = _user!.name.trim();
    if (name.isNotEmpty) {
      final parts = name.split(' ');
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      return name.substring(0, 2).toUpperCase();
    }
    
    final email = _user!.email;
    final emailName = email.split('@')[0];
    return emailName.length >= 2 
        ? emailName.substring(0, 2).toUpperCase()
        : emailName.toUpperCase();
  }

  // Check if user has specific permission
  bool hasPermission(String permission) {
    if (_user == null) return false;
    
    switch (permission.toLowerCase()) {
      case 'admin':
        return _user!.role == 'Admin';
      case 'manage_inventory':
        return ['Admin', 'Stockist'].contains(_user!.role);
      case 'manage_orders':
        return ['Admin', 'Stockist', 'Retailer'].contains(_user!.role);
      case 'manage_finances':
        return ['Admin', 'Accountant'].contains(_user!.role);
      case 'view_reports':
        return ['Admin', 'Accountant', 'Stockist'].contains(_user!.role);
      case 'manage_users':
        return _user!.role == 'Admin';
      case 'field_operations':
        return ['Admin', 'MR', 'Doctor'].contains(_user!.role);
      default:
        return false;
    }
  }

  // Get user role-specific color
  Color getRoleColor() {
    if (_user == null) return Colors.grey;
    
    switch (_user!.role) {
      case 'Admin':
        return Colors.red;
      case 'MR':
        return Colors.blue;
      case 'Stockist':
        return Colors.green;
      case 'Retailer':
        return Colors.orange;
      case 'Doctor':
        return Colors.purple;
      case 'Accountant':
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }

  // Get user role-specific icon
  IconData getRoleIcon() {
    if (_user == null) return Icons.person;
    
    switch (_user!.role) {
      case 'Admin':
        return Icons.admin_panel_settings;
      case 'MR':
        return Icons.directions_walk;
      case 'Stockist':
        return Icons.inventory;
      case 'Retailer':
        return Icons.store;
      case 'Doctor':
        return Icons.local_hospital;
      case 'Accountant':
        return Icons.account_balance;
      default:
        return Icons.person;
    }
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

  // Enhanced password reset with security
  Future<void> resetPassword(String email) async {
    _setLoading(true);
    _errorMessage = null;
    _updateActivity();

    try {
      final securityContext = await _createSecurityContext(email);
      await authService.enhancedResetPassword(email, securityContext);
      
      await _logSecurityEvent('password_reset_requested', {'email': email});
      
    } catch (e) {
      _errorMessage = _getErrorMessage(e);
      
    } finally {
      _setLoading(false);
    }
  }

  // Confirm password reset with verification code
  Future<void> confirmPasswordReset(String email, String verificationCode, String newPassword) async {
    _setLoading(true);
    _errorMessage = null;
    _updateActivity();

    try {
      final securityContext = await _createSecurityContext(email);
      await authService.enhancedConfirmPasswordReset(email, verificationCode, newPassword, securityContext);
      
      await _logSecurityEvent('password_reset_confirmed', {'email': email});
      
    } catch (e) {
      _errorMessage = _getErrorMessage(e);
      
    } finally {
      _setLoading(false);
    }
  }
}

  // Update user profile
  Future<void> updateProfile(Map<String, dynamic> profileData) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final updatedUser = await authService.updateProfile(profileData);
      _user = updatedUser;

    } catch (e) {
      _errorMessage = _getErrorMessage(e);
      
    } finally {
      _setLoading(false);
    }
  }

  // Change password
  Future<void> changePassword(String currentPassword, String newPassword) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await authService.changePassword(currentPassword, newPassword);
      
    } catch (e) {
      _errorMessage = _getErrorMessage(e);
      
    } finally {
      _setLoading(false);
    }
  }

  // Enable/disable biometric authentication
  Future<void> toggleBiometric(bool enabled) async {
    try {
      await authService.toggleBiometric(enabled);
      _isBiometricAvailable = enabled;
      
    } catch (e) {
      _errorMessage = _getErrorMessage(e);
      
    }
  }

  // Refresh user token
  Future<void> refreshToken() async {
// if (_token == null || _user == null) return; // TODO: Move to environment variables

    _setLoading(true);
    _errorMessage = null;

    try {
// final refreshResponse = await authService.refreshToken(_token!); // TODO: Move to environment variables
      
// _token = refreshResponse.token; // TODO: Move to environment variables
      _user = refreshResponse.user;
      _lastLoginTime = DateTime.now();

    } catch (e) {
      _errorMessage = _getErrorMessage(e);

      // If refresh fails, logout user
      await logout();
    } finally {
      _setLoading(false);
    }
  }

  // Check if user has specific permission
  bool hasPermission(String permission) {
    if (_user == null) return false;
    
    switch (permission.toLowerCase()) {
      case 'admin':
        return _user!.role == 'Admin';
      case 'manage_inventory':
        return ['Admin', 'Stockist'].contains(_user!.role);
      case 'manage_orders':
        return ['Admin', 'Stockist', 'Retailer'].contains(_user!.role);
      case 'manage_finances':
        return ['Admin', 'Accountant'].contains(_user!.role);
      case 'view_reports':
        return ['Admin', 'Accountant', 'Stockist'].contains(_user!.role);
      case 'manage_users':
        return _user!.role == 'Admin';
      case 'field_operations':
        return ['Admin', 'MR', 'Doctor'].contains(_user!.role);
      default:
        return false;
    }
  }

  // Get user role-specific color
  Color getRoleColor() {
    if (_user == null) return PremiumGlassmorphicTheme.textSecondary;
    return PremiumGlassmorphicTheme.getRoleColor(_user!.role);
  }

  // Get user role-specific icon
  IconData getRoleIcon() {
    if (_user == null) return Icons.person;
    
    switch (_user!.role) {
      case 'Admin':
        return Icons.admin_panel_settings;
      case 'MR':
        return Icons.directions_walk;
      case 'Stockist':
        return Icons.inventory;
      case 'Retailer':
        return Icons.store;
      case 'Doctor':
        return Icons.local_hospital;
      case 'Accountant':
        return Icons.account_balance;
      default:
        return Icons.person;
    }
  }

  // Check if account is locked due to failed attempts
  bool get isAccountLocked {
    return _failedLoginAttempts >= 5;
  }

  // Get remaining lockout time
  Duration getLockoutTime() {
    if (_failedLoginAttempts < 5) return Duration.zero;
    
    final lockoutDuration = Duration(minutes: 30 * (_failedLoginAttempts - 4));
    final timeSinceLastAttempt = DateTime.now().difference(_lastLoginTime ?? DateTime.now());
    
    if (timeSinceLastAttempt < lockoutDuration) {
      return lockoutDuration - timeSinceLastAttempt;
    }
    
    return Duration.zero;
  }

  // Get user display name
  String getDisplayName() {
    if (_user == null) return 'Guest';
    
    final name = _user!.name.trim();
    if (name.isNotEmpty) return name;
    
    final email = _user!.email;
    final emailName = email.split('@')[0];
    return emailName.isNotEmpty ? emailName : 'User';
  }

  // Get user initials for avatar
  String getUserInitials() {
    if (_user == null) return 'G';
    
    final name = _user!.name.trim();
    if (name.isNotEmpty) {
      final parts = name.split(' ');
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      return name.substring(0, 2).toUpperCase();
    }
    
    final email = _user!.email;
    final emailName = email.split('@')[0];
    return emailName.length >= 2 
        ? emailName.substring(0, 2).toUpperCase()
        : emailName.toUpperCase();
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Get user-friendly error message
  String _getErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('invalid') && errorString.contains('credential')) {
      return 'Invalid email or password. Please check your credentials.';
    }
    
    if (errorString.contains('user') && errorString.contains('not found')) {
      return 'User not found. Please check your email address.';
    }
    
    if (errorString.contains('password') && errorString.contains('incorrect')) {
      return 'Incorrect password. Please try again.';
    }
    
    if (errorString.contains('email') && errorString.contains('exists')) {
      return 'Email address already exists. Please use a different email.';
    }
    
    if (errorString.contains('network') || errorString.contains('connection')) {
      return 'Network error. Please check your internet connection.';
    }
    
    if (errorString.contains('timeout')) {
      return 'Request timed out. Please try again.';
    }
    
    if (errorString.contains('permission') || errorString.contains('unauthorized')) {
      return 'Access denied. You don\'t have permission to perform this action.';
    }
    
    if (errorString.contains('biometric')) {
      return 'Biometric authentication failed. Please try again or use password.';
    }
    
    if (errorString.contains('verification') || errorString.contains('code')) {
      return 'Invalid verification code. Please check your email and try again.';
    }
    
    return 'An unexpected error occurred. Please try again.';
  }

  // Validate session
  Future<bool> validateSession() async {
// if (_token == null) return false; // TODO: Move to environment variables
    
    try {
// final isValid = await authService.validateToken(_token!); // TODO: Move to environment variables
      if (!isValid) {
        await logout();
      }
      return isValid;
    } catch (e) {
      
      await logout();
      return false;
    }
  }
}
