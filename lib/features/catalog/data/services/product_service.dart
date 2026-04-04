import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/product_model.dart';
import '../../../../shared/utils/error_handling_utils.dart';
import '../../../../shared/utils/nepal_localization_utils.dart';

/// Product Service for VedantaTrade Catalog
class ProductService {
  static final ProductService _instance = ProductService._internal();
  factory ProductService() => _instance;
  ProductService._internal();

  final Dio _dio;
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  ProductFilter? _currentFilter;
  Timer? _debounceTimer;

  ProductService() : _dio = Dio() {
    _setupDioClient();
    _loadCachedProducts();
  }

  /// Setup Dio client with Nepal-specific configurations
  void _setupDioClient() {
    _dio.options = BaseOptions(
      baseUrl: 'https://api.vedantatrade.com.np',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'X-Country': 'NP',
        'X-Currency': 'NPR',
        'X-Timezone': 'Asia/Kathmandu',
      },
    );

    // Add request interceptor for authentication
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('auth_token');
          
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          
          handler.next(options);
        },
        onError: (error, handler) async {
          print('Product Service Error: ${error.message}');
          handler.next(error);
        },
      ),
    );
  }

  /// Load cached products from storage
  Future<void> _loadCachedProducts() async {
    try {
      print('📦 Loading cached products...');
      
      final prefs = await SharedPreferences.getInstance();
      final productsJson = prefs.getString('cached_products');
      
      if (productsJson != null) {
        final productsList = List<Map<String, dynamic>>.from(
          jsonDecode(productsJson!)
        );
        
        _products = productsList
            .map((json) => Product.fromJson(json))
            .toList();
        
        _filteredProducts = List.from(_products);
        print('✅ Loaded ${_products.length} cached products');
      }
      
    } catch (e) {
      print('❌ Failed to load cached products: $e');
    }
  }

  /// Cache products to storage
  Future<void> _cacheProducts() async {
    try {
      print('💾 Caching products...');
      
      final prefs = await SharedPreferences.getInstance();
      final productsJson = jsonEncode(
        _products.map((product) => product.toJson()).toList(),
      );
      
      await prefs.setString('cached_products', productsJson);
      await prefs.setString('last_products_update', DateTime.now().toIso8601String());
      
      print('✅ Products cached successfully');
      
    } catch (e) {
      print('❌ Failed to cache products: $e');
    }
  }

  /// Get all products
  List<Product> get products => List.unmodifiable(_products);

  /// Get filtered products
  List<Product> get filteredProducts => List.unmodifiable(_filteredProducts);

  /// Fetch products from server
  Future<List<Product>> fetchProducts({bool forceRefresh = false}) async {
    try {
      print('📡 Fetching products from server...');
      
      // Check if we need to refresh
      if (!forceRefresh) {
        final prefs = await SharedPreferences.getInstance();
        final lastUpdate = prefs.getString('last_products_update');
        
        if (lastUpdate != null) {
          final lastUpdateTime = DateTime.parse(lastUpdate);
          final timeSinceUpdate = DateTime.now().difference(lastUpdateTime);
          
          // Use cached data if less than 5 minutes old
          if (timeSinceUpdate.inMinutes < 5) {
            print('📱 Using cached products (${timeSinceUpdate.inMinutes}m old)');
            return _products;
          }
        }
      }

      final response = await _dio.get('/api/products');
      
      if (response.statusCode == 200) {
        final productsData = response.data['products'] as List;
        final newProducts = productsData
            .map((json) => Product.fromJson(json))
            .toList();
        
        _products = newProducts;
        _applyCurrentFilter();
        await _cacheProducts();
        
        print('✅ Fetched ${newProducts.length} products from server');
        return newProducts;
      } else {
        throw Exception('Failed to fetch products: ${response.statusCode}');
      }
      
    } catch (e) {
      print('❌ Failed to fetch products: $e');
      // Return cached products if available
      if (_products.isNotEmpty) {
        print('📱 Falling back to cached products');
        return _products;
      }
      throw Exception('Failed to fetch products: $e');
    }
  }

  /// Get product by ID
  Product? getProductById(String productId) {
    try {
      return _products.firstWhere(
        (product) => product.id == productId,
        orElse: () => null as Product,
      );
    } catch (e) {
      print('❌ Failed to get product by ID: $e');
      return null;
    }
  }

  /// Search products
  Future<List<Product>> searchProducts(String query) async {
    try {
      print('🔍 Searching products: $query');
      
      final response = await _dio.get(
        '/api/products/search',
        queryParameters: {'q': query},
      );
      
      if (response.statusCode == 200) {
        final productsData = response.data['products'] as List;
        final searchResults = productsData
            .map((json) => Product.fromJson(json))
            .toList();
        
        print('✅ Found ${searchResults.length} search results');
        return searchResults;
      } else {
        throw Exception('Failed to search products: ${response.statusCode}');
      }
      
    } catch (e) {
      print('❌ Failed to search products: $e');
      throw Exception('Failed to search products: $e');
    }
  }

  /// Get products by category
  List<Product> getProductsByCategory(String category) {
    return _products.where((product) => product.category == category).toList();
  }

  /// Get products by manufacturer
  List<Product> getProductsByManufacturer(String manufacturer) {
    return _products.where((product) => 
        product.manufacturer.toLowerCase().contains(manufacturer.toLowerCase())
    ).toList();
  }

  /// Get in-stock products
  List<Product> getInStockProducts() {
    return _products.where((product) => product.isInStock).toList();
  }

  /// Get low stock products
  List<Product> getLowStockProducts() {
    return _products.where((product) => product.isLowStock).toList();
  }

  /// Get expiring products
  List<Product> getExpiringProducts() {
    return _products.where((product) => product.isExpiringSoon).toList();
  }

  /// Get expired products
  List<Product> getExpiredProducts() {
    return _products.where((product) => product.isExpired).toList();
  }

  /// Get prescription products
  List<Product> getPrescriptionProducts() {
    return _products.where((product) => product.isPrescription).toList();
  }

  /// Get controlled products
  List<Product> getControlledProducts() {
    return _products.where((product) => product.isControlled).toList();
  }

  /// Apply filter to products
  void applyFilter(ProductFilter filter) {
    _currentFilter = filter;
    _applyCurrentFilter();
  }

  /// Apply current filter to products
  void _applyCurrentFilter() {
    if (_currentFilter == null) {
      _filteredProducts = List.from(_products);
      return;
    }

    _filteredProducts = _products.where((product) => _currentFilter!.matches(product)).toList();
    
    print('🔍 Filter applied: ${_filteredProducts.length} products match filter');
  }

  /// Clear current filter
  void clearFilter() {
    _currentFilter = null;
    _filteredProducts = List.from(_products);
    print('🗑️ Filter cleared');
  }

  /// Get product categories
  List<String> getCategories() {
    final categories = _products.map((product) => product.category).toSet().toList();
    categories.sort();
    return categories;
  }

  /// Get manufacturers
  List<String> getManufacturers() {
    final manufacturers = _products.map((product) => product.manufacturer).toSet().toList();
    manufacturers.sort();
    return manufacturers;
  }

  /// Get product statistics
  Map<String, dynamic> getProductStatistics() {
    final totalProducts = _products.length;
    final inStockProducts = _products.where((p) => p.isInStock).length;
    final outOfStockProducts = _products.where((p) => !p.isInStock).length;
    final lowStockProducts = _products.where((p) => p.isLowStock).length;
    final expiringProducts = _products.where((p) => p.isExpiringSoon).length;
    final expiredProducts = _products.where((p) => p.isExpired).length;
    final prescriptionProducts = _products.where((p) => p.isPrescription).length;
    final controlledProducts = _products.where((p) => p.isControlled).length;

    return {
      'totalProducts': totalProducts,
      'inStockProducts': inStockProducts,
      'outOfStockProducts': outOfStockProducts,
      'lowStockProducts': lowStockProducts,
      'expiringProducts': expiringProducts,
      'expiredProducts': expiredProducts,
      'prescriptionProducts': prescriptionProducts,
      'controlledProducts': controlledProducts,
      'inStockPercentage': totalProducts > 0 ? (inStockProducts / totalProducts * 100).round() : 0,
      'outOfStockPercentage': totalProducts > 0 ? (outOfStockProducts / totalProducts * 100).round() : 0,
      'lowStockPercentage': totalProducts > 0 ? (lowStockProducts / totalProducts * 100).round() : 0,
      'expiringPercentage': totalProducts > 0 ? (expiringProducts / totalProducts * 100).round() : 0,
      'expiredPercentage': totalProducts > 0 ? (expiredProducts / totalProducts * 100).round() : 0,
    };
  }

  /// Create new product
  Future<Product?> createProduct(CreateProductRequest request) async {
    try {
      print('📝 Creating new product...');
      
      final response = await _dio.post(
        '/api/products',
        data: request.toJson(),
      );
      
      if (response.statusCode == 201) {
        final productData = response.data['product'];
        final newProduct = Product.fromJson(productData);
        
        _products.insert(0, newProduct);
        _applyCurrentFilter();
        await _cacheProducts();
        
        print('✅ Product created successfully: ${newProduct.id}');
        return newProduct;
      } else {
        throw Exception('Failed to create product: ${response.statusCode}');
      }
      
    } catch (e) {
      print('❌ Failed to create product: $e');
      throw Exception('Failed to create product: $e');
    }
  }

  /// Update existing product
  Future<bool> updateProduct(Product product) async {
    try {
      print('📝 Updating product: ${product.id}');
      
      final response = await _dio.put(
        '/api/products/${product.id}',
        data: product.toJson(),
      );
      
      if (response.statusCode == 200) {
        final productData = response.data['product'];
        final updatedProduct = Product.fromJson(productData);
        
        final index = _products.indexWhere((p) => p.id == product.id);
        if (index != -1) {
          _products[index] = updatedProduct;
          _applyCurrentFilter();
          await _cacheProducts();
        }
        
        print('✅ Product updated successfully: ${updatedProduct.id}');
        return true;
      } else {
        throw Exception('Failed to update product: ${response.statusCode}');
      }
      
    } catch (e) {
      print('❌ Failed to update product: $e');
      throw Exception('Failed to update product: $e');
    }
  }

  /// Delete product
  Future<bool> deleteProduct(String productId) async {
    try {
      print('🗑️ Deleting product: $productId');
      
      final response = await _dio.delete('/api/products/$productId');
      
      if (response.statusCode == 200) {
        _products.removeWhere((product) => product.id == productId);
        _applyCurrentFilter();
        await _cacheProducts();
        
        print('✅ Product deleted successfully: $productId');
        return true;
      } else {
        throw Exception('Failed to delete product: ${response.statusCode}');
      }
      
    } catch (e) {
      print('❌ Failed to delete product: $e');
      throw Exception('Failed to delete product: $e');
    }
  }

  /// Update product stock
  Future<bool> updateProductStock(String productId, int quantity) async {
    try {
      print('📦 Updating product stock: $productId -> $quantity');
      
      final response = await _dio.patch(
        '/api/products/$productId/stock',
        data: {'quantity': quantity},
      );
      
      if (response.statusCode == 200) {
        final productData = response.data['product'];
        final updatedProduct = Product.fromJson(productData);
        
        final index = _products.indexWhere((p) => p.id == productId);
        if (index != -1) {
          _products[index] = updatedProduct;
          _applyCurrentFilter();
          await _cacheProducts();
        }
        
        print('✅ Product stock updated successfully: $productId');
        return true;
      } else {
        throw Exception('Failed to update product stock: ${response.statusCode}');
      }
      
    } catch (e) {
      print('❌ Failed to update product stock: $e');
      throw Exception('Failed to update product stock: $e');
    }
  }

  /// Get products by price range
  List<Product> getProductsByPriceRange(double minPrice, double maxPrice) {
    return _products.where((product) => 
        product.price >= minPrice && product.price <= maxPrice
    ).toList();
  }

  /// Get products by tags
  List<Product> getProductsByTags(List<String> tags) {
    return _products.where((product) => 
        tags.any((tag) => product.tags.contains(tag))
    ).toList();
  }

  /// Get featured products
  List<Product> getFeaturedProducts() {
    return _products.where((product) => 
        product.tags.contains('featured') || product.discountedPrice != null
    ).toList();
  }

  /// Get new arrivals
  List<Product> getNewArrivals({int days = 7}) {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    return _products.where((product) => 
        product.createdAt.isAfter(cutoffDate)
    ).toList();
  }

  /// Get best selling products
  List<Product> getBestSellingProducts({int limit = 10}) {
    // This would typically come from sales data
    // For now, return products with high stock and good ratings
    return _products
        .where((product) => product.isInStock && !product.isPrescription)
        .take(limit)
        .toList();
  }

  /// Clear cached data
  Future<void> clearCache() async {
    try {
      print('🗑️ Clearing product cache...');
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('cached_products');
      await prefs.remove('last_products_update');
      
      _products.clear();
      _filteredProducts.clear();
      _currentFilter = null;
      
      print('✅ Product cache cleared');
      
    } catch (e) {
      print('❌ Failed to clear cache: $e');
    }
  }

  /// Dispose resources
  void dispose() {
    _debounceTimer?.cancel();
    _products.clear();
    _filteredProducts.clear();
    print('🗑️ Product service disposed');
  }
}

