import 'business_role.dart';

class AuthUser {
  const AuthUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
  });

  final String id;
  final String fullName;
  final String email;
  final BusinessRole role;

  String get firstName {
    final trimmed = fullName.trim();
    if (trimmed.isEmpty) {
      return 'User';
    }

    return trimmed.split(RegExp(r'\s+')).first;
  }
}
