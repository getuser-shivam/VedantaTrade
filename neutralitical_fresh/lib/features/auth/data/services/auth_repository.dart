import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/auth_user.dart';
import '../../domain/models/business_role.dart';

class AuthFailure implements Exception {
  const AuthFailure(this.message);

  final String message;
}

abstract class AuthRepository {
  Future<AuthUser?> restoreSession();

  Future<AuthUser> signIn({required String email, required String password});

  Future<AuthUser> register({
    required String fullName,
    required String email,
    required String password,
    required BusinessRole role,
  });

  Future<void> signOut();
}

class LocalAuthRepository implements AuthRepository {
  LocalAuthRepository();

  static const _accountsKey = 'neutralitical.auth.accounts.v1';
  static const _sessionUserIdKey = 'neutralitical.auth.session_user_id.v1';
  static const _seedPassword = 'Neutral@2026';

  @override
  Future<AuthUser?> restoreSession() async {
    final preferences = await SharedPreferences.getInstance();
    final sessionUserId = preferences.getString(_sessionUserIdKey);
    if (sessionUserId == null || sessionUserId.isEmpty) {
      return null;
    }

    final accounts = await _loadAccounts(preferences);
    final account = accounts
        .where((candidate) => candidate.id == sessionUserId)
        .firstOrNull;

    if (account == null) {
      await preferences.remove(_sessionUserIdKey);
      return null;
    }

    return account.toAuthUser();
  }

  @override
  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = _normalizeEmail(email);
    final preferences = await SharedPreferences.getInstance();
    final accounts = await _loadAccounts(preferences);
    final account = accounts
        .where((candidate) => candidate.email == normalizedEmail)
        .firstOrNull;

    if (account == null || !_matchesPassword(account, password)) {
      throw const AuthFailure('Invalid email or password.');
    }

