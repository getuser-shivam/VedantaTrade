import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:vedanta_trade/core/api_config.dart';

/// Security Event Notification Service
/// Manages security event notifications and alerts
class SecurityNotificationService {
  static const String _notificationPreferencesKey = 'security_notification_preferences';
  static const String _lastNotificationCheckKey = 'last_notification_check';
  
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock_this_device),
  );
  
  final Dio _dio = Dio();
  
  SecurityNotificationService() {
    _dio.options.baseUrl = ApiConfig.baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 15);
    _dio.options.receiveTimeout = const Duration(seconds: 15);
    _dio.options.headers = {'Content-Type': 'application/json'};
  }
  
  /// Get notification preferences
  Future<NotificationPreferences> getNotificationPreferences() async {
    try {
      final preferencesStr = await _secureStorage.read(key: _notificationPreferencesKey);
      if (preferencesStr != null) {
        final preferences = jsonDecode(preferencesStr);
        return NotificationPreferences.fromJson(preferences);
      }
      
      // Return default preferences
      return NotificationPreferences.defaults();
    } catch (e) {
      return NotificationPreferences.defaults();
    }
  }
  
  /// Update notification preferences
  Future<bool> updateNotificationPreferences(NotificationPreferences preferences) async {
    try {
      final token = await _getStoredToken();
      if (token == null) return false;
      
      final response = await _dio.post(
        '/auth/security/notifications/preferences',
        data: preferences.toJson(),
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          await _secureStorage.write(
            key: _notificationPreferencesKey,
            value: jsonEncode(preferences.toJson()),
          );
          return true;
        }
      }
      
      return false;
    } catch (e) {
      return false;
    }
  }
  
  /// Get security notifications
  Future<List<SecurityNotification>> getSecurityNotifications({
    DateTime? since,
    int limit = 50,
  }) async {
    try {
      final token = await _getStoredToken();
      if (token == null) return [];
      
      final response = await _dio.get(
        '/auth/security/notifications',
        queryParameters: {
          if (since != null) 'since': since.toIso8601String(),
          'limit': limit,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return List<SecurityNotification>.from(
            data['notifications'].map((n) => SecurityNotification.fromJson(n))
          );
        }
      }
      
      return [];
    } catch (e) {
      return [];
    }
  }
  
  /// Mark notification as read
  Future<bool> markNotificationAsRead(String notificationId) async {
    try {
      final token = await _getStoredToken();
      if (token == null) return false;
      
      final response = await _dio.post(
        '/auth/security/notifications/$notificationId/read',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  
  /// Mark all notifications as read
  Future<bool> markAllNotificationsAsRead() async {
    try {
      final token = await _getStoredToken();
      if (token == null) return false;
      
      final response = await _dio.post(
        '/auth/security/notifications/read-all',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  
  /// Delete notification
  Future<bool> deleteNotification(String notificationId) async {
    try {
      final token = await _getStoredToken();
      if (token == null) return false;
      
      final response = await _dio.delete(
        '/auth/security/notifications/$notificationId',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  
  /// Get unread notification count
  Future<int> getUnreadNotificationCount() async {
    try {
      final token = await _getStoredToken();
      if (token == null) return 0;
      
      final response = await _dio.get(
        '/auth/security/notifications/unread-count',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        return data['count'] ?? 0;
      }
      
      return 0;
    } catch (e) {
      return 0;
    }
  }
  
  /// Subscribe to security event notifications
  Future<bool> subscribeToSecurityEvents({
    required List<SecurityEventType> eventTypes,
    required NotificationChannel channel,
  }) async {
    try {
      final token = await _getStoredToken();
      if (token == null) return false;
      
      final response = await _dio.post(
        '/auth/security/notifications/subscribe',
        data: {
          'event_types': eventTypes.map((e) => e.name).toList(),
          'channel': channel.name,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  
  /// Unsubscribe from security event notifications
  Future<bool> unsubscribeFromSecurityEvents({
    required List<SecurityEventType> eventTypes,
  }) async {
    try {
      final token = await _getStoredToken();
      if (token == null) return false;
      
      final response = await _dio.post(
        '/auth/security/notifications/unsubscribe',
        data: {
          'event_types': eventTypes.map((e) => e.name).toList(),
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  
  /// Get notification channels
  Future<List<NotificationChannel>> getNotificationChannels() async {
    try {
      final token = await _getStoredToken();
      if (token == null) return [];
      
      final response = await _dio.get(
        '/auth/security/notifications/channels',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return List<NotificationChannel>.from(
            data['channels'].map((c) => NotificationChannel.values.firstWhere(
              (ch) => ch.name == c,
              orElse: () => NotificationChannel.inApp,
            ))
          );
        }
      }
      
      return [];
    } catch (e) {
      return [];
    }
  }
  
  /// Send test notification
  Future<bool> sendTestNotification(SecurityEventType eventType) async {
    try {
      final token = await _getStoredToken();
      if (token == null) return false;
      
      final response = await _dio.post(
        '/auth/security/notifications/test',
        data: {
          'event_type': eventType.name,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  
  /// Get notification history
  Future<List<SecurityNotification>> getNotificationHistory({
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final token = await _getStoredToken();
      if (token == null) return [];
      
      final response = await _dio.get(
        '/auth/security/notifications/history',
        queryParameters: {
          if (startDate != null) 'start_date': startDate.toIso8601String(),
          if (endDate != null) 'end_date': endDate.toIso8601String(),
          'page': page,
          'limit': limit,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return List<SecurityNotification>.from(
            data['notifications'].map((n) => SecurityNotification.fromJson(n))
          );
        }
      }
      
      return [];
    } catch (e) {
      return [];
    }
  }
  
  /// Get stored token
  Future<String?> _getStoredToken() async {
    return await _secureStorage.read(key: 'access_token');
  }
}

/// Security Notification
class SecurityNotification {
  final String id;
  final SecurityEventType eventType;
  final String title;
  final String message;
  final DateTime createdAt;
  final bool isRead;
  final NotificationPriority priority;
  final String? actionUrl;
  final Map<String, dynamic> metadata;
  
  SecurityNotification({
    required this.id,
    required this.eventType,
    required this.title,
    required this.message,
    required this.createdAt,
    required this.isRead,
    required this.priority,
    this.actionUrl,
    this.metadata = const {},
  });
  
  factory SecurityNotification.fromJson(Map<String, dynamic> json) {
    return SecurityNotification(
      id: json['id']?.toString() ?? '',
      eventType: SecurityEventType.values.firstWhere(
        (type) => type.name == json['event_type'],
        orElse: () => SecurityEventType.loginSuccess,
      ),
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      isRead: json['is_read'] ?? false,
      priority: NotificationPriority.values.firstWhere(
        (p) => p.name == json['priority'],
        orElse: () => NotificationPriority.medium,
      ),
      actionUrl: json['action_url']?.toString(),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }
}

/// Security Event Type
enum SecurityEventType {
  loginSuccess,
  loginFailed,
  accountLocked,
  passwordChanged,
  mfaEnabled,
  mfaDisabled,
  deviceAdded,
  deviceRemoved,
  suspiciousActivity,
  sessionTerminated,
  passwordResetRequested,
  oauthLogin,
  biometricEnabled,
  biometricDisabled,
}

/// Notification Priority
enum NotificationPriority {
  low,
  medium,
  high,
  critical,
}

/// Notification Channel
enum NotificationChannel {
  inApp,
  email,
  sms,
  push,
}

/// Notification Preferences
class NotificationPreferences {
  final bool enableLoginNotifications;
  final bool enableSecurityAlerts;
  final bool enableDeviceNotifications;
  final bool enablePasswordNotifications;
  final bool enableMfaNotifications;
  final List<NotificationChannel> preferredChannels;
  final List<SecurityEventType> subscribedEvents;
  final bool quietHoursEnabled;
  final int quietHoursStart;
  final int quietHoursEnd;
  
  NotificationPreferences({
    required this.enableLoginNotifications,
    required this.enableSecurityAlerts,
    required this.enableDeviceNotifications,
    required this.enablePasswordNotifications,
    required this.enableMfaNotifications,
    required this.preferredChannels,
    required this.subscribedEvents,
    required this.quietHoursEnabled,
    required this.quietHoursStart,
    required this.quietHoursEnd,
  });
  
  factory NotificationPreferences.defaults() {
    return NotificationPreferences(
      enableLoginNotifications: true,
      enableSecurityAlerts: true,
      enableDeviceNotifications: true,
      enablePasswordNotifications: true,
      enableMfaNotifications: true,
      preferredChannels: [NotificationChannel.inApp, NotificationChannel.email],
      subscribedEvents: SecurityEventType.values,
      quietHoursEnabled: false,
      quietHoursStart: 22, // 10 PM
      quietHoursEnd: 8,   // 8 AM
    );
  }
  
  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    return NotificationPreferences(
      enableLoginNotifications: json['enable_login_notifications'] ?? true,
      enableSecurityAlerts: json['enable_security_alerts'] ?? true,
      enableDeviceNotifications: json['enable_device_notifications'] ?? true,
      enablePasswordNotifications: json['enable_password_notifications'] ?? true,
      enableMfaNotifications: json['enable_mfa_notifications'] ?? true,
      preferredChannels: List<NotificationChannel>.from(
        (json['preferred_channels'] ?? ['inApp', 'email']).map((c) => 
          NotificationChannel.values.firstWhere(
            (ch) => ch.name == c,
            orElse: () => NotificationChannel.inApp,
          )
        )
      ),
      subscribedEvents: List<SecurityEventType>.from(
        (json['subscribed_events'] ?? SecurityEventType.values.map((e) => e.name)).map((e) =>
          SecurityEventType.values.firstWhere(
            (ev) => ev.name == e,
            orElse: () => SecurityEventType.loginSuccess,
          )
        )
      ),
      quietHoursEnabled: json['quiet_hours_enabled'] ?? false,
      quietHoursStart: json['quiet_hours_start'] ?? 22,
      quietHoursEnd: json['quiet_hours_end'] ?? 8,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'enable_login_notifications': enableLoginNotifications,
      'enable_security_alerts': enableSecurityAlerts,
      'enable_device_notifications': enableDeviceNotifications,
      'enable_password_notifications': enablePasswordNotifications,
      'enable_mfa_notifications': enableMfaNotifications,
      'preferred_channels': preferredChannels.map((c) => c.name).toList(),
      'subscribed_events': subscribedEvents.map((e) => e.name).toList(),
      'quiet_hours_enabled': quietHoursEnabled,
      'quiet_hours_start': quietHoursStart,
      'quiet_hours_end': quietHoursEnd,
    };
  }
}
