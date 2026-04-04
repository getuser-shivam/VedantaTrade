import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:io';

/// Comprehensive Error Handling and Validation Utilities
class ErrorHandlingUtils {
  static const String _defaultErrorTitle = 'Something went wrong';
  static const String _defaultErrorMessage = 'An unexpected error occurred. Please try again.';
  static const String _networkErrorTitle = 'Network Error';
  static const String _networkErrorMessage = 'Please check your internet connection and try again.';
  static const String _serverErrorTitle = 'Server Error';
  static const String _serverErrorMessage = 'Our servers are experiencing issues. Please try again later.';
  static const String _timeoutErrorTitle = 'Request Timeout';
  static const String _timeoutErrorMessage = 'The request took too long. Please try again.';
  static const String _validationErrorTitle = 'Validation Error';
  static const String _authErrorTitle = 'Authentication Error';
  static const String _permissionErrorTitle = 'Permission Denied';
  static const String _notFoundErrorTitle = 'Not Found';
  static const String _conflictErrorTitle = 'Conflict';

  // Error Type Classification
  static ErrorType classifyError(dynamic error) {
    if (error is DioException) {
      return _classifyDioError(error);
    } else if (error is SocketException) {
      return ErrorType.network;
    } else if (error is TimeoutException) {
      return ErrorType.timeout;
    } else if (error is FormatException) {
      return ErrorType.parsing;
    } else if (error is ValidationException) {
      return ErrorType.validation;
    } else if (error is AuthenticationException) {
      return ErrorType.authentication;
    } else if (error is PermissionException) {
      return ErrorType.permission;
    } else if (error is NotFoundException) {
      return ErrorType.notFound;
    } else if (error is ConflictException) {
      return ErrorType.conflict;
    } else if (error is StateError) {
      return ErrorType.state;
    } else {
      return ErrorType.unknown;
    }
  }

