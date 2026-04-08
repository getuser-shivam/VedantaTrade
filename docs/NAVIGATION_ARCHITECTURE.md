# VedantaTrade Navigation Architecture Design

## Overview

This document outlines the new unified navigation architecture for VedantaTrade, designed to provide consistent, intuitive, and accessible navigation across all features and device types.

## Current Navigation Issues

### Identified Problems
1. **Multiple Navigation Implementations**: Different features use different navigation patterns
2. **Inconsistent State Management**: No unified navigation state
3. **No Deep Linking**: Cannot deep link to specific screens
4. **No History Tracking**: No navigation history for back navigation
5. **Mixed Navigation Systems**: Combination of go_router and custom navigation
6. **Inconsistent Active States**: Different active state indicators across features
7. **No Navigation Provider**: No centralized navigation state management

## New Navigation Architecture

### Core Principles
1. **Single Source of Truth**: Unified navigation state managed by NavigationProvider
2. **Consistent Patterns**: Same navigation behavior across all features
3. **Deep Linking Support**: All screens accessible via deep links
4. **History Tracking**: Complete navigation history for back navigation
5. **Accessibility First**: Keyboard navigation and screen reader support
6. **Responsive Design**: Adaptive navigation for all device types

### Navigation State Management

#### NavigationProvider
```dart
class NavigationProvider extends ChangeNotifier {
  // Current navigation state
  NavigationState _currentState = NavigationState.home;
  NavigationState get currentState => _currentState;
  
  // Navigation history stack
  final List<NavigationState> _history = [];
  List<NavigationState> get history => List.unmodifiable(_history);
  
  // Can go back?
  bool get canGoBack => _history.isNotEmpty;
  
  // Navigate to new state
  void navigateTo(NavigationState state) {
    _history.add(_currentState);
    _currentState = state;
    notifyListeners();
  }
  
  // Go back in history
  void goBack() {
    if (canGoBack) {
      _currentState = _history.removeLast();
      notifyListeners();
    }
  }
  
  // Navigate to specific route with parameters
  void navigateToRoute(String route, {Map<String, dynamic>? params}) {
    final state = NavigationState.fromRoute(route, params);
    navigateTo(state);
  }
  
  // Clear history and navigate
  void navigateAndClearHistory(NavigationState state) {
    _history.clear();
    _currentState = state;
    notifyListeners();
  }
}
```

#### NavigationState Model
```dart
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
  
  factory NavigationState.fromRoute(String route, Map<String, dynamic>? params) {
    // Parse route and determine state type
    return NavigationState(
      route: route,
      params: params,
      type: _determineNavigationType(route),
    );
  }
  
  static NavigationType _determineNavigationType(String route) {
    if (route.startsWith('/')) {
      return NavigationType.screen;
    } else if (route.startsWith('#')) {
      return NavigationType.section;
    } else {
      return NavigationType.dialog;
    }
  }
}

enum NavigationType {
  screen,
  section,
  dialog,
  bottomSheet,
}
```

### Navigation Routes Structure

#### Route Definitions
```dart
class AppRoutes {
  // Authentication
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  
  // Main Navigation
  static const String home = '/';
  static const String catalog = '/catalog';
  static const String orders = '/orders';
  static const String profile = '/profile';
  static const String notifications = '/notifications';
  
  // Product Catalog
  static const String productDetail = '/product/:id';
  static const String productComparison = '/products/compare';
  static const String categoryProducts = '/category/:id';
  
  // Distribution
  static const String distributionDashboard = '/distribution';
  static const String distributionCenters = '/distribution/centers';
  static const String addDistributionCenter = '/distribution/centers/add';
  static const String salesDashboard = '/distribution/sales';
  static const String marketingCampaigns = '/distribution/marketing';
  
  // Accounting
  static const String accountingDashboard = '/accounting';
  static const String vatReturns = '/accounting/vat';
  static const String expenses = '/accounting/expenses';
  static const String reports = '/accounting/reports';
  static const String invoices = '/accounting/invoices';
  
  // Admin
  static const String adminDashboard = '/admin';
  static const String users = '/admin/users';
  static const String products = '/admin/products';
  static const String mediaUpload = '/admin/media';
  static const String scraper = '/admin/scraper';
  static const String map = '/admin/map';
  
  // Field Force
  static const String fieldForceDashboard = '/field-force';
  static const String expenseSubmission = '/field-force/expense';
  static const String gpsTracking = '/field-force/gps';
  
  // Retailer
  static const String retailerDashboard = '/retailer';
  static const String retailerOrders = '/retailer/orders';
  static const String checkout = '/retailer/checkout';
  static const String payment = '/retailer/payment';
  
  // Stockist
  static const String stockistDashboard = '/stockist';
  static const String stockistInventory = '/stockist/inventory';
  static const String stockistOrders = '/stockist/orders';
}
```

