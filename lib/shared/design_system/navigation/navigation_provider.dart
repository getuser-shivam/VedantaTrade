import 'package:flutter/foundation.dart';
import 'navigation_state.dart';
import 'navigation_event.dart';
import 'navigation_history_manager.dart';

/// Navigation Provider for managing app-wide navigation state
/// Provides unified navigation state management across all features
class NavigationProvider extends ChangeNotifier {
  // Current navigation state
  NavigationState _currentState = const NavigationState(route: '/');
  NavigationState get currentState => _currentState;

  // Navigation history stack
  final List<NavigationState> _history = [];
  List<NavigationState> get history => List.unmodifiable(_history);

  // Can go back?
  bool get canGoBack => _history.isNotEmpty;

  // History manager for tracking navigation events
  final NavigationHistoryManager _historyManager = NavigationHistoryManager();

  NavigationProvider() {
    // Initialize with home state
    _currentState = const NavigationState(route: '/');
  }

  /// Navigate to new state
  void navigateTo(NavigationState state) {
    // Record navigation event
    _historyManager.addEvent(NavigationEvent(
      fromRoute: _currentState.route,
      toRoute: state.route,
      params: state.params,
      method: NavigationMethod.programmatic,
    ));

    // Add current state to history
    _history.add(_currentState);

    // Update current state
    _currentState = state;
    notifyListeners();
  }

  /// Navigate to specific route with parameters
  void navigateToRoute(String route, {Map<String, dynamic>? params}) {
    final state = NavigationState.fromRoute(route, params);
    navigateTo(state);
  }

  /// Navigate to route by index (for bottom navigation)
  void navigateToIndex(int index) {
    final routes = _getMainNavigationRoutes();
    if (index >= 0 && index < routes.length) {
      navigateToRoute(routes[index]);
    }
  }

  /// Go back in history
  void goBack() {
    if (canGoBack) {
      final previousState = _history.removeLast();

      // Record back navigation event
      _historyManager.addEvent(NavigationEvent(
        fromRoute: _currentState.route,
        toRoute: previousState.route,
        method: NavigationMethod.back,
      ));

      _currentState = previousState;
      notifyListeners();
    }
  }

  /// Clear history and navigate to new state
  void navigateAndClearHistory(NavigationState state) {
    _history.clear();
    navigateTo(state);
  }

  /// Navigate and clear history by route
  void navigateToRouteAndClearHistory(String route, {Map<String, dynamic>? params}) {
    final state = NavigationState.fromRoute(route, params);
    navigateAndClearHistory(state);
  }

  /// Get current route
  String get currentRoute => _currentState.route;

  /// Get current route parameters
  Map<String, dynamic>? get currentParams => _currentState.params;

  /// Check if current route matches
  bool isCurrentRoute(String route) {
    return _currentState.route == route || _currentState.route.startsWith('$route/');
  }

  /// Get navigation history
  List<NavigationEvent> getNavigationHistory() {
    return _historyManager.getHistory();
  }

  /// Get navigation history for specific route
  List<NavigationEvent> getHistoryForRoute(String route) {
    return _historyManager.getHistoryForRoute(route);
  }

  /// Clear all navigation history
  void clearHistory() {
    _history.clear();
    _historyManager.clearHistory();
    notifyListeners();
  }

  /// Get main navigation routes for bottom navigation
  List<String> _getMainNavigationRoutes() {
    return [
      '/',
      '/catalog',
      '/orders',
      '/notifications',
      '/profile',
    ];
  }

  /// Get current navigation index
  int getCurrentIndex() {
    final routes = _getMainNavigationRoutes();
    for (int i = 0; i < routes.length; i++) {
      if (isCurrentRoute(routes[i])) {
        return i;
      }
    }
    return 0;
  }
}
