import 'package:flutter/foundation.dart';

import '../../data/services/auth_repository.dart';
import '../../domain/models/auth_user.dart';
import '../../domain/models/business_role.dart';

class AuthController extends ChangeNotifier {
  AuthController({required AuthRepository authRepository})
    : _authRepository = authRepository;

  final AuthRepository _authRepository;

  bool _isInitializing = true;
  bool _isSubmitting = false;
  AuthUser? _currentUser;
  String? _statusMessage;

  bool get isInitializing => _isInitializing;
  bool get isSubmitting => _isSubmitting;
  AuthUser? get currentUser => _currentUser;
  String? get statusMessage => _statusMessage;
  bool get isAuthenticated => _currentUser != null;

  Future<void> restoreSession() async {
    _isInitializing = true;
    notifyListeners();

    try {
      _currentUser = await _authRepository.restoreSession();
      _statusMessage = null;
    } finally {
      _isInitializing = false;
      notifyListeners();
    }
  }

  Future<bool> signIn({required String email, required String password}) async {
    return _runAuthOperation(
      () => _authRepository.signIn(email: email, password: password),
    );
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
    required BusinessRole role,
  }) async {
    return _runAuthOperation(
      () => _authRepository.register(
        fullName: fullName,
        email: email,
        password: password,
        role: role,
      ),
    );
  }

  Future<void> signOut() async {
    _isSubmitting = true;
    notifyListeners();

    try {
      await _authRepository.signOut();
      _currentUser = null;
      _statusMessage = null;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  void clearStatus() {
    if (_statusMessage == null) {
      return;
    }

    _statusMessage = null;
    notifyListeners();
  }

  Future<bool> _runAuthOperation(Future<AuthUser> Function() operation) async {
    _isSubmitting = true;
    _statusMessage = null;
    notifyListeners();

    try {
      _currentUser = await operation();
      return true;
    } on AuthFailure catch (error) {
      _statusMessage = error.message;
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}
