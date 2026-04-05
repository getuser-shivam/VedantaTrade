import 'package:dartz/dartz.dart';
import '../entities/product_entity.dart';
import '../repositories/product_catalog_repository.dart';

/// Get Product By ID Use Case
/// Handles retrieving a single product by ID business logic
class GetProductByIdUseCase {
  final ProductCatalogRepository _repository;

  GetProductByIdUseCase(this._repository);

  Future<Either<String, ProductEntity>> execute(String id) async {
    // Validate input
    if (id.isEmpty) {
      return const Left('Product ID cannot be empty');
    }

    // Call repository
    return await _repository.getProductById(id);
  }
}
