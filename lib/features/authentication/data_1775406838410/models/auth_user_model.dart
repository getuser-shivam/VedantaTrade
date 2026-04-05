import 'package:flutter/material.dart';

/// Authentication User Model
class AuthUser {
  final String id;
  final String username;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;
  final String? profileImageUrl;
  final UserRole role;
  final bool isActive;
  final bool isEmailVerified;
  final bool isPhoneVerified;
  final bool isTwoFactorEnabled;
  final DateTime? lastLoginAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? preferences;
  final Map<String, dynamic>? permissions;
  final List<String>? devices;
  final String? department;
  final String? region;
  final String? territory;
  final Map<String, dynamic>? metadata;

  AuthUser({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    required this.isActive,
    required this.isEmailVerified,
    required this.isPhoneVerified,
    required this.createdAt,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.profileImageUrl,
    this.isTwoFactorEnabled,
    this.lastLoginAt,
    this.updatedAt,
    this.preferences,
    this.permissions,
    this.devices,
    this.department,
    this.region,
    this.territory,
    this.metadata,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      profileImageUrl: json['profileImageUrl'] as String?,
      role: UserRole.values.firstWhere(
        (role) => role.toString() == json['role'],
        orElse: () => UserRole.user,
      ),
      isActive: json['isActive'] as bool,
      isEmailVerified: json['isEmailVerified'] as bool,
      isPhoneVerified: json['isPhoneVerified'] as bool,
      isTwoFactorEnabled: json['isTwoFactorEnabled'] as bool? ?? false,
      lastLoginAt: json['lastLoginAt'] != null 
          ? DateTime.parse(json['lastLoginAt'] as String) 
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String) 
          : null,
      preferences: json['preferences'] as Map<String, dynamic>?,
      permissions: json['permissions'] as Map<String, dynamic>?,
      devices: (json['devices'] as List<dynamic>?)?.cast<String>(),
      department: json['department'] as String?,
      region: json['region'] as String?,
      territory: json['territory'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'role': role.toString(),
      'isActive': isActive,
      'isEmailVerified': isEmailVerified,
      'isPhoneVerified': isPhoneVerified,
      'isTwoFactorEnabled': isTwoFactorEnabled,
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'preferences': preferences,
      'permissions': permissions,
      'devices': devices,
      'department': department,
      'region': region,
      'territory': territory,
      'metadata': metadata,
    };
  }

  AuthUser copyWith({
    String? id,
    String? username,
    String? email,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? profileImageUrl,
    UserRole? role,
    bool? isActive,
    bool? isEmailVerified,
    bool? isPhoneVerified,
    bool? isTwoFactorEnabled,
    DateTime? lastLoginAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? preferences,
    Map<String, dynamic>? permissions,
    List<String>? devices,
    String? department,
    String? region,
    String? territory,
    Map<String, dynamic>? metadata,
  }) {
    return AuthUser(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      isTwoFactorEnabled: isTwoFactorEnabled ?? this.isTwoFactorEnabled,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      preferences: preferences ?? this.preferences,
      permissions: permissions ?? this.permissions,
      devices: devices ?? this.devices,
      department: department ?? this.department,
      region: region ?? this.region,
      territory: territory ?? this.territory,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Get full name
  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    } else if (firstName != null) {
      return firstName!;
    } else if (lastName != null) {
      return lastName!;
    } else {
      return username;
    }
  }

  /// Get display name
  String get displayName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    } else if (firstName != null) {
      return firstName!;
    } else {
      return username;
    }
  }

  /// Check if user has specific permission
  bool hasPermission(String permission) {
    return permissions?.containsKey(permission) ?? false;
  }

  /// Check if user has any of the specified permissions
  bool hasAnyPermission(List<String> permissions) {
    return permissions?.keys.any((perm) => permissions.contains(perm)) ?? false;
  }

  /// Check if user is in specific role
  bool isInRole(UserRole role) {
    return this.role == role;
  }

  /// Check if user is in any of the specified roles
  bool isInAnyRole(List<UserRole> roles) {
    return roles.contains(this.role);
  }

  /// Get user's initial
  String get initials {
    final parts = fullName.split(' ');
    String initials = '';
    
    for (final part in parts) {
      if (part.isNotEmpty) {
        initials += part[0].toUpperCase();
      }
    }
    
    return initials;
  }

  /// Check if user is admin or super admin
  bool get isAdmin => isInRole(UserRole.admin) || isInRole(UserRole.superAdmin);

  /// Check if user is MR (Medical Representative)
  bool get isMR => isInRole(UserRole.mr);

  /// Check if user is Doctor
  bool get isDoctor => isInRole(UserRole.doctor);

  /// Check if user is Stockist
  bool get isStockist => isInRole(UserRole.stockist);

  /// Check if user is Retailer
  bool get isRetailer => isInRole(UserRole.retailer);

  /// Check if user is Accountant
  bool get isAccountant => isInRole(UserRole.accountant);

  /// Check if user is active and verified
  bool get isFullyVerified => isActive && isEmailVerified && isPhoneVerified;

  /// Get user's region/territory info
  String get locationInfo {
    final parts = <String>[];
    if (region != null) parts.add('Region: $region');
    if (territory != null) parts.add('Territory: $territory');
    if (department != null) parts.add('Department: $department');
    
    return parts.join(' | ');
  }
}

/// User Role Enum
enum UserRole {
  superAdmin,
  admin,
  mr,
  doctor,
  stockist,
  retailer,
  accountant,
}

/// Authentication Request Models
class LoginRequest {
  final String username;
  final String password;
  final bool rememberMe;
  final String? twoFactorCode;

  const LoginRequest({
    required this.username,
    required this.password,
    this.rememberMe = false,
    this.twoFactorCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'rememberMe': rememberMe,
      'twoFactorCode': twoFactorCode,
    };
  }
}

class RegisterRequest {
  final String username;
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String? phoneNumber;
  final UserRole role;
  final String? department;
  final String? region;
  final String? territory;

  const RegisterRequest({
    required this.username,
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.phoneNumber,
    this.department,
    this.region,
    this.territory,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'password': password,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'role': role.toString(),
      'department': department,
      'region': region,
      'territory': territory,
    };
  }
}

class ForgotPasswordRequest {
  final String email;

  const ForgotPasswordRequest({
    required this.email,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
    };
  }
}

class ResetPasswordRequest {
  final String token;
  final String password;
  final String confirmPassword;

  const ResetPasswordRequest({
    required this.token,
    required this.password,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'password': password,
      'confirmPassword': confirmPassword,
    };
  }
}

class ChangePasswordRequest {
  final String currentPassword;
  final String newPassword;
  final String confirmPassword;

  const ChangePasswordRequest({
    required this.currentPassword,
    required this.newPassword,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
      'confirmPassword': confirmPassword,
    };
  }
}

class UpdateProfileRequest {
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;
  final String? department;
  final String? region;
  final String? territory;
  final String? profileImageUrl;

  const UpdateProfileRequest({
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.department,
    this.region,
    this.territory,
    this.profileImageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'department': department,
      'region': region,
      'territory': territory,
      'profileImageUrl': profileImageUrl,
    };
  }
}

class TwoFactorSetupRequest {
  final String method;
  final String? phoneNumber;
  final String? email;
  final String? authenticatorAppSecret;

  const TwoFactorSetupRequest({
    required this.method,
    this.phoneNumber,
    this.email,
    this.authenticatorAppSecret,
  });

  Map<String, dynamic> toJson() {
    return {
      'method': method,
      'phoneNumber': phoneNumber,
      'email': email,
      'authenticatorAppSecret': authenticatorAppSecret,
    };
  }
}
