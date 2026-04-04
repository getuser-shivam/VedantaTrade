import 'package:dartz/dartz.dart';
import '../entities/product_entity.dart';

/// Product Catalog Repository Interface
/// Defines the contract for product catalog data operations
abstract class ProductCatalogRepository {
  /// Get all products
  Future<Either<String, List<ProductEntity>>> getProducts();

  /// Get product by ID
  Future<Either<String, ProductEntity>> getProductById(String id);

  /// Get products by category
  Future<Either<String, List<ProductEntity>>> getProductsByCategory(String category);

  /// Get featured products
  Future<Either<String, List<ProductEntity>>> getFeaturedProducts();

  /// Search products
  Future<Either<String, List<ProductEntity>>> searchProducts(String query);

  /// Get products by manufacturer
  Future<Either<String, List<ProductEntity>>> getProductsByManufacturer(String manufacturer);

  /// Get product categories
  Future<Either<String, List<String>>> getCategories();

  /// Get product manufacturers
  Future<Either<String, List<String>>> getManufacturers();

  /// Add product (for admin)
  Future<Either<String, ProductEntity>> addProduct(ProductEntity product);

  /// Update product (for admin)
  Future<Either<String, ProductEntity>> updateProduct(ProductEntity product);

  /// Delete product (for admin)
  Future<Either<String, void>> deleteProduct(String id);

  /// Update product stock
  Future<Either<String, ProductEntity>> updateProductStock(String id, int quantity);

  /// Get low stock products
  Future<Either<String, List<ProductEntity>>> getLowStockProducts();

  /// Get out of stock products
  Future<Either<String, List<ProductEntity>>> getOutOfStockProducts();
}
