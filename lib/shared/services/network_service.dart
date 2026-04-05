import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import '../error/error_handler.dart';

class NetworkService {
  static NetworkService? _instance;
  static NetworkService get instance => _instance ??= NetworkService._();
  
  NetworkService._();
  
  http.Client? _client;
  String? _authToken;
  Map<String, String> _defaultHeaders = {
    'Content-Type': AppConstants.jsonContentType,
    'Accept': AppConstants.jsonContentType,
    'User-Agent': 'VedantaTrade/${AppConstants.appVersion}',
  };
  
  void initialize({http.Client? client}) {
    _client = client ?? http.Client();
  }
  
  void setAuthToken(String? token) {
    _authToken = token;
  }
  
  void clearAuthToken() {
    _authToken = null;
  }
  
  Future<http.Response> get(
    String endpoint, {
    Map<String, String>? headers,
    Duration? timeout,
    bool? followRedirects,
  }) async {
    return _makeRequest(
      'GET',
      endpoint,
      headers: headers,
      timeout: timeout,
      followRedirects: followRedirects,
    );
  }
  
  Future<http.Response> post(
    String endpoint, {
    Map<String, String>? headers,
    dynamic body,
    Encoding? encoding,
    Duration? timeout,
    bool? followRedirects,
  }) async {
    return _makeRequest(
      'POST',
      endpoint,
      headers: headers,
      body: body,
      encoding: encoding,
      timeout: timeout,
      followRedirects: followRedirects,
    );
  }
  
  Future<http.Response> put(
    String endpoint, {
    Map<String, String>? headers,
    dynamic body,
    Encoding? encoding,
    Duration? timeout,
    bool? followRedirects,
  }) async {
    return _makeRequest(
      'PUT',
      endpoint,
      headers: headers,
      body: body,
      encoding: encoding,
      timeout: timeout,
      followRedirects: followRedirects,
    );
  }
  
  Future<http.Response> delete(
    String endpoint, {
    Map<String, String>? headers,
    dynamic body,
    Encoding? encoding,
    Duration? timeout,
    bool? followRedirects,
  }) async {
    return _makeRequest(
      'DELETE',
      endpoint,
      headers: headers,
      body: body,
      encoding: encoding,
      timeout: timeout,
      followRedirects: followRedirects,
    );
  }
  
  Future<http.Response> patch(
    String endpoint, {
    Map<String, String>? headers,
    dynamic body,
    Encoding? encoding,
    Duration? timeout,
    bool? followRedirects,
  }) async {
    return _makeRequest(
      'PATCH',
      endpoint,
      headers: headers,
      body: body,
      encoding: encoding,
      timeout: timeout,
      followRedirects: followRedirects,
    );
  }
  
