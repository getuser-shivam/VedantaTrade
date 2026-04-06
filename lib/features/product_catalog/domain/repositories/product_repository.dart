import '../models/product_entity.dart';
import '../models/product_filter.dart';

abstract class ProductRepository {
  Future<List<Product>> getProducts({
    ProductFilter? filter,
    int page = 1,
    int limit = 20,
  });

  Future<Product?> getProductById(String id);
  
  Future<List<Product>> getProductsByCategory(String category);
  
  Future<List<Product>> searchProducts(String query);
  
  Future<List<Product>> getFeaturedProducts();
  
  Future<List<Product>> getDiscountedProducts();
  
  Future<List<Product>> getExpiringSoonProducts();
  
  Future<List<Product>> getLowStockProducts();
  
  Future<List<String>> getCategories();
  
  Future<List<String>> getManufacturers();
  
  Future<List<String>> getTags();
  
  Future<List<Product>> getRelatedProducts(String productId);
  
  Future<void> addToFavorites(String productId);
  Future<void> removeFromFavorites(String productId);
  Future<List<Product>> getFavoriteProducts();
  Future<bool> isFavorite(String productId);
  
  Future<void> addToRecentlyViewed(String productId);
  Future<List<Product>> getRecentlyViewedProducts();
  
  Future<void> rateProduct(String productId, double rating, String? review);
  
  Future<List<Product>> getProductsByManufacturer(String manufacturer);
  
  Future<void> trackProductView(String productId);
  
  Future<Map<String, dynamic>> getProductAnalytics();
}
