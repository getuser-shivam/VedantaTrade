import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'auth_user_entity.g.dart';

/// Authentication User Entity
/// Represents an authenticated user in the system
@JsonSerializable()
class AuthUserEntity extends Equatable {
  final String id;
  final String email;
  final String? phoneNumber;
  final String firstName;
  final String lastName;
  final String? middleName;
  final String fullName;
  final String? profileImageUrl;
  final UserRole role;
  final UserStatus status;
  final bool isEmailVerified;
  final bool isPhoneVerified;
  final bool isTwoFactorEnabled;
  final DateTime? emailVerifiedAt;
  final DateTime? phoneVerifiedAt;
  final DateTime? lastLoginAt;
  final DateTime? passwordChangedAt;
  final List<String> permissions;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserPreferences preferences;
  final List<UserSession> activeSessions;
  final SecuritySettings securitySettings;
  final UserProfile? profile;

  const AuthUserEntity({
    required this.id,
    required this.email,
    this.phoneNumber,
    required this.firstName,
    required this.lastName,
    this.middleName,
    required this.fullName,
    this.profileImageUrl,
    required this.role,
    required this.status,
    required this.isEmailVerified,
    required this.isPhoneVerified,
    required this.isTwoFactorEnabled,
    this.emailVerifiedAt,
    this.phoneVerifiedAt,
    this.lastLoginAt,
    this.passwordChangedAt,
    this.permissions = const [],
    this.metadata = const {},
    required this.createdAt,
    required this.updatedAt,
    required this.preferences,
    this.activeSessions = const [],
    required this.securitySettings,
    this.profile,
  });

  /// Get user's display name
  String get displayName {
    if (fullName.isNotEmpty) return fullName;
    if (middleName != null && middleName!.isNotEmpty) {
      return '$firstName $middleName $lastName';
    }
    return '$firstName $lastName';
  }

  /// Get user's initials
  String get initials {
    final nameParts = displayName.split(' ').where((part) => part.isNotEmpty).toList();
    if (nameParts.isEmpty) return '';
    if (nameParts.length == 1) return nameParts.first[0].toUpperCase();
    return nameParts.map((part) => part[0].toUpperCase()).take(2).join();
  }

  /// Check if user is active
  bool get isActive => status == UserStatus.active;

  /// Check if user is suspended
  bool get isSuspended => status == UserStatus.suspended;

  /// Check if user is pending verification
  bool get isPendingVerification => 
      status == UserStatus.pendingEmailVerification ||
      status == UserStatus.pendingPhoneVerification;

  /// Check if user has any active sessions
  bool get hasActiveSessions => activeSessions.isNotEmpty;

  /// Get primary session
  UserSession? get primarySession {
    return activeSessions.where((session) => session.isPrimary).firstOrNull;
  }

  /// Get session count
  int get sessionCount => activeSessions.length;

  /// Check if user can perform action
  bool canPerformAction(String permission) {
    return permissions.contains(permission) || role.hasPermission(permission);
  }

  /// Get all permissions
  List<String> get allPermissions {
    final allPerms = <String>[...permissions];
    allPerms.addAll(role.permissions);
    return allPerms.toSet().toList();
  }

  /// Check if user needs password change
  bool get needsPasswordChange {
// if (passwordChangedAt == null) return true; // TODO: Move to environment variables
// final daysSinceChange = DateTime.now().difference(passwordChangedAt!).inDays; // TODO: Move to environment variables
    return daysSinceChange > 90; // Password change required every 90 days
  }

  /// Check if user has security risks
  bool get hasSecurityRisks {
    return !isEmailVerified || 
           !isPhoneVerified || 
           needsPasswordChange ||
           activeSessions.length > 3;
  }