### Navigation Components

#### Unified Navigation Bar
```dart
class UnifiedNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final NavigationStyle style;
  
  const UnifiedNavigationBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    this.style = NavigationStyle.auto,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1200;
    final isTablet = MediaQuery.of(context).size.width >= 768;
    
    switch (style) {
      case NavigationStyle.desktop:
        return _DesktopNavigationBar(
          currentIndex: currentIndex,
          onTap: onTap,
        );
      case NavigationStyle.tablet:
        return _TabletNavigationBar(
          currentIndex: currentIndex,
          onTap: onTap,
        );
      case NavigationStyle.mobile:
        return _MobileNavigationBar(
          currentIndex: currentIndex,
          onTap: onTap,
        );
      case NavigationStyle.auto:
        if (isDesktop) {
          return _DesktopNavigationBar(
            currentIndex: currentIndex,
            onTap: onTap,
          );
        } else if (isTablet) {
          return _TabletNavigationBar(
            currentIndex: currentIndex,
            onTap: onTap,
          );
        } else {
          return _MobileNavigationBar(
            currentIndex: currentIndex,
            onTap: onTap,
          );
        }
    }
  }
}

enum NavigationStyle {
  desktop,
  tablet,
  mobile,
  auto,
}
```

#### Navigation Item Model
```dart
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
  
  bool isActive(String currentRoute) {
    return currentRoute.startsWith(route);
  }
}
```

#### Navigation Configuration
```dart
class NavigationConfig {
  static const List<NavigationItem> mainNavigationItems = [
    NavigationItem(
      id: 'home',
      label: 'Home',
      icon: Icons.home_rounded,
      activeIcon: Icons.home_filled,
      route: AppRoutes.home,
    ),
    NavigationItem(
      id: 'catalog',
      label: 'Catalog',
      icon: Icons.inventory_2_rounded,
      activeIcon: Icons.inventory_2,
      route: AppRoutes.catalog,
    ),
    NavigationItem(
      id: 'orders',
      label: 'Orders',
      icon: Icons.shopping_bag_rounded,
      activeIcon: Icons.shopping_bag,
      route: AppRoutes.orders,
      badge: '3',
    ),
    NavigationItem(
      id: 'notifications',
      label: 'Notifications',
      icon: Icons.notifications_rounded,
      activeIcon: Icons.notifications,
      route: AppRoutes.notifications,
      badge: '5',
    ),
    NavigationItem(
      id: 'profile',
      label: 'Profile',
      icon: Icons.person_rounded,
      activeIcon: Icons.person,
      route: AppRoutes.profile,
    ),
  ];
  
  static List<NavigationItem> getNavigationItemsForRole(String role) {
    switch (role) {
      case 'ADMIN':
        return _adminNavigationItems;
      case 'MEDICAL_REP':
        return _mrNavigationItems;
      case 'ACCOUNTANT':
        return _accountantNavigationItems;
      case 'DOCTOR':
        return _doctorNavigationItems;
      case 'STOCKIST':
        return _stockistNavigationItems;
      case 'RETAILER':
        return _retailerNavigationItems;
      default:
        return mainNavigationItems;
    }
  }
  
  static const List<NavigationItem> _adminNavigationItems = [
    NavigationItem(
      id: 'admin-dashboard',
      label: 'Dashboard',
      icon: Icons.dashboard_rounded,
      route: AppRoutes.adminDashboard,
    ),
    NavigationItem(
      id: 'users',
      label: 'Users',
      icon: Icons.people_rounded,
      route: AppRoutes.users,
    ),
    NavigationItem(
      id: 'products',
      label: 'Products',
      icon: Icons.inventory_2_rounded,
      route: AppRoutes.products,
    ),
    NavigationItem(
      id: 'media-upload',
      label: 'Media',
      icon: Icons.cloud_upload_rounded,
      route: AppRoutes.mediaUpload,
    ),
    NavigationItem(
      id: 'scraper',
      label: 'Scraper',
      icon: Icons.travel_explore_rounded,
      route: AppRoutes.scraper,
    ),
    NavigationItem(
      id: 'map',
      label: 'Map',
      icon: Icons.map_rounded,
      route: AppRoutes.map,
    ),
    NavigationItem(
      id: 'profile',
      label: 'Profile',
      icon: Icons.person_rounded,
      route: AppRoutes.profile,
    ),
  ];
  
  // Similar lists for other roles...
}
```

