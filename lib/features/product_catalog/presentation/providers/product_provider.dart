import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../domain/models/product_entity.dart';
import '../../domain/models/product_filter.dart';
import '../../domain/repositories/product_repository.dart';
import '../../data/repositories/product_repository_impl.dart';

class ProductProvider extends ChangeNotifier {
  final ProductRepository _repository;
  
  List<ProductEntity> _products = [];
  List<ProductEntity> _filteredProducts = [];
  ProductFilter _filter = const ProductFilter();
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  int _totalPages = 1;
  final int _itemsPerPage = 20;

  ProductProvider({required ProductRepository repository})
      : _repository = repository;

  // Getters
  List<ProductEntity> get products => _filteredProducts;
  bool get isLoading => _isLoading;
  String? get error => _error;
  ProductFilter get filter => _filter;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get totalItems => _products.length;
  bool get hasNextPage => _currentPage < _totalPages;
  bool get hasPreviousPage => _currentPage > 1;

  // Initialize
  Future<void> initialize() async {
    await loadProducts();
  }

  // Load products
  Future<void> loadProducts({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
    }
    
    _setLoading(true);
    _clearError();
    
    try {
      final result = await _repository.getProducts(
        filter: _filter,
        page: _currentPage,
        limit: _itemsPerPage,
      );
      
      if (_currentPage == 1) {
        _products = result;
      } else {
        _products.addAll(result);
      }
      
      _filteredProducts = _products;
      _calculateTotalPages();
      _notifyListeners();
    } catch (e) {
      _setError('Failed to load products: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load more products (pagination)
  Future<void> loadMoreProducts() async {
    if (hasNextPage && !_isLoading) {
      _currentPage++;
      await loadProducts();
    }
  }

  // Refresh products
  Future<void> refreshProducts() async {
    await loadProducts(refresh: true);
  }

  // Apply filter
  Future<void> applyFilter(ProductFilter newFilter) async {
    _filter = newFilter;
    _currentPage = 1;
    await loadProducts();
  }

  // Update search query
  Future<void> updateSearchQuery(String query) async {
    final newFilter = _filter.copyWithSearch(query);
    await applyFilter(newFilter);
  }

  // Update category filter
  Future<void> updateCategoryFilter(ProductCategory category) async {
    final newFilter = _filter.copyWithCategory(category);
    await applyFilter(newFilter);
  }

  // Update price range filter
  Future<void> updatePriceRangeFilter(double minPrice, double maxPrice) async {
    final newFilter = _filter.copyWithPriceRange(minPrice, maxPrice);
    await applyFilter(newFilter);
  }

  // Update sort option
  Future<void> updateSortOption(ProductSortOption sortBy) async {
    final newFilter = _filter.copyWithSort(sortBy);
    await applyFilter(newFilter);
  }

  // Clear all filters
  Future<void> clearFilters() async {
    final newFilter = _filter.clear();
    await applyFilter(newFilter);
  }

  // Get product by ID
  Future<ProductEntity?> getProductById(String id) async {
    return await _repository.getProductById(id);
  }

  // Search products
  Future<void> searchProducts(String query) async {
    await updateSearchQuery(query);
  }

  // Get categories
  Future<List<String>> getCategories() async {
    return await _repository.getCategories();
  }

  // Get manufacturers
  Future<List<String>> getManufacturers() async {
    return await _repository.getManufacturers();
  }

  // Get tags
  Future<List<String>> getTags() async {
    return await _repository.getTags();
  }

  // Toggle favorite
  Future<void> toggleFavorite(String productId) async {
    try {
      final isFavorite = await _repository.isFavorite(productId);
      if (isFavorite) {
        await _repository.removeFromFavorites(productId);
      } else {
        await _repository.addToFavorites(productId);
      }
      await refreshProducts();
    } catch (e) {
      _setError('Failed to toggle favorite: $e');
    }
  }

  // Track product view
  Future<void> trackProductView(String productId) async {
    try {
      await _repository.trackProductView(productId);
    } catch (e) {
      // Silently fail for tracking
    }
  }

  // Get favorite products
  Future<List<ProductEntity>> getFavoriteProducts() async {
    return await _repository.getFavoriteProducts();
  }

  // Get recently viewed products
  Future<List<ProductEntity>> getRecentlyViewedProducts() async {
    return await _repository.getRecentlyViewedProducts();
  }

  // Rate product
  Future<void> rateProduct(String productId, double rating, String? review) async {
    try {
      await _repository.rateProduct(productId, rating, review);
      await refreshProducts();
    } catch (e) {
      _setError('Failed to rate product: $e');
    }
  }

  // Get featured products
  Future<List<ProductEntity>> getFeaturedProducts() async {
    return await _repository.getFeaturedProducts();
  }

  // Get discounted products
  Future<List<ProductEntity>> getDiscountedProducts() async {
    return await _repository.getDiscountedProducts();
  }

  // Get expiring soon products
  Future<List<ProductEntity>> getExpiringSoonProducts() async {
    return await _repository.getExpiringSoonProducts();
  }

  // Get low stock products
  Future<List<ProductEntity>> getLowStockProducts() async {
    return await _repository.getLowStockProducts();
  }

  // Private methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    _notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    _notifyListeners();
  }

  void _clearError() {
    _error = null;
    _notifyListeners();
  }

  void _calculateTotalPages() {
    _totalPages = (_products.length / _itemsPerPage).ceil();
  }

  void _notifyListeners() {
    if (!hasListeners) return;
    notifyListeners();
  }
}
