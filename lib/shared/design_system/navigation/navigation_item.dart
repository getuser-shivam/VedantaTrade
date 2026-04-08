import 'package:flutter/material.dart';

/// Navigation Item Model
/// Represents a single navigation item in the navigation bar
class NavigationItem {
  final String id;
  final String label;
  final String? subtitle;
  final IconData icon;
  final IconData? activeIcon;
  final String route;
  final List<NavigationItem>? children;
  final String? badge;
  final bool requiresAuth;
  final List<String>? requiredRoles;

  const NavigationItem({
    required this.id,
    required this.label,
    this.subtitle,
    required this.icon,
    this.activeIcon,
    required this.route,
    this.children,
    this.badge,
    this.requiresAuth = true,
    this.requiredRoles,
  });

  /// Check if this item is active for a given route
  bool isActive(String currentRoute) {
    return currentRoute.startsWith(route);
  }

  /// Get the icon to display (active or inactive)
  IconData getIcon(bool isActive) {
    return activeIcon != null && isActive ? activeIcon! : icon;
  }

  /// Create a copy with updated values
  NavigationItem copyWith({
    String? id,
    String? label,
    String? subtitle,
    IconData? icon,
    IconData? activeIcon,
    String? route,
    List<NavigationItem>? children,
    String? badge,
    bool? requiresAuth,
    List<String>? requiredRoles,
  }) {
    return NavigationItem(
      id: id ?? this.id,
      label: label ?? this.label,
      subtitle: subtitle ?? this.subtitle,
      icon: icon ?? this.icon,
      activeIcon: activeIcon ?? this.activeIcon,
      route: route ?? this.route,
      children: children ?? this.children,
      badge: badge ?? this.badge,
      requiresAuth: requiresAuth ?? this.requiresAuth,
      requiredRoles: requiredRoles ?? this.requiredRoles,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NavigationItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
