import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vedanta_trade/app/theme/app_theme.dart';
import 'package:vedanta_trade/shared/app_scaffold.dart';
import 'package:vedanta_trade/shared/widgets.dart';
import 'package:provider/provider.dart';
import 'package:vedanta_trade/providers/auth_provider.dart';
import 'package:dio/dio.dart';
import 'package:vedanta_trade/core/api_config.dart';

class RetailerDashboard extends StatefulWidget {
  const RetailerDashboard({super.key});
  @override
  State<RetailerDashboard> createState() => _RetailerDashboardState();
}

class _RetailerDashboardState extends State<RetailerDashboard> {
  Map<String, dynamic>? _stats;
  bool _loading = true;

  @override
  void initState() { super.initState(); _loadData(); }

  Future<void> _loadData() async {
    try {
      final auth = context.read<AuthProvider>();
      final dio = Dio();
      final res = await dio.get('${ApiConfig.baseUrl}/retailers/dashboard', options: Options(headers: {'Authorization': 'Bearer ${auth.token}'}));
      if (mounted) setState(() { _stats = res.data['data']; _loading = false; });
    } catch (_) { if (mounted) setState(() { _loading = false; _stats = {'pendingOrders': 0, 'inventoryCount': 0, 'pendingInvoices': 0}; }); }
  }

  static const _navItems = [
    NavItem(label: 'Dashboard', icon: Icons.dashboard_rounded, route: '/retailer'),
    NavItem(label: 'Orders', icon: Icons.shopping_bag_rounded, route: '/orders'),
    NavItem(label: 'Inventory', icon: Icons.inventory_rounded, route: '/products'),
    NavItem(label: 'Invoices', icon: Icons.receipt_long_rounded, route: '/accounting/invoices'),
    NavItem(label: 'Profile', icon: Icons.person_rounded, route: '/profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Retailer Dashboard',
      roleColor: AppTheme.retailerColor,
      navItems: _navItems,
      selectedIndex: 0,
      fab: FloatingActionButton.extended(
        onPressed: () => context.go('/orders'),
        backgroundColor: AppTheme.retailerColor,
        icon: const Icon(Icons.add_shopping_cart_rounded),
        label: const Text('Place Order'),
      ),
      body: _loading
        ? const Center(child: CircularProgressIndicator(color: AppTheme.retailerColor))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [AppTheme.retailerColor.withOpacity(0.25), AppTheme.primary.withOpacity(0.05)]),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(children: [
                  Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: AppTheme.retailerColor.withOpacity(0.2), borderRadius: BorderRadius.circular(12)), child: Icon(Icons.storefront_rounded, color: AppTheme.retailerColor, size: 28)),
                  const SizedBox(width: 16),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(_stats?['profile']?['firmName'] ?? 'City Pharmacy', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                    Text(_stats?['profile']?['city'] ?? 'Mumbai', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                  ]),
                ]),
              ),
              const SizedBox(height: 24),
              GridView.count(
                crossAxisCount: 3, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16, crossAxisSpacing: 16, childAspectRatio: 1.5,
                children: [
                  StatCard(title: 'Pending Orders', value: '${_stats?['pendingOrders'] ?? 0}', icon: Icons.pending_actions_rounded, color: AppTheme.retailerColor),
                  StatCard(title: 'Inventory Items', value: '${_stats?['inventoryCount'] ?? 0}', icon: Icons.inventory_rounded, color: AppTheme.primary),
                  StatCard(title: 'Unpaid Invoices', value: '${_stats?['pendingInvoices'] ?? 0}', icon: Icons.receipt_long_rounded, color: AppTheme.warning),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: AppTheme.cardDark, borderRadius: BorderRadius.circular(16)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const SectionHeader(title: 'Quick Actions'),
                  const SizedBox(height: 16),
                  GridView.count(crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 3, children: [
                    _ActionBtn(icon: Icons.shopping_cart_rounded, label: 'Order from Stockist', color: AppTheme.retailerColor, onTap: () => context.go('/orders')),
                    _ActionBtn(icon: Icons.inventory_2_rounded, label: 'View Products', color: AppTheme.primary, onTap: () => context.go('/products')),
                    _ActionBtn(icon: Icons.receipt_long_rounded, label: 'View Invoices', color: AppTheme.accountantColor, onTap: () => context.go('/accounting/invoices')),
                    _ActionBtn(icon: Icons.person_rounded, label: 'My Profile', color: AppTheme.secondary, onTap: () => context.go('/profile')),
                  ]),
                ]),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: AppTheme.cardDark, borderRadius: BorderRadius.circular(16)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const SectionHeader(title: '📦 Low Stock Alert'),
                  const SizedBox(height: 12),
                  _LowStockItem(name: 'Vitamin D3 60000 IU', stock: 5, min: 20),
                  const SizedBox(height: 8),
                  _LowStockItem(name: 'Amoxicillin 500mg', stock: 12, min: 25),
                ]),
              ),
            ]),
          ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: color.withOpacity(0.25))),
        child: Row(children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12)),
        ]),
      ),
    );
  }
}

class _LowStockItem extends StatelessWidget {
  final String name;
  final int stock, min;
  const _LowStockItem({required this.name, required this.stock, required this.min});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 16),
      const SizedBox(width: 8),
      Expanded(child: Text(name, style: const TextStyle(color: Colors.white, fontSize: 13))),
      Text('$stock / $min', style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.w600, fontSize: 12)),
    ]);
  }
}
