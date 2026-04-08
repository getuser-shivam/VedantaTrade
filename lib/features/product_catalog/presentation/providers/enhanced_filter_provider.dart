import 'package:flutter/foundation.dart';
import '../../domain/entities/product_filter_entity.dart';
import '../../domain/entities/filter_preset_entity.dart';
import '../../domain/entities/filter_history_entity.dart';
import '../../data/services/filter_service.dart';

/// Enhanced Filter Provider
/// Manages filter state, presets, and history
class EnhancedFilterProvider extends ChangeNotifier {
  final FilterService _filterService = FilterService();

  // State
  ProductFilterEntity _currentFilter = const ProductFilterEntity();
  List<FilterPresetEntity> _presets = [];
  List<FilterHistoryEntity> _history = [];
  List<FilterHistoryEntity> _recentHistory = [];
  
  // Loading states
  bool _isLoadingPresets = false;
  bool _isLoadingHistory = false;
  bool _isSavingPreset = false;
  
  // Error state
  String? _errorMessage;

  // Getters
  ProductFilterEntity get currentFilter => _currentFilter;
  List<FilterPresetEntity> get presets => _presets;
  List<FilterHistoryEntity> get history => _history;
  List<FilterHistoryEntity> get recentHistory => _recentHistory;
  bool get isLoadingPresets => _isLoadingPresets;
  bool get isLoadingHistory => _isLoadingHistory;
  bool get isSavingPreset => _isSavingPreset;
  String? get errorMessage => _errorMessage;
  
  bool get hasActiveFilters => _currentFilter.hasActiveFilters;
  int get activeFilterCount => _currentFilter.activeFilterCount;

  // Initialize
  Future<void> initialize() async {
    await Future.wait([
      loadPresets(),
      loadHistory(),
    ]);
  }

  // Update current filter
  void updateFilter(ProductFilterEntity newFilter) {
    _currentFilter = newFilter;
    notifyListeners();
  }

  // Update specific filter field
  void updateFilterField({
    String? searchQuery,
    List<String>? categories,
    List<String>? brands,
    List<String>? manufacturers,
    List<String>? dosageForms,
    List<String>? tags,
    double? minPrice,
    double? maxPrice,
    bool? inStockOnly,
    bool? onSaleOnly,
    bool? requiresPrescription,
    ProductAvailability? availability,
    double? minRating,
    String? sortBy,
    String? sortOrder,
    bool? isActiveOnly,
    DateTime? expiryDateRangeStart,
    DateTime? expiryDateRangeEnd,
  }) {
    _currentFilter = _currentFilter.copyWith(
      searchQuery: searchQuery,
      categories: categories,
      brands: brands,
      manufacturers: manufacturers,
      dosageForms: dosageForms,
      tags: tags,
      minPrice: minPrice,
      maxPrice: maxPrice,
      inStockOnly: inStockOnly,
      onSaleOnly: onSaleOnly,
      requiresPrescription: requiresPrescription,
      availability: availability,
      minRating: minRating,
      sortBy: sortBy,
      sortOrder: sortOrder,
      isActiveOnly: isActiveOnly,
      expiryDateRangeStart: expiryDateRangeStart,
      expiryDateRangeEnd: expiryDateRangeEnd,
    );
    notifyListeners();
  }

  // Clear all filters
  void clearAllFilters() {
    _currentFilter = const ProductFilterEntity();
    notifyListeners();
  }

  // Clear specific filter category
  void clearFilterCategory(String category) {
    _currentFilter = _currentFilter.clearCategory(category);
    notifyListeners();
  }

  // Apply preset
  void applyPreset(FilterPresetEntity preset) {
    _currentFilter = preset.filter;
    _addToHistory(preset.filter);
    notifyListeners();
  }

  // Load presets
  Future<void> loadPresets() async {
    _isLoadingPresets = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _presets = await _filterService.getFilterPresets();
    } catch (e) {
      _errorMessage = 'Failed to load presets: $e';
      debugPrint('Error loading presets: $e');
    } finally {
      _isLoadingPresets = false;
      notifyListeners();
    }
  }

  // Save custom preset
  Future<void> savePreset(String name, String description) async {
    _isSavingPreset = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final preset = FilterPresetEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        description: description,
        icon: Icons.filter_list,
        filter: _currentFilter,
        createdAt: DateTime.now(),
      );
      
      await _filterService.saveFilterPreset(preset);
      await loadPresets();
    } catch (e) {
      _errorMessage = 'Failed to save preset: $e';
      debugPrint('Error saving preset: $e');
    } finally {
      _isSavingPreset = false;
      notifyListeners();
    }
  }

  // Delete preset
  Future<void> deletePreset(String presetId) async {
    try {
      await _filterService.deleteFilterPreset(presetId);
      await loadPresets();
    } catch (e) {
      _errorMessage = 'Failed to delete preset: $e';
      debugPrint('Error deleting preset: $e');
    }
  }

  // Load filter history
  Future<void> loadHistory() async {
    _isLoadingHistory = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _history = await _filterService.getFilterHistory();
      _recentHistory = _history.where((h) => h.isRecent).toList();
    } catch (e) {
      _errorMessage = 'Failed to load history: $e';
      debugPrint('Error loading history: $e');
    } finally {
      _isLoadingHistory = false;
      notifyListeners();
    }
  }

  // Add to history
  void _addToHistory(ProductFilterEntity filter, {int resultCount = 0}) {
    final historyItem = FilterHistoryEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      filter: filter,
      appliedAt: DateTime.now(),
      resultCount: resultCount,
    );
    
    _history.insert(0, historyItem);
    if (_history.length > 50) {
      _history.removeLast();
    }
    
    _recentHistory = _history.where((h) => h.isRecent).toList();
    
    // Persist to storage
    _filterService.saveFilterHistory(_history);
  }

  // Apply history item
  void applyHistoryItem(FilterHistoryEntity historyItem) {
    _currentFilter = historyItem.filter;
    notifyListeners();
  }

  // Clear history
  Future<void> clearHistory() async {
    try {
      _history.clear();
      _recentHistory.clear();
      await _filterService.clearFilterHistory();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to clear history: $e';
      debugPrint('Error clearing history: $e');
    }
  }

  // Get filter summary
  String getFilterSummary() {
    final parts = <String>[];
    
    if (_currentFilter.categories.isNotEmpty) {
      parts.add(_currentFilter.categories.join(', '));
    }
    
    if (_currentFilter.minPrice != null || _currentFilter.maxPrice != null) {
      parts.add(_currentFilter.formattedPriceRange);
    }
    
    if (_currentFilter.minRating != null) {
      parts.add('${_currentFilter.minRating}+ Stars');
    }
    
    if (_currentFilter.inStockOnly == true) {
      parts.add('In Stock');
    }
    
    if (_currentFilter.onSaleOnly == true) {
      parts.add('On Sale');
    }
    
    if (_currentFilter.searchQuery != null && _currentFilter.searchQuery!.isNotEmpty) {
      parts.add('"${_currentFilter.searchQuery}"');
    }
    
    return parts.isEmpty ? 'No filters' : parts.join(' • ');
  }

  // Check if filter matches preset
  bool matchesPreset(FilterPresetEntity preset) {
    return _currentFilter == preset.filter;
  }

  // Reset error
  void resetError() {
    _errorMessage = null;
    notifyListeners();
  }
}
