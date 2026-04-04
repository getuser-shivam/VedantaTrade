import 'package:dio/dio.dart';
import 'package:vedanta_trade/core/api_config.dart';

class AuthService {
  late final Dio _dio;
  
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
          'device_info': {
            'platform': 'flutter',
            'timestamp': DateTime.now().toIso8601String(),
          },
        },
        options: Options(
          validateStatus: (status) => status != null && status < 500,
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

  Future<Map<String, dynamic>> register(String name, String email, String password, String phone) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: {
          'name': name.trim(),
          'email': email.trim(),
          'password': password,
          'phone': phone.trim(),
          'role': 'User', // Default role
          'device_info': {
            'platform': 'flutter',
            'timestamp': DateTime.now().toIso8601String(),
          },
        },
        options: Options(
          validateStatus: (status) => status != null && status < 500,
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

  Future<Map<String, dynamic>> resetPassword(String email) async {
    try {
      final response = await _dio.post(
        '/auth/reset-password',
        data: {
          'email': email.trim(),
          'app_name': 'VedantaTrade',
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
