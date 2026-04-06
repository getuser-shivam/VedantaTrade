import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:math';
import 'package:vedanta_trade/core/api_config.dart';
import 'package:vedanta_trade/features/authentication/domain/entities/user_entity.dart';

class AuthService {
  late final Dio _dio;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final LocalAuthentication _localAuth = LocalAuthentication();
  
  // Token management
// static const String _accessTokenKey = 'access_token'; // TODO: Move to environment variables
// static const String _refreshTokenKey = 'refresh_token'; // TODO: Move to environment variables
  static const String _userKey = 'user_data';
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _deviceIdKey = 'device_id';
  
  // Rate limiting
  final Map<String, DateTime> _loginAttempts = {};
  final int _maxAttempts = 5;
  final Duration _lockoutDuration = const Duration(minutes: 15);
  
  AuthService() {
    _dio = Dio();
    _dio.options.baseUrl = ApiConfig.baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
    _dio.options.headers = {'Content-Type': 'application/json'};
    
    // Add request interceptor for auth token
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Add auth token if available (handled by AuthProvider)
          handler.next(options);
        },
        onError: (error, handler) {
          // Handle 401 unauthorized globally
          if (error.response?.statusCode == 401) {
            // Token expired or invalid - AuthProvider will handle refresh
          }
          handler.next(error);
        },
      ),
    );
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {
          'email': email.trim(),
          'password': password,
        },
      );
      
      return response.data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 423) {
        return {
          'success': false,
          'message': e.response?.data?['message'] ?? 'Account is locked.',
          'isLocked': true,
        };
      }
      return {
        'success': false,
        'message': _getErrorMessage(e),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred',
      };
    }
  }

  Future<Map<String, dynamic>> verifyMfaLogin(String mfaToken, String otp) async {
    try {
      final response = await _dio.post(
        '/auth/mfa/login-verify',
        data: {
          'mfaToken': mfaToken,
          'otp': otp,
        },
      );
      return response.data;
    } catch (e) {
      return {
        'success': false,
        'message': _getErrorMessage(e),
      };
    }
  }

  Future<Map<String, dynamic>> setupMfa(String token) async {
    try {
      final response = await _dio.post(
        '/auth/mfa/setup',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data;
    } catch (e) {
      return {
        'success': false,
        'message': _getErrorMessage(e),
      };
    }
  }

  Future<Map<String, dynamic>> enableMfa(String token, String secret, String otp) async {
    try {
      final response = await _dio.post(
        '/auth/mfa/verify',
        data: {'secret': secret, 'token': otp},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data;
    } catch (e) {
      return {
        'success': false,
        'message': _getErrorMessage(e),
      };
    }
  }

  Future<Map<String, dynamic>> disableMfa(String token, String password, String otp) async {
    try {
      final response = await _dio.post(
        '/auth/mfa/disable',
        data: {'password': password, 'mfaToken': otp},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data;
    } catch (e) {
      return {
        'success': false,
        'message': _getErrorMessage(e),
      };
    }
  }

  Future<Map<String, dynamic>> register(String name, String email, String password, String phone) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: {
          'name': name.trim(),
          'email': email.trim(),
          'password': password,
          'phone': phone.trim(),
        },
      );
      
      return response.data;
    } catch (e) {
      return {
        'success': false,
        'message': _getErrorMessage(e),
      };
    }
  }

  Future<Map<String, dynamic>> resetPassword(String email) async {
    try {
      final response = await _dio.post(
        '/auth/reset-password',
        data: {
          'email': email.trim(),
        },
      );
      
      return response.data;
    } catch (e) {
      return {
        'success': false,
        'message': _getErrorMessage(e),
      };
    }
  }

  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {


    try {
      final response = await _dio.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );
      
      return response.data;
    } catch (e) {
      return {
        'success': false,
        'message': _getErrorMessage(e),
      };
    }
  }

  Future<Map<String, dynamic>> verifyToken(String token) async {
    try {
      final response = await _dio.get(
        '/auth/verify',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      
      return response.data;
    } catch (e) {
      return {
        'success': false,
        'message': _getErrorMessage(e),
      };
    }
  }

  Future<Map<String, dynamic>> logout(String token) async {
    try {
      final response = await _dio.post(
        '/auth/logout',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      
      return response.data;
    } catch (e) {
      return {
        'success': false,
        'message': _getErrorMessage(e),
      };
    }
  }

  Future<Map<String, dynamic>> validateToken(String token) async {
    try {
      final response = await _dio.get(
        '/auth/validate',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      
      return response.data;
    } catch (e) {
      return {
        'success': false,
        'message': _getErrorMessage(e),
      };
    }
  }

  String _getErrorMessage(dynamic e) {
    if (e is DioException) {
      return e.response?.data?['message'] ?? e.message ?? 'Network error occurred';
    }
    return 'An unexpected error occurred';
  }
}
