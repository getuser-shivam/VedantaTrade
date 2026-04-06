import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../../data/models/product_model.dart';
import '../../data/services/product_catalog_service.dart';
import '../../domain/entities/product_filter_entity.dart';

enum ViewMode { grid, list }

class ProductCatalogProvider extends ChangeNotifier {
  final ProductCatalogService _productService = ProductCatalogService();

  // State management
  List<Product> _products = [];
  List<ProductCategory> _categories = [];
  List<Product> _filteredProducts = [];
  Product? _selectedProduct;
  ProductCategory? _selectedCategory;
  
  // Loading states
  bool _isLoading = false;
  bool _isLoadingCategories = false;
  bool _isLoadingMore = false;
  
  // Search and filter
  ProductFilterEntity _filter = const ProductFilterEntity();
  
  // Favorites and Comparison
  final List<String> _favoriteProductIds = [];
  final List<String> _comparisonProductIds = [];

  // Pagination
  int _currentPage = 1;
  int _totalPages = 1;
  final int _pageSize = 20;
  bool _hasMore = true;
  ViewMode _viewMode = ViewMode.grid;
  int _currentTabIndex = 0;

  // Getters
  List<Product> get products => _filteredProducts.isEmpty ? _products : _filteredProducts;
  List<ProductCategory> get categories => _categories;
  Product? get selectedProduct => _selectedProduct;
  ProductCategory? get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  bool get isLoadingCategories => _isLoadingCategories;
  bool get isLoadingMore => _isLoadingMore;
  
  ProductFilterEntity get filter => _filter;
  bool get hasActiveFilters => _filter.hasActiveFilters;
  
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
  
  int get totalProducts => _products.length;
  int get filteredProductsCount => _filteredProducts.length;
  bool get hasError => _errorMessage != null;
  String? get errorMessage => _errorMessage;

  double get averageRating => _products.isEmpty ? 0.0 : 
      _products.map((p) => p.rating).reduce((a, b) => a + b) / _products.length;

  // Initialize data
  Future<void> initialize() async {
    await Future.wait([
      loadCategories(),
      loadProducts(),
    ]);
  }

