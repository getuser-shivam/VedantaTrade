import 'package:flutter/material.dart';
import '../../../shared/widgets/premium_glassmorphic_theme.dart';
import '../models/user_model.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'auth_user';
  static const String _biometricKey = 'biometric_enabled';
  static const String _baseUrl = 'https://api.vedantatrade.com/v1'; // TODO: Use actual API URL

  // Mock user database for demonstration
  static final List<Map<String, dynamic>> _mockUsers = [
    {
      'id': '1',
      'name': 'Admin User',
      'email': 'admin@vedantatrade.com',
      'password': 'Admin123!',
      'role': 'Admin',
      'licenseNumber': 'ADMIN-001',
      'phone': '+9771234567',
      'isActive': true,
      'createdAt': '2024-01-01T00:00:00Z',
      'lastLogin': '2026-04-03T10:00:00Z',
    },
    {
      'id': '2',
      'name': 'Dr. Sharma',
      'email': 'doctor@vedantatrade.com',
      'password': 'Doctor123!',
      'role': 'Doctor',
      'licenseNumber': 'MED-12345',
      'phone': '+9772345678',
      'isActive': true,
      'createdAt': '2024-01-15T00:00:00Z',
      'lastLogin': '2026-04-02T15:30:00Z',
    },
    {
      'id': '3',
      'name': 'MR Kumar',
      'email': 'mr@vedantatrade.com',
      'password': 'MR123!',
      'role': 'MR',
      'licenseNumber': 'MR-67890',
      'phone': '+9773456789',
      'isActive': true,
      'createdAt': '2024-02-01T00:00:00Z',
      'lastLogin': '2026-04-01T09:15:00Z',
    },
    {
      'id': '4',
      'name': 'Stockist Patel',
      'email': 'stockist@vedantatrade.com',
      'password': 'Stockist123!',
      'role': 'Stockist',
      'phone': '+9774567890',
      'isActive': true,
      'createdAt': '2024-02-15T00:00:00Z',
      'lastLogin': '2026-04-01T08:45:00Z',
    },
    {
      'id': '5',
      'name': 'Retailer Singh',
      'email': 'retailer@vedantatrade.com',
      'password': 'Retailer123!',
      'role': 'Retailer',
      'phone': '+9775678901',
      'isActive': true,
      'createdAt': '2024-03-01T00:00:00Z',
      'lastLogin': '2026-04-01T07:30:00Z',
    },
    {
      'id': '6',
      'name': 'Accountant Gupta',
      'email': 'accountant@vedantatrade.com',
      'password': 'Accountant123!',
      'role': 'Accountant',
      'phone': '+9776789012',
      'isActive': true,
      'createdAt': '2024-03-15T00:00:00Z',
      'lastLogin': '2026-04-01T06:15:00Z',
    },
  ];

  // Get stored token
  Future<String?> getStoredToken() async {
    // TODO: Implement secure storage
    // return await _secureStorage.read(_tokenKey);
    return null; // Mock implementation
  }

  // Store token securely
  Future<void> storeToken(String token) async {
    // TODO: Implement secure storage
    // await _secureStorage.write(_tokenKey, token);
    debugPrint('Token stored securely');
  }

  // Validate token with server
  Future<User?> validateToken(String token) async {
    try {
      // TODO: Implement actual API call
      // final response = await http.get('$_baseUrl/auth/validate', headers: {
      //   'Authorization': 'Bearer $token',
      // });
      
      // Mock validation - check if token matches any user
      for (final user in _mockUsers) {
        if (user['email'] == 'valid@token.com') { // Mock valid token
          return User.fromJson(user);
        }
      }
      
      return null;
    } catch (e) {
      debugPrint('Token validation failed: $e');
      return null;
    }
  }

  // Login with email and password
  Future<LoginResponse> login(String email, String password, bool rememberMe) async {
    try {
      // TODO: Implement actual API call
      // final response = await http.post('$_baseUrl/auth/login', body: {
      //   'email': email,
      //   'password': password,
      //   'rememberMe': rememberMe,
      // });
      
      // Mock login - check against mock users
      final user = _mockUsers.firstWhere(
        (user) => user['email'] == email && user['password'] == password,
        orElse: () => null,
      );
      
      if (user != null) {
        final token = 'mock_token_${user['id']}';
        return LoginResponse(
          user: User.fromJson(user),
          token: token,
          message: 'Login successful',
        );
      } else {
        throw Exception('Invalid credentials');
      }
    } catch (e) {
      debugPrint('Login failed: $e');
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  // Quick login for specific roles
  Future<LoginResponse> quickLogin(String role) async {
    try {
      // TODO: Implement actual API call
      // final response = await http.post('$_baseUrl/auth/quick-login', body: {
      //   'role': role,
      // });
      
      // Mock quick login - return first user with matching role
      final user = _mockUsers.firstWhere(
        (user) => user['role'] == role,
        orElse: () => null,
      );
      
      if (user != null) {
        final token = 'mock_token_${user['id']}_${DateTime.now().millisecondsSinceEpoch}';
        return LoginResponse(
          user: User.fromJson(user),
          token: token,
          message: 'Quick login successful',
        );
      } else {
        throw Exception('Role not found');
      }
    } catch (e) {
      debugPrint('Quick login failed: $e');
      throw Exception('Quick login failed: ${e.toString()}');
    }
  }

  // Biometric login
  Future<LoginResponse> biometricLogin() async {
    try {
      // TODO: Implement actual biometric authentication
      // final response = await http.post('$_baseUrl/auth/biometric', body: {
      //   'biometricData': await _biometricAuth.getBiometricData(),
      // });
      
      // Mock biometric login - return MR user for demo
      final user = _mockUsers.firstWhere(
        (user) => user['role'] == 'MR',
        orElse: () => null,
      );
      
      if (user != null) {
        final token = 'biometric_token_${user['id']}_${DateTime.now().millisecondsSinceEpoch}';
        return LoginResponse(
          user: User.fromJson(user),
          token: token,
          message: 'Biometric login successful',
        );
      } else {
        throw Exception('Biometric authentication not available');
      }
    } catch (e) {
      debugPrint('Biometric login failed: $e');
      throw Exception('Biometric login failed: ${e.toString()}');
    }
  }

  // Register new user
  Future<RegisterResponse> register(Map<String, dynamic> userData) async {
    try {
      // TODO: Implement actual API call
      // final response = await http.post('$_baseUrl/auth/register', body: userData);
      
      // Mock registration
      final email = userData['email'] as String;
      
      // Check if email already exists
      if (_mockUsers.any((user) => user['email'] == email)) {
        throw Exception('Email already exists');
      }
      
      final newUser = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'name': userData['name'],
        'email': email,
        'role': userData['role'],
        'licenseNumber': userData['licenseNumber'],
        'phone': userData['phone'],
        'isActive': true,
        'createdAt': DateTime.now().toIso8601String(),
        'lastLogin': null,
      };
      
      final token = 'mock_token_${newUser['id']}';
      
      return RegisterResponse(
        user: User.fromJson(newUser),
        token: token,
        message: 'Registration successful',
      );
    } catch (e) {
      debugPrint('Registration failed: $e');
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      // TODO: Implement actual API call
      // await http.post('$_baseUrl/auth/reset-password', body: {
      //   'email': email,
      // });
      
      // Mock password reset
      debugPrint('Password reset initiated for email: $email');
      
      // In a real implementation, this would send an email
      // with a reset link containing a verification code
    } catch (e) {
      debugPrint('Password reset failed: $e');
      throw Exception('Password reset failed: ${e.toString()}');
    }
  }

  // Confirm password reset with verification code
  Future<void> confirmPasswordReset(String email, String verificationCode, String newPassword) async {
    try {
      // TODO: Implement actual API call
      // await http.post('$_baseUrl/auth/confirm-reset', body: {
      //   'email': email,
      //   'verificationCode': verificationCode,
      //   'newPassword': newPassword,
      // });
      
      // Mock password reset confirmation
      debugPrint('Password reset confirmed for email: $email');
      debugPrint('Verification code: $verificationCode');
      debugPrint('New password: $newPassword');
    } catch (e) {
      debugPrint('Password reset confirmation failed: $e');
      throw Exception('Password reset confirmation failed: ${e.toString()}');
    }
  }

  // Logout user
  Future<void> logout() async {
    try {
      // TODO: Implement actual API call
      // await http.post('$_baseUrl/auth/logout', headers: {
      //   'Authorization': 'Bearer $token',
      // });
      
      // Clear stored data
      // await _secureStorage.delete(_tokenKey);
      // await _secureStorage.delete(_userKey);
      
      debugPrint('Logout successful');
    } catch (e) {
      debugPrint('Logout failed: $e');
    }
  }

  // Update user profile
  Future<User> updateProfile(Map<String, dynamic> profileData) async {
    try {
      // TODO: Implement actual API call
      // final response = await http.put('$_baseUrl/auth/profile', body: profileData, headers: {
      //   'Authorization': 'Bearer $token',
      // });
      
      // Mock profile update
      debugPrint('Profile updated: $profileData');
      
      // Return updated user (mock implementation)
      return User.fromJson(_mockUsers.first);
    } catch (e) {
      debugPrint('Profile update failed: $e');
      throw Exception('Profile update failed: ${e.toString()}');
    }
  }

  // Change password
  Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      // TODO: Implement actual API call
      // await http.post('$_baseUrl/auth/change-password', body: {
      //   'currentPassword': currentPassword,
      //   'newPassword': newPassword,
      // }, headers: {
      //   'Authorization': 'Bearer $token',
      // });
      
      // Mock password change
      debugPrint('Password changed successfully');
    } catch (e) {
      debugPrint('Password change failed: $e');
      throw Exception('Password change failed: ${e.toString()}');
    }
  }

  // Check biometric availability
  Future<bool> isBiometricAvailable() async {
    try {
      // TODO: Implement actual biometric check
      // return await _biometricAuth.canCheckBiometrics();
      
      // Mock biometric availability
      return true; // Always return true for demo
    } catch (e) {
      debugPrint('Biometric check failed: $e');
      return false;
    }
  }

  // Toggle biometric authentication
  Future<void> toggleBiometric(bool enabled) async {
    try {
      // TODO: Implement actual biometric toggle
      // await _secureStorage.write(_biometricKey, enabled.toString());
      
      debugPrint('Biometric authentication ${enabled ? 'enabled' : 'disabled'}');
    } catch (e) {
      debugPrint('Biometric toggle failed: $e');
    }
  }

  // Refresh user token
  Future<LoginResponse> refreshToken(String token) async {
    try {
      // TODO: Implement actual API call
      // final response = await http.post('$_baseUrl/auth/refresh', headers: {
      //   'Authorization': 'Bearer $token',
      // });
      
      // Mock token refresh
      final user = _mockUsers.first;
      final newToken = 'refreshed_token_${DateTime.now().millisecondsSinceEpoch}';
      
      return LoginResponse(
        user: User.fromJson(user),
        token: newToken,
        message: 'Token refreshed successfully',
      );
    } catch (e) {
      debugPrint('Token refresh failed: $e');
      throw Exception('Token refresh failed: ${e.toString()}');
    }
  }
}

// Response models
class LoginResponse {
  final User user;
  final String token;
  final String message;

  LoginResponse({
    required this.user,
    required this.token,
    required this.message,
  });
}

class RegisterResponse {
  final User user;
  final String token;
  final String message;

  RegisterResponse({
    required this.user,
    required this.token,
    required this.message,
  });
}
