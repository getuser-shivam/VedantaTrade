import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedanta_trade/app/theme/app_theme.dart';
import 'package:vedanta_trade/shared/app_scaffold.dart';
import 'package:vedanta_trade/shared/widgets/glassmorphic_widgets.dart';
import 'package:vedanta_trade/features/authentication/presentation/providers/auth_provider.dart';
import 'package:vedanta_trade/features/stockist/presentation/providers/order_provider.dart';
import 'package:dio/dio.dart';
import 'package:vedanta_trade/core/api_config.dart';
import 'package:intl/intl.dart';
import 'package:vedanta_trade/features/stockist/presentation/screens/order_management_screen.dart';

class StockistDashboard extends StatefulWidget {
  const StockistDashboard({super.key});
  @override
  State<StockistDashboard> createState() => _StockistDashboardState();
}

class _StockistDashboardState extends State<StockistDashboard>
    with TickerProviderStateMixin {
  Map<String, dynamic>? _stats;
  bool _loading = true;
  List<dynamic> _orders = [];
  List<dynamic> _inventory = [];
  late TabController _tabController;

  @override
  void initState() { 
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final auth = context.read<AuthProvider>();
      final dio = Dio();
      
      // Load dashboard stats
// final res = await dio.get('${ApiConfig.baseUrl}/stockists/dashboard', options: Options(headers: {'Authorization': 'Bearer ${auth.token}'})); // TODO: Move to environment variables
      if (mounted) {
        setState(() {
          _stats = res.data['data'] ?? {'pendingOrders': 0, 'totalInventoryItems': 0, 'overduePayments': 0, 'outstandingAmount': 0};
          _loading = false;
        });
      }
      
      // Load orders
      await _loadOrders();
      
      // Load inventory
      await _loadInventory();
      
    } catch (_) { 
      if (mounted) {
        setState(() { 
          _loading = false;
          _stats = {'pendingOrders': 0, 'totalInventoryItems': 0, 'overduePayments': 0, 'outstandingAmount': 0};
        });
      }
    }
  }

  Future<void> _loadOrders() async {
    try {
      final auth = context.read<AuthProvider>();
      final dio = Dio();
      
// final res = await dio.get('${ApiConfig.baseUrl}/stockists/orders', options: Options(headers: {'Authorization': 'Bearer ${auth.token}'})); // TODO: Move to environment variables
      
      if (mounted) {
        setState(() {
          _orders = res.data['data'] ?? [
            {
              'id': 'ORD001',
              'retailerName': 'Janakpur Pharmacy',
              'status': 'pending',
              'totalAmount': 15000,
              'items': 5,
              'createdAt': DateTime.now().subtract(const Duration(hours: 2)),
              'expectedDelivery': DateTime.now().add(const Duration(days: 2)),
            },
            {
              'id': 'ORD002',
              'retailerName': 'City Medical Store',
              'status': 'approved',
              'totalAmount': 25000,
              'items': 8,
              'createdAt': DateTime.now().subtract(const Duration(hours: 5)),
              'expectedDelivery': DateTime.now().add(const Duration(days: 1)),
            },
          ];
        });
      }
    } catch (e) {
      
    }
  }

  Future<void> _loadInventory() async {
    try {
      final auth = context.read<AuthProvider>();
      final dio = Dio();
      
// final res = await dio.get('${ApiConfig.baseUrl}/stockists/inventory', options: Options(headers: {'Authorization': 'Bearer ${auth.token}'})); // TODO: Move to environment variables
      
      if (mounted) {
        setState(() {
          _inventory = res.data['data'] ?? [
            {
              'sku': 'MED001',
              'productName': 'Paracetamol 500mg',
              'currentStock': 150,
              'minStock': 50,
              'maxStock': 500,
              'unitPrice': 5,
              'expiryDate': DateTime.now().add(const Duration(days: 365)),
              'supplier': 'Pharma Corp',
            },
            {
              'sku': 'MED002',
              'productName': 'Amoxicillin 250mg',
              'currentStock': 25,
              'minStock': 30,
              'maxStock': 200,
              'unitPrice': 15,
              'expiryDate': DateTime.now().add(const Duration(days: 180)),
              'supplier': 'MediTech Ltd',
            },
          ];
        });
      }
    } catch (e) {
      
    }
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
        onPressed: () => _createNewOrder(),
        backgroundColor: AppTheme.stockistColor,
        icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
        label: const Text('New Order', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: _loading
          ? const Center(child: LoadingAnimation())
          : RefreshIndicator(
              onRefresh: _loadData,
              color: AppTheme.stockistColor,
              child: Column(
                children: [
                  // Stats Cards
                  _buildStatsCards(),
                  const SizedBox(height: 20),

                  // Quick Actions
                  _buildQuickActions(),
                  const SizedBox(height: 20),

                  // Tabs
                  _buildTabs(),
                  const SizedBox(height: 20),

                  // Tab Content
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildOrdersTab(),
                        _buildInventoryTab(),
                        _buildAnalyticsTab(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatsCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: GlassmorphicStatCard(
              title: 'Pending Orders',
              value: '${_stats?['pendingOrders'] ?? 0}',
              icon: Icons.pending_rounded,
              color: Colors.orange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GlassmorphicStatCard(
              title: 'Inventory Items',
              value: '${_stats?['totalInventoryItems'] ?? 0}',
              icon: Icons.inventory_rounded,
              color: AppTheme.stockistColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GlassmorphicStatCard(
              title: 'Outstanding',
              value: 'NPR ${(_stats?['outstandingAmount'] ?? 0).toString()}',
              icon: Icons.account_balance_wallet_rounded,
              color: AppTheme.success,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _QuickActionCard(
              icon: Icons.add_shopping_cart,
              label: 'New Order',
              color: AppTheme.stockistColor,
              onTap: () => _createNewOrder(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _QuickActionCard(
              icon: Icons.inventory_rounded,
              label: 'Stock Check',
              color: AppTheme.info,
              onTap: () => _tabController.animateTo(1),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _QuickActionCard(
              icon: Icons.analytics_rounded,
              label: 'Reports',
              color: AppTheme.success,
              onTap: () => _tabController.animateTo(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorColor: AppTheme.stockistColor,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white54,
        tabs: const [
          Tab(text: 'Orders'),
          Tab(text: 'Inventory'),
          Tab(text: 'Analytics'),
        ],
      ),
    );
  }

  Widget _buildOrdersTab() {
    return Column(
      children: [
        // Filter Chips
        _buildOrderFilters(),
        const SizedBox(height: 16),

        // Orders List
        Expanded(
          child: _orders.isEmpty
              ? _buildEmptyState('No orders found', Icons.shopping_cart_outlined)
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _orders.length,
                  itemBuilder: (context, index) {
                    final order = _orders[index];
                    return _OrderCard(
                      order: order,
                      onTap: () => _showOrderDetails(order),
                      onStatusChange: (newStatus) => _updateOrderStatus(order['id'], newStatus),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildOrderFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _FilterChip(
              label: 'All',
              isSelected: true,
              onTap: () {},
            ),
            const SizedBox(width: 8),
            _FilterChip(
              label: 'Pending',
              isSelected: false,
              onTap: () {},
            ),
            const SizedBox(width: 8),
            _FilterChip(
              label: 'Approved',
              isSelected: false,
              onTap: () {},
            ),
            const SizedBox(width: 8),
            _FilterChip(
              label: 'Dispatched',
              isSelected: false,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInventoryTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Search Bar
          TextField(
            style: const TextStyle(color: Colors.white),
            decoration: AppTheme.inputDecoration('Search inventory...'),
          ),
          const SizedBox(height: 16),

          // Inventory List
          Expanded(
            child: _inventory.isEmpty
                ? _buildEmptyState('No inventory items', Icons.inventory_outlined)
                : ListView.builder(
                    itemCount: _inventory.length,
                    itemBuilder: (context, index) {
                      final item = _inventory[index];
                      return _InventoryCard(
                        item: item,
                        onTap: () => _showInventoryDetails(item),
                        onRestock: () => _showRestockDialog(item),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sales Analytics',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // Analytics Cards
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                _AnalyticsCard(
                  title: 'Today\'s Sales',
                  value: 'NPR 45,000',
                  icon: Icons.trending_up,
                  color: AppTheme.success,
                ),
                _AnalyticsCard(
                  title: 'Orders Today',
                  value: '12',
                  icon: Icons.shopping_cart,
                  color: AppTheme.stockistColor,
                ),
                _AnalyticsCard(
                  title: 'Avg Order Value',
                  value: 'NPR 3,750',
                  icon: Icons.analytics,
                  color: AppTheme.info,
                ),
                _AnalyticsCard(
                  title: 'Top Product',
                  value: 'Paracetamol',
                  icon: Icons.star,
                  color: Colors.orange,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Colors.white38),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(color: Colors.white38, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  void _createNewOrder() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const OrderManagementScreen(),
      ),
    );
  }

  void _showOrderDetails(Map<String, dynamic> order) {
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Order ${order['id']} details')),
    );
  }

  void _updateOrderStatus(String orderId, String newStatus) async {
    try {
      final auth = context.read<AuthProvider>();
      final dio = Dio();
      
      await dio.patch(
        '${ApiConfig.baseUrl}/stockists/orders/$orderId',
        data: {'status': newStatus},
        options: Options(headers: {'Authorization': 'Bearer ${auth.token}'}),
      );
      
      // Refresh data
      await _loadOrders();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order $orderId updated to $newStatus'),
          backgroundColor: AppTheme.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update order: $e'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  void _showInventoryDetails(Map<String, dynamic> item) {
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Inventory details for ${item['productName']}')),
    );
  }

  void _showRestockDialog(Map<String, dynamic> item) {
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Restock ${item['productName']}')),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassmorphicCard(
        height: 80,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withOpacity(0.2),
                    color.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(colors: [AppTheme.stockistColor, AppTheme.stockistColor.withOpacity(0.8)])
              : LinearGradient(colors: [Colors.white.withOpacity(0.05), Colors.white.withOpacity(0.02)]),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.stockistColor : Colors.white.withOpacity(0.2),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  final VoidCallback onTap;
  final Function(String) onStatusChange;

  const _OrderCard({
    required this.order,
    required this.onTap,
    required this.onStatusChange,
  });

  @override
  Widget build(BuildContext context) {
    final status = order['status'] as String;
    final statusColor = _getStatusColor(status);
    
    return GlassmorphicCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order['retailerName'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Order #${order['id']}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      statusColor.withOpacity(0.2),
                      statusColor.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _InfoRow(
                  icon: Icons.monetization_on,
                  label: 'NPR ${order['totalAmount']}',
                  color: AppTheme.success,
                ),
              ),
              Expanded(
                child: _InfoRow(
                  icon: Icons.inventory_2,
                  label: '${order['items']} items',
                  color: Colors.white54,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _InfoRow(
                  icon: Icons.calendar_today,
                  label: 'Created: ${DateFormat('MMM dd').format(order['createdAt'])}',
                  color: Colors.white54,
                ),
              ),
              Expanded(
                child: _InfoRow(
                  icon: Icons.event,
                  label: 'Delivery: ${DateFormat('MMM dd').format(order['expectedDelivery'])}',
                  color: AppTheme.info,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (status == 'pending')
            SizedBox(
              width: double.infinity,
              height: 36,
              child: ElevatedButton(
                onPressed: () => onStatusChange('approved'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.stockistColor.withOpacity(0.2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check, color: AppTheme.stockistColor, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'Approve',
                      style: TextStyle(color: AppTheme.stockistColor, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return AppTheme.success;
      case 'dispatched':
        return AppTheme.info;
      case 'delivered':
        return Colors.purple;
      default:
        return Colors.white54;
    }
  }
}

class _InventoryCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onTap;
  final VoidCallback onRestock;

  const _InventoryCard({
    required this.item,
    required this.onTap,
    required this.onRestock,
  });

  @override
  Widget build(BuildContext context) {
    final currentStock = item['currentStock'] as int;
    final minStock = item['minStock'] as int;
    final isLowStock = currentStock <= minStock;
    final expiryDate = item['expiryDate'] as DateTime;
    final isExpiringSoon = expiryDate.difference(DateTime.now).inDays <= 30;

    return GlassmorphicCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['productName'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'SKU: ${item['sku']}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isLowStock
                        ? [AppTheme.error.withOpacity(0.2), AppTheme.error.withOpacity(0.1)]
                        : [AppTheme.success.withOpacity(0.2), AppTheme.success.withOpacity(0.1)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isLowStock ? AppTheme.error.withOpacity(0.3) : AppTheme.success.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  '$currentStock units',
                  style: TextStyle(
                    color: isLowStock ? AppTheme.error : AppTheme.success,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _InfoRow(
                  icon: Icons.monetization_on,
                  label: 'NPR ${item['unitPrice']}',
                  color: AppTheme.success,
                ),
              ),
              const SizedBox(width: 8),
              if (isLowStock)
                Expanded(
                  child: _InfoRow(
                    icon: Icons.warning,
                    label: 'Low Stock',
                    color: AppTheme.error,
                  ),
                )
              else
                Expanded(
                  child: _InfoRow(
                    icon: Icons.inventory,
                    label: 'Min: $minStock',
                    color: Colors.white54,
                  ),
                ),
            ],
          ),
          if (isExpiringSoon) ...[
            const SizedBox(height: 8),
            _InfoRow(
              icon: Icons.event,
              label: 'Expires in ${expiryDate.difference(DateTime.now).inDays} days',
              color: Colors.orange,
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 36,
            child: ElevatedButton(
              onPressed: onRestock,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.stockistColor.withOpacity(0.2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_shopping_cart, color: AppTheme.stockistColor, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Restock',
                    style: TextStyle(color: AppTheme.stockistColor, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _AnalyticsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _AnalyticsCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassmorphicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
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
