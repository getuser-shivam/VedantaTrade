import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:vedanta_trade/core/api_config.dart';

/// Session Management Service
/// Manages user sessions, device tracking, and concurrent session control
class SessionManagementService {
  static const String _currentSessionKey = 'current_session';
  static const String _sessionsListKey = 'sessions_list';
  static const String _deviceIdKey = 'device_id';
  
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock_this_device),
  );
  
  final Dio _dio = Dio();
  
  SessionManagementService() {
    _dio.options.baseUrl = ApiConfig.baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 15);
    _dio.options.receiveTimeout = const Duration(seconds: 15);
    _dio.options.headers = {'Content-Type': 'application/json'};
  }
  
  /// Get or generate device ID
  Future<String> getDeviceId() async {
    String? deviceId = await _secureStorage.read(key: _deviceIdKey);
    if (deviceId == null) {
      deviceId = _generateDeviceId();
      await _secureStorage.write(key: _deviceIdKey, value: deviceId);
    }
    return deviceId;
  }
  
  /// Create new session
  Future<SessionResult> createSession({
    required String userId,
    required String accessToken,
    required String refreshToken,
    required DateTime expiresAt,
    Map<String, dynamic>? deviceInfo,
  }) async {
    try {
      final deviceId = await getDeviceId();
      
      final response = await _dio.post(
        '/auth/sessions/create',
        data: {
          'user_id': userId,
          'device_id': deviceId,
          'access_token': accessToken,
          'refresh_token': refreshToken,
          'expires_at': expiresAt.toIso8601String(),
          'device_info': deviceInfo ?? await _getDeviceInfo(),
          'ip_address': await _getIpAddress(),
          'user_agent': await _getUserAgent(),
        },
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          final session = data['session'];
          
          // Store current session
          await _storeCurrentSession(session);
          
          // Update sessions list
          await _updateSessionsList(session);
          
          return SessionResult(
            success: true,
            session: Session.fromJson(session),
            message: 'Session created successfully',
          );
        }
      }
      
      return SessionResult(
        success: false,
        error: data['message'] ?? 'Failed to create session',
      );
    } catch (e) {
      return SessionResult(
        success: false,
        error: 'Failed to create session: ${e.toString()}',
      );
    }
  }
  
  /// Get current session
  Future<Session?> getCurrentSession() async {
    try {
      final sessionStr = await _secureStorage.read(key: _currentSessionKey);
      if (sessionStr == null) return null;
      
      final sessionData = jsonDecode(sessionStr);
      return Session.fromJson(sessionData);
    } catch (e) {
      return null;
    }
  }
  
  /// Get all user sessions
  Future<List<Session>> getUserSessions() async {
    try {
      final token = await _secureStorage.read(key: 'access_token');
      if (token == null) return [];
      
      final response = await _dio.get(
        '/auth/sessions/list',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return List<Session>.from(
            data['sessions'].map((s) => Session.fromJson(s))
          );
        }
      }
      
      return [];
    } catch (e) {
      return [];
    }
  }
  
  /// Terminate specific session
  Future<SessionResult> terminateSession(String sessionId) async {
    try {
      final token = await _secureStorage.read(key: 'access_token');
      if (token == null) {
        return SessionResult(
          success: false,
          error: 'No authentication token found',
        );
      }
      
      final response = await _dio.post(
        '/auth/sessions/terminate',
        data: {
          'session_id': sessionId,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          // If terminating current session, clear local storage
          final currentSession = await getCurrentSession();
          if (currentSession != null && currentSession.id == sessionId) {
            await _clearCurrentSession();
          }
          
          return SessionResult(
            success: true,
            message: 'Session terminated successfully',
          );
        }
      }
      
      return SessionResult(
        success: false,
        error: data['message'] ?? 'Failed to terminate session',
      );
    } catch (e) {
      return SessionResult(
        success: false,
        error: 'Failed to terminate session: ${e.toString()}',
      );
    }
  }
  
  /// Terminate all other sessions except current
  Future<SessionResult> terminateOtherSessions() async {
    try {
      final token = await _secureStorage.read(key: 'access_token');
      if (token == null) {
        return SessionResult(
          success: false,
          error: 'No authentication token found',
        );
      }
      
      final currentSession = await getCurrentSession();
      if (currentSession == null) {
        return SessionResult(
          success: false,
          error: 'No current session found',
        );
      }
      
      final response = await _dio.post(
        '/auth/sessions/terminate-others',
        data: {
          'current_session_id': currentSession.id,
          'device_id': await getDeviceId(),
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return SessionResult(
            success: true,
            message: 'All other sessions terminated',
          );
        }
      }
      
      return SessionResult(
        success: false,
        error: data['message'] ?? 'Failed to terminate other sessions',
      );
    } catch (e) {
      return SessionResult(
        success: false,
        error: 'Failed to terminate other sessions: ${e.toString()}',
      );
    }
  }
  
  /// Terminate all sessions
  Future<SessionResult> terminateAllSessions() async {
    try {
      final token = await _secureStorage.read(key: 'access_token');
      if (token == null) {
        return SessionResult(
          success: false,
          error: 'No authentication token found',
        );
      }
      
      final response = await _dio.post(
        '/auth/sessions/terminate-all',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          await _clearCurrentSession();
          await _clearSessionsList();
          
          return SessionResult(
            success: true,
            message: 'All sessions terminated',
          );
        }
      }
      
      return SessionResult(
        success: false,
        error: data['message'] ?? 'Failed to terminate all sessions',
      );
    } catch (e) {
      return SessionResult(
        success: false,
        error: 'Failed to terminate all sessions: ${e.toString()}',
      );
    }
  }
  
  /// Validate current session
  Future<bool> validateCurrentSession() async {
    try {
      final currentSession = await getCurrentSession();
      if (currentSession == null) return false;
      
      // Check if session is expired
      if (DateTime.now().isAfter(currentSession.expiresAt)) {
        await _clearCurrentSession();
        return false;
      }
      
      // Validate with server
      final token = await _secureStorage.read(key: 'access_token');
      if (token == null) return false;
      
      final response = await _dio.get(
        '/auth/sessions/validate/${currentSession.id}',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['valid'] == true) {
          // Update last activity
          await _updateSessionActivity(currentSession.id);
          return true;
        }
      }
      
      await _clearCurrentSession();
      return false;
    } catch (e) {
      await _clearCurrentSession();
      return false;
    }
  }
  
  /// Update session activity
  Future<void> _updateSessionActivity(String sessionId) async {
    try {
      final token = await _secureStorage.read(key: 'access_token');
      if (token == null) return;
      
      await _dio.post(
        '/auth/sessions/update-activity',
        data: {
          'session_id': sessionId,
          'last_activity': DateTime.now().toIso8601String(),
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
    } catch (e) {
      // Continue even if update fails
    }
  }
  
  /// Get session statistics
  Future<SessionStatistics> getSessionStatistics() async {
    try {
      final token = await _secureStorage.read(key: 'access_token');
      if (token == null) {
        return SessionStatistics();
      }
      
      final response = await _dio.get(
        '/auth/sessions/statistics',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        return SessionStatistics.fromJson(data);
      }
      
      return SessionStatistics();
    } catch (e) {
      return SessionStatistics();
    }
  }
  
  /// Store current session
  Future<void> _storeCurrentSession(Map<String, dynamic> session) async {
    await _secureStorage.write(
      key: _currentSessionKey,
      value: jsonEncode(session),
    );
  }
  
  /// Clear current session
  Future<void> _clearCurrentSession() async {
    await _secureStorage.delete(key: _currentSessionKey);
  }
  
  /// Update sessions list
  Future<void> _updateSessionsList(Map<String, dynamic> session) async {
    final sessionsListStr = await _secureStorage.read(key: _sessionsListKey);
    List<Map<String, dynamic>> sessionsList = [];
    
    if (sessionsListStr != null) {
      try {
        sessionsList = List<Map<String, dynamic>>.from(jsonDecode(sessionsListStr));
      } catch (e) {
        sessionsList = [];
      }
    }
    
    // Add or update session
    final index = sessionsList.indexWhere((s) => s['id'] == session['id']);
    if (index >= 0) {
      sessionsList[index] = session;
    } else {
      sessionsList.add(session);
    }
    
    // Keep only last 10 sessions
    if (sessionsList.length > 10) {
      sessionsList = sessionsList.sublist(sessionsList.length - 10);
    }
    
    await _secureStorage.write(
      key: _sessionsListKey,
      value: jsonEncode(sessionsList),
    );
  }
  
  /// Clear sessions list
  Future<void> _clearSessionsList() async {
    await _secureStorage.delete(key: _sessionsListKey);
  }
  
  /// Generate device ID
  String _generateDeviceId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = DateTime.now().microsecondsSinceEpoch;
    final combined = '$timestamp-$random-device';
    return sha256.convert(utf8.encode(combined)).toString().substring(0, 32);
  }
  
  /// Get device information
  Future<Map<String, dynamic>> _getDeviceInfo() async {
    return {
      'platform': 'mobile',
      'user_agent': 'VedantaTrade Mobile App',
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
  
  /// Get IP address
  Future<String> _getIpAddress() async {
    try {
      final response = await _dio.get('https://api.ipify.org?format=json');
      return response.data['ip'] ?? 'unknown';
    } catch (e) {
      return 'unknown';
    }
  }
  
  /// Get user agent
  Future<String> _getUserAgent() async {
    return 'VedantaTrade/Mobile';
  }
}

/// Session Model
class Session {
  final String id;
  final String userId;
  final String deviceId;
  final String ipAddress;
  final String userAgent;
  final DateTime createdAt;
  final DateTime expiresAt;
  final DateTime? lastActivityAt;
  final bool isActive;
  final String? location;
  final Map<String, dynamic> deviceInfo;
  
  Session({
    required this.id,
    required this.userId,
    required this.deviceId,
    required this.ipAddress,
    required this.userAgent,
    required this.createdAt,
    required this.expiresAt,
    this.lastActivityAt,
    required this.isActive,
    this.location,
    required this.deviceInfo,
  });
  
  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      deviceId: json['device_id']?.toString() ?? '',
      ipAddress: json['ip_address']?.toString() ?? '',
      userAgent: json['user_agent']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      expiresAt: DateTime.tryParse(json['expires_at'] ?? '') ?? DateTime.now(),
      lastActivityAt: json['last_activity_at'] != null 
          ? DateTime.tryParse(json['last_activity_at']) 
          : null,
      isActive: json['is_active'] ?? true,
      location: json['location']?.toString(),
      deviceInfo: Map<String, dynamic>.from(json['device_info'] ?? {}),
    );
  }
}

