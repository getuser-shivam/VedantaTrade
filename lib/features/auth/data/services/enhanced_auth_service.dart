import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:convert';
import 'dart:math';
import 'dart:async';
import '../../../shared/widgets/premium_glassmorphic_theme.dart';
import '../models/user_model.dart';
import '../../domain/entities/user_entity.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'auth_user';
  static const String _biometricKey = 'biometric_enabled';
  static const String _sessionTokenKey = 'session_token';
  static const String _deviceIdKey = 'device_id';
  static const String _trustedDevicesKey = 'trusted_devices';
  static const String _securityLogsKey = 'security_logs';
  static const String _baseUrl = 'https://api.vedantatrade.com/v1'; // TODO: Use actual API URL

  late final Dio _dio;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock_this_device),
  );
  final LocalAuthentication _localAuth = LocalAuthentication();
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  final PackageInfoPlugin _packageInfo = PackageInfoPlugin();

  // Rate limiting and security
  final Map<String, DateTime> _loginAttempts = {};
  final int _maxAttempts = 5;
  final Duration _lockoutDuration = const Duration(minutes: 15);
  final Duration _sessionTimeout = const Duration(hours: 8);
  final Duration _inactivityTimeout = const Duration(minutes: 30);

  // Enhanced security features
  String? _deviceId;
  String? _appVersion;
  List<String> _trustedDevices = [];
  Timer? _sessionTimer;
  Timer? _inactivityTimer;

  AuthService() {
    _initializeDio();
    _initializeSecurity();
  }

  void _initializeDio() {
    _dio = Dio();
    _dio.options.baseUrl = _baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
    _dio.options.headers = {'Content-Type': 'application/json'};
    
    // Add request interceptor for auth token and security
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add auth token if available
          final token = await _secureStorage.read(key: _tokenKey);
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          
          // Add security context
          final securityContext = await _createSecurityContext();
          options.headers['X-Security-Context'] = json.encode(securityContext);
          
          handler.next(options);
        },
        onError: (error, handler) {
          // Handle 401 unauthorized globally
          if (error.response?.statusCode == 401) {
            _handleUnauthorizedError();
          }
          handler.next(error);
        },
      ),
    );
  }

  Future<void> _initializeSecurity() async {
    try {
      // Get device information
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
      final trustedDevicesJson = await _secureStorage.read(key: _trustedDevicesKey);
      if (trustedDevicesJson != null) {
        _trustedDevices = List<String>.from(json.decode(trustedDevicesJson));
      }

      debugPrint('Security initialized for device: $_deviceId');
    } catch (e) {
      debugPrint('Error initializing security: $e');
    }
  }

  Future<Map<String, dynamic>> _createSecurityContext() async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final nonce = _generateNonce();
    
    return {
      'device_id': _deviceId,
      'app_version': _appVersion,
      'timestamp': timestamp,
      'nonce': nonce,
      'is_trusted_device': _trustedDevices.contains(_deviceId ?? ''),
    };
  }

  String _generateNonce() {
    final random = Random.secure();
    final values = List<int>.generate(32, (_) => random.nextInt(256));
    return base64.encode(values);
  }

  void _handleUnauthorizedError() {
    // Clear session and notify user
    _clearSession();
    debugPrint('Unauthorized access - session cleared');
  }

  Future<void> _clearSession() async {
    await _secureStorage.deleteAll();
    _sessionTimer?.cancel();
    _inactivityTimer?.cancel();
  }

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
      final existingLogs = await _secureStorage.read(key: _securityLogsKey);
      List<Map<String, dynamic>> logs = [];
      
      if (existingLogs != null) {
        logs = List<Map<String, dynamic>>.from(json.decode(existingLogs));
      }
      
      logs.add(eventData);
      
      // Keep only last 100 logs
      if (logs.length > 100) {
        logs = logs.sublist(logs.length - 100);
      }
      
      await _secureStorage.write(key: _securityLogsKey, value: json.encode(logs));
      
      // Send to server
      await _dio.post('/auth/security-log', data: eventData);
    } catch (e) {
      debugPrint('Failed to log security event: $e');
    }
  }

  // Enhanced login with security features
  Future<LoginResponse> enhancedLogin(String email, String password, bool rememberMe, {
    Map<String, dynamic>? securityContext,
  }) async {
    try {
      // Check rate limiting
      await _checkRateLimit(email);

      // Create security context if not provided
      securityContext ??= await _createSecurityContext();

      // Hash password for security
      final hashedPassword = _hashPassword(password);

      final response = await _dio.post(
        '/auth/enhanced-login',
        data: {
          'email': email.trim(),
          'password': hashedPassword,
          'rememberMe': rememberMe,
          'security_context': securityContext,
          'device_info': {
            'platform': 'flutter',
            'timestamp': DateTime.now().toIso8601String(),
            'device_id': _deviceId,
            'app_version': _appVersion,
          },
        },
        options: Options(
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.data['success'] == true) {
        // Store session data
        await _storeSession(response.data, rememberMe);
        
        // Log successful login
        await _logSecurityEvent('login_success', {
          'email': email,
          'remember_me': rememberMe,
          'trusted_device': securityContext['is_trusted_device'],
        });

        return LoginResponse(
          user: User.fromJson(response.data['user']),
          token: response.data['token'],
          message: response.data['message'] ?? 'Login successful',
        );
      } else {
        // Handle failed login
        await _handleFailedLogin(email, response.data['message'] ?? 'Login failed');
        throw Exception(response.data['message'] ?? 'Login failed');
      }
    } catch (e) {
      await _logSecurityEvent('login_failed', {
        'email': email,
        'error': e.toString(),
      });
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  // Enhanced biometric login
  Future<LoginResponse> biometricLogin(String email, {
    Map<String, dynamic>? securityContext,
  }) async {
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

      securityContext ??= await _createSecurityContext();

      final response = await _dio.post(
        '/auth/biometric-login',
        data: {
          'email': email.trim(),
          'security_context': securityContext,
          'biometric_data': {
            'timestamp': DateTime.now().toIso8601String(),
            'device_id': _deviceId,
          },
        },
      );

      if (response.data['success'] == true) {
        await _storeSession(response.data, true);
        
        await _logSecurityEvent('biometric_login_success', {
          'email': email,
          'method': 'biometric',
        });

        return LoginResponse(
          user: User.fromJson(response.data['user']),
          token: response.data['token'],
          message: 'Biometric login successful',
        );
      } else {
        throw Exception(response.data['message'] ?? 'Biometric login failed');
      }
    } catch (e) {
      await _logSecurityEvent('biometric_login_failed', {
        'email': email,
        'error': e.toString(),
      });
      throw Exception('Biometric login failed: ${e.toString()}');
    }
  }

  // Enhanced registration with security
  Future<RegisterResponse> enhancedRegister(Map<String, dynamic> userData) async {
    try {
      // Add security context
      final securityContext = await _createSecurityContext();
      userData['security_context'] = securityContext;

      // Hash password
      if (userData['password'] != null) {
        userData['password'] = _hashPassword(userData['password']);
      }

      final response = await _dio.post(
        '/auth/enhanced-register',
        data: userData,
      );

      if (response.data['success'] == true) {
        await _storeSession(response.data, true);
        
        await _logSecurityEvent('user_registered', {
          'email': userData['email'],
          'role': userData['role'],
        });

        return RegisterResponse(
          user: User.fromJson(response.data['user']),
          token: response.data['token'],
          message: response.data['message'] ?? 'Registration successful',
        );
      } else {
        throw Exception(response.data['message'] ?? 'Registration failed');
      }
    } catch (e) {
      await _logSecurityEvent('registration_failed', {
        'email': userData['email'],
        'error': e.toString(),
      });
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  // Two-factor authentication setup
  Future<String> generateTwoFactorSecret() async {
    try {
      final response = await _dio.post('/auth/2fa/setup');
      
      if (response.data['success'] == true) {
        final secret = response.data['secret'];
        await _secureStorage.write(key: '2fa_secret', value: secret);
        
        await _logSecurityEvent('2fa_setup_initiated', {
          'user_id': response.data['user_id'],
        });
        
        return secret;
      } else {
        throw Exception('Failed to generate 2FA secret');
      }
    } catch (e) {
      await _logSecurityEvent('2fa_setup_failed', {'error': e.toString()});
      throw Exception('2FA setup failed: ${e.toString()}');
    }
  }

  // Verify two-factor authentication code
  Future<bool> verifyTwoFactorCode(String secret, String code) async {
    try {
      final response = await _dio.post(
        '/auth/2fa/verify',
        data: {
          'secret': secret,
          'code': code,
        },
      );

      if (response.data['success'] == true) {
        await _logSecurityEvent('2fa_verified', {'success': true});
        return true;
      } else {
        await _logSecurityEvent('2fa_failed', {'error': response.data['message']});
        return false;
      }
    } catch (e) {
      await _logSecurityEvent('2fa_error', {'error': e.toString()});
      return false;
    }
  }

  // Enhanced password reset
  Future<void> enhancedResetPassword(String email, Map<String, dynamic>? securityContext) async {
    try {
      securityContext ??= await _createSecurityContext();

      final response = await _dio.post(
        '/auth/enhanced-reset-password',
        data: {
          'email': email.trim(),
          'security_context': securityContext,
          'app_name': 'VedantaTrade',
        },
      );

      if (response.data['success'] == true) {
        await _logSecurityEvent('password_reset_requested', {'email': email});
      } else {
        throw Exception(response.data['message'] ?? 'Password reset failed');
      }
    } catch (e) {
      await _logSecurityEvent('password_reset_failed', {
        'email': email,
        'error': e.toString(),
      });
      throw Exception('Password reset failed: ${e.toString()}');
    }
  }

  // Enhanced password reset confirmation
  Future<void> enhancedConfirmPasswordReset(
    String email, 
    String verificationCode, 
    String newPassword,
    Map<String, dynamic>? securityContext,
  ) async {
    try {
      securityContext ??= await _createSecurityContext();

      final response = await _dio.post(
        '/auth/enhanced-confirm-reset',
        data: {
          'email': email.trim(),
          'verification_code': verificationCode,
          'new_password': _hashPassword(newPassword),
          'security_context': securityContext,
        },
      );

      if (response.data['success'] == true) {
        await _logSecurityEvent('password_reset_confirmed', {'email': email});
      } else {
        throw Exception(response.data['message'] ?? 'Password reset confirmation failed');
      }
    } catch (e) {
      await _logSecurityEvent('password_reset_confirm_failed', {
        'email': email,
        'error': e.toString(),
      });
      throw Exception('Password reset confirmation failed: ${e.toString()}');
    }
  }

  // Enhanced logout with security cleanup
  Future<void> enhancedLogout() async {
    try {
      final token = await _secureStorage.read(key: _tokenKey);
      if (token != null) {
        await _dio.post(
          '/auth/enhanced-logout',
          options: Options(
            headers: {'Authorization': 'Bearer $token'},
          ),
        );
      }

      await _logSecurityEvent('logout', {
        'session_duration': _getSessionDuration(),
      });

      await _clearSession();
    } catch (e) {
      await _logSecurityEvent('logout_failed', {'error': e.toString()});
      // Clear session even if server logout fails
      await _clearSession();
    }
  }

  // Enhanced token validation
  Future<bool> validateToken(String token) async {
    try {
      final response = await _dio.get(
        '/auth/enhanced-validate',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.data['valid'] == true) {
        return true;
      } else {
        await _clearSession();
        return false;
      }
    } catch (e) {
      await _clearSession();
      return false;
    }
  }

  // Enhanced token refresh
  Future<LoginResponse> refreshToken(String refreshToken) async {
    try {
      final securityContext = await _createSecurityContext();

      final response = await _dio.post(
        '/auth/enhanced-refresh',
        data: {
          'refresh_token': refreshToken,
          'security_context': securityContext,
        },
      );

      if (response.data['success'] == true) {
        await _storeSession(response.data, true);
        
        await _logSecurityEvent('token_refreshed', {
          'success': true,
        });

        return LoginResponse(
          user: User.fromJson(response.data['user']),
          token: response.data['token'],
          message: 'Token refreshed successfully',
        );
      } else {
        throw Exception(response.data['message'] ?? 'Token refresh failed');
      }
    } catch (e) {
      await _logSecurityEvent('token_refresh_failed', {'error': e.toString()});
      await _clearSession();
      throw Exception('Token refresh failed: ${e.toString()}');
    }
  }

  // Helper methods
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  Future<void> _checkRateLimit(String email) async {
    final now = DateTime.now();
    final lastAttempt = _loginAttempts[email];

    if (lastAttempt != null) {
      final timeSinceLastAttempt = now.difference(lastAttempt);
      if (timeSinceLastAttempt < const Duration(minutes: 1)) {
        throw Exception('Too many login attempts. Please try again later.');
      }
    }

    _loginAttempts[email] = now;
  }

  Future<void> _handleFailedLogin(String email, String message) async {
    final attempts = (_loginAttempts[email] != null) ? 1 : 0;
    
    if (attempts >= _maxAttempts) {
      final lockoutUntil = DateTime.now().add(_lockoutDuration);
      await _secureStorage.write(key: 'lockout_until', value: lockoutUntil.toIso8601String());
      
      await _logSecurityEvent('account_locked', {
        'email': email,
        'attempts': attempts,
        'lockout_until': lockoutUntil.toIso8601String(),
      });
    }

    await _logSecurityEvent('login_failed', {
      'email': email,
      'message': message,
      'attempts': attempts,
    });
  }

  Future<void> _storeSession(Map<String, dynamic> response, bool rememberMe) async {
    await _secureStorage.write(key: _tokenKey, value: response['token']);
    await _secureStorage.write(key: _userKey, value: json.encode(response['user']));
    await _secureStorage.write(key: 'last_activity', value: DateTime.now().toIso8601String());
    
    if (rememberMe && _deviceId != null) {
      await _addTrustedDevice(_deviceId!);
    }

    // Start session monitoring
    _startSessionMonitoring();
  }

  Future<void> _addTrustedDevice(String deviceId) async {
    if (!_trustedDevices.contains(deviceId)) {
      _trustedDevices.add(deviceId);
      await _secureStorage.write(key: _trustedDevicesKey, value: json.encode(_trustedDevices));
      
      await _logSecurityEvent('device_trusted', {'device_id': deviceId});
    }
  }

  void _startSessionMonitoring() {
    // Cancel existing timers
    _sessionTimer?.cancel();
    _inactivityTimer?.cancel();

    // Session timeout timer
    _sessionTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _checkSessionTimeout();
    });

    // Inactivity timer
    _inactivityTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _checkInactivityTimeout();
    });
  }

  Future<void> _checkSessionTimeout() async {
    try {
      final lastActivity = await _secureStorage.read(key: 'last_activity');
      if (lastActivity != null) {
        final lastActivityTime = DateTime.parse(lastActivity);
        if (DateTime.now().difference(lastActivityTime) > _sessionTimeout) {
          await _logSecurityEvent('session_timeout', {
            'session_duration': _getSessionDuration(),
          });
          await _clearSession();
        }
      }
    } catch (e) {
      debugPrint('Session timeout check failed: $e');
    }
  }

  Future<void> _checkInactivityTimeout() async {
    try {
      final lastActivity = await _secureStorage.read(key: 'last_activity');
      if (lastActivity != null) {
        final lastActivityTime = DateTime.parse(lastActivity);
        if (DateTime.now().difference(lastActivityTime) > _inactivityTimeout) {
          await _logSecurityEvent('inactivity_timeout', {
            'inactive_duration': DateTime.now().difference(lastActivityTime).inMinutes,
          });
          // Don't clear session, just require re-authentication
        }
      }
    } catch (e) {
      debugPrint('Inactivity timeout check failed: $e');
    }
  }

  int _getSessionDuration() {
    // Calculate session duration in minutes
    // This would normally be calculated from stored session start time
    return 0;
  }

  // Get security logs
  Future<List<Map<String, dynamic>>> getSecurityLogs() async {
    try {
      final logsJson = await _secureStorage.read(key: _securityLogsKey);
      if (logsJson != null) {
        return List<Map<String, dynamic>>.from(json.decode(logsJson));
      }
      return [];
    } catch (e) {
      debugPrint('Failed to get security logs: $e');
      return [];
    }
  }

  // Get security score
  Future<int> getSecurityScore() async {
    int score = 0;
    
    // Base score for having authentication
    final token = await _secureStorage.read(key: _tokenKey);
    if (token != null) score += 20;
    
    // Trusted device
    if (_deviceId != null && _trustedDevices.contains(_deviceId!)) {
      score += 15;
    }
    
    // Recent activity
    final lastActivity = await _secureStorage.read(key: 'last_activity');
    if (lastActivity != null) {
      final lastActivityTime = DateTime.parse(lastActivity);
      if (DateTime.now().difference(lastActivityTime).inMinutes < 60) {
        score += 10;
      }
    }
    
    // Security logs (indicates active monitoring)
    final logs = await getSecurityLogs();
    if (logs.isNotEmpty) score += 15;
    
    // No recent failed attempts
    final recentFailedLogs = logs.where((log) => 
      log['event'] == 'login_failed' && 
      DateTime.parse(log['timestamp']).isAfter(DateTime.now().subtract(const Duration(hours: 24)))
    ).toList();
    
    if (recentFailedLogs.isEmpty) score += 15;
    
    // Two-factor authentication (would check stored setting)
    final twoFactorEnabled = await _secureStorage.read(key: '2fa_enabled');
    if (twoFactorEnabled == 'true') score += 25;
    
    return score.clamp(0, 100);
  }

  // Update last activity
  Future<void> updateLastActivity() async {
    await _secureStorage.write(key: 'last_activity', value: DateTime.now().toIso8601String());
  }
  static final List<Map<String, dynamic>> _mockUsers = [
    {
      'id': '1',
      'name': 'Admin User',
      'email': 'admin@vedantatrade.com',
      'password': 'Admin123!',
      'role': 'Admin',
      'licenseNumber': 'ADMIN-001',
      'phone': '+9771234567',
      'isActive': true,
      'createdAt': '2024-01-01T00:00:00Z',
      'lastLogin': '2026-04-03T10:00:00Z',
    },
    {
      'id': '2',
      'name': 'Dr. Sharma',
      'email': 'doctor@vedantatrade.com',
      'password': 'Doctor123!',
      'role': 'Doctor',
      'licenseNumber': 'MED-12345',
      'phone': '+9772345678',
      'isActive': true,
      'createdAt': '2024-01-15T00:00:00Z',
      'lastLogin': '2026-04-02T15:30:00Z',
    },
    {
      'id': '3',
      'name': 'MR Kumar',
      'email': 'mr@vedantatrade.com',
      'password': 'MR123!',
      'role': 'MR',
      'licenseNumber': 'MR-67890',
      'phone': '+9773456789',
      'isActive': true,
      'createdAt': '2024-02-01T00:00:00Z',
      'lastLogin': '2026-04-01T09:15:00Z',
    },
    {
      'id': '4',
      'name': 'Stockist Patel',
      'email': 'stockist@vedantatrade.com',
      'password': 'Stockist123!',
      'role': 'Stockist',
      'phone': '+9774567890',
      'isActive': true,
      'createdAt': '2024-02-15T00:00:00Z',
      'lastLogin': '2026-04-01T08:45:00Z',
    },
    {
      'id': '5',
      'name': 'Retailer Singh',
      'email': 'retailer@vedantatrade.com',
      'password': 'Retailer123!',
      'role': 'Retailer',
      'phone': '+9775678901',
      'isActive': true,
      'createdAt': '2024-03-01T00:00:00Z',
      'lastLogin': '2026-04-01T07:30:00Z',
    },
    {
      'id': '6',
      'name': 'Accountant Gupta',
      'email': 'accountant@vedantatrade.com',
      'password': 'Accountant123!',
      'role': 'Accountant',
      'phone': '+9776789012',
      'isActive': true,
      'createdAt': '2024-03-15T00:00:00Z',
      'lastLogin': '2026-04-01T06:15:00Z',
    },
  ];

  // Get stored token
  Future<String?> getStoredToken() async {
    // TODO: Implement secure storage
    // return await _secureStorage.read(_tokenKey);
    return null; // Mock implementation
  }

  // Store token securely
  Future<void> storeToken(String token) async {
    // TODO: Implement secure storage
    // await _secureStorage.write(_tokenKey, token);
    debugPrint('Token stored securely');
  }

  // Validate token with server
  Future<User?> validateToken(String token) async {
    try {
      // TODO: Implement actual API call
      // final response = await http.get('$_baseUrl/auth/validate', headers: {
      //   'Authorization': 'Bearer $token',
      // });
      
      // Mock validation - check if token matches any user
      for (final user in _mockUsers) {
        if (user['email'] == 'valid@token.com') { // Mock valid token
          return User.fromJson(user);
        }
      }
      
      return null;
    } catch (e) {
      debugPrint('Token validation failed: $e');
      return null;
    }
  }

  // Login with email and password
  Future<LoginResponse> login(String email, String password, bool rememberMe) async {
    try {
      // TODO: Implement actual API call
      // final response = await http.post('$_baseUrl/auth/login', body: {
      //   'email': email,
      //   'password': password,
      //   'rememberMe': rememberMe,
      // });
      
      // Mock login - check against mock users
      final user = _mockUsers.firstWhere(
        (user) => user['email'] == email && user['password'] == password,
        orElse: () => null,
      );
      
      if (user != null) {
        final token = 'mock_token_${user['id']}';
        return LoginResponse(
          user: User.fromJson(user),
          token: token,
          message: 'Login successful',
        );
      } else {
        throw Exception('Invalid credentials');
      }
    } catch (e) {
      debugPrint('Login failed: $e');
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  // Quick login for specific roles
  Future<LoginResponse> quickLogin(String role) async {
    try {
      // TODO: Implement actual API call
      // final response = await http.post('$_baseUrl/auth/quick-login', body: {
      //   'role': role,
      // });
      
      // Mock quick login - return first user with matching role
      final user = _mockUsers.firstWhere(
        (user) => user['role'] == role,
        orElse: () => null,
      );
      
      if (user != null) {
        final token = 'mock_token_${user['id']}_${DateTime.now().millisecondsSinceEpoch}';
        return LoginResponse(
          user: User.fromJson(user),
          token: token,
          message: 'Quick login successful',
        );
      } else {
        throw Exception('Role not found');
      }
    } catch (e) {
      debugPrint('Quick login failed: $e');
      throw Exception('Quick login failed: ${e.toString()}');
    }
  }

  // Biometric login
  Future<LoginResponse> biometricLogin() async {
    try {
      // TODO: Implement actual biometric authentication
      // final response = await http.post('$_baseUrl/auth/biometric', body: {
      //   'biometricData': await _biometricAuth.getBiometricData(),
      // });
      
      // Mock biometric login - return MR user for demo
      final user = _mockUsers.firstWhere(
        (user) => user['role'] == 'MR',
        orElse: () => null,
      );
      
      if (user != null) {
        final token = 'biometric_token_${user['id']}_${DateTime.now().millisecondsSinceEpoch}';
        return LoginResponse(
          user: User.fromJson(user),
          token: token,
          message: 'Biometric login successful',
        );
      } else {
        throw Exception('Biometric authentication not available');
      }
    } catch (e) {
      debugPrint('Biometric login failed: $e');
      throw Exception('Biometric login failed: ${e.toString()}');
    }
  }

  // Register new user
  Future<RegisterResponse> register(Map<String, dynamic> userData) async {
    try {
      // TODO: Implement actual API call
      // final response = await http.post('$_baseUrl/auth/register', body: userData);
      
      // Mock registration
      final email = userData['email'] as String;
      
      // Check if email already exists
      if (_mockUsers.any((user) => user['email'] == email)) {
        throw Exception('Email already exists');
      }
      
      final newUser = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'name': userData['name'],
        'email': email,
        'role': userData['role'],
        'licenseNumber': userData['licenseNumber'],
        'phone': userData['phone'],
        'isActive': true,
        'createdAt': DateTime.now().toIso8601String(),
        'lastLogin': null,
      };
      
      final token = 'mock_token_${newUser['id']}';
      
      return RegisterResponse(
        user: User.fromJson(newUser),
        token: token,
        message: 'Registration successful',
      );
    } catch (e) {
      debugPrint('Registration failed: $e');
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      // TODO: Implement actual API call
      // await http.post('$_baseUrl/auth/reset-password', body: {
      //   'email': email,
      // });
      
      // Mock password reset
      debugPrint('Password reset initiated for email: $email');
      
      // In a real implementation, this would send an email
      // with a reset link containing a verification code
    } catch (e) {
      debugPrint('Password reset failed: $e');
      throw Exception('Password reset failed: ${e.toString()}');
    }
  }

  // Confirm password reset with verification code
  Future<void> confirmPasswordReset(String email, String verificationCode, String newPassword) async {
    try {
      // TODO: Implement actual API call
      // await http.post('$_baseUrl/auth/confirm-reset', body: {
      //   'email': email,
      //   'verificationCode': verificationCode,
      //   'newPassword': newPassword,
      // });
      
      // Mock password reset confirmation
      debugPrint('Password reset confirmed for email: $email');
      debugPrint('Verification code: $verificationCode');
      debugPrint('New password: $newPassword');
    } catch (e) {
      debugPrint('Password reset confirmation failed: $e');
      throw Exception('Password reset confirmation failed: ${e.toString()}');
    }
  }

  // Logout user
  Future<void> logout() async {
    try {
      // TODO: Implement actual API call
      // await http.post('$_baseUrl/auth/logout', headers: {
      //   'Authorization': 'Bearer $token',
      // });
      
      // Clear stored data
      // await _secureStorage.delete(_tokenKey);
      // await _secureStorage.delete(_userKey);
      
      debugPrint('Logout successful');
    } catch (e) {
      debugPrint('Logout failed: $e');
    }
  }

  // Update user profile
  Future<User> updateProfile(Map<String, dynamic> profileData) async {
    try {
      // TODO: Implement actual API call
      // final response = await http.put('$_baseUrl/auth/profile', body: profileData, headers: {
      //   'Authorization': 'Bearer $token',
      // });
      
      // Mock profile update
      debugPrint('Profile updated: $profileData');
      
      // Return updated user (mock implementation)
      return User.fromJson(_mockUsers.first);
    } catch (e) {
      debugPrint('Profile update failed: $e');
      throw Exception('Profile update failed: ${e.toString()}');
    }
  }

  // Change password
  Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      // TODO: Implement actual API call
      // await http.post('$_baseUrl/auth/change-password', body: {
      //   'currentPassword': currentPassword,
      //   'newPassword': newPassword,
      // }, headers: {
      //   'Authorization': 'Bearer $token',
      // });
      
      // Mock password change
      debugPrint('Password changed successfully');
    } catch (e) {
      debugPrint('Password change failed: $e');
      throw Exception('Password change failed: ${e.toString()}');
    }
  }

  // Check biometric availability
  Future<bool> isBiometricAvailable() async {
    try {
      // TODO: Implement actual biometric check
      // return await _biometricAuth.canCheckBiometrics();
      
      // Mock biometric availability
      return true; // Always return true for demo
    } catch (e) {
      debugPrint('Biometric check failed: $e');
      return false;
    }
  }

  // Toggle biometric authentication
  Future<void> toggleBiometric(bool enabled) async {
    try {
      // TODO: Implement actual biometric toggle
      // await _secureStorage.write(_biometricKey, enabled.toString());
      
      debugPrint('Biometric authentication ${enabled ? 'enabled' : 'disabled'}');
    } catch (e) {
      debugPrint('Biometric toggle failed: $e');
    }
  }

  // Refresh user token
  Future<LoginResponse> refreshToken(String token) async {
    try {
      // TODO: Implement actual API call
      // final response = await http.post('$_baseUrl/auth/refresh', headers: {
      //   'Authorization': 'Bearer $token',
      // });
      
      // Mock token refresh
      final user = _mockUsers.first;
      final newToken = 'refreshed_token_${DateTime.now().millisecondsSinceEpoch}';
      
      return LoginResponse(
        user: User.fromJson(user),
        token: newToken,
        message: 'Token refreshed successfully',
      );
    } catch (e) {
      debugPrint('Token refresh failed: $e');
      throw Exception('Token refresh failed: ${e.toString()}');
    }
  }
}

// Response models
class LoginResponse {
  final User user;
  final String token;
  final String message;

  LoginResponse({
    required this.user,
    required this.token,
    required this.message,
  });
}

class RegisterResponse {
  final User user;
  final String token;
  final String message;

  RegisterResponse({
    required this.user,
    required this.token,
    required this.message,
  });
}