  static ErrorType _classifyDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ErrorType.timeout;
      case DioExceptionType.badResponse:
        return _classifyHttpError(error.response?.statusCode ?? 0);
      case DioExceptionType.cancel:
        return ErrorType.cancelled;
      case DioExceptionType.connectionError:
      case DioExceptionType.unknown:
        return ErrorType.network;
      default:
        return ErrorType.unknown;
    }
  }

  static ErrorType _classifyHttpError(int statusCode) {
    if (statusCode >= 400 && statusCode < 500) {
      switch (statusCode) {
        case 400:
          return ErrorType.validation;
        case 401:
          return ErrorType.authentication;
        case 403:
          return ErrorType.permission;
        case 404:
          return ErrorType.notFound;
        case 409:
          return ErrorType.conflict;
        case 422:
          return ErrorType.validation;
        default:
          return ErrorType.client;
      }
    } else if (statusCode >= 500) {
      return ErrorType.server;
    }
    return ErrorType.unknown;
  }

  // Error Message Generation
  static String getErrorMessage(dynamic error, {String? customMessage}) {
    final errorType = classifyError(error);
    
    if (customMessage != null) {
      return customMessage;
    }
    
    switch (errorType) {
      case ErrorType.network:
        return _networkErrorMessage;
      case ErrorType.timeout:
        return _timeoutErrorMessage;
      case ErrorType.server:
        return _serverErrorMessage;
      case ErrorType.authentication:
        return 'Your session has expired. Please log in again.';
      case ErrorType.permission:
        return 'You don\'t have permission to perform this action.';
      case ErrorType.notFound:
        return 'The requested resource was not found.';
      case ErrorType.validation:
        return _extractValidationMessage(error);
      case ErrorType.conflict:
        return 'There was a conflict with your request. Please refresh and try again.';
      case ErrorType.parsing:
        return 'We received invalid data. Please try again.';
      case ErrorType.cancelled:
        return 'The operation was cancelled.';
      case ErrorType.client:
        return 'There was an issue with your request. Please check and try again.';
      case ErrorType.state:
        return 'The application is in an invalid state. Please restart the app.';
      default:
        return _defaultErrorMessage;
    }
  }

  static String getErrorTitle(dynamic error) {
    final errorType = classifyError(error);
    
    switch (errorType) {
      case ErrorType.network:
        return _networkErrorTitle;
      case ErrorType.timeout:
        return _timeoutErrorTitle;
      case ErrorType.server:
        return _serverErrorTitle;
      case ErrorType.authentication:
        return _authErrorTitle;
      case ErrorType.permission:
        return _permissionErrorTitle;
      case ErrorType.notFound:
        return _notFoundErrorTitle;
      case ErrorType.validation:
        return _validationErrorTitle;
      case ErrorType.conflict:
        return _conflictErrorTitle;
      default:
        return _defaultErrorTitle;
    }
  }

  static String _extractValidationMessage(dynamic error) {
    if (error is DioException && error.response?.data is Map) {
      final data = error.response!.data as Map;
      if (data['message'] != null) {
        return data['message'].toString();
      }
      if (data['errors'] != null) {
        final errors = data['errors'];
        if (errors is Map) {
          final errorMessages = errors.values.map((e) => e.toString()).join('\n');
          return errorMessages;
        } else if (errors is List) {
          return errors.map((e) => e.toString()).join('\n');
        }
      }
    }
    
    if (error is ValidationException) {
      return error.message;
    }
    
    return 'Please check your input and try again.';
  }

  // Error Dialog Display
  static void showErrorDialog(
    BuildContext context, {
    dynamic error,
    String? title,
    String? message,
    VoidCallback? onRetry,
    VoidCallback? onDismiss,
  }) {
    final errorTitle = title ?? getErrorTitle(error);
    final errorMessage = message ?? getErrorMessage(error);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _ErrorDialog(
        title: errorTitle,
        message: errorMessage,
        onRetry: onRetry,
        onDismiss: onDismiss ?? () => Navigator.pop(context),
      ),
    );
  }

  // Error SnackBar Display
  static void showErrorSnackBar(
    BuildContext context, {
    dynamic error,
    String? message,
    Duration duration = const Duration(seconds: 4),
    VoidCallback? action,
  }) {
    final errorMessage = message ?? getErrorMessage(error);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        duration: duration,
        backgroundColor: Colors.red,
        action: action != null
            ? SnackBarAction(
                label: 'Retry',
                onPressed: action,
                textColor: Colors.white,
              )
            : null,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // Error Logging
  static void logError(dynamic error, {String? context, StackTrace? stackTrace}) {
    if (kDebugMode) {
      
      if (context != null) {
        
      }
      if (stackTrace != null) {
        
      }
    }
    
    // In production, send to crash reporting service
    // FirebaseCrashlytics.instance.recordError(error, stackTrace);
  }

  // Error Recovery
  static Future<T?> retryOperation<T>(
    Future<T> Function() operation, {
    int maxRetries = 3,
    Duration delay = const Duration(seconds: 1),
    bool Function(dynamic error)? shouldRetry,
  }) async {
    int attempts = 0;
    
    while (attempts < maxRetries) {
      try {
        return await operation();
      } catch (error) {
        attempts++;
        
        if (attempts >= maxRetries) {
          rethrow;
        }
        
        if (shouldRetry != null && !shouldRetry(error)) {
          rethrow;
        }
        
        // Don't retry on certain error types
        final errorType = classifyError(error);
        if (errorType == ErrorType.authentication ||
            errorType == ErrorType.permission ||
            errorType == ErrorType.validation ||
            errorType == ErrorType.notFound) {
          rethrow;
        }
        
        await Future.delayed(delay * attempts);
      }
    }
    
    return null;
  }
}

// Custom Exception Classes
class ValidationException implements Exception {
  final String message;
  final Map<String, String>? fieldErrors;
  
  ValidationException(this.message, {this.fieldErrors});
  
  @override
  String toString() => message;
}

class AuthenticationException implements Exception {
  final String message;
  final String? code;
  
  AuthenticationException(this.message, {this.code});
  
  @override
  String toString() => message;
}

class PermissionException implements Exception {
  final String message;
  final String? requiredPermission;
  
  PermissionException(this.message, {this.requiredPermission});
  
  @override
  String toString() => message;
}

class NotFoundException implements Exception {
  final String message;
  final String? resourceType;
  
  NotFoundException(this.message, {this.resourceType});
  
  @override
  String toString() => message;
}

class ConflictException implements Exception {
  final String message;
  final String? conflictReason;
  
  ConflictException(this.message, {this.conflictReason});
  
  @override
  String toString() => message;
}

class BusinessLogicException implements Exception {
  final String message;
  final String? businessRule;
  final Map<String, dynamic>? context;
  
  BusinessLogicException(this.message, {this.businessRule, this.context});
  
  @override
  String toString() => message;
}

// Error Types Enum
enum ErrorType {
  network,
  timeout,
  server,
  authentication,
  permission,
  validation,
  notFound,
  conflict,
  parsing,
  cancelled,
  client,
  state,
  unknown,
}

// Error Dialog Widget
class _ErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;
  final VoidCallback onDismiss;

  const _ErrorDialog({
    required this.title,
    required this.message,
    this.onRetry,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 24,
          ),
          const SizedBox(width: 8),
          Text(title),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.blue.withOpacity(0.1),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Would you like to try again?',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      actions: [
        if (onRetry != null)
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onRetry();
            },
            child: Text('Retry'),
          ),
        TextButton(
          onPressed: onDismiss,
          child: Text('OK'),
        ),
      ],
    );
  }
}

