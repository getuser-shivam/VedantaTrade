import 'package:flutter/foundation.dart';

/// Navigation Event Model
/// Tracks individual navigation events for analytics and history
class NavigationEvent {
  final DateTime timestamp;
  final String fromRoute;
  final String toRoute;
  final Map<String, dynamic>? params;
  final NavigationMethod method;

  const NavigationEvent({
    required this.fromRoute,
    required this.toRoute,
    this.params,
    required this.method,
  }) : timestamp = null; // Will be set in constructor

  NavigationEvent._({
    required this.fromRoute,
    required this.toRoute,
    this.params,
    required this.method,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory NavigationEvent.create({
    required String fromRoute,
    required String toRoute,
    Map<String, dynamic>? params,
    required NavigationMethod method,
  }) {
    return NavigationEvent._(
      fromRoute: fromRoute,
      toRoute: toRoute,
      params: params,
      method: method,
    );
  }

  /// Convert to JSON for serialization
  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'fromRoute': fromRoute,
      'toRoute': toRoute,
      'params': params,
      'method': method.toString(),
    };
  }

  /// Create from JSON
  factory NavigationEvent.fromJson(Map<String, dynamic> json) {
    return NavigationEvent._(
      fromRoute: json['fromRoute'] as String,
      toRoute: json['toRoute'] as String,
      params: json['params'] as Map<String, dynamic>?,
      method: NavigationMethod.values.firstWhere(
        (e) => e.toString() == json['method'],
        orElse: () => NavigationMethod.programmatic,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  @override
  String toString() {
    return 'NavigationEvent(from: $fromRoute, to: $toRoute, method: $method)';
  }
}

/// Navigation Method Enum
/// Indicates how the navigation was triggered
enum NavigationMethod {
  tap,
  swipe,
  deepLink,
  back,
  programmatic,
}
