import 'package:flutter/foundation.dart';

import 'package:neutralitical_app/features/catalog/domain/models/product.dart';
import 'package:neutralitical_app/features/catalog/data/services/product_catalog_service.dart';

class ProductProvider extends ChangeNotifier {
  ProductProvider({ProductCatalogService? catalogService})
      : _catalogService = catalogService ?? const ProductCatalogService() {
    loadProducts();
  }

  final ProductCatalogService _catalogService;
  List<Product> _products = [];
  List<Product> _featuredProducts = [];
  bool _isLoading = true;
  String? _errorMessage;

  List<Product> get products => _products;
  List<Product> get featuredProducts => _featuredProducts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadProducts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _products = await _catalogService.loadRegisteredProducts();
      _featuredProducts = _products.where((product) => product.featured).toList();
    } catch (error, stackTrace) {
      debugPrint('Failed to load product catalog: $error');
      debugPrintStack(stackTrace: stackTrace);
      _products = [];
      _featuredProducts = [];
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

  List<String> getCategories() {
    final categories = _products.map((product) => product.category).toSet().toList();
    categories.sort();
    return categories;
  }
}