  // Load products
  Future<void> loadProducts({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      _products.clear();
    }

    if (_isLoading && !refresh) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newProducts = await _productService.loadRegisteredProducts(
        category: _filter.categories.isNotEmpty ? _filter.categories.first : null,
        token: null, // TODO: Get from AuthProvider
      );

      if (refresh) {
        _products = newProducts;
      } else {
        _products.addAll(newProducts);
      }

      _currentPage++;
      _hasMore = newProducts.length == _pageSize;
      _totalPages = (_products.length / _pageSize).ceil();

      _applyFilters();
    } catch (e) {
      debugPrint('Error loading products: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load more products
  Future<void> loadMoreProducts() async {
    if (_isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final newProducts = await _productService.loadMoreProducts(
        category: _filter.categories.isNotEmpty ? _filter.categories.first : null,
        searchQuery: _filter.searchQuery,
        sortOption: _filter.sortBy,
        startIndex: _products.length,
        limit: _pageSize,
      );

      _products.addAll(newProducts);
      _hasMore = newProducts.length == _pageSize;
      _totalPages = (_products.length / _pageSize).ceil();

      _applyFilters();
    } catch (e) {
      _errorMessage = 'Error loading more products: $e';
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  // Load categories
  Future<void> loadCategories() async {
    _isLoadingCategories = true;
    notifyListeners();

    try {
      _categories = await _productService.getCategories();
    } catch (e) {
      debugPrint('Error loading categories: $e');
    } finally {
      _isLoadingCategories = false;
      notifyListeners();
    }
  }

  // Filter products
  void updateFilters(ProductFilterEntity newFilter) {
    _filter = newFilter;
    _currentPage = 1;
    _hasMore = true;
    _applyFilters();
    notifyListeners();
  }

  void selectCategory(String categoryName) {
    if (categoryName == 'All') {
      _filter = _filter.copyWith(categories: []);
    } else {
      _filter = _filter.copyWith(categories: [categoryName]);
    }
    _currentPage = 1;
    _hasMore = true;
    _applyFilters();
    notifyListeners();
  }

  void setViewMode(ViewMode mode) {
    _viewMode = mode;
    notifyListeners();
  }

  void setTab(int index) {
    _currentTabIndex = index;
    _applyFilters();
    notifyListeners();
  }

  void clearFilters() {
    _filter = const ProductFilterEntity();
    _currentPage = 1;
    _hasMore = true;
    _applyFilters();
    notifyListeners();
  }

  void toggleFavorite(Product product) {
    if (_favoriteProductIds.contains(product.id)) {
      _favoriteProductIds.remove(product.id);
    } else {
      _favoriteProductIds.add(product.id);
    }
    notifyListeners();
  }

  void toggleComparison(Product product) {
    if (_comparisonProductIds.contains(product.id)) {
      _comparisonProductIds.remove(product.id);
    } else {
      _comparisonProductIds.add(product.id);
    }
    notifyListeners();
  }

  bool isFavorite(String productId) => _favoriteProductIds.contains(productId);
  bool isCompared(String productId) => _comparisonProductIds.contains(productId);

  // Apply filters
  void _applyFilters() {
    _filteredProducts = List.from(_products);

    // Apply category filter
    if (_filter.categories.isNotEmpty) {
      _filteredProducts = _filteredProducts
          .where((product) => _filter.categories.contains(product.category))
          .toList();
    }

    // Apply stock filter
    if (_filter.inStockOnly == true) {
      _filteredProducts = _filteredProducts
          .where((product) => product.stockQuantity > 0)
          .toList();
    }

    // Apply price range
    if (_filter.minPrice != null) {
      _filteredProducts = _filteredProducts
          .where((product) => product.finalPrice >= _filter.minPrice!)
          .toList();
    }
    if (_filter.maxPrice != null) {
      _filteredProducts = _filteredProducts
          .where((product) => product.finalPrice <= _filter.maxPrice!)
          .toList();
    }

    // Apply rating filter
    if (_filter.minRating != null) {
      _filteredProducts = _filteredProducts
          .where((product) => product.rating >= _filter.minRating!)
          .toList();
    }

    // Apply search filter
    if (_filter.searchQuery != null && _filter.searchQuery!.isNotEmpty) {
      final query = _filter.searchQuery!.toLowerCase();
      _filteredProducts = _filteredProducts
          .where((product) =>
              product.name.toLowerCase().contains(query) ||
              product.genericName.toLowerCase().contains(query) ||
              product.manufacturer.toLowerCase().contains(query) ||
              product.description.toLowerCase().contains(query))
          .toList();
    }

    // Apply tab filtering
    switch (_currentTabIndex) {
      case 1: // Featured
        _filteredProducts = _filteredProducts.where((p) => p.rating >= 4.5).toList();
        break;
      case 2: // On Sale
        _filteredProducts = _filteredProducts.where((p) => p.isOnSale).toList();
        break;
      case 3: // New Arrivals
        _filteredProducts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }

    // Apply sorting
    if (_filter.sortBy != null) {
      switch (_filter.sortBy) {
        case 'price':
          if (_filter.sortOrder == 'asc') {
            _filteredProducts.sort((a, b) => a.finalPrice.compareTo(b.finalPrice));
          } else {
            _filteredProducts.sort((a, b) => b.finalPrice.compareTo(a.finalPrice));
          }
          break;
        case 'rating':
          _filteredProducts.sort((a, b) => b.rating.compareTo(a.rating));
          break;
        case 'createdAt':
          _filteredProducts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          break;
        case 'name':
        default:
          if (_filter.sortOrder == 'desc') {
            _filteredProducts.sort((a, b) => b.name.compareTo(a.name));
          } else {
            _filteredProducts.sort((a, b) => a.name.compareTo(b.name));
          }
          break;
      }
    }

    notifyListeners();
  }

  // Select product
  void selectProduct(Product product) {
    _selectedProduct = product;
    notifyListeners();
  }

  // Product actions
  Future<void> updateProduct(Product product) async {
    try {
      await _productService.updateProduct(product);
      
      final index = _products.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        _products[index] = product;
        _applyFilters();
      }
      
      if (_selectedProduct?.id == product.id) {
        _selectedProduct = product;
      }
    } catch (e) {
      debugPrint('Error updating product: $e');
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      await _productService.deleteProduct(productId);
      
      _products.removeWhere((p) => p.id == productId);
      _filteredProducts.removeWhere((p) => p.id == productId);
      
      if (_selectedProduct?.id == productId) {
        _selectedProduct = null;
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting product: $e');
    }
  }

  // Special product lists
  Future<void> loadFeaturedProducts() async {
    try {
      final featured = await _productService.getFeaturedProducts();
      _featuredProducts = featured;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading featured products: $e');
    }
  }

  Future<void> loadLowStockProducts() async {
    try {
      final lowStock = await _productService.getLowStockProducts();
      _lowStockProducts = lowStock;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading low stock products: $e');
    }
  }

  Future<void> loadExpiringSoonProducts() async {
    try {
      final expiringSoon = await _productService.getExpiringSoonProducts();
      _expiringSoonProducts = expiringSoon;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading expiring soon products: $e');
    }
  }

  // Refresh data
  Future<void> refresh() async {
    await Future.wait([
      loadCategories(),
      loadProducts(refresh: true),
    ]);
  }

  // Get product by ID
  Product? getProductById(String productId) {
    try {
      return _products.firstWhere((product) => product.id == productId);
    } catch (e) {
      return null;
    }
  }

  // Get products by category
  List<Product> getProductsByCategory(String category) {
    return _products.where((product) => product.category == category).toList();
  }

  // Get category statistics
  Map<String, int> getCategoryStats() {
    final stats = <String, int>{};
    for (final product in _products) {
      stats[product.category] = (stats[product.category] ?? 0) + 1;
    }
    return stats;
  }

  // Get stock statistics
  Map<String, dynamic> getStockStats() {
    final inStock = _products.where((p) => p.stockQuantity > 0).length;
    final outOfStock = _products.where((p) => p.stockQuantity == 0).length;
    final lowStock = _products.where((p) => p.isLowStock).length;
    final expiringSoon = _products.where((p) => p.isExpiringSoon).length;
    final expired = _products.where((p) => p.isExpired).length;

    return {
      'total': _products.length,
      'inStock': inStock,
      'outOfStock': outOfStock,
      'lowStock': lowStock,
      'expiringSoon': expiringSoon,
      'expired': expired,
    };
  }
}