### Deep Linking Implementation

#### Deep Link Handler
```dart
class DeepLinkHandler {
  final NavigationProvider _navigationProvider;
  
  DeepLinkHandler(this._navigationProvider);
  
  Future<void> handleDeepLink(String deepLink) async {
    try {
      // Parse deep link
      final uri = Uri.parse(deepLink);
      
      // Extract route and parameters
      final route = uri.path;
      final params = uri.queryParameters;
      
      // Validate route
      if (!_isValidRoute(route)) {
        throw InvalidRouteException(route);
      }
      
      // Check authentication requirements
      if (_requiresAuth(route) && !isAuthenticated()) {
        _navigationProvider.navigateToRoute(AppRoutes.login);
        return;
      }
      
      // Check role requirements
      if (_requiresRole(route) && !hasRequiredRole(route)) {
        _navigationProvider.navigateToRoute(AppRoutes.home);
        return;
      }
      
      // Navigate to route
      _navigationProvider.navigateToRoute(route, params: params);
      
    } on FormatException {
      throw InvalidDeepLinkException(deepLink);
    }
  }
  
  bool _isValidRoute(String route) {
    // Check if route is defined in AppRoutes
    return AppRoutes.allRoutes.contains(route);
  }
  
  bool _requiresAuth(String route) {
    // Check if route requires authentication
    return !_publicRoutes.contains(route);
  }
  
  bool _requiresRole(String route) {
    // Check if route requires specific role
    return _roleRestrictedRoutes.containsKey(route);
  }
  
  bool hasRequiredRole(String route) {
    final requiredRole = _roleRestrictedRoutes[route];
    return currentUser?.role == requiredRole;
  }
  
  bool isAuthenticated() {
    return currentUser != null;
  }
}
```

### Navigation History

#### History Manager
```dart
class NavigationHistoryManager {
  final List<NavigationEvent> _events = [];
  final int maxHistorySize = 50;
  
  void addEvent(NavigationEvent event) {
    _events.add(event);
    if (_events.length > maxHistorySize) {
      _events.removeAt(0);
    }
  }
  
  List<NavigationEvent> getHistory() {
    return List.unmodifiable(_events);
  }
  
  List<NavigationEvent> getHistoryForRoute(String route) {
    return _events.where((e) => e.toRoute == route).toList();
  }
  
  NavigationEvent? getLastEvent() {
    return _events.isNotEmpty ? _events.last : null;
  }
  
  void clearHistory() {
    _events.clear();
  }
}

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
  }) : timestamp = DateTime.now();
}

enum NavigationMethod {
  tap,
  swipe,
  deepLink,
  back,
  programmatic,
}
```

### Responsive Navigation

#### Desktop Navigation (Sidebar)
```dart
class _DesktopNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  
  const _DesktopNavigationBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildNavigationItems()),
          _buildFooter(),
        ],
      ),
    );
  }
  
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Icon(
            Icons.medical_services,
            color: Theme.of(context).colorScheme.primary,
            size: 32,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'VedantaTrade',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Text(
                'Pharma Distribution',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildNavigationItems() {
    final items = NavigationConfig.getNavigationItemsForRole(currentUser?.role ?? '');
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isSelected = currentIndex == index;
        
        return _NavigationItemTile(
          item: item,
          isSelected: isSelected,
          onTap: () => onTap(index),
        );
      },
    );
  }
  
  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Divider(),
          const SizedBox(height: 12),
          Text(
            'Version ${AppConstants.appVersion}',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}
```

#### Tablet Navigation (Top Bar)
```dart
class _TabletNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  
  const _TabletNavigationBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final items = NavigationConfig.getNavigationItemsForRole(currentUser?.role ?? '');
    
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          _buildLogo(),
          const Spacer(),
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return _TabletNavigationItem(
              item: item,
              isSelected: currentIndex == index,
              onTap: () => onTap(index),
            );
          }),
          const SizedBox(width: 16),
          _buildUserAvatar(),
          const SizedBox(width: 16),
        ],
      ),
    );
  }
  
  Widget _buildLogo() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.medical_services,
        color: Colors.white,
        size: 24,
      ),
    );
  }
  
  Widget _buildUserAvatar() {
    return CircleAvatar(
      backgroundColor: Theme.of(context).colorScheme.primary,
      child: Icon(
        Icons.person,
        color: Colors.white,
      ),
    );
  }
}
```

