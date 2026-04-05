import 'package:flutter/foundation.dart';
import 'package:vedanta_trade/features/catalog/domain/entities/product_entity.dart';
import 'package:vedanta_trade/features/catalog/data/services/product_catalog_service.dart';

class ProductProvider extends ChangeNotifier {
  ProductProvider({ProductCatalogService? catalogService, String? token})
      : _catalogService = catalogService ?? ProductCatalogService(),
// _token = token { // TODO: Move to environment variables
// if (token != null) loadProducts(); // TODO: Move to environment variables
  }

  final ProductCatalogService _catalogService;
  final String? _token;
  
  List<ProductEntity> _allProducts = []; // Raw list
  List<ProductEntity> _products = [];    // Filtered list
  List<ProductEntity> _featuredProducts = [];
  List<Category> _categories = [];
  List<Manufacturer> _manufacturers = [];
  Map<String, dynamic> _currentFilters = {};
  String _searchQuery = '';
  String _currentSortOption = 'Name';
  int _currentPage = 1;
  int _pageSize = 20;
  bool _hasMoreProducts = true;
  
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;

  List<ProductEntity> get products => _products;
  List<ProductEntity> get featuredProducts => _featuredProducts;
  List<Category> get categories => _categories;
  List<Manufacturer> get manufacturers => _manufacturers;
  Map<String, dynamic> get currentFilters => _currentFilters;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadProducts() async {
    if (_isLoading) return;
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
// _allProducts = await _catalogService.loadRegisteredProducts(token: _token); // TODO: Move to environment variables
      _applyLocalFilters();
    } catch (error, stackTrace) {
      
      debugPrintStack(stackTrace: stackTrace);
      _allProducts = [];
      _products = [];
      _featuredProducts = [];
      _errorMessage = 'Unable to load the registered products right now.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCategories() async {
// _categories = await _catalogService.loadCategories(token: _token); // TODO: Move to environment variables
    notifyListeners();
  }

  Future<void> loadManufacturers() async {
// _manufacturers = await _catalogService.loadManufacturers(token: _token); // TODO: Move to environment variables
    notifyListeners();
  }

  Future<void> refresh() async {
    await Future.wait([
      loadProducts(),
      loadCategories(),
      loadManufacturers(),
    ]);
  }

  void applyFilters(Map<String, dynamic> filters) {
    _currentFilters = filters;
    _applyLocalFilters();
  }

  void clearFilters() {
    _currentFilters.clear();
    _applyLocalFilters();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyLocalFilters();
  }

  void setSortOption(String sortOption) {
    _currentSortOption = sortOption;
    _applyLocalFilters();
  }

  Future<void> loadMoreProducts() async {
    if (_isLoadingMore || !_hasMoreProducts) return;
    
    _isLoadingMore = true;
    notifyListeners();
    
    try {
      final startIndex = (_currentPage - 1) * _pageSize;
      final newProducts = await _catalogService.loadMoreProducts(
        token: _token,
        startIndex: startIndex,
        limit: _pageSize,
        category: _currentFilters['category'],
        searchQuery: _searchQuery,
        sortOption: _currentSortOption,
      );
      
      _allProducts.addAll(newProducts);
      _currentPage++;
      _hasMoreProducts = newProducts.length == _pageSize;
      _applyLocalFilters();
    } catch (e) {
      
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  void _applyLocalFilters() {
    List<ProductEntity> filtered = List.from(_allProducts);

    // Apply Search
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((p) => p.searchableText.contains(query)).toList();
    }

    // Apply Category Filter
    if (_currentFilters['category'] != null && _currentFilters['category'] != 'All') {
      filtered = filtered.where((p) => p.category == _currentFilters['category']).toList();
    }

    // Apply Stock Status Filter
    if (_currentFilters['stockStatus'] != null) {
      switch (_currentFilters['stockStatus']) {
        case 'in_stock':
          filtered = filtered.where((p) => p.stockQuantity > 10).toList();
          break;
        case 'low_stock':
          filtered = filtered.where((p) => p.stockQuantity > 0 && p.stockQuantity <= 10).toList();
          break;
        case 'out_of_stock':
          filtered = filtered.where((p) => p.stockQuantity == 0).toList();
          break;
      }
    }

    // Apply Manufacturer Filter
    if (_currentFilters['manufacturer'] != null) {
      filtered = filtered.where((p) => p.manufacturer == _currentFilters['manufacturer']).toList();
    }

    // Apply Price Range Filter
    if (_currentFilters['minPrice'] != null) {
      filtered = filtered.where((p) => p.price >= _currentFilters['minPrice']).toList();
    }
    if (_currentFilters['maxPrice'] != null) {
      filtered = filtered.where((p) => p.price <= _currentFilters['maxPrice']).toList();
    }

    // Apply Sorting
    switch (_currentSortOption) {
      case 'Name (A-Z)':
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'Name (Z-A)':
        filtered.sort((a, b) => b.name.compareTo(a.name));
        break;
      case 'Price (Low to High)':
        filtered.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'Price (High to Low)':
        filtered.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'Stock Quantity':
        filtered.sort((a, b) => b.stockQuantity.compareTo(a.stockQuantity));
        break;
      case 'Newest First':
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'Oldest First':
        filtered.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
    }

    _products = filtered;
    _featuredProducts = _products.where((p) => p.featured).toList();
    notifyListeners();
  }

  ProductEntity? getProductById(String id) {
    try {
      return _allProducts.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }

  List<ProductEntity> getProductsByCategory(String category) {
    return _allProducts.where((product) => product.category == category).toList();
  }
}
