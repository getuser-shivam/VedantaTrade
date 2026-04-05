import 'package:dartz/dartz.dart';
import '../entities/product_entity.dart';
import '../entities/product_filter_entity.dart';

/// Product Catalog Repository Interface
/// Abstract interface for product catalog operations
abstract class ProductCatalogRepository {
  /// Get products with filtering, sorting, and pagination
  Future<Either<String, ProductSearchResult>> getProducts({
    ProductFilterEntity? filters,
    int page = 1,
    int limit = 20,
  });

  /// Get product by ID
  Future<Either<String, ProductEntity>> getProductById(String id);

  /// Search products by query
  Future<Either<String, ProductSearchResult>> searchProducts(
    String query, {
    ProductFilterEntity? filters,
    int page = 1,
    int limit = 20,
  });

  /// Get products by category
  Future<Either<String, ProductSearchResult>> getProductsByCategory(
    String categoryId, {
    ProductFilterEntity? filters,
    int page = 1,
    int limit = 20,
  });

  /// Get products by brand
  Future<Either<String, ProductSearchResult>> getProductsByBrand(
    String brand, {
    ProductFilterEntity? filters,
    int page = 1,
    int limit = 20,
  });

  /// Get featured products
  Future<Either<String, List<ProductEntity>>> getFeaturedProducts({int limit = 10});

  /// Get trending products
  Future<Either<String, List<ProductEntity>>> getTrendingProducts({int limit = 10});

  /// Get related products
  Future<Either<String, List<ProductEntity>>> getRelatedProducts(
    String productId, {
    int limit = 5,
  });

  /// Get recently viewed products
  Future<Either<String, List<ProductEntity>>> getRecentlyViewedProducts({
    int limit = 10,
  });

  /// Get products on sale
  Future<Either<String, ProductSearchResult>> getProductsOnSale({
    ProductFilterEntity? filters,
    int page = 1,
    int limit = 20,
  });

  /// Get out of stock products
  Future<Either<String, ProductSearchResult>> getOutOfStockProducts({
    int page = 1,
    int limit = 20,
  });

  /// Get expiring soon products
  Future<Either<String, List<ProductEntity>>> getExpiringSoonProducts({
    int days = 30,
    int limit = 20,
  });

  /// Get low stock products
  Future<Either<String, List<ProductEntity>>> getLowStockProducts({
    int threshold = 10,
    int limit = 20,
  });

  /// Get product suggestions based on query
  Future<Either<String, List<String>>> getProductSuggestions(String query);

  /// Get filter options (available categories, brands, etc.)
  Future<Either<String, Map<String, List<String>>>> getFilterOptions();

  /// Save product to favorites
  Future<Either<String, void>> addToFavorites(String productId);

  /// Remove product from favorites
  Future<Either<String, void>> removeFromFavorites(String productId);

  /// Get favorite products
  Future<Either<String, List<ProductEntity>>> getFavoriteProducts({
    int page = 1,
    int limit = 20,
  });

  /// Check if product is in favorites
  Future<Either<String, bool>> isProductFavorite(String productId);

  /// Track product view
  Future<Either<String, void>> trackProductView(String productId);

  /// Get recently viewed product IDs
  Future<Either<String, List<String>>> getRecentlyViewedProductIds();

  /// Save search history
  Future<Either<String, void>> saveSearchQuery(String query);

  /// Get search history
  Future<Either<String, List<String>>> getSearchHistory({int limit = 10});

  /// Clear search history
  Future<Either<String, void>> clearSearchHistory();

  /// Get product reviews
  Future<Either<String, List<ProductReview>>> getProductReviews(
    String productId, {
    int page = 1,
    int limit = 20,
  });

  /// Add product review
  Future<Either<String, void>> addProductReview(
    String productId,
    ProductReview review,
  );

  /// Update product review
  Future<Either<String, void>> updateProductReview(
    String productId,
    String reviewId,
    ProductReview review,
  );

  /// Delete product review
  Future<Either<String, void>> deleteProductReview(
    String productId,
    String reviewId,
  );

  /// Get product rating summary
  Future<Either<String, ProductRatingSummary>> getProductRatingSummary(String productId);

  /// Report product issue
  Future<Either<String, void>> reportProductIssue(
    String productId,
    ProductIssueReport report,
  );

  /// Get product stock information
  Future<Either<String, ProductStockInfo>> getProductStockInfo(String productId);

  /// Update product stock
  Future<Either<String, void>> updateProductStock(
    String productId,
    int quantity,
  );

