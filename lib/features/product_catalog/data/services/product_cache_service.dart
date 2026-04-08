import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/product_model.dart';

/// Product Cache Service
/// Handles offline caching of product data for improved performance and offline access
class ProductCacheService {
  static const String _cachedProductsKey = 'cached_products';
  static const String _cacheTimestampKey = 'cache_timestamp';
  static const String _categoriesKey = 'cached_categories';
  static const Duration _cacheExpiry = Duration(hours: 24);

  /// Cache products locally
  Future<void> cacheProducts(List<Product> products) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final productsJson = json.encode(
        products.map((p) => p.toJson()).toList(),
      );
      final timestamp = DateTime.now().toIso8601String();

      await prefs.setString(_cachedProductsKey, productsJson);
      await prefs.setString(_cacheTimestampKey, timestamp);

      debugPrint('Cached ${products.length} products');
    } catch (e) {
      debugPrint('Error caching products: $e');
    }
  }

  /// Get cached products
  Future<List<Product>?> getCachedProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final productsJson = prefs.getString(_cachedProductsKey);
      final timestamp = prefs.getString(_cacheTimestampKey);

      if (productsJson == null || timestamp == null) {
        return null;
      }

      // Check if cache is expired
      final cacheTime = DateTime.parse(timestamp);
      if (DateTime.now().difference(cacheTime) > _cacheExpiry) {
        await clearCache();
        return null;
      }

      final productsList = json.decode(productsJson) as List;
      return productsList.map((json) => Product.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error getting cached products: $e');
      return null;
    }
  }

  /// Cache categories
  Future<void> cacheCategories(List<dynamic> categories) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final categoriesJson = json.encode(categories);
      await prefs.setString(_categoriesKey, categoriesJson);
      debugPrint('Cached ${categories.length} categories');
    } catch (e) {
      debugPrint('Error caching categories: $e');
    }
  }

  /// Get cached categories
  Future<List<dynamic>?> getCachedCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final categoriesJson = prefs.getString(_categoriesKey);

      if (categoriesJson == null) {
        return null;
      }

      return json.decode(categoriesJson) as List;
    } catch (e) {
      debugPrint('Error getting cached categories: $e');
      return null;
    }
  }

  /// Check if cache is valid (not expired)
  Future<bool> isCacheValid() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getString(_cacheTimestampKey);

      if (timestamp == null) {
        return false;
      }

      final cacheTime = DateTime.parse(timestamp);
      return DateTime.now().difference(cacheTime) < _cacheExpiry;
    } catch (e) {
      debugPrint('Error checking cache validity: $e');
      return false;
    }
  }

  /// Clear all cached data
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cachedProductsKey);
      await prefs.remove(_cacheTimestampKey);
      await prefs.remove(_categoriesKey);
      debugPrint('Cleared product cache');
    } catch (e) {
      debugPrint('Error clearing cache: $e');
    }
  }

  /// Get cache size in bytes (approximate)
  Future<int> getCacheSize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final productsJson = prefs.getString(_cachedProductsKey) ?? '';
      final categoriesJson = prefs.getString(_categoriesKey) ?? '';
      return productsJson.length + categoriesJson.length;
    } catch (e) {
      debugPrint('Error getting cache size: $e');
      return 0;
    }
  }
}
