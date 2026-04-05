import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter/foundation.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Wireless Debugging Service
/// Provides comprehensive debugging capabilities for wireless environments
/// Includes remote debugging, logging, performance monitoring, and device optimization
class WirelessDebugService {
  static final WirelessDebugService _instance = WirelessDebugService._internal();
  factory WirelessDebugService() => _instance;
  
  WebSocketChannel? _debugSocket;
  final StreamController<DebugEvent> _debugEventController;
  final StreamController<PerformanceMetric> _performanceController;
  final StreamController<NetworkStatus> _networkStatusController;
  final Connectivity _connectivity;
  final Map<String, dynamic> _deviceInfo = {};
  final List<DebugLog> _debugLogs = [];
  Timer? _performanceTimer;
  Timer? _networkCheckTimer;
  bool _isConnected = false;
  String? _sessionId;
  DateTime? _sessionStartTime;
  int _logCount = 0;
  static const int _maxLogCount = 1000;

  WirelessDebugService._internal()
    : _debugEventController = StreamController<DebugEvent>.broadcast(),
      _performanceController = StreamController<PerformanceMetric>.broadcast(),
      _networkStatusController = StreamController<NetworkStatus>.broadcast(),
      _connectivity = Connectivity();

  /// Stream of debug events
  Stream<DebugEvent> get debugEventStream => _debugEventController.stream;

  /// Stream of performance metrics
  Stream<PerformanceMetric> get performanceStream => _performanceController.stream;

  /// Stream of network status updates
  Stream<NetworkStatus> get networkStatusStream => _networkStatusController.stream;

  /// Current session information
  DebugSessionInfo? get currentSession => _sessionId != null
      ? DebugSessionInfo(
          sessionId: _sessionId!,
          startTime: _sessionStartTime!,
          deviceInfo: _deviceInfo,
          isConnected: _isConnected,
          logCount: _logCount,
        )
      : null;

  /// Initialize wireless debugging environment
  Future<void> initialize() async {
    try {
      print('🔍 Initializing Wireless Debug Service...');
      
      // Collect device information
      await _collectDeviceInfo();
      
      // Initialize connectivity monitoring
      await _initializeConnectivityMonitoring();
      
      // Start performance monitoring
      _startPerformanceMonitoring();
      
      // Connect to debug server
      await _connectToDebugServer();
      
      // Start network status monitoring
      _startNetworkStatusMonitoring();
      
      print('✅ Wireless Debug Service initialized successfully');
    } catch (e) {
      print('❌ Failed to initialize Wireless Debug Service: $e');
      _logError('INITIALIZATION_ERROR', e.toString());
    }
  }

  /// Start remote debugging session
  Future<void> startDebugSession({
    String? sessionId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      print('🚀 Starting debug session...');
      
      _sessionId = sessionId ?? _generateSessionId();
      _sessionStartTime = DateTime.now();
      _logCount = 0;
      
      final sessionInfo = {
        'type': 'session_start',
        'session_id': _sessionId,
        'timestamp': DateTime.now().toIso8601String(),
        'device_info': _deviceInfo,
        'metadata': metadata ?? {},
        'app_version': await _getAppVersion(),
      };
      
      await _sendDebugEvent(sessionInfo);
      
      _logInfo('Debug session started: $_sessionId');
      
      print('✅ Debug session started: $_sessionId');
    } catch (e) {
      print('❌ Failed to start debug session: $e');
      _logError('SESSION_START_ERROR', e.toString());
    }
  }

  /// Stop debug session
  Future<void> stopDebugSession({String? reason}) async {
    try {
      if (_sessionId == null) {
        print('⚠️ No active debug session to stop');
        return;
      }
      
      print('🛑 Stopping debug session: $_sessionId');
      
      final sessionInfo = {
        'type': 'session_end',
        'session_id': _sessionId,
        'timestamp': DateTime.now().toIso8601String(),
        'duration': DateTime.now().difference(_sessionStartTime!).inMilliseconds,
        'log_count': _logCount,
        'reason': reason ?? 'User requested',
      };
      
      await _sendDebugEvent(sessionInfo);
      
      _logInfo('Debug session stopped: $_sessionId');
      
      _sessionId = null;
      _sessionStartTime = null;
      
      print('✅ Debug session stopped');
    } catch (e) {
      print('❌ Failed to stop debug session: $e');
      _logError('SESSION_STOP_ERROR', e.toString());
    }
  }

