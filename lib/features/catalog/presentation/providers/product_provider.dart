import 'package:flutter/foundation.dart';
import 'package:vedanta_trade/features/catalog/domain/models/product.dart';
import 'package:vedanta_trade/features/catalog/data/services/product_catalog_service.dart';

class ProductProvider extends ChangeNotifier {
  ProductProvider({ProductCatalogService? catalogService, String? token})
      : _catalogService = catalogService ?? ProductCatalogService(),
        _token = token {
    if (token != null) loadProducts();
  }

  final ProductCatalogService _catalogService;
  final String? _token;
  
  List<Product> _allProducts = []; // Raw list
  List<Product> _products = [];    // Filtered list
  List<Product> _featuredProducts = [];
  List<Category> _categories = [];
  List<Manufacturer> _manufacturers = [];
  Map<String, dynamic> _currentFilters = {};
  String _searchQuery = '';
  
  bool _isLoading = false;
  String? _errorMessage;

  List<Product> get products => _products;
  List<Product> get featuredProducts => _featuredProducts;
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
      _allProducts = await _catalogService.loadRegisteredProducts(token: _token);
      _applyLocalFilters();
    } catch (error, stackTrace) {
      debugPrint('Failed to load product catalog: $error');
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
    _categories = await _catalogService.loadCategories(token: _token);
    notifyListeners();
  }

  Future<void> loadManufacturers() async {
    _manufacturers = await _catalogService.loadManufacturers(token: _token);
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

  void _applyLocalFilters() {
    List<Product> filtered = List.from(_allProducts);

    // Apply Search
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((p) => p.searchableText.contains(query)).toList();
    }

    // Apply Category Filter
    if (_currentFilters['category'] != null && _currentFilters['category'] != 'All') {
      filtered = filtered.where((p) => p.category == _currentFilters['category']).toList();
    }

    _products = filtered;
    _featuredProducts = _products.where((p) => p.featured).toList();
    notifyListeners();
  }

  Product? getProductById(String id) {
    try {
      return _allProducts.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Product> getProductsByCategory(String category) {
    return _allProducts.where((product) => product.category == category).toList();
  }
}
