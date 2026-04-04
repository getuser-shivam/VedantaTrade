import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedanta_trade/app/theme/app_theme.dart';
import 'package:vedanta_trade/shared/app_scaffold.dart';
import 'package:vedanta_trade/shared/widgets/glassmorphic_widgets.dart';
import 'package:vedanta_trade/features/auth/presentation/providers/auth_provider.dart';
import 'package:dio/dio.dart';
import 'package:vedanta_trade/core/api_config.dart';
import 'package:intl/intl.dart';
import 'dart:async';

/// Real-time Order Management Screen for Stockists
class OrderManagementScreen extends StatefulWidget {
  const OrderManagementScreen({super.key});

  @override
  State<OrderManagementScreen> createState() => _OrderManagementScreenState();
}

class _OrderManagementScreenState extends State<OrderManagementScreen>
    with TickerProviderStateMixin {
  List<Map<String, dynamic>> _orders = [];
  List<Map<String, dynamic>> _retailers = [];
  List<Map<String, dynamic>> _products = [];
  bool _loading = true;
  String _selectedFilter = 'all';
  Timer? _realtimeTimer;
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
    _startRealtimeUpdates();
  }

  @override
  void dispose() {
    _realtimeTimer?.cancel();
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// Start real-time updates every 30 seconds
  void _startRealtimeUpdates() {
    _realtimeTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        _loadOrders();
        _loadRetailers();
      }
    });
  }

  /// Load all necessary data
  Future<void> _loadData() async {
    setState(() => _loading = true);
    await Future.wait([
      _loadOrders(),
      _loadRetailers(),
      _loadProducts(),
    ]);
    setState(() => _loading = false);
  }

  /// Load orders with real-time status
  Future<void> _loadOrders() async {
    try {
      final auth = context.read<AuthProvider>();
      final dio = Dio();
      
      final response = await dio.get(
        '${ApiConfig.baseUrl}/stockists/orders',
        options: Options(headers: {'Authorization': 'Bearer ${auth.token}'}),
      );
      
      if (mounted) {
        setState(() {
          _orders = (response.data['data'] as List<dynamic>?)
                  ?.map((order) => Map<String, dynamic>.from(order))
                  .toList() ??
              _getMockOrders();
        });
      }
    } catch (e) {
      debugPrint('Error loading orders: $e');
      if (mounted) {
        setState(() {
          _orders = _getMockOrders();
        });
      }
    }
  }

  /// Load retailers for order creation
  Future<void> _loadRetailers() async {
    try {
      final auth = context.read<AuthProvider>();
      final dio = Dio();
      
      final response = await dio.get(
        '${ApiConfig.baseUrl}/stockists/retailers',
        options: Options(headers: {'Authorization': 'Bearer ${auth.token}'}),
      );
      
      if (mounted) {
        setState(() {
          _retailers = (response.data['data'] as List<dynamic>?)
                  ?.map((retailer) => Map<String, dynamic>.from(retailer))
                  .toList() ??
              _getMockRetailers();
        });
      }
    } catch (e) {
      debugPrint('Error loading retailers: $e');
      if (mounted) {
        setState(() {
          _retailers = _getMockRetailers();
        });
      }
    }
  }

  /// Load products for order creation
  Future<void> _loadProducts() async {
    try {
      final auth = context.read<AuthProvider>();
      final dio = Dio();
      
      final response = await dio.get(
        '${ApiConfig.baseUrl}/stockists/products',
        options: Options(headers: {'Authorization': 'Bearer ${auth.token}'}),
      );
      
      if (mounted) {
        setState(() {
          _products = (response.data['data'] as List<dynamic>?)
                  ?.map((product) => Map<String, dynamic>.from(product))
                  .toList() ??
              _getMockProducts();
        });
      }
    } catch (e) {
      debugPrint('Error loading products: $e');
      if (mounted) {
        setState(() {
          _products = _getMockProducts();
        });
      }
    }
  }

  /// Mock orders for development
  List<Map<String, dynamic>> _getMockOrders() {
    return [
      {
        'id': 'ORD001',
        'retailerId': 'RET001',
        'retailerName': 'Janakpur Pharmacy',
        'retailerPhone': '9876543210',
        'status': 'pending',
        'totalAmount': 15000,
        'vatAmount': 1950,
        'finalAmount': 16950,
        'items': [
          {'sku': 'MED001', 'name': 'Paracetamol 500mg', 'quantity': 10, 'unitPrice': 5, 'total': 50},
          {'sku': 'MED002', 'name': 'Amoxicillin 250mg', 'quantity': 5, 'unitPrice': 15, 'total': 75},
        ],
        'createdAt': DateTime.now().subtract(const Duration(hours: 2)),
        'expectedDelivery': DateTime.now().add(const Duration(days: 2)),
        'paymentStatus': 'pending',
        'deliveryStatus': 'pending',
        'notes': 'Urgent delivery required',
      },
      {
        'id': 'ORD002',
        'retailerId': 'RET002',
        'retailerName': 'City Medical Store',
        'retailerPhone': '9876543211',
        'status': 'approved',
        'totalAmount': 25000,
        'vatAmount': 3250,
        'finalAmount': 28250,
        'items': [
          {'sku': 'MED003', 'name': 'Ibuprofen 400mg', 'quantity': 20, 'unitPrice': 8, 'total': 160},
          {'sku': 'MED004', 'name': 'Cetrizine 10mg', 'quantity': 15, 'unitPrice': 12, 'total': 180},
        ],
        'createdAt': DateTime.now().subtract(const Duration(hours: 5)),
        'expectedDelivery': DateTime.now().add(const Duration(days: 1)),
        'paymentStatus': 'paid',
        'deliveryStatus': 'dispatched',
        'notes': 'Customer waiting for delivery',
      },
      {
        'id': 'ORD003',
        'retailerId': 'RET003',
        'retailerName': 'Shree Medical Hall',
        'retailerPhone': '9876543212',
        'status': 'dispatched',
        'totalAmount': 18000,
        'vatAmount': 2340,
        'finalAmount': 20340,
        'items': [
          {'sku': 'MED005', 'name': 'Aspirin 75mg', 'quantity': 25, 'unitPrice': 6, 'total': 150},
          {'sku': 'MED006', 'name': 'Vitamin C 500mg', 'quantity': 30, 'unitPrice': 10, 'total': 300},
        ],
        'createdAt': DateTime.now().subtract(const Duration(days: 1)),
        'expectedDelivery': DateTime.now().add(const Duration(hours: 4)),
        'paymentStatus': 'paid',
        'deliveryStatus': 'in_transit',
        'notes': 'Delivery in progress',
      },
      {
        'id': 'ORD004',
        'retailerId': 'RET004',
        'retailerName': 'New Life Pharmacy',
        'retailerPhone': '9876543213',
        'status': 'delivered',
        'totalAmount': 22000,
        'vatAmount': 2860,
        'finalAmount': 24860,
        'items': [
          {'sku': 'MED007', 'name': 'Metformin 500mg', 'quantity': 40, 'unitPrice': 7, 'total': 280},
          {'sku': 'MED008', 'name': 'Atorvastatin 10mg', 'quantity': 35, 'unitPrice': 18, 'total': 630},
        ],
        'createdAt': DateTime.now().subtract(const Duration(days: 2)),
        'expectedDelivery': DateTime.now().subtract(const Duration(days: 1)),
        'paymentStatus': 'paid',
        'deliveryStatus': 'delivered',
        'notes': 'Delivered successfully',
      },
    ];
  }

  /// Mock retailers for development
  List<Map<String, dynamic>> _getMockRetailers() {
    return [
      {
        'id': 'RET001',
        'name': 'Janakpur Pharmacy',
        'phone': '9876543210',
        'address': 'Bhanu Chowk, Janakpur',
        'creditLimit': 50000,
        'outstandingAmount': 15000,
        'isPreferred': true,
      },
      {
        'id': 'RET002',
        'name': 'City Medical Store',
        'phone': '9876543211',
        'address': 'Ram Chowk, Janakpur',
        'creditLimit': 30000,
        'outstandingAmount': 8000,
        'isPreferred': false,
      },
      {
        'id': 'RET003',
        'name': 'Shree Medical Hall',
        'phone': '9876543212',
        'address': 'Jaleshwor Road, Janakpur',
        'creditLimit': 40000,
        'outstandingAmount': 12000,
        'isPreferred': true,
      },
      {
        'id': 'RET004',
        'name': 'New Life Pharmacy',
        'phone': '9876543213',
        'address': 'Mahendra Chowk, Janakpur',
        'creditLimit': 35000,
        'outstandingAmount': 5000,
        'isPreferred': false,
      },
    ];
  }

  /// Mock products for development
  List<Map<String, dynamic>> _getMockProducts() {
    return [
      {
        'sku': 'MED001',
        'name': 'Paracetamol 500mg',
        'description': 'Pain relief medication',
        'unitPrice': 5.0,
        'currentStock': 150,
        'minStock': 50,
        'maxStock': 500,
        'category': 'Pain Relief',
        'manufacturer': 'Pharma Corp',
        'expiryDate': DateTime.now().add(const Duration(days: 365)),
      },
      {
        'sku': 'MED002',
        'name': 'Amoxicillin 250mg',
        'description': 'Antibiotic medication',
        'unitPrice': 15.0,
        'currentStock': 25,
        'minStock': 30,
        'maxStock': 200,
        'category': 'Antibiotics',
        'manufacturer': 'MediTech Ltd',
        'expiryDate': DateTime.now().add(const Duration(days: 180)),
      },
      {
        'sku': 'MED003',
        'name': 'Ibuprofen 400mg',
        'description': 'Anti-inflammatory medication',
        'unitPrice': 8.0,
        'currentStock': 80,
        'minStock': 40,
        'maxStock': 300,
        'category': 'Pain Relief',
        'manufacturer': 'Pharma Corp',
        'expiryDate': DateTime.now().add(const Duration(days: 270)),
      },
      {
        'sku': 'MED004',
        'name': 'Cetrizine 10mg',
        'description': 'Antihistamine medication',
        'unitPrice': 12.0,
        'currentStock': 60,
        'minStock': 25,
        'maxStock': 250,
        'category': 'Allergy',
        'manufacturer': 'MediTech Ltd',
        'expiryDate': DateTime.now().add(const Duration(days: 450)),
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Order Management',
      roleColor: AppTheme.stockistColor,
      navItems: const [
        NavItem(label: 'Dashboard', icon: Icons.dashboard_rounded, route: '/stockist'),
        NavItem(label: 'Orders', icon: Icons.shopping_bag_rounded, route: '/orders'),
        NavItem(label: 'Inventory', icon: Icons.inventory_rounded, route: '/products'),
        NavItem(label: 'Retailers', icon: Icons.storefront_rounded, route: '/doctors-list'),
        NavItem(label: 'Invoices', icon: Icons.receipt_long_rounded, route: '/accounting/invoices'),
        NavItem(label: 'Profile', icon: Icons.person_rounded, route: '/profile'),
      ],
      selectedIndex: 1,
      fab: FloatingActionButton.extended(
        onPressed: () => _createNewOrder(),
        backgroundColor: AppTheme.stockistColor,
        icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
        label: const Text('New Order', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.stockistColor))
          : Column(
              children: [
                // Search and Filter Bar
                _buildSearchAndFilterBar(),
                const SizedBox(height: 16),

                // Real-time Status Overview
                _buildStatusOverview(),
                const SizedBox(height: 16),

                // Tabs
                _buildTabs(),
                const SizedBox(height: 16),

                // Tab Content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildOrdersList(),
                      _buildOrderAnalytics(),
                      _buildOrderHistory(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  /// Build search and filter bar
  Widget _buildSearchAndFilterBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Search Bar
          TextField(
            controller: _searchController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search orders by retailer, ID, or status...',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
              prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.6)),
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.stockistColor),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('all', 'All Orders'),
                _buildFilterChip('pending', 'Pending'),
                _buildFilterChip('approved', 'Approved'),
                _buildFilterChip('dispatched', 'Dispatched'),
                _buildFilterChip('delivered', 'Delivered'),
                _buildFilterChip('cancelled', 'Cancelled'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build filter chip
  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => _selectedFilter = value),
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
      ),
    );
  }

  /// Build real-time status overview
  Widget _buildStatusOverview() {
    final pendingOrders = _orders.where((o) => o['status'] == 'pending').length;
    final approvedOrders = _orders.where((o) => o['status'] == 'approved').length;
    final dispatchedOrders = _orders.where((o) => o['status'] == 'dispatched').length;
    final deliveredOrders = _orders.where((o) => o['status'] == 'delivered').length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildStatusCard('Pending', pendingOrders, Colors.orange),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatusCard('Approved', approvedOrders, AppTheme.success),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatusCard('Dispatched', dispatchedOrders, AppTheme.info),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatusCard('Delivered', deliveredOrders, Colors.purple),
          ),
        ],
      ),
    );
  }

  /// Build status card
  Widget _buildStatusCard(String title, int count, Color color) {
    return GlassmorphicCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Build tabs
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
          Tab(text: 'Active Orders'),
          Tab(text: 'Analytics'),
          Tab(text: 'History'),
        ],
      ),
    );
  }

  /// Build orders list
  Widget _buildOrdersList() {
    final filteredOrders = _orders.where((order) {
      if (_selectedFilter != 'all' && order['status'] != _selectedFilter) {
        return false;
      }
      
      if (_searchController.text.isNotEmpty) {
        final searchLower = _searchController.text.toLowerCase();
        return order['retailerName'].toString().toLowerCase().contains(searchLower) ||
               order['id'].toString().toLowerCase().contains(searchLower) ||
               order['status'].toString().toLowerCase().contains(searchLower);
      }
      
      return true;
    }).toList();

    return filteredOrders.isEmpty
        ? _buildEmptyState('No orders found', Icons.shopping_cart_outlined)
        : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: filteredOrders.length,
            itemBuilder: (context, index) {
              final order = filteredOrders[index];
              return _OrderCard(
                order: order,
                onTap: () => _showOrderDetails(order),
                onStatusChange: (newStatus) => _updateOrderStatus(order['id'], newStatus),
                onPaymentUpdate: () => _updatePaymentStatus(order['id']),
              );
            },
          );
  }

  /// Build order analytics
  Widget _buildOrderAnalytics() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Analytics',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // Analytics Grid
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                _buildAnalyticsCard('Today\'s Orders', '12', Icons.today, AppTheme.stockistColor),
                _buildAnalyticsCard('Pending Value', 'NPR 45,000', Icons.pending, Colors.orange),
                _buildAnalyticsCard('Avg Order Value', 'NPR 3,750', Icons.analytics, AppTheme.info),
                _buildAnalyticsCard('Top Retailer', 'Janakpur Pharmacy', Icons.store, AppTheme.success),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build analytics card
  Widget _buildAnalyticsCard(String title, String value, IconData icon, Color color) {
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
              fontSize: 18,
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

  /// Build order history
  Widget _buildOrderHistory() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order History',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // History List
          Expanded(
            child: ListView.builder(
              itemCount: _orders.length,
              itemBuilder: (context, index) {
                final order = _orders[index];
                return _HistoryOrderCard(
                  order: order,
                  onTap: () => _showOrderDetails(order),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Build empty state
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

  /// Create new order
  void _createNewOrder() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CreateOrderModal(
        retailers: _retailers,
        products: _products,
        onSuccess: () => _loadData(),
      ),
    );
  }

  /// Show order details
  void _showOrderDetails(Map<String, dynamic> order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _OrderDetailsModal(
        order: order,
        onStatusChange: (newStatus) => _updateOrderStatus(order['id'], newStatus),
        onPaymentUpdate: () => _updatePaymentStatus(order['id']),
      ),
    );
  }

  /// Update order status
  Future<void> _updateOrderStatus(String orderId, String newStatus) async {
    try {
      final auth = context.read<AuthProvider>();
      final dio = Dio();
      
      await dio.patch(
        '${ApiConfig.baseUrl}/stockists/orders/$orderId',
        data: {'status': newStatus},
        options: Options(headers: {'Authorization': 'Bearer ${auth.token}'}),
      );
      
      await _loadOrders();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order $orderId updated to $newStatus'),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update order: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  /// Update payment status
  Future<void> _updatePaymentStatus(String orderId) async {
    try {
      final auth = context.read<AuthProvider>();
      final dio = Dio();
      
      await dio.patch(
        '${ApiConfig.baseUrl}/stockists/orders/$orderId/payment',
        data: {'paymentStatus': 'paid'},
        options: Options(headers: {'Authorization': 'Bearer ${auth.token}'}),
      );
      
      await _loadOrders();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment marked as paid for order $orderId'),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update payment: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }
}

/// Order Card Widget
class _OrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  final VoidCallback onTap;
  final Function(String) onStatusChange;
  final VoidCallback onPaymentUpdate;

  const _OrderCard({
    required this.order,
    required this.onTap,
    required this.onStatusChange,
    required this.onPaymentUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final status = order['status'] as String;
    final paymentStatus = order['paymentStatus'] as String;
    final statusColor = _getStatusColor(status);
    final paymentColor = _getPaymentColor(paymentStatus);
    
    return GlassmorphicCard(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
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
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [statusColor.withOpacity(0.2), statusColor.withOpacity(0.1)],
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
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [paymentColor.withOpacity(0.2), paymentColor.withOpacity(0.1)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: paymentColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      paymentStatus.toUpperCase(),
                      style: TextStyle(
                        color: paymentColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Amount and Items Row
          Row(
            children: [
              Expanded(
                child: _InfoRow(
                  icon: Icons.monetization_on,
                  label: 'NPR ${order['finalAmount']}',
                  color: AppTheme.success,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _InfoRow(
                  icon: Icons.inventory_2,
                  label: '${order['items'].length} items',
                  color: Colors.white54,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Dates Row
          Row(
            children: [
              Expanded(
                child: _InfoRow(
                  icon: Icons.calendar_today,
                  label: 'Created: ${DateFormat('MMM dd').format(order['createdAt'])}',
                  color: Colors.white54,
                ),
              ),
              const SizedBox(width: 8),
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
          
          // Action Buttons
          Row(
            children: [
              if (status == 'pending') ...[
                Expanded(
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
                const SizedBox(width: 8),
              ],
              if (status == 'approved') ...[
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => onStatusChange('dispatched'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.info.withOpacity(0.2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.local_shipping, color: AppTheme.info, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          'Dispatch',
                          style: TextStyle(color: AppTheme.info, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              if (paymentStatus == 'pending') ...[
                Expanded(
                  child: ElevatedButton(
                    onPressed: onPaymentUpdate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.success.withOpacity(0.2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.payment, color: AppTheme.success, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          'Mark Paid',
                          style: TextStyle(color: AppTheme.success, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
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
      case 'cancelled':
        return AppTheme.error;
      default:
        return Colors.white54;
    }
  }

  Color _getPaymentColor(String paymentStatus) {
    switch (paymentStatus) {
      case 'pending':
        return Colors.orange;
      case 'paid':
        return AppTheme.success;
      case 'overdue':
        return AppTheme.error;
      default:
        return Colors.white54;
    }
  }
}

/// Info Row Widget
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

/// History Order Card Widget
class _HistoryOrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  final VoidCallback onTap;

  const _HistoryOrderCard({
    required this.order,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final status = order['status'] as String;
    final statusColor = _getStatusColor(status);
    
    return GlassmorphicCard(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [statusColor.withOpacity(0.2), statusColor.withOpacity(0.1)],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: statusColor.withOpacity(0.3)),
              ),
              child: Icon(
                _getStatusIcon(status),
                color: statusColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order['retailerName'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Order #${order['id']} • NPR ${order['finalAmount']}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '${DateFormat('MMM dd, yyyy').format(order['createdAt'])}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.5)),
          ],
        ),
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
      case 'cancelled':
        return AppTheme.error;
      default:
        return Colors.white54;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.pending;
      case 'approved':
        return Icons.check_circle;
      case 'dispatched':
        return Icons.local_shipping;
      case 'delivered':
        return Icons.delivery_dining;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }
}

/// Create Order Modal
class _CreateOrderModal extends StatefulWidget {
  final List<Map<String, dynamic>> retailers;
  final List<Map<String, dynamic>> products;
  final VoidCallback onSuccess;

  const _CreateOrderModal({
    required this.retailers,
    required this.products,
    required this.onSuccess,
  });

  @override
  State<_CreateOrderModal> createState() => _CreateOrderModalState();
}

class _CreateOrderModalState extends State<_CreateOrderModal> {
  String? _selectedRetailerId;
  List<Map<String, dynamic>> _orderItems = [];
  bool _submitting = false;
  final _notesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return GlassmorphicBackground(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.bgDark.withOpacity(0.8),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle Bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 24),
            
            // Header
            const Text(
              'Create New Order',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white),
            ),
            const Text(
              'Select retailer and add products to create order',
              style: TextStyle(color: Colors.white38, fontSize: 13),
            ),
            const SizedBox(height: 24),
            
            // Form Content
            Expanded(
              child: ListView(
                children: [
                  // Retailer Selection
                  const Text('RETAILER', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    dropdownColor: AppTheme.surfaceDark,
                    style: const TextStyle(color: Colors.white),
                    decoration: AppTheme.inputDecoration('Select retailer...'),
                    items: widget.retailers.map((retailer) {
                      return DropdownMenuItem(
                        value: retailer['id'],
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(retailer['name']),
                            Text(
                              '${retailer['address']} • Credit: NPR ${retailer['creditLimit']}',
                              style: TextStyle(color: Colors.white54, fontSize: 11),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _selectedRetailerId = value),
                  ),
                  const SizedBox(height: 24),
                  
                  // Add Products Section
                  const Text('PRODUCTS', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ..._orderItems.map((item) => _buildOrderItem(item)).toList(),
                  
                  // Add Product Button
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _addProduct,
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text('Add Product', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.stockistColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Notes
                  const Text('NOTES', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _notesController,
                    maxLines: 3,
                    style: const TextStyle(color: Colors.white),
                    decoration: AppTheme.inputDecoration('Order notes...'),
                  ),
                ],
              ),
            ),
            
            // Order Summary
            if (_orderItems.isNotEmpty) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Subtotal:', style: TextStyle(color: Colors.white70)),
                        Text('NPR ${_calculateSubtotal().toStringAsFixed(2)}', style: const TextStyle(color: Colors.white)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('VAT (13%):', style: TextStyle(color: Colors.white70)),
                        Text('NPR ${_calculateVAT().toStringAsFixed(2)}', style: const TextStyle(color: Colors.white)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        Text('NPR ${_calculateTotal().toStringAsFixed(2)}', style: const TextStyle(color: AppTheme.success, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 24),
            
            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _submitting || _selectedRetailerId == null || _orderItems.isEmpty ? null : _submitOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.stockistColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: _submitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'CREATE ORDER',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, letterSpacing: 1),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItem(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'],
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Text(
                  'NPR ${item['unitPrice']} x ${item['quantity']}',
                  style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            'NPR ${(item['unitPrice'] * item['quantity']).toStringAsFixed(2)}',
            style: const TextStyle(color: AppTheme.success, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => setState(() => _orderItems.remove(item)),
            icon: const Icon(Icons.remove_circle, color: AppTheme.error),
          ),
        ],
      ),
    );
  }

  void _addProduct() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _ProductSelectionModal(
        products: widget.products,
        onProductSelected: (product) {
          setState(() {
            _orderItems.add({
              'sku': product['sku'],
              'name': product['name'],
              'unitPrice': product['unitPrice'],
              'quantity': 1,
            });
          });
        },
      ),
    );
  }

  double _calculateSubtotal() {
    return _orderItems.fold(0.0, (sum, item) => sum + (item['unitPrice'] * item['quantity']));
  }

  double _calculateVAT() {
    return _calculateSubtotal() * 0.13; // 13% VAT
  }

  double _calculateTotal() {
    return _calculateSubtotal() + _calculateVAT();
  }

  Future<void> _submitOrder() async {
    setState(() => _submitting = true);
    
    try {
      final auth = context.read<AuthProvider>();
      final dio = Dio();
      
      final orderData = {
        'retailerId': _selectedRetailerId,
        'items': _orderItems,
        'subtotal': _calculateSubtotal(),
        'vatAmount': _calculateVAT(),
        'totalAmount': _calculateTotal(),
        'finalAmount': _calculateTotal(),
        'notes': _notesController.text,
      };
      
      await dio.post(
        '${ApiConfig.baseUrl}/stockists/orders',
        data: orderData,
        options: Options(headers: {'Authorization': 'Bearer ${auth.token}'}),
      );
      
      widget.onSuccess();
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order created successfully'),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create order: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } finally {
      setState(() => _submitting = false);
    }
  }
}

/// Product Selection Modal
class _ProductSelectionModal extends StatefulWidget {
  final List<Map<String, dynamic>> products;
  final Function(Map<String, dynamic>) onProductSelected;

  const _ProductSelectionModal({
    required this.products,
    required this.onProductSelected,
  });

  @override
  State<_ProductSelectionModal> createState() => _ProductSelectionModalState();
}

class _ProductSelectionModalState extends State<_ProductSelectionModal> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return GlassmorphicBackground(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.6,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.bgDark.withOpacity(0.8),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle Bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 24),
            
            // Header
            const Text(
              'Select Product',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white),
            ),
            const SizedBox(height: 16),
            
            // Search Bar
            TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: AppTheme.inputDecoration('Search products...'),
            ),
            const SizedBox(height: 16),
            
            // Products List
            Expanded(
              child: ListView.builder(
                itemCount: widget.products.length,
                itemBuilder: (context, index) {
                  final product = widget.products[index];
                  return _ProductCard(
                    product: product,
                    onTap: () => widget.onProductSelected(product),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Product Card Widget
class _ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final VoidCallback onTap;

  const _ProductCard({
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final currentStock = product['currentStock'] as int;
    final minStock = product['minStock'] as int;
    final isLowStock = currentStock <= minStock;
    
    return GlassmorphicCard(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'],
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'SKU: ${product['sku']} • ${product['category']}',
                    style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
                  ),
                  Text(
                    'Stock: $currentStock units',
                    style: TextStyle(
                      color: isLowStock ? AppTheme.error : Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'NPR ${product['unitPrice']}',
                  style: const TextStyle(color: AppTheme.success, fontWeight: FontWeight.bold),
                ),
                if (isLowStock)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.error.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Low Stock',
                      style: TextStyle(color: AppTheme.error, fontSize: 10),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Order Details Modal
class _OrderDetailsModal extends StatelessWidget {
  final Map<String, dynamic> order;
  final Function(String) onStatusChange;
  final VoidCallback onPaymentUpdate;

  const _OrderDetailsModal({
    required this.order,
    required this.onStatusChange,
    required this.onPaymentUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return GlassmorphicBackground(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.bgDark.withOpacity(0.8),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle Bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 24),
            
            // Header
            Text(
              'Order #${order['id']}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white),
            ),
            Text(
              order['retailerName'],
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 24),
            
            // Order Details
            Expanded(
              child: ListView(
                children: [
                  // Status Information
                  _buildStatusSection(order),
                  const SizedBox(height: 24),
                  
                  // Items List
                  _buildItemsSection(order),
                  const SizedBox(height: 24),
                  
                  // Payment Information
                  _buildPaymentSection(order),
                  const SizedBox(height: 24),
                  
                  // Notes
                  if (order['notes'] != null && order['notes'].toString().isNotEmpty) ...[
                    _buildNotesSection(order),
                    const SizedBox(height: 24),
                  ],
                  
                  // Action Buttons
                  _buildActionButtons(order),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSection(Map<String, dynamic> order) {
    final status = order['status'] as String;
    final statusColor = _getStatusColor(status);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('STATUS', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [statusColor.withOpacity(0.2), statusColor.withOpacity(0.1)]),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Updated: ${DateFormat('MMM dd, yyyy hh:mm a').format(order['createdAt'])}',
                  style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemsSection(Map<String, dynamic> order) {
    final items = order['items'] as List<dynamic>;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('ORDER ITEMS', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['name'],
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'SKU: ${item['sku']}',
                        style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Text(
                  'x${item['quantity']}',
                  style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
                ),
                const SizedBox(width: 16),
                Text(
                  'NPR ${item['total']}',
                  style: const TextStyle(color: AppTheme.success, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildPaymentSection(Map<String, dynamic> order) {
    final paymentStatus = order['paymentStatus'] as String;
    final paymentColor = _getPaymentColor(paymentStatus);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('PAYMENT INFORMATION', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [paymentColor.withOpacity(0.2), paymentColor.withOpacity(0.1)]),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: paymentColor.withOpacity(0.3)),
                ),
                child: Text(
                  paymentStatus.toUpperCase(),
                  style: TextStyle(color: paymentColor, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Subtotal: NPR ${order['subtotal']}', style: TextStyle(color: Colors.white.withOpacity(0.7))),
                    Text('VAT (13%): NPR ${order['vatAmount']}', style: TextStyle(color: Colors.white.withOpacity(0.7))),
                    Text('Total: NPR ${order['totalAmount']}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    Text('Final: NPR ${order['finalAmount']}', style: const TextStyle(color: AppTheme.success, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection(Map<String, dynamic> order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('NOTES', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(
            order['notes'],
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(Map<String, dynamic> order) {
    final status = order['status'] as String;
    final paymentStatus = order['paymentStatus'] as String;
    
    return Column(
      children: [
        if (status == 'pending') ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => onStatusChange('approved'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.stockistColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Approve Order', style: TextStyle(color: Colors.white)),
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (status == 'approved') ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => onStatusChange('dispatched'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.info,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Dispatch Order', style: TextStyle(color: Colors.white)),
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (paymentStatus == 'pending') ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onPaymentUpdate,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.success,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Mark as Paid', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ],
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
      case 'cancelled':
        return AppTheme.error;
      default:
        return Colors.white54;
    }
  }

  Color _getPaymentColor(String paymentStatus) {
    switch (paymentStatus) {
      case 'pending':
        return Colors.orange;
      case 'paid':
        return AppTheme.success;
      case 'overdue':
        return AppTheme.error;
      default:
        return Colors.white54;
    }
  }
}
