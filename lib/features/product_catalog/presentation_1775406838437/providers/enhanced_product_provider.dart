import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/premium_glassmorphic_theme.dart';
import '../../data/services/product_catalog_service.dart';
import '../models/product.dart';

class ProductProvider extends ChangeNotifier {
  final ProductCatalogService catalogService;
  final String? token;

  ProductProvider({
    required this.catalogService,
    this.token,
  });

  // State variables
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  List<Category> _categories = [];
  List<Manufacturer> _manufacturers = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  Map<String, dynamic> _filters = {};
  String _sortBy = 'name';
  bool _sortAscending = true;

  // Getters
  List<Product> get products => _filteredProducts;
  List<Product> get allProducts => _products;
  List<Category> get categories => _categories;
  List<Manufacturer> get manufacturers => _manufacturers;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  Map<String, dynamic> get filters => _filters;
  String get sortBy => _sortBy;
  bool get sortAscending => _sortAscending;

  // Load products from catalog service
  Future<void> loadProducts() async {
    _setLoading(true);
    _error = null;
    
    try {
      _products = await catalogService.getProducts();
      _applyFiltersAndSearch();
    } catch (e) {
      _error = e.toString();
      
    } finally {
      _setLoading(false);
    }
  }

  // Load categories
  Future<void> loadCategories() async {
    try {
      _categories = await catalogService.getCategories();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      
    }
  }

  // Load manufacturers
  Future<void> loadManufacturers() async {
    try {
      _manufacturers = await catalogService.getManufacturers();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      
    }
  }

  // Refresh all data
  Future<void> refresh() async {
    await Future.wait([
      loadProducts(),
      loadCategories(),
      loadManufacturers(),
    ]);
  }

  // Set search query
  void setSearchQuery(String query) {
    _searchQuery = query.toLowerCase();
    _applyFiltersAndSearch();
  }

  // Apply filters
  void applyFilters(Map<String, dynamic> filters) {
    _filters = Map<String, dynamic>.from(filters);
    _applyFiltersAndSearch();
  }

  // Clear all filters
  void clearFilters() {
    _filters.clear();
    _searchQuery = '';
    _sortBy = 'name';
    _sortAscending = true;
    _applyFiltersAndSearch();
  }

  // Sort products
  void sortProducts(String sortBy, bool ascending) {
    _sortBy = sortBy;
    _sortAscending = ascending;
    _applyFiltersAndSearch();
  }

  // Apply filters and search
  void _applyFiltersAndSearch() {
    _filteredProducts = List<Product>.from(_products);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      _filteredProducts = _filteredProducts.where((product) {
        return product.name.toLowerCase().contains(_searchQuery) ||
               product.category.toLowerCase().contains(_searchQuery) ||
               product.manufacturer.toLowerCase().contains(_searchQuery) ||
               product.description.toLowerCase().contains(_searchQuery);
      }).toList();
    }

    // Apply category filter
    if (_filters.containsKey('category') && _filters['category'] != 'All') {
      final category = _filters['category'] as String;
      _filteredProducts = _filteredProducts.where((product) {
        return product.category == category;
      }).toList();
    }

    // Apply manufacturer filter
    if (_filters.containsKey('manufacturer') && _filters['manufacturer'] != 'All') {
      final manufacturer = _filters['manufacturer'] as String;
      _filteredProducts = _filteredProducts.where((product) {
        return product.manufacturer == manufacturer;
      }).toList();
    }

    // Apply price range filter
    if (_filters.containsKey('minPrice')) {
      final minPrice = _filters['minPrice'] as double;
      _filteredProducts = _filteredProducts.where((product) {
        return product.price >= minPrice;
      }).toList();
    }

    if (_filters.containsKey('maxPrice')) {
      final maxPrice = _filters['maxPrice'] as double;
      _filteredProducts = _filteredProducts.where((product) {
        return product.price <= maxPrice;
      }).toList();
    }

    // Apply stock filter
    if (_filters.containsKey('inStockOnly') && _filters['inStockOnly'] == true) {
      _filteredProducts = _filteredProducts.where((product) {
        return product.stockQuantity > 0;
      }).toList();
    }

