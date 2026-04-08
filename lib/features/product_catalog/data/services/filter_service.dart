import 'package:flutter/foundation.dart';
import '../../domain/entities/filter_preset_entity.dart';
import '../../domain/entities/filter_history_entity.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Filter Service
/// Manages filter presets and history persistence
class FilterService {
  static const String _presetsKey = 'filter_presets';
  static const String _historyKey = 'filter_history';

  /// Get filter presets from storage
  Future<List<FilterPresetEntity>> getFilterPresets() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final presetsJson = prefs.getString(_presetsKey);
      
      if (presetsJson == null) {
        return [];
      }

      final List<dynamic> decoded = json.decode(presetsJson);
      return decoded
          .map((json) => FilterPresetEntity.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error loading filter presets: $e');
      return [];
    }
  }

  /// Save filter preset
  Future<void> saveFilterPreset(FilterPresetEntity preset) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final presets = await getFilterPresets();
      
      // Check if preset already exists
      final existingIndex = presets.indexWhere((p) => p.id == preset.id);
      if (existingIndex != -1) {
        presets[existingIndex] = preset;
      } else {
        presets.add(preset);
      }

      final presetsJson = json.encode(
        presets.map((p) => p.toJson()).toList(),
      );
      await prefs.setString(_presetsKey, presetsJson);
    } catch (e) {
      debugPrint('Error saving filter preset: $e');
      rethrow;
    }
  }

  /// Delete filter preset
  Future<void> deleteFilterPreset(String presetId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final presets = await getFilterPresets();
      
      presets.removeWhere((p) => p.id == presetId);

      final presetsJson = json.encode(
        presets.map((p) => p.toJson()).toList(),
      );
      await prefs.setString(_presetsKey, presetsJson);
    } catch (e) {
      debugPrint('Error deleting filter preset: $e');
      rethrow;
    }
  }

  /// Get filter history from storage
  Future<List<FilterHistoryEntity>> getFilterHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(_historyKey);
      
      if (historyJson == null) {
        return [];
      }

      final List<dynamic> decoded = json.decode(historyJson);
      return decoded
          .map((json) => FilterHistoryEntity.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error loading filter history: $e');
      return [];
    }
  }

  /// Save filter history
  Future<void> saveFilterHistory(List<FilterHistoryEntity> history) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final historyJson = json.encode(
        history.map((h) => h.toJson()).toList(),
      );
      await prefs.setString(_historyKey, historyJson);
    } catch (e) {
      debugPrint('Error saving filter history: $e');
    }
  }

  /// Clear filter history
  Future<void> clearFilterHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_historyKey);
    } catch (e) {
      debugPrint('Error clearing filter history: $e');
      rethrow;
    }
  }

  /// Get available filter options from products
  Future<Map<String, List<String>>> getFilterOptions(List<dynamic> products) async {
    final categories = <String>{};
    final brands = <String>{};
    final manufacturers = <String>{};
    final dosageForms = <String>{};
    final tags = <String>{};

    for (final product in products) {
      if (product['category'] != null) {
        categories.add(product['category']);
      }
      if (product['brand'] != null) {
        brands.add(product['brand']);
      }
      if (product['manufacturer'] != null) {
        manufacturers.add(product['manufacturer']);
      }
      if (product['dosageForm'] != null) {
        dosageForms.add(product['dosageForm']);
      }
      if (product['tags'] != null) {
        for (final tag in product['tags']) {
          tags.add(tag);
        }
      }
    }

    return {
      'categories': categories.toList()..sort(),
      'brands': brands.toList()..sort(),
      'manufacturers': manufacturers.toList()..sort(),
      'dosageForms': dosageForms.toList()..sort(),
      'tags': tags.toList()..sort(),
    };
  }

  /// Get price range from products
  Future<Map<String, double>> getPriceRange(List<dynamic> products) async {
    if (products.isEmpty) {
      return {'min': 0.0, 'max': 1000.0};
    }

    double minPrice = double.infinity;
    double maxPrice = double.negativeInfinity;

    for (final product in products) {
      final price = (product['price'] ?? 0.0).toDouble();
      if (price < minPrice) minPrice = price;
      if (price > maxPrice) maxPrice = price;
    }

    return {
      'min': minPrice.isFinite ? minPrice : 0.0,
      'max': maxPrice.isFinite ? maxPrice : 1000.0,
    };
  }
}
