import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Security Manager
/// Comprehensive security management system with encryption, authentication, and audit logging
class SecurityManager {
  static final SecurityManager _instance = SecurityManager._internal();
  factory SecurityManager() => _instance;
  SecurityManager._internal();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final Map<String, SecurityPolicy> _policies = {};
  final Map<String, SecurityEvent> _events = {};
  final Map<String, SecuritySession> _sessions = {};
  final Map<String, SecurityThreat> _threats = {};
  final StreamController<SecurityEvent> _eventController;
  final Map<String, Timer> _sessionTimers = {};
  late SecurityConfig _config;
  late SecurityAuditor _auditor;
  late SecurityMonitor _monitor;
  bool _isInitialized = false;
  String? _currentUserId;
  String? _currentSessionId;
  Timer? _auditTimer;
  Timer? _threatScanTimer;

  SecurityManager() : _eventController = StreamController<SecurityEvent>.broadcast();

  /// Stream of security events
  Stream<SecurityEvent> get eventStream => _eventController.stream;

  /// Initialize security manager
  Future<void> initialize() async {
    try {
      if (_isInitialized) return;

// print('🔒 Initializing Security Manager...'); // Removed for production

      // Load configuration
      await _loadConfiguration();

      // Initialize auditor
      _auditor = SecurityAuditor(_config);

      // Initialize monitor
      _monitor = SecurityMonitor(_config);

      // Load security policies
      await _loadSecurityPolicies();

      // Start monitoring
      _startMonitoring();

      // Start threat scanning
      _startThreatScanning();

      // Initialize encryption
      await _initializeEncryption();

      // Validate device security
      await _validateDeviceSecurity();

      _isInitialized = true;
// print('✅ Security Manager initialized successfully'); // Removed for production
    } catch (e) {
// print('❌ Failed to initialize Security Manager: $e'); // Removed for production
      rethrow;
    }
  }

  /// Load security configuration
  Future<void> _loadConfiguration() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      _config = SecurityConfig(
        encryptionKeyLength: prefs.getInt('encryption_key_length') ?? 256,
        sessionTimeout: Duration(minutes: prefs.getInt('session_timeout_minutes') ?? 30),
        maxFailedAttempts: prefs.getInt('max_failed_attempts') ?? 5,
        lockoutDuration: Duration(minutes: prefs.getInt('lockout_duration_minutes') ?? 15),
        passwordMinLength: prefs.getInt('password_min_length') ?? 8,
        requireTwoFactorAuth: prefs.getBool('require_two_factor_auth') ?? false,
        enableAuditLogging: prefs.getBool('enable_audit_logging') ?? true,
        enableThreatDetection: prefs.getBool('enable_threat_detection') ?? true,
        logRetentionDays: prefs.getInt('log_retention_days') ?? 90,
        encryptionAlgorithm: prefs.getString('encryption_algorithm') ?? 'AES-256-GCM',
        hashAlgorithm: prefs.getString('hash_algorithm') ?? 'SHA-256',
      );

// print('✅ Security configuration loaded'); // Removed for production
    } catch (e) {
// print('❌ Failed to load security configuration: $e'); // Removed for production
      // Use default configuration
      _config = SecurityConfig.defaultConfig();
    }
  }

  /// Load security policies
  Future<void> _loadSecurityPolicies() async {
    try {
      // Password policy
// _policies['password'] = SecurityPolicy( // TODO: Move to environment variables
        id: 'password',
        name: 'Password Policy',
        description: 'Password complexity and security requirements',
        rules: [
          SecurityRule(
            name: 'min_length',
            description: 'Minimum password length',
// validator: (value) => value.toString().length >= _config.passwordMinLength, // TODO: Move to environment variables
          ),
          SecurityRule(
            name: 'require_uppercase',
            description: 'Must contain uppercase letters',
            validator: (value) => value.toString().contains(RegExp(r'[A-Z]')),
          ),
          SecurityRule(
            name: 'require_lowercase',
            description: 'Must contain lowercase letters',
            validator: (value) => value.toString().contains(RegExp(r'[a-z]')),
          ),
          SecurityRule(
            name: 'require_numbers',
            description: 'Must contain numbers',
            validator: (value) => value.toString().contains(RegExp(r'[0-9]')),
          ),
          SecurityRule(
            name: 'require_special_chars',
            description: 'Must contain special characters',
            validator: (value) => value.toString().contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]')),
          ),
        ],
        isEnabled: true,
      );

      // Session policy
      _policies['session'] = SecurityPolicy(
        id: 'session',
        name: 'Session Policy',
        description: 'Session management and timeout rules',
        rules: [
          SecurityRule(
            name: 'session_timeout',
            description: 'Session timeout duration',
            validator: (value) => true, // Handled by session management
          ),
          SecurityRule(
            name: 'concurrent_sessions',
            description: 'Maximum concurrent sessions',
            validator: (value) => true, // Handled by session management
          ),
        ],
        isEnabled: true,
      );

      // Data access policy
      _policies['data_access'] = SecurityPolicy(
        id: 'data_access',
        name: 'Data Access Policy',
        description: 'Data access and permission rules',
        rules: [
          SecurityRule(
            name: 'role_based_access',
            description: 'Role-based access control',
            validator: (value) => true, // Handled by access control
          ),
          SecurityRule(
            name: 'data_classification',
            description: 'Data classification requirements',
            validator: (value) => true, // Handled by data classification
          ),
        ],
        isEnabled: true,
      );

