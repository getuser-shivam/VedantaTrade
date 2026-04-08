import 'dart:convert';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';
import 'package:vedanta_trade/core/api_config.dart';
import 'package:vedanta_trade/features/authentication/domain/entities/auth_user_entity.dart';

/// Multi-Factor Authentication Service
class MFAService {
  static const String _mfaSecretKey = 'mfa_secret';
  static const String _mfaBackupKey = 'mfa_backup_codes';
  static const String _mfaEnabledKey = 'mfa_enabled';
  
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock_this_device),
  );
  
  final Dio _dio = Dio();
  
  MFAService() {
    _dio.options.baseUrl = ApiConfig.baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 15);
    _dio.options.receiveTimeout = const Duration(seconds: 15);
    _dio.options.headers = {'Content-Type': 'application/json'};
  }
  
  /// Generate TOTP secret for user
  Future<MFAResult> generateMFASecret(String userId) async {
    try {
      final response = await _dio.post(
        '/auth/mfa/generate-secret',
        data: {
          'user_id': userId,
          'app_name': 'VedantaTrade',
          'issuer': 'VedantaTrade',
        },
        options: Options(
          headers: {'Authorization': 'Bearer ${await _getStoredToken()}'},
        ),
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          final secret = data['secret'];
          final qrCode = data['qr_code'];
          final backupCodes = List<String>.from(data['backup_codes'] ?? []);
          
          // Store secret temporarily (not enabled yet)
          await _secureStorage.write(key: _mfaSecretKey, value: secret);
          await _secureStorage.write(key: _mfaBackupKey, value: jsonEncode(backupCodes));
          
          return MFAResult(
            success: true,
            secret: secret,
            qrCode: qrCode,
            backupCodes: backupCodes,
          );
        }
      }
      
      return MFAResult(
        success: false,
        error: data['message'] ?? 'Failed to generate MFA secret',
      );
    } catch (e) {
      return MFAResult(
        success: false,
        error: 'Failed to generate MFA secret: ${e.toString()}',
      );
    }
  }
  
  /// Enable MFA for user
  Future<MFAResult> enableMFA({
    required String userId,
    required String verificationCode,
    TwoFactorMethod method = TwoFactorMethod.authenticatorApp,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/mfa/enable',
        data: {
          'user_id': userId,
          'verification_code': verificationCode,
          'method': method.name,
        },
        options: Options(
          headers: {'Authorization': 'Bearer ${await _getStoredToken()}'},
        ),
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          // Mark MFA as enabled locally
          await _secureStorage.write(key: _mfaEnabledKey, value: 'true');
          
          return MFAResult(
            success: true,
            message: 'MFA enabled successfully',
          );
        }
      }
      
      return MFAResult(
        success: false,
        error: data['message'] ?? 'Failed to enable MFA',
      );
    } catch (e) {
      return MFAResult(
        success: false,
        error: 'Failed to enable MFA: ${e.toString()}',
      );
    }
  }
  
  /// Disable MFA for user
  Future<MFAResult> disableMFA({
    required String userId,
    required String password,
    required String verificationCode,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/mfa/disable',
        data: {
          'user_id': userId,
          'password': password,
          'verification_code': verificationCode,
        },
        options: Options(
          headers: {'Authorization': 'Bearer ${await _getStoredToken()}'},
        ),
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          // Clear MFA data locally
          await Future.wait([
            _secureStorage.delete(key: _mfaSecretKey),
            _secureStorage.delete(key: _mfaBackupKey),
            _secureStorage.delete(key: _mfaEnabledKey),
          ]);
          
          return MFAResult(
            success: true,
            message: 'MFA disabled successfully',
          );
        }
      }
      
      return MFAResult(
        success: false,
        error: data['message'] ?? 'Failed to disable MFA',
      );
    } catch (e) {
      return MFAResult(
        success: false,
        error: 'Failed to disable MFA: ${e.toString()}',
      );
    }
  }
  
  /// Verify MFA code during login
  Future<MFAResult> verifyMFACode({
    required String mfaToken,
    required String verificationCode,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/mfa/verify',
        data: {
          'mfa_token': mfaToken,
          'verification_code': verificationCode,
          'device_info': await _getDeviceInfo(),
        },
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return MFAResult(
            success: true,
            accessToken: data['access_token'],
            refreshToken: data['refresh_token'],
            expiresAt: data['expires_at'] != null 
                ? DateTime.tryParse(data['expires_at']) 
                : null,
            user: _parseAuthUser(data['user']),
          );
        }
      }
      
      return MFAResult(
        success: false,
        error: data['message'] ?? 'Invalid verification code',
      );
    } catch (e) {
      return MFAResult(
        success: false,
        error: 'Failed to verify MFA code: ${e.toString()}',
      );
    }
  }
  
  /// Send SMS verification code
  Future<MFAResult> sendSMSVerification({
    required String phoneNumber,
    required String userId,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/mfa/send-sms',
        data: {
          'phone_number': phoneNumber,
          'user_id': userId,
          'purpose': 'mfa_verification',
        },
        options: Options(
          headers: {'Authorization': 'Bearer ${await _getStoredToken()}'},
        ),
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return MFAResult(
            success: true,
            message: 'SMS verification code sent',
            sessionId: data['session_id'],
          );
        }
      }
      
      return MFAResult(
        success: false,
        error: data['message'] ?? 'Failed to send SMS verification',
      );
    } catch (e) {
      return MFAResult(
        success: false,
        error: 'Failed to send SMS verification: ${e.toString()}',
      );
    }
  }
  
  /// Send email verification code
  Future<MFAResult> sendEmailVerification({
    required String email,
    required String userId,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/mfa/send-email',
        data: {
          'email': email,
          'user_id': userId,
          'purpose': 'mfa_verification',
        },
        options: Options(
          headers: {'Authorization': 'Bearer ${await _getStoredToken()}'},
        ),
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return MFAResult(
            success: true,
            message: 'Email verification code sent',
            sessionId: data['session_id'],
          );
        }
      }
      
      return MFAResult(
        success: false,
        error: data['message'] ?? 'Failed to send email verification',
      );
    } catch (e) {
      return MFAResult(
        success: false,
        error: 'Failed to send email verification: ${e.toString()}',
      );
    }
  }
  
  /// Verify backup code
  Future<MFAResult> verifyBackupCode({
    required String userId,
    required String backupCode,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/mfa/verify-backup-code',
        data: {
          'user_id': userId,
          'backup_code': backupCode,
          'device_info': await _getDeviceInfo(),
        },
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return MFAResult(
            success: true,
            accessToken: data['access_token'],
            refreshToken: data['refresh_token'],
            expiresAt: data['expires_at'] != null 
                ? DateTime.tryParse(data['expires_at']) 
                : null,
            user: _parseAuthUser(data['user']),
            message: 'Backup code verified successfully',
          );
        }
      }
      
      return MFAResult(
        success: false,
        error: data['message'] ?? 'Invalid backup code',
      );
    } catch (e) {
      return MFAResult(
        success: false,
        error: 'Failed to verify backup code: ${e.toString()}',
      );
    }
  }
  
  /// Generate new backup codes
  Future<MFAResult> generateNewBackupCodes(String userId) async {
    try {
      final response = await _dio.post(
        '/auth/mfa/generate-backup-codes',
        data: {'user_id': userId},
        options: Options(
          headers: {'Authorization': 'Bearer ${await _getStoredToken()}'},
        ),
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          final backupCodes = List<String>.from(data['backup_codes'] ?? []);
          
          // Store backup codes locally
          await _secureStorage.write(
            key: _mfaBackupKey,
            value: jsonEncode(backupCodes),
          );
          
          return MFAResult(
            success: true,
            backupCodes: backupCodes,
            message: 'New backup codes generated',
          );
        }
      }
      
      return MFAResult(
        success: false,
        error: data['message'] ?? 'Failed to generate backup codes',
      );
    } catch (e) {
      return MFAResult(
        success: false,
        error: 'Failed to generate backup codes: ${e.toString()}',
      );
    }
  }
  
  /// Check if MFA is enabled locally
  Future<bool> isMFAEnabled() async {
    final enabled = await _secureStorage.read(key: _mfaEnabledKey);
    return enabled == 'true';
  }
  
  /// Get stored backup codes
  Future<List<String>> getStoredBackupCodes() async {
    final codesStr = await _secureStorage.read(key: _mfaBackupKey);
    if (codesStr == null) return [];
    
    try {
      return List<String>.from(jsonDecode(codesStr));
    } catch (e) {
      return [];
    }
  }
  
  /// Generate TOTP code (for testing purposes)
  String generateTOTPCode(String secret) {
    final key = base32.decode(secret);
    final interval = DateTime.now().millisecondsSinceEpoch ~/ 1000 ~/ 30;
    
    final hmac = Hmac(sha1, key);
    final bytes = utf8.encode(interval.toString());
    final digest = hmac.convert(bytes);
    
    final offset = digest.bytes[digest.bytes.length - 1] & 0x0F;
    final binary = ((digest.bytes[offset] & 0x7F) << 24) |
                 ((digest.bytes[offset + 1] & 0xFF) << 16) |
                 ((digest.bytes[offset + 2] & 0xFF) << 8) |
                 (digest.bytes[offset + 3] & 0xFF);
    
    final code = (binary % 1000000).toString().padLeft(6, '0');
    return code;
  }
  
  /// Validate TOTP code
  bool validateTOTPCode(String secret, String code) {
    final key = base32.decode(secret);
    final interval = DateTime.now().millisecondsSinceEpoch ~/ 1000 ~/ 30;
    
    // Check current interval and adjacent intervals (for clock skew)
    for (int i = -1; i <= 1; i++) {
      final hmac = Hmac(sha1, key);
      final bytes = utf8.encode((interval + i).toString());
      final digest = hmac.convert(bytes);
      
      final offset = digest.bytes[digest.bytes.length - 1] & 0x0F;
      final binary = ((digest.bytes[offset] & 0x7F) << 24) |
                   ((digest.bytes[offset + 1] & 0xFF) << 16) |
                   ((digest.bytes[offset + 2] & 0xFF) << 8) |
                   (digest.bytes[offset + 3] & 0xFF);
      
      final generatedCode = (binary % 1000000).toString().padLeft(6, '0');
      if (generatedCode == code) {
        return true;
      }
    }
    
    return false;
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
  
  /// Parse AuthUser from API response
  AuthUserEntity _parseAuthUser(dynamic data) {
    return AuthUserEntity(
      id: data['id']?.toString() ?? '',
      email: data['email']?.toString() ?? '',
      phoneNumber: data['phone_number']?.toString(),
      firstName: data['first_name']?.toString() ?? '',
      lastName: data['last_name']?.toString() ?? '',
      fullName: data['full_name']?.toString() ?? '',
      profileImageUrl: data['profile_image_url']?.toString(),
      role: UserRole(
        id: data['role']?['id']?.toString() ?? '',
        name: data['role']?['name']?.toString() ?? 'user',
        description: data['role']?['description']?.toString() ?? '',
        permissions: List<String>.from(data['role']?['permissions'] ?? []),
        level: data['role']?['level'] ?? 0,
        isActive: data['role']?['is_active'] ?? true,
        createdAt: DateTime.tryParse(data['role']?['created_at'] ?? '') ?? DateTime.now(),
        updatedAt: DateTime.tryParse(data['role']?['updated_at'] ?? '') ?? DateTime.now(),
      ),
      status: UserStatus.values.firstWhere(
        (status) => status.name == data['status'],
        orElse: () => UserStatus.active,
      ),
      isEmailVerified: data['is_email_verified'] ?? false,
      isPhoneVerified: data['is_phone_verified'] ?? false,
      isTwoFactorEnabled: data['is_two_factor_enabled'] ?? false,
      emailVerifiedAt: data['email_verified_at'] != null 
          ? DateTime.tryParse(data['email_verified_at']) 
          : null,
      phoneVerifiedAt: data['phone_verified_at'] != null 
          ? DateTime.tryParse(data['phone_verified_at']) 
          : null,
      lastLoginAt: data['last_login_at'] != null 
          ? DateTime.tryParse(data['last_login_at']) 
          : null,
      passwordChangedAt: data['password_changed_at'] != null 
          ? DateTime.tryParse(data['password_changed_at']) 
          : null,
      permissions: List<String>.from(data['permissions'] ?? []),
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
      createdAt: DateTime.tryParse(data['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(data['updated_at'] ?? '') ?? DateTime.now(),
      preferences: UserPreferences(),
      activeSessions: [],
      securitySettings: SecuritySettings(
        twoFactorEnabled: data['security_settings']?['two_factor_enabled'] ?? false,
        twoFactorMethod: TwoFactorMethod.values.firstWhere(
          (method) => method.name == data['security_settings']?['two_factor_method'],
          orElse: () => TwoFactorMethod.none,
        ),
        sessionTimeoutEnabled: data['security_settings']?['session_timeout_enabled'] ?? true,
        sessionTimeoutMinutes: data['security_settings']?['session_timeout_minutes'] ?? 30,
        ipWhitelistEnabled: data['security_settings']?['ip_whitelist_enabled'] ?? false,
        whitelistedIps: List<String>.from(data['security_settings']?['whitelisted_ips'] ?? []),
        deviceTrackingEnabled: data['security_settings']?['device_tracking_enabled'] ?? true,
        maxConcurrentSessions: data['security_settings']?['max_concurrent_sessions'] ?? 3,
        passwordComplexityEnabled: data['security_settings']?['password_complexity_enabled'] ?? true,
        passwordMinLength: data['security_settings']?['password_min_length'] ?? 8,
        passwordHistoryCount: data['security_settings']?['password_history_count'] ?? 5,
        loginAttemptLimitEnabled: data['security_settings']?['login_attempt_limit_enabled'] ?? true,
        maxLoginAttempts: data['security_settings']?['max_login_attempts'] ?? 5,
        lockoutDurationMinutes: data['security_settings']?['lockout_duration_minutes'] ?? 15,
        suspiciousActivityDetection: data['security_settings']?['suspicious_activity_detection'] ?? true,
      ),
      profile: null,
    );
  }
}

/// MFA Result
class MFAResult {
  final bool success;
  final String? error;
  final String? message;
  final String? secret;
  final String? qrCode;
  final List<String>? backupCodes;
  final String? sessionId;
  final String? accessToken;
  final String? refreshToken;
  final DateTime? expiresAt;
  final AuthUserEntity? user;
  
  const MFAResult({
    required this.success,
    this.error,
    this.message,
    this.secret,
    this.qrCode,
    this.backupCodes,
    this.sessionId,
    this.accessToken,
    this.refreshToken,
    this.expiresAt,
    this.user,
  });
}