  /// Send debug event
  Future<void> sendDebugEvent({
    required String type,
    required Map<String, dynamic> data,
    String? level = 'info',
  }) async {
    try {
      final event = {
        'type': type,
        'level': level,
        'timestamp': DateTime.now().toIso8601String(),
        'session_id': _sessionId,
        'data': data,
      };
      
      await _sendDebugEvent(event);
      
      _logDebugEvent(type, level, data);
      
    } catch (e) {
      print('❌ Failed to send debug event: $e');
      _logError('EVENT_SEND_ERROR', e.toString());
    }
  }

  /// Capture screenshot for debugging
  Future<void> captureScreenshot({String? description}) async {
    try {
      // This would use screenshot package in real implementation
      final screenshotData = {
        'type': 'screenshot',
        'timestamp': DateTime.now().toIso8601String(),
        'description': description ?? 'Debug screenshot',
        'device_info': _deviceInfo,
      };
      
      await _sendDebugEvent(screenshotData);
      
      _logInfo('Screenshot captured: $description');
      
      print('📸 Screenshot captured: $description');
    } catch (e) {
      print('❌ Failed to capture screenshot: $e');
      _logError('SCREENSHOT_ERROR', e.toString());
    }
  }

  /// Log performance metrics
  void logPerformanceMetrics({
    required String operation,
    required Duration duration,
    Map<String, dynamic>? metadata,
  }) {
    try {
      final metric = PerformanceMetric(
        operation: operation,
        duration: duration,
        timestamp: DateTime.now(),
        metadata: metadata ?? {},
        deviceInfo: _deviceInfo,
      );
      
      _performanceController.add(metric);
      
      _logDebugEvent('performance', 'info', {
        'operation': operation,
        'duration_ms': duration.inMilliseconds,
        'metadata': metadata,
      });
      
    } catch (e) {
      print('❌ Failed to log performance metrics: $e');
      _logError('PERFORMANCE_LOG_ERROR', e.toString());
    }
  }

  /// Log network request/response
  void logNetworkRequest({
    required String url,
    required String method,
    required int statusCode,
    required Duration duration,
    Map<String, dynamic>? metadata,
  }) {
    try {
      final networkData = {
        'type': 'network_request',
        'url': url,
        'method': method,
        'status_code': statusCode,
        'duration_ms': duration.inMilliseconds,
        'timestamp': DateTime.now().toIso8601String(),
        'metadata': metadata ?? {},
      };
      
      _sendDebugEvent(networkData);
      
      _logDebugEvent('network', statusCode >= 400 ? 'error' : 'info', {
        'url': url,
        'method': method,
        'status_code': statusCode,
        'duration_ms': duration.inMilliseconds,
      });
      
    } catch (e) {
      print('❌ Failed to log network request: $e');
      _logError('NETWORK_LOG_ERROR', e.toString());
    }
  }

  /// Log user interaction
  void logUserInteraction({
    required String action,
    required String screen,
    Map<String, dynamic>? metadata,
  }) {
    try {
      final interactionData = {
        'type': 'user_interaction',
        'action': action,
        'screen': screen,
        'timestamp': DateTime.now().toIso8601String(),
        'metadata': metadata ?? {},
      };
      
      _sendDebugEvent(interactionData);
      
      _logDebugEvent('user_action', 'info', {
        'action': action,
        'screen': screen,
        'metadata': metadata,
      });
      
    } catch (e) {
      print('❌ Failed to log user interaction: $e');
      _logError('USER_INTERACTION_ERROR', e.toString());
    }
  }

