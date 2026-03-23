import 'package:flutter/material.dart';
import 'package:vedanta_trade/app/theme/app_theme.dart';
import 'package:vedanta_trade/shared/app_scaffold.dart';
import 'package:provider/provider.dart';
import 'package:vedanta_trade/providers/auth_provider.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return AppScaffold(
      title: 'Products Inventory',
      roleColor: _getRoleColor(auth.userRole),
      navItems: _getNavItems(auth.userRole),
      selectedIndex: 2,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_rounded, size: 64, color: AppTheme.primary.withOpacity(0.5)),
            const SizedBox(height: 16),
            const Text('Product Catalog', style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Connect to backend to load products', style: TextStyle(color: Colors.white54)),
          ],
        ),
      ),
    );
  }

  Color _getRoleColor(String? role) {
    switch(role) {
      case 'ADMIN': return AppTheme.adminColor;
      case 'STOCKIST': return AppTheme.stockistColor;
      case 'RETAILER': return AppTheme.retailerColor;
      case 'DOCTOR': return AppTheme.doctorColor;
      default: return AppTheme.primary;
    }
  }

  List<NavItem> _getNavItems(String? role) {
    if (role == 'ADMIN') return const [
      NavItem(label: 'Dashboard', icon: Icons.dashboard_rounded, route: '/admin'),
      NavItem(label: 'Users', icon: Icons.people_rounded, route: '/admin/users'),
      NavItem(label: 'Products', icon: Icons.inventory_2_rounded, route: '/products'),
    ];
    if (role == 'STOCKIST') return const [
      NavItem(label: 'Dashboard', icon: Icons.dashboard_rounded, route: '/stockist'),
      NavItem(label: 'Orders', icon: Icons.shopping_bag_rounded, route: '/orders'),
      NavItem(label: 'Inventory', icon: Icons.inventory_rounded, route: '/products'),
    ];
    return const [];
  }
}
