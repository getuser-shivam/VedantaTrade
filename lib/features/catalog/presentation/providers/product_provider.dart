import 'package:flutter/foundation.dart';
import 'package:vedanta_trade/features/catalog/domain/models/product.dart';
import 'package:vedanta_trade/features/catalog/data/services/product_catalog_service.dart';

class ProductProvider extends ChangeNotifier {
  ProductProvider({ProductCatalogService? catalogService, String? token})
      : _catalogService = catalogService ?? const ProductCatalogService(),
        _token = token {
    if (token != null) loadProducts();
  }

  final ProductCatalogService _catalogService;
  final String? _token;
  List<Product> _products = [];
  List<Product> _featuredProducts = [];
  List<String> _categories = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Product> get products => _products;
  List<Product> get featuredProducts => _featuredProducts;
  List<String> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadProducts() async {
    if (_isLoading) return;
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _products = await _catalogService.loadRegisteredProducts(token: _token);
      _featuredProducts = _products.where((product) => product.featured).toList();
      
      // Load categories from API
      _categories = await _catalogService.loadCategories(token: _token);
      
      // If API categories fail, fallback to product categories
      if (_categories.isEmpty) {
        _categories = _products.map((product) => product.category).toSet().toList();
        _categories.sort();
      }
    } catch (error, stackTrace) {
      debugPrint('Failed to load product catalog: $error');
      debugPrintStack(stackTrace: stackTrace);
      _products = [];
      _featuredProducts = [];
      _categories = [];
      _errorMessage = 'Unable to load the registered products right now.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Product? getProductById(String id) {
    try {
      return _products.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Product> getProductsByCategory(String category) {
    return _products.where((product) => product.category == category).toList();
  }
}