  /// Get product variants
  Future<Either<String, List<ProductVariant>>> getProductVariants(String productId);

  /// Get product comparison
  Future<Either<String, List<ProductEntity>>> getProductComparison(
    List<String> productIds,
  );

  /// Add to comparison
  Future<Either<String, void>> addToComparison(String productId);

  /// Remove from comparison
  Future<Either<String, void>> removeFromComparison(String productId);

  /// Get comparison list
  Future<Either<String, List<ProductEntity>>> getComparisonList();

  /// Clear comparison list
  Future<Either<String, void>> clearComparisonList();

  /// Bulk operations
  Future<Either<String, void>> bulkAddToFavorites(List<String> productIds);

  Future<Either<String, void>> bulkRemoveFromFavorites(List<String> productIds);

  Future<Either<String, List<ProductEntity>>> bulkGetProducts(List<String> productIds);

  /// Cache management
  Future<Either<String, void>> clearProductCache();

  Future<Either<String, void>> preloadPopularProducts();

  /// Sync operations
  Future<Either<String, void>> syncProducts();

  Future<Either<String, bool>> isProductDataFresh();

  /// Analytics and insights
  Future<Either<String, ProductAnalytics>> getProductAnalytics();

  Future<Either<String, List<String>>> getPopularSearchTerms();

  Future<Either<String, List<String>>> getTrendingCategories();

  /// Advanced search with filters
  Future<Either<String, ProductSearchResult>> advancedSearch({
    String? query,
    List<String>? categories,
    List<String>? brands,
    List<String>? manufacturers,
    List<String>? tags,
    double? minPrice,
    double? maxPrice,
    bool? inStockOnly,
    bool? onSaleOnly,
    double? minRating,
    String? sortBy,
    String? sortOrder,
    int page = 1,
    int limit = 20,
  });

  /// Get products by manufacturer
  Future<Either<String, ProductSearchResult>> getProductsByManufacturer(
    String manufacturer, {
    ProductFilterEntity? filters,
    int page = 1,
    int limit = 20,
  });

  /// Get products by dosage form
  Future<Either<String, ProductSearchResult>> getProductsByDosageForm(
    String dosageForm, {
    ProductFilterEntity? filters,
    int page = 1,
    int limit = 20,
  });

  /// Get products by tags
  Future<Either<String, ProductSearchResult>> getProductsByTags(
    List<String> tags, {
    ProductFilterEntity? filters,
    int page = 1,
    int limit = 20,
  });

  /// Get products by price range
  Future<Either<String, ProductSearchResult>> getProductsByPriceRange(
    double minPrice,
    double maxPrice, {
    ProductFilterEntity? filters,
    int page = 1,
    int limit = 20,
  });

  /// Get products by rating
  Future<Either<String, ProductSearchResult>> getProductsByRating(
    double minRating, {
    ProductFilterEntity? filters,
    int page = 1,
    int limit = 20,
  });

  /// Get products by availability
  Future<Either<String, ProductSearchResult>> getProductsByAvailability(
    ProductAvailability availability, {
    ProductFilterEntity? filters,
    int page = 1,
    int limit = 20,
  });

  /// Get new arrivals
  Future<Either<String, List<ProductEntity>>> getNewArrivals({int limit = 10});

  /// Get best sellers
  Future<Either<String, List<ProductEntity>>> getBestSellers({int limit = 10});

  /// Get recommended products
  Future<Either<String, List<ProductEntity>>> getRecommendedProducts({
    String? userId,
    int limit = 10,
  });

  /// Get similar products
  Future<Either<String, List<ProductEntity>>> getSimilarProducts(
    String productId, {
    int limit = 5,
  });

  /// Get frequently bought together products
  Future<Either<String, List<ProductEntity>>> getFrequentlyBoughtTogether(
    String productId, {
    int limit = 5,
  });

  /// Get product categories with counts
  Future<Either<String, List<ProductCategory>>> getProductCategoriesWithCounts();

  /// Get product brands with counts
  Future<Either<String, List<ProductBrand>>> getProductBrandsWithCounts();

  /// Get product manufacturers with counts
  Future<Either<String, List<ProductManufacturer>>> getProductManufacturersWithCounts();

  /// Get product dosage forms with counts
  Future<Either<String, List<ProductDosageForm>>> getProductDosageFormsWithCounts();

  /// Get popular tags with counts
  Future<Either<String, List<ProductTag>>> getPopularTagsWithCounts();

