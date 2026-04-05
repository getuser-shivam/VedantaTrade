import 'package:dartz/dartz.dart';
import '../entities/product_entity.dart';
import '../repositories/product_catalog_repository.dart';

/// Get Products Use Case
/// Handles retrieving all products business logic
class GetProductsUseCase {
  final ProductCatalogRepository _repository;

  GetProductsUseCase(this._repository);

  Future<Either<String, List<ProductEntity>>> execute() async {
    return await _repository.getProducts();
  }
}
