import 'package:flutter/material.dart';
import 'package:vedanta_trade/app/theme/app_theme.dart';
import 'package:vedanta_trade/shared/app_scaffold.dart';
import 'package:provider/provider.dart';
import 'package:vedanta_trade/features/auth/presentation/providers/auth_provider.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});
  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<dynamic> _orders = [];
  bool _loading = true;
  String _filter = 'ALL';

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    try {
      final auth = context.read<AuthProvider>();
      final dio = Dio();
      final res = await dio.get(
        '${ApiConfig.baseUrl}/orders',
        queryParameters: _filter == 'ALL' ? {} : {'status': _filter},
        options: Options(headers: {'Authorization': 'Bearer ${auth.token}'}),
      );
      if (res.data['success'] == true && mounted) {
        setState(() { _orders = res.data['data']; _loading = false; });
      }
    } catch (_) {
      if (mounted) setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final roleColor = _getRoleColor(auth.userRole);

    return AppScaffold(
      title: 'Order Management',
      roleColor: roleColor,
      navItems: _getNavItems(auth.userRole),
      selectedIndex: _getIndex(auth.userRole),
      actions: [
        IconButton(icon: const Icon(Icons.refresh_rounded, color: Colors.white54), onPressed: _loadOrders),
      ],
      body: Column(
        children: [
          // Filter Tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: ['ALL', 'PENDING', 'APPROVED', 'DISPATCHED', 'DELIVERED', 'CANCELLED'].map((f) {
                final selected = _filter == f;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(f, style: TextStyle(color: selected ? Colors.white : Colors.white38, fontSize: 11, fontWeight: FontWeight.bold)),
                    selected: selected,
                    onSelected: (val) { if (val) setState(() { _filter = f; _loading = true; _loadOrders(); }); },
                    backgroundColor: AppTheme.surfaceDark,
                    selectedColor: roleColor,
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: _loading
              ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
              : _orders.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                    onRefresh: _loadOrders,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _orders.length,
                      itemBuilder: (context, i) => _OrderCard(order: _orders[i], roleColor: roleColor),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 16),
          const Text('No orders found', style: TextStyle(color: Colors.white38, fontSize: 16)),
          if (_filter != 'ALL')
            TextButton(onPressed: () => setState(() { _filter = 'ALL'; _loadOrders(); }), child: const Text('Clear Filters')),
        ],
      ),
    );
  }

  Color _getRoleColor(String? role) {
    switch (role) {
      case 'ADMIN': return AppTheme.adminColor;
      case 'MEDICAL_REP': return AppTheme.mrColor;
      case 'ACCOUNTANT': return AppTheme.accountantColor;
      case 'DOCTOR': return AppTheme.doctorColor;
      case 'STOCKIST': return AppTheme.stockistColor;
      case 'RETAILER': return AppTheme.retailerColor;
      default: return AppTheme.primary;
    }
  }

  int _getIndex(String? role) {
    switch (role) {
      case 'ADMIN': return 3;
      case 'MEDICAL_REP': return 5;
      case 'ACCOUNTANT': return 1; // Assuming orders is 2nd for accountant too
      case 'STOCKIST': return 1;
      case 'RETAILER': return 1;
      case 'DOCTOR': return 1;
      default: return 0;
    }
  }

  List<NavItem> _getNavItems(String? role) {
    if (role == 'ADMIN') return const [
      NavItem(label: 'Dashboard', icon: Icons.dashboard_rounded, route: '/admin'),
      NavItem(label: 'Users', icon: Icons.people_rounded, route: '/admin/users'),
      NavItem(label: 'Products', icon: Icons.inventory_2_rounded, route: '/products'),
      NavItem(label: 'Orders', icon: Icons.shopping_bag_rounded, route: '/orders'),
      NavItem(label: 'Scraper', icon: Icons.travel_explore_rounded, route: '/admin/scraper'),
    ];
    if (role == 'MEDICAL_REP') return const [
      NavItem(label: 'Dashboard', icon: Icons.dashboard_rounded, route: '/mr'),
      NavItem(label: 'Visits', icon: Icons.medical_services_rounded, route: '/mr/visits'),
      NavItem(label: 'Tour Plan', icon: Icons.map_rounded, route: '/mr/tour-plan'),
      NavItem(label: 'Expenses', icon: Icons.receipt_long_rounded, route: '/mr/expenses'),
      NavItem(label: 'Orders', icon: Icons.shopping_bag_rounded, route: '/orders'),
    ];
    // Add other roles as needed
    return [
      NavItem(label: 'Dashboard', icon: Icons.dashboard_rounded, route: role == 'STOCKIST' ? '/stockist' : '/retailer'),
      NavItem(label: 'Orders', icon: Icons.shopping_bag_rounded, route: '/orders'),
      NavItem(label: 'Products', icon: Icons.inventory_2_rounded, route: '/products'),
    ];
  }
}

class _OrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  final Color roleColor;
  const _OrderCard({required this.order, required this.roleColor});

  @override
  Widget build(BuildContext context) {
    final status = order['status'] ?? 'PENDING';
    final itemsCount = (order['items'] as List?)?.length ?? 0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.cardDark, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(order['orderNumber'] ?? '#ORD-000', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              const Spacer(),
              _StatusBadge(status: status),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('From: ${order['retailer']?['name'] ?? order['doctor']?['name'] ?? 'Direct'}', style: const TextStyle(color: Colors.white60, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text('Items: $itemsCount', style: const TextStyle(color: Colors.white38, fontSize: 11)),
                ],
              ),
              const Spacer(),
              Text('₹${order['totalAmount']?.toStringAsFixed(2) ?? '0.00'}', style: TextStyle(color: roleColor, fontWeight: FontWeight.w800, fontSize: 16)),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case 'PENDING': color = AppTheme.warning; break;
      case 'APPROVED': color = AppTheme.success; break;
      case 'DISPATCHED': color = AppTheme.primary; break;
      case 'DELIVERED': color = Colors.green; break;
      case 'CANCELLED': color = AppTheme.error; break;
      default: color = Colors.blueGrey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.4))),
      child: Text(status, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w800)),
    );
  }
}

