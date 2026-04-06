import 'package:dartz/dartz.dart';
import '../entities/auth_user_entity.dart';

/// Authentication Repository Interface
/// Abstract interface for authentication operations
abstract class AuthenticationRepository {
  /// User Registration
  Future<Either<String, AuthUserEntity>> registerUser({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? middleName,
    String? phoneNumber,
    UserRole? role,
    UserProfile? profile,
  });

  /// Email Registration
  Future<Either<String, AuthUserEntity>> registerWithEmail({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? middleName,
  });

  /// Phone Registration
  Future<Either<String, AuthUserEntity>> registerWithPhone({
    required String phoneNumber,
    required String password,
    required String firstName,
    required String lastName,
    String? middleName,
  });

  /// Verify MFA Login
  Future<Either<String, AuthResult>> verifyMfaLogin({
    required String identifier,
    required String mfaToken,
    required String mfaCode,
  });

  /// User Login
  Future<Either<String, AuthResult>> loginUser({
    required String identifier, // email or phone
    required String password,
    bool rememberMe = false,
    String? deviceToken,
    String? deviceInfo,
  });

  /// Email Login
  Future<Either<String, AuthResult>> loginWithEmail({
    required String email,
    required String password,
    bool rememberMe = false,
    String? deviceToken,
    String? deviceInfo,
  });

  /// Phone Login
  Future<Either<String, AuthResult>> loginWithPhone({
    required String phoneNumber,
    required String password,
    bool rememberMe = false,
    String? deviceToken,
    String? deviceInfo,
  });

  /// OAuth Login
  Future<Either<String, AuthResult>> loginWithOAuth({
    required OAuthProvider provider,
    required String accessToken,
    String? deviceToken,
    String? deviceInfo,
  });

  /// Biometric Login
  Future<Either<String, AuthResult>> loginWithBiometric({
    required String userId,
    String? deviceToken,
    String? deviceInfo,
  });

  /// Refresh Token
  Future<Either<String, AuthResult>> refreshToken(String refreshToken);

  /// Logout
  Future<Either<String, void>> logout({
    String? sessionId,
    bool logoutAllDevices = false,
  });

  /// Send Email Verification
  Future<Either<String, void>> sendEmailVerification(String email);

  /// Send Phone Verification
  Future<Either<String, void>> sendPhoneVerification(String phoneNumber);

  /// Verify Email
  Future<Either<String, AuthUserEntity>> verifyEmail({
    required String email,
    required String verificationCode,
  });

  /// Verify Phone
  Future<Either<String, AuthUserEntity>> verifyPhone({
    required String phoneNumber,
    required String verificationCode,
  });

  /// Resend Email Verification
  Future<Either<String, void>> resendEmailVerification(String email);

  /// Resend Phone Verification
  Future<Either<String, void>> resendPhoneVerification(String phoneNumber);

  /// Password Reset Request
  Future<Either<String, void>> requestPasswordReset({
    required String identifier, // email or phone
    PasswordResetMethod method = PasswordResetMethod.email,
  });

  /// Reset Password
  Future<Either<String, void>> resetPassword({
    required String identifier,
    required String verificationCode,
    required String newPassword,
  });

  /// Change Password
  Future<Either<String, void>> changePassword({
    required String userId,
    required String currentPassword,
    required String newPassword,
  });

  /// Setup Two-Factor Authentication
  Future<Either<String, void>> setupTwoFactor({
    required String userId,
    required TwoFactorMethod method,
    String? phoneNumber,
    String? email,
  });

  /// Enable Two-Factor Authentication
  Future<Either<String, void>> enableTwoFactor({
    required String userId,
    required String verificationCode,
    required TwoFactorMethod method,
  });

  /// Disable Two-Factor Authentication
  Future<Either<String, void>> disableTwoFactor({
    required String userId,
    required String currentPassword,
    required String twoFactorCode,
  });

  /// Generate Backup Codes
  Future<Either<String, List<String>>> generateBackupCodes(String userId);

  /// Verify Backup Code
  Future<Either<String, AuthResult>> verifyBackupCode({
    required String userId,
    required String backupCode,
  });

  /// Get Current User
  Future<Either<String, AuthUserEntity>> getCurrentUser();

  /// Update User Profile
  Future<Either<String, AuthUserEntity>> updateProfile({
    required String userId,
    String? firstName,
    String? lastName,
    String? middleName,
    String? phoneNumber,
    String? profileImageUrl,
    UserProfile? profile,
  });

  /// Update User Preferences
  Future<Either<String, void>> updatePreferences({
    required String userId,
    required UserPreferences preferences,
  });