  /// Get security risk level
  SecurityRiskLevel get securityRiskLevel {
    int riskScore = 0;
    
    if (!isEmailVerified) riskScore += 2;
    if (!isPhoneVerified) riskScore += 1;
    if (needsPasswordChange) riskScore += 1;
    if (!isTwoFactorEnabled) riskScore += 2;
    if (activeSessions.length > 3) riskScore += 1;
    if (activeSessions.length > 5) riskScore += 2;

    if (riskScore >= 5) return SecurityRiskLevel.high;
    if (riskScore >= 3) return SecurityRiskLevel.medium;
    if (riskScore >= 1) return SecurityRiskLevel.low;
    return SecurityRiskLevel.none;
  }

  /// Create copy with updated values
  AuthUserEntity copyWith({
    String? id,
    String? email,
    String? phoneNumber,
    String? firstName,
    String? lastName,
    String? middleName,
    String? fullName,
    String? profileImageUrl,
    UserRole? role,
    UserStatus? status,
    bool? isEmailVerified,
    bool? isPhoneVerified,
    bool? isTwoFactorEnabled,
    DateTime? emailVerifiedAt,
    DateTime? phoneVerifiedAt,
    DateTime? lastLoginAt,
    DateTime? passwordChangedAt,
    List<String>? permissions,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    UserPreferences? preferences,
    List<UserSession>? activeSessions,
    SecuritySettings? securitySettings,
    UserProfile? profile,
  }) {
    return AuthUserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      middleName: middleName ?? this.middleName,
      fullName: fullName ?? this.fullName,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      role: role ?? this.role,
      status: status ?? this.status,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      isTwoFactorEnabled: isTwoFactorEnabled ?? this.isTwoFactorEnabled,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
      phoneVerifiedAt: phoneVerifiedAt ?? this.phoneVerifiedAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      passwordChangedAt: passwordChangedAt ?? this.passwordChangedAt,
      permissions: permissions ?? this.permissions,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      preferences: preferences ?? this.preferences,
      activeSessions: activeSessions ?? this.activeSessions,
      securitySettings: securitySettings ?? this.securitySettings,
      profile: profile ?? this.profile,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        phoneNumber,
        firstName,
        lastName,
        middleName,
        fullName,
        profileImageUrl,
        role,
        status,
        isEmailVerified,
        isPhoneVerified,
        isTwoFactorEnabled,
        emailVerifiedAt,
        phoneVerifiedAt,
        lastLoginAt,
        passwordChangedAt,
        permissions,
        metadata,
        createdAt,
        updatedAt,
        preferences,
        activeSessions,
        securitySettings,
        profile,
      ];

  @override
  String toString() {
    return 'AuthUserEntity(id: $id, email: $email, role: $role)';
  }
}

/// User Role
@JsonSerializable()
class UserRole extends Equatable {
  final String id;
  final String name;
  final String description;
  final List<String> permissions;
  final int level;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserRole({
    required this.id,
    required this.name,
    required this.description,
    required this.permissions,
    required this.level,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Check if role has specific permission
  bool hasPermission(String permission) {
    return permissions.contains(permission);
  }

  /// Check if role is admin level
  bool get isAdmin => level >= 100;

  /// Check if role is manager level
  bool get isManager => level >= 50;

  /// Check if role is user level
  bool get isUser => level < 50;

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        permissions,
        level,
        isActive,
        createdAt,
        updatedAt,
      ];
}

/// User Status
enum UserStatus {
  active,
  inactive,
  suspended,
  pendingEmailVerification,
  pendingPhoneVerification,
  locked,
  deleted,
}

/// User Preferences
@JsonSerializable()
class UserPreferences extends Equatable {
  final String language;
  final String theme;
  final String timezone;
  final String currency;
  final String dateFormat;
  final String timeFormat;
  final bool emailNotifications;
  final bool smsNotifications;
  final bool pushNotifications;
  final bool twoFactorReminder;
  final bool sessionTimeoutWarning;
  final int sessionTimeoutMinutes;
  final Map<String, dynamic> customSettings;

