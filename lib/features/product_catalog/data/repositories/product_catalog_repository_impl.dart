import 'dart:async';
import 'package:dartz/dartz.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/entities/product_filter_entity.dart';
import '../../domain/repositories/product_catalog_repository.dart';
import '../datasources/product_local_datasource.dart';
import '../datasources/product_remote_datasource.dart';
import '../models/product_models.dart';
import '../../../shared/utils/app_utils.dart';
import '../../../shared/storage/storage_service.dart';

/// Product Catalog Repository Implementation
/// Concrete implementation of ProductCatalogRepository
class ProductCatalogRepositoryImpl implements ProductCatalogRepository {
  final ProductLocalDataSource _localDataSource;
  final ProductRemoteDataSource _remoteDataSource;
  final AppUtils _appUtils;
  final StorageService _storageService;

  ProductCatalogRepositoryImpl({
    required ProductLocalDataSource localDataSource,
    required ProductRemoteDataSource remoteDataSource,
    required AppUtils appUtils,
    required StorageService storageService,
  })  : _localDataSource = localDataSource,
        _remoteDataSource = remoteDataSource,
        _appUtils = appUtils,
        _storageService = storageService;

  @override
  Future<Either<String, ProductSearchResult>> getProducts({
    ProductFilterEntity? filters,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final stopwatch = Stopwatch()..start();

      // Try to get from cache first
      final cachedProducts = await _localDataSource.getCachedProducts();
      
      if (cachedProducts.isNotEmpty && page == 1) {
        // Apply filters to cached data
        final filteredProducts = _applyFilters(cachedProducts, filters);
        final sortedProducts = _applySorting(filteredProducts, filters);
        
        // Apply pagination
        final startIndex = (page - 1) * limit;
        final endIndex = startIndex + limit;
        final paginatedProducts = sortedProducts.skip(startIndex).take(endIndex - startIndex).toList();

        stopwatch.stop();

        return Right(ProductSearchResult(
          products: paginatedProducts,
          totalCount: sortedProducts.length,
          currentPage: page,
          totalPages: (sortedProducts.length / limit).ceil(),
          hasNextPage: endIndex < sortedProducts.length,
          hasPreviousPage: page > 1,
          appliedFilters: filters ?? const ProductFilterEntity(),
          searchTime: stopwatch.elapsed,
        ));
      }

      // Fetch from remote
      final remoteResult = await _remoteDataSource.getProducts(
        filters: filters,
        page: page,
        limit: limit,
      );

      if (remoteResult.isLeft()) {
        return Left(remoteResult.fold((l) => l, (r) => 'Failed to get products'));
      }

      final products = remoteResult.fold((l) => [], (r) => r);

      // Cache the results
      if (page == 1) {
        await _localDataSource.cacheProducts(products);
      }

      stopwatch.stop();

      return Right(ProductSearchResult(
        products: products,
        totalCount: products.length,
        currentPage: page,
        totalPages: (products.length / limit).ceil(),
        hasNextPage: products.length == limit,
        hasPreviousPage: page > 1,
        appliedFilters: filters ?? const ProductFilterEntity(),
        searchTime: stopwatch.elapsed,
      ));
    } catch (e) {
      // Fallback to cached data if remote fails
      try {
        final cachedProducts = await _localDataSource.getCachedProducts();
        if (cachedProducts.isNotEmpty) {
          final filteredProducts = _applyFilters(cachedProducts, filters);
          final sortedProducts = _applySorting(filteredProducts, filters);
          
          final startIndex = (page - 1) * limit;
          final endIndex = startIndex + limit;
          final paginatedProducts = sortedProducts.skip(startIndex).take(endIndex - startIndex).toList();

          return Right(ProductSearchResult(
            products: paginatedProducts,
            totalCount: sortedProducts.length,
            currentPage: page,
            totalPages: (sortedProducts.length / limit).ceil(),
            hasNextPage: endIndex < sortedProducts.length,
            hasPreviousPage: page > 1,
            appliedFilters: filters ?? const ProductFilterEntity(),
            searchTime: Duration.zero,
          ));
        }
      } catch (cacheError) {
        // Cache also failed
      }
      
      return Left('Failed to get products: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, Product>> getProductById(String id) async {
    try {
      // Check cache first
      final cachedProduct = await _localDataSource.getCachedProductById(id);
      if (cachedProduct != null) {
        return Right(cachedProduct);
      }

      // Fetch from remote
      final result = await _remoteDataSource.getProductById(id);
      
      if (result.isLeft()) {
        return Left(result.fold((l) => l, (r) => 'Product not found'));
      }

      final product = result.fold((l) => throw Exception(l), (r) => r);
      
      // Cache the product
      await _localDataSource.cacheProduct(product);

      return Right(product);
    } catch (e) {
      // Fallback to cache
      final cachedProduct = await _localDataSource.getCachedProductById(id);
      if (cachedProduct != null) {
        return Right(cachedProduct);
      }
      return Left('Failed to get product: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, ProductSearchResult>> searchProducts(
    String query, {
    ProductFilterEntity? filters,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final searchFilters = filters?.copyWith(searchQuery: query) ?? 
                           ProductFilterEntity(searchQuery: query);
      
      return await getProducts(filters: searchFilters, page: page, limit: limit);
    } catch (e) {
      return Left('Search failed: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, ProductSearchResult>> getProductsByCategory(
    String categoryId, {
    ProductFilterEntity? filters,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final categoryFilters = filters?.copyWith(categories: [categoryId]) ?? 
                             ProductFilterEntity(categories: [categoryId]);
      
      return await getProducts(filters: categoryFilters, page: page, limit: limit);
    } catch (e) {
      return Left('Failed to get products by category: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, ProductSearchResult>> getProductsByBrand(
    String brand, {
    ProductFilterEntity? filters,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final brandFilters = filters?.copyWith(brands: [brand]) ?? 
                          ProductFilterEntity(brands: [brand]);
      
      return await getProducts(filters: brandFilters, page: page, limit: limit);
    } catch (e) {
      return Left('Failed to get products by brand: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, List<Product>>> getFeaturedProducts({int limit = 10}) async {
    try {
      final filters = ProductFilterEntity(
        isActiveOnly: true,
        minRating: 4.0,
        sortBy: 'rating',
        sortOrder: 'desc',
      );
      
      final result = await getProducts(filters: filters, page: 1, limit: limit);
      
      return result.fold(
        (l) => Left(l),
        (r) => Right(r.products),
      );
    } catch (e) {
      return Left('Failed to get featured products: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, List<Product>>> getTrendingProducts({int limit = 10}) async {
    try {
      final result = await _remoteDataSource.getTrendingProducts(limit: limit);
      
      if (result.isLeft()) {
        return Left(result.fold((l) => l, (r) => 'Failed to get trending products'));
      }

      return Right(result.fold((l) => [], (r) => r));
    } catch (e) {
      return Left('Failed to get trending products: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, List<Product>>> getRelatedProducts(
    String productId, {
    int limit = 5,
  }) async {
    try {
      final productResult = await getProductById(productId);
      
      if (productResult.isLeft()) {
        return Left('Product not found');
      }

      final product = productResult.fold((l) => throw Exception(l), (r) => r);
      
      final filters = ProductFilterEntity(
        categories: [product.category],
        brands: [product.brand],
        manufacturers: [product.manufacturer],
        isActiveOnly: true,
        sortBy: 'popularity',
        sortOrder: 'desc',
      );
      
      final result = await getProducts(filters: filters, page: 1, limit: limit + 1);
      
      return result.fold(
        (l) => Left(l),
        (r) => Right(r.products.where((p) => p.id != productId).take(limit).toList()),
      );
    } catch (e) {
      return Left('Failed to get related products: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, List<Product>>> getRecentlyViewedProducts({
    int limit = 10,
  }) async {
    try {
      final recentlyViewedIds = await _localDataSource.getRecentlyViewedProductIds();
      
      if (recentlyViewedIds.isEmpty) {
        return const Right([]);
      }

      final result = await bulkGetProducts(recentlyViewedIds.take(limit).toList());
      
      return result.fold(
        (l) => Left(l),
        (r) => Right(r),
      );
    } catch (e) {
      return Left('Failed to get recently viewed products: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, ProductSearchResult>> getProductsOnSale({
    ProductFilterEntity? filters,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final saleFilters = filters?.copyWith(onSaleOnly: true) ?? 
                         ProductFilterEntity(onSaleOnly: true);
      
      return await getProducts(filters: saleFilters, page: page, limit: limit);
    } catch (e) {
      return Left('Failed to get products on sale: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, ProductSearchResult>> getOutOfStockProducts({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final filters = ProductFilterEntity(
        availability: ProductAvailability.outOfStock,
        sortBy: 'name',
        sortOrder: 'asc',
      );
      
      return await getProducts(filters: filters, page: page, limit: limit);
    } catch (e) {
      return Left('Failed to get out of stock products: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, List<Product>>> getExpiringSoonProducts({
    int days = 30,
    int limit = 20,
  }) async {
    try {
      final result = await _remoteDataSource.getExpiringSoonProducts(days: days, limit: limit);
      
      if (result.isLeft()) {
        return Left(result.fold((l) => l, (r) => 'Failed to get expiring soon products'));
      }

      return Right(result.fold((l) => [], (r) => r));
    } catch (e) {
      return Left('Failed to get expiring soon products: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, List<Product>>> getLowStockProducts({
    int threshold = 10,
    int limit = 20,
  }) async {
    try {
      final result = await _remoteDataSource.getLowStockProducts(threshold: threshold, limit: limit);
      
      if (result.isLeft()) {
        return Left(result.fold((l) => l, (r) => 'Failed to get low stock products'));
      }

      return Right(result.fold((l) => [], (r) => r));
    } catch (e) {
      return Left('Failed to get low stock products: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, List<String>>> getProductSuggestions(String query) async {
    try {
      final result = await _remoteDataSource.getProductSuggestions(query);
      
      if (result.isLeft()) {
        return Left(result.fold((l) => l, (r) => 'Failed to get product suggestions'));
      }

      return Right(result.fold((l) => [], (r) => r));
    } catch (e) {
      return Left('Failed to get product suggestions: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, Map<String, List<String>>>> getFilterOptions() async {
    try {
      final result = await _remoteDataSource.getFilterOptions();
      
      if (result.isLeft()) {
        return Left(result.fold((l) => l, (r) => 'Failed to get filter options'));
      }

      return Right(result.fold((l) => {}, (r) => r));
    } catch (e) {
      return Left('Failed to get filter options: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, void>> addToFavorites(String productId) async {
    try {
      await _localDataSource.addToFavorites(productId);
      await _remoteDataSource.addToFavorites(productId);
      
      return const Right(null);
    } catch (e) {
      return Left('Failed to add to favorites: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, void>> removeFromFavorites(String productId) async {
    try {
      await _localDataSource.removeFromFavorites(productId);
      await _remoteDataSource.removeFromFavorites(productId);
      
      return const Right(null);
    } catch (e) {
      return Left('Failed to remove from favorites: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, List<Product>>> getFavoriteProducts({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final favoriteIds = await _localDataSource.getFavoriteProductIds();
      
      if (favoriteIds.isEmpty) {
        return const Right([]);
      }

      final startIndex = (page - 1) * limit;
      final endIndex = startIndex + limit;
      final paginatedIds = favoriteIds.skip(startIndex).take(endIndex - startIndex).toList();

      final result = await bulkGetProducts(paginatedIds);
      
      return result.fold(
        (l) => Left(l),
        (r) => Right(r),
      );
    } catch (e) {
      return Left('Failed to get favorite products: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, bool>> isProductFavorite(String productId) async {
    try {
      final isFavorite = await _localDataSource.isFavorite(productId);
      return Right(isFavorite);
    } catch (e) {
      return Left('Failed to check favorite status: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, void>> trackProductView(String productId) async {
    try {
      await _localDataSource.trackProductView(productId);
      await _remoteDataSource.trackProductView(productId);
      
      return const Right(null);
    } catch (e) {
      return Left('Failed to track product view: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, List<String>>> getRecentlyViewedProductIds() async {
    try {
      final ids = await _localDataSource.getRecentlyViewedProductIds();
      return Right(ids);
    } catch (e) {
      return Left('Failed to get recently viewed product IDs: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, void>> saveSearchQuery(String query) async {
    try {
      await _localDataSource.saveSearchQuery(query);
      await _remoteDataSource.saveSearchQuery(query);
      
      return const Right(null);
    } catch (e) {
      return Left('Failed to save search query: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, List<String>>> getSearchHistory({int limit = 10}) async {
    try {
      final history = await _localDataSource.getSearchHistory(limit: limit);
      return Right(history);
    } catch (e) {
      return Left('Failed to get search history: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, void>> clearSearchHistory() async {
    try {
      await _localDataSource.clearSearchHistory();
      await _remoteDataSource.clearSearchHistory();
      
      return const Right(null);
    } catch (e) {
      return Left('Failed to clear search history: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, List<ProductReview>>> getProductReviews(
    String productId, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final result = await _remoteDataSource.getProductReviews(
        productId,
        page: page,
        limit: limit,
      );
      
      if (result.isLeft()) {
        return Left(result.fold((l) => l, (r) => 'Failed to get product reviews'));
      }

      return Right(result.fold((l) => [], (r) => r));
    } catch (e) {
      return Left('Failed to get product reviews: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, void>> addProductReview(
    String productId,
    ProductReview review,
  ) async {
    try {
      await _remoteDataSource.addProductReview(productId, review);
      
      return const Right(null);
    } catch (e) {
      return Left('Failed to add product review: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, void>> updateProductReview(
    String productId,
    String reviewId,
    ProductReview review,
  ) async {
    try {
      await _remoteDataSource.updateProductReview(productId, reviewId, review);
      
      return const Right(null);
    } catch (e) {
      return Left('Failed to update product review: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, void>> deleteProductReview(
    String productId,
    String reviewId,
  ) async {
    try {
      await _remoteDataSource.deleteProductReview(productId, reviewId);
      
      return const Right(null);
    } catch (e) {
      return Left('Failed to delete product review: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, ProductRatingSummary>> getProductRatingSummary(String productId) async {
    try {
      final result = await _remoteDataSource.getProductRatingSummary(productId);
      
      if (result.isLeft()) {
        return Left(result.fold((l) => l, (r) => 'Failed to get product rating summary'));
      }

      return Right(result.fold((l) => throw Exception(l), (r) => r));
    } catch (e) {
      return Left('Failed to get product rating summary: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, void>> reportProductIssue(
    String productId,
    ProductIssueReport report,
  ) async {
    try {
      await _remoteDataSource.reportProductIssue(productId, report);
      
      return const Right(null);
    } catch (e) {
      return Left('Failed to report product issue: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, ProductStockInfo>> getProductStockInfo(String productId) async {
    try {
      final result = await _remoteDataSource.getProductStockInfo(productId);
      
      if (result.isLeft()) {
        return Left(result.fold((l) => l, (r) => 'Failed to get product stock info'));
      }

      return Right(result.fold((l) => throw Exception(l), (r) => r));
    } catch (e) {
      return Left('Failed to get product stock info: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, void>> updateProductStock(
    String productId,
    int quantity,
  ) async {
    try {
      await _remoteDataSource.updateProductStock(productId, quantity);
      
      // Clear cache to refresh data
      await _localDataSource.clearProductCache();
      
      return const Right(null);
    } catch (e) {
      return Left('Failed to update product stock: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, List<ProductVariant>>> getProductVariants(String productId) async {
    try {
      final result = await _remoteDataSource.getProductVariants(productId);
      
      if (result.isLeft()) {
        return Left(result.fold((l) => l, (r) => 'Failed to get product variants'));
      }

      return Right(result.fold((l) => [], (r) => r));
    } catch (e) {
      return Left('Failed to get product variants: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, List<Product>>> getProductComparison(
    List<String> productIds,
  ) async {
    try {
      final result = await bulkGetProducts(productIds);
      
      return result.fold(
        (l) => Left(l),
        (r) => Right(r),
      );
    } catch (e) {
      return Left('Failed to get product comparison: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, void>> addToComparison(String productId) async {
    try {
      await _localDataSource.addToComparison(productId);
      
      return const Right(null);
    } catch (e) {
      return Left('Failed to add to comparison: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, void>> removeFromComparison(String productId) async {
    try {
      await _localDataSource.removeFromComparison(productId);
      
      return const Right(null);
    } catch (e) {
      return Left('Failed to remove from comparison: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, List<Product>>> getComparisonList() async {
    try {
      final comparisonIds = await _localDataSource.getComparisonProductIds();
      
      if (comparisonIds.isEmpty) {
        return const Right([]);
      }

      final result = await bulkGetProducts(comparisonIds);
      
      return result.fold(
        (l) => Left(l),
        (r) => Right(r),
      );
    } catch (e) {
      return Left('Failed to get comparison list: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, void>> clearComparisonList() async {
    try {
      await _localDataSource.clearComparisonList();
      
      return const Right(null);
    } catch (e) {
      return Left('Failed to clear comparison list: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, void>> bulkAddToFavorites(List<String> productIds) async {
    try {
      await _localDataSource.bulkAddToFavorites(productIds);
      await _remoteDataSource.bulkAddToFavorites(productIds);
      
      return const Right(null);
    } catch (e) {
      return Left('Failed to bulk add to favorites: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, void>> bulkRemoveFromFavorites(List<String> productIds) async {
    try {
      await _localDataSource.bulkRemoveFromFavorites(productIds);
      await _remoteDataSource.bulkRemoveFromFavorites(productIds);
      
      return const Right(null);
    } catch (e) {
      return Left('Failed to bulk remove from favorites: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, List<Product>>> bulkGetProducts(List<String> productIds) async {
    try {
      final result = await _remoteDataSource.bulkGetProducts(productIds);
      
      if (result.isLeft()) {
        return Left(result.fold((l) => l, (r) => 'Failed to bulk get products'));
      }

      return Right(result.fold((l) => [], (r) => r));
    } catch (e) {
      return Left('Failed to bulk get products: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, void>> clearProductCache() async {
    try {
      await _localDataSource.clearProductCache();
      
      return const Right(null);
    } catch (e) {
      return Left('Failed to clear product cache: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, void>> preloadPopularProducts() async {
    try {
      final result = await _remoteDataSource.getPopularProducts(limit: 50);
      
      if (result.isLeft()) {
        return Left(result.fold((l) => l, (r) => 'Failed to preload popular products'));
      }

      final products = result.fold((l) => [], (r) => r);
      await _localDataSource.cacheProducts(products);
      
      return const Right(null);
    } catch (e) {
      return Left('Failed to preload popular products: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, void>> syncProducts() async {
    try {
      await _remoteDataSource.syncProducts();
      await _localDataSource.clearProductCache();
      
      return const Right(null);
    } catch (e) {
      return Left('Failed to sync products: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, bool>> isProductDataFresh() async {
    try {
      final isFresh = await _localDataSource.isProductDataFresh();
      return Right(isFresh);
    } catch (e) {
      return Left('Failed to check product data freshness: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, ProductAnalytics>> getProductAnalytics() async {
    try {
      final result = await _remoteDataSource.getProductAnalytics();
      
      if (result.isLeft()) {
        return Left(result.fold((l) => l, (r) => 'Failed to get product analytics'));
      }

      return Right(result.fold((l) => throw Exception(l), (r) => r));
    } catch (e) {
      return Left('Failed to get product analytics: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, List<String>>> getPopularSearchTerms() async {
    try {
      final result = await _remoteDataSource.getPopularSearchTerms();
      
      if (result.isLeft()) {
        return Left(result.fold((l) => l, (r) => 'Failed to get popular search terms'));
      }

      return Right(result.fold((l) => [], (r) => r));
    } catch (e) {
      return Left('Failed to get popular search terms: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, List<String>>> getTrendingCategories() async {
    try {
      final result = await _remoteDataSource.getTrendingCategories();
      
      if (result.isLeft()) {
        return Left(result.fold((l) => l, (r) => 'Failed to get trending categories'));
      }

      return Right(result.fold((l) => [], (r) => r));
    } catch (e) {
      return Left('Failed to get trending categories: ${e.toString()}');
    }
  }

  // Private helper methods

  /// Apply filters to product list
  List<Product> _applyFilters(List<Product> products, ProductFilterEntity? filter) {
    if (filter == null || !filter.hasActiveFilters) return products;

    var filteredProducts = products;

    // Search query filter
    if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) {
      final searchQuery = filter.searchQuery!.toLowerCase();
      filteredProducts = filteredProducts.where((product) {
        return product.name.toLowerCase().contains(searchQuery) ||
               product.description.toLowerCase().contains(searchQuery) ||
               product.brand.toLowerCase().contains(searchQuery) ||
               product.manufacturer.toLowerCase().contains(searchQuery) ||
               product.sku.toLowerCase().contains(searchQuery) ||
               product.tags.any((tag) => tag.toLowerCase().contains(searchQuery));
      }).toList();
    }

    // Category filter
    if (filter.categories.isNotEmpty) {
      filteredProducts = filteredProducts
          .where((p) => filter.categories.contains(p.category))
          .toList();
    }

    // Brand filter
    if (filter.brands.isNotEmpty) {
      filteredProducts = filteredProducts
          .where((p) => filter.brands.contains(p.brand))
          .toList();
    }

    // Manufacturer filter
    if (filter.manufacturers.isNotEmpty) {
      filteredProducts = filteredProducts
          .where((p) => filter.manufacturers.contains(p.manufacturer))
          .toList();
    }

    // Dosage form filter
    if (filter.dosageForms.isNotEmpty) {
      filteredProducts = filteredProducts
          .where((p) => filter.dosageForms.contains(p.formulation))
          .toList();
    }

    // Tags filter
    if (filter.tags.isNotEmpty) {
      filteredProducts = filteredProducts
          .where((p) => filter.tags.any((tag) => p.tags.contains(tag)))
          .toList();
    }

    // Price range filter
    if (filter.minPrice != null) {
      filteredProducts = filteredProducts
          .where((p) => p.effectivePrice >= filter.minPrice!)
          .toList();
    }

    if (filter.maxPrice != null) {
      filteredProducts = filteredProducts
          .where((p) => p.effectivePrice <= filter.maxPrice!)
          .toList();
    }

    // Stock filter
    if (filter.inStockOnly == true) {
      filteredProducts = filteredProducts
          .where((p) => p.isInStock)
          .toList();
    }

    // Sale filter
    if (filter.onSaleOnly == true) {
      filteredProducts = filteredProducts
          .where((p) => p.isOnSale)
          .toList();
    }

    // Prescription filter
    if (filter.requiresPrescription != null) {
      filteredProducts = filteredProducts
          .where((p) => p.requiresPrescription == filter.requiresPrescription)
          .toList();
    }

    // Availability filter
    if (filter.availability != null) {
      filteredProducts = filteredProducts
          .where((p) => p.availability == filter.availability)
          .toList();
    }

    // Rating filter
    if (filter.minRating != null) {
      filteredProducts = filteredProducts
          .where((p) => (p.rating ?? 0) >= filter.minRating!)
          .toList();
    }

    // Active filter
    if (filter.isActiveOnly == true) {
      filteredProducts = filteredProducts
          .where((p) => p.isActive)
          .toList();
    }

    // Expiry date range filter
    if (filter.expiryDateRangeStart != null) {
      filteredProducts = filteredProducts
          .where((p) => p.expiryDate != null && p.expiryDate!.isAfter(filter.expiryDateRangeStart!))
          .toList();
    }

    if (filter.expiryDateRangeEnd != null) {
      filteredProducts = filteredProducts
          .where((p) => p.expiryDate != null && p.expiryDate!.isBefore(filter.expiryDateRangeEnd!))
          .toList();
    }

    return filteredProducts;
  }

  /// Apply sorting to product list
  List<Product> _applySorting(List<Product> products, ProductFilterEntity? filter) {
    if (filter == null || filter.sortBy == null) return products;

    final sortBy = filter.sortBy!;
    final sortOrder = filter.sortOrder ?? 'asc';

    switch (sortBy) {
      case 'name':
        products.sort((a, b) => sortOrder == 'asc' 
            ? a.name.compareTo(b.name)
            : b.name.compareTo(a.name));
        break;
      case 'price':
        products.sort((a, b) => sortOrder == 'asc'
            ? a.effectivePrice.compareTo(b.effectivePrice)
            : b.effectivePrice.compareTo(a.effectivePrice));
        break;
      case 'rating':
        products.sort((a, b) => sortOrder == 'asc'
            ? (a.rating ?? 0).compareTo(b.rating ?? 0)
            : (b.rating ?? 0).compareTo(a.rating ?? 0));
        break;
      case 'createdAt':
        products.sort((a, b) => sortOrder == 'asc'
            ? a.createdAt.compareTo(b.createdAt)
            : b.createdAt.compareTo(a.createdAt));
        break;
      case 'stockQuantity':
        products.sort((a, b) => sortOrder == 'asc'
            ? a.stockQuantity.compareTo(b.stockQuantity)
            : b.stockQuantity.compareTo(a.stockQuantity));
        break;
      case 'popularity':
        // This would need to be implemented based on actual popularity data
        products.sort((a, b) => sortOrder == 'asc'
            ? (a.reviewCount ?? 0).compareTo(b.reviewCount ?? 0)
            : (b.reviewCount ?? 0).compareTo(a.reviewCount ?? 0));
        break;
      default:
        break;
    }

    return products;
  }

  // Additional method implementations would go here...
  @override
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
  }) async {
    final filters = ProductFilterEntity(
      searchQuery: query,
      categories: categories ?? [],
      brands: brands ?? [],
      manufacturers: manufacturers ?? [],
      tags: tags ?? [],
      minPrice: minPrice,
      maxPrice: maxPrice,
      inStockOnly: inStockOnly,
      onSaleOnly: onSaleOnly,
      minRating: minRating,
      sortBy: sortBy,
      sortOrder: sortOrder,
    );

    return await getProducts(filters: filters, page: page, limit: limit);
  }

  @override
  Future<Either<String, ProductSearchResult>> getProductsByManufacturer(
    String manufacturer, {
    ProductFilterEntity? filters,
    int page = 1,
    int limit = 20,
  }) async {
    final manufacturerFilters = filters?.copyWith(manufacturers: [manufacturer]) ?? 
                                ProductFilterEntity(manufacturers: [manufacturer]);
    
    return await getProducts(filters: manufacturerFilters, page: page, limit: limit);
  }

  @override
  Future<Either<String, ProductSearchResult>> getProductsByDosageForm(
    String dosageForm, {
    ProductFilterEntity? filters,
    int page = 1,
    int limit = 20,
  }) async {
    final dosageFilters = filters?.copyWith(dosageForms: [dosageForm]) ?? 
                          ProductFilterEntity(dosageForms: [dosageForm]);
    
    return await getProducts(filters: dosageFilters, page: page, limit: limit);
  }

  @override
  Future<Either<String, ProductSearchResult>> getProductsByTags(
    List<String> tags, {
    ProductFilterEntity? filters,
    int page = 1,
    int limit = 20,
  }) async {
    final tagFilters = filters?.copyWith(tags: tags) ?? 
                      ProductFilterEntity(tags: tags);
    
    return await getProducts(filters: tagFilters, page: page, limit: limit);
  }

  @override
  Future<Either<String, ProductSearchResult>> getProductsByPriceRange(
    double minPrice,
    double maxPrice, {
    ProductFilterEntity? filters,
    int page = 1,
    int limit = 20,
  }) async {
    final priceFilters = filters?.copyWith(minPrice: minPrice, maxPrice: maxPrice) ?? 
                        ProductFilterEntity(minPrice: minPrice, maxPrice: maxPrice);
    
    return await getProducts(filters: priceFilters, page: page, limit: limit);
  }

  @override
  Future<Either<String, ProductSearchResult>> getProductsByRating(
    double minRating, {
    ProductFilterEntity? filters,
    int page = 1,
    int limit = 20,
  }) async {
    final ratingFilters = filters?.copyWith(minRating: minRating) ?? 
                         ProductFilterEntity(minRating: minRating);
    
    return await getProducts(filters: ratingFilters, page: page, limit: limit);
  }

  @override
  Future<Either<String, ProductSearchResult>> getProductsByAvailability(
    ProductAvailability availability, {
    ProductFilterEntity? filters,
    int page = 1,
    int limit = 20,
  }) async {
    final availabilityFilters = filters?.copyWith(availability: availability) ?? 
                               ProductFilterEntity(availability: availability);
    
    return await getProducts(filters: availabilityFilters, page: page, limit: limit);
  }

  @override
  Future<Either<String, List<Product>>> getNewArrivals({int limit = 10}) async {
    final filters = ProductFilterEntity(
      isActiveOnly: true,
      sortBy: 'createdAt',
      sortOrder: 'desc',
    );
    
    final result = await getProducts(filters: filters, page: 1, limit: limit);
    
    return result.fold(
      (l) => Left(l),
      (r) => Right(r.products),
    );
  }

  @override
  Future<Either<String, List<Product>>> getBestSellers({int limit = 10}) async {
    final result = await _remoteDataSource.getBestSellers(limit: limit);
    
    return result.fold(
      (l) => Left(l),
      (r) => Right(r),
    );
  }

  @override
  Future<Either<String, List<Product>>> getRecommendedProducts({
    String? userId,
    int limit = 10,
  }) async {
    final result = await _remoteDataSource.getRecommendedProducts(userId: userId, limit: limit);
    
    return result.fold(
      (l) => Left(l),
      (r) => Right(r),
    );
  }

  @override
  Future<Either<String, List<Product>>> getSimilarProducts(
    String productId, {
    int limit = 5,
  }) async {
    final result = await _remoteDataSource.getSimilarProducts(productId, limit: limit);
    
    return result.fold(
      (l) => Left(l),
      (r) => Right(r),
    );
  }

  @override
  Future<Either<String, List<Product>>> getFrequentlyBoughtTogether(
    String productId, {
    int limit = 5,
  }) async {
    final result = await _remoteDataSource.getFrequentlyBoughtTogether(productId, limit: limit);
    
    return result.fold(
      (l) => Left(l),
      (r) => Right(r),
    );
  }

  @override
  Future<Either<String, List<ProductCategory>>> getProductCategoriesWithCounts() async {
    final result = await _remoteDataSource.getProductCategoriesWithCounts();
    
    return result.fold(
      (l) => Left(l),
      (r) => Right(r),
    );
  }

  @override
  Future<Either<String, List<ProductBrand>>> getProductBrandsWithCounts() async {
    final result = await _remoteDataSource.getProductBrandsWithCounts();
    
    return result.fold(
      (l) => Left(l),
      (r) => Right(r),
    );
  }

  @override
  Future<Either<String, List<ProductManufacturer>>> getProductManufacturersWithCounts() async {
    final result = await _remoteDataSource.getProductManufacturersWithCounts();
    
    return result.fold(
      (l) => Left(l),
      (r) => Right(r),
    );
  }

  @override
  Future<Either<String, List<ProductDosageForm>>> getProductDosageFormsWithCounts() async {
    final result = await _remoteDataSource.getProductDosageFormsWithCounts();
    
    return result.fold(
      (l) => Left(l),
      (r) => Right(r),
    );
  }

  @override
  Future<Either<String, List<ProductTag>>> getPopularTagsWithCounts() async {
    final result = await _remoteDataSource.getPopularTagsWithCounts();
    
    return result.fold(
      (l) => Left(l),
      (r) => Right(r),
    );
  }

  @override
  Future<Either<String, ProductStatistics>> getProductStatistics() async {
    final result = await _remoteDataSource.getProductStatistics();
    
    return result.fold(
      (l) => Left(l),
      (r) => Right(r),
    );
  }

  @override
  Future<Either<String, void>> updateProductPopularity(
    String productId,
    double score,
  ) async {
    await _remoteDataSource.updateProductPopularity(productId, score);
    return const Right(null);
  }

  @override
  Future<Either<String, List<ProductPriceHistory>>> getProductPriceHistory(
    String productId, {
    int days = 30,
  }) async {
    final result = await _remoteDataSource.getProductPriceHistory(productId, days: days);
    
    return result.fold(
      (l) => Left(l),
      (r) => Right(r),
    );
  }

  @override
  Future<Either<String, List<ProductStockHistory>>> getProductStockHistory(
    String productId, {
    int days = 30,
  }) async {
    final result = await _remoteDataSource.getProductStockHistory(productId, days: days);
    
    return result.fold(
      (l) => Left(l),
      (r) => Right(r),
    );
  }

  @override
  Future<Either<String, List<ProductViewHistory>>> getProductViewHistory(
    String productId, {
    int days = 30,
  }) async {
    final result = await _remoteDataSource.getProductViewHistory(productId, days: days);
    
    return result.fold(
      (l) => Left(l),
      (r) => Right(r),
    );
  }

  @override
  Future<Either<String, String>> exportProducts({
    ProductFilterEntity? filters,
    String format = 'csv',
  }) async {
    final result = await _remoteDataSource.exportProducts(filters: filters, format: format);
    
    return result.fold(
      (l) => Left(l),
      (r) => Right(r),
    );
  }

  @override
  Future<Either<String, void>> importProducts(
    String filePath, {
    bool overwrite = false,
  }) async {
    await _remoteDataSource.importProducts(filePath, overwrite: overwrite);
    await _localDataSource.clearProductCache();
    return const Right(null);
  }

  @override
  Future<Either<String, List<ProductValidationError>>> validateProductData(
    List<Map<String, dynamic>> productsData,
  ) async {
    final result = await _remoteDataSource.validateProductData(productsData);
    
    return result.fold(
      (l) => Left(l),
      (r) => Right(r),
    );
  }

  @override
  Future<Either<String, void>> bulkUpdateProducts(
    List<Product> products,
  ) async {
    await _remoteDataSource.bulkUpdateProducts(products);
    await _localDataSource.clearProductCache();
    return const Right(null);
  }

  @override
  Future<Either<String, void>> bulkDeleteProducts(List<String> productIds) async {
    await _remoteDataSource.bulkDeleteProducts(productIds);
    await _localDataSource.clearProductCache();
    return const Right(null);
  }

  @override
  Future<Either<String, void>> archiveProducts(List<String> productIds) async {
    await _remoteDataSource.archiveProducts(productIds);
    await _localDataSource.clearProductCache();
    return const Right(null);
  }

  @override
  Future<Either<String, void>> restoreArchivedProducts(List<String> productIds) async {
    await _remoteDataSource.restoreArchivedProducts(productIds);
    await _localDataSource.clearProductCache();
    return const Right(null);
  }

  @override
  Future<Either<String, ProductSearchResult>> getArchivedProducts({
    int page = 1,
    int limit = 20,
  }) async {
    final result = await _remoteDataSource.getArchivedProducts(page: page, limit: limit);
    
    return result.fold(
      (l) => Left(l),
      (r) => Right(r),
    );
  }

  @override
  Future<Either<String, ProductSearchResult>> searchArchivedProducts(
    String query, {
    int page = 1,
    int limit = 20,
  }) async {
    final result = await _remoteDataSource.searchArchivedProducts(query, page: page, limit: limit);
    
    return result.fold(
      (l) => Left(l),
      (r) => Right(r),
    );
  }
}