  /// Update Security Settings
  Future<Either<String, void>> updateSecuritySettings({
    required String userId,
    required SecuritySettings securitySettings,
  });

  /// Get User Sessions
  Future<Either<String, List<UserSession>>> getUserSessions(String userId);

  /// Terminate Session
  Future<Either<String, void>> terminateSession({
    required String userId,
    required String sessionId,
  });

  /// Terminate All Sessions
  Future<Either<String, void>> terminateAllSessions(String userId);

  /// Add Device to Whitelist
  Future<Either<String, void>> addDeviceToWhitelist({
    required String userId,
    required String deviceInfo,
    required String ipAddress,
  });

  /// Remove Device from Whitelist
  Future<Either<String, void>> removeDeviceFromWhitelist({
    required String userId,
    required String deviceId,
  });

  /// Get Security Audit Log
  Future<Either<String, List<SecurityAuditEntry>>> getSecurityAuditLog({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int limit = 50,
  });

  /// Report Suspicious Activity
  Future<Either<String, void>> reportSuspiciousActivity({
    required String userId,
    required String activity,
    String? description,
    Map<String, dynamic>? metadata,
  });

  /// Check Account Lock Status
  Future<Either<String, AccountLockStatus>> checkAccountLockStatus(String identifier);

  /// Unlock Account
  Future<Either<String, void>> unlockAccount({
    required String identifier,
    required String verificationCode,
  });

  /// Validate Session
  Future<Either<String, bool>> validateSession(String sessionId);

  /// Refresh User Data
  Future<Either<String, AuthUserEntity>> refreshUserData(String userId);

  /// Get OAuth Providers
  Future<Either<String, List<OAuthProvider>>> getAvailableOAuthProviders();

  /// Link OAuth Account
  Future<Either<String, void>> linkOAuthAccount({
    required String userId,
    required OAuthProvider provider,
    required String accessToken,
  });

  /// Unlink OAuth Account
  Future<Either<String, void>> unlinkOAuthAccount({
    required String userId,
    required OAuthProvider provider,
  });

  /// Get Password Strength
  Future<Either<String, PasswordStrength>> checkPasswordStrength(String password);

  /// Get Security Questions
  Future<Either<String, List<SecurityQuestion>>> getSecurityQuestions();

  /// Set Security Questions
  Future<Either<String, void>> setSecurityQuestions({
    required String userId,
    required List<SecurityQuestionAnswer> answers,
  });

  /// Verify Security Questions
  Future<Either<String, bool>> verifySecurityQuestions({
    required String userId,
    required List<SecurityQuestionAnswer> answers,
  });

  /// Get Authentication History
  Future<Either<String, List<AuthHistoryEntry>>> getAuthHistory({
    required String userId,
    int page = 1,
    int limit = 20,
  });

  /// Clear Authentication History
  Future<Either<String, void>> clearAuthHistory(String userId);

  /// Get Device Information
  Future<Either<String, DeviceInfo>> getDeviceInfo(String deviceId);

  /// Update Device Information
  Future<Either<String, void>> updateDeviceInfo({
    required String deviceId,
    required DeviceInfo deviceInfo,
  });

  /// Check Rate Limiting
  Future<Either<String, RateLimitStatus>> checkRateLimit(String identifier, String action);

  /// Report Login Attempt
  Future<Either<String, void>> reportLoginAttempt({
    required String identifier,
    required bool success,
    String? ipAddress,
    String? userAgent,
    String? failureReason,
  });

  /// Get Security Recommendations
  Future<Either<String, List<SecurityRecommendation>>> getSecurityRecommendations(String userId);

  /// Enable Account Recovery
  Future<Either<String, void>> enableAccountRecovery({
    required String userId,
    AccountRecoveryMethod method,
    String? recoveryEmail,
    String? recoveryPhone,
  });

  /// Test Account Recovery
  Future<Either<String, bool>> testAccountRecovery({
    required String userId,
    required String recoveryCode,
  });

  /// Complete Account Recovery
  Future<Either<String, AuthUserEntity>> completeAccountRecovery({
    required String userId,
    required String recoveryCode,
    required String newPassword,
  });
}

/// Authentication Result
class AuthResult {
  final AuthUserEntity user;
  final String accessToken;
  final String refreshToken;
  final String sessionId;
  final DateTime expiresAt;
  final UserSession session;
  final bool requiresTwoFactor;
  final TwoFactorMethod? requiredTwoFactorMethod;
  final DateTime? passwordExpiresAt;
  final Map<String, dynamic> metadata;

  const AuthResult({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
    required this.sessionId,
    required this.expiresAt,
    required this.session,
    this.requiresTwoFactor = false,
    this.requiredTwoFactorMethod,
    this.passwordExpiresAt,
    this.metadata = const {},
  });

