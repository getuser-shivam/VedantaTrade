import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'dart:async';
import 'package:vedanta_trade/core/api_config.dart';
import 'package:vedanta_trade/features/auth/data/services/auth_service.dart';
import 'package:local_auth/local_auth.dart';

class AuthProvider extends ChangeNotifier {
  static const String _baseUrl = ApiConfig.baseUrl;
  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );
  final LocalAuthentication _localAuth = LocalAuthentication();
  final AuthService _authService = AuthService();

  Map<String, dynamic>? _user;
  String? _token;
  String? _refreshToken;
  DateTime? _tokenExpiry;
  bool _isLoading = false;
  String? _error;
  bool _biometricEnabled = false;
  Timer? _sessionTimer;
  bool _isSessionExpired = false;

  Map<String, dynamic>? get user => _user;
  String? get token => _token;
  String? get refreshToken => _refreshToken;
  DateTime? get tokenExpiry => _tokenExpiry;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _token != null && _user != null && !_isSessionExpired;
  String? get userRole => _user?['role'];
  String? get userName => _user?['name'];
  int? get userId => _user?['user_id'];
  bool get biometricEnabled => _biometricEnabled;
  bool get isSessionExpired => _isSessionExpired;
  
  bool get isTokenExpired {
    if (_tokenExpiry == null) return false;
    return DateTime.now().isAfter(_tokenExpiry!);
  }

  AuthProvider() {
    _loadSession();
  }

  Future<bool> checkHealth() async {
    try {
      final dio = Dio();
      final res = await dio.get(ApiConfig.health);
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<void> _loadSession() async {
    try {
      final token = await _storage.read(key: 'token');
      final refreshToken = await _storage.read(key: 'refresh_token');
      final userJson = await _storage.read(key: 'user');
      final tokenExpiryStr = await _storage.read(key: 'token_expiry');
      final biometricEnabled = await _storage.read(key: 'biometric_enabled');
      
      if (token != null && userJson != null) {
        _token = token;
        _refreshToken = refreshToken;
        _user = json.decode(userJson);
        _biometricEnabled = biometricEnabled == 'true';
        
        if (tokenExpiryStr != null) {
          _tokenExpiry = DateTime.parse(tokenExpiryStr);
          _startSessionTimer();
        }
        
        // Check if token needs refresh
        if (isTokenExpired && _refreshToken != null) {
          await _refreshTokenAction();
        }
        
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<bool> login(String email, String password, {bool useBiometric = false}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Check biometric if enabled
      if (useBiometric || _biometricEnabled) {
        final authenticated = await _authenticateWithBiometrics();
        if (!authenticated) {
          _error = 'Biometric authentication failed';
          _isLoading = false;
          notifyListeners();
          return false;
        }
      }

      final response = await _authService.login(email, password);
      
      if (response['success'] == true) {
        await _handleAuthSuccess(response);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Login failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Connection failed. Please check if server is running.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout({bool force = false}) async {
    try {
      if (_token != null && !force) {
        await _authService.logout(_token!);
      }
    } catch (_) {}

    _token = null;
    _refreshToken = null;
    _user = null;
    _tokenExpiry = null;
    _isSessionExpired = false;
    _sessionTimer?.cancel();
    
    await _storage.deleteAll();
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Enhanced authentication methods
  Future<void> _handleAuthSuccess(Map<String, dynamic> response) async {
    _token = response['token'];
    _refreshToken = response['refresh_token'];
    _user = response['user'];
    
    // Set token expiry (7 days from now as per backend)
    _tokenExpiry = DateTime.now().add(const Duration(days: 7));
    
    await _storage.write(key: 'token', value: _token);
    await _storage.write(key: 'refresh_token', value: _refreshToken);
    await _storage.write(key: 'user', value: json.encode(_user));
    await _storage.write(key: 'token_expiry', value: _tokenExpiry!.toIso8601String());
    
    _startSessionTimer();
  }

  Future<bool> _refreshTokenAction() async {
    if (_refreshToken == null) return false;
    
    try {
      final response = await _authService.refreshToken(_refreshToken!);
      if (response['success'] == true) {
        await _handleAuthSuccess(response);
        return true;
      }
    } catch (_) {}
    
    // Refresh failed, logout user
    await logout(force: true);
    return false;
  }

  void _startSessionTimer() {
    _sessionTimer?.cancel();
    if (_tokenExpiry == null) return;
    
    final timeUntilExpiry = _tokenExpiry!.difference(DateTime.now());
    if (timeUntilExpiry.isNegative) return;
    
    _sessionTimer = Timer(timeUntilExpiry, () {
      _isSessionExpired = true;
      notifyListeners();
      // Attempt silent refresh
      _refreshTokenAction();
    });
  }

  Future<bool> _authenticateWithBiometrics() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      if (!isAvailable) return true; // Skip if not available
      
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to access VedantaTrade',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
      return authenticated;
    } catch (_) {
      return true; // Allow fallback to password
    }
  }

  Future<bool> register(String name, String email, String password, String phone) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.register(name, email, password, phone);
      
      if (response['success'] == true) {
        await _handleAuthSuccess(response);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Registration failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Registration failed. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.resetPassword(email);
      
      _isLoading = false;
      if (response['success'] == true) {
        return true;
      } else {
        _error = response['message'] ?? 'Password reset failed';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Password reset failed. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> toggleBiometricAuth() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      if (!isAvailable) {
        _error = 'Biometric authentication not available on this device';
        notifyListeners();
        return;
      }
      
      if (_biometricEnabled) {
        _biometricEnabled = false;
        await _storage.delete(key: 'biometric_enabled');
      } else {
        final authenticated = await _localAuth.authenticate(
          localizedReason: 'Enable biometric authentication for faster login',
          options: const AuthenticationOptions(
            biometricOnly: true,
            stickyAuth: true,
          ),
        );
        
        if (authenticated) {
          _biometricEnabled = true;
          await _storage.write(key: 'biometric_enabled', value: 'true');
        } else {
          _error = 'Biometric authentication failed';
        }
      }
      notifyListeners();
    } catch (e) {
      _error = 'Failed to toggle biometric authentication';
      notifyListeners();
    }
  }

  Future<bool> validateSession() async {
    if (_token == null) return false;
    
    try {
      final response = await _authService.validateToken(_token!);
      return response['success'] == true;
    } catch (_) {
      await logout(force: true);
      return false;
    }
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    super.dispose();
  }
}
