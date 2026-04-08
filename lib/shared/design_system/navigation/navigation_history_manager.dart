import 'navigation_event.dart';

/// Navigation History Manager
/// Manages navigation event history for analytics and back navigation
class NavigationHistoryManager {
  final List<NavigationEvent> _events = [];
  final int maxHistorySize = 50;

  /// Add a navigation event to history
  void addEvent(NavigationEvent event) {
    _events.add(event);
    if (_events.length > maxHistorySize) {
      _events.removeAt(0);
    }
  }

  /// Get all navigation events
  List<NavigationEvent> getHistory() {
    return List.unmodifiable(_events);
  }

  /// Get navigation events for a specific route
  List<NavigationEvent> getHistoryForRoute(String route) {
    return _events.where((e) => e.toRoute == route).toList();
  }

  /// Get the last navigation event
  NavigationEvent? getLastEvent() {
    return _events.isNotEmpty ? _events.last : null;
  }

  /// Get navigation events by method
  List<NavigationEvent> getHistoryByMethod(NavigationMethod method) {
    return _events.where((e) => e.method == method).toList();
  }

  /// Get navigation count for a route
  int getVisitCount(String route) {
    return _events.where((e) => e.toRoute == route).length;
  }

  /// Clear all navigation history
  void clearHistory() {
    _events.clear();
  }

  /// Get navigation statistics
  Map<String, int> getNavigationStatistics() {
    final stats = <String, int>{};
    for (final event in _events) {
      stats[event.toRoute] = (stats[event.toRoute] ?? 0) + 1;
    }
    return stats;
  }

  /// Get most visited routes
  List<MapEntry<String, int>> getMostVisitedRoutes({int limit = 10}) {
    final stats = getNavigationStatistics();
    final sorted = stats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(limit).toList();
  }
}
