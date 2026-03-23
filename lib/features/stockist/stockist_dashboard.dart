import 'package:flutter/material.dart';
import 'package:vedanta_trade/app/theme/app_theme.dart';
import 'package:vedanta_trade/shared/app_scaffold.dart';
import 'package:vedanta_trade/shared/widgets.dart';
import 'package:provider/provider.dart';
import 'package:vedanta_trade/providers/auth_provider.dart';
import 'package:dio/dio.dart';
import 'package:vedanta_trade/core/api_config.dart';

class StockistDashboard extends StatefulWidget {
  const StockistDashboard({super.key});
  @override
  State<StockistDashboard> createState() => _StockistDashboardState();
}

class _StockistDashboardState extends State<StockistDashboard> {
  Map<String, dynamic>? _stats;
  bool _loading = true;

  @override
  void initState() { super.initState(); _loadData(); }

  Future<void> _loadData() async {
    try {
      final auth = context.read<AuthProvider>();
      final dio = Dio();
      final res = await dio.get('${ApiConfig.baseUrl}/stockists/dashboard', options: Options(headers: {'Authorization': 'Bearer ${auth.token}'}));
      if (mounted) setState(() { _stats = res.data['data']; _loading = false; });
    } catch (_) { if (mounted) setState(() { _loading = false; _stats = {'pendingOrders': 0, 'totalInventoryItems': 0, 'overduePayments': 0, 'outstandingAmount': 0}; }); }
  }

  static const _navItems = [
    NavItem(label: 'Dashboard', icon: Icons.dashboard_rounded, route: '/stockist'),
    NavItem(label: 'Orders', icon: Icons.shopping_bag_rounded, route: '/orders'),
    NavItem(label: 'Inventory', icon: Icons.inventory_rounded, route: '/products'),
    NavItem(label: 'Retailers', icon: Icons.storefront_rounded, route: '/doctors-list'),
    NavItem(label: 'Invoices', icon: Icons.receipt_long_rounded, route: '/accounting/invoices'),
    NavItem(label: 'Profile', icon: Icons.person_rounded, route: '/profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Stockist Dashboard',
      roleColor: AppTheme.stockistColor,
      navItems: _navItems,
      selectedIndex: 0,
      fab: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: AppTheme.stockistColor,
        icon: const Icon(Icons.add_shopping_cart_rounded),
        label: const Text('New Order'),
      ),
      body: _loading
        ? const Center(child: CircularProgressIndicator(color: AppTheme.stockistColor))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Profile strip
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [AppTheme.stockistColor.withOpacity(0.25), AppTheme.primary.withOpacity(0.05)]),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(children: [
                  Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: AppTheme.stockistColor.withOpacity(0.2), borderRadius: BorderRadius.circular(12)), child: Icon(Icons.warehouse_rounded, color: AppTheme.stockistColor, size: 28)),
                  const SizedBox(width: 16),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(_stats?['profile']?['firmName'] ?? 'Mahesh Distributors', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                    Text('${_stats?['profile']?['city'] ?? 'Mumbai'}  •  Credit: ₹${_stats?['profile']?['creditLimit'] ?? 0}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                  ]),
                ]),
              ),
              const SizedBox(height: 24),
              GridView.count(
                crossAxisCount: 4, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16, crossAxisSpacing: 16, childAspectRatio: 1.4,
                children: [
                  StatCard(title: 'Pending Orders', value: '${_stats?['pendingOrders'] ?? 0}', icon: Icons.pending_actions_rounded, color: AppTheme.stockistColor),
                  StatCard(title: 'Inventory Items', value: '${_stats?['totalInventoryItems'] ?? 0}', icon: Icons.inventory_rounded, color: AppTheme.primary),
                  StatCard(title: 'Overdue Payments', value: '${_stats?['overduePayments'] ?? 0}', icon: Icons.warning_rounded, color: AppTheme.error),
                  StatCard(title: 'Outstanding', value: '₹${_stats?['outstandingAmount'] ?? 0}', icon: Icons.account_balance_wallet_rounded, color: AppTheme.warning),
                ],
              ),
              const SizedBox(height: 24),
              // Inventory Status
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: AppTheme.cardDark, borderRadius: BorderRadius.circular(16)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const SectionHeader(title: 'Inventory Status'),
                  const SizedBox(height: 16),
                  _InventoryRow(product: 'Amoxicillin 500mg', stock: 500, minStock: 100, color: AppTheme.success),
                  const SizedBox(height: 10),
                  _InventoryRow(product: 'Metformin 500mg', stock: 1000, minStock: 200, color: AppTheme.success),
                  const SizedBox(height: 10),
                  _InventoryRow(product: 'Vitamin D3 60000 IU', stock: 50, minStock: 100, color: AppTheme.error, lowStock: true),
                ]),
              ),
              const SizedBox(height: 24),
              // Retailer List
              const SectionHeader(title: 'Active Retailers'),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(color: AppTheme.cardDark, borderRadius: BorderRadius.circular(16)),
                child: Column(children: [
                  _RetailerRow(name: 'City Pharmacy', city: 'Bandra', outstanding: '₹45,000'),
                  const Divider(color: Color(0xFF2D3057), height: 1),
                  _RetailerRow(name: 'Health Plus', city: 'Andheri', outstanding: '₹22,500'),
                ]),
              ),
            ]),
          ),
    );
  }
}

class _InventoryRow extends StatelessWidget {
  final String product;
  final int stock, minStock;
  final Color color;
  final bool lowStock;
  const _InventoryRow({required this.product, required this.stock, required this.minStock, required this.color, this.lowStock = false});

  @override
  Widget build(BuildContext context) {
    final pct = (stock / (minStock * 10)).clamp(0.0, 1.0);
    return Row(children: [
      Expanded(flex: 3, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(product, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
        if (lowStock) const Text('⚠️ Low Stock', style: TextStyle(color: Colors.orange, fontSize: 10)),
      ])),
      const SizedBox(width: 12),
      Expanded(flex: 2, child: ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: pct, color: color, backgroundColor: Colors.white10, minHeight: 6))),
      const SizedBox(width: 12),
      Text('$stock units', style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    ]);
  }
}

class _RetailerRow extends StatelessWidget {
  final String name, city, outstanding;
  const _RetailerRow({required this.name, required this.city, required this.outstanding});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(backgroundColor: AppTheme.retailerColor.withOpacity(0.15), child: Icon(Icons.storefront_rounded, color: AppTheme.retailerColor, size: 18)),
      title: Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
      subtitle: Text(city, style: const TextStyle(color: Colors.white38, fontSize: 11)),
      trailing: Text(outstanding, style: const TextStyle(color: AppTheme.warning, fontWeight: FontWeight.w700, fontSize: 13)),
    );
  }
}
