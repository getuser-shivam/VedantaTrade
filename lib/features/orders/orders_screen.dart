import 'package:flutter/material.dart';
import 'package:vedanta_trade/app/theme/app_theme.dart';
import 'package:vedanta_trade/shared/app_scaffold.dart';
import 'package:provider/provider.dart';
import 'package:vedanta_trade/providers/auth_provider.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return AppScaffold(
      title: 'Order Management',
      roleColor: _getRoleColor(auth.userRole),
      navItems: _getNavItems(auth.userRole),
      selectedIndex: _getIndex(auth.userRole),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag_rounded, size: 64, color: AppTheme.primary.withOpacity(0.5)),
            const SizedBox(height: 16),
            const Text('Orders', style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Connect to backend to load B2B orders', style: TextStyle(color: Colors.white54)),
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
      case 'MEDICAL_REP': return AppTheme.mrColor;
      default: return AppTheme.primary;
    }
  }

  int _getIndex(String? role) {
    if (role == 'ADMIN') return 3;
    if (role == 'STOCKIST') return 1;
    if (role == 'RETAILER') return 1;
    if (role == 'DOCTOR') return 1;
    if (role == 'MEDICAL_REP') return 5;
    return 1;
  }

  List<NavItem> _getNavItems(String? role) {
    if (role == 'ADMIN') return const [
      NavItem(label: 'Dashboard', icon: Icons.dashboard_rounded, route: '/admin'),
      NavItem(label: 'Users', icon: Icons.people_rounded, route: '/admin/users'),
      NavItem(label: 'Products', icon: Icons.inventory_2_rounded, route: '/products'),
      NavItem(label: 'Orders', icon: Icons.shopping_bag_rounded, route: '/orders'),
    ];
    if (role == 'STOCKIST') return const [
      NavItem(label: 'Dashboard', icon: Icons.dashboard_rounded, route: '/stockist'),
      NavItem(label: 'Orders', icon: Icons.shopping_bag_rounded, route: '/orders'),
      NavItem(label: 'Inventory', icon: Icons.inventory_rounded, route: '/products'),
    ];
    if (role == 'RETAILER') return const [
      NavItem(label: 'Dashboard', icon: Icons.dashboard_rounded, route: '/retailer'),
      NavItem(label: 'Orders', icon: Icons.shopping_bag_rounded, route: '/orders'),
      NavItem(label: 'Inventory', icon: Icons.inventory_rounded, route: '/products'),
    ];
    if (role == 'DOCTOR') return const [
      NavItem(label: 'Dashboard', icon: Icons.dashboard_rounded, route: '/doctor'),
      NavItem(label: 'Orders', icon: Icons.shopping_bag_rounded, route: '/orders'),
      NavItem(label: 'Products', icon: Icons.inventory_2_rounded, route: '/products'),
    ];
    if (role == 'MEDICAL_REP') return const [
      NavItem(label: 'MR Dashboard', icon: Icons.dashboard_rounded, route: '/mr'),
      NavItem(label: 'Doctor Visits', icon: Icons.medical_services_rounded, route: '/mr/visits'),
      NavItem(label: 'Tour Plan', icon: Icons.map_rounded, route: '/mr/tour-plan'),
      NavItem(label: 'Expenses', icon: Icons.receipt_long_rounded, route: '/mr/expenses'),
      NavItem(label: 'Doctor List', icon: Icons.health_and_safety_rounded, route: '/doctors-list'),
      NavItem(label: 'Orders', icon: Icons.shopping_bag_rounded, route: '/orders'),
    ];
    return const [];
  }
}
