import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../features/catalog/domain/models/product.dart';
import '../config/api_config.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  List<Category> _categories = [];
  List<Manufacturer> _manufacturers = [];
  List<Product> _favoriteProducts = [];
  Map<String, dynamic> _currentFilters = {};
  String _searchQuery = '';
  int _currentPage = 1;
  int _totalPages = 1;
  bool _isLoading = false;
  bool _hasMore = true;
  String? _error;

  // Getters
  List<Product> get products => _products;
  List<Category> get categories => _categories;
  List<Manufacturer> get manufacturers => _manufacturers;
  List<Product> get favoriteProducts => _favoriteProducts;
  Map<String, dynamic> get currentFilters => _currentFilters;
  String get searchQuery => _searchQuery;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  String? get error => _error;

  // Load products from local JSON and API
  Future<void> loadProducts({
    int page = 1,
    Map<String, dynamic>? filters,
    String? searchQuery,
    bool refresh = false,
  }) async {
    if (refresh) {
      _products.clear();
      _currentPage = 1;
      _hasMore = true;
    }

    if (_isLoading && !refresh) return;

    _setLoading(true);
    _clearError();

    try {
      // Step 1: Load from Local JSON (registered products)
      final String response = await rootBundle.loadString('assets/data/products.json');
      final List<dynamic> data = json.decode(response);
      List<Product> localProducts = data.map((json) => Product.fromJson(json)).toList();

      // Step 2: Apply Search/Filters locally (can be extended to API later)
      if (searchQuery != null && searchQuery.isNotEmpty) {
        localProducts = localProducts.where((p) => 
          p.searchableText.contains(searchQuery.toLowerCase())
        ).toList();
      }

      if (filters != null && filters.isNotEmpty) {
        if (filters['category'] != null && filters['category'] != 'All') {
          localProducts = localProducts.where((p) => 
            p.category == filters['category']
          ).toList();
        }
      }

      _products = localProducts;
      _searchQuery = searchQuery ?? '';
      _currentFilters = filters ?? {};
      _hasMore = false; // Local data is finite
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to load products: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load categories from local data or API
  Future<void> loadCategories() async {
    try {
      final String response = await rootBundle.loadString('assets/data/products.json');
      final List<dynamic> data = json.decode(response);
      final Set<String> categoryNames = data.map((json) => json['category'] as String).toSet();
      
      _categories = categoryNames.map((name) => Category(name: name)).toList();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load categories: $e');
    }
  }

  // Load manufacturers
  Future<void> loadManufacturers() async {
    try {
      final String response = await rootBundle.loadString('assets/data/products.json');
      final List<dynamic> data = json.decode(response);
      final Set<String> manufacturerNames = data.map((json) => 
        json['manufacturer'] as String? ?? 'Vedanta TradeLink'
      ).toSet();
      
      _manufacturers = manufacturerNames.map((name) => Manufacturer(name: name)).toList();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load manufacturers: $e');
    }
  }

  // Get product details
  Future<Product?> getProductDetails(String productId) async {
    if (_products.isEmpty) {
      await loadProducts();
    }
    return _products.firstWhere((p) => p.id == productId);
  }

  // Toggle favorite product
  Future<void> toggleFavorite(Product product) async {
    if (_favoriteProducts.any((p) => p.id == product.id)) {
      _favoriteProducts.removeWhere((p) => p.id == product.id);
    } else {
      _favoriteProducts.add(product);
    }
    notifyListeners();
  }

  bool isFavorite(Product product) {
    return _favoriteProducts.any((p) => p.id == product.id);
  }

  void applyFilters(Map<String, dynamic> filters) {
    _currentFilters = filters;
    loadProducts(refresh: true, filters: filters, searchQuery: _searchQuery);
  }

  void clearFilters() {
    _currentFilters.clear();
    loadProducts(refresh: true, searchQuery: _searchQuery);
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    loadProducts(refresh: true, searchQuery: query, filters: _currentFilters);
  }

  Future<void> refresh() async {
    await Future.wait([
      loadProducts(refresh: true),
      loadCategories(),
      loadManufacturers(),
    ]);
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}
