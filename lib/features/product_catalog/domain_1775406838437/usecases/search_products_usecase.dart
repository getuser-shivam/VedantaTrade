import 'package:dartz/dartz.dart';
import '../entities/product_entity.dart';
import '../repositories/product_catalog_repository.dart';

/// Search Products Use Case
/// Handles product search business logic
class SearchProductsUseCase {
  final ProductCatalogRepository _repository;

  SearchProductsUseCase(this._repository);

  Future<Either<String, List<ProductEntity>>> execute(String query) async {
    // Validate input
    if (query.isEmpty) {
      return const Left('Search query cannot be empty');
    }

    if (query.length < 2) {
      return const Left('Search query must be at least 2 characters');
    }

    // Call repository
    return await _repository.searchProducts(query);
  }
}
