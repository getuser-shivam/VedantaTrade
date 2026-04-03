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
          'user': {
            'role': demoUser['role'],
            'email': demoUser['email'],
            'name': demoUser['name'],
            'user_id': 999,
          }
        });
        _isLoading = false;
        notifyListeners();
        return true;
      }

      // 2. Fallback to real API if not a demo role
      final response = await _authService.login(email, password);
      if (response['success'] == true) {
        await _handleAuthSuccess(response);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Login failed';
      }
    } catch (e) {
      _error = 'Auth error. Please check your connection.';
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

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
