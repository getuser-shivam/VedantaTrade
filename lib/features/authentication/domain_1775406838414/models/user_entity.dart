import 'package:equatable/equatable.dart';

enum UserRole {
  admin,
  medicalRepresentative,
  stockist,
  retailer,
  doctor,
  accountant,
}

enum AuthenticationStatus {
  unauthenticated,
  authenticated,
  pending,
  locked,
  disabled,
}

enum UserStatus {
  active,
  inactive,
  suspended,
  pendingVerification,
}

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final UserRole role;
  final UserStatus status;
  final AuthenticationStatus authStatus;
  final DateTime? lastLoginAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? accountLockedUntil;
  final int failedLoginAttempts;
  final bool isEmailVerified;
  final bool isPhoneVerified;
  final bool isTwoFactorEnabled;
  final String? profileImageUrl;
  final Map<String, dynamic> preferences;
  final Map<String, dynamic> securitySettings;
  final String? deviceId;
  final String? lastKnownIp;
  final DateTime? passwordChangedAt;
  final DateTime? lastPasswordResetAt;

  const UserEntity({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.role,
    required this.status,
    required this.authStatus,
    required this.createdAt,
    required this.updatedAt,
    this.lastLoginAt,
    this.accountLockedUntil,
    this.failedLoginAttempts = 0,
    this.isEmailVerified = false,
    this.isPhoneVerified = false,
    this.isTwoFactorEnabled = false,
    this.profileImageUrl,
    this.preferences = const {},
    this.securitySettings = const {},
    this.deviceId,
    this.lastKnownIp,
    this.passwordChangedAt,
    this.lastPasswordResetAt,
  });

  UserEntity copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    UserRole? role,
    UserStatus? status,
    AuthenticationStatus? authStatus,
    DateTime? lastLoginAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? accountLockedUntil,
    int? failedLoginAttempts,
    bool? isEmailVerified,
    bool? isPhoneVerified,
    bool? isTwoFactorEnabled,
    String? profileImageUrl,
    Map<String, dynamic>? preferences,
    Map<String, dynamic>? securitySettings,
    String? deviceId,
    String? lastKnownIp,
    DateTime? passwordChangedAt,
    DateTime? lastPasswordResetAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      status: status ?? this.status,
      authStatus: authStatus ?? this.authStatus,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      accountLockedUntil: accountLockedUntil ?? this.accountLockedUntil,
      failedLoginAttempts: failedLoginAttempts ?? this.failedLoginAttempts,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      isTwoFactorEnabled: isTwoFactorEnabled ?? this.isTwoFactorEnabled,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      preferences: preferences ?? this.preferences,
      securitySettings: securitySettings ?? this.securitySettings,
      deviceId: deviceId ?? this.deviceId,
      lastKnownIp: lastKnownIp ?? this.lastKnownIp,
      passwordChangedAt: passwordChangedAt ?? this.passwordChangedAt,
      lastPasswordResetAt: lastPasswordResetAt ?? this.lastPasswordResetAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        firstName,
        lastName,
        phoneNumber,
        role,
        status,
        authStatus,
        lastLoginAt,
        createdAt,
        updatedAt,
        accountLockedUntil,
        failedLoginAttempts,
        isEmailVerified,
        isPhoneVerified,
        isTwoFactorEnabled,
        profileImageUrl,
        preferences,
        securitySettings,
        deviceId,
        lastKnownIp,
        passwordChangedAt,
        lastPasswordResetAt,
      ];

  @override
  String toString() {
    return 'UserEntity(id: $id, email: $email, role: $role)';
  }

  // Computed properties
  String get fullName => '$firstName $lastName';
  String get displayName => fullName.isNotEmpty ? fullName : email;
  bool get isActive => status == UserStatus.active;
  bool get isLocked => status == UserStatus.locked || 
      (accountLockedUntil != null && accountLockedUntil!.isAfter(DateTime.now()));
  bool get isPendingVerification => status == UserStatus.pendingVerification;
  bool get canLogin => !isLocked && !isPendingVerification && authStatus == AuthenticationStatus.authenticated;
  bool get needsTwoFactor => isTwoFactorEnabled && authStatus == AuthenticationStatus.pending;
  bool get hasSecurityIssues => failedLoginAttempts >= 3 || isLocked;
  String get roleDisplayName => role.name.split('').map((word) => 
        word[0].toUpperCase() + word.substring(1)).join(' ');
  
  // Security methods
  bool isPasswordValid(String password) {
    // Would implement actual password validation logic
// return password.isNotEmpty && password.length >= 8; // TODO: Move to environment variables
  }
  
  bool isEmailValid(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }
  
  bool isPhoneNumberValid(String phone) {
    final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]{10,15}$');
    return phoneRegex.hasMatch(phone);
  }
  
  bool shouldLockAccount() {
    return failedLoginAttempts >= 5;
  }
  
  DateTime? getAccountLockDuration() {
    final baseDuration = const Duration(hours: 1);
    final additionalDuration = Duration(
      hours: (failedLoginAttempts - 3) * 2,
    );
    return baseDuration + additionalDuration;
  }
}
