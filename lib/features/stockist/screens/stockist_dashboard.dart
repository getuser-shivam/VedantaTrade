import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedanta_trade/app/theme/enhanced_app_theme.dart';
import 'package:vedanta_trade/shared/widgets/enhanced_ui_components.dart';
import 'package:vedanta_trade/features/auth/presentation/providers/auth_provider.dart';
import 'package:vedanta_trade/features/stockist/presentation/providers/stockist_provider.dart';
import 'package:vedanta_trade/features/stockist/widgets/inventory_alert_widget.dart';
import 'package:vedanta_trade/features/stockist/widgets/order_management_widget.dart';
import 'package:vedanta_trade/features/stockist/widgets/sku_management_widget.dart';
import 'package:intl/intl.dart';

class StockistDashboard extends StatefulWidget {
  const StockistDashboard({super.key});

  @override
  State<StockistDashboard> createState() => _StockistDashboardState();
}

class _StockistDashboardState extends State<StockistDashboard>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initializeAnimations();
    _loadData();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    _fadeController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final stockistProvider = context.read<StockistProvider>();
    await stockistProvider.loadInventory();
    await stockistProvider.loadOrders();
    await stockistProvider.loadRetailers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EnhancedAppTheme.backgroundColor,
      appBar: _buildAppBar(),
      body: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                _buildHeaderStats(),
                _buildTabBar(),
                Expanded(
                  child: _buildTabBarView(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: EnhancedAppTheme.surfaceColor,
      elevation: 0,
      title: Text(
        'Stockist Dashboard',
        style: TextStyle(
          color: EnhancedAppTheme.textPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.notifications,
            color: EnhancedAppTheme.textPrimary,
          ),
          onPressed: _showNotifications,
        ),
        IconButton(
          icon: Icon(
            Icons.refresh,
            color: EnhancedAppTheme.textPrimary,
          ),
          onPressed: _refreshData,
        ),
      ],
    );
  }

  Widget _buildHeaderStats() {
    return Consumer<StockistProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Total Products',
                      '${provider.totalProducts}',
                      Icons.inventory,
                      EnhancedAppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Low Stock',
                      '${provider.lowStockCount}',
                      Icons.warning,
                      Colors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Pending Orders',
                      '${provider.pendingOrders}',
                      Icons.pending,
                      EnhancedAppTheme.secondaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Active Retailers',
                      '${provider.activeRetailers}',
                      Icons.store,
                      EnhancedAppTheme.accentColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return EnhancedUIComponents.glassmorphicCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: EnhancedAppTheme.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: EnhancedAppTheme.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: EnhancedAppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorColor: EnhancedAppTheme.primaryColor,
        labelColor: EnhancedAppTheme.primaryColor,
        unselectedLabelColor: EnhancedAppTheme.textSecondary,
        tabs: const [
          Tab(text: 'Inventory'),
          Tab(text: 'Orders'),
          Tab(text: 'SKU Mgmt'),
          Tab(text: 'Retailers'),
        ],
      ),
    );
  }

  Widget _buildTabBarView() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildInventoryTab(),
        _buildOrdersTab(),
        _buildSkuManagementTab(),
        _buildRetailersTab(),
      ],
    );
  }

  Widget _buildInventoryTab() {
    return Consumer<StockistProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            InventoryAlertWidget(
              lowStockItems: provider.lowStockItems,
              expiredItems: provider.expiredItems,
              onRefresh: provider.loadInventory,
            ),
            Expanded(
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: provider.inventory.length,
                      itemBuilder: (context, index) {
                        final item = provider.inventory[index];
                        return _buildInventoryCard(item);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInventoryCard(Map<String, dynamic> item) {
    final isLowStock = item['stockQuantity'] <= item['lowStockThreshold'];
    final isExpired = item['expiryDate'] != null &&
        DateTime.parse(item['expiryDate']).isBefore(DateTime.now());

    return EnhancedUIComponents.glassmorphicCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      borderColor: isLowStock
          ? Colors.orange
          : isExpired
              ? Colors.red
              : EnhancedAppTheme.glassBorderColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item['name'],
                  style: TextStyle(
                    color: EnhancedAppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isLowStock
                      ? Colors.orange.withOpacity(0.2)
                      : isExpired
                          ? Colors.red.withOpacity(0.2)
                          : EnhancedAppTheme.primaryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isLowStock
                      ? 'Low Stock'
                      : isExpired
                          ? 'Expired'
                          : 'In Stock',
                  style: TextStyle(
                    color: isLowStock
                        ? Colors.orange
                        : isExpired
                            ? Colors.red
                            : EnhancedAppTheme.primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SKU: ${item['sku']}',
                      style: TextStyle(
                        color: EnhancedAppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Stock: ${item['stockQuantity']} units',
                      style: TextStyle(
                        color: EnhancedAppTheme.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'NPR ${NumberFormat('#,##0.00').format(item['price'])}',
                    style: TextStyle(
                      color: EnhancedAppTheme.primaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (item['expiryDate'] != null)
                    Text(
                      'Exp: ${DateFormat('MMM dd, yyyy').format(DateTime.parse(item['expiryDate']))}',
                      style: TextStyle(
                        color: isExpired ? Colors.red : EnhancedAppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: EnhancedUIComponents.enhancedButton(
                  child: const Text('Update Stock'),
                  onPressed: () => _showUpdateStockDialog(item),
                  backgroundColor: EnhancedAppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: EnhancedUIComponents.enhancedButton(
                  child: const Text('View Details'),
                  onPressed: () => _showProductDetails(item),
                  backgroundColor: EnhancedAppTheme.secondaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersTab() {
    return Consumer<StockistProvider>(
      builder: (context, provider, child) {
        return OrderManagementWidget(
          orders: provider.orders,
          retailers: provider.retailers,
          onOrderUpdated: provider.loadOrders,
        );
      },
    );
  }

  Widget _buildSkuManagementTab() {
    return Consumer<StockistProvider>(
      builder: (context, provider, child) {
        return SkuManagementWidget(
          inventory: provider.inventory,
          onInventoryUpdated: provider.loadInventory,
        );
      },
    );
  }

  Widget _buildRetailersTab() {
    return Consumer<StockistProvider>(
      builder: (context, provider, child) {
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: provider.retailers.length,
          itemBuilder: (context, index) {
            final retailer = provider.retailers[index];
            return _buildRetailerCard(retailer);
          },
        );
      },
    );
  }

  Widget _buildRetailerCard(Map<String, dynamic> retailer) {
    return EnhancedUIComponents.glassmorphicCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: EnhancedAppTheme.primaryColor.withOpacity(0.2),
                child: Icon(
                  Icons.store,
                  color: EnhancedAppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      retailer['name'],
                      style: TextStyle(
                        color: EnhancedAppTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      retailer['area'],
                      style: TextStyle(
                        color: EnhancedAppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: retailer['isActive']
                      ? Colors.green.withOpacity(0.2)
                      : Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  retailer['isActive'] ? 'Active' : 'Inactive',
                  style: TextStyle(
                    color: retailer['isActive'] ? Colors.green : Colors.grey,
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
                child: _buildRetailerStat('Orders', '${retailer['totalOrders']}'),
              ),
              Expanded(
                child: _buildRetailerStat('Pending', '${retailer['pendingOrders']}'),
              ),
              Expanded(
                child: _buildRetailerStat('Revenue', 'NPR ${NumberFormat('#,##0').format(retailer['totalRevenue'])}'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRetailerStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: EnhancedAppTheme.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: EnhancedAppTheme.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  void _showNotifications() {
    // TODO: Implement notifications
  }

  void _refreshData() {
    _loadData();
  }

  void _showUpdateStockDialog(Map<String, dynamic> item) {
    // TODO: Implement update stock dialog
  }

  void _showProductDetails(Map<String, dynamic> item) {
    // TODO: Implement product details
  }
}
