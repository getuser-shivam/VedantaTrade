import 'dart:io';
import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class AppErrorHandler {
  static AppErrorHandler? _instance;
  static AppErrorHandler get instance => _instance ??= AppErrorHandler._();
  
  AppErrorHandler._();
  
  final Map<String, List<Function(dynamic)>> _errorHandlers = {};
  
  void registerErrorHandler(String errorType, Function(dynamic) handler) {
    _errorHandlers[errorType] ??= [];
    _errorHandlers[errorType]!.add(handler);
  }
  
  void unregisterErrorHandler(String errorType, Function(dynamic) handler) {
    _errorHandlers[errorType]?.remove(handler);
  }
  
  void handleError(dynamic error, {String? context, StackTrace? stackTrace}) {
    final errorType = _getErrorType(error);
    final errorMessage = _getErrorMessage(error);
    final errorContext = context ?? _getErrorContext(error);
    
    // Log error
    _logError(errorType, errorMessage, errorContext, stackTrace);
    
    // Call registered handlers
    final handlers = _errorHandlers[errorType] ?? [];
    for (final handler in handlers) {
      try {
        handler(error);
      } catch (e) {
        // Prevent infinite loops
// print('Error in error handler: $e'); // Removed for production
      }
    }
    
    // Show user-friendly message
    _showUserFriendlyMessage(errorType, errorMessage, errorContext);
  }
  
  String _getErrorType(dynamic error) {
    if (error is SocketException) {
      return 'network';
    } else if (error is HttpException) {
      return 'http';
    } else if (error is FormatException) {
      return 'format';
    } else if (error is TimeoutException) {
      return 'timeout';
    } else if (error.toString().contains('unauthorized') ||
               error.toString().contains('401')) {
      return 'auth';
    } else if (error.toString().contains('forbidden') ||
               error.toString().contains('403')) {
      return 'permission';
    } else if (error.toString().contains('not found') ||
               error.toString().contains('404')) {
      return 'not_found';
    } else if (error.toString().contains('server') ||
               error.toString().contains('500')) {
      return 'server';
    } else if (error.toString().contains('validation') ||
               error.toString().contains('400')) {
      return 'validation';
    } else if (error.toString().contains('rate limit') ||
               error.toString().contains('429')) {
      return 'rate_limit';
    } else if (error.toString().contains('maintenance') ||
               error.toString().contains('503')) {
      return 'maintenance';
    } else {
      return 'unknown';
    }
  }
  
  String _getErrorMessage(dynamic error) {
    if (error is Exception) {
      return error.toString();
    } else if (error is String) {
      return error;
    } else {
      return error.toString();
    }
  }
  
  String _getErrorContext(dynamic error) {
    if (error is SocketException) {
      return 'Network connection failed';
    } else if (error is HttpException) {
      return 'HTTP request failed';
    } else if (error is TimeoutException) {
      return 'Request timed out';
    } else {
      return 'Application error';
    }
  }
  
  void _logError(String errorType, String errorMessage, String context, StackTrace? stackTrace) {
    final timestamp = DateTime.now().toIso8601String();
    final logMessage = '[$timestamp] $errorType: $errorMessage - $context';
    
// print(logMessage); // Removed for production
    if (stackTrace != null) {
// print('Stack trace: $stackTrace'); // Removed for production
    }
    
    // In a real app, you would send this to a logging service
    // AnalyticsService.logError(errorType, errorMessage, context, stackTrace);
  }
  
  void _showUserFriendlyMessage(String errorType, String errorMessage, String context) {
    String userMessage;
    Color backgroundColor;
    Color textColor;
    
    switch (errorType) {
      case 'network':
        userMessage = AppConstants.networkErrorMessage;
        backgroundColor = Colors.orange;
        textColor = Colors.white;
        break;
      case 'http':
        userMessage = AppConstants.serverErrorMessage;
        backgroundColor = Colors.red;
        textColor = Colors.white;
        break;
      case 'auth':
        userMessage = AppConstants.authErrorMessage;
        backgroundColor = Colors.red;
        textColor = Colors.white;
        break;
      case 'validation':
        userMessage = AppConstants.validationErrorMessage;
        backgroundColor = Colors.orange;
        textColor = Colors.white;
        break;
      case 'timeout':
        userMessage = 'Request timed out. Please check your connection and try again.';
        backgroundColor = Colors.orange;
        textColor = Colors.white;
        break;
      case 'not_found':
        userMessage = 'The requested resource was not found.';
        backgroundColor = Colors.grey;
        textColor = Colors.white;
        break;
      case 'permission':
        userMessage = 'You don\'t have permission to perform this action.';
        backgroundColor = Colors.red;
        textColor = Colors.white;
        break;
      case 'server':
        userMessage = AppConstants.serverErrorMessage;
        backgroundColor = Colors.red;
        textColor = Colors.white;
        break;
      case 'rate_limit':
        userMessage = 'Too many requests. Please try again later.';
        backgroundColor = Colors.orange;
        textColor = Colors.white;
        break;
      case 'maintenance':
        userMessage = 'Service is currently under maintenance. Please try again later.';
        backgroundColor = Colors.blue;
        textColor = Colors.white;
        break;
      default:
        userMessage = AppConstants.genericErrorMessage;
        backgroundColor = Colors.grey;
        textColor = Colors.white;
    }
    
    _showErrorSnackBar(userMessage, backgroundColor, textColor);
  }
  
  void _showErrorSnackBar(String message, Color backgroundColor, Color textColor) {
    // This would be implemented using a global key or context
    // For now, this is a placeholder
// print('Error Message: $message'); // Removed for production
  }
  
  void clearErrorHandlers() {
    _errorHandlers.clear();
  }
  
  List<String> getRegisteredErrorTypes() {
    return _errorHandlers.keys.toList();
  }
  
  bool hasErrorHandler(String errorType) {
    return _errorHandlers.containsKey(errorType) && _errorHandlers[errorType]!.isNotEmpty;
  }
}

