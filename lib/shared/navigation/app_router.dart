import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class AppRouter {
  static const String initialRoute = AppConstants.splashRoute;
  
  static Map<String, Widget Function(BuildContext)> get routes => {
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
  };

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final routeName = settings.name;
    
    if (routeName != null && routes.containsKey(routeName)) {
      return MaterialPageRoute(
        builder: routes[routeName]!,
        settings: settings,
      );
    }
    
    // Handle deep links
    if (routeName?.startsWith(AppConstants.productDetailScheme) == true) {
      final productId = routeName?.split('/').last;
      return MaterialPageRoute(
        builder: (context) => ProductDetailScreen(productId: productId),
        settings: settings,
      );
    }
    
    if (routeName?.startsWith(AppConstants.orderTrackScheme) == true) {
      final orderId = routeName?.split('/').last;
      return MaterialPageRoute(
        builder: (context) => OrderTrackingScreen(orderId: orderId),
        settings: settings,
      );
    }
    
    if (routeName?.startsWith(AppConstants.campaignScheme) == true) {
      final campaignId = routeName?.split('/').last;
      return MaterialPageRoute(
        builder: (context) => CampaignDetailScreen(campaignId: campaignId),
        settings: settings,
      );
    }
    
    // Default route
    return MaterialPageRoute(
      builder: (context) => const NotFoundScreen(),
      settings: settings,
    );
  }

  static void navigateTo(BuildContext context, String routeName, {Object? arguments}) {
    Navigator.pushNamed(context, routeName, arguments: arguments);
  }

  static void navigateAndReplace(BuildContext context, String routeName, {Object? arguments}) {
    Navigator.pushReplacementNamed(context, routeName, arguments: arguments);
  }

  static void navigateAndClearStack(BuildContext context, String routeName, {Object? arguments}) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  static void goBack(BuildContext context, {Object? result}) {
    Navigator.pop(context, result);
  }

  static bool canGoBack(BuildContext context) {
    return Navigator.canPop(context);
  }

  static void navigateToProductDetail(BuildContext context, String productId) {
    navigateTo(context, '${AppConstants.productDetailScheme}/$productId');
  }

  static void navigateToOrderTracking(BuildContext context, String orderId) {
    navigateTo(context, '${AppConstants.orderTrackScheme}/$orderId');
  }

  static void navigateToCampaignDetail(BuildContext context, String campaignId) {
    navigateTo(context, '${AppConstants.campaignScheme}/$campaignId');
  }

  static void navigateToLogin(BuildContext context) {
    navigateAndClearStack(context, AppConstants.loginRoute);
  }

  static void navigateToDashboard(BuildContext context) {
    navigateAndClearStack(context, AppConstants.dashboardRoute);
  }

  static void navigateToProductCatalog(BuildContext context) {
    navigateTo(context, AppConstants.productCatalogRoute);
  }

  static void navigateToDistribution(BuildContext context) {
    navigateTo(context, AppConstants.distributionRoute);
  }

  static void navigateToInventory(BuildContext context) {
    navigateTo(context, AppConstants.inventoryRoute);
  }

  static void navigateToOrders(BuildContext context) {
    navigateTo(context, AppConstants.ordersRoute);
  }

  static void navigateToCampaigns(BuildContext context) {
    navigateTo(context, AppConstants.campaignsRoute);
  }

  static void navigateToAnalytics(BuildContext context) {
    navigateTo(context, AppConstants.analyticsRoute);
  }

  static void navigateToProfile(BuildContext context) {
    navigateTo(context, AppConstants.profileRoute);
  }

  static void navigateToSettings(BuildContext context) {
    navigateTo(context, AppConstants.settingsRoute);
  }

  static void navigateToForgotPassword(BuildContext context) {
    navigateTo(context, AppConstants.forgotPasswordRoute);
  }

  static void navigateToSignUp(BuildContext context) {
    navigateTo(context, AppConstants.signUpRoute);
  }
}

// Placeholder widgets - these would be imported from their respective feature modules
class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Splash Screen')));
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Login Screen')));
}

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Sign Up Screen')));
}

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Forgot Password Screen')));
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Dashboard')));
}

class ProductCatalogScreen extends StatelessWidget {
  const ProductCatalogScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Product Catalog')));
}

class DistributionScreen extends StatelessWidget {
  const DistributionScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Distribution')));
}

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Inventory')));
}

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Orders')));
}

class CampaignsScreen extends StatelessWidget {
  const CampaignsScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Campaigns')));
}

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Analytics')));
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Profile')));
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Settings')));
}

class ProductDetailScreen extends StatelessWidget {
  final String? productId;
  const ProductDetailScreen({Key? key, this.productId}) : super(key: key);
  @override
  Widget build(BuildContext context) => Scaffold(body: Center(child: Text('Product Detail: $productId')));
}

class OrderTrackingScreen extends StatelessWidget {
  final String? orderId;
  const OrderTrackingScreen({Key? key, this.orderId}) : super(key: key);
  @override
  Widget build(BuildContext context) => Scaffold(body: Center(child: Text('Order Tracking: $orderId')));
}

class CampaignDetailScreen extends StatelessWidget {
  final String? campaignId;
  const CampaignDetailScreen({Key? key, this.campaignId}) : super(key: key);
  @override
  Widget build(BuildContext context) => Scaffold(body: Center(child: Text('Campaign Detail: $campaignId')));
}

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Page Not Found')));
}
