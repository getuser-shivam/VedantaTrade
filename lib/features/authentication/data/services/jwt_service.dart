import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:vedanta_trade/core/api_config.dart';

/// JWT Service for token management and validation
class JWTService {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _tokenExpiryKey = 'token_expiry';
  static const String _userIdKey = 'user_id';
  static const String _deviceIdKey = 'device_id';
  
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock_this_device),
  );
  
  final Dio _dio = Dio();
  
  /// Get current access token
  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: _accessTokenKey);
  }
  
  /// Get current refresh token
  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: _refreshTokenKey);
  }
  
  /// Get token expiry time
  Future<DateTime?> getTokenExpiry() async {
    final expiryStr = await _secureStorage.read(key: _tokenExpiryKey);
    if (expiryStr == null) return null;
    return DateTime.parse(expiryStr);
  }
  
  /// Get current user ID
  Future<String?> getUserId() async {
    return await _secureStorage.read(key: _userIdKey);
  }
  
  /// Get device ID
  Future<String?> getDeviceId() async {
    String? deviceId = await _secureStorage.read(key: _deviceIdKey);
    if (deviceId == null) {
      deviceId = _generateDeviceId();
      await _secureStorage.write(key: _deviceIdKey, value: deviceId);
    }
    return deviceId;
  }
  
  /// Store tokens securely
  Future<void> storeTokens({
    required String accessToken,
    required String refreshToken,
    required String userId,
    required DateTime expiresAt,
  }) async {
    await Future.wait([
      _secureStorage.write(key: _accessTokenKey, value: accessToken),
      _secureStorage.write(key: _refreshTokenKey, value: refreshToken),
      _secureStorage.write(key: _tokenExpiryKey, value: expiresAt.toIso8601String()),
      _secureStorage.write(key: _userIdKey, value: userId),
    ]);
  }
  
  /// Clear all stored tokens
  Future<void> clearTokens() async {
    await Future.wait([
      _secureStorage.delete(key: _accessTokenKey),
      _secureStorage.delete(key: _refreshTokenKey),
      _secureStorage.delete(key: _tokenExpiryKey),
      _secureStorage.delete(key: _userIdKey),
    ]);
  }
  
  /// Check if access token is expired
  Future<bool> isTokenExpired() async {
    final expiry = await getTokenExpiry();
    if (expiry == null) return true;
    
    // Add 5-minute buffer before expiry
    final now = DateTime.now().add(const Duration(minutes: 5));
    return now.isAfter(expiry);
  }
  
  /// Check if access token is valid
  Future<bool> isAccessTokenValid() async {
    final token = await getAccessToken();
    if (token == null) return false;
    
    try {
      // Check if token is expired
      if (JwtDecoder.isExpired(token)) return false;
      
      // Verify token structure
      final decodedToken = JwtDecoder.decode(token);
      return decodedToken != null;
    } catch (e) {
      return false;
    }
  }
  
  /// Decode JWT token payload
  Future<Map<String, dynamic>?> decodeToken() async {
    final token = await getAccessToken();
    if (token == null) return null;
    
    try {
      return JwtDecoder.decode(token);
    } catch (e) {
      return null;
    }
  }
  
  /// Get user info from token
  Future<Map<String, dynamic>?> getUserFromToken() async {
    final token = await getAccessToken();
    if (token == null) return null;
    
    try {
      final decodedToken = JwtDecoder.decode(token);
      return {
        'userId': decodedToken['sub'] ?? decodedToken['user_id'],
        'email': decodedToken['email'],
        'role': decodedToken['role'],
        'permissions': decodedToken['permissions'] ?? [],
        'iat': decodedToken['iat'],
        'exp': decodedToken['exp'],
      };
    } catch (e) {
      return null;
    }
  }
  
  /// Refresh access token using refresh token
  Future<Map<String, dynamic>?> refreshAccessToken() async {
    final refreshToken = await getRefreshToken();
    if (refreshToken == null) return null;
    
    try {
      final response = await _dio.post(
        '${ApiConfig.baseUrl}/auth/refresh',
        data: {
          'refresh_token': refreshToken,
          'device_id': await getDeviceId(),
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'User-Agent': _getUserAgent(),
          },
        ),
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          final newAccessToken = data['access_token'];
          final newRefreshToken = data['refresh_token'] ?? refreshToken;
          final expiresAt = DateTime.parse(data['expires_at']);
          final userId = data['user_id'] ?? await getUserId();
          
          await storeTokens(
            accessToken: newAccessToken,
            refreshToken: newRefreshToken,
            userId: userId,
            expiresAt: expiresAt,
          );
          
          return {
            'success': true,
            'access_token': newAccessToken,
            'refresh_token': newRefreshToken,
            'expires_at': expiresAt.toIso8601String(),
            'user_id': userId,
          };
        }
      }
      
      return null;
    } on DioException catch (e) {
      // If refresh token is invalid, clear all tokens
      if (e.response?.statusCode == 401) {
        await clearTokens();
      }
      return null;
    } catch (e) {
      return null;
    }
  }
  
  /// Validate token with server
  Future<bool> validateTokenWithServer() async {
    final token = await getAccessToken();
    if (token == null) return false;
    
    try {
      final response = await _dio.get(
        '${ApiConfig.baseUrl}/auth/validate',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'User-Agent': _getUserAgent(),
          },
        ),
      );
      
      return response.statusCode == 200 && response.data['valid'] == true;
    } catch (e) {
      return false;
    }
  }
  
  /// Get authorization header
  Future<String?> getAuthHeader() async {
    final token = await getAccessToken();
    if (token == null) return null;
    return 'Bearer $token';
  }
  
  /// Generate secure device ID
  String _generateDeviceId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(100000);
    final deviceInfo = Platform.operatingSystem;
    final combined = '$deviceInfo-$timestamp-$random';
    return sha256.convert(utf8.encode(combined)).toString();
  }
  
  /// Get user agent string
  String _getUserAgent() {
    return 'VedantaTrade/${Platform.operatingSystem}';
  }
  
  /// Get token remaining time in seconds
  Future<int?> getTokenRemainingTime() async {
    final expiry = await getTokenExpiry();
    if (expiry == null) return null;
    
    final now = DateTime.now();
    if (now.isAfter(expiry)) return 0;
    
    return expiry.difference(now).inSeconds;
  }
  
  /// Check if token needs refresh (within 5 minutes of expiry)
  Future<bool> shouldRefreshToken() async {
    final remainingTime = await getTokenRemainingTime();
    if (remainingTime == null) return true;
    
    return remainingTime <= 300; // 5 minutes
  }
  
  /// Get token information
  Future<Map<String, dynamic>?> getTokenInfo() async {
    final token = await getAccessToken();
    if (token == null) return null;
    
    try {
      final decodedToken = JwtDecoder.decode(token);
      return {
        'userId': decodedToken['sub'] ?? decodedToken['user_id'],
        'email': decodedToken['email'],
        'role': decodedToken['role'],
        'permissions': decodedToken['permissions'] ?? [],
        'issuedAt': DateTime.fromMillisecondsSinceEpoch((decodedToken['iat'] ?? 0) * 1000),
        'expiresAt': DateTime.fromMillisecondsSinceEpoch((decodedToken['exp'] ?? 0) * 1000),
        'issuer': decodedToken['iss'],
        'audience': decodedToken['aud'],
      };
    } catch (e) {
      return null;
    }
  }
  
  /// Revoke token on server
  Future<bool> revokeToken() async {
    final token = await getAccessToken();
    if (token == null) return false;
    
    try {
      final response = await _dio.post(
        '${ApiConfig.baseUrl}/auth/revoke',
        data: {
          'token': token,
          'device_id': await getDeviceId(),
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'User-Agent': _getUserAgent(),
          },
        ),
      );
      
      if (response.statusCode == 200) {
        await clearTokens();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
  
  /// Check if user has specific permission from token
  Future<bool> hasPermission(String permission) async {
    final tokenInfo = await getTokenInfo();
    if (tokenInfo == null) return false;
    
    final permissions = List<String>.from(tokenInfo['permissions'] ?? []);
    return permissions.contains(permission) || permissions.contains('*');
  }
  
  /// Check if user has specific role from token
  Future<bool> hasRole(String role) async {
    final tokenInfo = await getTokenInfo();
    if (tokenInfo == null) return false;
    
    return tokenInfo['role'] == role;
  }
}

/// Token validation result
class TokenValidationResult {
  final bool isValid;
  final bool isExpired;
  final bool needsRefresh;
  final String? error;
  final Map<String, dynamic>? payload;
  
  const TokenValidationResult({
    required this.isValid,
    required this.isExpired,
    required this.needsRefresh,
    this.error,
    this.payload,
  });
}