#### Mobile Navigation (Bottom Bar)
```dart
class _MobileNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  
  const _MobileNavigationBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final items = NavigationConfig.getNavigationItemsForRole(currentUser?.role ?? '');
    
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return _MobileNavigationItem(
            item: item,
            isSelected: currentIndex == index,
            onTap: () => onTap(index),
          );
        }).toList(),
      ),
    );
  }
}
```

### Accessibility Features

#### Keyboard Navigation
```dart
class KeyboardNavigationHandler extends StatelessWidget {
  final Widget child;
  
  const KeyboardNavigationHandler({
    Key? key,
    required this.child,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return FocusScope(
      onKey: (node, event) {
        if (event.logicalKey == LogicalKeyboardKey.tab) {
          // Handle tab navigation
          return KeyEventResult.handled;
        }
        if (event.logicalKey == LogicalKeyboardKey.escape) {
          // Handle escape to go back
          context.read<NavigationProvider>().goBack();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: child,
    );
  }
}
```

#### Screen Reader Support
```dart
class AccessibleNavigationItem extends StatelessWidget {
  final NavigationItem item;
  final bool isSelected;
  final VoidCallback onTap;
  
  const AccessibleNavigationItem({
    Key? key,
    required this.item,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: _getSemanticLabel(),
      hint: _getSemanticHint(),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: _buildContent(),
      ),
    );
  }
  
  String _getSemanticLabel() {
    return '${item.label}${item.subtitle != null ? ', ${item.subtitle}' : ''}';
  }
  
  String _getSemanticHint() {
    return isSelected ? 'Currently selected' : 'Double tap to navigate';
  }
  
  Widget _buildContent() {
    // Build navigation item content
  }
}
```

## Implementation Plan

### Phase 1: Foundation (Week 1)
1. Create NavigationProvider
2. Define NavigationState model
3. Create AppRoutes constants
4. Set up NavigationConfig

### Phase 2: Components (Week 2)
1. Implement UnifiedNavigationBar
2. Create navigation item components
3. Build responsive navigation variants
4. Add accessibility features

### Phase 3: Integration (Week 3)
1. Integrate with existing screens
2. Update router configuration
3. Add deep linking support
4. Implement history tracking

### Phase 4: Testing (Week 4)
1. Test navigation across all device types
2. Test deep linking
3. Test accessibility features
4. Performance testing

## Migration Guide

### Step 1: Update Dependencies
```yaml
dependencies:
  provider: ^6.0.0
  go_router: ^12.0.0
```

### Step 2: Wrap App with Providers
```dart
void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        // Other providers...
      ],
      child: const VedantaTradeApp(),
    ),
  );
}
```

### Step 3: Replace Navigation Components
```dart
// Before
BottomNavigationBar(
  currentIndex: currentIndex,
  onTap: (index) => setState(() => currentIndex = index),
  items: [...],
)

// After
UnifiedNavigationBar(
  currentIndex: currentIndex,
  onTap: (index) => context.read<NavigationProvider>().navigateToIndex(index),
)
```

### Step 4: Update Navigation Calls
```dart
// Before
Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen()));

// After
context.read<NavigationProvider>().navigateToRoute(AppRoutes.productDetail);
```

## Success Metrics

### Quantitative
- **Navigation Consistency**: 100% of screens using unified navigation
- **Deep Link Coverage**: 100% of screens accessible via deep links
- **Accessibility Score**: WCAG 2.1 AA compliance for navigation
- **Performance**: < 100ms navigation transitions
- **Code Reduction**: 30% reduction in navigation code

### Qualitative
- **User Feedback**: Improved navigation satisfaction scores
- **Developer Experience**: Faster navigation implementation
- **Maintainability**: Easier to add new navigation items
- **Visual Consistency**: Consistent navigation appearance

## Conclusion

This new navigation architecture provides a unified, accessible, and performant navigation system for VedantaTrade. By implementing this architecture, the application will achieve:

1. **Consistency**: Same navigation behavior across all features
2. **Accessibility**: Full keyboard and screen reader support
3. **Performance**: Fast and smooth navigation transitions
4. **Maintainability**: Easier to maintain and extend
5. **User Experience**: Intuitive and predictable navigation

The implementation plan ensures a smooth migration from the current system to the new architecture with minimal disruption to existing functionality.