  const UserPreferences({
    this.language = 'en',
    this.theme = 'light',
    this.timezone = 'Asia/Kathmandu',
    this.currency = 'NPR',
    this.dateFormat = 'yyyy-MM-dd',
    this.timeFormat = 'HH:mm',
    this.emailNotifications = true,
    this.smsNotifications = true,
    this.pushNotifications = true,
    this.twoFactorReminder = true,
    this.sessionTimeoutWarning = true,
    this.sessionTimeoutMinutes = 30,
    this.customSettings = const {},
  });

  @override
  List<Object?> get props => [
        language,
        theme,
        timezone,
        currency,
        dateFormat,
        timeFormat,
        emailNotifications,
        smsNotifications,
        pushNotifications,
        twoFactorReminder,
        sessionTimeoutWarning,
        sessionTimeoutMinutes,
        customSettings,
      ];
}

/// User Session
@JsonSerializable()
class UserSession extends Equatable {
  final String id;
  final String userId;
  final String deviceType;
  final String deviceName;
  final String deviceOs;
  final String ipAddress;
  final String location;
  final DateTime createdAt;
  final DateTime? lastAccessAt;
  final DateTime? expiresAt;
  final bool isActive;
  final bool isPrimary;
  final String? userAgent;
  final Map<String, dynamic> metadata;

  const UserSession({
    required this.id,
    required this.userId,
    required this.deviceType,
    required this.deviceName,
    required this.deviceOs,
    required this.ipAddress,
    required this.location,
    required this.createdAt,
    this.lastAccessAt,
    this.expiresAt,
    required this.isActive,
    required this.isPrimary,
    this.userAgent,
    this.metadata = const {},
  });

  /// Check if session is expired
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Check if session is expiring soon (within 5 minutes)
  bool get isExpiringSoon {
    if (expiresAt == null) return false;
    final fiveMinutesFromNow = DateTime.now().add(const Duration(minutes: 5));
    return expiresAt!.isBefore(fiveMinutesFromNow);
  }

  /// Get session duration
  Duration get sessionDuration {
    final end = lastAccessAt ?? DateTime.now();
    return end.difference(createdAt);
  }

  /// Get formatted session duration
  String get formattedDuration {
    final duration = sessionDuration;
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours % 24}h';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else {
      return '${duration.inMinutes}m';
    }
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        deviceType,
        deviceName,
        deviceOs,
        ipAddress,
        location,
        createdAt,
        lastAccessAt,
        expiresAt,
        isActive,
        isPrimary,
        userAgent,
        metadata,
      ];
}

/// Security Settings
@JsonSerializable()
class SecuritySettings extends Equatable {
  final bool twoFactorEnabled;
  final TwoFactorMethod twoFactorMethod;
  final bool sessionTimeoutEnabled;
  final int sessionTimeoutMinutes;
  final bool ipWhitelistEnabled;
  final List<String> whitelistedIps;
  final bool deviceTrackingEnabled;
  final int maxConcurrentSessions;
  final bool passwordComplexityEnabled;
  final int passwordMinLength;
  final int passwordHistoryCount;
  final bool loginAttemptLimitEnabled;
  final int maxLoginAttempts;
  final int lockoutDurationMinutes;
  final bool suspiciousActivityDetection;
  final DateTime? lastSecurityAudit;

  const SecuritySettings({
    required this.twoFactorEnabled,
    required this.twoFactorMethod,
    required this.sessionTimeoutEnabled,
    required this.sessionTimeoutMinutes,
    required this.ipWhitelistEnabled,
    required this.whitelistedIps,
    required this.deviceTrackingEnabled,
    required this.maxConcurrentSessions,
    required this.passwordComplexityEnabled,
    required this.passwordMinLength,
    required this.passwordHistoryCount,
    required this.loginAttemptLimitEnabled,
    required this.maxLoginAttempts,
    required this.lockoutDurationMinutes,
    required this.suspiciousActivityDetection,
    this.lastSecurityAudit,
  });

