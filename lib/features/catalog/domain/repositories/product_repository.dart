import 'package:vedanta_trade/features/catalog/domain/models/product.dart';

/// Repository interface for product catalog operations
/// Following Clean Architecture - Domain Layer
abstract class ProductRepository {
  /// Get all registered products
  Future<List<Product>> getProducts({String? category, String? token});
  
  /// Get featured products for showcase
  Future<List<Product>> getFeaturedProducts({String? token});
  
  /// Get product by ID
  Future<Product?> getProductById(String id, {String? token});
  
  /// Search products by query
  Future<List<Product>> searchProducts(String query, {String? token});
  
  /// Get all categories
  Future<List<Category>> getCategories({String? token});
  
  /// Get all manufacturers
  Future<List<Manufacturer>> getManufacturers({String? token});
  
  /// Get products by category
  Future<List<Product>> getProductsByCategory(String category, {String? token});
  
  /// Get low stock products (for stockist view)
  Future<List<Product>> getLowStockProducts({String? token});
  
  /// Filter products by multiple criteria
  Future<List<Product>> filterProducts({
    String? category,
    String? manufacturer,
    double? minPrice,
    double? maxPrice,
    bool? inStock,
    String? token,
  });
}
