import 'package:flutter/foundation.dart';
import '../../domain/entities/search_query_entity.dart';
import '../../data/services/search_service.dart';
import '../../data/models/product_model.dart';

/// Search Provider
/// Manages search state, history, and suggestions
class SearchProvider extends ChangeNotifier {
  final SearchService _searchService = SearchService();

  // State
  String _currentQuery = '';
  List<Product> _searchResults = [];
  List<SearchQueryEntity> _searchHistory = [];
  List<String> _suggestions = [];
  List<String> _trendingSearches = [];
  
  // Loading states
  bool _isSearching = false;
  bool _isLoadingHistory = false;
  bool _isLoadingSuggestions = false;
  
  // Debounce timer
  DateTime? _lastSearchTime;
  static const Duration _debounceDelay = Duration(milliseconds: 500);

  // Error state
  String? _errorMessage;

  // Getters
  String get currentQuery => _currentQuery;
  List<Product> get searchResults => _searchResults;
  List<SearchQueryEntity> get searchHistory => _searchHistory;
  List<String> get suggestions => _suggestions;
  List<String> get trendingSearches => _trendingSearches;
  bool get isSearching => _isSearching;
  bool get isLoadingHistory => _isLoadingHistory;
  bool get isLoadingSuggestions => _isLoadingSuggestions;
  String? get errorMessage => _errorMessage;
  bool get hasQuery => _currentQuery.isNotEmpty;
  int get resultCount => _searchResults.length;

  // Initialize
  Future<void> initialize() async {
    await Future.wait([
      loadSearchHistory(),
      loadTrendingSearches(),
    ]);
  }

  // Update search query with debouncing
  void updateQuery(String query) {
    _currentQuery = query;
    notifyListeners();

    if (query.isEmpty) {
      _searchResults.clear();
      _suggestions.clear();
      notifyListeners();
      return;
    }

    // Debounce search
    final now = DateTime.now();
    _lastSearchTime = now;
    
    Future.delayed(_debounceDelay, () {
      if (_lastSearchTime == now && _currentQuery == query) {
        performSearch(query);
      }
    });
  }

  // Perform search immediately
  Future<void> performSearch(String query) async {
    if (query.isEmpty) {
      _searchResults.clear();
      notifyListeners();
      return;
    }

    _isSearching = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await _searchService.searchProducts(query);
      _searchResults = results;
      
      // Add to history
      if (results.isNotEmpty) {
        await addToHistory(query, results.length);
      }
      
      // Load suggestions
      loadSuggestions(query);
    } catch (e) {
      _errorMessage = 'Search failed: $e';
      debugPrint('Error searching: $e');
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  // Clear search
  void clearSearch() {
    _currentQuery = '';
    _searchResults.clear();
    _suggestions.clear();
    _errorMessage = null;
    notifyListeners();
  }

  // Load search history
  Future<void> loadSearchHistory() async {
    _isLoadingHistory = true;
    notifyListeners();

    try {
      _searchHistory = await _searchService.getSearchHistory();
    } catch (e) {
      debugPrint('Error loading search history: $e');
    } finally {
      _isLoadingHistory = false;
      notifyListeners();
    }
  }

  // Add to search history
  Future<void> addToHistory(String query, int resultCount) async {
    try {
      final historyItem = SearchQueryEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        query: query,
        timestamp: DateTime.now(),
        resultCount: resultCount,
      );
      
      _searchHistory.insert(0, historyItem);
      if (_searchHistory.length > 20) {
        _searchHistory.removeLast();
      }
      
      await _searchService.saveSearchHistory(_searchHistory);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding to history: $e');
    }
  }

  // Remove from history
  Future<void> removeFromHistory(String queryId) async {
    try {
      _searchHistory.removeWhere((item) => item.id == queryId);
      await _searchService.saveSearchHistory(_searchHistory);
      notifyListeners();
    } catch (e) {
      debugPrint('Error removing from history: $e');
    }
  }

  // Clear search history
  Future<void> clearHistory() async {
    try {
      _searchHistory.clear();
      await _searchService.clearSearchHistory();
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing history: $e');
    }
  }

  // Toggle favorite in history
  Future<void> toggleFavorite(String queryId) async {
    try {
      final index = _searchHistory.indexWhere((item) => item.id == queryId);
      if (index != -1) {
        _searchHistory[index] = _searchHistory[index].copyWith(
          isFavorite: !_searchHistory[index].isFavorite,
        );
        await _searchService.saveSearchHistory(_searchHistory);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
    }
  }

  // Load suggestions
  Future<void> loadSuggestions(String query) async {
    _isLoadingSuggestions = true;
    notifyListeners();

    try {
      _suggestions = await _searchService.getSearchSuggestions(query);
    } catch (e) {
      debugPrint('Error loading suggestions: $e');
    } finally {
      _isLoadingSuggestions = false;
      notifyListeners();
    }
  }

  // Load trending searches
  Future<void> loadTrendingSearches() async {
    try {
      _trendingSearches = await _searchService.getTrendingSearches();
    } catch (e) {
      debugPrint('Error loading trending searches: $e');
    }
  }

  // Apply history item
  void applyHistoryItem(SearchQueryEntity historyItem) {
    updateQuery(historyItem.query);
    performSearch(historyItem.query);
  }

  // Apply suggestion
  void applySuggestion(String suggestion) {
    updateQuery(suggestion);
    performSearch(suggestion);
  }

  // Reset error
  void resetError() {
    _errorMessage = null;
    notifyListeners();
  }
}
