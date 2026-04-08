import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vedanta_trade/core/api_config.dart';
import 'package:vedanta_trade/features/authentication/domain/entities/auth_user_entity.dart';

/// OAuth Service for handling third-party authentication
class OAuthService {
  static const String _stateKey = 'oauth_state';
  static const String _providerKey = 'oauth_provider';
  
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock_this_device),
  );
  
  final Dio _dio = Dio();
  
  OAuthService() {
    _dio.options.baseUrl = ApiConfig.baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.options.headers = {'Content-Type': 'application/json'};
  }
  
  /// Get available OAuth providers
  Future<List<OAuthProvider>> getAvailableProviders() async {
    try {
      final response = await _dio.get('/auth/oauth/providers');
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          final providers = List<OAuthProvider>.from(
            data['providers'].map((p) => _parseOAuthProvider(p))
          );
          return providers;
        }
      }
      
      // Return default providers if API fails
      return [
        OAuthProvider.google,
        OAuthProvider.facebook,
        OAuthProvider.apple,
        OAuthProvider.microsoft,
      ];
    } catch (e) {
      // Return default providers on error
      return [
        OAuthProvider.google,
        OAuthProvider.facebook,
        OAuthProvider.apple,
        OAuthProvider.microsoft,
      ];
    }
  }
  
  /// Initiate OAuth login
  Future<OAuthResult> initiateOAuth(OAuthProvider provider) async {
    try {
      // Generate secure state parameter
      final state = _generateSecureState();
      await _secureStorage.write(key: _stateKey, value: state);
      await _secureStorage.write(key: _providerKey, value: provider.name);
      
      // Get OAuth configuration
      final config = await _getOAuthConfig(provider);
      if (config == null) {
        return OAuthResult(
          success: false,
          error: 'OAuth provider not configured',
        );
      }
      
      // Build authorization URL
      final authUrl = _buildAuthorizationUrl(config, state);
      
      // Launch URL in browser
      final launched = await launchUrl(
        Uri.parse(authUrl),
        mode: LaunchMode.externalApplication,
      );
      
      if (!launched) {
        return OAuthResult(
          success: false,
          error: 'Could not launch authentication URL',
        );
      }
      
      return OAuthResult(
        success: true,
        requiresRedirect: true,
        state: state,
      );
    } catch (e) {
      return OAuthResult(
        success: false,
        error: 'Failed to initiate OAuth: ${e.toString()}',
      );
    }
  }
  
  /// Handle OAuth callback
  Future<OAuthResult> handleOAuthCallback(Map<String, String> params) async {
    try {
      // Verify state parameter
      final storedState = await _secureStorage.read(key: _stateKey);
      final providerName = await _secureStorage.read(key: _providerKey);
      
      if (storedState == null || params['state'] != storedState) {
        return OAuthResult(
          success: false,
          error: 'Invalid state parameter',
        );
      }
      
      // Clear stored state
      await Future.wait([
        _secureStorage.delete(key: _stateKey),
        _secureStorage.delete(key: _providerKey),
      ]);
      
      final provider = _parseProviderByName(providerName ?? '');
      
      // Handle authorization code
      if (params.containsKey('code')) {
        return await _exchangeCodeForToken(
          provider,
          params['code']!,
          params['redirect_uri'],
        );
      }
      
      // Handle OAuth error
      if (params.containsKey('error')) {
        return OAuthResult(
          success: false,
          error: 'OAuth error: ${params['error']}',
          errorDescription: params['error_description'],
        );
      }
      
      return OAuthResult(
        success: false,
        error: 'Invalid OAuth callback',
      );
    } catch (e) {
      return OAuthResult(
        success: false,
        error: 'Failed to handle OAuth callback: ${e.toString()}',
      );
    }
  }
  
  /// Exchange authorization code for tokens
  Future<OAuthResult> _exchangeCodeForToken(
    OAuthProvider provider,
    String code,
    String? redirectUri,
  ) async {
    try {
      final response = await _dio.post(
        '/auth/oauth/callback',
        data: {
          'provider': provider.name,
          'code': code,
          'redirect_uri': redirectUri,
          'device_info': await _getDeviceInfo(),
        },
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          final authData = data['data'];
          
          return OAuthResult(
            success: true,
            user: _parseAuthUser(authData['user']),
            accessToken: authData['access_token'],
            refreshToken: authData['refresh_token'],
            expiresAt: DateTime.parse(authData['expires_at']),
            isNewUser: authData['is_new_user'] ?? false,
          );
        }
      }
      
      return OAuthResult(
        success: false,
        error: data['message'] ?? 'Failed to exchange code for token',
      );
    } catch (e) {
      return OAuthResult(
        success: false,
        error: 'Failed to exchange code for token: ${e.toString()}',
      );
    }
  }
  
  /// Link OAuth account to existing user
  Future<OAuthResult> linkOAuthAccount(
    String userId,
    OAuthProvider provider,
    String accessToken,
  ) async {
    try {
      final response = await _dio.post(
        '/auth/oauth/link',
        data: {
          'user_id': userId,
          'provider': provider.name,
          'access_token': accessToken,
        },
        options: Options(
          headers: {'Authorization': 'Bearer ${await _getStoredToken()}'},
        ),
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        return OAuthResult(
          success: data['success'] == true,
          error: data['success'] == true ? null : data['message'],
        );
      }
      
      return OAuthResult(
        success: false,
        error: 'Failed to link OAuth account',
      );
    } catch (e) {
      return OAuthResult(
        success: false,
        error: 'Failed to link OAuth account: ${e.toString()}',
      );
    }
  }
  
  /// Unlink OAuth account
  Future<OAuthResult> unlinkOAuthAccount(
    String userId,
    OAuthProvider provider,
  ) async {
    try {
      final response = await _dio.post(
        '/auth/oauth/unlink',
        data: {
          'user_id': userId,
          'provider': provider.name,
        },
        options: Options(
          headers: {'Authorization': 'Bearer ${await _getStoredToken()}'},
        ),
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        return OAuthResult(
          success: data['success'] == true,
          error: data['success'] == true ? null : data['message'],
        );
      }
      
      return OAuthResult(
        success: false,
        error: 'Failed to unlink OAuth account',
      );
    } catch (e) {
      return OAuthResult(
        success: false,
        error: 'Failed to unlink OAuth account: ${e.toString()}',
      );
    }
  }
  
  /// Get OAuth configuration for provider
  Future<OAuthConfig?> _getOAuthConfig(OAuthProvider provider) async {
    try {
      // First try OpenID Connect discovery
      final oidcConfig = await _discoverOIDCConfiguration(provider);
      if (oidcConfig != null) {
        return oidcConfig;
      }
      
      // Fallback to server configuration
      final response = await _dio.get('/auth/oauth/config/${provider.name}');
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return OAuthConfig.fromJson(data['config']);
        }
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }
  
  /// Discover OpenID Connect configuration
  Future<OAuthConfig?> _discoverOIDCConfiguration(OAuthProvider provider) async {
    try {
      final discoveryUrl = _getOIDCDiscoveryUrl(provider);
      if (discoveryUrl == null) return null;
      
      final response = await _dio.get(discoveryUrl);
      
      if (response.statusCode == 200) {
        final config = response.data;
        
        return OAuthConfig(
          provider: provider,
          clientId: config['client_id'] ?? '',
          clientSecret: config['client_secret'] ?? '',
          authorizationUrl: config['authorization_endpoint'] ?? '',
          tokenUrl: config['token_endpoint'] ?? '',
          userInfoUrl: config['userinfo_endpoint'] ?? '',
          redirectUri: config['redirect_uris']?.first ?? '',
          scopes: List<String>.from(config['scopes_supported'] ?? ['openid', 'profile', 'email']),
        );
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }
  
  /// Get OpenID Connect discovery URL for provider
  String? _getOIDCDiscoveryUrl(OAuthProvider provider) {
    switch (provider) {
      case OAuthProvider.google:
        return 'https://accounts.google.com/.well-known/openid-configuration';
      case OAuthProvider.microsoft:
        return 'https://login.microsoftonline.com/common/v2.0/.well-known/openid-configuration';
      case OAuthProvider.apple:
        return 'https://appleid.apple.com/.well-known/openid-configuration';
      default:
        return null;
    }
  }
  
  /// Build authorization URL
  String _buildAuthorizationUrl(OAuthConfig config, String state) {
    final params = <String, String>{
      'client_id': config.clientId,
      'redirect_uri': config.redirectUri,
      'response_type': 'code',
      'state': state,
      'scope': config.scopes.join(' '),
    };
    
    if (config.provider == OAuthProvider.google) {
      params['access_type'] = 'offline';
      params['prompt'] = 'consent';
    }
    
    final queryString = params.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
    
    return '${config.authorizationUrl}?$queryString';
  }
  
  /// Generate secure state parameter
  String _generateSecureState() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = DateTime.now().microsecondsSinceEpoch;
    final combined = '$timestamp-$random-${Platform.operatingSystem}';
    return sha256.convert(utf8.encode(combined)).toString();
  }
  
  /// Get device information
  Future<Map<String, dynamic>> _getDeviceInfo() async {
    return {
      'platform': Platform.operatingSystem,
      'version': Platform.operatingSystemVersion,
      'user_agent': 'VedantaTrade/${Platform.operatingSystem}',
    };
  }
  
  /// Get stored access token
  Future<String?> _getStoredToken() async {
    const FlutterSecureStorage storage = FlutterSecureStorage();
    return await storage.read(key: 'access_token');
  }
  
  /// Parse OAuth provider by name
  OAuthProvider _parseProviderByName(String name) {
    switch (name.toLowerCase()) {
      case 'google':
        return OAuthProvider.google;
      case 'facebook':
        return OAuthProvider.facebook;
      case 'apple':
        return OAuthProvider.apple;
      case 'microsoft':
        return OAuthProvider.microsoft;
      case 'twitter':
        return OAuthProvider.twitter;
      case 'linkedin':
        return OAuthProvider.linkedin;
      case 'github':
        return OAuthProvider.github;
      default:
        return OAuthProvider.google;
    }
  }
  
  /// Parse OAuth provider from API response
  OAuthProvider _parseOAuthProvider(dynamic data) {
    return _parseProviderByName(data['name']?.toString() ?? '');
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

/// OAuth Configuration
class OAuthConfig {
  final OAuthProvider provider;
  final String clientId;
  final String clientSecret;
  final String authorizationUrl;
  final String tokenUrl;
  final String userInfoUrl;
  final String redirectUri;
  final List<String> scopes;
  
  const OAuthConfig({
    required this.provider,
    required this.clientId,
    required this.clientSecret,
    required this.authorizationUrl,
    required this.tokenUrl,
    required this.userInfoUrl,
    required this.redirectUri,
    required this.scopes,
  });
  
  factory OAuthConfig.fromJson(Map<String, dynamic> json) {
    return OAuthConfig(
      provider: OAuthProvider.values.firstWhere(
        (p) => p.name == json['provider'],
        orElse: () => OAuthProvider.google,
      ),
      clientId: json['client_id'] ?? '',
      clientSecret: json['client_secret'] ?? '',
      authorizationUrl: json['authorization_url'] ?? '',
      tokenUrl: json['token_url'] ?? '',
      userInfoUrl: json['user_info_url'] ?? '',
      redirectUri: json['redirect_uri'] ?? '',
      scopes: List<String>.from(json['scopes'] ?? []),
    );
  }
}

/// OAuth Result
class OAuthResult {
  final bool success;
  final bool requiresRedirect;
  final String? error;
  final String? errorDescription;
  final String? state;
  final AuthUserEntity? user;
  final String? accessToken;
  final String? refreshToken;
  final DateTime? expiresAt;
  final bool isNewUser;
  
  const OAuthResult({
    required this.success,
    this.requiresRedirect = false,
    this.error,
    this.errorDescription,
    this.state,
    this.user,
    this.accessToken,
    this.refreshToken,
    this.expiresAt,
    this.isNewUser = false,
  });
}