  /// Check if IP is whitelisted
  bool isIpWhitelisted(String ip) {
    return !ipWhitelistEnabled || whitelistedIps.contains(ip);
  }

  /// Check if user has reached max sessions
  bool hasReachedMaxSessions(int currentSessions) {
    return deviceTrackingEnabled && currentSessions >= maxConcurrentSessions;
  }

  /// Check if account should be locked
  bool shouldLockAccount(int failedAttempts) {
    return loginAttemptLimitEnabled && failedAttempts >= maxLoginAttempts;
  }

  /// Get lockout duration
  Duration get lockoutDuration => Duration(minutes: lockoutDurationMinutes);

  @override
  List<Object?> get props => [
        twoFactorEnabled,
        twoFactorMethod,
        sessionTimeoutEnabled,
        sessionTimeoutMinutes,
        ipWhitelistEnabled,
        whitelistedIps,
        deviceTrackingEnabled,
        maxConcurrentSessions,
        passwordComplexityEnabled,
        passwordMinLength,
        passwordHistoryCount,
        loginAttemptLimitEnabled,
        maxLoginAttempts,
        lockoutDurationMinutes,
        suspiciousActivityDetection,
        lastSecurityAudit,
      ];
}

/// User Profile
@JsonSerializable()
class UserProfile extends Equatable {
  final String? bio;
  final String? dateOfBirth;
  final String? gender;
  final String? address;
  final String? city;
  final String? state;
  final String? country;
  final String? postalCode;
  final String? company;
  final String? jobTitle;
  final String? department;
  final String? workPhone;
  final String? workEmail;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final String? emergencyContactRelation;
  final Map<String, dynamic> socialLinks;
  final List<String> interests;
  final List<String> skills;
  final Map<String, dynamic> customFields;

  const UserProfile({
    this.bio,
    this.dateOfBirth,
    this.gender,
    this.address,
    this.city,
    this.state,
    this.country,
    this.postalCode,
    this.company,
    this.jobTitle,
    this.department,
    this.workPhone,
    this.workEmail,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.emergencyContactRelation,
    this.socialLinks = const {},
    this.interests = const [],
    this.skills = const [],
    this.customFields = const {},
  });

  /// Get full address
  String get fullAddress {
    final parts = <String>[];
    if (address != null && address!.isNotEmpty) parts.add(address!);
    if (city != null && city!.isNotEmpty) parts.add(city!);
    if (state != null && state!.isNotEmpty) parts.add(state!);
    if (postalCode != null && postalCode!.isNotEmpty) parts.add(postalCode!);
    if (country != null && country!.isNotEmpty) parts.add(country!);
    return parts.join(', ');
  }

  /// Get age from date of birth
  int? get age {
    if (dateOfBirth == null || dateOfBirth!.isEmpty) return null;
    try {
      final birthDate = DateTime.parse(dateOfBirth!);
      final now = DateTime.now();
      int age = now.year - birthDate.year;
      if (now.month < birthDate.month || 
          (now.month == birthDate.month && now.day < birthDate.day)) {
        age--;
      }
      return age;
    } catch (e) {
      return null;
    }
  }

  @override
  List<Object?> get props => [
        bio,
        dateOfBirth,
        gender,
        address,
        city,
        state,
        country,
        postalCode,
        company,
        jobTitle,
        department,
        workPhone,
        workEmail,
        emergencyContactName,
        emergencyContactPhone,
        emergencyContactRelation,
        socialLinks,
        interests,
        skills,
        customFields,
      ];
}

/// Two Factor Method
enum TwoFactorMethod {
  none,
  sms,
  email,
  authenticatorApp,
  pushNotification,
  hardwareToken,
}

/// Security Risk Level
enum SecurityRiskLevel {
  none,
  low,
  medium,
  high,
}