class AppException implements Exception {
  final String message;
  final String? code;
  final String? type;
  final dynamic details;
  
  const AppException({
    required this.message,
    this.code,
    this.type,
    this.details,
  });
  
  @override
  String toString() {
    return 'AppException: $message${code != null ? ' (Code: $code)' : ''}';
  }
}

class NetworkException extends AppException {
  const NetworkException({
    required String message,
    String? code,
    dynamic details,
  }) : super(
    message: message,
    code: code,
    type: 'network',
    details: details,
  );
}

class AuthException extends AppException {
  const AuthException({
    required String message,
    String? code,
    dynamic details,
  }) : super(
    message: message,
    code: code,
    type: 'auth',
    details: details,
  );
}

class ValidationException extends AppException {
  final Map<String, String>? fieldErrors;
  
  const ValidationException({
    required String message,
    String? code,
    this.fieldErrors,
    dynamic details,
  }) : super(
    message: message,
    code: code,
    type: 'validation',
    details: details,
  );
}

class ServerException extends AppException {
  final int? statusCode;
  final Map<String, dynamic>? responseData;
  
  const ServerException({
    required String message,
    this.statusCode,
    this.responseData,
    String? code,
    dynamic details,
  }) : super(
    message: message,
    code: code,
    type: 'server',
    details: details,
  );
}

class TimeoutException extends AppException {
  const TimeoutException({
    required String message,
    String? code,
    dynamic details,
  }) : super(
    message: message,
    code: code,
    type: 'timeout',
    details: details,
  );
}

class PermissionException extends AppException {
  const PermissionException({
    required String message,
    String? code,
    dynamic details,
  }) : super(
    message: message,
    code: code,
    type: 'permission',
    details: details,
  );
}

class MaintenanceException extends AppException {
  const MaintenanceException({
    required String message,
    String? code,
    dynamic details,
  }) : super(
    message: message,
    code: code,
    type: 'maintenance',
    details: details,
  );
}

class RateLimitException extends AppException {
  final DateTime? resetTime;
  final int? retryAfter;
  
  const RateLimitException({
    required String message,
    this.resetTime,
    this.retryAfter,
    String? code,
    dynamic details,
  }) : super(
    message: message,
    code: code,
    type: 'rate_limit',
    details: details,
  );
}

class NotFoundException extends AppException {
  final String? resourceType;
  final String? resourceId;
  
  const NotFoundException({
    required String message,
    this.resourceType,
    this.resourceId,
    String? code,
    dynamic details,
  }) : super(
    message: message,
    code: code,
    type: 'not_found',
    details: details,
  );
}

class ErrorHandlerMixin {
  void handleError(dynamic error, {String? context, StackTrace? stackTrace}) {
    AppErrorHandler.instance.handleError(error, context: context, stackTrace: stackTrace);
  }
  
  void handleNetworkError(dynamic error, {String? context}) {
    final networkException = NetworkException(
      message: error.toString(),
      details: error,
    );
    handleError(networkException, context: context);
  }
  
  void handleAuthError(dynamic error, {String? context}) {
    final authException = AuthException(
      message: error.toString(),
      details: error,
    );
    handleError(authException, context: context);
  }
  
  void handleValidationError(dynamic error, {String? context}) {
    final validationException = ValidationException(
      message: error.toString(),
      details: error,
    );
    handleError(validationException, context: context);
  }
  
  void handleServerError(dynamic error, {String? context}) {
    final serverException = ServerException(
      message: error.toString(),
      details: error,
    );
    handleError(serverException, context: context);
  }
  
  void handleTimeoutError(dynamic error, {String? context}) {
    final timeoutException = TimeoutException(
      message: error.toString(),
      details: error,
    );
    handleError(timeoutException, context: context);
  }
  
  void handlePermissionError(dynamic error, {String? context}) {
    final permissionException = PermissionException(
      message: error.toString(),
      details: error,
    );
    handleError(permissionException, context: context);
  }
  
  void handleMaintenanceError(dynamic error, {String? context}) {
    final maintenanceException = MaintenanceException(
      message: error.toString(),
      details: error,
    );
    handleError(maintenanceException, context: context);
  }
  
