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
          headers: token != null ? {'Authorization': 'Bearer $token'} : {},
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

  Future<List<Category>> loadCategories({String? token}) async {
    try {
      final response = await _dio.get(
        ApiConfig.categories,
        options: Options(
          headers: token != null ? {'Authorization': 'Bearer $token'} : {},
        ),
      );
      
      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => Category.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      
      // Fallback to local
      try {
        final String response = await rootBundle.loadString('assets/data/products.json');
        final List<dynamic> data = json.decode(response);
        final Set<String> categoryNames = data.map((j) => (j['category'] ?? 'Uncategorized') as String).toSet();
        return categoryNames.map((name) => Category(name: name)).toList();
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
        options: Options(
          headers: token != null ? {'Authorization': 'Bearer $token'} : {},
        ),
      );
      
      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => Product.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      
      return [];
    }
  }
}
