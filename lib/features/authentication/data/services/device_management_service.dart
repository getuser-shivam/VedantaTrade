import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:vedanta_trade/core/api_config.dart';

/// Device Management Service
/// Manages trusted devices, device trust levels, and device security settings
class DeviceManagementService {
  static const String _trustedDevicesKey = 'trusted_devices';
  static const String _currentDeviceKey = 'current_device';
  static const String _deviceIdKey = 'device_id';
  
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock_this_device),
  );
  
  final Dio _dio = Dio();
  
  DeviceManagementService() {
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
  
  /// Get current device information
  Future<Device> getCurrentDevice() async {
    try {
      final deviceId = await getDeviceId();
      final deviceStr = await _secureStorage.read(key: _currentDeviceKey);
      
      if (deviceStr != null) {
        final deviceData = jsonDecode(deviceStr);
        return Device.fromJson(deviceData);
      }
      
      // Create new device record
      final device = Device(
        id: deviceId,
        name: await _getDeviceName(),
        platform: await _getPlatform(),
        deviceType: await _getDeviceType(),
        isTrusted: false,
        trustLevel: DeviceTrustLevel.unknown,
        lastSeenAt: DateTime.now(),
        registeredAt: DateTime.now(),
        deviceInfo: await _getDeviceInfo(),
      );
      
      await _storeCurrentDevice(device);
      return device;
    } catch (e) {
      return Device(
        id: await getDeviceId(),
        name: 'Unknown Device',
        platform: 'unknown',
        deviceType: DeviceType.unknown,
        isTrusted: false,
        trustLevel: DeviceTrustLevel.unknown,
        lastSeenAt: DateTime.now(),
        registeredAt: DateTime.now(),
        deviceInfo: {},
      );
    }
  }
  
  /// Register current device
  Future<DeviceManagementResult> registerDevice({
    required String userId,
    String? deviceName,
  }) async {
    try {
      final deviceId = await getDeviceId();
      final deviceInfo = await _getDeviceInfo();
      
      final response = await _dio.post(
        '/auth/devices/register',
        data: {
          'user_id': userId,
          'device_id': deviceId,
          'device_name': deviceName ?? await _getDeviceName(),
          'platform': await _getPlatform(),
          'device_type': (await _getDeviceType()).name,
          'device_info': deviceInfo,
        },
        options: Options(
          headers: {'Authorization': 'Bearer ${await _getStoredToken()}'},
        ),
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          final device = Device.fromJson(data['device']);
          await _storeCurrentDevice(device);
          await _updateTrustedDevices(device);
          
          return DeviceManagementResult(
            success: true,
            device: device,
            message: 'Device registered successfully',
          );
        }
      }
      
      return DeviceManagementResult(
        success: false,
        error: data['message'] ?? 'Failed to register device',
      );
    } catch (e) {
      return DeviceManagementResult(
        success: false,
        error: 'Failed to register device: ${e.toString()}',
      );
    }
  }
  
  /// Get all trusted devices for user
  Future<List<Device>> getTrustedDevices() async {
    try {
      final token = await _getStoredToken();
      if (token == null) return [];
      
      final response = await _dio.get(
        '/auth/devices/trusted',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return List<Device>.from(
            data['devices'].map((d) => Device.fromJson(d))
          );
        }
      }
      
      return [];
    } catch (e) {
      return [];
    }
  }
  
  /// Trust a device
  Future<DeviceManagementResult> trustDevice({
    required String deviceId,
    DeviceTrustLevel trustLevel = DeviceTrustLevel.trusted,
  }) async {
    try {
      final token = await _getStoredToken();
      if (token == null) {
        return DeviceManagementResult(
          success: false,
          error: 'No authentication token',
        );
      }
      
      final response = await _dio.post(
        '/auth/devices/trust',
        data: {
          'device_id': deviceId,
          'trust_level': trustLevel.name,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          final device = Device.fromJson(data['device']);
          await _updateTrustedDevices(device);
          
          return DeviceManagementResult(
            success: true,
            device: device,
            message: 'Device trusted successfully',
          );
        }
      }
      
      return DeviceManagementResult(
        success: false,
        error: data['message'] ?? 'Failed to trust device',
      );
    } catch (e) {
      return DeviceManagementResult(
        success: false,
        error: 'Failed to trust device: ${e.toString()}',
      );
    }
  }
  
  /// Untrust a device
  Future<DeviceManagementResult> untrustDevice(String deviceId) async {
    try {
      final token = await _getStoredToken();
      if (token == null) {
        return DeviceManagementResult(
          success: false,
          error: 'No authentication token',
        );
      }
      
      final response = await _dio.post(
        '/auth/devices/untrust',
        data: {
          'device_id': deviceId,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          await _removeTrustedDevice(deviceId);
          
          return DeviceManagementResult(
            success: true,
            message: 'Device untrusted successfully',
          );
        }
      }
      
      return DeviceManagementResult(
        success: false,
        error: data['message'] ?? 'Failed to untrust device',
      );
    } catch (e) {
      return DeviceManagementResult(
        success: false,
        error: 'Failed to untrust device: ${e.toString()}',
      );
    }
  }
  
  /// Remove a device
  Future<DeviceManagementResult> removeDevice(String deviceId) async {
    try {
      final token = await _getStoredToken();
      if (token == null) {
        return DeviceManagementResult(
          success: false,
          error: 'No authentication token',
        );
      }
      
      final response = await _dio.post(
        '/auth/devices/remove',
        data: {
          'device_id': deviceId,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          await _removeTrustedDevice(deviceId);
          
          return DeviceManagementResult(
            success: true,
            message: 'Device removed successfully',
          );
        }
      }
      
      return DeviceManagementResult(
        success: false,
        error: data['message'] ?? 'Failed to remove device',
      );
    } catch (e) {
      return DeviceManagementResult(
        success: false,
        error: 'Failed to remove device: ${e.toString()}',
      );
    }
  }
  
  /// Update device information
  Future<DeviceManagementResult> updateDevice({
    required String deviceId,
    String? deviceName,
    DeviceTrustLevel? trustLevel,
  }) async {
    try {
      final token = await _getStoredToken();
      if (token == null) {
        return DeviceManagementResult(
          success: false,
          error: 'No authentication token',
        );
      }
      
      final response = await _dio.post(
        '/auth/devices/update',
        data: {
          'device_id': deviceId,
          if (deviceName != null) 'device_name': deviceName,
          if (trustLevel != null) 'trust_level': trustLevel.name,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          final device = Device.fromJson(data['device']);
          await _updateTrustedDevices(device);
          
          return DeviceManagementResult(
            success: true,
            device: device,
            message: 'Device updated successfully',
          );
        }
      }
      
      return DeviceManagementResult(
        success: false,
        error: data['message'] ?? 'Failed to update device',
      );
    } catch (e) {
      return DeviceManagementResult(
        success: false,
        error: 'Failed to update device: ${e.toString()}',
      );
    }
  }
  
  /// Check if device is trusted
  Future<bool> isDeviceTrusted(String deviceId) async {
    try {
      final trustedDevices = await getTrustedDevices();
      return trustedDevices.any((d) => d.id == deviceId && d.isTrusted);
    } catch (e) {
      return false;
    }
  }
  
  /// Get device security recommendations
  Future<List<SecurityRecommendation>> getDeviceSecurityRecommendations() async {
    try {
      final token = await _getStoredToken();
      if (token == null) return [];
      
      final currentDevice = await getCurrentDevice();
      
      final response = await _dio.get(
        '/auth/devices/security-recommendations/${currentDevice.id}',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return List<SecurityRecommendation>.from(
            data['recommendations'].map((r) => SecurityRecommendation(
              id: r['id']?.toString() ?? '',
              title: r['title']?.toString() ?? '',
              description: r['description']?.toString() ?? '',
              type: SecurityRecommendationType.values.firstWhere(
                (type) => type.name == r['type'],
                orElse: () => SecurityRecommendationType.deviceSecurity,
              ),
              priority: SecurityRecommendationPriority.values.firstWhere(
                (priority) => priority.name == r['priority'],
                orElse: () => SecurityRecommendationPriority.medium,
              ),
              isActionable: r['is_actionable'] ?? true,
            ))
          );
        }
      }
      
      return [];
    } catch (e) {
      return [];
    }
  }
  
  /// Store current device
  Future<void> _storeCurrentDevice(Device device) async {
    await _secureStorage.write(
      key: _currentDeviceKey,
      value: jsonEncode(device.toJson()),
    );
  }
  
  /// Update trusted devices list
  Future<void> _updateTrustedDevices(Device device) async {
    final trustedDevicesStr = await _secureStorage.read(key: _trustedDevicesKey);
    List<Map<String, dynamic>> trustedDevices = [];
    
    if (trustedDevicesStr != null) {
      try {
        trustedDevices = List<Map<String, dynamic>>.from(jsonDecode(trustedDevicesStr));
      } catch (e) {
        trustedDevices = [];
      }
    }
    
    // Add or update device
    final index = trustedDevices.indexWhere((d) => d['id'] == device.id);
    if (index >= 0) {
      trustedDevices[index] = device.toJson();
    } else {
      trustedDevices.add(device.toJson());
    }
    
    await _secureStorage.write(
      key: _trustedDevicesKey,
      value: jsonEncode(trustedDevices),
    );
  }
  
  /// Remove trusted device from list
  Future<void> _removeTrustedDevice(String deviceId) async {
    final trustedDevicesStr = await _secureStorage.read(key: _trustedDevicesKey);
    if (trustedDevicesStr == null) return;
    
    try {
      final trustedDevices = List<Map<String, dynamic>>.from(jsonDecode(trustedDevicesStr));
      trustedDevices.removeWhere((d) => d['id'] == deviceId);
      
      await _secureStorage.write(
        key: _trustedDevicesKey,
        value: jsonEncode(trustedDevices),
      );
    } catch (e) {
      // Continue even if update fails
    }
  }
  
  /// Generate device ID
  String _generateDeviceId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = DateTime.now().microsecondsSinceEpoch;
    final combined = '$timestamp-$random-device';
    return sha256.convert(utf8.encode(combined)).toString().substring(0, 32);
  }
  
  /// Get device name
  Future<String> _getDeviceName() async {
    return 'Mobile Device';
  }
  
  /// Get platform
  Future<String> _getPlatform() async {
    return 'mobile';
  }
  
  /// Get device type
  Future<DeviceType> _getDeviceType() async {
    return DeviceType.mobile;
  }
  
  /// Get device information
  Future<Map<String, dynamic>> _getDeviceInfo() async {
    return {
      'platform': 'mobile',
      'user_agent': 'VedantaTrade Mobile App',
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
  
  /// Get stored token
  Future<String?> _getStoredToken() async {
    return await _secureStorage.read(key: 'access_token');
  }
}

/// Device Model
class Device {
  final String id;
  final String name;
  final String platform;
  final DeviceType deviceType;
  final bool isTrusted;
  final DeviceTrustLevel trustLevel;
  final DateTime lastSeenAt;
  final DateTime registeredAt;
  final Map<String, dynamic> deviceInfo;
  final String? location;
  final String? ipAddress;
  
  Device({
    required this.id,
    required this.name,
    required this.platform,
    required this.deviceType,
    required this.isTrusted,
    required this.trustLevel,
    required this.lastSeenAt,
    required this.registeredAt,
    required this.deviceInfo,
    this.location,
    this.ipAddress,
  });
  
  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      platform: json['platform']?.toString() ?? '',
      deviceType: DeviceType.values.firstWhere(
        (type) => type.name == json['device_type'],
        orElse: () => DeviceType.unknown,
      ),
      isTrusted: json['is_trusted'] ?? false,
      trustLevel: DeviceTrustLevel.values.firstWhere(
        (level) => level.name == json['trust_level'],
        orElse: () => DeviceTrustLevel.unknown,
      ),
      lastSeenAt: DateTime.tryParse(json['last_seen_at'] ?? '') ?? DateTime.now(),
      registeredAt: DateTime.tryParse(json['registered_at'] ?? '') ?? DateTime.now(),
      deviceInfo: Map<String, dynamic>.from(json['device_info'] ?? {}),
      location: json['location']?.toString(),
      ipAddress: json['ip_address']?.toString(),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'platform': platform,
      'device_type': deviceType.name,
      'is_trusted': isTrusted,
      'trust_level': trustLevel.name,
      'last_seen_at': lastSeenAt.toIso8601String(),
      'registered_at': registeredAt.toIso8601String(),
      'device_info': deviceInfo,
      if (location != null) 'location': location,
      if (ipAddress != null) 'ip_address': ipAddress,
    };
  }
}

/// Device Type
enum DeviceType {
  mobile,
  tablet,
  desktop,
  unknown,
}

/// Device Trust Level
enum DeviceTrustLevel {
  unknown,
  untrusted,
  trusted,
  highlyTrusted,
}

/// Device Management Result
class DeviceManagementResult {
  final bool success;
  final String? error;
  final String? message;
  final Device? device;
  
  const DeviceManagementResult({
    required this.success,
    this.error,
    this.message,
    this.device,
  });
}

/// Security Recommendation Type
enum SecurityRecommendationType {
  deviceSecurity,
  passwordStrength,
  mfaSetup,
  sessionManagement,
  dataPrivacy,
}

/// Security Recommendation Priority
enum SecurityRecommendationPriority {
  low,
  medium,
  high,
  critical,
}

/// Security Recommendation
class SecurityRecommendation {
  final String id;
  final String title;
  final String description;
  final SecurityRecommendationType type;
  final SecurityRecommendationPriority priority;
  final bool isActionable;
  final String? actionUrl;
  final Map<String, dynamic> metadata;
  
  SecurityRecommendation({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.priority,
    required this.isActionable,
    this.actionUrl,
    this.metadata = const {},
  });
}