  void handleRateLimitError(dynamic error, {String? context}) {
    final rateLimitException = RateLimitException(
      message: error.toString(),
      details: error,
    );
    handleError(rateLimitException, context: context);
  }
  
  void handleNotFoundError(dynamic error, {String? context}) {
    final notFoundException = NotFoundException(
      message: error.toString(),
      details: error,
    );
    handleError(notFoundException, context: context);
  }
}

class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(dynamic error, StackTrace? stackTrace)? errorBuilder;
  final Function(dynamic error, StackTrace? stackTrace)? onError;
  
  const ErrorBoundary({
    Key? key,
    required this.child,
    this.errorBuilder,
    this.onError,
  }) : super(key: key);
  
  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  dynamic _error;
  StackTrace? _stackTrace;
  
  @override
  void initState() {
    super.initState();
    FlutterError.onError = (FlutterErrorDetails details) {
      setState(() {
        _error = details.exception;
        _stackTrace = details.stack;
      });
      
      widget.onError?.call(details.exception, details.stack);
    };
  }
  
  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return widget.errorBuilder?.call(_error, _stackTrace) ??
          _defaultErrorBuilder(context, _error, _stackTrace);
    }
    
    return widget.child;
  }
  
  Widget _defaultErrorBuilder(BuildContext context, dynamic error, StackTrace? stackTrace) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
        backgroundColor: Colors.red,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              const Text(
                'An error occurred',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _error = null;
                    _stackTrace = null;
                  });
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ErrorLogger {
  static void logError({
    required String errorType,
    required String message,
    String? context,
    StackTrace? stackTrace,
    Map<String, dynamic>? additionalInfo,
  }) {
    final timestamp = DateTime.now().toIso8601String();
    final logEntry = {
      'timestamp': timestamp,
      'type': errorType,
      'message': message,
      'context': context,
      'stackTrace': stackTrace?.toString(),
      'additionalInfo': additionalInfo,
    };
    
    // Log to console for development
// print('ERROR: ${logEntry.toString()}'); // Removed for production
    
    // In a real app, you would send this to a logging service
    // AnalyticsService.logError(logEntry);
  }
  
  static void logWarning({
    required String message,
    String? context,
    Map<String, dynamic>? additionalInfo,
  }) {
    final timestamp = DateTime.now().toIso8601String();
    final logEntry = {
      'timestamp': timestamp,
      'type': 'warning',
      'message': message,
      'context': context,
      'additionalInfo': additionalInfo,
    };
    
// print('WARNING: ${logEntry.toString()}'); // Removed for production
    // AnalyticsService.logWarning(logEntry);
  }
  
  static void logInfo({
    required String message,
    String? context,
    Map<String, dynamic>? additionalInfo,
  }) {
    final timestamp = DateTime.now().toIso8601String();
    final logEntry = {
      'timestamp': timestamp,
      'type': 'info',
      'message': message,
      'context': context,
      'additionalInfo': additionalInfo,
    };
    
// print('INFO: ${logEntry.toString()}'); // Removed for production
    // AnalyticsService.logInfo(logEntry);
  }
  
  static void logDebug({
    required String message,
    String? context,
    Map<String, dynamic>? additionalInfo,
  }) {
    if (AppConstants.enableDebugMode) {
      final timestamp = DateTime.now().toIso8601String();
      final logEntry = {
        'timestamp': timestamp,
        'type': 'debug',
        'message': message,
        'context': context,
        'additionalInfo': additionalInfo,
      };
      
// print('DEBUG: ${logEntry.toString()}'); // Removed for production
      // AnalyticsService.logDebug(logEntry);
    }
  }
}

class ErrorRecovery {
  static Future<bool> attemptRecovery(
    dynamic error, {
    int maxRetries = 3,
    Duration delay = const Duration(seconds: 1),
  }) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        // Attempt recovery based on error type
        if (await _performRecovery(error)) {
          return true;
        }
      } catch (e) {
        ErrorLogger.logError(
          errorType: 'recovery_failed',
          message: 'Recovery attempt $attempt failed: $e',
          additionalInfo: {'originalError': error.toString()},
        );
      }
      
      if (attempt < maxRetries) {
        await Future.delayed(delay * attempt);
      }
    }
    return false;
  }
  
  static Future<bool> _performRecovery(dynamic error) async {
    // Implement recovery logic based on error type
    if (error is NetworkException) {
      return await _recoverFromNetworkError(error);
    } else if (error is AuthException) {
      return await _recoverFromAuthError(error);
    } else if (error is ServerException) {
      return await _recoverFromServerError(error);
    }
    
    return false;
  }
  
  static Future<bool> _recoverFromNetworkError(NetworkException error) async {
    // Try to reconnect or use cached data
    return await Future.delayed(const Duration(seconds: 2)).then((_) => true);
  }
  
  static Future<bool> _recoverFromAuthError(AuthException error) async {
    // Try to refresh token or re-authenticate
    return await Future.delayed(const Duration(seconds: 1)).then((_) => true);
  }
  
  static Future<bool> _recoverFromServerError(ServerException error) async {
    // Try to use cached data or retry with exponential backoff
    return await Future.delayed(const Duration(seconds: 3)).then((_) => true);
  }
}
