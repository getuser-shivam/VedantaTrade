import '../models/user_entity.dart';

abstract class AuthenticationRepository {
  // Authentication methods
  Future<UserEntity?> signIn(String email, String password);
  Future<UserEntity?> signUp(String email, String password, String firstName, String lastName, String phoneNumber);
  Future<void> signOut();
  Future<UserEntity?> getCurrentUser();
  Future<bool> isSignedIn();
  
  // Password management
  Future<void> resetPassword(String email);
  Future<void> changePassword(String currentPassword, String newPassword);
  Future<void> confirmPasswordReset(String token, String newPassword);
  
  // Multi-factor authentication
  Future<String> generateMfaToken(String userId);
  Future<bool> verifyMfaToken(String userId, String token);
  Future<void> enableMfa(String userId, String token);
  Future<void> disableMfa(String userId, String password);
  
  // Account management
  Future<void> updateProfile(UserEntity user);
  Future<void> updatePassword(String userId, String newPassword);
  Future<void> lockAccount(String userId, String reason);
  Future<void> unlockAccount(String userId);
  Future<void> deactivateAccount(String userId);
  Future<void> reactivateAccount(String userId);
  
  // Session management
  Future<void> refreshToken();
  Future<void> revokeToken(String token);
  Future<List<String>> getActiveSessions(String userId);
  Future<void> revokeSession(String userId, String sessionId);
  Future<void> revokeAllSessions(String userId);
  
  // OAuth integration
  Future<UserEntity?> signInWithGoogle();
  Future<UserEntity?> signInWithFacebook();
  Future<UserEntity?> signInWithApple();
  Future<UserEntity?> linkGoogleAccount(String userId);
  Future<UserEntity?> linkFacebookAccount(String userId);
  Future<UserEntity?> linkAppleAccount(String userId);
  Future<void> unlinkSocialAccount(String userId, String provider);
  
  // Security and monitoring
  Future<void> logSecurityEvent(String userId, String eventType, Map<String, dynamic> metadata);
  Future<List<Map<String, dynamic>>> getSecurityEvents(String userId);
  Future<bool> isAccountLocked(String userId);
  Future<DateTime?> getLastLoginAttempt(String userId);
  Future<int> getFailedLoginAttempts(String userId);
  Future<void> clearFailedLoginAttempts(String userId);
  
  // Email and phone verification
  Future<void> sendEmailVerification(String email);
  Future<bool> verifyEmail(String token);
  Future<void> sendPhoneVerification(String phoneNumber);
  Future<bool> verifyPhone(String phoneNumber, String token);
  
  // JWT token management
  Future<String> generateJwtToken(UserEntity user);
  Future<bool> validateJwtToken(String token);
  Future<UserEntity?> getUserFromJwtToken(String token);
  Future<void> revokeJwtToken(String token);
  
  // Device management
  Future<void> registerDevice(String userId, Map<String, dynamic> deviceInfo);
  Future<List<Map<String, dynamic>>> getRegisteredDevices(String userId);
  Future<void> unregisterDevice(String userId, String deviceId);
  Future<void> revokeDeviceAccess(String userId, String deviceId);
  
  // Preferences and settings
  Future<void> updatePreferences(String userId, Map<String, dynamic> preferences);
  Future<Map<String, dynamic>> getPreferences(String userId);
  Future<void> updateSecuritySettings(String userId, Map<String, dynamic> settings);
  Future<Map<String, dynamic>> getSecuritySettings(String userId);
  
  // Rate limiting and throttling
  Future<bool> isRateLimited(String identifier);
  Future<DateTime?> getRateLimitResetTime(String identifier);
  Future<void> incrementRateLimit(String identifier);
  Future<void> resetRateLimit(String identifier);
  
  // Audit and logging
  Future<void> logAuthEvent(String eventType, Map<String, dynamic> eventData);
  Future<List<Map<String, dynamic>>> getAuthHistory(String userId, {DateTime? startDate, DateTime? endDate});
  Future<Map<String, dynamic>> getAuthAnalytics({DateTime? startDate, DateTime? endDate});
  
  // Compliance and regulations
  Future<bool> isCompliantWithGDPR();
  Future<bool> isCompliantWithCCPA();
  Future<bool> isCompliantWithHIPAA();
  Future<Map<String, dynamic>> getComplianceReport();
  Future<void> exportUserData(String userId, {String format = 'json'});
  Future<void> deleteUserData(String userId);
  
  // Social authentication providers
  Future<List<Map<String, dynamic>>> getConnectedSocialAccounts(String userId);
  Future<void> disconnectSocialAccount(String userId, String provider);
  Future<bool> isSocialAccountConnected(String userId, String provider);
  
  // Biometric authentication
  Future<bool> isBiometricAvailable();
  Future<bool> authenticateWithBiometrics();
  Future<void> enableBiometricAuth(String userId);
  Future<void> disableBiometricAuth(String userId);
  Future<bool> isBiometricAuthEnabled(String userId);
  
  // Session security
  Future<void> updateSessionSecurity(String userId, Map<String, dynamic> securitySettings);
  Future<Map<String, dynamic>> getSessionSecurity(String userId);
  Future<bool> isSessionSecure(String userId);
  
  // Password policies
  Future<Map<String, dynamic>> getPasswordPolicy();
  Future<bool> validatePassword(String password);
  Future<bool> isPasswordExpired(String userId);
  Future<DateTime?> getPasswordExpiryDate(String userId);
  
  // Account recovery options
  Future<List<String>> getAvailableRecoveryOptions(String email);
  Future<void> initiateAccountRecovery(String email, String method);
  Future<bool> verifyRecoveryCode(String email, String code);
  Future<void> completeAccountRecovery(String email, String code, String newPassword);
  
  // Two-factor authentication setup
  Future<List<String>> getAvailableMfaMethods();
  Future<void> setupMfaMethod(String userId, String method);
  Future<Map<String, dynamic>> getMfaSetupStatus(String userId);
  Future<void> verifyMfaSetup(String userId, String method, String verificationCode);
  
  // Security questions
  Future<List<Map<String, dynamic>>> getSecurityQuestions();
  Future<void> setSecurityQuestions(String userId, List<Map<String, dynamic>> questions);
  Future<bool> verifySecurityQuestions(String userId, List<Map<String, dynamic>> answers);
  
  // Account activity monitoring
  Future<List<Map<String, dynamic>>> getRecentActivity(String userId);
  Future<void> markActivityAsRecognized(String userId, String activityId);
  Future<void> reportSuspiciousActivity(String userId, Map<String, dynamic> activity);
  
  // Token refresh and rotation
  Future<String> refreshToken(String refreshToken);
  Future<void> rotateTokens(String userId);
  Future<bool> isTokenValid(String token);
  Future<DateTime?> getTokenExpiry(String token);
  
  // Cross-device authentication
  Future<String> generateCrossDeviceToken(String userId);
  Future<bool> verifyCrossDeviceToken(String userId, String token);
  Future<void> approveCrossDeviceLogin(String userId, String requestId);
  Future<void> denyCrossDeviceLogin(String userId, String requestId);
}