  /// Get product statistics
  Future<Either<String, ProductStatistics>> getProductStatistics();

  /// Update product popularity score
  Future<Either<String, void>> updateProductPopularity(
    String productId,
    double score,
  );

  /// Get product price history
  Future<Either<String, List<ProductPriceHistory>>> getProductPriceHistory(
    String productId, {
    int days = 30,
  });

  /// Get product stock history
  Future<Either<String, List<ProductStockHistory>>> getProductStockHistory(
    String productId, {
    int days = 30,
  });

  /// Get product view history
  Future<Either<String, List<ProductViewHistory>>> getProductViewHistory(
    String productId, {
    int days = 30,
  });

  /// Export product data
  Future<Either<String, String>> exportProducts({
    ProductFilterEntity? filters,
    String format = 'csv',
  });

  /// Import product data
  Future<Either<String, void>> importProducts(
    String filePath, {
    bool overwrite = false,
  });

  /// Validate product data
  Future<Either<String, List<ProductValidationError>>> validateProductData(
    List<Map<String, dynamic>> productsData,
  );

  /// Bulk update products
  Future<Either<String, void>> bulkUpdateProducts(
    List<ProductEntity> products,
  );

  /// Bulk delete products
  Future<Either<String, void>> bulkDeleteProducts(List<String> productIds);

  /// Archive products
  Future<Either<String, void>> archiveProducts(List<String> productIds);

  /// Restore archived products
  Future<Either<String, void>> restoreArchivedProducts(List<String> productIds);

  /// Get archived products
  Future<Either<String, ProductSearchResult>> getArchivedProducts({
    int page = 1,
    int limit = 20,
  });

  /// Search archived products
  Future<Either<String, ProductSearchResult>> searchArchivedProducts(
    String query, {
    int page = 1,
    int limit = 20,
  });
}

/// Product Review Entity
class ProductReview {
  final String id;
  final String productId;
  final String userId;
  final String userName;
  final double rating;
  final String title;
  final String comment;
  final List<String> pros;
  final List<String> cons;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool verified;
  final int helpfulCount;

  const ProductReview({
    required this.id,
    required this.productId,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.title,
    required this.comment,
    this.pros = const [],
    this.cons = const [],
    required this.createdAt,
    required this.updatedAt,
    this.verified = false,
    this.helpfulCount = 0,
  });
}

/// Product Rating Summary
class ProductRatingSummary {
  final double averageRating;
  final int totalReviews;
  final Map<int, int> ratingDistribution;
  final double recommendedPercentage;

  const ProductRatingSummary({
    required this.averageRating,
    required this.totalReviews,
    required this.ratingDistribution,
    required this.recommendedPercentage,
  });
}

/// Product Issue Report
class ProductIssueReport {
  final String productId;
  final String userId;
  final ProductIssueType issueType;
  final String description;
  final List<String> attachments;
  final DateTime createdAt;

  const ProductIssueReport({
    required this.productId,
    required this.userId,
    required this.issueType,
    required this.description,
    this.attachments = const [],
    required this.createdAt,
  });
}

/// Product Stock Information
class ProductStockInfo {
  final String productId;
  final int currentStock;
  final int availableStock;
  final int reservedStock;
  final DateTime lastUpdated;
  final String? nextRestockDate;
  final bool isLowStock;
  final bool isOutOfStock;

  const ProductStockInfo({
    required this.productId,
    required this.currentStock,
    required this.availableStock,
    required this.reservedStock,
    required this.lastUpdated,
    this.nextRestockDate,
    this.isLowStock = false,
    this.isOutOfStock = false,
  });
}

/// Product Analytics
class ProductAnalytics {
  final int totalProducts;
  final int totalCategories;
  final int totalBrands;
  final int lowStockProducts;
  final int outOfStockProducts;
  final int expiringSoonProducts;
  final List<String> topCategories;
  final List<String> topBrands;
  final List<String> trendingProducts;
  final double averageRating;
  final int totalReviews;

  const ProductAnalytics({
    required this.totalProducts,
    required this.totalCategories,
    required this.totalBrands,
    required this.lowStockProducts,
    required this.outOfStockProducts,
    required this.expiringSoonProducts,
    required this.topCategories,
    required this.topBrands,
    required this.trendingProducts,
    required this.averageRating,
    required this.totalReviews,
  });
}

/// Product Issue Type
enum ProductIssueType {
  incorrectInformation,
  qualityIssue,
  damagedProduct,
  wrongProduct,
  missingParts,
  other,
}

