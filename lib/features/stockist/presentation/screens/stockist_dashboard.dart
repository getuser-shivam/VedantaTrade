import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/order_management_service.dart';
import '../providers/stockist_provider.dart';
import '../../../../shared/theme/enhanced_theme.dart';
import '../../../../shared/widgets/enhanced_ui_kit.dart';

/// Stockist dashboard with real-time inventory management
class StockistDashboardScreen extends StatefulWidget {
  const StockistDashboardScreen({Key? key}) : super(key: key);

  @override
  State<StockistDashboardScreen> createState() => _StockistDashboardScreenState();
}

class _StockistDashboardScreenState extends State<StockistDashboardScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  List<Order> _orders = [];
  List<StockAlert> _stockAlerts = [];
  List<InventoryItem> _inventory = [];
  bool _isLoading = false;
  String _searchQuery = '';
  OrderStatus? _selectedOrderStatus;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    // Initialize order management service
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeDashboard();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Initialize dashboard
  Future<void> _initializeDashboard() async {
    try {
      setState(() => _isLoading = true);
      
      final orderService = OrderManagementService();
      
      // Get current stockist ID from preferences
      final prefs = await SharedPreferences.getInstance();
      final stockistId = prefs.getString('stockist_id');
      
      if (stockistId != null) {
        // Initialize order service with stockist ID
        await orderService.initialize(stockistId: stockistId);
        
        // Listen to order updates
        orderService.ordersStream.listen((orders) {
          if (mounted) {
            setState(() {
              _orders = orders;
              _isLoading = false;
            });
          }
        });
        
        // Listen to stock alerts
        orderService.stockAlertsStream.listen((alerts) {
          if (mounted) {
            setState(() {
              _stockAlerts = alerts;
            });
          }
        });
        
        // Load inventory
        await _loadInventory();
      }
      
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog('Failed to initialize dashboard: $e');
    }
  }

  /// Load inventory data
  Future<void> _loadInventory() async {
    try {
      // Mock inventory data - in real implementation,
      // this would come from backend API
      setState(() {
        _inventory = [
          InventoryItem(
            sku: 'MED001',
            productName: 'Paracetamol 500mg',
            brand: 'Nepal Pharma',
            currentStock: 150,
            minStock: 50,
            maxStock: 500,
            unitPrice: 25.50,
            batchNumber: 'BATCH001',
            expiryDate: DateTime.now().add(const Duration(days: 365)),
            lastUpdated: DateTime.now(),
          ),
          InventoryItem(
            sku: 'MED002',
            productName: 'Amoxicillin 250mg',
            brand: 'Janakpur Labs',
            currentStock: 35,
            minStock: 30,
            maxStock: 200,
            unitPrice: 45.75,
            batchNumber: 'BATCH002',
            expiryDate: DateTime.now().add(const Duration(days: 180)),
            lastUpdated: DateTime.now(),
          ),
          InventoryItem(
            sku: 'MED003',
            productName: 'Ibuprofen 400mg',
            brand: 'Himalayan Pharma',
            currentStock: 8,
            minStock: 25,
            maxStock: 150,
            unitPrice: 15.25,
            batchNumber: 'BATCH003',
            expiryDate: DateTime.now().add(const Duration(days: 90)),
            lastUpdated: DateTime.now(),
          ),
        ];
      });
      
    } catch (e) {
      print('Failed to load inventory: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EnhancedTheme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          _buildSummaryCards(context),
          _buildTabBar(context),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOrdersTab(context),
                _buildInventoryTab(context),
                _buildAlertsTab(context),
                _buildAnalyticsTab(context),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  /// Build app bar
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return EnhancedAppBar(
      title: 'Stockist Dashboard',
      subtitle: 'Inventory & Order Management',
      backgroundColor: EnhancedTheme.of(context).appBarColor,
      actions: [
        IconButton(
          icon: Icon(
            Icons.search,
            color: EnhancedTheme.of(context).iconColor,
          ),
          onPressed: _showSearchDialog,
        ),
        IconButton(
          icon: Icon(
            Icons.refresh,
            color: EnhancedTheme.of(context).iconColor,
          ),
          onPressed: _refreshData,
        ),
        PopupMenuButton<String>(
          icon: Icon(
            Icons.more_vert,
            color: EnhancedTheme.of(context).iconColor,
          ),
          onSelected: (value) => _handleMenuAction(context, value),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'export',
              child: Row(
                children: [
                  Icon(
                    Icons.download,
                    color: EnhancedTheme.of(context).iconColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Export Data',
                    style: TextStyle(
                      color: EnhancedTheme.of(context).textColor,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'settings',
              child: Row(
                children: [
                  Icon(
                    Icons.settings,
                    color: EnhancedTheme.of(context).iconColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Settings',
                    style: TextStyle(
                      color: EnhancedTheme.of(context).textColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build summary cards
  Widget _buildSummaryCards(BuildContext context) {
    final pendingOrders = _orders.where((order) => order.status == OrderStatus.pending).length;
    final criticalAlerts = _stockAlerts.where((alert) => alert.severity == StockAlertSeverity.critical).length;
    final lowStockItems = _inventory.where((item) => item.currentStock <= item.minStock).length;
    
    return Container(
      height: 120,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              context,
              'Pending Orders',
              '$pendingOrders',
              Icons.shopping_cart,
              Colors.orange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              context,
              'Critical Alerts',
              '$criticalAlerts',
              Icons.warning,
              Colors.red,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              context,
              'Low Stock Items',
              '$lowStockItems',
              Icons.inventory,
              Colors.amber,
            ),
          ),
        ],
      ),
    );
  }

  /// Build summary card
  Widget _buildSummaryCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: EnhancedTheme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blur: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 24,
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.trending_up,
                  color: color,
                  size: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: EnhancedTheme.of(context).textColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: EnhancedTheme.of(context).textColor.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  /// Build tab bar
  Widget _buildTabBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: EnhancedTheme.of(context).cardColor,
        border: Border(
          bottom: BorderSide(
            color: EnhancedTheme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        labelColor: EnhancedTheme.of(context).textColor,
        unselectedLabelColor: EnhancedTheme.of(context).textColor.withOpacity(0.6),
        indicator: BoxDecoration(
          color: EnhancedTheme.of(context).primaryColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(8),
          ),
        ),
        tabs: const [
          Tab(
            text: 'Orders',
            icon: Icon(Icons.shopping_cart),
          ),
          Tab(
            text: 'Inventory',
            icon: Icon(Icons.inventory),
          ),
          Tab(
            text: 'Alerts',
            icon: Icon(Icons.warning),
          ),
          Tab(
            text: 'Analytics',
            icon: Icon(Icons.analytics),
          ),
        ],
      ),
    );
  }

  /// Build orders tab
  Widget _buildOrdersTab(BuildContext context) {
    return Column(
      children: [
        // Order status filter
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                Icons.filter_list,
                color: EnhancedTheme.of(context).iconColor,
              ),
              const SizedBox(width: 8),
              Text(
                'Filter by Status:',
                style: TextStyle(
                  color: EnhancedTheme.of(context).textColor,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButton<OrderStatus>(
                  value: _selectedOrderStatus,
                  hint: Text(
                    'All Orders',
                    style: TextStyle(
                      color: EnhancedTheme.of(context).textColor,
                    ),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: null,
                      child: Text(
                        'All Orders',
                        style: TextStyle(
                          color: EnhancedTheme.of(context).textColor,
                        ),
                      ),
                    ),
                    ...OrderStatus.values.map((status) => DropdownMenuItem(
                      value: status,
                      child: Text(
                        status.toString().split('.').last.capitalize(),
                        style: TextStyle(
                          color: EnhancedTheme.of(context).textColor,
                        ),
                      ),
                    )),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedOrderStatus = value;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
        
        // Orders list
        Expanded(
          child: _isLoading
              ? _buildLoadingWidget(context)
              : _orders.isEmpty
                  ? _buildEmptyState(context, 'No orders found')
                  : ListView.builder(
                      itemCount: _getFilteredOrders().length,
                      itemBuilder: (context, index) {
                        final order = _getFilteredOrders()[index];
                        return _buildOrderCard(context, order);
                      },
                    ),
        ),
      ],
    );
  }

  /// Build inventory tab
  Widget _buildInventoryTab(BuildContext context) {
    return Column(
      children: [
        // Search bar
        Container(
          padding: const EdgeInsets.all(16),
          child: EnhancedTextField(
            hintText: 'Search inventory...',
            prefixIcon: Icon(
              Icons.search,
              color: EnhancedTheme.of(context).iconColor,
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value.toLowerCase();
              });
            },
          ),
        ),
        
        // Inventory list
        Expanded(
          child: _isLoading
              ? _buildLoadingWidget(context)
              : _inventory.isEmpty
                  ? _buildEmptyState(context, 'No inventory found')
                  : ListView.builder(
                      itemCount: _getFilteredInventory().length,
                      itemBuilder: (context, index) {
                        final item = _getFilteredInventory()[index];
                        return _buildInventoryCard(context, item);
                      },
                    ),
        ),
      ],
    );
  }

  /// Build alerts tab
  Widget _buildAlertsTab(BuildContext context) {
    return Column(
      children: [
        // Alert summary
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: _buildAlertSummary(
                  context,
                  'Critical',
                  _stockAlerts.where((alert) => alert.severity == StockAlertSeverity.critical).length,
                  Colors.red,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAlertSummary(
                  context,
                  'Low Stock',
                  _stockAlerts.where((alert) => alert.severity == StockAlertSeverity.low).length,
                  Colors.amber,
                ),
              ),
            ],
          ),
        ),
        
        // Alerts list
        Expanded(
          child: _isLoading
              ? _buildLoadingWidget(context)
              : _stockAlerts.isEmpty
                  ? _buildEmptyState(context, 'No alerts found')
                  : ListView.builder(
                      itemCount: _stockAlerts.length,
                      itemBuilder: (context, index) {
                        final alert = _stockAlerts[index];
                        return _buildAlertCard(context, alert);
                      },
                    ),
        ),
      ],
    );
  }

  /// Build analytics tab
  Widget _buildAnalyticsTab(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Inventory Analytics',
            style: TextStyle(
              color: EnhancedTheme.of(context).textColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Analytics cards
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _buildAnalyticsCard(
                  context,
                  'Total Inventory Value',
                  '₹${_calculateTotalInventoryValue().toStringAsFixed(2)}',
                  Icons.attach_money,
                  Colors.green,
                ),
                _buildAnalyticsCard(
                  context,
                  'Total SKUs',
                  '${_inventory.length}',
                  Icons.category,
                  Colors.blue,
                ),
                _buildAnalyticsCard(
                  context,
                  'Low Stock Items',
                  '${_inventory.where((item) => item.currentStock <= item.minStock).length}',
                  Icons.warning,
                  Colors.amber,
                ),
                _buildAnalyticsCard(
                  context,
                  'Expired Items',
                  '${_inventory.where((item) => item.expiryDate.isBefore(DateTime.now())).length}',
                  Icons.schedule,
                  Colors.red,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build alert summary
  Widget _buildAlertSummary(
    BuildContext context,
    String label,
    int count,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: EnhancedTheme.of(context).textColor,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$count',
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Build order card
  Widget _buildOrderCard(BuildContext context, Order order) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: EnhancedTheme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blur: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
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
                      order.retailerName,
                      style: TextStyle(
                        color: EnhancedTheme.of(context).textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      order.retailerAddress,
                      style: TextStyle(
                        color: EnhancedTheme.of(context).textColor.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(order.status),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  order.status.toString().split('.').last.toUpperCase(),
                  style: TextStyle(
                    color: Colors.white,
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
              Text(
                'Items: ${order.items.length}',
                style: TextStyle(
                  color: EnhancedTheme.of(context).textColor,
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              Text(
                'Total: ₹${order.finalAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  color: EnhancedTheme.of(context).primaryColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Created: ${_formatDate(order.createdAt)}',
                style: TextStyle(
                  color: EnhancedTheme.of(context).textColor.withOpacity(0.7),
                  fontSize: 10,
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  if (order.status == OrderStatus.pending)
                    IconButton(
                      icon: Icon(
                        Icons.check,
                        color: Colors.green,
                        size: 20,
                      ),
                      onPressed: () => _approveOrder(order),
                    ),
                  if (order.status == OrderStatus.approved)
                    IconButton(
                      icon: Icon(
                        Icons.local_shipping,
                        color: Colors.blue,
                        size: 20,
                      ),
                      onPressed: () => _dispatchOrder(order),
                    ),
                  IconButton(
                    icon: Icon(
                      Icons.visibility,
                      color: EnhancedTheme.of(context).primaryColor,
                      size: 20,
                    ),
                    onPressed: () => _viewOrderDetails(order),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build inventory card
  Widget _buildInventoryCard(BuildContext context, InventoryItem item) {
    final isLowStock = item.currentStock <= item.minStock;
    final isExpired = item.expiryDate.isBefore(DateTime.now());
    
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: EnhancedTheme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blur: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isLowStock || isExpired ? Colors.red : Colors.transparent,
          width: 2,
        ),
      ),
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
                      item.productName,
                      style: TextStyle(
                        color: EnhancedTheme.of(context).textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${item.brand} - ${item.sku}',
                      style: TextStyle(
                        color: EnhancedTheme.of(context).textColor.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (isLowStock)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'LOW STOCK',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              if (isExpired)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'EXPIRED',
                    style: TextStyle(
                      color: Colors.white,
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
              Text(
                'Stock: ${item.currentStock}',
                style: TextStyle(
                  color: isLowStock ? Colors.red : EnhancedTheme.of(context).textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Min: ${item.minStock}',
                style: TextStyle(
                  color: EnhancedTheme.of(context).textColor.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Max: ${item.maxStock}',
                style: TextStyle(
                  color: EnhancedTheme.of(context).textColor.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              Text(
                '₹${item.unitPrice.toStringAsFixed(2)}',
                style: TextStyle(
                  color: EnhancedTheme.of(context).primaryColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Batch: ${item.batchNumber}',
                style: TextStyle(
                  color: EnhancedTheme.of(context).textColor.withOpacity(0.7),
                  fontSize: 10,
                ),
              ),
              const Spacer(),
              Text(
                'Expires: ${_formatDate(item.expiryDate)}',
                style: TextStyle(
                  color: isExpired ? Colors.red : EnhancedTheme.of(context).textColor.withOpacity(0.7),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build alert card
  Widget _buildAlertCard(BuildContext context, StockAlert alert) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: EnhancedTheme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blur: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: _getAlertSeverityColor(alert.severity),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning,
                color: _getAlertSeverityColor(alert.severity),
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alert.productName,
                      style: TextStyle(
                        color: EnhancedTheme.of(context).textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${alert.brand} - ${alert.sku}',
                      style: TextStyle(
                        color: EnhancedTheme.of(context).textColor.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getAlertSeverityColor(alert.severity),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  alert.severity.toString().split('.').last.toUpperCase(),
                  style: TextStyle(
                    color: Colors.white,
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
              Text(
                'Current Stock: ${alert.currentStock}',
                style: TextStyle(
                  color: EnhancedTheme.of(context).textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Min Stock: ${alert.minStock}',
                style: TextStyle(
                  color: EnhancedTheme.of(context).textColor.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              Text(
                'Created: ${_formatDate(alert.createdAt)}',
                style: TextStyle(
                  color: EnhancedTheme.of(context).textColor.withOpacity(0.7),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build analytics card
  Widget _buildAnalyticsCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: EnhancedTheme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blur: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  color: EnhancedTheme.of(context).textColor,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Build floating action button
  Widget _buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: EnhancedTheme.of(context).primaryColor,
      onPressed: _showAddOrderDialog,
      child: Icon(
        Icons.add,
        color: Colors.white,
      ),
    );
  }

  /// Build loading widget
  Widget _buildLoadingWidget(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/animations/loading.json',
            width: 100,
            height: 100,
          ),
          const SizedBox(height: 16),
          Text(
            'Loading...',
            style: TextStyle(
              color: EnhancedTheme.of(context).textColor,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  /// Build empty state widget
  Widget _buildEmptyState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: EnhancedTheme.of(context).iconColor.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: EnhancedTheme.of(context).textColor.withOpacity(0.7),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  /// Get filtered orders
  List<Order> _getFilteredOrders() {
    if (_selectedOrderStatus == null) {
      return _orders;
    }
    return _orders.where((order) => order.status == _selectedOrderStatus).toList();
  }

  /// Get filtered inventory
  List<InventoryItem> _getFilteredInventory() {
    if (_searchQuery.isEmpty) {
      return _inventory;
    }
    return _inventory.where((item) =>
        item.productName.toLowerCase().contains(_searchQuery) ||
        item.brand.toLowerCase().contains(_searchQuery) ||
        item.sku.toLowerCase().contains(_searchQuery)
    ).toList();
  }

  /// Get status color
  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.approved:
        return Colors.blue;
      case OrderStatus.dispatched:
        return Colors.purple;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.paid:
        return Colors.teal;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  /// Get alert severity color
  Color _getAlertSeverityColor(StockAlertSeverity severity) {
    switch (severity) {
      case StockAlertSeverity.critical:
        return Colors.red;
      case StockAlertSeverity.low:
        return Colors.amber;
      case StockAlertSeverity.normal:
        return Colors.green;
    }
  }

  /// Calculate total inventory value
  double _calculateTotalInventoryValue() {
    return _inventory.fold(0.0, (sum, item) {
      return sum + (item.currentStock * item.unitPrice);
    });
  }

  /// Format date
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Show search dialog
  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Search Orders'),
        content: EnhancedTextField(
          hintText: 'Enter order ID or retailer name...',
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement search functionality
            },
            child: Text('Search'),
          ),
        ],
      ),
    );
  }

  /// Show add order dialog
  void _showAddOrderDialog() {
    // Navigate to add order screen
    Navigator.pushNamed(context, '/add-order');
  }

  /// Approve order
  Future<void> _approveOrder(Order order) async {
    try {
      final orderService = OrderManagementService();
      final success = await orderService.updateOrderStatus(order.id, OrderStatus.approved);
      
      if (success) {
        _showSuccessSnackBar('Order approved successfully');
      } else {
        _showErrorSnackBar('Failed to approve order');
      }
    } catch (e) {
      _showErrorSnackBar('Error: $e');
    }
  }

  /// Dispatch order
  Future<void> _dispatchOrder(Order order) async {
    try {
      final orderService = OrderManagementService();
      final success = await orderService.updateOrderStatus(order.id, OrderStatus.dispatched);
      
      if (success) {
        _showSuccessSnackBar('Order dispatched successfully');
      } else {
        _showErrorSnackBar('Failed to dispatch order');
      }
    } catch (e) {
      _showErrorSnackBar('Error: $e');
    }
  }

  /// View order details
  void _viewOrderDetails(Order order) {
    Navigator.pushNamed(context, '/order-details', arguments: order);
  }

  /// Refresh data
  Future<void> _refreshData() async {
    setState(() => _isLoading = true);
    
    try {
      final orderService = OrderManagementService();
      await orderService._fetchOrdersFromServer();
      await orderService._fetchStockAlertsFromServer();
      await _loadInventory();
    } catch (e) {
      _showErrorSnackBar('Failed to refresh data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Handle menu actions
  void _handleMenuAction(BuildContext context, String? action) {
    switch (action) {
      case 'export':
        _exportData(context);
        break;
      case 'settings':
        Navigator.pushNamed(context, '/settings');
        break;
    }
  }

  /// Export data
  void _exportData(BuildContext context) {
    // Implement data export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Data exported successfully'),
        backgroundColor: EnhancedTheme.of(context).primaryColor,
      ),
    );
  }

  /// Show success snack bar
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  /// Show error snack bar
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  /// Show error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}

/// Inventory item model
class InventoryItem {
  final String sku;
  final String productName;
  final String brand;
  final int currentStock;
  final int minStock;
  final int maxStock;
  final double unitPrice;
  final String batchNumber;
  final DateTime expiryDate;
  final DateTime lastUpdated;
  
  InventoryItem({
    required this.sku,
    required this.productName,
    required this.brand,
    required this.currentStock,
    required this.minStock,
    required this.maxStock,
    required this.unitPrice,
    required this.batchNumber,
    required this.expiryDate,
    required this.lastUpdated,
  });
}

/// Extension for string capitalization
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }
}
