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

  // ============================================
  // SALES TRACKING & MARKETING MANAGEMENT
  // ============================================

  // Sales Analytics
  Future<Map<String, dynamic>> getSalesAnalytics({
    DateTime? startDate,
    DateTime? endDate,
    int? centerId,
    int? productId,
    int? campaignId,
    String? token,
  }) async {
    try {
      final response = await _dio.get(
        '/api/distribution/sales/analytics',
        queryParameters: {
          if (startDate != null) 'start_date': startDate.toIso8601String(),
          if (endDate != null) 'end_date': endDate.toIso8601String(),
          if (centerId != null) 'center_id': centerId,
          if (productId != null) 'product_id': productId,
          if (campaignId != null) 'campaign_id': campaignId,
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
        'message': 'Failed to load sales analytics',
      };
    }
  }

  // Record a sale
  Future<Map<String, dynamic>> recordSale({
    required int productId,
    required int centerId,
    required int quantity,
    required double unitPrice,
    double? discount,
    int? campaignId,
    String? customerId,
    String? notes,
    String? token,
  }) async {
    try {
      final response = await _dio.post(
        '/api/distribution/sales',
        data: {
          'product_id': productId,
          'center_id': centerId,
          'quantity': quantity,
          'unit_price': unitPrice,
          'discount': discount,
          'campaign_id': campaignId,
          'customer_id': customerId,
          'notes': notes,
          'sale_date': DateTime.now().toIso8601String(),
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
        'message': 'Failed to record sale',
      };
    }
  }

  // Marketing Campaigns
  Future<Map<String, dynamic>> getMarketingCampaigns({
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int limit = 20,
    String? token,
  }) async {
    try {
      final response = await _dio.get(
        '/api/distribution/campaigns',
        queryParameters: {
          if (status != null) 'status': status,
          if (startDate != null) 'start_date': startDate.toIso8601String(),
          if (endDate != null) 'end_date': endDate.toIso8601String(),
          'page': page,
          'limit': limit,
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
        'message': 'Failed to load campaigns',
      };
    }
  }

  Future<Map<String, dynamic>> createMarketingCampaign({
    required String name,
    String? description,
    required DateTime startDate,
    DateTime? endDate,
    double budget = 0,
    String? targetAudience,
    required int createdBy,
    String? token,
  }) async {
    try {
      final response = await _dio.post(
        '/api/distribution/campaigns',
        data: {
          'name': name,
          'description': description,
          'start_date': startDate.toIso8601String(),
          'end_date': endDate?.toIso8601String(),
          'budget': budget,
          'target_audience': targetAudience,
          'created_by': createdBy,
          'status': 'ACTIVE',
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
        'message': 'Failed to create campaign',
      };
    }
  }

  // Campaign Products
  Future<Map<String, dynamic>> getCampaignProducts({
    required int campaignId,
    String? token,
  }) async {
    try {
      final response = await _dio.get(
        '/api/distribution/campaigns/$campaignId/products',
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
        'message': 'Failed to load campaign products',
      };
    }
  }

  Future<Map<String, dynamic>> addProductToCampaign({
    required int campaignId,
    required int productId,
    double discountPercentage = 0,
    double? specialPrice,
    DateTime? startDate,
    DateTime? endDate,
    String? token,
  }) async {
    try {
      final response = await _dio.post(
        '/api/distribution/campaigns/$campaignId/products',
        data: {
          'product_id': productId,
          'discount_percentage': discountPercentage,
          'special_price': specialPrice,
          'start_date': startDate?.toIso8601String(),
          'end_date': endDate?.toIso8601String(),
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
        'message': 'Failed to add product to campaign',
      };
    }
  }

  // Product Inventory at Distribution Centers
  Future<Map<String, dynamic>> getProductInventory({
    required int productId,
    int? centerId,
    String? token,
  }) async {
    try {
      final response = await _dio.get(
        '/api/distribution/inventory/product/$productId',
        queryParameters: {
          if (centerId != null) 'center_id': centerId,
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
        'message': 'Failed to load product inventory',
      };
    }
  }

  // Inventory Movement/Transfer
  Future<Map<String, dynamic>> transferInventory({
    required int productId,
    required int fromCenterId,
    required int toCenterId,
    required int quantity,
    String? notes,
    String? token,
  }) async {
    try {
      final response = await _dio.post(
        '/api/distribution/inventory/transfer',
        data: {
          'product_id': productId,
          'from_center_id': fromCenterId,
          'to_center_id': toCenterId,
          'quantity': quantity,
          'notes': notes,
          'transfer_date': DateTime.now().toIso8601String(),
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
        'message': 'Failed to transfer inventory',
      };
    }
  }

  // Marketing Metrics
  Future<Map<String, dynamic>> getCampaignMetrics({
    required int campaignId,
    String? metricType,
    DateTime? startDate,
    DateTime? endDate,
    String? token,
  }) async {
    try {
      final response = await _dio.get(
        '/api/distribution/campaigns/$campaignId/metrics',
        queryParameters: {
          if (metricType != null) 'metric_type': metricType,
          if (startDate != null) 'start_date': startDate.toIso8601String(),
          if (endDate != null) 'end_date': endDate.toIso8601String(),
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
        'message': 'Failed to load campaign metrics',
      };
    }
  }

  Future<Map<String, dynamic>> recordCampaignMetric({
    required int campaignId,
    required String metricType,
    required double metricValue,
    String? token,
  }) async {
    try {
      final response = await _dio.post(
        '/api/distribution/campaigns/$campaignId/metrics',
        data: {
          'metric_type': metricType,
          'metric_value': metricValue,
          'metric_date': DateTime.now().toIso8601String(),
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
        'message': 'Failed to record metric',
      };
    }
  }
}