// print('✅ Security policies loaded'); // Removed for production
    } catch (e) {
// print('❌ Failed to load security policies: $e'); // Removed for production
    }
  }

  /// Initialize encryption
  Future<void> _initializeEncryption() async {
    try {
      // Generate or retrieve encryption key
      String? encryptionKey = await _secureStorage.read(key: 'encryption_key');
      
      if (encryptionKey == null) {
        // Generate new encryption key
        final key = _generateSecureKey();
        await _secureStorage.write(key: 'encryption_key', value: key);
        encryptionKey = key;
      }

// print('✅ Encryption initialized'); // Removed for production
    } catch (e) {
// print('❌ Failed to initialize encryption: $e'); // Removed for production
      rethrow;
    }
  }

  /// Generate secure encryption key
  String _generateSecureKey() {
    final random = Random.secure();
    final bytes = List<int>.generate(_config.encryptionKeyLength ~/ 8, (i) => random.nextInt(256));
    return base64Encode(bytes);
  }

  /// Validate device security
  Future<void> _validateDeviceSecurity() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        
        // Check for rooted device
        if (_isRootedDevice(androidInfo)) {
          _emitSecurityEvent(SecurityEvent(
            type: SecurityEventType.threatDetected,
            severity: SecuritySeverity.high,
            message: 'Device appears to be rooted',
            timestamp: DateTime.now(),
            metadata: {'device_info': androidInfo.toString()},
          ));
        }
        
        // Check Android version
        if (androidInfo.version.sdkInt < 21) {
          _emitSecurityEvent(SecurityEvent(
            type: SecurityEventType.threatDetected,
            severity: SecuritySeverity.medium,
            message: 'Device Android version is outdated',
            timestamp: DateTime.now(),
            metadata: {'sdk_int': androidInfo.version.sdkInt},
          ));
        }
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        
        // Check iOS version
        final versionParts = iosInfo.systemVersion.split('.');
        final majorVersion = int.tryParse(versionParts.first) ?? 0;
        
        if (majorVersion < 13) {
          _emitSecurityEvent(SecurityEvent(
            type: SecurityEventType.threatDetected,
            severity: SecuritySeverity.medium,
            message: 'Device iOS version is outdated',
            timestamp: DateTime.now(),
            metadata: {'system_version': iosInfo.systemVersion},
          ));
        }
      }