/// Product Category with Count
class ProductCategory {
  final String id;
  final String name;
  final String? iconUrl;
  final int productCount;
  final bool isActive;

  const ProductCategory({
    required this.id,
    required this.name,
    this.iconUrl,
    required this.productCount,
    this.isActive = true,
  });
}

/// Product Brand with Count
class ProductBrand {
  final String id;
  final String name;
  final String? logoUrl;
  final int productCount;
  final bool isActive;

  const ProductBrand({
    required this.id,
    required this.name,
    this.logoUrl,
    required this.productCount,
    this.isActive = true,
  });
}

/// Product Manufacturer with Count
class ProductManufacturer {
  final String id;
  final String name;
  final String? logoUrl;
  final int productCount;
  final bool isActive;

  const ProductManufacturer({
    required this.id,
    required this.name,
    this.logoUrl,
    required this.productCount,
    this.isActive = true,
  });
}

/// Product Dosage Form with Count
class ProductDosageForm {
  final String id;
  final String name;
  final String? iconUrl;
  final int productCount;
  final bool isActive;

  const ProductDosageForm {
    required this.id,
    required this.name,
    this.iconUrl,
    required this.productCount,
    this.isActive = true,
  };
}

/// Product Tag with Count
class ProductTag {
  final String id;
  final String name;
  final String? color;
  final int productCount;
  final bool isActive;

  const ProductTag({
    required this.id,
    required this.name,
    this.color,
    required this.productCount,
    this.isActive = true,
  });
}

/// Product Statistics
class ProductStatistics {
  final int totalProducts;
  final int activeProducts;
  final int inactiveProducts;
  final int archivedProducts;
  final int lowStockProducts;
  final int outOfStockProducts;
  final int expiringSoonProducts;
  final int productsOnSale;
  final double averagePrice;
  final double averageRating;
  final int totalReviews;
  final int totalCategories;
  final int totalBrands;
  final int totalManufacturers;
  final DateTime lastUpdated;

  const ProductStatistics({
    required this.totalProducts,
    required this.activeProducts,
    required this.inactiveProducts,
    required this.archivedProducts,
    required this.lowStockProducts,
    required this.outOfStockProducts,
    required this.expiringSoonProducts,
    required this.productsOnSale,
    required this.averagePrice,
    required this.averageRating,
    required this.totalReviews,
    required this.totalCategories,
    required this.totalBrands,
    required this.totalManufacturers,
    required this.lastUpdated,
  });
}

/// Product Price History
class ProductPriceHistory {
  final String productId;
  final double price;
  final double? discountedPrice;
  final DateTime effectiveDate;
  final String? reason;

  const ProductPriceHistory({
    required this.productId,
    required this.price,
    this.discountedPrice,
    required this.effectiveDate,
    this.reason,
  });
}

/// Product Stock History
class ProductStockHistory {
  final String productId;
  final int previousStock;
  final int newStock;
  final DateTime effectiveDate;
  final String? reason;

  const ProductStockHistory({
    required this.productId,
    required this.previousStock,
    required this.newStock,
    required this.effectiveDate,
    this.reason,
  });
}

/// Product View History
class ProductViewHistory {
  final String productId;
  final int viewCount;
  final DateTime date;
  final String? userId;
  final String? sessionId;

  const ProductViewHistory({
    required this.productId,
    required this.viewCount,
    required this.date,
    this.userId,
    this.sessionId,
  });
}

/// Product Validation Error
class ProductValidationError {
  final String field;
  final String message;
  final String? productId;
  final ValidationErrorType type;

  const ProductValidationError({
    required this.field,
    required this.message,
    this.productId,
    required this.type,
  });
}

/// Validation Error Type
enum ValidationErrorType {
  required,
  invalidFormat,
  invalidRange,
  duplicate,
  reference,
  business,
}

/// Product Search Result
class ProductSearchResult {
  final List<ProductEntity> products;
  final int totalCount;
  final int currentPage;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;
  final ProductFilterEntity appliedFilters;
  final Duration searchTime;

  const ProductSearchResult({
    required this.products,
    required this.totalCount,
    required this.currentPage,
    required this.totalPages,
    this.hasNextPage = false,
    this.hasPreviousPage = false,
    required this.appliedFilters,
    required this.searchTime,
  });

  bool get hasResults => products.isNotEmpty;
  bool get hasMoreResults => hasNextPage;
}