/// Session Result
class SessionResult {
  final bool success;
  final String? error;
  final String? message;
  final Session? session;
  
  const SessionResult({
    required this.success,
    this.error,
    this.message,
    this.session,
  });
}

/// Session Statistics
class SessionStatistics {
  final int totalSessions;
  final int activeSessions;
  final int expiredSessions;
  final int maxConcurrentSessions;
  final DateTime? lastLoginAt;
  final Map<String, int> sessionsByPlatform;
  final Map<String, int> sessionsByLocation;
  
  const SessionStatistics({
    this.totalSessions = 0,
    this.activeSessions = 0,
    this.expiredSessions = 0,
    this.maxConcurrentSessions = 3,
    this.lastLoginAt,
    this.sessionsByPlatform = const {},
    this.sessionsByLocation = const {},
  });
  
  factory SessionStatistics.fromJson(Map<String, dynamic> json) {
    return SessionStatistics(
      totalSessions: json['total_sessions'] ?? 0,
      activeSessions: json['active_sessions'] ?? 0,
      expiredSessions: json['expired_sessions'] ?? 0,
      maxConcurrentSessions: json['max_concurrent_sessions'] ?? 3,
      lastLoginAt: json['last_login_at'] != null 
          ? DateTime.tryParse(json['last_login_at']) 
          : null,
      sessionsByPlatform: Map<String, int>.from(json['sessions_by_platform'] ?? {}),
      sessionsByLocation: Map<String, int>.from(json['sessions_by_location'] ?? {}),
    );
  }
}
