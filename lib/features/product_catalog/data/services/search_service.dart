import 'package:flutter/foundation.dart';
import '../../domain/entities/search_query_entity.dart';
import '../models/product_model.dart';
import '../services/product_catalog_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Search Service
/// Handles product search, suggestions, and search history
class SearchService {
  final ProductCatalogService _productService = ProductCatalogService();
  static const String _historyKey = 'search_history';
  static const String _trendingKey = 'trending_searches';

  /// Search products with fuzzy matching
  Future<List<Product>> searchProducts(String query) async {
    try {
      final allProducts = await _productService.loadRegisteredProducts();
      
      if (query.isEmpty) {
        return allProducts;
      }

      final lowerQuery = query.toLowerCase();
      final results = <Product>[];

      for (final product in allProducts) {
        final score = _calculateRelevanceScore(product, lowerQuery);
        if (score > 0) {
          results.add(product);
        }
      }

      // Sort by relevance score
      results.sort((a, b) => _calculateRelevanceScore(b, lowerQuery)
          .compareTo(_calculateRelevanceScore(a, lowerQuery)));

      return results;
    } catch (e) {
      debugPrint('Error searching products: $e');
      return [];
    }
  }

  /// Calculate relevance score for fuzzy matching
  int _calculateRelevanceScore(Product product, String query) {
    int score = 0;
    
    // Exact match in name (highest score)
    if (product.name.toLowerCase() == query) {
      score += 100;
    }
    
    // Name contains query
    if (product.name.toLowerCase().contains(query)) {
      score += 50;
    }
    
    // Generic name contains query
    if (product.genericName.toLowerCase().contains(query)) {
      score += 40;
    }
    
    // Manufacturer contains query
    if (product.manufacturer.toLowerCase().contains(query)) {
      score += 30;
    }
    
    // Brand contains query
    if (product.brand.toLowerCase().contains(query)) {
      score += 30;
    }
    
    // Category contains query
    if (product.category.toLowerCase().contains(query)) {
      score += 25;
    }
    
    // Description contains query
    if (product.description.toLowerCase().contains(query)) {
      score += 20;
    }
    
    // Tags contain query
    for (final tag in product.tags) {
      if (tag.toLowerCase().contains(query)) {
        score += 15;
      }
    }
    
    // Fuzzy match for typos (Levenshtein distance)
    if (_isFuzzyMatch(product.name.toLowerCase(), query)) {
      score += 10;
    }
    
    return score;
  }

  /// Fuzzy matching using simple algorithm
  bool _isFuzzyMatch(String text, String query) {
    if (text.length < query.length) return false;
    
    int distance = 0;
    for (int i = 0; i < query.length; i++) {
      if (text[i] != query[i]) {
        distance++;
        if (distance > 2) return false;
      }
    }
    return true;
  }

  /// Get search suggestions
  Future<List<String>> getSearchSuggestions(String query) async {
    try {
      final allProducts = await _productService.loadRegisteredProducts();
      final suggestions = <String>{};
      
      final lowerQuery = query.toLowerCase();
      
      for (final product in allProducts) {
        // Suggest product names
        if (product.name.toLowerCase().startsWith(lowerQuery)) {
          suggestions.add(product.name);
        }
        
        // Suggest categories
        if (product.category.toLowerCase().startsWith(lowerQuery)) {
          suggestions.add(product.category);
        }
        
        // Suggest brands
        if (product.brand.toLowerCase().startsWith(lowerQuery)) {
          suggestions.add(product.brand);
        }
        
        // Suggest manufacturers
        if (product.manufacturer.toLowerCase().startsWith(lowerQuery)) {
          suggestions.add(product.manufacturer);
        }
      }
      
      return suggestions.toList()..take(10);
    } catch (e) {
      debugPrint('Error getting suggestions: $e');
      return [];
    }
  }

  /// Get trending searches
  Future<List<String>> getTrendingSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final trendingJson = prefs.getString(_trendingKey);
      
      if (trendingJson == null) {
        // Return default trending searches
        return [
          'Paracetamol',
          'Amoxicillin',
          'Vitamin C',
          'Ibuprofen',
          'Antibiotics',
          'Pain Relief',
          'Supplements',
          'Diabetes',
        ];
      }

      final List<dynamic> decoded = json.decode(trendingJson);
      return decoded.cast<String>();
    } catch (e) {
      debugPrint('Error loading trending searches: $e');
      return [];
    }
  }

  /// Update trending searches
  Future<void> updateTrendingSearches(List<String> searches) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final trendingJson = json.encode(searches.take(10).toList());
      await prefs.setString(_trendingKey, trendingJson);
    } catch (e) {
      debugPrint('Error updating trending searches: $e');
    }
  }

  /// Get search history
  Future<List<SearchQueryEntity>> getSearchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(_historyKey);
      
      if (historyJson == null) {
        return [];
      }

      final List<dynamic> decoded = json.decode(historyJson);
      return decoded
          .map((json) => SearchQueryEntity.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error loading search history: $e');
      return [];
    }
  }

  /// Save search history
  Future<void> saveSearchHistory(List<SearchQueryEntity> history) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = json.encode(
        history.map((h) => h.toJson()).toList(),
      );
      await prefs.setString(_historyKey, historyJson);
    } catch (e) {
      debugPrint('Error saving search history: $e');
    }
  }

  /// Clear search history
  Future<void> clearSearchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_historyKey);
    } catch (e) {
      debugPrint('Error clearing search history: $e');
    }
  }

  /// Get autocomplete suggestions
  Future<List<String>> getAutocompleteSuggestions(String partialQuery) async {
    try {
      final suggestions = await getSearchSuggestions(partialQuery);
      final history = await getSearchHistory();
      
      // Add history matches
      for (final item in history) {
        if (item.query.toLowerCase().startsWith(partialQuery.toLowerCase()) &&
            !suggestions.contains(item.query)) {
          suggestions.insert(0, item.query);
        }
      }
      
      return suggestions.take(10).toList();
    } catch (e) {
      debugPrint('Error getting autocomplete: $e');
      return [];
    }
  }
}
