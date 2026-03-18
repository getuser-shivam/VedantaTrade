import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString('user');
      
      if (userData != null) {
        final userJson = json.decode(userData);
        _user = User.fromJson(userJson);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading user: $e');
    }
  }

  Future<void> _saveUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_user != null) {
        await prefs.setString('user', json.encode(_user!.toJson()));
      } else {
        await prefs.remove('user');
      }
    } catch (e) {
      debugPrint('Error saving user: $e');
    }
  }

  Future<bool> signUp(String name, String email, String phone, String password) async {
    _setLoading(true);
    _clearError();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // In a real app, this would be an API call to create user
      // For demo, we'll create a mock user
      _user = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        email: email,
        phone: phone,
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
      );

      await _saveUser();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Sign up failed. Please try again.');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signIn(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // In a real app, this would validate credentials with backend
      // For demo, we'll accept any email/password combination
      if (email.isNotEmpty && password.isNotEmpty) {
        _user = User(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: email.split('@')[0], // Extract name from email
          email: email,
          phone: '+977 1234567890', // Mock phone
          createdAt: DateTime.now(),
          lastLogin: DateTime.now(),
        );

        await _saveUser();
        _setLoading(false);
        return true;
      } else {
        _setError('Invalid email or password');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Sign in failed. Please try again.');
      _setLoading(false);
      return false;
    }
  }

  Future<void> signOut() async {
    _user = null;
    await _saveUser();
    notifyListeners();
  }

  Future<bool> updateProfile({
    String? name,
    String? phone,
    String? avatar,
  }) async {
    if (_user == null) return false;

    _setLoading(true);
    _clearError();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      _user = _user!.copyWith(
        name: name,
        phone: phone,
        avatar: avatar,
      );

      await _saveUser();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Profile update failed. Please try again.');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> addAddress(String address) async {
    if (_user == null) return false;

    _setLoading(true);
    _clearError();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      final updatedAddresses = List<String>.from(_user!.addresses);
      updatedAddresses.add(address);

      _user = _user!.copyWith(addresses: updatedAddresses);
      await _saveUser();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to add address. Please try again.');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> removeAddress(String address) async {
    if (_user == null) return false;

    _setLoading(true);
    _clearError();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      final updatedAddresses = List<String>.from(_user!.addresses);
      updatedAddresses.remove(address);

      _user = _user!.copyWith(addresses: updatedAddresses);
      await _saveUser();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to remove address. Please try again.');
      _setLoading(false);
      return false;
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
