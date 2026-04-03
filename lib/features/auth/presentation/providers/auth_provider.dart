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
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock_this_device),
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
  String? get errorMessage => _error; // Alias for UI compatibility
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
      final res = await dio.get(ApiConfig.health).timeout(const Duration(seconds: 3));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<void> _loadSession() async {
    try {
      final token = await _storage.read(key: 'token');
      final userJson = await _storage.read(key: 'user');
      if (token != null && userJson != null) {
        _token = token;
        _user = json.decode(userJson);
        notifyListeners();
      }
    } catch (_) {}
  }

  // Demo roles for mock login
  final List<Map<String, dynamic>> _demoRoles = [
    {'role': 'ADMIN', 'email': 'admin@vedanta.com', 'password': 'Admin@123', 'name': 'Super Admin'},
    {'role': 'MEDICAL_REP', 'email': 'mr@vedanta.com', 'password': 'MR@123', 'name': 'John MR'},
    {'role': 'ACCOUNTANT', 'email': 'accountant@vedanta.com', 'password': 'Acc@123', 'name': 'Fin Manager'},
    {'role': 'DOCTOR', 'email': 'doctor@vedanta.com', 'password': 'Doc@123', 'name': 'Dr. Sharma'},
    {'role': 'STOCKIST', 'email': 'stockist@vedanta.com', 'password': 'Stock@123', 'name': 'Central Stockist'},
    {'role': 'RETAILER', 'email': 'retailer@vedanta.com', 'password': 'Retail@123', 'name': 'Local Pharmacist'},
  ];

  Future<bool> login(String email, String password, {bool useBiometric = false}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 1. Try Mock Login first if it matches demo credentials
      final demoUser = _demoRoles.firstWhere(
        (u) => u['email'] == email && u['password'] == password,
        orElse: () => {},
      );

      if (demoUser.isNotEmpty) {
        await Future.delayed(const Duration(milliseconds: 800)); // Simulate delay
        await _handleAuthSuccess({
          'token': 'mock_token_${demoUser['role']}',
          'refresh_token': 'mock_refresh',
          'user': demoUser,
          'expires_at': DateTime.now().add(const Duration(days: 1)).toIso8601String(),
        });
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        // 2. Check biometric authentication first if requested
        if (useBiometric) {
          final canCheckBiometrics = await LocalAuthentication().canCheckBiometrics;
          if (canCheckBiometrics) {
            final isDeviceSupported = await LocalAuthentication().isDeviceSupported();
            if (isDeviceSupported) {
              final didAuthenticate = await LocalAuthentication().authenticate(
                localizedReason: 'Authenticate to access VedantaTrade',
                options: const AuthenticationOptions(
                  biometricOnly: true,
                  stickyAuth: true,
                ),
              );

              if (didAuthenticate) {
                // Get user from storage for biometric user
                final userJson = await _storage.read(key: 'user');
                if (userJson != null) {
                  final user = json.decode(userJson);
                  await _handleAuthSuccess({
                    'token': 'biometric_token_${user['role']}',
                    'refresh_token': 'biometric_refresh',
                    'user': user,
                    'expires_at': DateTime.now().add(const Duration(days: 1)).toIso8601String(),
                  });
                  _isLoading = false;
                  notifyListeners();
                  return true;
                } else {
                  _setError('No user found for biometric authentication');
                }
              } else {
                _setError('Biometric authentication failed');
              }
            } else {
              _setError('Biometric authentication not available');
            }
          } else {
            _setError('Biometric authentication not supported');
          }
        } else {
          // 3. Regular password authentication
          final response = await _authService.login(email, password);
          if (response['success'] == true) {
            await _handleAuthSuccess(response);
            _isLoading = false;
            notifyListeners();
            return true;
          } else {
            _setError(response['message'] ?? 'Login failed');
          }
        }
      }
    } catch (e) {
      _setError('An error occurred during login: ${e.toString()}');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // Alias for compatibility
  Future<bool> signIn(String email, String password) => login(email, password);

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
      }
    } catch (e) {
      _error = 'Registration failed. Please try again.';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // Alias for compatibility
  Future<bool> signUp(String name, String email, String phone, String password) => 
      register(name, email, password, phone);

  Future<void> logout({bool force = false}) async {
    _token = null;
    _user = null;
    await _storage.deleteAll();
    notifyListeners();
  }

  Future<void> _handleAuthSuccess(Map<String, dynamic> response) async {
    _token = response['token'];
    _user = response['user'];
    await _storage.write(key: 'token', value: _token);
    await _storage.write(key: 'user', value: json.encode(_user));
  }

  Future<void> _setError(String error) async {
    _error = error;
    notifyListeners();
  }

  Future<void> toggleBiometric() async {
    _biometricEnabled = !_biometricEnabled;
    await _storage.write(key: 'biometric_enabled', value: _biometricEnabled.toString());
    notifyListeners();
  }

  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.resetPassword(email);
      if (response['success'] == true) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Password reset failed';
      }
    } catch (e) {
      _error = 'Password reset failed. Please try again.';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> refreshToken() async {
    if (_refreshToken == null) return false;

    try {
      final response = await _authService.refreshToken(_refreshToken!);
      if (response['success'] == true) {
        await _handleAuthSuccess(response);
        return true;
      }
    } catch (e) {
      debugPrint('Token refresh failed: $e');
    }
    
    // If refresh fails, logout user
    await logout(force: true);
    return false;
  }

  Future<bool> verifyCurrentToken() async {
    if (_token == null) return false;

    try {
      final response = await _authService.verifyToken(_token!);
      return response['success'] == true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> enableBiometric() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      final isSupported = await _localAuth.isDeviceSupported();
      
      if (!isAvailable || !isSupported) {
        _error = 'Biometric authentication not supported on this device';
        notifyListeners();
        return false;
      }

      final didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Enable biometric login for VedantaTrade',
        options: const AuthenticationOptions(
          biometricOnly: true,
          useErrorDialogs: true,
        ),
      );

      if (didAuthenticate) {
        _biometricEnabled = true;
        await _storage.write(key: 'biometric_enabled', value: 'true');
        notifyListeners();
        return true;
      }
    } catch (e) {
      _error = 'Failed to enable biometric authentication';
    }

    notifyListeners();
    return false;
  }

  Future<bool> authenticateWithBiometric() async {
    if (!_biometricEnabled) return false;

    try {
      final didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Login to VedantaTrade',
        options: const AuthenticationOptions(
          biometricOnly: true,
          useErrorDialogs: true,
        ),
      );

      return didAuthenticate;
    } catch (e) {
      return false;
    }
  }
}
