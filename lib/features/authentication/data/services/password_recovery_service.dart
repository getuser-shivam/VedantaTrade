import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:vedanta_trade/core/api_config.dart';

/// Enhanced Password Recovery Service
/// Multi-step password recovery with multiple verification methods
class PasswordRecoveryService {
  static const String _recoverySessionKey = 'password_recovery_session';
  static const String _recoveryStepKey = 'recovery_step';
  static const String _recoveryIdentifierKey = 'recovery_identifier';
  static const String _recoveryMethodKey = 'recovery_method';
  static const String _recoveryTokenKey = 'recovery_token';
  
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock_this_device),
  );
  
  final Dio _dio = Dio();
  
  PasswordRecoveryService() {
    _dio.options.baseUrl = ApiConfig.baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 15);
    _dio.options.receiveTimeout = const Duration(seconds: 15);
    _dio.options.headers = {'Content-Type': 'application/json'};
  }
  
  /// Start password recovery process
  Future<PasswordRecoveryResult> initiateRecovery({
    required String identifier,
    required RecoveryMethod method,
  }) async {
    try {
      // Generate session ID
      final sessionId = _generateSessionId();
      
      // Store recovery session
      await _storeRecoverySession(
        sessionId: sessionId,
        identifier: identifier,
        method: method,
        step: RecoveryStep.verification,
      );
      
      // Send verification code based on method
      final result = await _sendVerificationCode(
        identifier: identifier,
        method: method,
        sessionId: sessionId,
      );
      
      if (!result.success) {
        await _clearRecoverySession();
        return result;
      }
      
      return PasswordRecoveryResult(
        success: true,
        sessionId: sessionId,
        step: RecoveryStep.verification,
        message: 'Verification code sent via ${method.name}',
      );
    } catch (e) {
      await _clearRecoverySession();
      return PasswordRecoveryResult(
        success: false,
        error: 'Failed to initiate recovery: ${e.toString()}',
      );
    }
  }
  
  /// Verify the code sent to user
  Future<PasswordRecoveryResult> verifyCode({
    required String sessionId,
    required String code,
  }) async {
    try {
      final session = await _getRecoverySession(sessionId);
      if (session == null) {
        return PasswordRecoveryResult(
          success: false,
          error: 'Invalid or expired recovery session',
        );
      }
      
      final response = await _dio.post(
        '/auth/password/verify-code',
        data: {
          'session_id': sessionId,
          'code': code,
          'identifier': session['identifier'],
          'method': session['method'],
        },
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          // Update session step
          await _updateRecoveryStep(sessionId, RecoveryStep.resetPassword);
          
          return PasswordRecoveryResult(
            success: true,
            sessionId: sessionId,
            step: RecoveryStep.resetPassword,
            token: data['reset_token'],
            message: 'Code verified successfully',
          );
        }
      }
      
      return PasswordRecoveryResult(
        success: false,
        error: data['message'] ?? 'Invalid verification code',
      );
    } catch (e) {
      return PasswordRecoveryResult(
        success: false,
        error: 'Verification failed: ${e.toString()}',
      );
    }
  }
  
  /// Reset password with new password
  Future<PasswordRecoveryResult> resetPassword({
    required String sessionId,
    required String newPassword,
    required String confirmPassword,
    String? resetToken,
  }) async {
    try {
      final session = await _getRecoverySession(sessionId);
      if (session == null) {
        return PasswordRecoveryResult(
          success: false,
          error: 'Invalid or expired recovery session',
        );
      }
      
      // Validate passwords match
      if (newPassword != confirmPassword) {
        return PasswordRecoveryResult(
          success: false,
          error: 'Passwords do not match',
        );
      }
      
      // Check password strength
      final strength = _checkPasswordStrength(newPassword);
      if (strength.level.index < PasswordStrengthLevel.fair.index) {
        return PasswordRecoveryResult(
          success: false,
          error: 'Password is too weak',
          suggestions: strength.suggestions,
        );
      }
      
      final response = await _dio.post(
        '/auth/password/reset',
        data: {
          'session_id': sessionId,
          'reset_token': resetToken,
          'new_password': newPassword,
          'identifier': session['identifier'],
          'method': session['method'],
        },
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          // Clear recovery session
          await _clearRecoverySession();
          
          return PasswordRecoveryResult(
            success: true,
            step: RecoveryStep.completed,
            message: 'Password reset successfully',
          );
        }
      }
      
      return PasswordRecoveryResult(
        success: false,
        error: data['message'] ?? 'Failed to reset password',
      );
    } catch (e) {
      return PasswordRecoveryResult(
        success: false,
        error: 'Password reset failed: ${e.toString()}',
      );
    }
  }
  
  /// Resend verification code
  Future<PasswordRecoveryResult> resendCode({
    required String sessionId,
  }) async {
    try {
      final session = await _getRecoverySession(sessionId);
      if (session == null) {
        return PasswordRecoveryResult(
          success: false,
          error: 'Invalid or expired recovery session',
        );
      }
      
      final method = RecoveryMethod.values.firstWhere(
        (m) => m.name == session['method'],
        orElse: () => RecoveryMethod.email,
      );
      
      final result = await _sendVerificationCode(
        identifier: session['identifier'],
        method: method,
        sessionId: sessionId,
        resend: true,
      );
      
      return result;
    } catch (e) {
      return PasswordRecoveryResult(
        success: false,
        error: 'Failed to resend code: ${e.toString()}',
      );
    }
  }
  
  /// Cancel password recovery
  Future<void> cancelRecovery(String sessionId) async {
    await _clearRecoverySession();
  }
  
  /// Get available recovery methods for user
  Future<List<RecoveryMethod>> getAvailableMethods(String identifier) async {
    try {
      final response = await _dio.get(
        '/auth/password/recovery-methods/$identifier',
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          final methods = List<String>.from(data['methods'] ?? []);
          return methods.map((m) => RecoveryMethod.values.firstWhere(
            (method) => method.name == m,
            orElse: () => RecoveryMethod.email,
          )).toList();
        }
      }
      
      // Return default methods
      return [RecoveryMethod.email, RecoveryMethod.sms];
    } catch (e) {
      return [RecoveryMethod.email, RecoveryMethod.sms];
    }
  }
  
  /// Check if recovery session is valid
  Future<bool> isSessionValid(String sessionId) async {
    final session = await _getRecoverySession(sessionId);
    return session != null;
  }
  
  /// Get current recovery step
  Future<RecoveryStep?> getCurrentStep(String sessionId) async {
    final session = await _getRecoverySession(sessionId);
    if (session == null) return null;
    
    final stepStr = session['step'];
    return RecoveryStep.values.firstWhere(
      (step) => step.name == stepStr,
      orElse: () => RecoveryStep.initiation,
    );
  }
  
  /// Send verification code
  Future<PasswordRecoveryResult> _sendVerificationCode({
    required String identifier,
    required RecoveryMethod method,
    required String sessionId,
    bool resend = false,
  }) async {
    try {
      final response = await _dio.post(
        resend ? '/auth/password/resend-code' : '/auth/password/send-code',
        data: {
          'identifier': identifier,
          'method': method.name,
          'session_id': sessionId,
        },
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return PasswordRecoveryResult(
            success: true,
            message: resend ? 'Code resent successfully' : 'Code sent successfully',
          );
        }
      }
      
      return PasswordRecoveryResult(
        success: false,
        error: data['message'] ?? 'Failed to send verification code',
      );
    } catch (e) {
      return PasswordRecoveryResult(
        success: false,
        error: 'Failed to send code: ${e.toString()}',
      );
    }
  }
  
  /// Store recovery session
  Future<void> _storeRecoverySession({
    required String sessionId,
    required String identifier,
    required RecoveryMethod method,
    required RecoveryStep step,
  }) async {
    final session = {
      'session_id': sessionId,
      'identifier': identifier,
      'method': method.name,
      'step': step.name,
      'created_at': DateTime.now().toIso8601String(),
      'expires_at': DateTime.now().add(const Duration(minutes: 30)).toIso8601String(),
    };
    
    await _secureStorage.write(
      key: _recoverySessionKey,
      value: jsonEncode(session),
    );
  }
  
  /// Get recovery session
  Future<Map<String, dynamic>?> _getRecoverySession(String sessionId) async {
    final sessionStr = await _secureStorage.read(key: _recoverySessionKey);
    if (sessionStr == null) return null;
    
    try {
      final session = jsonDecode(sessionStr) as Map<String, dynamic>;
      
      // Check if session is expired
      final expiresAt = DateTime.tryParse(session['expires_at'] ?? '');
      if (expiresAt == null || DateTime.now().isAfter(expiresAt)) {
        await _clearRecoverySession();
        return null;
      }
      
      // Verify session ID matches
      if (session['session_id'] != sessionId) {
        return null;
      }
      
      return session;
    } catch (e) {
      return null;
    }
  }
  
  /// Update recovery step
  Future<void> _updateRecoveryStep(String sessionId, RecoveryStep step) async {
    final sessionStr = await _secureStorage.read(key: _recoverySessionKey);
    if (sessionStr == null) return;
    
    try {
      final session = jsonDecode(sessionStr) as Map<String, dynamic>;
      session['step'] = step.name;
      await _secureStorage.write(
        key: _recoverySessionKey,
        value: jsonEncode(session),
      );
    } catch (e) {
      // Ignore errors
    }
  }
  
  /// Clear recovery session
  Future<void> _clearRecoverySession() async {
    await Future.wait([
      _secureStorage.delete(key: _recoverySessionKey),
      _secureStorage.delete(key: _recoveryStepKey),
      _secureStorage.delete(key: _recoveryIdentifierKey),
      _secureStorage.delete(key: _recoveryMethodKey),
      _secureStorage.delete(key: _recoveryTokenKey),
    ]);
  }
  
  /// Generate secure session ID
  String _generateSessionId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(100000);
    final combined = '$timestamp-$random';
    return sha256.convert(utf8.encode(combined)).toString().substring(0, 32);
  }
  
  /// Check password strength
  PasswordStrength _checkPasswordStrength(String password) {
    int score = 0;
    
    if (password.length >= 8) score += 1;
    if (password.contains(RegExp(r'[A-Z]'))) score += 1;
    if (password.contains(RegExp(r'[a-z]'))) score += 1;
    if (password.contains(RegExp(r'[0-9]'))) score += 1;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score += 1;
    
    PasswordStrengthLevel level;
    List<String> suggestions = [];
    
    if (score <= 2) {
      level = PasswordStrengthLevel.veryWeak;
      suggestions = ['Use at least 8 characters', 'Include uppercase and lowercase letters'];
    } else if (score <= 3) {
      level = PasswordStrengthLevel.weak;
      suggestions = ['Add more variety to your password'];
    } else if (score <= 4) {
      level = PasswordStrengthLevel.fair;
      suggestions = [];
    } else {
      level = PasswordStrengthLevel.strong;
      suggestions = [];
    }
    
    return PasswordStrength(
      score: score,
      level: level,
      suggestions: suggestions,
    );
  }
}

/// Recovery Method
enum RecoveryMethod {
  email,
  sms,
  securityQuestions,
  backupCode,
}

/// Recovery Step
enum RecoveryStep {
  initiation,
  verification,
  resetPassword,
  completed,
}

/// Password Recovery Result
class PasswordRecoveryResult {
  final bool success;
  final String? error;
  final String? message;
  final String? sessionId;
  final String? token;
  final RecoveryStep? step;
  final List<String>? suggestions;
  
  const PasswordRecoveryResult({
    required this.success,
    this.error,
    this.message,
    this.sessionId,
    this.token,
    this.step,
    this.suggestions,
  });
}

/// Password Strength
class PasswordStrength {
  final int score;
  final PasswordStrengthLevel level;
  final List<String> suggestions;
  
  const PasswordStrength({
    required this.score,
    required this.level,
    required this.suggestions,
  });
}

/// Password Strength Level
enum PasswordStrengthLevel {
  veryWeak,
  weak,
  fair,
  good,
  strong,
}