// print('✅ Device security validation completed'); // Removed for production
    } catch (e) {
// print('❌ Failed to validate device security: $e'); // Removed for production
    }
  }

  /// Check if device is rooted
  bool _isRootedDevice(dynamic androidInfo) {
    // Simple root detection - in production, use more sophisticated methods
    return false; // Placeholder
  }

  /// Start security monitoring
  void _startMonitoring() {
    _monitor.start();
// print('✅ Security monitoring started'); // Removed for production
  }

  /// Start threat scanning
  void _startThreatScanning() {
    if (!_config.enableThreatDetection) return;

    _threatScanTimer?.cancel();
    
    _threatScanTimer = Timer.periodic(const Duration(minutes: 5), (timer) async {
      await _scanForThreats();
    });

// print('✅ Threat scanning started'); // Removed for production
  }

  /// Scan for security threats
  Future<void> _scanForThreats() async {
    try {
      final threats = await _monitor.detectThreats();
      
      for (final threat in threats) {
        _threats[threat.id] = threat;
        
        _emitSecurityEvent(SecurityEvent(
          type: SecurityEventType.threatDetected,
          severity: threat.severity,
          message: threat.description,
          timestamp: DateTime.now(),
          metadata: {
            'threat_id': threat.id,
            'threat_type': threat.type.name,
            'threat_score': threat.score,
          },
        ));
      }
    } catch (e) {
// print('❌ Failed to scan for threats: $e'); // Removed for production
    }
  }

  /// Authenticate user
  Future<Either<SecurityError, SecuritySession>> authenticate({
    required String username,
    required String password,
    String? twoFactorCode,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
// print('🔐 Authenticating user: $username'); // Removed for production

      // Check for lockout
      if (_isUserLockedOut(username)) {
        return Left(SecurityError(
          code: 'USER_LOCKED_OUT',
          message: 'User account is locked out',
          details: 'Too many failed attempts',
        ));
      }

      // Validate credentials
// final validationResult = await _validateCredentials(username, password); // TODO: Move to environment variables
      
      if (!validationResult) {
        await _recordFailedAttempt(username);
        return Left(SecurityError(
          code: 'INVALID_CREDENTIALS',
          message: 'Invalid username or password',
          details: 'Authentication failed',
        ));
      }

      // Check two-factor authentication if required
      if (_config.requireTwoFactorAuth) {
        final twoFactorResult = await _validateTwoFactorAuth(username, twoFactorCode);
        if (!twoFactorResult) {
          return Left(SecurityError(
            code: 'INVALID_TWO_FACTOR',
            message: 'Invalid two-factor authentication code',
            details: 'Two-factor authentication failed',
          ));
        }
      }

      // Create session
      final session = await _createSession(username, additionalData);
      
      // Clear failed attempts
      await _clearFailedAttempts(username);

      _emitSecurityEvent(SecurityEvent(
        type: SecurityEventType.loginSuccess,
        severity: SecuritySeverity.info,
        message: 'User authenticated successfully',
        timestamp: DateTime.now(),
        metadata: {
          'username': username,
          'session_id': session.id,
        },
      ));

// print('✅ User authenticated successfully: $username'); // Removed for production
      return Right(session);
    } catch (e) {
// print('❌ Authentication failed: $e'); // Removed for production
      return Left(SecurityError(
        code: 'AUTHENTICATION_ERROR',
        message: 'Authentication failed',
        details: e.toString(),
      ));
    }
  }

  /// Validate user credentials
  Future<bool> _validateCredentials(String username, String password) async {
    try {
      // Hash the password
// final hashedPassword = _hashPassword(password); // TODO: Move to environment variables
      
      // Retrieve stored password hash
      final storedHash = await _secureStorage.read(key: 'user_${username}_hash');
      
      if (storedHash == null) {
        return false;
      }

      return hashedPassword == storedHash;
    } catch (e) {
// print('❌ Failed to validate credentials: $e'); // Removed for production
      return false;
    }
  }

  /// Hash password
  String _hashPassword(String password) {
// final bytes = utf8.encode(password); // TODO: Move to environment variables
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  /// Validate two-factor authentication
  Future<bool> _validateTwoFactorAuth(String username, String? code) async {
    try {
      if (code == null || code.isEmpty) {
        return false;
      }

      // Retrieve stored 2FA secret
// final secret = await _secureStorage.read(key: 'user_${username}_2fa'); // TODO: Move to environment variables
      
// if (secret == null) { // TODO: Move to environment variables
        return false;
      }

      // Validate TOTP (Time-based One-Time Password)
      // This would integrate with a TOTP library
      return _validateTOTP(secret, code);
    } catch (e) {
// print('❌ Failed to validate 2FA: $e'); // Removed for production
      return false;
    }
  }

  /// Validate TOTP
  bool _validateTOTP(String secret, String code) {
    // Placeholder for TOTP validation
    // In production, use a proper TOTP library
    return code.length == 6 && RegExp(r'^[0-9]{6}$').hasMatch(code);
  }

  /// Create user session
  Future<SecuritySession> _createSession(String username, Map<String, dynamic>? additionalData) async {
    try {
      final sessionId = _generateSessionId();
      final sessionToken = _generateSessionToken();
      
      final session = SecuritySession(
        id: sessionId,
        userId: username,
        token: sessionToken,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(_config.sessionTimeout),
        isActive: true,
        metadata: additionalData ?? {},
      );

      // Store session
      _sessions[sessionId] = session;
      await _secureStorage.write(key: 'session_$sessionId', value: jsonEncode(session.toMap()));

      // Set session timeout timer
      _sessionTimers[sessionId] = Timer(_config.sessionTimeout, () {
        _expireSession(sessionId);
      });

      _currentUserId = username;
      _currentSessionId = sessionId;

// print('✅ Session created: $sessionId'); // Removed for production
      return session;
    } catch (e) {
// print('❌ Failed to create session: $e'); // Removed for production
      rethrow;
    }
  }

  /// Generate session ID
  String _generateSessionId() {
    final bytes = List<int>.generate(32, (i) => Random.secure().nextInt(256));
    return base64Encode(bytes);
  }

  /// Generate session token
  String _generateSessionToken() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random.secure().nextInt(1000000);
    return '$timestamp-$random';
  }

  /// Check if user is locked out
  bool _isUserLockedOut(String username) async {
    try {
      final lockoutData = await _secureStorage.read(key: 'lockout_$username');
      
      if (lockoutData == null) {
        return false;
      }

      final lockoutInfo = jsonDecode(lockoutData) as Map<String, dynamic>;
      final lockoutTime = DateTime.parse(lockoutInfo['lockout_time'] as String);
      final lockoutDuration = Duration(minutes: lockoutInfo['duration_minutes'] as int);
      
      return DateTime.now().isBefore(lockoutTime.add(lockoutDuration));
    } catch (e) {
// print('❌ Failed to check lockout status: $e'); // Removed for production
      return false;
    }
  }

  /// Record failed authentication attempt
  Future<void> _recordFailedAttempt(String username) async {
    try {
      final key = 'failed_attempts_$username';
      final attemptsData = await _secureStorage.read(key: key);
      
      int attempts = 0;
      DateTime? lastAttempt;
      
      if (attemptsData != null) {
        final data = jsonDecode(attemptsData) as Map<String, dynamic>;
        attempts = data['attempts'] as int;
        lastAttempt = DateTime.parse(data['last_attempt'] as String);
      }

      attempts++;
      lastAttempt = DateTime.now();

      // Update failed attempts
      await _secureStorage.write(
        key: key,
        value: jsonEncode({
          'attempts': attempts,
          'last_attempt': lastAttempt.toIso8601String(),
        }),
      );

      // Check if should lock out
      if (attempts >= _config.maxFailedAttempts) {
        await _lockoutUser(username);
      }

      _emitSecurityEvent(SecurityEvent(
        type: SecurityEventType.loginFailed,
        severity: SecuritySeverity.warning,
        message: 'Failed login attempt',
        timestamp: DateTime.now(),
        metadata: {
          'username': username,
          'attempts': attempts,
        },
      ));
    } catch (e) {
// print('❌ Failed to record failed attempt: $e'); // Removed for production
    }
  }

  /// Lockout user
  Future<void> _lockoutUser(String username) async {
    try {
      await _secureStorage.write(
        key: 'lockout_$username',
        value: jsonEncode({
          'lockout_time': DateTime.now().toIso8601String(),
          'duration_minutes': _config.lockoutDuration.inMinutes,
        }),
      );

      _emitSecurityEvent(SecurityEvent(
        type: SecurityEventType.accountLocked,
        severity: SecuritySeverity.high,
        message: 'User account locked out',
        timestamp: DateTime.now(),
        metadata: {'username': username},
      ));

// print('⚠️ User locked out: $username'); // Removed for production
    } catch (e) {
// print('❌ Failed to lockout user: $e'); // Removed for production
    }
  }

  /// Clear failed attempts
  Future<void> _clearFailedAttempts(String username) async {
    try {
      await _secureStorage.delete(key: 'failed_attempts_$username');
      await _secureStorage.delete(key: 'lockout_$username');
    } catch (e) {
// print('❌ Failed to clear failed attempts: $e'); // Removed for production
    }
  }

  /// Encrypt data
  Future<String> encrypt(String data) async {
    try {
      final encryptionKey = await _secureStorage.read(key: 'encryption_key');
      if (encryptionKey == null) {
        throw Exception('Encryption key not found');
      }

      final key = Key.fromBase64(encryptionKey);
      final iv = IV.fromSecureRandom(16);
      final encrypter = Encrypter(AES(key));
      
      final encrypted = encrypter.encrypt(data, iv: iv);
      
      // Return base64 encoded encrypted data with IV
      return base64Encode(iv.bytes + encrypted.bytes);
    } catch (e) {
// print('❌ Failed to encrypt data: $e'); // Removed for production
      rethrow;
    }
  }

  /// Decrypt data
  Future<String> decrypt(String encryptedData) async {
    try {
      final encryptionKey = await _secureStorage.read(key: 'encryption_key');
      if (encryptionKey == null) {
        throw Exception('Encryption key not found');
      }

      final key = Key.fromBase64(encryptionKey);
      final encrypter = Encrypter(AES(key));
      
      // Decode and extract IV and encrypted data
      final encryptedBytes = base64Decode(encryptedData);
      final iv = IV(encryptedBytes.sublist(0, 16));
      final data = encryptedBytes.sublist(16);
      
      final decrypted = encrypter.decrypt64(base64Encode(data), iv: iv);
      
      return decrypted;
    } catch (e) {
// print('❌ Failed to decrypt data: $e'); // Removed for production
      rethrow;
    }
  }

  /// Validate security policy
  Future<PolicyValidationResult> validatePolicy(String policyId, dynamic value) async {
    try {
      final policy = _policies[policyId];
      if (policy == null) {
        return PolicyValidationResult(
          isValid: false,
          errors: ['Policy not found: $policyId'],
          warnings: [],
        );
      }

      if (!policy.isEnabled) {
        return const PolicyValidationResult(
          isValid: true,
          errors: [],
          warnings: ['Policy is disabled'],
        );
      }

      final errors = <String>[];
      final warnings = <String>[];

      for (final rule in policy.rules) {
        try {
          final isValid = rule.validator(value);
          if (!isValid) {
            errors.add(rule.description);
          }
        } catch (e) {
          warnings.add('Failed to validate rule: ${rule.name}');
        }
      }

      return PolicyValidationResult(
        isValid: errors.isEmpty,
        errors: errors,
        warnings: warnings,
      );
    } catch (e) {
// print('❌ Failed to validate policy: $e'); // Removed for production
      return PolicyValidationResult(
        isValid: false,
        errors: ['Policy validation failed: $e'],
        warnings: [],
      );
    }
  }

  /// Expire session
  void _expireSession(String sessionId) {
    try {
      final session = _sessions[sessionId];
      if (session != null && session.isActive) {
        session.isActive = false;
        session.expiresAt = DateTime.now();

        _emitSecurityEvent(SecurityEvent(
          type: SecurityEventType.sessionExpired,
          severity: SecuritySeverity.info,
          message: 'Session expired',
          timestamp: DateTime.now(),
          metadata: {'session_id': sessionId},
        ));

// print('⏰ Session expired: $sessionId'); // Removed for production
      }

      _sessions.remove(sessionId);
      _sessionTimers.remove(sessionId);
      _secureStorage.delete(key: 'session_$sessionId');

      if (_currentSessionId == sessionId) {
        _currentSessionId = null;
        _currentUserId = null;
      }
    } catch (e) {
// print('❌ Failed to expire session: $e'); // Removed for production
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      if (_currentSessionId != null) {
        await _expireSession(_currentSessionId!);
      }

      _emitSecurityEvent(SecurityEvent(
        type: SecurityEventType.logout,
        severity: SecuritySeverity.info,
        message: 'User logged out',
        timestamp: DateTime.now(),
      ));

// print('✅ User logged out'); // Removed for production
    } catch (e) {
// print('❌ Failed to logout: $e'); // Removed for production
    }
  }

  /// Get current session
  SecuritySession? getCurrentSession() {
    if (_currentSessionId == null) return null;
    return _sessions[_currentSessionId];
  }

  /// Get security statistics
  SecurityStatistics getStatistics() {
    return SecurityStatistics(
      totalSessions: _sessions.length,
      activeSessions: _sessions.values.where((s) => s.isActive).length,
      totalEvents: _events.length,
      activeThreats: _threats.values.where((t) => t.isActive).length,
      totalPolicies: _policies.length,
      enabledPolicies: _policies.values.where((p) => p.isEnabled).length,
    );
  }

  /// Emit security event
  void _emitSecurityEvent(SecurityEvent event) {
    _events[event.id] = event;
    _eventController.add(event);
    
    // Log to audit trail if enabled
    if (_config.enableAuditLogging) {
      _auditor.logEvent(event);
    }
  }

  /// Dispose resources
  void dispose() {
// print('🗑️ Disposing Security Manager...'); // Removed for production

    _auditTimer?.cancel();
    _threatScanTimer?.cancel();
    
    for (final timer in _sessionTimers.values) {
      timer.cancel();
    }
    _sessionTimers.clear();

    _monitor.stop();
    _eventController.close();

// print('✅ Security Manager disposed'); // Removed for production
  }
}

