import '../models/product_entity.dart';
import '../models/product_filter.dart';

abstract class ProductRepository {
  Future<List<ProductEntity>> getProducts({
    ProductFilter? filter,
    int page = 1,
    int limit = 20,
  });

  Future<ProductEntity?> getProductById(String id);
  
  Future<List<ProductEntity>> getProductsByCategory(String category);
  
  Future<List<ProductEntity>> searchProducts(String query);
  
  Future<List<ProductEntity>> getFeaturedProducts();
  
  Future<List<ProductEntity>> getDiscountedProducts();
  
  Future<List<ProductEntity>> getExpiringSoonProducts();
  
  Future<List<ProductEntity>> getLowStockProducts();
  
  Future<List<String>> getCategories();
  
  Future<List<String>> getManufacturers();
  
  Future<List<String>> getTags();
  
  Future<List<ProductEntity>> getRelatedProducts(String productId);
  
  Future<void> addToFavorites(String productId);
  Future<void> removeFromFavorites(String productId);
  Future<List<ProductEntity>> getFavoriteProducts();
  Future<bool> isFavorite(String productId);
  
  Future<void> addToRecentlyViewed(String productId);
  Future<List<ProductEntity>> getRecentlyViewedProducts();
  
  Future<void> rateProduct(String productId, double rating, String? review);
  
  Future<List<ProductEntity>> getProductsByManufacturer(String manufacturer);
  
  Future<void> trackProductView(String productId);
  
  Future<Map<String, dynamic>> getProductAnalytics();
}