    await preferences.setString(_sessionUserIdKey, account.id);
    return account.toAuthUser();
  }

  @override
  Future<AuthUser> register({
    required String fullName,
    required String email,
    required String password,
    required BusinessRole role,
  }) async {
    final normalizedName = fullName.trim();
    final normalizedEmail = _normalizeEmail(email);

    if (normalizedName.length < 2) {
      throw const AuthFailure('Enter your full name to create an account.');
    }

    if (!_isValidEmail(normalizedEmail)) {
      throw const AuthFailure('Enter a valid email address.');
    }

    if (!_isStrongPassword(password)) {
      throw const AuthFailure(
        'Use at least 8 characters with upper, lower, and numeric characters.',
      );
    }

    final preferences = await SharedPreferences.getInstance();
    final accounts = await _loadAccounts(preferences);
    final exists = accounts.any(
      (candidate) => candidate.email == normalizedEmail,
    );

    if (exists) {
      throw const AuthFailure(
        'An account with that email already exists. Sign in instead.',
      );
    }

    final salt = _randomToken(length: 16);
    final account = _StoredAccount(
      id: _randomToken(length: 12),
      fullName: normalizedName,
      email: normalizedEmail,
      role: role,
      passwordSalt: salt,
      passwordHash: _hashPassword(salt: salt, password: password),
    );

    final updatedAccounts = [...accounts, account];
    await preferences.setString(
      _accountsKey,
      jsonEncode(updatedAccounts.map((item) => item.toJson()).toList()),
    );
    await preferences.setString(_sessionUserIdKey, account.id);

    return account.toAuthUser();
  }

  @override
  Future<void> signOut() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_sessionUserIdKey);
  }

  Future<List<_StoredAccount>> _loadAccounts(
    SharedPreferences preferences,
  ) async {
    final encodedAccounts = preferences.getString(_accountsKey);
    final customAccounts = <_StoredAccount>[];
    if (encodedAccounts == null || encodedAccounts.isEmpty) {
      return [..._seedAccounts];
    }

    final decoded = jsonDecode(encodedAccounts) as List<dynamic>;
    customAccounts.addAll(
      decoded
          .map((item) => _StoredAccount.fromJson(item as Map<String, dynamic>)),
    );
    return [..._seedAccounts, ...customAccounts];
  }

  bool _matchesPassword(_StoredAccount account, String password) {
    return account.passwordHash ==
        _hashPassword(salt: account.passwordSalt, password: password);
  }

  String _normalizeEmail(String value) => value.trim().toLowerCase();

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
  }

  bool _isStrongPassword(String password) {
    return password.length >= 8 &&
        RegExp(r'[A-Z]').hasMatch(password) &&
        RegExp(r'[a-z]').hasMatch(password) &&
        RegExp(r'\d').hasMatch(password);
  }

  String _hashPassword({required String salt, required String password}) {
    final bytes = utf8.encode('$salt::$password');
    return sha256.convert(bytes).toString();
  }

  List<_StoredAccount> get _seedAccounts {
    return [
      _seededAccount(
        id: 'seed_admin',
        fullName: 'Anika Pradhan',
        email: 'admin@neutralitical.app',
        role: BusinessRole.admin,
      ),
      _seededAccount(
        id: 'seed_mr',
        fullName: 'Rohit Verma',
        email: 'mr.east@neutralitical.app',
        role: BusinessRole.medicalRepresentative,
      ),
      _seededAccount(
        id: 'seed_accountant',
        fullName: 'Milan Koirala',
        email: 'accounts@neutralitical.app',
        role: BusinessRole.accountant,
      ),
      _seededAccount(
        id: 'seed_auditor',
        fullName: 'Sana Shah',
        email: 'audit@neutralitical.app',
        role: BusinessRole.auditor,
      ),
      _seededAccount(
        id: 'seed_doctor',
        fullName: 'Dr. Meera Adhikari',
        email: 'doctor.demo@neutralitical.app',
        role: BusinessRole.doctor,
      ),
      _seededAccount(
        id: 'seed_stockist',
        fullName: 'Omkar Distributors',
        email: 'stockist.demo@neutralitical.app',
        role: BusinessRole.stockist,
      ),
      _seededAccount(
        id: 'seed_retailer',
        fullName: 'CarePlus Pharmacy',
        email: 'retailer.demo@neutralitical.app',
        role: BusinessRole.retailer,
      ),
      _seededAccount(
        id: 'seed_hospital',
        fullName: 'Aarogya City Hospital',
        email: 'hospital.demo@neutralitical.app',
        role: BusinessRole.hospital,
      ),
    ];
  }

  _StoredAccount _seededAccount({
    required String id,
    required String fullName,
    required String email,
    required BusinessRole role,
  }) {
    final salt = 'neutralitical_seed';
    return _StoredAccount(
      id: id,
      fullName: fullName,
      email: email,
      role: role,
      passwordSalt: salt,
      passwordHash: _hashPassword(salt: salt, password: _seedPassword),
    );
  }

  String _randomToken({required int length}) {
    final random = Random.secure();
    final bytes = List<int>.generate(length, (_) => random.nextInt(256));
    return base64UrlEncode(bytes).replaceAll('=', '');
  }
}

class _StoredAccount {
  const _StoredAccount({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    required this.passwordSalt,
    required this.passwordHash,
  });

  final String id;
  final String fullName;
  final String email;
  final BusinessRole role;
  final String passwordSalt;
  final String passwordHash;

  factory _StoredAccount.fromJson(Map<String, dynamic> json) {
    return _StoredAccount(
      id: json['id']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: BusinessRoleX.fromValue(json['role']?.toString()),
      passwordSalt: json['passwordSalt']?.toString() ?? '',
      passwordHash: json['passwordHash']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'role': role.name,
      'passwordSalt': passwordSalt,
      'passwordHash': passwordHash,
    };
  }

  AuthUser toAuthUser() {
    return AuthUser(id: id, fullName: fullName, email: email, role: role);
  }
}
