import 'dart:convert';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';
import 'package:vedanta_trade/core/api_config.dart';
import 'package:vedanta_trade/features/authentication/domain/entities/auth_user_entity.dart';

/// Account Security Service for handling account locking, rate limiting, and security features
class AccountSecurityService {
  static const String _failedAttemptsKey = 'failed_attempts';
  static const String _lockoutEndKey = 'lockout_end';
  static const String _lastAttemptKey = 'last_attempt';
  static const String _securityQuestionsKey = 'security_questions';
  static const String _backupCodesKey = 'backup_codes';
  
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock_this_device),
  );
  
  final Dio _dio = Dio();
  
  AccountSecurityService() {
    _dio.options.baseUrl = ApiConfig.baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 15);
    _dio.options.receiveTimeout = const Duration(seconds: 15);
    _dio.options.headers = {'Content-Type': 'application/json'};
  }
  
  /// Check account lock status
  Future<AccountLockStatus> checkAccountLockStatus(String identifier) async {
    try {
      final response = await _dio.get(
        '/auth/security/lock-status/$identifier',
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        return AccountLockStatus(
          isLocked: data['is_locked'] ?? false,
          lockedUntil: data['locked_until'] != null 
              ? DateTime.tryParse(data['locked_until']) 
              : null,
          lockReason: data['lock_reason'],
          failedAttempts: data['failed_attempts'] ?? 0,
          maxAttempts: data['max_attempts'] ?? 5,
          remainingAttempts: data['remaining_attempts'] ?? 5,
          lastAttemptAt: data['last_attempt_at'] != null 
              ? DateTime.tryParse(data['last_attempt_at']) 
              : null,
        );
      }
      
      // Return default status on API failure
      return AccountLockStatus(
        isLocked: false,
        failedAttempts: 0,
        maxAttempts: 5,
        remainingAttempts: 5,
      );
    } catch (e) {
      // Return default status on error
      return AccountLockStatus(
        isLocked: false,
        failedAttempts: 0,
        maxAttempts: 5,
        remainingAttempts: 5,
      );
    }
  }
  
  /// Record failed login attempt
  Future<void> recordFailedAttempt(String identifier) async {
    try {
      await _dio.post(
        '/auth/security/failed-attempt',
        data: {
          'identifier': identifier,
          'timestamp': DateTime.now().toIso8601String(),
          'ip_address': await _getIpAddress(),
          'user_agent': await _getUserAgent(),
        },
      );
    } catch (e) {
      // Continue even if recording fails
    }
    
    // Also track locally for immediate feedback
    await _trackLocalFailedAttempt(identifier);
  }
  
  /// Record successful login
  Future<void> recordSuccessfulAttempt(String identifier) async {
    try {
      await _dio.post(
        '/auth/security/successful-attempt',
        data: {
          'identifier': identifier,
          'timestamp': DateTime.now().toIso8601String(),
          'ip_address': await _getIpAddress(),
          'user_agent': await _getUserAgent(),
        },
      );
    } catch (e) {
      // Continue even if recording fails
    }
    
    // Clear local failed attempts
    await _clearLocalFailedAttempts(identifier);
  }
  
  /// Lock account
  Future<bool> lockAccount({
    required String identifier,
    required String reason,
    Duration? duration,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/security/lock-account',
        data: {
          'identifier': identifier,
          'reason': reason,
          'duration_minutes': duration?.inMinutes ?? 30,
          'permanent': false,
        },
      );
      
      return response.statusCode == 200 && response.data['success'] == true;
    } catch (e) {
      return false;
    }
  }
  
  /// Unlock account
  Future<bool> unlockAccount({
    required String identifier,
    required String verificationCode,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/security/unlock-account',
        data: {
          'identifier': identifier,
          'verification_code': verificationCode,
          'ip_address': await _getIpAddress(),
        },
      );
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        await _clearLocalFailedAttempts(identifier);
        return true;
      }
      
      return false;
    } catch (e) {
      return false;
    }
  }
  
  /// Check rate limit
  Future<RateLimitStatus> checkRateLimit(String identifier, String action) async {
    try {
      final response = await _dio.get(
        '/auth/security/rate-limit/$identifier/$action',
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        return RateLimitStatus(
          isLimited: data['is_limited'] ?? false,
          remainingAttempts: data['remaining_attempts'] ?? 5,
          maxAttempts: data['max_attempts'] ?? 5,
          resetAt: data['reset_at'] != null 
              ? DateTime.tryParse(data['reset_at']) 
              : null,
          resetIn: data['reset_in_seconds'] != null 
              ? Duration(seconds: data['reset_in_seconds']) 
              : null,
        );
      }
      
      return RateLimitStatus(
        isLimited: false,
        remainingAttempts: 5,
        maxAttempts: 5,
      );
    } catch (e) {
      return RateLimitStatus(
        isLimited: false,
        remainingAttempts: 5,
        maxAttempts: 5,
      );
    }
  }
  
  /// Check suspicious activity
  Future<SecurityRiskLevel> checkSuspiciousActivity(String identifier) async {
    try {
      final response = await _dio.get(
        '/auth/security/suspicious-activity/$identifier',
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        final riskScore = data['risk_score'] ?? 0;
        
        if (riskScore >= 80) return SecurityRiskLevel.high;
        if (riskScore >= 60) return SecurityRiskLevel.medium;
        if (riskScore >= 40) return SecurityRiskLevel.low;
        return SecurityRiskLevel.none;
      }
      
      return SecurityRiskLevel.none;
    } catch (e) {
      return SecurityRiskLevel.none;
    }
  }
  
  /// Report suspicious activity
  Future<bool> reportSuspiciousActivity({
    required String userId,
    required String activity,
    String? description,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/security/report-suspicious-activity',
        data: {
          'user_id': userId,
          'activity': activity,
          'description': description,
          'metadata': metadata ?? {},
          'timestamp': DateTime.now().toIso8601String(),
          'ip_address': await _getIpAddress(),
          'user_agent': await _getUserAgent(),
        },
      );
      
      return response.statusCode == 200 && response.data['success'] == true;
    } catch (e) {
      return false;
    }
  }
  
  /// Generate backup codes
  Future<List<String>?> generateBackupCodes(String userId) async {
    try {
      final response = await _dio.post(
        '/auth/security/generate-backup-codes',
        data: {'user_id': userId},
        options: Options(
          headers: {'Authorization': 'Bearer ${await _getStoredToken()}'},
        ),
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          final codes = List<String>.from(data['backup_codes'] ?? []);
          
          // Store backup codes locally (encrypted)
          await _storeBackupCodes(codes);
          
          return codes;
        }
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }
  
  /// Verify backup code
  Future<bool> verifyBackupCode({
    required String userId,
    required String backupCode,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/security/verify-backup-code',
        data: {
          'user_id': userId,
          'backup_code': backupCode,
          'ip_address': await _getIpAddress(),
        },
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          // Remove used backup code from local storage
          await _removeBackupCode(backupCode);
          return true;
        }
      }
      
      return false;
    } catch (e) {
      return false;
    }
  }
  
  /// Get security audit log
  Future<List<SecurityAuditEntry>> getSecurityAuditLog({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final response = await _dio.get(
        '/auth/security/audit-log/$userId',
        queryParameters: {
          'start_date': startDate?.toIso8601String(),
          'end_date': endDate?.toIso8601String(),
          'page': page,
          'limit': limit,
        },
        options: Options(
          headers: {'Authorization': 'Bearer ${await _getStoredToken()}'},
        ),
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return List<SecurityAuditEntry>.from(
            data['audit_entries'].map((entry) => SecurityAuditEntry(
              id: entry['id']?.toString() ?? '',
              userId: entry['user_id']?.toString() ?? '',
              eventType: SecurityEventType.values.firstWhere(
                (type) => type.name == entry['event_type'],
                orElse: () => SecurityEventType.login,
              ),
              description: entry['description']?.toString() ?? '',
              ipAddress: entry['ip_address']?.toString(),
              userAgent: entry['user_agent']?.toString(),
              location: entry['location']?.toString(),
              timestamp: DateTime.tryParse(entry['timestamp'] ?? '') ?? DateTime.now(),
              success: entry['success'] ?? false,
              failureReason: entry['failure_reason']?.toString(),
              metadata: Map<String, dynamic>.from(entry['metadata'] ?? {}),
            ))
          );
        }
      }
      
      return [];
    } catch (e) {
      return [];
    }
  }
  
  /// Get security recommendations
  Future<List<SecurityRecommendation>> getSecurityRecommendations(String userId) async {
    try {
      final response = await _dio.get(
        '/auth/security/recommendations/$userId',
        options: Options(
          headers: {'Authorization': 'Bearer ${await _getStoredToken()}'},
        ),
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return List<SecurityRecommendation>.from(
            data['recommendations'].map((rec) => SecurityRecommendation(
              id: rec['id']?.toString() ?? '',
              title: rec['title']?.toString() ?? '',
              description: rec['description']?.toString() ?? '',
              type: SecurityRecommendationType.values.firstWhere(
                (type) => type.name == rec['type'],
                orElse: () => SecurityRecommendationType.passwordStrength,
              ),
              priority: SecurityRecommendationPriority.values.firstWhere(
                (priority) => priority.name == rec['priority'],
                orElse: () => SecurityRecommendationPriority.medium,
              ),
              isActionable: rec['is_actionable'] ?? true,
              actionUrl: rec['action_url']?.toString(),
              metadata: Map<String, dynamic>.from(rec['metadata'] ?? {}),
            ))
          );
        }
      }
      
      return [];
    } catch (e) {
      return [];
    }
  }
  
  /// Track failed attempt locally
  Future<void> _trackLocalFailedAttempt(String identifier) async {
    final key = '$_failedAttemptsKey${_hashIdentifier(identifier)}';
    final attemptsStr = await _secureStorage.read(key: key) ?? '0';
    final attempts = int.tryParse(attemptsStr) ?? 0;
    
    await _secureStorage.write(key: key, value: (attempts + 1).toString());
    await _secureStorage.write(
      key: '${_lastAttemptKey}${_hashIdentifier(identifier)}',
      value: DateTime.now().toIso8601String(),
    );
    
    // Check if account should be locked locally
    if (attempts + 1 >= 5) {
      final lockoutEnd = DateTime.now().add(const Duration(minutes: 15));
      await _secureStorage.write(
        key: '${_lockoutEndKey}${_hashIdentifier(identifier)}',
        value: lockoutEnd.toIso8601String(),
      );
    }
  }
  
  /// Clear local failed attempts
  Future<void> _clearLocalFailedAttempts(String identifier) async {
    final hash = _hashIdentifier(identifier);
    await Future.wait([
      _secureStorage.delete(key: '$_failedAttemptsKey$hash'),
      _secureStorage.delete(key: '${_lastAttemptKey}$hash'),
      _secureStorage.delete(key: '${_lockoutEndKey}$hash'),
    ]);
  }
  
  /// Check local account lock
  Future<bool> _isAccountLockedLocally(String identifier) async {
    final key = '${_lockoutEndKey}${_hashIdentifier(identifier)}';
    final lockoutEndStr = await _secureStorage.read(key: key);
    
    if (lockoutEndStr == null) return false;
    
    final lockoutEnd = DateTime.tryParse(lockoutEndStr);
    if (lockoutEnd == null) return false;
    
    if (DateTime.now().isAfter(lockoutEnd)) {
      await _secureStorage.delete(key: key);
      return false;
    }
    
    return true;
  }
  
  /// Store backup codes securely
  Future<void> _storeBackupCodes(List<String> codes) async {
    final encryptedCodes = codes.map((code) => _encryptBackupCode(code)).toList();
    await _secureStorage.write(
      key: _backupCodesKey,
      value: jsonEncode(encryptedCodes),
    );
  }
  
  /// Remove used backup code
  Future<void> _removeBackupCode(String usedCode) async {
    final codesStr = await _secureStorage.read(key: _backupCodesKey);
    if (codesStr == null) return;
    
    final encryptedCodes = List<String>.from(jsonDecode(codesStr));
    final remainingCodes = encryptedCodes.where((code) => 
        _decryptBackupCode(code) != usedCode).toList();
    
    await _secureStorage.write(
      key: _backupCodesKey,
      value: jsonEncode(remainingCodes),
    );
  }
  
  /// Encrypt backup code
  String _encryptBackupCode(String code) {
    final key = 'backup-code-key';
    final bytes = utf8.encode(code);
    final hash = sha256.convert(utf8.encode(key));
    return base64.encode(bytes.map((b) => b ^ hash.bytes[0]).toList());
  }
  
  /// Decrypt backup code
  String _decryptBackupCode(String encryptedCode) {
    final key = 'backup-code-key';
    final hash = sha256.convert(utf8.encode(key));
    final bytes = base64.decode(encryptedCode);
    return String.fromCharCodes(bytes.map((b) => b ^ hash.bytes[0]).toList());
  }
  
  /// Hash identifier for storage
  String _hashIdentifier(String identifier) {
    return sha256.convert(utf8.encode(identifier.toLowerCase())).toString();
  }
  
  /// Get IP address (placeholder - in real app, use service)
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
    return 'VedantaTrade/${Platform.operatingSystem}';
  }
  
  /// Get stored token
  Future<String?> _getStoredToken() async {
    return await _secureStorage.read(key: 'access_token');
  }
  
  /// Check password strength
  PasswordStrength checkPasswordStrength(String password) {
    int score = 0;
    final criteria = <String, bool>{};
    
    // Length
    if (password.length >= 8) {
      score += 1;
      criteria['length'] = true;
    } else {
      criteria['length'] = false;
    }
    
    // Uppercase
    if (password.contains(RegExp(r'[A-Z]'))) {
      score += 1;
      criteria['uppercase'] = true;
    } else {
      criteria['uppercase'] = false;
    }
    
    // Lowercase
    if (password.contains(RegExp(r'[a-z]'))) {
      score += 1;
      criteria['lowercase'] = true;
    } else {
      criteria['lowercase'] = false;
    }
    
    // Numbers
    if (password.contains(RegExp(r'[0-9]'))) {
      score += 1;
      criteria['numbers'] = true;
    } else {
      criteria['numbers'] = false;
    }
    
    // Special characters
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      score += 1;
      criteria['special'] = true;
    } else {
      criteria['special'] = false;
    }
    
    // Common patterns (negative)
    if (password.toLowerCase().contains('password') ||
        password.toLowerCase().contains('123456') ||
        password.toLowerCase().contains('qwerty')) {
      score -= 1;
      criteria['common_pattern'] = false;
    } else {
      criteria['common_pattern'] = true;
    }
    
    PasswordStrengthLevel level;
    List<String> suggestions = [];
    
    if (score <= 2) {
      level = PasswordStrengthLevel.veryWeak;
      suggestions = [
        'Use at least 8 characters',
        'Include uppercase and lowercase letters',
        'Add numbers and special characters',
      ];
    } else if (score <= 3) {
      level = PasswordStrengthLevel.weak;
      suggestions = [
        'Add more variety to your password',
        'Include special characters',
      ];
    } else if (score <= 4) {
      level = PasswordStrengthLevel.fair;
      suggestions = [
        'Consider adding more complexity',
      ];
    } else if (score <= 5) {
      level = PasswordStrengthLevel.good;
      suggestions = [];
    } else {
      level = PasswordStrengthLevel.strong;
      suggestions = [];
    }
    
    return PasswordStrength(
      score: score,
      level: level,
      suggestions: suggestions,
      criteria: criteria,
    );
  }
}
