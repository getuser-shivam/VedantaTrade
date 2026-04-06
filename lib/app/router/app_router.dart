import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:vedanta_trade/features/authentication/presentation/providers/auth_provider.dart';
import 'package:vedanta_trade/features/authentication/presentation/screens/login_screen.dart';
import 'package:vedanta_trade/features/product_catalog/product_catalog.dart';
import 'package:vedanta_trade/features/cart/presentation/screens/cart_screen.dart';
import 'package:vedanta_trade/features/profile/presentation/screens/profile_screen.dart';
import 'package:vedanta_trade/features/orders/presentation/screens/order_history_screen.dart';
import 'package:vedanta_trade/features/notifications/presentation/screens/notifications_screen.dart';

GoRouter createAppRouter() {
  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final auth = context.read<AuthProvider>();
      final isLoggingIn = state.matchedLocation.startsWith('/auth') || state.matchedLocation == '/login' || state.matchedLocation == '/register';

      if (!auth.isLoggedIn && !isLoggingIn) {
        return '/login';
      }
      if (auth.isLoggedIn && isLoggingIn) {
        return '/';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const PasswordResetScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const ProductCatalogScreen(),
      ),
      GoRoute(
        path: '/product/:id',
        builder: (context, state) {
          final productId = state.pathParameters['id']!;
          final product = context.read<ProductCatalogProvider>().getProductById(productId);

          if (product == null) {
            return const _MissingProductScreen();
          }

          return ProductDetailScreen(product: product);
        },
      ),
      GoRoute(
        path: '/cart',
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/orders',
        builder: (context, state) => const OrderHistoryScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
    ],
  );
}

class _MissingProductScreen extends StatelessWidget {
  const _MissingProductScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product not found')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.inventory_2_outlined, size: 64),
            const SizedBox(height: 12),
            const Text('This product is not available in the catalog.'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Back to catalog'),
            ),
          ],
        ),
      ),
    );
  }
}
