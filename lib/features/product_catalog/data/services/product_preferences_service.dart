import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Product Preferences Service
/// Handles persistent storage for favorites, comparison, and recent searches
class ProductPreferencesService {
  static const _storage = FlutterSecureStorage();
  static const String _favoritesKey = 'product_favorites';
  static const String _comparisonKey = 'product_comparison';
  static const String _recentSearchesKey = 'recent_searches';

  /// Save favorite product IDs
  Future<void> saveFavorites(List<String> favoriteIds) async {
    try {
      final favoritesJson = json.encode(favoriteIds);
      await _storage.write(key: _favoritesKey, value: favoritesJson);
      debugPrint('Saved ${favoriteIds.length} favorites');
    } catch (e) {
      debugPrint('Error saving favorites: $e');
    }
  }

  /// Get favorite product IDs
  Future<List<String>> getFavorites() async {
    try {
      final favoritesJson = await _storage.read(key: _favoritesKey);
      if (favoritesJson == null) {
        return [];
      }
      final favoritesList = json.decode(favoritesJson) as List;
      return favoritesList.map((id) => id.toString()).toList();
    } catch (e) {
      debugPrint('Error getting favorites: $e');
      return [];
    }
  }

  /// Add product to favorites
  Future<void> addFavorite(String productId) async {
    try {
      final favorites = await getFavorites();
      if (!favorites.contains(productId)) {
        favorites.add(productId);
        await saveFavorites(favorites);
      }
    } catch (e) {
      debugPrint('Error adding favorite: $e');
    }
  }

  /// Remove product from favorites
  Future<void> removeFavorite(String productId) async {
    try {
      final favorites = await getFavorites();
      favorites.remove(productId);
      await saveFavorites(favorites);
    } catch (e) {
      debugPrint('Error removing favorite: $e');
    }
  }

  /// Check if product is in favorites
  Future<bool> isFavorite(String productId) async {
    final favorites = await getFavorites();
    return favorites.contains(productId);
  }

  /// Save comparison product IDs
  Future<void> saveComparison(List<String> comparisonIds) async {
    try {
      final comparisonJson = json.encode(comparisonIds);
      await _storage.write(key: _comparisonKey, value: comparisonJson);
      debugPrint('Saved ${comparisonIds.length} comparison products');
    } catch (e) {
      debugPrint('Error saving comparison: $e');
    }
  }

  /// Get comparison product IDs
  Future<List<String>> getComparison() async {
    try {
      final comparisonJson = await _storage.read(key: _comparisonKey);
      if (comparisonJson == null) {
        return [];
      }
      final comparisonList = json.decode(comparisonJson) as List;
      return comparisonList.map((id) => id.toString()).toList();
    } catch (e) {
      debugPrint('Error getting comparison: $e');
      return [];
    }
  }

  /// Add product to comparison
  Future<void> addToComparison(String productId) async {
    try {
      final comparison = await getComparison();
      if (!comparison.contains(productId) && comparison.length < 4) {
        comparison.add(productId);
        await saveComparison(comparison);
      }
    } catch (e) {
      debugPrint('Error adding to comparison: $e');
    }
  }

  /// Remove product from comparison
  Future<void> removeFromComparison(String productId) async {
    try {
      final comparison = await getComparison();
      comparison.remove(productId);
      await saveComparison(comparison);
    } catch (e) {
      debugPrint('Error removing from comparison: $e');
    }
  }

  /// Clear comparison
  Future<void> clearComparison() async {
    try {
      await _storage.delete(key: _comparisonKey);
      debugPrint('Cleared comparison products');
    } catch (e) {
      debugPrint('Error clearing comparison: $e');
    }
  }

  /// Save recent searches
  Future<void> saveRecentSearches(List<String> searches) async {
    try {
      final searchesJson = json.encode(searches);
      await _storage.write(key: _recentSearchesKey, value: searchesJson);
      debugPrint('Saved ${searches.length} recent searches');
    } catch (e) {
      debugPrint('Error saving recent searches: $e');
    }
  }

  /// Get recent searches
  Future<List<String>> getRecentSearches() async {
    try {
      final searchesJson = await _storage.read(key: _recentSearchesKey);
      if (searchesJson == null) {
        return [];
      }
      final searchesList = json.decode(searchesJson) as List;
      return searchesList.map((search) => search.toString()).toList();
    } catch (e) {
      debugPrint('Error getting recent searches: $e');
      return [];
    }
  }

  /// Add search to recent searches
  Future<void> addRecentSearch(String searchQuery) async {
    try {
      final searches = await getRecentSearches();
      searches.remove(searchQuery);
      searches.insert(0, searchQuery);
      if (searches.length > 10) {
        searches.removeLast();
      }
      await saveRecentSearches(searches);
    } catch (e) {
      debugPrint('Error adding recent search: $e');
    }
  }

  /// Clear recent searches
  Future<void> clearRecentSearches() async {
    try {
      await _storage.delete(key: _recentSearchesKey);
      debugPrint('Cleared recent searches');
    } catch (e) {
      debugPrint('Error clearing recent searches: $e');
    }
  }

  /// Clear all preferences
  Future<void> clearAll() async {
    try {
      await _storage.delete(key: _favoritesKey);
      await _storage.delete(key: _comparisonKey);
      await _storage.delete(key: _recentSearchesKey);
      debugPrint('Cleared all product preferences');
    } catch (e) {
      debugPrint('Error clearing preferences: $e');
    }
  }
}
