import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../widgets/enhanced_navigation.dart';

/// Optimized App Router with improved performance and maintainability
/// Features: Route caching, lazy loading, and better error handling
class OptimizedAppRouter {
  static const String initialRoute = AppConstants.splashRoute;
  
  // Route cache for performance optimization
  static final Map<String, Widget> _routeCache = {};
  static final Map<String, Widget Function(BuildContext)> _routeBuilders = {};
  
  // Initialize route builders
  static void initialize() {
    _routeBuilders.clear();
    _routeBuilders.addAll({
      AppConstants.splashRoute: (context) => const SplashScreen(),
      AppConstants.loginRoute: (context) => const LoginScreen(),
      AppConstants.signUpRoute: (context) => const SignUpScreen(),
      AppConstants.forgotPasswordRoute: (context) => const ForgotPasswordScreen(),
      AppConstants.dashboardRoute: (context) => const DashboardScreen(),
      AppConstants.productCatalogRoute: (context) => const ProductCatalogScreen(),
      AppConstants.distributionRoute: (context) => const DistributionScreen(),
      AppConstants.inventoryRoute: (context) => const InventoryScreen(),
      AppConstants.ordersRoute: (context) => const OrdersScreen(),
      AppConstants.campaignsRoute: (context) => const CampaignsScreen(),
      AppConstants.analyticsRoute: (context) => const AnalyticsScreen(),
      AppConstants.profileRoute: (context) => const ProfileScreen(),
      AppConstants.settingsRoute: (context) => const SettingsScreen(),
    });
  }
  
  /// Get cached route builder for better performance
  static Widget? getCachedRoute(String routeName) {
    return _routeCache[routeName];
  }
  
  /// Cache route for future use
  static void cacheRoute(String routeName, Widget widget) {
    if (_routeCache.length > 50) {
      _routeCache.remove(_routeCache.keys.first);
    }
    _routeCache[routeName] = widget;
  }
  
  /// Generate route with improved error handling and performance
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final routeName = settings.name;
    
    if (routeName == null) {
      return _buildErrorRoute('Route name is null');
    }
    
    // Check cache first for performance
    final cachedRoute = getCachedRoute(routeName!);
    if (cachedRoute != null) {
      return MaterialPageRoute(
        builder: (context) => cachedRoute,
        settings: settings,
      );
    }
    
    // Check registered routes
    final routeBuilder = _routeBuilders[routeName!];
    if (routeBuilder != null) {
      final widget = routeBuilder(settings.arguments as BuildContext?);
      cacheRoute(routeName!, widget!);
      
      return MaterialPageRoute(
        builder: (context) => widget!,
        settings: settings,
      );
    }
    