// Validation Utilities
class ValidationUtils {
  // Email Validation
  static bool isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email);
  }
  
  // Phone Validation (Nepal)
  static bool isValidPhone(String phone) {
    return RegExp(r'^[9][6-8]\d{8}$').hasMatch(phone);
  }
  
  // Password Validation
  static bool isValidPassword(String password) {
    if (password.length < 8) return false;
    if (!RegExp(r'[A-Z]').hasMatch(password)) return false;
    if (!RegExp(r'[a-z]').hasMatch(password)) return false;
    if (!RegExp(r'[0-9]').hasMatch(password)) return false;
    return true;
  }
  
  // Name Validation
  static bool isValidName(String name) {
    return RegExp(r'^[a-zA-Z\s]{2,50}$').hasMatch(name);
  }
  
  // Address Validation
  static bool isValidAddress(String address) {
    return address.trim().length >= 10 && address.trim().length <= 200;
  }
  
  // Required Field Validation
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }
  
  // Email Validation with Message
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (!isValidEmail(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }
  
  // Phone Validation with Message
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    if (!isValidPhone(value)) {
      return 'Please enter a valid 10-digit phone number';
    }
    return null;
  }
  
  // Password Validation with Message
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number';
    }
    return null;
  }
  
  // Confirm Password Validation
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }
  
  // Amount Validation
  static String? validateAmount(String? value, {double? min, double? max}) {
    if (value == null || value.trim().isEmpty) {
      return 'Amount is required';
    }
    
    final amount = double.tryParse(value);
    if (amount == null) {
      return 'Please enter a valid amount';
    }
    
    if (min != null && amount < min) {
      return 'Amount must be at least $min';
    }
    
    if (max != null && amount > max) {
      return 'Amount must not exceed $max';
    }
    
    if (amount <= 0) {
      return 'Amount must be greater than 0';
    }
    
    return null;
  }
  
  // Quantity Validation
  static String? validateQuantity(String? value, {int? min, int? max}) {
    if (value == null || value.trim().isEmpty) {
      return 'Quantity is required';
    }
    
    final quantity = int.tryParse(value);
    if (quantity == null) {
      return 'Please enter a valid quantity';
    }
    
    if (min != null && quantity < min) {
      return 'Quantity must be at least $min';
    }
    
    if (max != null && quantity > max) {
      return 'Quantity must not exceed $max';
    }
    
    if (quantity <= 0) {
      return 'Quantity must be greater than 0';
    }
    
    return null;
  }
  
  // URL Validation
  static bool isValidUrl(String url) {
    try {
      Uri.parse(url);
      return true;
    } catch (e) {
      return false;
    }
  }
  
  // Date Validation
  static String? validateDate(DateTime? date, {DateTime? minDate, DateTime? maxDate}) {
    if (date == null) {
      return 'Date is required';
    }
    
    if (minDate != null && date.isBefore(minDate)) {
      return 'Date must be after ${minDate.toString().split(' ')[0]}';
    }
    
    if (maxDate != null && date.isAfter(maxDate)) {
      return 'Date must be before ${maxDate.toString().split(' ')[0]}';
    }
    
    return null;
  }
  
  // Multi-field Validation
  static Map<String, String?> validateFields(Map<String, String> fields) {
    final errors = <String, String?>{};
    
    for (final entry in fields.entries) {
      final error = validateRequired(entry.value, entry.key);
      if (error != null) {
        errors[entry.key] = error;
      }
    }
    
    return errors;
  }
  
  // Custom Validation
  static String? validateCustom(
    String? value,
    String fieldName,
    bool Function(String) validator,
  ) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    
    if (!validator(value)) {
      return 'Invalid $fieldName';
    }
    
    return null;
  }
}

// Error Boundary Widget
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(dynamic error, VoidCallback retry)? errorBuilder;
  
  const ErrorBoundary({
    Key? key,
    required this.child,
    this.errorBuilder,
  }) : super(key: key);

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  dynamic _error;
  
  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      if (widget.errorBuilder != null) {
        return widget.errorBuilder!(_error, _retry);
      }
      
      return _DefaultErrorWidget(
        error: _error,
        onRetry: _retry,
      );
    }
    
    return widget.child;
  }
  
  void _retry() {
    setState(() {
      _error = null;
    });
  }
}

class _DefaultErrorWidget extends StatelessWidget {
  final dynamic error;
  final VoidCallback onRetry;
  
  const _DefaultErrorWidget({
    Key? key,
    required this.error,
    required this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Error'),
        backgroundColor: Colors.red,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Something went wrong',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onRetry,
                child: Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