/// Create Product Request Model
class CreateProductRequest {
  final String name;
  final String description;
  final String category;
  final String manufacturer;
  final String sku;
  final double price;
  final double? discountedPrice;
  final int stockQuantity;
  final int minOrderQuantity;
  final String unit;
  final List<String> images;
  final List<ProductSpecification> specifications;
  final String? batchNumber;
  final DateTime? expiryDate;
  final double? weight;
  final double? volume;
  final String? storageConditions;
  final List<String> tags;
  final bool isPrescription;
  final bool isControlled;
  final String? regulatoryInfo;
  final double? vatRate;
  final String? hsnCode;

  CreateProductRequest({
    required this.name,
    required this.description,
    required this.category,
    required this.manufacturer,
    required this.sku,
    required this.price,
    required this.stockQuantity,
    required this.minOrderQuantity,
    required this.unit,
    required this.images,
    required this.specifications,
    this.discountedPrice,
    this.batchNumber,
    this.expiryDate,
    this.weight,
    this.volume,
    this.storageConditions,
    this.tags = const [],
    this.isPrescription = false,
    this.isControlled = false,
    this.regulatoryInfo,
    this.vatRate,
    this.hsnCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'manufacturer': manufacturer,
      'sku': sku,
      'price': price,
      'discountedPrice': discountedPrice,
      'stockQuantity': stockQuantity,
      'minOrderQuantity': minOrderQuantity,
      'unit': unit,
      'images': images,
      'specifications': specifications.map((spec) => spec.toJson()).toList(),
      'batchNumber': batchNumber,
      'expiryDate': expiryDate?.toIso8601String(),
      'weight': weight,
      'volume': volume,
      'storageConditions': storageConditions,
      'tags': tags,
      'isPrescription': isPrescription,
      'isControlled': isControlled,
      'regulatoryInfo': regulatoryInfo,
      'vatRate': vatRate,
      'hsnCode': hsnCode,
    };
  }
}