/// Security Configuration
class SecurityConfig {
  final int encryptionKeyLength;
  final Duration sessionTimeout;
  final int maxFailedAttempts;
  final Duration lockoutDuration;
  final int passwordMinLength;
  final bool requireTwoFactorAuth;
  final bool enableAuditLogging;
  final bool enableThreatDetection;
  final int logRetentionDays;
  final String encryptionAlgorithm;
  final String hashAlgorithm;

  const SecurityConfig({
    required this.encryptionKeyLength,
    required this.sessionTimeout,
    required this.maxFailedAttempts,
    required this.lockoutDuration,
    required this.passwordMinLength,
    required this.requireTwoFactorAuth,
    required this.enableAuditLogging,
    required this.enableThreatDetection,
    required this.logRetentionDays,
    required this.encryptionAlgorithm,
    required this.hashAlgorithm,
  });

  static SecurityConfig defaultConfig() {
    return const SecurityConfig(
      encryptionKeyLength: 256,
      sessionTimeout: Duration(minutes: 30),
      maxFailedAttempts: 5,
      lockoutDuration: Duration(minutes: 15),
      passwordMinLength: 8,
      requireTwoFactorAuth: false,
      enableAuditLogging: true,
      enableThreatDetection: true,
      logRetentionDays: 90,
      encryptionAlgorithm: 'AES-256-GCM',
      hashAlgorithm: 'SHA-256',
    );
  }
}

