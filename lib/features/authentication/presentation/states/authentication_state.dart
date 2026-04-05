import 'package:equatable/equatable.dart';
import '../../domain/entities/auth_user_entity.dart';

/// Authentication State
/// Represents the current state of authentication
class AuthenticationState extends Equatable {
  final AuthUserEntity? user;
  final bool isLoading;
  final String? errorMessage;
  final bool isAuthenticated;
  final bool isRegistered;
  final bool isTwoFactorRequired;
  final AuthResult? twoFactorAuthResult;
  final bool isPasswordResetSent;
  final bool isPasswordResetSuccess;
  final bool isPasswordChanged;
  final bool isEmailVerificationSent;
  final PasswordStrength? passwordStrength;
  final AccountLockStatus? accountLockStatus;
  final DateTime? lastUpdated;

  const AuthenticationState._({
    this.user,
    required this.isLoading,
    this.errorMessage,
    required this.isAuthenticated,
    required this.isRegistered,
    required this.isTwoFactorRequired,
    this.twoFactorAuthResult,
    required this.isPasswordResetSent,
    required this.isPasswordResetSuccess,
    required this.isPasswordChanged,
    required this.isEmailVerificationSent,
    this.passwordStrength,
    this.accountLockStatus,
    this.lastUpdated,
  });

  /// Initial state
  const AuthenticationState.initial()
      : isLoading = false,
        isAuthenticated = false,
        isRegistered = false,
        isTwoFactorRequired = false,
        isPasswordResetSent = false,
        isPasswordResetSuccess = false,
        isPasswordChanged = false,
        isEmailVerificationSent = false,
        lastUpdated = null;

  /// Loading state
  const AuthenticationState.loading()
      : isLoading = true,
        isAuthenticated = false,
        isRegistered = false,
        isTwoFactorRequired = false,
        isPasswordResetSent = false,
        isPasswordResetSuccess = false,
        isPasswordChanged = false,
        isEmailVerificationSent = false,
        lastUpdated = DateTime.now();

  /// Authenticated state
  const AuthenticationState.authenticated({required AuthUserEntity user})
      : user = user,
        isLoading = false,
        isAuthenticated = true,
        isRegistered = false,
        isTwoFactorRequired = false,
        isPasswordResetSent = false,
        isPasswordResetSuccess = false,
        isPasswordChanged = false,
        isEmailVerificationSent = false,
        lastUpdated = DateTime.now();

  /// Unauthenticated state
  const AuthenticationState.unauthenticated()
      : isLoading = false,
        isAuthenticated = false,
        isRegistered = false,
        isTwoFactorRequired = false,
        isPasswordResetSent = false,
        isPasswordResetSuccess = false,
        isPasswordChanged = false,
        isEmailVerificationSent = false,
        lastUpdated = DateTime.now();

  /// Registered state
  const AuthenticationState.registered({required AuthUserEntity user})
      : user = user,
        isLoading = false,
        isAuthenticated = false,
        isRegistered = true,
        isTwoFactorRequired = false,
        isPasswordResetSent = false,
        isPasswordResetSuccess = false,
        isPasswordChanged = false,
        isEmailVerificationSent = false,
        lastUpdated = DateTime.now();

  /// Error state
  const AuthenticationState.error({required String message})
      : errorMessage = message,
        isLoading = false,
        isAuthenticated = false,
        isRegistered = false,
        isTwoFactorRequired = false,
        isPasswordResetSent = false,
        isPasswordResetSuccess = false,
        isPasswordChanged = false,
        isEmailVerificationSent = false,
        lastUpdated = DateTime.now();

  /// Two-factor required state
  const AuthenticationState.twoFactorRequired({
    required AuthUserEntity user,
    required AuthResult authResult,
  }) : user = user,
        isLoading = false,
        isAuthenticated = false,
        isRegistered = false,
        isTwoFactorRequired = true,
        twoFactorAuthResult = authResult,
        isPasswordResetSent = false,
        isPasswordResetSuccess = false,
        isPasswordChanged = false,
        isEmailVerificationSent = false,
        lastUpdated = DateTime.now();

  /// Password reset sent state
  const AuthenticationState.passwordResetSent()
      : isLoading = false,
        isAuthenticated = false,
        isRegistered = false,
        isTwoFactorRequired = false,
        isPasswordResetSent = true,
        isPasswordResetSuccess = false,
        isPasswordChanged = false,
        isEmailVerificationSent = false,
        lastUpdated = DateTime.now();

  /// Password reset success state
  const AuthenticationState.passwordResetSuccess()
      : isLoading = false,
        isAuthenticated = false,
        isRegistered = false,
        isTwoFactorRequired = false,
        isPasswordResetSent = false,
        isPasswordResetSuccess = true,
        isPasswordChanged = false,
        isEmailVerificationSent = false,
        lastUpdated = DateTime.now();

  /// Password changed state
  const AuthenticationState.passwordChanged()
      : isLoading = false,
        isAuthenticated = false,
        isRegistered = false,
        isTwoFactorRequired = false,
        isPasswordResetSent = false,
        isPasswordResetSuccess = false,
        isPasswordChanged = true,
        isEmailVerificationSent = false,
        lastUpdated = DateTime.now();

  /// Email verification sent state
  const AuthenticationState.emailVerificationSent()
      : isLoading = false,
        isAuthenticated = false,
        isRegistered = false,
        isTwoFactorRequired = false,
        isPasswordResetSent = false,
        isPasswordResetSuccess = false,
        isPasswordChanged = false,
        isEmailVerificationSent = true,
        lastUpdated = DateTime.now();

