import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:vedanta_trade/core/api_config.dart';

class AuthProvider extends ChangeNotifier {
  static const String _baseUrl = ApiConfig.baseUrl;
  final _storage = const FlutterSecureStorage();

  Map<String, dynamic>? _user;
  String? _token;
  bool _isLoading = false;
  String? _error;

  Map<String, dynamic>? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _token != null && _user != null;
  String? get userRole => _user?['role'];
  String? get userName => _user?['name'];
  int? get userId => _user?['id'];

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
      final userJson = await _storage.read(key: 'user');
      if (token != null && userJson != null) {
        _token = token;
        _user = json.decode(userJson);
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final dio = Dio();
      final response = await dio.post(
        '$_baseUrl/auth/login',
        data: {'email': email, 'password': password},
        options: Options(
          contentType: 'application/json',
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.data['success'] == true) {
        _token = response.data['token'];
        _user = response.data['user'];

        await _storage.write(key: 'token', value: _token);
        await _storage.write(key: 'user', value: json.encode(_user));

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response.data['message'] ?? 'Login failed';
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

  Future<void> logout() async {
    try {
      if (_token != null) {
        final dio = Dio();
        await dio.post('$_baseUrl/auth/logout', options: Options(headers: {'Authorization': 'Bearer $_token'}));
      }
    } catch (_) {}

    _token = null;
    _user = null;
    await _storage.deleteAll();
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