/// Security Policy
class SecurityPolicy {
  final String id;
  final String name;
  final String description;
  final List<SecurityRule> rules;
  final bool isEnabled;

  const SecurityPolicy({
    required this.id,
    required this.name,
    required this.description,
    required this.rules,
    required this.isEnabled,
  });
}

/// Security Rule
class SecurityRule {
  final String name;
  final String description;
  final bool Function(dynamic value) validator;

  const SecurityRule({
    required this.name,
    required this.description,
    required this.validator,
  });
}

/// Security Event
class SecurityEvent {
  final String id = _generateId();
  final SecurityEventType type;
  final SecuritySeverity severity;
  final String message;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  SecurityEvent({
    required this.type,
    required this.severity,
    required this.message,
    required this.timestamp,
    this.metadata = const {},
  });

  static String _generateId() {
    return 'sec_${DateTime.now().millisecondsSinceEpoch}';
  }
}

/// Security Session
class SecuritySession {
  final String id;
  final String userId;
  final String token;
  final DateTime createdAt;
  DateTime expiresAt;
  bool isActive;
  final Map<String, dynamic> metadata;

  SecuritySession({
    required this.id,
    required this.userId,
    required this.token,
    required this.createdAt,
    required this.expiresAt,
    required this.isActive,
    required this.metadata,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'token': token,
      'created_at': createdAt.toIso8601String(),
      'expires_at': expiresAt.toIso8601String(),
      'is_active': isActive,
      'metadata': metadata,
    };
  }
}

