/// Navigation State Model
/// Represents the current navigation state of the application
class NavigationState {
  final String route;
  final String? title;
  final Map<String, dynamic>? params;
  final NavigationType type;

  const NavigationState({
    required this.route,
    this.title,
    this.params,
    this.type = NavigationType.screen,
  });

  /// Create NavigationState from route string
  factory NavigationState.fromRoute(String route, Map<String, dynamic>? params) {
    return NavigationState(
      route: route,
      params: params,
      type: _determineNavigationType(route),
    );
  }

  /// Determine navigation type based on route pattern
  static NavigationType _determineNavigationType(String route) {
    if (route.startsWith('/')) {
      return NavigationType.screen;
    } else if (route.startsWith('#')) {
      return NavigationType.section;
    } else {
      return NavigationType.dialog;
    }
  }

  /// Check if this state matches another state
  bool matches(NavigationState other) {
    return route == other.route;
  }

  /// Check if this state is a child of another state
  bool isChildOf(NavigationState parent) {
    return route.startsWith('${parent.route}/');
  }

  /// Create a copy with updated values
  NavigationState copyWith({
    String? route,
    String? title,
    Map<String, dynamic>? params,
    NavigationType? type,
  }) {
    return NavigationState(
      route: route ?? this.route,
      title: title ?? this.title,
      params: params ?? this.params,
      type: type ?? this.type,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NavigationState &&
        other.route == route &&
        other.type == type;
  }

  @override
  int get hashCode => route.hashCode ^ type.hashCode;
}

/// Navigation Type Enum
enum NavigationType {
  screen,
  section,
  dialog,
  bottomSheet,
}
