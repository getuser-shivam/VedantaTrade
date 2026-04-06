import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:vedanta_trade/core/api_config.dart';
import '../models/product_model.dart';

class ProductCatalogService {
  final Dio _dio = Dio();
  
  ProductCatalogService() {
    _dio.options.baseUrl = ApiConfig.baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
  }

  Future<List<Product>> loadRegisteredProducts({String? category, String? token}) async {
    try {
      final response = await _dio.get(
        ApiConfig.products,
        queryParameters: {
          if (category != null && category != 'All') 'category': category,
        },
        options: Options(
// headers: token != null ? {'Authorization': 'Bearer $token'} : {}, // TODO: Move to environment variables
        ),
      );
      
      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => Product.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      // Fallback to local data if API fails (useful for offline demo or initial load)
      return _loadLocalProducts();
    }
  }

  Future<List<Product>> _loadLocalProducts() async {
    try {
      final String response = await rootBundle.loadString('assets/data/products.json');
      final List<dynamic> data = json.decode(response);
      return data.map((json) => Product.fromJson(json)).toList();
    } catch (e) {
      
      return [];
    }
  }

  Future<List<ProductCategory>> loadCategories({String? token}) async {
    try {
      final response = await _dio.get(
        ApiConfig.categories,
      );
      
      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => ProductCategory.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      // Fallback to local
      try {
        final String response = await rootBundle.loadString('assets/data/products.json');
        final List<dynamic> data = json.decode(response);
        final Set<String> categoryNames = data.map((j) => (j['category'] ?? 'Uncategorized') as String).toSet();
        return categoryNames.map((name) => ProductCategory(
          id: name.toLowerCase().replaceAll(' ', '_'),
          name: name,
          description: 'Explore our range of $name products',
        )).toList();
      } catch (_) {
        return [];
      }
    }
  }

  Future<List<Product>> loadMoreProducts({
    String? category,
    String? searchQuery,
    String? sortOption,
    int startIndex = 0,
    int limit = 20,
    String? token,
  }) async {
    try {
      final response = await _dio.get(
        ApiConfig.products,
        queryParameters: {
          if (category != null && category != 'All') 'category': category,
          if (searchQuery != null && searchQuery.isNotEmpty) 'search': searchQuery,
          if (sortOption != null) 'sort': sortOption,
          'start': startIndex.toString(),
          'limit': limit.toString(),
        },
      );
      
      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => Product.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      // Fallback to local
      final String data = await rootBundle.loadString('assets/data/products.json');
      final List<dynamic> jsonList = json.decode(data);
      List<Product> products = jsonList.map((j) => Product.fromJson(j)).toList();
      
      // Basic local filtering
      if (category != null && category != 'All') {
        products = products.where((p) => p.category == category).toList();
      }
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        products = products.where((p) => 
          p.name.toLowerCase().contains(query) || 
          p.genericName.toLowerCase().contains(query) ||
          p.description.toLowerCase().contains(query)).toList();
      }
      
      // Basic pagination
      if (startIndex >= products.length) return [];
      final end = (startIndex + limit) > products.length ? products.length : (startIndex + limit);
      return products.sublist(startIndex, end);
    }
  }

  Future<List<Product>> getProducts({
    String? category,
    String? search,
    String? sortBy,
    bool? inStock,
    int page = 1,
    int limit = 20,
    String? token,
  }) async {
    final startIndex = (page - 1) * limit;
    return loadMoreProducts(
      category: category,
      searchQuery: search,
      sortOption: sortBy,
      startIndex: startIndex,
      limit: limit,
      token: token,
    );
  }

  Future<List<ProductCategory>> getCategories() async {
    return loadCategories();
  }

  Future<List<Product>> searchProducts(String query) async {
    return getProducts(search: query);
  }

  Future<List<Product>> getFeaturedProducts() async {
    final products = await loadRegisteredProducts();
    return products.where((p) => p.rating >= 4.5).toList();
  }

  Future<List<Product>> getLowStockProducts() async {
    final products = await loadRegisteredProducts();
    return products.where((p) => p.isLowStock).toList();
  }

  Future<List<Product>> getExpiringSoonProducts() async {
    final products = await loadRegisteredProducts();
    return products.where((p) => p.isExpiringSoon).toList();
  }

  Future<void> updateProduct(Product product) async {
    debugPrint('Updating product: ${product.name}');
  }

  Future<void> deleteProduct(String productId) async {
    debugPrint('Deleting product: $productId');
  }
}