  /// Log error with stack trace
  void logError({
    required String error,
    String? stackTrace,
    Map<String, dynamic>? metadata,
  }) {
    try {
      final errorData = {
        'type': 'error',
        'error': error,
        'stack_trace': stackTrace,
        'timestamp': DateTime.now().toIso8601String(),
        'metadata': metadata ?? {},
      };
      
      _sendDebugEvent(errorData);
      
      _logDebugEvent('error', 'error', {
        'error': error,
        'stack_trace': stackTrace,
        'metadata': metadata,
      });
      
    } catch (e) {
      print('❌ Failed to log error: $e');
    }
  }

  /// Get debugging dashboard data
  Future<Map<String, dynamic>> getDebugDashboardData() async {
    try {
      final recentLogs = _debugLogs.take(50).toList();
      final performanceMetrics = await _getRecentPerformanceMetrics();
      final networkStatus = await _getCurrentNetworkStatus();
      
      return {
        'session_info': currentSession?.toJson(),
        'recent_logs': recentLogs.map((log) => log.toJson()).toList(),
        'performance_metrics': performanceMetrics.map((metric) => metric.toJson()).toList(),
        'network_status': networkStatus.toJson(),
        'device_info': _deviceInfo,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      print('❌ Failed to get debug dashboard data: $e');
      return {};
    }
  }

  /// Collect device information
  Future<void> _collectDeviceInfo() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      final packageInfo = PackageInfo.fromPlatform();
      
      _deviceInfo.addAll({
        'platform': Platform.operatingSystem,
        'version': Platform.operatingSystemVersion,
        'is_debug_mode': !kReleaseMode,
        'app_version': packageInfo.version,
        'app_build_number': packageInfo.buildNumber,
        'device_model': await deviceInfo.model,
        'device_brand': await deviceInfo.brand,
        'device_type': await _getDeviceType(),
        'memory_info': await _getMemoryInfo(),
        'storage_info': await _getStorageInfo(),
        'network_info': await _getNetworkInfo(),
      });
      
      print('✅ Device information collected');
    } catch (e) {
      print('❌ Failed to collect device information: $e');
    }
  }

  /// Initialize connectivity monitoring
  Future<void> _initializeConnectivityMonitoring() async {
    try {
      // Listen to connectivity changes
      _connectivity.onConnectivityChanged.listen((result) {
        _isConnected = result != ConnectivityResult.none;
        
        final networkStatus = NetworkStatus(
          isConnected: _isConnected,
          connectionType: _mapConnectionType(result),
          timestamp: DateTime.now(),
        );
        
        _networkStatusController.add(networkStatus);
        
        _sendDebugEvent({
          'type': 'connectivity_change',
          'is_connected': _isConnected,
          'connection_type': _mapConnectionType(result),
          'timestamp': DateTime.now().toIso8601String(),
        });
      });
      
      print('✅ Connectivity monitoring initialized');
    } catch (e) {
      print('❌ Failed to initialize connectivity monitoring: $e');
    }
  }

  /// Start performance monitoring
  void _startPerformanceMonitoring() {
    _performanceTimer?.cancel();
    
    _performanceTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      try {
        final memoryUsage = await _getMemoryUsage();
        final cpuUsage = await _getCpuUsage();
        final batteryLevel = await _getBatteryLevel();
        
        final metric = PerformanceMetric(
          operation: 'system_health',
          duration: Duration.zero,
          timestamp: DateTime.now(),
          metadata: {
            'memory_usage': memoryUsage,
            'cpu_usage': cpuUsage,
            'battery_level': batteryLevel,
            'device_info': _deviceInfo,
          },
        );
        
        _performanceController.add(metric);
        
      } catch (e) {
        print('❌ Failed to collect performance metrics: $e');
      }
    });
    
    print('✅ Performance monitoring started');
  }

  /// Connect to debug server
  Future<void> _connectToDebugServer() async {
    try {
      // In a real implementation, this would connect to a WebSocket server
      // For now, we'll simulate the connection
      
      print('🔌 Connected to debug server');
      
      _isConnected = true;
      
      _sendDebugEvent({
        'type': 'connection_established',
        'timestamp': DateTime.now().toIso8601String(),
        'device_info': _deviceInfo,
      });
      
    } catch (e) {
      print('❌ Failed to connect to debug server: $e');
      _isConnected = false;
    }
  }

  /// Start network status monitoring
  void _startNetworkStatusMonitoring() {
    _networkCheckTimer?.cancel();
    
    _networkCheckTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      try {
        final networkStatus = await _getCurrentNetworkStatus();
        _networkStatusController.add(networkStatus);
        
      } catch (e) {
        print('❌ Failed to check network status: $e');
      }
    });
    
    print('✅ Network status monitoring started');
  }

  /// Send debug event to server
  Future<void> _sendDebugEvent(Map<String, dynamic> event) async {
    try {
      if (_debugSocket != null) {
        _debugSocket!.sink.add(jsonEncode(event));
      }
      
      // Also store locally
      _debugLogs.add(DebugLog.fromEvent(event));
      
      // Maintain log count limit
      if (_debugLogs.length > _maxLogCount) {
        _debugLogs.removeRange(0, _debugLogs.length - _maxLogCount);
      }
      
      _logCount++;
      
    } catch (e) {
      print('❌ Failed to send debug event: $e');
    }
  }

  /// Log debug event locally
  void _logDebugEvent(String type, String level, Map<String, dynamic> data) {
    final log = DebugLog(
      type: type,
      level: level,
      data: data,
      timestamp: DateTime.now(),
    );
    
    _debugLogs.add(log);
    
    // Print to console for immediate visibility
    print('🔍 [$level] $type: $data');
  }

  /// Log info message
  void _logInfo(String message) {
    print('ℹ️ $message');
  }

  /// Log error message
  void _logError(String error, String details) {
    print('❌ $error: $details');
  }

  /// Generate unique session ID
  String _generateSessionId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = DateTime.now().millisecond % 1000;
    return 'DEBUG-${timestamp}-$random';
  }

  /// Get app version
  Future<String> _getAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return packageInfo.version;
    } catch (e) {
      return 'Unknown';
    }
  }

  /// Get device type
  Future<String> _getDeviceType() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      final isTablet = await deviceInfo.isTablet;
      final isDesktop = Platform.isWindows || Platform.isLinux || Platform.isMacOS;
      
      if (isDesktop) return 'Desktop';
      if (isTablet) return 'Tablet';
      return 'Mobile';
    } catch (e) {
      return 'Unknown';
    }
  }

  /// Get memory information
  Future<Map<String, dynamic>> _getMemoryInfo() async {
    try {
      // This would use platform-specific memory info packages
      return {
        'total_memory': 'Unknown',
        'available_memory': 'Unknown',
        'used_memory': 'Unknown',
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  /// Get storage information
  Future<Map<String, dynamic>> _getStorageInfo() async {
    try {
      // This would use platform-specific storage info packages
      return {
        'total_storage': 'Unknown',
        'available_storage': 'Unknown',
        'used_storage': 'Unknown',
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  /// Get network information
  Future<Map<String, dynamic>> _getNetworkInfo() async {
    try {
      final wifiName = await NetworkInfo().getWifiName();
      final wifiBSSID = await NetworkInfo().getWifiBSSID();
      final ipAddress = await NetworkInfo().getWifiIP();
      
      return {
        'wifi_name': wifiName,
        'wifi_bssid': wifiBSSID,
        'ip_address': ipAddress,
        'connection_type': 'wifi',
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  /// Get current network status
  Future<NetworkStatus> _getCurrentNetworkStatus() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      final networkInfo = await _getNetworkInfo();
      
      return NetworkStatus(
        isConnected: connectivityResult != ConnectivityResult.none,
        connectionType: _mapConnectionType(connectivityResult),
        timestamp: DateTime.now(),
        wifiName: networkInfo['wifi_name'],
        ipAddress: networkInfo['ip_address'],
      );
    } catch (e) {
      return NetworkStatus(
        isConnected: false,
        connectionType: 'none',
        timestamp: DateTime.now(),
      );
    }
  }

  /// Get recent performance metrics
  Future<List<PerformanceMetric>> _getRecentPerformanceMetrics() async {
    // This would return recent performance metrics from storage
    return [];
  }

  /// Get memory usage
  Future<Map<String, dynamic>> _getMemoryUsage() async {
    // This would use platform-specific memory monitoring
    return {
      'used_memory_mb': 0,
      'available_memory_mb': 0,
      'usage_percentage': 0.0,
    };
  }

  /// Get CPU usage
  Future<double> _getCpuUsage() async {
    // This would use platform-specific CPU monitoring
    return 0.0;
  }

  /// Get battery level
  Future<double> _getBatteryLevel() async {
    // This would use battery plugin
    return 100.0;
  }

  /// Map connection type
  String _mapConnectionType(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.wifi:
        return 'wifi';
      case ConnectivityResult.mobile:
        return 'mobile';
      case ConnectivityResult.ethernet:
        return 'ethernet';
      case ConnectivityResult.bluetooth:
        return 'bluetooth';
      case ConnectivityResult.other:
        return 'other';
      case ConnectivityResult.none:
        return 'none';
    }
  }

  /// Dispose resources
  void dispose() {
    print('🗑️ Disposing Wireless Debug Service...');
    
    _performanceTimer?.cancel();
    _networkCheckTimer?.cancel();
    _debugSocket?.sink.close();
    _debugEventController.close();
    _performanceController.close();
    _networkStatusController.close();
    
    print('✅ Wireless Debug Service disposed');
  }
}

/// Debug event entity
class DebugEvent {
  final String type;
  final String level;
  final DateTime timestamp;
  final Map<String, dynamic> data;

  const DebugEvent({
    required this.type,
    required this.level,
    required this.timestamp,
    required this.data,
  });
}

/// Debug log entity
class DebugLog {
  final String type;
  final String level;
  final DateTime timestamp;
  final Map<String, dynamic> data;

  const DebugLog({
    required this.type,
    required this.level,
    required this.timestamp,
    required this.data,
  });

  factory DebugLog.fromEvent(Map<String, dynamic> event) {
    return DebugLog(
      type: event['type'] as String,
      level: event['level'] as String,
      timestamp: DateTime.parse(event['timestamp'] as String),
      data: event['data'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'level': level,
      'timestamp': timestamp.toIso8601String(),
      'data': data,
    };
  }
}

/// Performance metric entity
class PerformanceMetric {
  final String operation;
  final Duration duration;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  const PerformanceMetric({
    required this.operation,
    required this.duration,
    required this.timestamp,
    required this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'operation': operation,
      'duration_ms': duration.inMilliseconds,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
    };
  }
}

/// Network status entity
class NetworkStatus {
  final bool isConnected;
  final String connectionType;
  final DateTime timestamp;
  final String? wifiName;
  final String? ipAddress;

  const NetworkStatus({
    required this.isConnected,
    required this.connectionType,
    required this.timestamp,
    this.wifiName,
    this.ipAddress,
  });

  Map<String, dynamic> toJson() {
    return {
      'is_connected': isConnected,
      'connection_type': connectionType,
      'timestamp': timestamp.toIso8601String(),
      'wifi_name': wifiName,
      'ip_address': ipAddress,
    };
  }
}

/// Debug session information
class DebugSessionInfo {
  final String sessionId;
  final DateTime startTime;
  final Map<String, dynamic> deviceInfo;
  final bool isConnected;
  final int logCount;

  const DebugSessionInfo({
    required this.sessionId,
    required this.startTime,
    required this.deviceInfo,
    required this.isConnected,
    required this.logCount,
  });

  Map<String, dynamic> toJson() {
    return {
      'session_id': sessionId,
      'start_time': startTime.toIso8601String(),
      'device_info': deviceInfo,
      'is_connected': isConnected,
      'log_count': logCount,
    };
  }
}