  /// Check if token is expired
  bool get isTokenExpired => DateTime.now().isAfter(expiresAt);

  /// Check if password is expiring
  bool get isPasswordExpiring {
// if (passwordExpiresAt == null) return false; // TODO: Move to environment variables
    final sevenDaysFromNow = DateTime.now().add(const Duration(days: 7));
    return passwordExpiresAt!.isBefore(sevenDaysFromNow);
  }

  /// Get token remaining time
  Duration get tokenRemainingTime {
    final now = DateTime.now();
    if (now.isAfter(expiresAt)) return Duration.zero;
    return expiresAt.difference(now);
  }

  /// Get formatted token expiry
  String get formattedTokenExpiry {
// final remaining = tokenRemainingTime; // TODO: Move to environment variables
    if (remaining.inDays > 0) {
      return '${remaining.inDays}d ${remaining.inHours % 24}h';
    } else if (remaining.inHours > 0) {
      return '${remaining.inHours}h ${remaining.inMinutes % 60}m';
    } else {
      return '${remaining.inMinutes}m';
    }
  }
}

/// OAuth Provider
enum OAuthProvider {
  google,
  facebook,
  apple,
  microsoft,
  twitter,
  linkedin,
  github,
}

/// Password Reset Method
enum PasswordResetMethod {
  email,
  phone,
  securityQuestions,
  oauth,
}

/// Security Audit Entry
class SecurityAuditEntry {
  final String id;
  final String userId;
  final SecurityEventType eventType;
  final String description;
  final String? ipAddress;
  final String? userAgent;
  final String? location;
  final DateTime timestamp;
  final bool success;
  final String? failureReason;
  final Map<String, dynamic> metadata;

  const SecurityAuditEntry({
    required this.id,
    required this.userId,
    required this.eventType,
    required this.description,
    this.ipAddress,
    this.userAgent,
    this.location,
    required this.timestamp,
    required this.success,
    this.failureReason,
    this.metadata = const {},
  });
}

/// Account Lock Status
class AccountLockStatus {
  final bool isLocked;
  final DateTime? lockedUntil;
  final String? lockReason;
  final int failedAttempts;
  final int maxAttempts;
  final int remainingAttempts;
  final DateTime? lastAttemptAt;

  const AccountLockStatus({
    required this.isLocked,
    this.lockedUntil,
    this.lockReason,
    required this.failedAttempts,
    required this.maxAttempts,
    required this.remainingAttempts,
    this.lastAttemptAt,
  });

  /// Get lock duration
  Duration? get lockDuration {
    if (lockedUntil == null) return null;
    return lockedUntil!.difference(DateTime.now());
  }

  /// Get formatted lock duration
  String get formattedLockDuration {
    final duration = lockDuration;
    if (duration == null || duration!.isNegative) return 'Unlocked';
    
    if (duration!.inDays > 0) {
      return '${duration!.inDays}d ${duration!.inHours % 24}h';
    } else if (duration!.inHours > 0) {
      return '${duration!.inHours}h ${duration!.inMinutes % 60}m';
    } else {
      return '${duration!.inMinutes}m';
    }
  }
}

/// Security Event Type
enum SecurityEventType {
  login,
  logout,
  passwordChange,
  twoFactorEnabled,
  twoFactorDisabled,
  accountLocked,
  accountUnlocked,
  suspiciousActivity,
  passwordReset,
  emailVerification,
  phoneVerification,
  oauthLinked,
  oauthUnlinked,
  sessionTerminated,
  securitySettingsChanged,
  profileUpdated,
}

/// Password Strength
class PasswordStrength {
  final int score;
  final PasswordStrengthLevel level;
  final List<String> suggestions;
  final Map<String, bool> criteria;

  const PasswordStrength({
    required this.score,
    required this.level,
    required this.suggestions,
    required this.criteria,
  });

  /// Get formatted strength
  String get formattedStrength {
    switch (level) {
      case PasswordStrengthLevel.veryWeak:
        return 'Very Weak';
      case PasswordStrengthLevel.weak:
        return 'Weak';
      case PasswordStrengthLevel.fair:
        return 'Fair';
      case PasswordStrengthLevel.good:
        return 'Good';
      case PasswordStrengthLevel.strong:
        return 'Strong';
      case PasswordStrengthLevel.veryStrong:
        return 'Very Strong';
    }
  }