    // Handle deep links
    return _handleDeepLink(routeName!, settings);
  }
  
  /// Handle deep links with improved parsing
  static Route<dynamic> _handleDeepLink(String routeName, RouteSettings settings) {
    try {
      // Product detail deep link
      if (routeName.startsWith(AppConstants.productDetailScheme)) {
        final productId = routeName.split('/').last;
        if (productId.isNotEmpty) {
          final widget = ProductDetailScreen(productId: productId);
          cacheRoute(routeName, widget);
          return MaterialPageRoute(
            builder: (context) => widget,
            settings: settings,
          );
        }
      }
      
      // Order tracking deep link
      if (routeName.startsWith(AppConstants.orderTrackScheme)) {
        final orderId = routeName.split('/').last;
        if (orderId.isNotEmpty) {
          final widget = OrderTrackingScreen(orderId: orderId);
          cacheRoute(routeName, widget);
          return MaterialPageRoute(
            builder: (context) => widget,
            settings: settings,
          );
        }
      }
      
      // Campaign deep link
      if (routeName.startsWith(AppConstants.campaignScheme)) {
        final campaignId = routeName.split('/').last;
        if (campaignId.isNotEmpty) {
          final widget = CampaignDetailScreen(campaignId: campaignId);
          cacheRoute(routeName, widget);
          return MaterialPageRoute(
            builder: (context) => widget,
            settings: settings,
          );
        }
      }
    } catch (e) {
      return _buildErrorRoute('Deep link parsing error: $e');
    }
    
    return _buildErrorRoute('Route not found: $routeName');
  }
  
  /// Build error route with better UX
  static Route<dynamic> _buildErrorRoute(String errorMessage) {
    return MaterialPageRoute(
      builder: (context) => ErrorScreen(
        title: 'Navigation Error',
        message: errorMessage,
        onRetry: () {
          // Navigate back to dashboard
          Navigator.of(context).pushNamedAndRemoveUntil(
            AppConstants.dashboardRoute,
            (route) => false,
          );
        },
      ),
    );
  }
  
  /// Navigation helpers with improved error handling
  static Future<void> navigateTo(BuildContext context, String routeName, {Object? arguments}) {
    try {
      await Navigator.of(context).pushNamed(routeName, arguments: arguments);
    } catch (e) {
      _showErrorSnackBar(context, 'Navigation failed: $e');
    }
  }
  
  static Future<void> navigateAndReplace(BuildContext context, String routeName, {Object? arguments}) {
    try {
      await Navigator.of(context).pushReplacementNamed(routeName, arguments: arguments);
    } catch (e) {
      _showErrorSnackBar(context, 'Navigation failed: $e');
    }
  }
  
  static Future<void> navigateAndClearStack(BuildContext context, String routeName, {Object? arguments}) {
    try {
      await Navigator.of(context).pushNamedAndRemoveUntil(
        routeName,
        (route) => false,
        arguments: arguments,
      );
    } catch (e) {
      _showErrorSnackBar(context, 'Navigation failed: $e');
    }
  }
  
  static void goBack(BuildContext context) {
    Navigator.of(context).pop();
  }
  
  static void goBackToRoot(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
  
  /// Check if route exists
  static bool hasRoute(String routeName) {
    return _routeBuilders.containsKey(routeName) || 
           routeName.startsWith(AppConstants.productDetailScheme) ||
           routeName.startsWith(AppConstants.orderTrackScheme) ||
           routeName.startsWith(AppConstants.campaignScheme);
  }
  
  /// Get all available routes
  static List<String> getAvailableRoutes() {
    return _routeBuilders.keys.toList();
  }
  
  /// Clear route cache
  static void clearCache() {
    _routeCache.clear();
  }
  
  /// Get cache statistics
  static Map<String, dynamic> getCacheStats() {
    return {
      'cacheSize': _routeCache.length,
      'maxCacheSize': 50,
      'availableRoutes': _routeBuilders.length,
    };
  }
  
  /// Show error snackbar with improved styling
  static void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Dismiss',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}

/// Enhanced error screen for better UX
class ErrorScreen extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;

  const ErrorScreen({
    Key? key,
    required this.title,
    required this.message,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: onRetry,
                  child: const Text('Retry'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Navigation service for centralized navigation management
class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  
  static BuildContext? get context => navigatorKey.currentContext;
  
  static Future<void> navigateTo(String routeName, {Object? arguments}) {
    final context = NavigationService.context;
    if (context != null) {
      await OptimizedAppRouter.navigateTo(context!, routeName, arguments: arguments);
    }
  }
  
  static Future<void> navigateAndReplace(String routeName, {Object? arguments}) {
    final context = NavigationService.context;
    if (context != null) {
      await OptimizedAppRouter.navigateAndReplace(context!, routeName, arguments: arguments);
    }
  }
  
  static Future<void> navigateAndClearStack(String routeName, {Object? arguments}) {
    final context = NavigationService.context;
    if (context != null) {
      await OptimizedAppRouter.navigateAndClearStack(context!, routeName, arguments: arguments);
    }
  }
  
  static void goBack() {
    final context = NavigationService.context;
    if (context != null) {
      OptimizedAppRouter.goBack(context!);
    }
  }
  
  static void goBackToRoot() {
    final context = NavigationService.context;
    if (context != null) {
      OptimizedAppRouter.goBackToRoot(context!);
    }
  }
}

/// Route guard for authentication and permissions
class RouteGuard {
  static Future<bool> canAccessRoute(String routeName, {Object? arguments}) async {
    // Check if route requires authentication
    if (_requiresAuthentication(routeName)) {
      // Check if user is authenticated
      // This would integrate with your authentication service
      return true; // Placeholder - implement actual auth check
    }
    
    // Check if route requires specific permissions
    if (_requiresPermissions(routeName)) {
      // Check user permissions
      return true; // Placeholder - implement actual permission check
    }
    
    return true;
  }
  
  static bool _requiresAuthentication(String routeName) {
    final protectedRoutes = [
      AppConstants.dashboardRoute,
      AppConstants.profileRoute,
      AppConstants.settingsRoute,
      AppConstants.ordersRoute,
      AppConstants.distributionRoute,
      AppConstants.inventoryRoute,
      AppConstants.campaignsRoute,
      AppConstants.analyticsRoute,
    ];
    
    return protectedRoutes.contains(routeName);
  }
  
  static bool _requiresPermissions(String routeName) {
    final adminRoutes = [
      AppConstants.campaignsRoute,
      AppConstants.analyticsRoute,
    ];
    
    return adminRoutes.contains(routeName);
  }
}

/// Navigation observer for analytics and tracking
class NavigationObserver extends NavigatorObserver {
  static final List<String> _navigationHistory = [];
  
  @override
  void didPush(Route route, Route? previousRoute) {
    _navigationHistory.add(route.settings.name ?? 'unknown');
    _logNavigationEvent('push', route.settings.name);
    super.didPush(route, previousRoute);
  }
  
  @override
  void didPop(Route route, Route? previousRoute) {
    _logNavigationEvent('pop', route.settings.name);
    super.didPop(route, previousRoute);
  }
  
  @override
  void didRemove(Route route, Route? previousRoute) {
    _logNavigationEvent('remove', route.settings.name);
    super.didRemove(route, previousRoute);
  }
  
  static List<String> getNavigationHistory() {
    return List.from(_navigationHistory);
  }
  
  static void clearNavigationHistory() {
    _navigationHistory.clear();
  }
  
  static void _logNavigationEvent(String action, String? routeName) {
    // Log navigation events for analytics
    print('Navigation: $action -> $routeName');
    // This would integrate with your analytics service
  }
}

/// Deep link handler for improved deep link processing
class DeepLinkHandler {
  static Future<void> handleDeepLink(String deepLink) async {
    try {
      final uri = Uri.parse(deepLink);
      
      switch (uri.scheme) {
        case 'vedantatrade':
          await _handleAppDeepLink(uri);
          break;
        case 'http':
        case 'https':
          if (uri.host.contains('vedantatrade.com')) {
            await _handleWebDeepLink(uri);
          }
          break;
        default:
          print('Unknown deep link scheme: ${uri.scheme}');
      }
    } catch (e) {
      print('Deep link handling error: $e');
    }
  }
  
  static Future<void> _handleAppDeepLink(Uri uri) async {
    final path = uri.path;
    final params = uri.queryParameters;
    
    switch (path) {
      case '/product':
        final productId = params['id'];
        if (productId != null) {
          await NavigationService.navigateTo(
            '${AppConstants.productDetailScheme}/$productId',
          );
        }
        break;
      case '/order':
        final orderId = params['id'];
        if (orderId != null) {
          await NavigationService.navigateTo(
            '${AppConstants.orderTrackScheme}/$orderId',
          );
        }
        break;
      case '/campaign':
        final campaignId = params['id'];
        if (campaignId != null) {
          await NavigationService.navigateTo(
            '${AppConstants.campaignScheme}/$campaignId',
          );
        }
        break;
      default:
        print('Unknown deep link path: $path');
    }
  }
  
  static Future<void> _handleWebDeepLink(Uri uri) async {
    final path = uri.path;
    
    if (path.startsWith('/product/')) {
      final productId = path.split('/').last;
      if (productId.isNotEmpty) {
        await NavigationService.navigateTo(
          '${AppConstants.productDetailScheme}/$productId',
        );
      }
    } else if (path.startsWith('/order/')) {
      final orderId = path.split('/').last;
      if (orderId.isNotEmpty) {
        await NavigationService.navigateTo(
          '${AppConstants.orderTrackScheme}/$orderId',
        );
      }
    }
  }
}