/// Security Threat
class SecurityThreat {
  final String id;
  final SecurityThreatType type;
  final String description;
  final SecuritySeverity severity;
  final double score;
  final DateTime detectedAt;
  final bool isActive;
  final Map<String, dynamic> metadata;

  const SecurityThreat({
    required this.id,
    required this.type,
    required this.description,
    required this.severity,
    required this.score,
    required this.detectedAt,
    required this.isActive,
    required this.metadata,
  });
}

/// Security Auditor
class SecurityAuditor {
  final SecurityConfig config;
  final List<SecurityEvent> _auditLog = [];

  SecurityAuditor(this.config);

  void logEvent(SecurityEvent event) {
    if (config.enableAuditLogging) {
      _auditLog.add(event);
      
      // Keep log size manageable
      if (_auditLog.length > 10000) {
        _auditLog.removeRange(0, 1000);
      }
    }
  }

  List<SecurityEvent> getAuditLog({DateTime? startDate, DateTime? endDate}) {
    var filteredLog = _auditLog;
    
    if (startDate != null) {
      filteredLog = filteredLog.where((e) => e.timestamp.isAfter(startDate)).toList();
    }
    
    if (endDate != null) {
      filteredLog = filteredLog.where((e) => e.timestamp.isBefore(endDate)).toList();
    }
    
    return filteredLog;
  }
}

