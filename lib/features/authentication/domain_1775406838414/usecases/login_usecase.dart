import 'package:dartz/dartz.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Login Use Case
/// Handles user login business logic
class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  Future<Either<String, UserEntity>> execute(String email, String password) async {
    // Validate input
    if (email.isEmpty || password.isEmpty) {
      return const Left('Email and password are required');
    }

    // Validate email format
    if (!_isValidEmail(email)) {
      return const Left('Invalid email format');
    }

    // Validate password strength
    if (password.length < 6) {
      return const Left('Password must be at least 6 characters');
    }

    // Call repository
    return await _repository.login(email, password);
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}
