import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

/// Biometric Authentication Service
/// Handles fingerprint, face recognition, and other biometric authentication methods
class BiometricService {
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _biometricTypeKey = 'biometric_type';
  static const String _biometricCredentialsKey = 'biometric_credentials';
  
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock_this_device),
  );
  
  final LocalAuthentication _localAuth = LocalAuthentication();
  
  /// Check if device supports biometric authentication
  Future<bool> isDeviceSupported() async {
    try {
      final isSupported = await _localAuth.canCheckBiometrics;
      if (!isSupported) return false;
      
      final isAvailable = await _localAuth.getAvailableBiometrics();
      return isAvailable.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking biometric support: $e');
      return false;
    }
  }
  
  /// Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      
      return availableBiometrics.map((type) {
        switch (type) {
          case BiometricType.face:
            return BiometricType.face;
          case BiometricType.fingerprint:
            return BiometricType.fingerprint;
          case BiometricType.iris:
            return BiometricType.iris;
          case BiometricType.strong:
            return BiometricType.strong;
          case BiometricType.weak:
            return BiometricType.weak;
          default:
            return BiometricType.fingerprint;
        }
      }).toList();
    } catch (e) {
      debugPrint('Error getting available biometrics: $e');
      return [];
    }
  }
  
  /// Check if biometric authentication is enabled for user
  Future<bool> isBiometricEnabled() async {
    final enabled = await _secureStorage.read(key: _biometricEnabledKey);
    return enabled == 'true';
  }
  
  /// Enable biometric authentication
  Future<BiometricResult> enableBiometric({
    required String userId,
    required String email,
    required String password,
  }) async {
    try {
      // Check if device supports biometrics
      if (!await isDeviceSupported()) {
        return BiometricResult(
          success: false,
          error: 'Device does not support biometric authentication',
        );
      }
      
      // Authenticate with biometrics to confirm
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Enable biometric authentication for quick login',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      
      if (!authenticated) {
        return BiometricResult(
          success: false,
          error: 'Biometric authentication failed',
        );
      }
      
      // Store biometric credentials (encrypted)
      final credentials = {
        'user_id': userId,
        'email': email,
        'password': _encryptPassword(password),
        'enabled_at': DateTime.now().toIso8601String(),
      };
      
      await _secureStorage.write(
        key: _biometricCredentialsKey,
        value: jsonEncode(credentials),
      );
      await _secureStorage.write(key: _biometricEnabledKey, value: 'true');
      
      // Store biometric type
      final availableTypes = await getAvailableBiometrics();
      if (availableTypes.isNotEmpty) {
        await _secureStorage.write(
          key: _biometricTypeKey,
          value: availableTypes.first.name,
        );
      }
      
      return BiometricResult(
        success: true,
        message: 'Biometric authentication enabled successfully',
      );
    } catch (e) {
      return BiometricResult(
        success: false,
        error: 'Failed to enable biometric: ${e.toString()}',
      );
    }
  }
  
  /// Disable biometric authentication
  Future<BiometricResult> disableBiometric() async {
    try {
      await Future.wait([
        _secureStorage.delete(key: _biometricEnabledKey),
        _secureStorage.delete(key: _biometricTypeKey),
        _secureStorage.delete(key: _biometricCredentialsKey),
      ]);
      
      return BiometricResult(
        success: true,
        message: 'Biometric authentication disabled',
      );
    } catch (e) {
      return BiometricResult(
        success: false,
        error: 'Failed to disable biometric: ${e.toString()}',
      );
    }
  }
  
  /// Authenticate using biometrics
  Future<BiometricResult> authenticateWithBiometric() async {
    try {
      // Check if biometric is enabled
      if (!await isBiometricEnabled()) {
        return BiometricResult(
          success: false,
          error: 'Biometric authentication is not enabled',
        );
      }
      
      // Check if device supports biometrics
      if (!await isDeviceSupported()) {
        return BiometricResult(
          success: false,
          error: 'Device does not support biometric authentication',
        );
      }
      
      // Authenticate with biometrics
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to access your account',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
          useErrorDialogs: true,
        ),
      );
      
      if (!authenticated) {
        return BiometricResult(
          success: false,
          error: 'Biometric authentication failed or cancelled',
        );
      }
      
      // Retrieve stored credentials
      final credentialsStr = await _secureStorage.read(key: _biometricCredentialsKey);
      if (credentialsStr == null) {
        return BiometricResult(
          success: false,
          error: 'No biometric credentials found',
        );
      }
      
      final credentials = jsonDecode(credentialsStr) as Map<String, dynamic>;
      
      return BiometricResult(
        success: true,
        userId: credentials['user_id']?.toString(),
        email: credentials['email']?.toString(),
        password: _decryptPassword(credentials['password']?.toString() ?? ''),
      );
    } catch (e) {
      return BiometricResult(
        success: false,
        error: 'Biometric authentication error: ${e.toString()}',
      );
    }
  }
  
  /// Get biometric type
  Future<BiometricType?> getBiometricType() async {
    final typeStr = await _secureStorage.read(key: _biometricTypeKey);
    if (typeStr == null) return null;
    
    try {
      return BiometricType.values.firstWhere(
        (type) => type.name == typeStr,
      );
    } catch (e) {
      return null;
    }
  }
  
  /// Check if biometric authentication is available and enabled
  Future<bool> canUseBiometric() async {
    return await isDeviceSupported() && await isBiometricEnabled();
  }
  
  /// Encrypt password for storage
  String _encryptPassword(String password) {
    final key = 'biometric-key-salt';
    final bytes = utf8.encode(password);
    final hash = sha256.convert(utf8.encode(key));
    return base64.encode(bytes.map((b) => b ^ hash.bytes[0]).toList());
  }
  
  /// Decrypt password from storage
  String _decryptPassword(String encryptedPassword) {
    final key = 'biometric-key-salt';
    final hash = sha256.convert(utf8.encode(key));
    final bytes = base64.decode(encryptedPassword);
    return String.fromCharCodes(bytes.map((b) => b ^ hash.bytes[0]).toList());
  }
  
  /// Get biometric status information
  Future<BiometricStatus> getBiometricStatus() async {
    return BiometricStatus(
      isDeviceSupported: await isDeviceSupported(),
      isEnabled: await isBiometricEnabled(),
      canUse: await canUseBiometric(),
      availableTypes: await getAvailableBiometrics(),
      currentType: await getBiometricType(),
    );
  }
}

/// Biometric Type Enum
enum BiometricType {
  fingerprint,
  face,
  iris,
  strong,
  weak,
}

/// Biometric Result
class BiometricResult {
  final bool success;
  final String? error;
  final String? message;
  final String? userId;
  final String? email;
  final String? password;
  
  const BiometricResult({
    required this.success,
    this.error,
    this.message,
    this.userId,
    this.email,
    this.password,
  });
}

/// Biometric Status
class BiometricStatus {
  final bool isDeviceSupported;
  final bool isEnabled;
  final bool canUse;
  final List<BiometricType> availableTypes;
  final BiometricType? currentType;
  
  const BiometricStatus({
    required this.isDeviceSupported,
    required this.isEnabled,
    required this.canUse,
    required this.availableTypes,
    this.currentType,
  });
}
