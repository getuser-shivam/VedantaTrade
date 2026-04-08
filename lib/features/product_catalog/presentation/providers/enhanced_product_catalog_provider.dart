import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../../data/models/product_model.dart';
import '../../data/services/product_catalog_service.dart';
import '../../data/services/product_cache_service.dart';
import '../../data/services/product_preferences_service.dart';
import '../../domain/models/product_entity.dart';
import '../../domain/models/product_category.dart';
import '../../domain/entities/product_filter_entity.dart';

enum ViewMode { grid, list }

class EnhancedProductCatalogProvider extends ChangeNotifier {
  final ProductCatalogService _productService = ProductCatalogService();
  final ProductCacheService _cacheService = ProductCacheService();
  final ProductPreferencesService _preferencesService = ProductPreferencesService();

  // State management
  List<Product> _allProducts = [];
  List<Product> _products = [];
  List<ProductCategory> _categories = [];
  List<String> _brands = [];
  List<String> _manufacturers = [];
  List<String> _tags = [];
  List<Product> _filteredProducts = [];
  Product? _selectedProduct;
  ProductCategory? _selectedCategory;
  
  // Loading states
  bool _isLoading = false;
  bool _isLoadingCategories = false;
  bool _isLoadingMore = false;
  String? _errorMessage;
  
  // Search and filter
  ProductFilterEntity _filter = const ProductFilterEntity();
  String _searchQuery = '';
  List<String> _searchSuggestions = [];
  List<String> _recentSearches = [];
  
  // Favorites and Comparison
  final List<String> _favoriteProductIds = [];
  final List<String> _comparisonProductIds = [];
  final Map<String, bool> _productFavorites = {};

  // Pagination
  int _currentPage = 1;
  int _totalPages = 1;
  final int _pageSize = 20;
  bool _hasMore = true;
  ViewMode _viewMode = ViewMode.grid;
  int _currentTabIndex = 0;

  // Getters
  List<Product> get products => _filteredProducts.isEmpty ? _products : _filteredProducts;
  List<Product> get allProducts => _allProducts;
  List<ProductCategory> get categories => _categories;
  List<String> get brands => _brands;
  List<String> get manufacturers => _manufacturers;
  List<String> get tags => _tags;
  Product? get selectedProduct => _selectedProduct;
  ProductCategory? get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  bool get isLoadingCategories => _isLoadingCategories;
  bool get isLoadingMore => _isLoadingMore;
  String? get errorMessage => _errorMessage;
  
  ProductFilterEntity get filter => _filter;
  String get searchQuery => _searchQuery;
  List<String> get searchSuggestions => _searchSuggestions;
  List<String> get recentSearches => _recentSearches;
  bool get hasActiveFilters => _filter.hasActiveFilters || _searchQuery.isNotEmpty;
  
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  bool get hasMore => _hasMore;
  ViewMode get viewMode => _viewMode;
  int get currentTabIndex => _currentTabIndex;

  // Computed properties
  List<Product> get featuredProducts => _products.where((p) => p.rating >= 4.5).toList();
  List<Product> get lowStockProducts => _products.where((p) => p.isLowStock).toList();
  List<Product> get expiringSoonProducts => _products.where((p) => p.isExpiringSoon).toList();
  List<Product> get outOfStockProducts => _products.where((p) => p.stockQuantity == 0).toList();
  List<Product> get favoriteProducts => _products.where((p) => _favoriteProductIds.contains(p.id)).toList();
  List<Product> get comparisonProducts => _products.where((p) => _comparisonProductIds.contains(p.id)).toList();
  
  int get totalProducts => _allProducts.length;
  int get filteredProductsCount => _filteredProducts.length;
  bool get hasError => _errorMessage != null;

  double get averageRating => _products.isEmpty ? 0.0 : 
    _products.map((p) => p.rating).reduce((a, b) => a + b) / _products.length;

  // Initialize data
  Future<void> initialize() async {
    await Future.wait([
      loadCategories(),
      loadProducts(),
      loadFilterOptions(),
      _loadFavoritesFromStorage(),
      _loadComparisonFromStorage(),
      _loadRecentSearchesFromStorage(),
    ]);
  }