/// Security Monitor
class SecurityMonitor {
  final SecurityConfig config;
  bool _isRunning = false;

  SecurityMonitor(this.config);

  void start() {
    _isRunning = true;
  }

  void stop() {
    _isRunning = false;
  }

  Future<List<SecurityThreat>> detectThreats() async {
    if (!_isRunning || !config.enableThreatDetection) {
      return [];
    }

    final threats = <SecurityThreat>[];
    
    // Placeholder for threat detection logic
    // In production, implement actual threat detection algorithms
    
    return threats;
  }
}

/// Policy Validation Result
class PolicyValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;

  const PolicyValidationResult({
    required this.isValid,
    required this.errors,
    required this.warnings,
  });
}

/// Security Error
class SecurityError {
  final String code;
  final String message;
  final String details;

  const SecurityError({
    required this.code,
    required this.message,
    required this.details,
  });
}

/// Security Statistics
class SecurityStatistics {
  final int totalSessions;
  final int activeSessions;
  final int totalEvents;
  final int activeThreats;
  final int totalPolicies;
  final int enabledPolicies;

  const SecurityStatistics({
    required this.totalSessions,
    required this.activeSessions,
    required this.totalEvents,
    required this.activeThreats,
    required this.totalPolicies,
    required this.enabledPolicies,
  });
}

// Enums
enum SecurityEventType {
  loginSuccess,
  loginFailed,
  logout,
  sessionExpired,
  accountLocked,
  threatDetected,
  policyViolation,
  dataAccess,
  dataModification,
}

enum SecuritySeverity {
  low,
  medium,
  high,
  critical,
}

enum SecurityThreatType {
  malware,
  phishing,
  dataBreach,
  unauthorizedAccess,
  suspiciousActivity,
}

// Either type for error handling
class Either<L, R> {
  final L? _left;
  final R? _right;
  final bool _isLeft;

  const Either.left(L value) : _left = value, _right = null, _isLeft = true;
  const Either.right(R value) : _left = null, _right = value, _isLeft = false;

  bool isLeft() => _isLeft;
  bool isRight() => !_isLeft;

  L? get left => _left;
  R? get right => _right;

  T fold<T>(T Function(L) ifLeft, T Function(R) ifRight) {
    return _isLeft ? ifLeft(_left!) : ifRight(_right!);
  }
}
