import 'package:dartz/dartz.dart';
import '../repositories/auth_repository.dart';

/// Logout Use Case
/// Handles user logout business logic
class LogoutUseCase {
  final AuthRepository _repository;

  LogoutUseCase(this._repository);

  Future<Either<String, void>> execute() async {
    // Call repository
    return await _repository.logout();
  }
}