  /// Password strength checked state
  const AuthenticationState.passwordStrengthChecked({
    required PasswordStrength strength,
  }) : passwordStrength = strength,
        isLoading = false,
        isAuthenticated = false,
        isRegistered = false,
        isTwoFactorRequired = false,
        isPasswordResetSent = false,
        isPasswordResetSuccess = false,
        isPasswordChanged = false,
        isEmailVerificationSent = false,
        lastUpdated = DateTime.now();

  /// Account lock status checked state
  const AuthenticationState.accountLockStatusChecked({
    required AccountLockStatus lockStatus,
  }) : accountLockStatus = lockStatus,
        isLoading = false,
        isAuthenticated = false,
        isRegistered = false,
        isTwoFactorRequired = false,
        isPasswordResetSent = false,
        isPasswordResetSuccess = false,
        isPasswordChanged = false,
        isEmailVerificationSent = false,
        lastUpdated = DateTime.now();

  /// Check if state is loading
  bool get isLoading => isLoading;

  /// Check if user is authenticated
  bool get isAuthenticated => isAuthenticated;

  /// Check if user is registered but not verified
  bool get isRegistered => isRegistered;

  /// Check if there's an error
  bool get isError => errorMessage != null;

  /// Check if two-factor authentication is required
  bool get isTwoFactorRequired => isTwoFactorRequired;

  /// Check if password reset was sent
  bool get isPasswordResetSent => isPasswordResetSent;

  /// Check if password was reset successfully
  bool get isPasswordResetSuccess => isPasswordResetSuccess;

  /// Check if password was changed
  bool get isPasswordChanged => isPasswordChanged;

  /// Check if email verification was sent
  bool get isEmailVerificationSent => isEmailVerificationSent;

  /// Check if password strength is available
  bool get hasPasswordStrength => passwordStrength != null;

  /// Check if account lock status is available
  bool get hasAccountLockStatus => accountLockStatus != null;

  /// Get user security risk level
  SecurityRiskLevel? get userSecurityRisk => user?.securityRiskLevel;

  /// Check if user needs password change
  bool get needsPasswordChange => user?.needsPasswordChange ?? false;

  /// Check if user has security risks
  bool get hasSecurityRisks => user?.hasSecurityRisks ?? false;

  /// Get user display name
  String? get userDisplayName => user?.displayName;

  /// Get user initials
  String? get userInitials => user?.initials;

  /// Get user profile image URL
  String? get userProfileImage => user?.profileImageUrl;

  /// Get user role
  UserRole? get userRole => user?.role;

  /// Get user status
  UserStatus? get userStatus => user?.status;

  /// Check if user email is verified
  bool get isUserEmailVerified => user?.isEmailVerified ?? false;

  /// Check if user phone is verified
  bool get isUserPhoneVerified => user?.isPhoneVerified ?? false;

  /// Check if user has two-factor enabled
  bool get isUserTwoFactorEnabled => user?.isTwoFactorEnabled ?? false;

  /// Get user permissions
  List<String> get userPermissions => user?.permissions ?? [];

  /// Get user active sessions
  List<UserSession> get userActiveSessions => user?.activeSessions ?? [];

  /// Get user session count
  int get userSessionCount => user?.sessionCount ?? 0;

  /// Check if user has active sessions
  bool get userHasActiveSessions => user?.hasActiveSessions ?? false;

  /// Get user preferences
  UserPreferences? get userPreferences => user?.preferences;

  /// Get user security settings
  SecuritySettings? get userSecuritySettings => user?.securitySettings;

  /// Create copy with updated values
  AuthenticationState copyWith({
    AuthUserEntity? user,
    bool? isLoading,
    String? errorMessage,
    bool? isAuthenticated,
    bool? isRegistered,
    bool? isTwoFactorRequired,
    AuthResult? twoFactorAuthResult,
    bool? isPasswordResetSent,
    bool? isPasswordResetSuccess,
    bool? isPasswordChanged,
    bool? isEmailVerificationSent,
    PasswordStrength? passwordStrength,
    AccountLockStatus? accountLockStatus,
  }) {
    return AuthenticationState._(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isRegistered: isRegistered ?? this.isRegistered,
      isTwoFactorRequired: isTwoFactorRequired ?? this.isTwoFactorRequired,
      twoFactorAuthResult: twoFactorAuthResult ?? this.twoFactorAuthResult,
      isPasswordResetSent: isPasswordResetSent ?? this.isPasswordResetSent,
      isPasswordResetSuccess: isPasswordResetSuccess ?? this.isPasswordResetSuccess,
      isPasswordChanged: isPasswordChanged ?? this.isPasswordChanged,
      isEmailVerificationSent: isEmailVerificationSent ?? this.isEmailVerificationSent,
      passwordStrength: passwordStrength ?? this.passwordStrength,
      accountLockStatus: accountLockStatus ?? this.accountLockStatus,
      lastUpdated: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        user,
        isLoading,
        errorMessage,
        isAuthenticated,
        isRegistered,
        isTwoFactorRequired,
        twoFactorAuthResult,
        isPasswordResetSent,
        isPasswordResetSuccess,
        isPasswordChanged,
        isEmailVerificationSent,
        passwordStrength,
        accountLockStatus,
        lastUpdated,
      ];

  @override
  String toString() {
    return 'AuthenticationState('
        'isLoading: $isLoading, '
        'isAuthenticated: $isAuthenticated, '
        'isError: $isError, '
        'errorMessage: $errorMessage, '
        'user: $user'
        ')';
  }
}
