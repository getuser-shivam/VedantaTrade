import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:neutralitical_app/features/auth/presentation/screens/auth_screen.dart';
import 'package:neutralitical_app/features/cart/presentation/screens/cart_screen.dart';
import 'package:neutralitical_app/features/catalog/presentation/providers/product_provider.dart';
import 'package:neutralitical_app/features/catalog/presentation/screens/catalog_screen.dart';
import 'package:neutralitical_app/features/catalog/presentation/screens/product_detail_screen.dart';
import 'package:neutralitical_app/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:neutralitical_app/features/orders/presentation/screens/order_history_screen.dart';
import 'package:neutralitical_app/features/profile/presentation/screens/profile_screen.dart';

GoRouter createAppRouter() {
  return GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const CatalogScreen(),
      ),
      GoRoute(
        path: '/product/:id',
        builder: (context, state) {
          final productId = state.pathParameters['id']!;
          final product = context.read<ProductProvider>().getProductById(productId);

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
        path: '/auth',
        builder: (context, state) => const AuthScreen(),
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