  Future<http.Response> upload(
    String endpoint,
    File file, {
    Map<String, String>? headers,
    Map<String, String>? fields,
    Duration? timeout,
    ProgressCallback? onProgress,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${AppConstants.apiBaseUrl}$endpoint'),
      );
      
      // Add headers
      final allHeaders = <String, String>{};
      allHeaders.addAll(_defaultHeaders);
      allHeaders.addAll(headers ?? {});
      
      if (_authToken != null) {
        allHeaders[AppConstants.authorizationHeader] = 'Bearer $_authToken';
      }
      
      request.headers.addAll(allHeaders);
      
      // Add fields
      fields?.forEach((key, value) {
        request.fields[key] = value;
      });
      
      // Add file
      final fileBytes = await file.readAsBytes();
      final multipartFile = http.MultipartFile.fromBytes(
        'file',
        fileBytes,
        filename: file.path.split('/').last,
      );
      request.files.add(multipartFile);
      
      // Send request
      final streamedResponse = await request.send().timeout(
        timeout ?? AppConstants.requestTimeout,
      );
      
      // Handle progress
      if (onProgress != null) {
        final contentLength = streamedResponse.contentLength ?? 0;
        var received = 0;
        
        final responseStream = streamedResponse.stream.transform(
          StreamTransformer.fromHandlers(
            handleData: (data, sink) {
              received += data.length;
              final progress = (received / contentLength) * 100;
              onProgress(progress);
              sink.add(data);
            },
          ),
        );
        
        final response = await http.Response.fromStream(responseStream);
        return response;
      }
      
      return await http.Response.fromStream(streamedResponse.stream);
    } catch (e) {
      throw NetworkException(
        message: 'Upload failed: $e',
        details: e,
      );
    }
  }
  
  Future<http.Response> download(
    String endpoint,
    String savePath, {
    Map<String, String>? headers,
    Duration? timeout,
    ProgressCallback? onProgress,
  }) async {
    try {
      final response = await get(
        endpoint,
        headers: headers,
        timeout: timeout,
      );
      
      if (response.statusCode == 200) {
        final file = File(savePath);
        await file.writeAsBytes(response.bodyBytes);
      }
      
      return response;
    } catch (e) {
      throw NetworkException(
        message: 'Download failed: $e',
        details: e,
      );
    }
  }
  
  Future<http.Response> _makeRequest(
    String method,
    String endpoint, {
    Map<String, String>? headers,
    dynamic body,
    Encoding? encoding,
    Duration? timeout,
    bool? followRedirects,
  }) async {
    try {
      final uri = Uri.parse('${AppConstants.apiBaseUrl}$endpoint');
      final allHeaders = <String, String>{};
      allHeaders.addAll(_defaultHeaders);
      allHeaders.addAll(headers ?? {});
      
      if (_authToken != null) {
        allHeaders[AppConstants.authorizationHeader] = 'Bearer $_authToken';
      }
      
      late Future<http.Response> response;
      
      switch (method.toUpperCase()) {
        case AppConstants.getMethod:
          response = _client!.get(
            uri,
            headers: allHeaders,
          ).timeout(timeout ?? AppConstants.requestTimeout);
          break;
        case AppConstants.postMethod:
          response = _client!.post(
            uri,
            headers: allHeaders,
            body: body,
            encoding: encoding,
          ).timeout(timeout ?? AppConstants.requestTimeout);
          break;
        case AppConstants.putMethod:
          response = _client!.put(
            uri,
            headers: allHeaders,
            body: body,
            encoding: encoding,
          ).timeout(timeout ?? AppConstants.requestTimeout);
          break;
        case AppConstants.deleteMethod:
          response = _client!.delete(
            uri,
            headers: allHeaders,
            body: body,
            encoding: encoding,
          ).timeout(timeout ?? AppConstants.requestTimeout);
          break;
        case AppConstants.patchMethod:
          response = _client!.patch(
            uri,
            headers: allHeaders,
            body: body,
            encoding: encoding,
          ).timeout(timeout ?? AppConstants.requestTimeout);
          break;
        default:
          throw ArgumentError('Unsupported HTTP method: $method');
      }
      
      // Handle response
      final finalResponse = await response;
      
      // Log request for debugging
      if (AppConstants.enableDebugMode) {
        print('HTTP $method $uri');
        print('Headers: $allHeaders');
        if (body != null) {
          print('Body: $body');
        }
        print('Response: ${finalResponse.statusCode}');
        print('Response Body: ${finalResponse.body}');
      }
      
      // Check for rate limiting
      if (finalResponse.statusCode == 429) {
        throw RateLimitException(
          message: 'Rate limit exceeded',
          retryAfter: _parseRetryAfter(finalResponse.headers),
        );
      }
      
      // Check for server errors
      if (finalResponse.statusCode >= 500) {
        throw ServerException(
          message: 'Server error: ${finalResponse.statusCode}',
          statusCode: finalResponse.statusCode,
          responseData: _parseResponseData(finalResponse.body),
        );
      }
      
      // Check for client errors
      if (finalResponse.statusCode >= 400 && finalResponse.statusCode < 500) {
        if (finalResponse.statusCode == 401) {
          throw AuthException(
            message: 'Unauthorized access',
            details: _parseResponseData(finalResponse.body),
          );
        } else if (finalResponse.statusCode == 403) {
          throw PermissionException(
            message: 'Access forbidden',
            details: _parseResponseData(finalResponse.body),
          );
        } else if (finalResponse.statusCode == 404) {
          throw NotFoundException(
            message: 'Resource not found',
            details: _parseResponseData(finalResponse.body),
          );
        } else if (finalResponse.statusCode == 422) {
          throw ValidationException(
            message: 'Validation error',
            details: _parseResponseData(finalResponse.body),
          );
        } else {
          throw ServerException(
            message: 'Client error: ${finalResponse.statusCode}',
            statusCode: finalResponse.statusCode,
            responseData: _parseResponseData(finalResponse.body),
          );
        }
      }
      
      return finalResponse;
    } on SocketException catch (e) {
      throw NetworkException(
        message: 'Network connection failed',
        details: e,
      );
    } on HttpException catch (e) {
      throw NetworkException(
        message: 'HTTP error: $e',
        details: e,
      );
    } on TimeoutException catch (e) {
      throw TimeoutException(
        message: 'Request timeout',
        details: e,
      );
    } catch (e) {
      throw AppException(
        message: 'Unexpected error: $e',
        details: e,
      );
    }
  }
  
  dynamic _parseResponseData(String responseBody) {
    try {
      return jsonDecode(responseBody);
    } catch (e) {
      return responseBody;
    }
  }
  
  int? _parseRetryAfter(Map<String, String>? headers) {
    final retryAfterHeader = headers?['retry-after'];
    if (retryAfterHeader != null) {
      try {
        return int.parse(retryAfterHeader);
      } catch (e) {
        return null;
      }
    }
    return null;
  }
  
  Future<bool> checkConnectivity() async {
    try {
      final response = await get(
        '/health',
        timeout: const Duration(seconds: 5),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  
  Future<Map<String, dynamic>> getServerInfo() async {
    try {
      final response = await get('/info');
      return _parseResponseData(response.body);
    } catch (e) {
      throw NetworkException(
        message: 'Failed to get server info',
        details: e,
      );
    }
  }
  
  void dispose() {
    _client?.close();
  }
}

typedef ProgressCallback = void Function(double progress);

class ApiEndpoints {
  // Authentication endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refreshToken = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String changePassword = '/auth/change-password';
  static const String enableMFA = '/auth/mfa/enable';
  static const String verifyMFA = '/auth/mfa/verify';
  static const String disableMFA = '/auth/mfa/disable';
  
  // User endpoints
  static const String profile = '/user/profile';
  static const String updateProfile = '/user/profile';
  static const String changeEmail = '/user/email';
  static const String changePhone = '/user/phone';
  static const String uploadAvatar = '/user/avatar';
  static const String deleteAccount = '/user/account';
  
  // Product endpoints
  static const String products = '/products';
  static const String productDetail = '/products';
  static const String searchProducts = '/products/search';
  static const String categories = '/products/categories';
  static const String manufacturers = '/products/manufacturers';
  static const String featuredProducts = '/products/featured';
  static const String productReviews = '/products';
  static const String addReview = '/products/reviews';
  
  // Distribution endpoints
  static const String distributions = '/distributions';
  static const String distributionDetail = '/distributions';
  static const String createDistribution = '/distributions';
  static const String updateDistribution = '/distributions';
  static const String deleteDistribution = '/distributions';
  static const String trackShipment = '/distributions/track';
  
  // Inventory endpoints
  static const String inventory = '/inventory';
  static const String inventoryDetail = '/inventory';
  static const String updateInventory = '/inventory';
  static const String inventoryMovements = '/inventory/movements';
  static const String lowStock = '/inventory/low-stock';
  static const String stockForecast = '/inventory/forecast';
  
  // Order endpoints
  static const String orders = '/orders';
  static const String orderDetail = '/orders';
  static const String createOrder = '/orders';
  static const String updateOrder = '/orders';
  static const String cancelOrder = '/orders/cancel';
  static const String orderHistory = '/orders/history';
  
  // Campaign endpoints
  static const String campaigns = '/campaigns';
  static const String campaignDetail = '/campaigns';
  static const String createCampaign = '/campaigns';
  static const String updateCampaign = '/campaigns';
  static const String deleteCampaign = '/campaigns';
  static const String campaignAnalytics = '/campaigns/analytics';
  
  // Analytics endpoints
  static const String dashboard = '/analytics/dashboard';
  static const String salesAnalytics = '/analytics/sales';
  static const String inventoryAnalytics = '/analytics/inventory';
  static const String customerAnalytics = '/analytics/customers';
  static const String performanceAnalytics = '/analytics/performance';
  static const String exportData = '/analytics/export';
  
  // Notification endpoints
  static const String notifications = '/notifications';
  static const String markAsRead = '/notifications/read';
  static const String notificationSettings = '/notifications/settings';
  static const String updateSettings = '/notifications/settings';
  
  // Settings endpoints
  static const String appSettings = '/settings/app';
  static const String userSettings = '/settings/user';
  static const String updateSettings = '/settings/user';
  static const String preferences = '/settings/preferences';
  static const String updatePreferences = '/settings/preferences';
  
  // File upload endpoints
  static const String uploadImage = '/upload/image';
  static const String uploadDocument = '/upload/document';
  static const String uploadBulk = '/upload/bulk';
  
  // System endpoints
  static const String health = '/health';
  static const String version = '/version';
  static const String config = '/config';
  static const String maintenance = '/maintenance';
}

class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final String? error;
  final int? statusCode;
  final Map<String, dynamic>? metadata;
  
  const ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.error,
    this.statusCode,
    this.metadata,
  });
  
  factory ApiResponse.success(T data, {String? message, Map<String, dynamic>? metadata}) {
    return ApiResponse<T>(
      success: true,
      data: data,
      message: message,
      metadata: metadata,
    );
  }
  
  factory ApiResponse.error(String error, {int? statusCode, String? message}) {
    return ApiResponse<T>(
      success: false,
      error: error,
      statusCode: statusCode,
      message: message,
    );
  }
  
  factory ApiResponse.fromResponse(http.Response response) {
    try {
      final responseData = jsonDecode(response.body);
      return ApiResponse<T>(
        success: response.statusCode >= 200 && response.statusCode < 300,
        data: responseData['data'],
        message: responseData['message'],
        error: responseData['error'],
        statusCode: response.statusCode,
        metadata: responseData['metadata'],
      );
    } catch (e) {
      return ApiResponse<T>(
        success: response.statusCode >= 200 && response.statusCode < 300,
        error: response.body,
        statusCode: response.statusCode,
      );
    }
  }
}
