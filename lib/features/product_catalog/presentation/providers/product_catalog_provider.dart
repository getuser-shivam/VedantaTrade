import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../../data/models/product_model.dart';
import '../../data/services/product_service.dart';

class ProductCatalogProvider extends ChangeNotifier {
  final ProductService _productService = ProductService();

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
  String _searchQuery = '';
  String _sortBy = 'name';
  String _filterByCategory = '';
  bool _showInStockOnly = false;
  bool _showExpiringSoonOnly = false;
  
  // Pagination
  int _currentPage = 1;
  int _totalPages = 1;
  final int _pageSize = 20;
  bool _hasMore = true;

  // Getters
  List<Product> get products => _filteredProducts.isEmpty ? _products : _filteredProducts;
  List<ProductCategory> get categories => _categories;
  Product? get selectedProduct => _selectedProduct;
  ProductCategory? get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  bool get isLoadingCategories => _isLoadingCategories;
  bool get isLoadingMore => _isLoadingMore;
  String get searchQuery => _searchQuery;
  String get sortBy => _sortBy;
  String get filterByCategory => _filterByCategory;
  bool get showInStockOnly => _showInStockOnly;
  bool get showExpiringSoonOnly => _showExpiringSoonOnly;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  bool get hasMore => _hasMore;

  // Computed properties
  List<Product> get featuredProducts => _products.where((p) => p.rating >= 4.5).take(6).toList();
  List<Product> get lowStockProducts => _products.where((p) => p.isLowStock).toList();
  List<Product> get expiringSoonProducts => _products.where((p) => p.isExpiringSoon).toList();
  List<Product> get outOfStockProducts => _products.where((p) => p.stockQuantity == 0).toList();
  
  int get totalProducts => _products.length;
  int get filteredProductsCount => _filteredProducts.length;
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
    notifyListeners();

    try {
      final newProducts = await _productService.getProducts(
        category: _filterByCategory.isNotEmpty ? _filterByCategory : null,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        sortBy: _sortBy,
        inStock: _showInStockOnly ? true : null,
        page: _currentPage,
        limit: _pageSize,
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
      final newProducts = await _productService.getProducts(
        category: _filterByCategory.isNotEmpty ? _filterByCategory : null,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        sortBy: _sortBy,
        inStock: _showInStockOnly ? true : null,
        page: _currentPage,
        limit: _pageSize,
      );

      _products.addAll(newProducts);
      _currentPage++;
      _hasMore = newProducts.length == _pageSize;
      _totalPages = (_products.length / _pageSize).ceil();

      _applyFilters();
    } catch (e) {
      debugPrint('Error loading more products: $e');
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

  // Search products
  Future<void> searchProducts(String query) async {
    if (_searchQuery == query) return;

    _searchQuery = query;
    _currentPage = 1;
    _hasMore = true;
    _products.clear();
    _filteredProducts.clear();

    if (query.isNotEmpty) {
      _isLoading = true;
      notifyListeners();

      try {
        final searchResults = await _productService.searchProducts(query);
        _products = searchResults;
        _applyFilters();
      } catch (e) {
        debugPrint('Error searching products: $e');
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    } else {
      await loadProducts(refresh: true);
    }
  }

  // Filter products
  void filterByCategory(String category) {
    _filterByCategory = category;
    _selectedCategory = _categories.firstWhere(
      (cat) => cat.name == category,
      orElse: () => _categories.first,
    );
    _currentPage = 1;
    _hasMore = true;
    loadProducts(refresh: true);
  }

  void sortByProducts(String sortBy) {
    _sortBy = sortBy;
    _currentPage = 1;
    _hasMore = true;
    loadProducts(refresh: true);
  }

  void toggleInStockFilter() {
    _showInStockOnly = !_showInStockOnly;
    _currentPage = 1;
    _hasMore = true;
    loadProducts(refresh: true);
  }

  void toggleExpiringSoonFilter() {
    _showExpiringSoonOnly = !_showExpiringSoonOnly;
    _currentPage = 1;
    _hasMore = true;
    loadProducts(refresh: true);
  }

  void clearFilters() {
    _searchQuery = '';
    _filterByCategory = '';
    _sortBy = 'name';
    _showInStockOnly = false;
    _showExpiringSoonOnly = false;
    _selectedCategory = null;
    _filteredProducts.clear();
    _currentPage = 1;
    _hasMore = true;
    loadProducts(refresh: true);
  }

  // Apply filters
  void _applyFilters() {
    _filteredProducts = List.from(_products);

    // Apply category filter
    if (_filterByCategory.isNotEmpty) {
      _filteredProducts = _filteredProducts
          .where((product) => product.category == _filterByCategory)
          .toList();
    }

    // Apply stock filter
    if (_showInStockOnly) {
      _filteredProducts = _filteredProducts
          .where((product) => product.stockQuantity > 0)
          .toList();
    }

    // Apply expiry filter
    if (_showExpiringSoonOnly) {
      _filteredProducts = _filteredProducts
          .where((product) => product.isExpiringSoon)
          .toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      _filteredProducts = _filteredProducts
          .where((product) =>
              product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              product.genericName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              product.manufacturer.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              product.description.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
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