  /// Get strength color
  String get strengthColor {
    switch (level) {
      case PasswordStrengthLevel.veryWeak:
        return '#FF5252'; // Red
      case PasswordStrengthLevel.weak:
        return '#FF9500'; // Orange
      case PasswordStrengthLevel.fair:
        return '#FFC107'; // Yellow
      case PasswordStrengthLevel.good:
        return '#48BB78'; // Green
      case PasswordStrengthLevel.strong:
        return '#0D6EFD'; // Blue
      case PasswordStrengthLevel.veryStrong:
        return '#6F42C1'; // Purple
    }
  }
}

/// Password Strength Level
enum PasswordStrengthLevel {
  veryWeak,
  weak,
  fair,
  good,
  strong,
  veryStrong,
}

/// Security Question
class SecurityQuestion {
  final String id;
  final String question;
  final String category;
  final bool isActive;

  const SecurityQuestion({
    required this.id,
    required this.question,
    required this.category,
    this.isActive = true,
  });
}

/// Security Question Answer
class SecurityQuestionAnswer {
  final String questionId;
  final String answer;
  final String? hashedAnswer;

  const SecurityQuestionAnswer({
    required this.questionId,
    required this.answer,
    this.hashedAnswer,
  });
}

/// Auth History Entry
class AuthHistoryEntry {
  final String id;
  final String userId;
  final AuthAction action;
  final String? identifier;
  final DateTime timestamp;
  final bool success;
  final String? ipAddress;
  final String? userAgent;
  final String? location;
  final String? failureReason;
  final Map<String, dynamic> metadata;

  const AuthHistoryEntry({
    required this.id,
    required this.userId,
    required this.action,
    this.identifier,
    required this.timestamp,
    required this.success,
    this.ipAddress,
    this.userAgent,
    this.location,
    this.failureReason,
    this.metadata = const {},
  });
}

/// Auth Action
enum AuthAction {
  login,
  logout,
  register,
  passwordChange,
  passwordReset,
  emailVerification,
  phoneVerification,
  twoFactorSetup,
  twoFactorVerification,
  oauthLogin,
  accountLock,
  accountUnlock,
  profileUpdate,
  securitySettingsUpdate,
}

/// Device Info
class DeviceInfo {
  final String id;
  final String userId;
  final String type;
  final String name;
  final String os;
  final String osVersion;
  final String appVersion;
  final String? ipAddress;
  final String? location;
  final DateTime firstSeen;
  final DateTime lastSeen;
  final bool isActive;
  final bool isTrusted;
  final Map<String, dynamic> metadata;

  const DeviceInfo({
    required this.id,
    required this.userId,
    required this.type,
    required this.name,
    required this.os,
    required this.osVersion,
    required this.appVersion,
    this.ipAddress,
    this.location,
    required this.firstSeen,
    required this.lastSeen,
    required this.isActive,
    this.isTrusted = false,
    this.metadata = const {},
  });

  /// Get device age
  Duration get deviceAge => DateTime.now().difference(firstSeen);

  /// Get formatted device age
  String get formattedDeviceAge {
    final age = deviceAge;
    if (age.inDays > 0) {
      return '${age.inDays} days ago';
    } else if (age.inHours > 0) {
      return '${age.inHours} hours ago';
    } else {
      return '${age.inMinutes} minutes ago';
    }
  }
}

/// Rate Limit Status
class RateLimitStatus {
  final bool isLimited;
  final int remainingAttempts;
  final int maxAttempts;
  final DateTime? resetAt;
  final Duration? resetIn;

  const RateLimitStatus({
    required this.isLimited,
    required this.remainingAttempts,
    required this.maxAttempts,
    this.resetAt,
    this.resetIn,
  });

  /// Get formatted reset time
  String get formattedResetTime {
    if (resetAt == null) return 'No limit';
    
    final now = DateTime.now();
    if (now.isAfter(resetAt!)) return 'Available now';
    
    final remaining = resetAt!.difference(now);
    if (remaining.inDays > 0) {
      return '${remaining.inDays}d ${remaining.inHours % 24}h';
    } else if (remaining.inHours > 0) {
      return '${remaining.inHours}h ${remaining.inMinutes % 60}m';
    } else {
      return '${remaining.inMinutes}m';
    }
  }
}

/// Account Recovery Method
enum AccountRecoveryMethod {
  email,
  phone,
  securityQuestions,
  oauth,
  trustedDevice,
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

  const SecurityRecommendation({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.priority,
    this.isActionable = true,
    this.actionUrl,
    this.metadata = const {},
  });
}

/// Security Recommendation Type
enum SecurityRecommendationType {
  passwordStrength,
  twoFactorAuth,
  sessionManagement,
  deviceSecurity,
  accountRecovery,
  dataPrivacy,
  phishingProtection,
}

/// Security Recommendation Priority
enum SecurityRecommendationPriority {
  low,
  medium,
  high,
  critical,
}
