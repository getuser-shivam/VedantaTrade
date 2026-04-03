import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/premium_glassmorphic_theme.dart';
import '../data/services/auth_service.dart';
import '../data/models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService authService;

  AuthProvider({required this.authService});

  // State variables
  User? _user;
  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _errorMessage;
  String? _token;
  DateTime? _lastLoginTime;
  int _failedLoginAttempts = 0;
  bool _isBiometricAvailable = false;

  // Getters
  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get errorMessage => _errorMessage;
  String? get token => _token;
  DateTime? get lastLoginTime => _lastLoginTime;
  int get failedLoginAttempts => _failedLoginAttempts;
  bool get isBiometricAvailable => _isBiometricAvailable;

  // Initialize authentication state
  Future<void> initializeAuth() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Check for stored token and validate
      final storedToken = await authService.getStoredToken();
      if (storedToken != null) {
        final user = await authService.validateToken(storedToken!);
        if (user != null) {
          _user = user;
          _token = storedToken;
          _isAuthenticated = true;
          _lastLoginTime = DateTime.now();
        }
      }

      // Check biometric availability
      _isBiometricAvailable = await authService.isBiometricAvailable();
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Error initializing auth: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Login with email and password
  Future<void> login(String email, String password, bool rememberMe) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final loginResponse = await authService.login(email, password, rememberMe);
      
      _user = loginResponse.user;
      _token = loginResponse.token;
      _isAuthenticated = true;
      _lastLoginTime = DateTime.now();
      _failedLoginAttempts = 0;

      // Store token if remember me is checked
      if (rememberMe) {
        await authService.storeToken(loginResponse.token);
      }

      debugPrint('Login successful for user: ${loginResponse.user.email}');
    } catch (e) {
      _errorMessage = _getErrorMessage(e);
      _failedLoginAttempts++;
      debugPrint('Login failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Quick login for specific roles
  Future<void> quickLogin(String role) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final loginResponse = await authService.quickLogin(role);
      
      _user = loginResponse.user;
      _token = loginResponse.token;
      _isAuthenticated = true;
      _lastLoginTime = DateTime.now();
      _failedLoginAttempts = 0;

      debugPrint('Quick login successful for role: $role');
    } catch (e) {
      _errorMessage = _getErrorMessage(e);
      _failedLoginAttempts++;
      debugPrint('Quick login failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Biometric login
  Future<void> biometricLogin() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final loginResponse = await authService.biometricLogin();
      
      _user = loginResponse.user;
      _token = loginResponse.token;
      _isAuthenticated = true;
      _lastLoginTime = DateTime.now();
      _failedLoginAttempts = 0;

      debugPrint('Biometric login successful for user: ${loginResponse.user.email}');
    } catch (e) {
      _errorMessage = _getErrorMessage(e);
      debugPrint('Biometric login failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Register new user
  Future<void> register(Map<String, dynamic> userData) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final registerResponse = await authService.register(userData);
      
      _user = registerResponse.user;
      _token = registerResponse.token;
      _isAuthenticated = true;
      _lastLoginTime = DateTime.now();

      debugPrint('Registration successful for user: ${registerResponse.user.email}');
    } catch (e) {
      _errorMessage = _getErrorMessage(e);
      debugPrint('Registration failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await authService.resetPassword(email);
      debugPrint('Password reset initiated for email: $email');
    } catch (e) {
      _errorMessage = _getErrorMessage(e);
      debugPrint('Password reset failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Confirm password reset with verification code
  Future<void> confirmPasswordReset(String email, String verificationCode, String newPassword) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await authService.confirmPasswordReset(email, verificationCode, newPassword);
      debugPrint('Password reset confirmed for email: $email');
    } catch (e) {
      _errorMessage = _getErrorMessage(e);
      debugPrint('Password reset confirmation failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Logout user
  Future<void> logout() async {
    _setLoading(true);

    try {
      await authService.logout();
      
      _user = null;
      _token = null;
      _isAuthenticated = false;
      _lastLoginTime = null;
      _failedLoginAttempts = 0;

      debugPrint('Logout successful');
    } catch (e) {
      _errorMessage = _getErrorMessage(e);
      debugPrint('Logout failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Update user profile
  Future<void> updateProfile(Map<String, dynamic> profileData) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final updatedUser = await authService.updateProfile(profileData);
      _user = updatedUser;
      
      debugPrint('Profile updated for user: ${updatedUser.email}');
    } catch (e) {
      _errorMessage = _getErrorMessage(e);
      debugPrint('Profile update failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Change password
  Future<void> changePassword(String currentPassword, String newPassword) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await authService.changePassword(currentPassword, newPassword);
      debugPrint('Password changed for user: ${_user?.email}');
    } catch (e) {
      _errorMessage = _getErrorMessage(e);
      debugPrint('Password change failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Enable/disable biometric authentication
  Future<void> toggleBiometric(bool enabled) async {
    try {
      await authService.toggleBiometric(enabled);
      _isBiometricAvailable = enabled;
      debugPrint('Biometric authentication ${enabled ? 'enabled' : 'disabled'}');
    } catch (e) {
      _errorMessage = _getErrorMessage(e);
      debugPrint('Biometric toggle failed: $e');
    }
  }

  // Refresh user token
  Future<void> refreshToken() async {
    if (_token == null || _user == null) return;

    _setLoading(true);
    _errorMessage = null;

    try {
      final refreshResponse = await authService.refreshToken(_token!);
      
      _token = refreshResponse.token;
      _user = refreshResponse.user;
      _lastLoginTime = DateTime.now();

      debugPrint('Token refreshed for user: ${refreshResponse.user.email}');
    } catch (e) {
      _errorMessage = _getErrorMessage(e);
      debugPrint('Token refresh failed: $e');
      
      // If refresh fails, logout user
      await logout();
    } finally {
      _setLoading(false);
    }
  }

  // Check if user has specific permission
  bool hasPermission(String permission) {
    if (_user == null) return false;
    
    switch (permission.toLowerCase()) {
      case 'admin':
        return _user!.role == 'Admin';
      case 'manage_inventory':
        return ['Admin', 'Stockist'].contains(_user!.role);
      case 'manage_orders':
        return ['Admin', 'Stockist', 'Retailer'].contains(_user!.role);
      case 'manage_finances':
        return ['Admin', 'Accountant'].contains(_user!.role);
      case 'view_reports':
        return ['Admin', 'Accountant', 'Stockist'].contains(_user!.role);
      case 'manage_users':
        return _user!.role == 'Admin';
      case 'field_operations':
        return ['Admin', 'MR', 'Doctor'].contains(_user!.role);
      default:
        return false;
    }
  }

  // Get user role-specific color
  Color getRoleColor() {
    if (_user == null) return PremiumGlassmorphicTheme.textSecondary;
    return PremiumGlassmorphicTheme.getRoleColor(_user!.role);
  }

  // Get user role-specific icon
  IconData getRoleIcon() {
    if (_user == null) return Icons.person;
    
    switch (_user!.role) {
      case 'Admin':
        return Icons.admin_panel_settings;
      case 'MR':
        return Icons.directions_walk;
      case 'Stockist':
        return Icons.inventory;
      case 'Retailer':
        return Icons.store;
      case 'Doctor':
        return Icons.local_hospital;
      case 'Accountant':
        return Icons.account_balance;
      default:
        return Icons.person;
    }
  }

  // Check if account is locked due to failed attempts
  bool get isAccountLocked {
    return _failedLoginAttempts >= 5;
  }

  // Get remaining lockout time
  Duration getLockoutTime() {
    if (_failedLoginAttempts < 5) return Duration.zero;
    
    final lockoutDuration = Duration(minutes: 30 * (_failedLoginAttempts - 4));
    final timeSinceLastAttempt = DateTime.now().difference(_lastLoginTime ?? DateTime.now());
    
    if (timeSinceLastAttempt < lockoutDuration) {
      return lockoutDuration - timeSinceLastAttempt;
    }
    
    return Duration.zero;
  }

  // Get user display name
  String getDisplayName() {
    if (_user == null) return 'Guest';
    
    final name = _user!.name.trim();
    if (name.isNotEmpty) return name;
    
    final email = _user!.email;
    final emailName = email.split('@')[0];
    return emailName.isNotEmpty ? emailName : 'User';
  }

  // Get user initials for avatar
  String getUserInitials() {
    if (_user == null) return 'G';
    
    final name = _user!.name.trim();
    if (name.isNotEmpty) {
      final parts = name.split(' ');
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      return name.substring(0, 2).toUpperCase();
    }
    
    final email = _user!.email;
    final emailName = email.split('@')[0];
    return emailName.length >= 2 
        ? emailName.substring(0, 2).toUpperCase()
        : emailName.toUpperCase();
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Get user-friendly error message
  String _getErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('invalid') && errorString.contains('credential')) {
      return 'Invalid email or password. Please check your credentials.';
    }
    
    if (errorString.contains('user') && errorString.contains('not found')) {
      return 'User not found. Please check your email address.';
    }
    
    if (errorString.contains('password') && errorString.contains('incorrect')) {
      return 'Incorrect password. Please try again.';
    }
    
    if (errorString.contains('email') && errorString.contains('exists')) {
      return 'Email address already exists. Please use a different email.';
    }
    
    if (errorString.contains('network') || errorString.contains('connection')) {
      return 'Network error. Please check your internet connection.';
    }
    
    if (errorString.contains('timeout')) {
      return 'Request timed out. Please try again.';
    }
    
    if (errorString.contains('permission') || errorString.contains('unauthorized')) {
      return 'Access denied. You don\'t have permission to perform this action.';
    }
    
    if (errorString.contains('biometric')) {
      return 'Biometric authentication failed. Please try again or use password.';
    }
    
    if (errorString.contains('verification') || errorString.contains('code')) {
      return 'Invalid verification code. Please check your email and try again.';
    }
    
    return 'An unexpected error occurred. Please try again.';
  }

  // Validate session
  Future<bool> validateSession() async {
    if (_token == null) return false;
    
    try {
      final isValid = await authService.validateToken(_token!);
      if (!isValid) {
        await logout();
      }
      return isValid;
    } catch (e) {
      debugPrint('Session validation failed: $e');
      await logout();
      return false;
    }
  }
}
