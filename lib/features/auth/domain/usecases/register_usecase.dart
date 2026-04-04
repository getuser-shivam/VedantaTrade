import 'package:dartz/dartz.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Register Use Case
/// Handles user registration business logic
class RegisterUseCase {
  final AuthRepository _repository;

  RegisterUseCase(this._repository);

  Future<Either<String, UserEntity>> execute(
    String name,
    String email,
    String password,
    String phone,
  ) async {
    // Validate input
    if (name.isEmpty || email.isEmpty || password.isEmpty || phone.isEmpty) {
      return const Left('All fields are required');
    }

    // Validate name
    if (name.length < 2) {
      return const Left('Name must be at least 2 characters');
    }

    // Validate email format
    if (!_isValidEmail(email)) {
      return const Left('Invalid email format');
    }

    // Validate password strength
    if (password.length < 6) {
      return const Left('Password must be at least 6 characters');
    }

    // Validate phone format
    if (!_isValidPhone(phone)) {
      return const Left('Invalid phone number format');
    }

    // Call repository
    return await _repository.register(name, email, password, phone);
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool _isValidPhone(String phone) {
    return RegExp(r'^[\d\s\-\+\(\)]+$').hasMatch(phone) && phone.length >= 10;
  }
}
