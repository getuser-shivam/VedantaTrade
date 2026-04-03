import 'package:dio/dio.dart';
import 'package:vedanta_trade/core/api_config.dart';

class AuthService {
  final Dio _dio = Dio();
  
  AuthService() {
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
    } on DioException catch (e) {
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
    } on DioException catch (e) {
      return {
        'success': false,
        'message': _getErrorMessage(e),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Password reset failed. Please try again.',
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
    } on DioException catch (e) {
      return {
        'success': false,
        'message': _getErrorMessage(e),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Token refresh failed',
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
    } on DioException catch (e) {
      return {
        'success': false,
        'message': _getErrorMessage(e),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Token verification failed',
      };
    }
  }
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
    } on DioException catch (e) {
      return {
        'success': false,
        'message': _getErrorMessage(e),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Registration failed. Please try again.',
      };
    }
  }

  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    try {
      final response = await _dio.post(
        '/auth/refresh',
        data: {
          'refresh_token': refreshToken,
        },
        options: Options(
          validateStatus: (status) => status != null && status < 500,
        ),
      );
      
      return response.data;
    } on DioException catch (e) {
      return {
        'success': false,
        'message': _getErrorMessage(e),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Token refresh failed',
      };
    }
  }

  Future<Map<String, dynamic>> logout(String token) async {
    try {
      final response = await _dio.post(
        '/auth/logout',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          validateStatus: (status) => status != null && status < 500,
        ),
      );
      
      return response.data;
    } on DioException catch (e) {
      return {
        'success': false,
        'message': _getErrorMessage(e),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Logout failed',
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
        options: Options(
          validateStatus: (status) => status != null && status < 500,
        ),
      );
      
      return response.data;
    } on DioException catch (e) {
      return {
        'success': false,
        'message': _getErrorMessage(e),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Password reset failed',
      };
    }
  }

  Future<Map<String, dynamic>> validateToken(String token) async {
    try {
      final response = await _dio.get(
        '/auth/validate',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          validateStatus: (status) => status != null && status < 500,
        ),
      );
      
      return response.data;
    } on DioException catch (e) {
      return {
        'success': false,
        'message': _getErrorMessage(e),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Token validation failed',
      };
    }
  }

  String _getErrorMessage(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.sendTimeout:
        return 'Request timeout. Please try again.';
      case DioExceptionType.receiveTimeout:
        return 'Server response timeout. Please try again.';
      case DioExceptionType.badResponse:
        if (error.response?.data is Map<String, dynamic>) {
          return error.response?.data['message'] ?? 'Server error occurred';
        }
        return 'Server error: ${error.response?.statusCode}';
      case DioExceptionType.cancel:
        return 'Request was cancelled';
      case DioExceptionType.unknown:
        if (error.error?.toString().contains('SocketException') ?? false) {
          return 'No internet connection. Please check your network.';
        }
        return 'Network error. Please check your connection.';
      default:
        return 'An unexpected error occurred';
    }
  }
}