  // Load favorites from persistent storage
  Future<void> _loadFavoritesFromStorage() async {
    try {
      final favoriteIds = await _preferencesService.getFavorites();
      _favoriteProductIds.clear();
      _favoriteProductIds.addAll(favoriteIds);
      
      // Update product favorites map
      for (final id in favoriteIds) {
        _productFavorites[id] = true;
      }
    } catch (e) {
      debugPrint('Error loading favorites from storage: $e');
    }
  }

  // Load comparison from persistent storage
  Future<void> _loadComparisonFromStorage() async {
    try {
      final comparisonIds = await _preferencesService.getComparison();
      _comparisonProductIds.clear();
      _comparisonProductIds.addAll(comparisonIds);
    } catch (e) {
      debugPrint('Error loading comparison from storage: $e');
    }
  }

  // Load recent searches from persistent storage
  Future<void> _loadRecentSearchesFromStorage() async {
    try {
      _recentSearches = await _preferencesService.getRecentSearches();
    } catch (e) {
      debugPrint('Error loading recent searches from storage: $e');
    }
  }

  // Load products
  Future<void> loadProducts({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      _allProducts.clear();
      _products.clear();
    }

    if (_isLoading && !refresh) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Try to load from cache first if not refreshing
      if (!refresh) {
        final cachedProducts = await _cacheService.getCachedProducts();
        if (cachedProducts != null && cachedProducts.isNotEmpty) {
          _allProducts = cachedProducts;
          _products = cachedProducts;
          _applyFilters();
          _isLoading = false;
          notifyListeners();
          return;
        }
      }

      // Load from API
      final newProducts = await _productService.loadRegisteredProducts(
        category: _filter.categories.isNotEmpty ? _filter.categories.first : null,
        token: null, // TODO: Get from AuthProvider
      );

      if (refresh) {
        _allProducts = newProducts;
        _products = newProducts;
      } else {
        _allProducts.addAll(newProducts);
        _products.addAll(newProducts);
      }

      // Cache the products
      await _cacheService.cacheProducts(_allProducts);

      _applyFilters();
      
      _currentPage++;
      _hasMore = newProducts.length >= _pageSize;
    } catch (e) {
      _errorMessage = 'Failed to load products: ${e.toString()}';
      
      // Try to load from cache as fallback
      final cachedProducts = await _cacheService.getCachedProducts();
      if (cachedProducts != null) {
        _allProducts = cachedProducts;
        _products = cachedProducts;
        _applyFilters();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load categories
  Future<void> loadCategories() async {
    if (_isLoadingCategories) return;

    _isLoadingCategories = true;
    notifyListeners();

    try {
      _categories = await _productService.loadCategories();
    } catch (e) {
      _errorMessage = 'Failed to load categories: ${e.toString()}';
    } finally {
      _isLoadingCategories = false;
      notifyListeners();
    }
  }

  // Load filter options
  Future<void> loadFilterOptions() async {
    try {
      // Extract unique values from products
      final allProducts = await _productService.loadRegisteredProducts();
      
      _brands = allProducts
          .map((p) => p.brand)
          .where((brand) => brand.isNotEmpty)
          .toSet()
          .toList()
        ..sort();
      
      _manufacturers = allProducts
          .map((p) => p.manufacturer)
          .where((manufacturer) => manufacturer.isNotEmpty)
          .toSet()
          .toList()
        ..sort();
      
      _tags = allProducts
          .expand((p) => p.tags)
          .where((tag) => tag.isNotEmpty)
          .toSet()
          .toList()
        ..sort();
    } catch (e) {
      // Handle error gracefully
    }
  }

  // Search functionality
  Future<void> searchProducts(String query) async {
    _searchQuery = query.toLowerCase().trim();
    
    if (_searchQuery.isEmpty) {
      _searchSuggestions.clear();
      _applyFilters();
      return;
    }

    _generateSearchSuggestions(_searchQuery);
    _applyFilters();
    await _addToRecentSearches(query);
  }

  void _generateSearchSuggestions(String query) {
    final suggestions = <String>[];
    
    // Product name suggestions
    for (final product in _allProducts) {
      if (product.name.toLowerCase().contains(query)) {
        suggestions.add(product.name);
      }
    }
    
    // Category suggestions
    for (final category in _categories) {
      if (category.name.toLowerCase().contains(query)) {
        suggestions.add(category.name);
      }
    }
    
    // Brand suggestions
    for (final brand in _brands) {
      if (brand.toLowerCase().contains(query)) {
        suggestions.add(brand);
      }
    }
    
    _searchSuggestions = suggestions.toSet().take(8).toList();
  }

  List<String> getSearchSuggestions(String query, int maxCount) {
    if (query.isEmpty) return _recentSearches.take(maxCount).toList();
    
    final suggestions = <String>[];
    
    // Product name suggestions
    for (final product in _allProducts) {
      if (product.name.toLowerCase().contains(query.toLowerCase())) {
        suggestions.add(product.name);
      }
    }
    
    // Category suggestions
    for (final category in _categories) {
      if (category.name.toLowerCase().contains(query.toLowerCase())) {
        suggestions.add(category.name);
      }
    }
    
    // Brand suggestions
    for (final brand in _brands) {
      if (brand.toLowerCase().contains(query.toLowerCase())) {
        suggestions.add(brand);
      }
    }
    
    return suggestions.toSet().take(maxCount).toList();
  }

  void _loadRecentSearches() {
    // Load from secure storage
    _recentSearches = [
      'Paracetamol 500mg',
      'Amoxicillin',
      'Vitamin C',
      'Blood Pressure Monitor',
      'Surgical Gloves',
    ];
  }

  Future<void> _addToRecentSearches(String query) async {
    _recentSearches.remove(query);
    _recentSearches.insert(0, query);
    if (_recentSearches.length > 10) {
      _recentSearches.removeLast();
    }
    await _preferencesService.addRecentSearch(query);
  }

  // Filter functionality
  void updateFilters(ProductFilterEntity newFilter) {
    _filter = newFilter;
    _applyFilters();
  }

  void _applyFilters() {
    _filteredProducts = _allProducts.where((product) {
      // Search query filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesName = product.name.toLowerCase().contains(query);
        final matchesDescription = product.description.toLowerCase().contains(query);
        final matchesBrand = product.brand.toLowerCase().contains(query);
        final matchesCategory = product.category.toLowerCase().contains(query);
        final matchesTags = product.tags.any((tag) => tag.toLowerCase().contains(query));
        
        if (!matchesName && !matchesDescription && !matchesBrand && !matchesCategory && !matchesTags) {
          return false;
        }
      }
      
      // Category filter
      if (_filter.categories.isNotEmpty) {
        if (!_filter.categories.contains(product.category)) {
          return false;
        }
      }
      
      // Brand filter
      if (_filter.brands.isNotEmpty) {
        if (!_filter.brands.contains(product.brand)) {
          return false;
        }
      }
      
      // Manufacturer filter
      if (_filter.manufacturers.isNotEmpty) {
        if (!_filter.manufacturers.contains(product.manufacturer)) {
          return false;
        }
      }
      
      // Tags filter
      if (_filter.tags.isNotEmpty) {
        final hasMatchingTag = product.tags.any((tag) => _filter.tags.contains(tag));
        if (!hasMatchingTag) {
          return false;
        }
      }
      
      // Price range filter
      if (_filter.minPrice != null && product.price < _filter.minPrice!) {
        return false;
      }
      if (_filter.maxPrice != null && product.price > _filter.maxPrice!) {
        return false;
      }
      
      // Stock range filter
      if (_filter.minStock != null && product.stockQuantity < _filter.minStock!) {
        return false;
      }
      if (_filter.maxStock != null && product.stockQuantity > _filter.maxStock!) {
        return false;
      }
      
      // Quick filters
      if (_filter.inStockOnly == true && product.stockQuantity == 0) {
        return false;
      }
      
      if (_filter.onSaleOnly == true && !product.isOnSale) {
        return false;
      }
      
      if (_filter.featuredOnly == true && !product.isFeatured) {
        return false;
      }
      
      return true;
    }).toList();
    
    // Apply sorting
    _applySorting();
    
    notifyListeners();
  }

  void _applySorting() {
    switch (_filter.sortBy) {
      case 'name':
        _filteredProducts.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'name_desc':
        _filteredProducts.sort((a, b) => b.name.compareTo(a.name));
        break;
      case 'price':
        _filteredProducts.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_desc':
        _filteredProducts.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'stock':
        _filteredProducts.sort((a, b) => a.stockQuantity.compareTo(b.stockQuantity));
        break;
      case 'stock_desc':
        _filteredProducts.sort((a, b) => b.stockQuantity.compareTo(a.stockQuantity));
        break;
      case 'created_at':
        _filteredProducts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'updated_at':
        _filteredProducts.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        break;
      case 'popularity':
        _filteredProducts.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      default:
        _filteredProducts.sort((a, b) => a.name.compareTo(b.name));
    }
  }

  // Category selection
  void selectCategory(String categoryName) {
    if (categoryName == 'All') {
      _selectedCategory = null;
      updateFilters(_filter.copyWith(categories: []));
    } else {
      _selectedCategory = _categories.firstWhere(
        (category) => category.name == categoryName,
        orElse: () => ProductCategory(id: '', name: categoryName),
      );
      updateFilters(_filter.copyWith(categories: [categoryName]));
    }
  }

  // Favorites functionality
  Future<void> toggleFavorite(Product product) async {
    if (_favoriteProductIds.contains(product.id)) {
      _favoriteProductIds.remove(product.id);
      _productFavorites[product.id] = false;
      await _preferencesService.removeFavorite(product.id);
    } else {
      _favoriteProductIds.add(product.id);
      _productFavorites[product.id] = true;
      await _preferencesService.addFavorite(product.id);
    }
    notifyListeners();
  }

  Future<bool> isFavorite(Product product) async {
    return await _preferencesService.isFavorite(product.id);
  }

  // Comparison functionality
  Future<void> toggleComparison(Product product) async {
    if (_comparisonProductIds.contains(product.id)) {
      _comparisonProductIds.remove(product.id);
      await _preferencesService.removeFromComparison(product.id);
    } else {
      if (_comparisonProductIds.length < 4) { // Limit to 4 products for comparison
        _comparisonProductIds.add(product.id);
        await _preferencesService.addToComparison(product.id);
      }
    }
    notifyListeners();
  }

  bool isInComparison(Product product) {
    return _comparisonProductIds.contains(product.id);
  }

  Future<void> clearComparison() async {
    _comparisonProductIds.clear();
    await _preferencesService.clearComparison();
    notifyListeners();
  }

  // View mode
  void setViewMode(ViewMode mode) {
    _viewMode = mode;
    notifyListeners();
  }

  // Tab management
  void setTabIndex(int index) {
    _currentTabIndex = index;
    notifyListeners();
  }

  // Product selection
  void selectProduct(Product? product) {
    _selectedProduct = product;
    notifyListeners();
  }

  // Pagination
  Future<void> loadMoreProducts() async {
    if (!_hasMore || _isLoadingMore) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final newProducts = await _productService.loadRegisteredProducts(
        category: _filter.categories.isNotEmpty ? _filter.categories.first : null,
        token: null,
        page: _currentPage,
      );

      _allProducts.addAll(newProducts);
      _products.addAll(newProducts);
      _applyFilters();

      _currentPage++;
      _hasMore = newProducts.length >= _pageSize;
    } catch (e) {
      _errorMessage = 'Failed to load more products: ${e.toString()}';
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  // Refresh
  Future<void> refresh() async {
    await loadProducts(refresh: true);
  }

  // Clear filters
  void clearFilters() {
    _filter = const ProductFilterEntity();
    _searchQuery = '';
    _searchSuggestions.clear();
    _selectedCategory = null;
    _applyFilters();
  }

  // Get product statistics
  Map<String, dynamic> getProductStatistics() {
    return {
      'totalProducts': _allProducts.length,
      'inStockProducts': _allProducts.where((p) => p.stockQuantity > 0).length,
      'outOfStockProducts': _allProducts.where((p) => p.stockQuantity == 0).length,
      'lowStockProducts': _allProducts.where((p) => p.isLowStock).length,
      'featuredProducts': _allProducts.where((p) => p.isFeatured).length,
      'onSaleProducts': _allProducts.where((p) => p.isOnSale).length,
      'averagePrice': _allProducts.isEmpty ? 0.0 : 
          _allProducts.map((p) => p.price).reduce((a, b) => a + b) / _allProducts.length,
      'averageRating': averageRating,
      'totalCategories': _categories.length,
      'totalBrands': _brands.length,
      'totalManufacturers': _manufacturers.length,
    };
  }
}