    // Apply discount filter
    if (_filters.containsKey('hasDiscountOnly') && _filters['hasDiscountOnly'] == true) {
      _filteredProducts = _filteredProducts.where((product) {
        return product.hasDiscount;
      }).toList();
    }

    // Apply sorting
    _filteredProducts.sort((a, b) {
      int comparison;
      
      switch (_sortBy) {
        case 'price':
          comparison = a.price.compareTo(b.price);
          break;
        case 'category':
          comparison = a.category.compareTo(b.category);
          break;
        case 'manufacturer':
          comparison = a.manufacturer.compareTo(b.manufacturer);
          break;
        case 'rating':
          comparison = a.rating.compareTo(b.rating);
          break;
        case 'stock':
          comparison = a.stockQuantity.compareTo(b.stockQuantity);
          break;
        case 'name':
        default:
          comparison = a.name.compareTo(b.name);
          break;
      }
      
      return _sortAscending ? comparison : -comparison;
    });

    notifyListeners();
  }

  // Get product by ID
  Product? getProductById(String id) {
    try {
      return _products.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get featured products
  List<Product> getFeaturedProducts({int limit = 6}) {
    return _products
        .where((product) => product.isFeatured)
        .take(limit)
        .toList();
  }

  // Get products by category
  List<Product> getProductsByCategory(String category) {
    return _products.where((product) => product.category == category).toList();
  }

  // Get products by manufacturer
  List<Product> getProductsByManufacturer(String manufacturer) {
    return _products.where((product) => product.manufacturer == manufacturer).toList();
  }

  // Get low stock products
  List<Product> getLowStockProducts() {
    return _products.where((product) => product.isLowStock).toList();
  }

  // Get out of stock products
  List<Product> getOutOfStockProducts() {
    return _products.where((product) => product.stockQuantity == 0).toList();
  }

  // Get discounted products
  List<Product> getDiscountedProducts() {
    return _products.where((product) => product.hasDiscount).toList();
  }

  // Search products
  List<Product> searchProducts(String query) {
    final lowerQuery = query.toLowerCase();
    return _products.where((product) {
      return product.name.toLowerCase().contains(lowerQuery) ||
             product.description.toLowerCase().contains(lowerQuery) ||
             product.category.toLowerCase().contains(lowerQuery) ||
             product.manufacturer.toLowerCase().contains(lowerQuery) ||
             product.ingredients.any((ingredient) => ingredient.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  // Get product statistics
  Map<String, dynamic> getProductStatistics() {
    return {
      'totalProducts': _products.length,
      'totalCategories': _categories.length,
      'totalManufacturers': _manufacturers.length,
      'inStockCount': _products.where((p) => p.stockQuantity > 0).length,
      'lowStockCount': _products.where((p) => p.isLowStock).length,
      'outOfStockCount': _products.where((p) => p.stockQuantity == 0).length,
      'discountedCount': _products.where((p) => p.hasDiscount).length,
      'featuredCount': _products.where((p) => p.isFeatured).length,
      'averageRating': _products.isEmpty ? 0.0 : 
          _products.map((p) => p.rating).reduce((a, b) => a + b) / _products.length,
      'totalValue': _products.fold(0.0, (sum, product) => sum + (product.price * product.stockQuantity)),
    };
  }

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Add product (for admin functionality)
  Future<void> addProduct(Product product) async {
    try {
      await catalogService.addProduct(product, token);
      _products.add(product);
      _applyFiltersAndSearch();
    } catch (e) {
      _error = e.toString();
      
    }
  }

  // Update product (for admin functionality)
  Future<void> updateProduct(Product product) async {
    try {
      await catalogService.updateProduct(product, token);
      final index = _products.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        _products[index] = product;
        _applyFiltersAndSearch();
      }
    } catch (e) {
      _error = e.toString();
      
    }
  }

  // Delete product (for admin functionality)
  Future<void> deleteProduct(String productId) async {
    try {
      await catalogService.deleteProduct(productId, token);
      _products.removeWhere((p) => p.id == productId);
      _applyFiltersAndSearch();
    } catch (e) {
      _error = e.toString();
      
    }
  }
}
