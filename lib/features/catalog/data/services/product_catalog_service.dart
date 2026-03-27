import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:vedanta_trade/core/api_config.dart';
import 'package:vedanta_trade/features/catalog/domain/models/product.dart';

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
    // This could still be used as a fallback
    return [];
  }

  Future<List<String>> loadCategories({String? token}) async {
    try {
      final response = await _dio.get(
        ApiConfig.categories,
        options: Options(
          headers: token != null ? {'Authorization': 'Bearer $token'} : {},
        ),
      );
      
      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => json['name'] as String).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Failed to load categories: $e');
      return [];
    }
  }
}
