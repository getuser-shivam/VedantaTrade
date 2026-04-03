import 'package:dio/dio.dart';
import 'package:vedanta_trade/core/api_config.dart';

class DistributionService {
  final Dio _dio = Dio();

  DistributionService() {
    _dio.options.baseUrl = ApiConfig.baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
    _dio.options.headers = {'Content-Type': 'application/json'};
  }

  // Distribution Centers
  Future<Map<String, dynamic>> getDistributionCenters({
    int page = 1,
    int limit = 20,
    String search = '',
    String? token,
  }) async {
    try {
      final response = await _dio.get(
        '/api/distribution/centers',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (search.isNotEmpty) 'search': search,
        },
        options: token != null
            ? Options(headers: {'Authorization': 'Bearer $token'})
            : null,
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

  Future<Map<String, dynamic>> createDistributionCenter({
    required String name,
    required String code,
    required String address,
    required String city,
    required String state,
    required String postalCode,
    String country = 'India',
    String? phone,
    String? email,
    String? managerName,
    double capacity = 0.0,
    String? token,
  }) async {
    try {
      final response = await _dio.post(
        '/api/distribution/centers',
        data: {
          'name': name,
          'code': code,
          'address': address,
          'city': city,
          'state': state,
          'postal_code': postalCode,
          'country': country,
          'phone': phone,
          'email': email,
          'manager_name': managerName,
          'capacity': capacity,
        },
        options: token != null
            ? Options(headers: {'Authorization': 'Bearer $token'})
            : null,
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

  // Inventory Management
  Future<Map<String, dynamic>> getInventoryAllocations({
    required int centerId,
    int page = 1,
    int limit = 20,
    String search = '',
    String? token,
  }) async {
    try {
      final response = await _dio.get(
        '/api/distribution/inventory/$centerId',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (search.isNotEmpty) 'search': search,
        },
        options: token != null
            ? Options(headers: {'Authorization': 'Bearer $token'})
            : null,
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

  Future<Map<String, dynamic>> allocateInventory({
    required int productId,
    required int centerId,
    required int quantity,
    String? token,
  }) async {
    try {
      final response = await _dio.post(
        '/api/distribution/inventory/allocate',
        data: {
          'product_id': productId,
          'center_id': centerId,
          'quantity': quantity,
        },
        options: token != null
            ? Options(headers: {'Authorization': 'Bearer $token'})
            : null,
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

  // Distribution Routes
  Future<Map<String, dynamic>> getDistributionRoutes({
    int page = 1,
    int limit = 20,
    int? centerId,
    String? token,
  }) async {
    try {
      final response = await _dio.get(
        '/api/distribution/routes',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (centerId != null) 'centerId': centerId,
        },
        options: token != null
            ? Options(headers: {'Authorization': 'Bearer $token'})
            : null,
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

  Future<Map<String, dynamic>> createDistributionRoute({
    required String name,
    required int centerId,
    String routeType = 'DELIVERY',
    List<String> areasCovered = const [],
    double estimatedTimeHours = 0.0,
    String? vehicleType,
    int? driverId,
    String? token,
  }) async {
    try {
      final response = await _dio.post(
        '/api/distribution/routes',
        data: {
          'name': name,
          'center_id': centerId,
          'route_type': routeType,
          'areas_covered': areasCovered,
          'estimated_time_hours': estimatedTimeHours,
          'vehicle_type': vehicleType,
          'driver_id': driverId,
        },
        options: token != null
            ? Options(headers: {'Authorization': 'Bearer $token'})
            : null,
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
          return error.response!.data['message'] ?? 'Server error occurred';
        }
        return 'Server error: ${error.response?.statusCode}';
      case DioExceptionType.cancel:
        return 'Request was cancelled';
      case DioExceptionType.unknown:
        if (error.error?.toString().contains('SocketException') ?? false) {
          return 'No internet connection. Please check your network.';
        }
        if (error.error?.toString().contains('HttpException') ?? false) {
          return 'Network error. Please check your connection.';
        }
        return 'An unexpected error occurred';
      default:
        return 'An unexpected error occurred';
    }
  }
}
