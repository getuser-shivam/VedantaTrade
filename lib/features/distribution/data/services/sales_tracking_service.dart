import 'package:dio/dio.dart';
import '../../../core/api_config.dart';
import '../../domain/models/sales_tracking_models.dart';

class SalesTrackingService {
  final Dio _dio = Dio();
  final String _baseUrl = ApiConfig.baseUrl;

  SalesTrackingService() {
    _dio.options.baseUrl = _baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
  }

  // Record a sales transaction
  Future<Map<String, dynamic>> recordSalesTransaction(SalesTransaction transaction) async {
    try {
      final response = await _dio.post(
        '/api/sales/transactions',
        data: transaction.toJson(),
      );
      
      if (response.statusCode == 201) {
        return {
          'success': true,
          'data': response.data,
          'message': 'Sales transaction recorded successfully',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to record sales transaction',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error recording sales transaction: ${e.toString()}',
      };
    }
  }

  // Get sales transactions with filters
  Future<Map<String, dynamic>> getSalesTransactions({
    String? distributorId,
    String? retailerId,
    String? productId,
    String? region,
    DateTime? startDate,
    DateTime? endDate,
    String? campaignId,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      if (distributorId != null) queryParams['distributor_id'] = distributorId;
      if (retailerId != null) queryParams['retailer_id'] = retailerId;
      if (productId != null) queryParams['product_id'] = productId;
      if (region != null) queryParams['region'] = region;
      if (startDate != null) queryParams['start_date'] = startDate.toIso8601String();
      if (endDate != null) queryParams['end_date'] = endDate.toIso8601String();
      if (campaignId != null) queryParams['campaign_id'] = campaignId;

      final response = await _dio.get(
        '/api/sales/transactions',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final transactions = (data['transactions'] as List)
            .map((item) => SalesTransaction.fromJson(item as Map<String, dynamic>))
            .toList();

        return {
          'success': true,
          'transactions': transactions,
          'total': data['total'],
          'page': data['page'],
          'totalPages': data['total_pages'],
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch sales transactions',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error fetching sales transactions: ${e.toString()}',
      };
    }
  }

  // Get sales analytics for a specific period
  Future<Map<String, dynamic>> getSalesAnalytics({
    required String period, // daily, weekly, monthly, quarterly, yearly
    DateTime? startDate,
    DateTime? endDate,
    String? region,
    String? distributorId,
    String? productId,
  }) async {
    try {
      final queryParams = <String, dynamic>{'period': period};

      if (startDate != null) queryParams['start_date'] = startDate.toIso8601String();
      if (endDate != null) queryParams['end_date'] = endDate.toIso8601String();
      if (region != null) queryParams['region'] = region;
      if (distributorId != null) queryParams['distributor_id'] = distributorId;
      if (productId != null) queryParams['product_id'] = productId;

      final response = await _dio.get(
        '/api/sales/analytics',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final analytics = SalesAnalytics.fromJson(response.data);
        return {
          'success': true,
          'analytics': analytics,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch sales analytics',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error fetching sales analytics: ${e.toString()}',
      };
    }
  }

  // Generate sales forecast
  Future<Map<String, dynamic>> generateSalesForecast({
    required String productId,
    required String region,
    required DateTime forecastDate,
    int forecastDays = 30,
  }) async {
    try {
      final response = await _dio.post(
        '/api/sales/forecast',
        data: {
          'product_id': productId,
          'region': region,
          'forecast_date': forecastDate.toIso8601String(),
          'forecast_days': forecastDays,
        },
      );

      if (response.statusCode == 201) {
        final forecast = SalesForecast.fromJson(response.data);
        return {
          'success': true,
          'forecast': forecast,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to generate sales forecast',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error generating sales forecast: ${e.toString()}',
      };
    }
  }

  // Get sales performance metrics
  Future<Map<String, dynamic>> getSalesPerformanceMetrics({
    String? distributorId,
    String? region,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};

      if (distributorId != null) queryParams['distributor_id'] = distributorId;
      if (region != null) queryParams['region'] = region;
      if (startDate != null) queryParams['start_date'] = startDate.toIso8601String();
      if (endDate != null) queryParams['end_date'] = endDate.toIso8601String();

      final response = await _dio.get(
        '/api/sales/performance',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'metrics': response.data,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch sales performance metrics',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error fetching sales performance metrics: ${e.toString()}',
      };
    }
  }

  // Get top performing products
  Future<Map<String, dynamic>> getTopPerformingProducts({
    required String period,
    int limit = 10,
    String? region,
    String? distributorId,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'period': period,
        'limit': limit,
      };

      if (region != null) queryParams['region'] = region;
      if (distributorId != null) queryParams['distributor_id'] = distributorId;

      final response = await _dio.get(
        '/api/sales/top-products',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final products = (response.data as List)
            .map((item) => TopProduct.fromJson(item as Map<String, dynamic>))
            .toList();

        return {
          'success': true,
          'products': products,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch top performing products',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error fetching top performing products: ${e.toString()}',
      };
    }
  }

  // Get top performing distributors
  Future<Map<String, dynamic>> getTopPerformingDistributors({
    required String period,
    int limit = 10,
    String? region,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'period': period,
        'limit': limit,
      };

      if (region != null) queryParams['region'] = region;

      final response = await _dio.get(
        '/api/sales/top-distributors',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final distributors = (response.data as List)
            .map((item) => TopDistributor.fromJson(item as Map<String, dynamic>))
            .toList();

        return {
          'success': true,
          'distributors': distributors,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch top performing distributors',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error fetching top performing distributors: ${e.toString()}',
      };
    }
  }

  // Update sales transaction
  Future<Map<String, dynamic>> updateSalesTransaction(
    String transactionId,
    Map<String, dynamic> updates,
  ) async {
    try {
      final response = await _dio.put(
        '/api/sales/transactions/$transactionId',
        data: updates,
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data,
          'message': 'Sales transaction updated successfully',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to update sales transaction',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error updating sales transaction: ${e.toString()}',
      };
    }
  }

  // Delete sales transaction
  Future<Map<String, dynamic>> deleteSalesTransaction(String transactionId) async {
    try {
      final response = await _dio.delete('/api/sales/transactions/$transactionId');

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Sales transaction deleted successfully',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to delete sales transaction',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error deleting sales transaction: ${e.toString()}',
      };
    }
  }
}
