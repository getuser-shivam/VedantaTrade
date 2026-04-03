import 'package:flutter/material.dart';
import 'package:vedanta_trade/app/theme/app_theme.dart';
import 'package:vedanta_trade/shared/app_scaffold.dart';
import 'package:vedanta_trade/shared/widgets.dart';
import 'package:provider/provider.dart';
import 'package:vedanta_trade/features/auth/presentation/providers/auth_provider.dart';
import 'package:dio/dio.dart';
import 'package:vedanta_trade/core/api_config.dart';
import 'package:intl/intl.dart';

class OrderManagementScreen extends StatefulWidget {
  const OrderManagementScreen({Key? key}) : super(key: key);

  @override
  _OrderManagementScreenState createState() => _OrderManagementScreenState();
}

class _OrderManagementScreenState extends State<OrderManagementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _orders = [];
  List<dynamic> _retailers = [];
  List<dynamic> _products = [];
  bool _loading = true;
  String _selectedStatus = 'ALL';
  final TextEditingController _searchController = TextEditingController();

  // Order lifecycle states
  static const List<String> orderStatuses = [
    'PENDING',
    'APPROVED',
    'DISPATCHED',
    'DELIVERED',
    'PAID',
    'CANCELLED'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final auth = context.read<AuthProvider>();
      final dio = Dio();
      
      // Load orders, retailers, and products in parallel
      final futures = await Future.wait([
        dio.get('${ApiConfig.baseUrl}/stockist/orders', 
             options: Options(headers: {'Authorization': 'Bearer ${auth.token}'})),
        dio.get('${ApiConfig.baseUrl}/stockist/retailers', 
             options: Options(headers: {'Authorization': 'Bearer ${auth.token}'})),
        dio.get('${ApiConfig.baseUrl}/stockist/products', 
             options: Options(headers: {'Authorization': 'Bearer ${auth.token}'})),
      ]);

      if (mounted) {
        setState(() {
          _orders = futures[0].data['data'] ?? [];
          _retailers = futures[1].data['data'] ?? [];
          _products = futures[2].data['data'] ?? [];
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e'), backgroundColor: AppTheme.error),
        );
      }
    }
  }

  List<dynamic> get _filteredOrders {
    var filtered = _orders.where((order) {
      if (_selectedStatus != 'ALL' && order['status'] != _selectedStatus) {
        return false;
      }
      if (_searchController.text.isNotEmpty) {
        final searchTerm = _searchController.text.toLowerCase();
        final retailerName = order['retailer']?['name']?.toString().toLowerCase() ?? '';
        final orderId = order['id']?.toString().toLowerCase() ?? '';
        return retailerName.contains(searchTerm) || orderId.contains(searchTerm);
      }
      return true;
    }).toList();

    // Sort by date (newest first)
    filtered.sort((a, b) {
      final dateA = DateTime.tryParse(a['createdAt'] ?? '') ?? DateTime.now();
      final dateB = DateTime.tryParse(b['createdAt'] ?? '') ?? DateTime.now();
      return dateB.compareTo(dateA);
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Order Management',
      roleColor: AppTheme.stockistColor,
      navItems: [
        NavItem(label: 'Dashboard', icon: Icons.dashboard_rounded, route: '/stockist'),
        NavItem(label: 'Orders', icon: Icons.shopping_cart_rounded, route: '/stockist/orders'),
        NavItem(label: 'Inventory', icon: Icons.inventory_2_rounded, route: '/stockist/inventory'),
        NavItem(label: 'Reports', icon: Icons.assessment_rounded, route: '/stockist/reports'),
      ],
      selectedIndex: 1,
      body: Column(
        children: [
          // Search and Filter Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardDark,
              border: Border(bottom: BorderSide(color: AppTheme.dividerDark)),
            ),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search by retailer name or order ID...',
                    hintStyle: const TextStyle(color: Colors.white38),
                    prefixIcon: const Icon(Icons.search, color: Colors.white38),
                    filled: true,
                    fillColor: AppTheme.surfaceDark,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) => setState(() {}),
                ),
                const SizedBox(height: 12),
                // Status Filter Chips
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: orderStatuses.length + 1,
                    itemBuilder: (context, index) {
                      final status = index == 0 ? 'ALL' : orderStatuses[index - 1];
                      final isSelected = _selectedStatus == status;
                      
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(
                            status,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.white38,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() => _selectedStatus = status);
                          },
                          backgroundColor: AppTheme.surfaceDark,
                          selectedColor: _getStatusColor(status),
                          checkmarkColor: Colors.white,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // Tab Bar
          Container(
            color: AppTheme.cardDark,
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppTheme.stockistColor,
              labelColor: AppTheme.stockistColor,
              unselectedLabelColor: Colors.white38,
              tabs: const [
                Tab(text: 'Orders', icon: Icon(Icons.shopping_cart_rounded)),
                Tab(text: 'Create Order', icon: Icons.add_circle_rounded)),
                Tab(text: 'Analytics', icon: Icon(Icons.analytics_rounded)),
              ],
            ),
          ),
          
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOrdersTab(),
                _buildCreateOrderTab(),
                _buildAnalyticsTab(),
              ],
            ),
          ),
        ],
      ),
      fab: FloatingActionButton.extended(
        onPressed: () => _showCreateOrderDialog(),
        backgroundColor: AppTheme.stockistColor,
        icon: const Icon(Icons.add_shopping_cart_rounded),
        label: const Text('New Order'),
      ),
    );
  }

  Widget _buildOrdersTab() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.stockistColor));
    }

    final filteredOrders = _filteredOrders;

    if (filteredOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_outlined, size: 64, color: AppTheme.stockistColor.withOpacity(0.3)),
            const SizedBox(height: 16),
            const Text('No orders found', style: TextStyle(color: Colors.white38, fontSize: 18)),
            const SizedBox(height: 8),
            const Text('Create your first order or adjust filters', style: TextStyle(color: Colors.white24, fontSize: 14)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredOrders.length,
      itemBuilder: (context, index) {
        final order = filteredOrders[index];
        return _buildOrderCard(order);
      },
    );
  }

  Widget _buildOrderCard(dynamic order) {
    final retailer = order['retailer'] ?? {};
    final status = order['status'] ?? 'PENDING';
    final totalAmount = order['totalAmount'] ?? 0.0;
    final createdAt = order['createdAt'] ?? '';
    final items = order['items'] ?? [];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _getStatusColor(status).withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: _getStatusColor(status).withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Retailer Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        retailer['name'] ?? 'Unknown Retailer',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Order #${order['id'] ?? 'N/A'}',
                        style: const TextStyle(color: Colors.white38, fontSize: 12),
                      ),
                      if (retailer['phone'] != null)
                        Text(
                          retailer['phone'],
                          style: const TextStyle(color: Colors.white38, fontSize: 12),
                        ),
                    ],
                  ),
                ),
                
                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Order Details
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Items Summary
                if (items.isNotEmpty) ...[
                  Row(
                    children: [
                      Icon(Icons.inventory_2_rounded, size: 16, color: Colors.white38),
                      const SizedBox(width: 8),
                      Text(
                        '${items.length} items',
                        style: const TextStyle(color: Colors.white38, fontSize: 12),
                      ),
                      const Spacer(),
                      Text(
                        'NPR ${totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // First few items
                  ...items.take(3).map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppTheme.stockistColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${item['quantity']} x ${item['product']?['name'] ?? 'Unknown Product'}',
                            style: const TextStyle(color: Colors.white60, fontSize: 12),
                          ),
                        ),
                        Text(
                          'NPR ${(item['unitPrice'] * item['quantity']).toStringAsFixed(2)}',
                          style: const TextStyle(color: Colors.white38, fontSize: 12),
                        ),
                      ],
                    ),
                  )).toList(),
                  if (items.length > 3)
                    Text(
                      '+${items.length - 3} more items',
                      style: const TextStyle(color: Colors.white24, fontSize: 11),
                    ),
                ],
                
                const SizedBox(height: 12),
                
                // Date and Actions
                Row(
                  children: [
                    Icon(Icons.schedule_rounded, size: 16, color: Colors.white38),
                    const SizedBox(width: 8),
                    Text(
                      createdAt.isNotEmpty 
                          ? DateFormat('MMM dd, yyyy HH:mm').format(DateTime.parse(createdAt))
                          : 'Unknown date',
                      style: const TextStyle(color: Colors.white38, fontSize: 12),
                    ),
                    const Spacer(),
                    // Action Buttons
                    if (status == 'PENDING') ...[
                      _buildActionButton('Approve', Icons.check_circle, AppTheme.success, () => _updateOrderStatus(order['id'], 'APPROVED')),
                      const SizedBox(width: 8),
                      _buildActionButton('Cancel', Icons.cancel, AppTheme.error, () => _updateOrderStatus(order['id'], 'CANCELLED')),
                    ] else if (status == 'APPROVED') ...[
                      _buildActionButton('Dispatch', Icons.local_shipping, AppTheme.warning, () => _updateOrderStatus(order['id'], 'DISPATCHED')),
                    ] else if (status == 'DISPATCHED') ...[
                      _buildActionButton('Delivered', Icons.check_circle, AppTheme.success, () => _updateOrderStatus(order['id'], 'DELIVERED')),
                    ] else if (status == 'DELIVERED') ...[
                      _buildActionButton('Mark Paid', Icons.payment, AppTheme.success, () => _updateOrderStatus(order['id'], 'PAID')),
                    ],
                    const SizedBox(width: 8),
                    _buildActionButton('View', Icons.visibility, AppTheme.primary, () => _showOrderDetails(order)),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 11)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        minimumSize: const Size(0, 32),
        padding: const EdgeInsets.symmetric(horizontal: 12),
      ),
    );
  }

  Widget _buildCreateOrderTab() {
    return Column(
      children: [
        // Create Order Form
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create New Order',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Retailer Selection
                Text(
                  'Select Retailer',
                  style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(
                  dropdownColor: AppTheme.surfaceDark,
                  decoration: AppTheme.inputDecoration('Choose a retailer'),
                  items: _retailers.map((retailer) => DropdownMenuItem<int>(
                    value: retailer['id'],
                    child: Text(retailer['name'] ?? 'Unknown Retailer'),
                  )).toList(),
                  onChanged: (value) {
                    // Handle retailer selection
                  },
                ),
                
                const SizedBox(height: 24),
                
                // Product Selection
                Text(
                  'Add Products',
                  style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: _products.length,
                    itemBuilder: (context, index) {
                      final product = _products[index];
                      return _buildProductTile(product);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Submit Button
        Container(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () => _showCreateOrderDialog(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.stockistColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'CREATE ORDER',
                style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductTile(dynamic product) {
    int quantity = 0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.dividerDark),
      ),
      child: Row(
        children: [
          // Product Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['name'] ?? 'Unknown Product',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  'Stock: ${product['stock'] ?? 0} units',
                  style: const TextStyle(color: Colors.white38, fontSize: 12),
                ),
                Text(
                  'Price: NPR ${product['price']?.toStringAsFixed(2) ?? '0.00'}',
                  style: const TextStyle(color: AppTheme.stockistColor, fontSize: 12),
                ),
              ],
            ),
          ),
          
          // Quantity Controls
          Row(
            children: [
              IconButton(
                onPressed: () {
                  if (quantity > 0) {
                    quantity--;
                    // Update quantity
                  }
                },
                icon: const Icon(Icons.remove_circle_outline, color: Colors.white38),
              ),
              Container(
                width: 40,
                alignment: Alignment.center,
                child: Text(
                  quantity.toString(),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                onPressed: () {
                  final maxStock = product['stock'] ?? 0;
                  if (quantity < maxStock) {
                    quantity++;
                    // Update quantity
                  }
                },
                icon: const Icon(Icons.add_circle_outline, color: AppTheme.stockistColor),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Analytics',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          // Stats Cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Orders',
                  '${_orders.length}',
                  Icons.shopping_cart_rounded,
                  AppTheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Pending',
                  '${_orders.where((o) => o['status'] == 'PENDING').length}',
                  Icons.pending_rounded,
                  AppTheme.warning,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Completed',
                  '${_orders.where((o) => o['status'] == 'PAID').length}',
                  Icons.check_circle_rounded,
                  AppTheme.success,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Revenue Chart Placeholder
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: AppTheme.surfaceDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.dividerDark),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.insert_chart_rounded, size: 48, color: Colors.white38),
                  SizedBox(height: 8),
                  Text('Revenue Chart', style: TextStyle(color: Colors.white38)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(color: Colors.white38, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return Colors.orange;
      case 'APPROVED':
        return Colors.blue;
      case 'DISPATCHED':
        return Colors.purple;
      case 'DELIVERED':
        return Colors.green;
      case 'PAID':
        return Colors.teal;
      case 'CANCELLED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _updateOrderStatus(int orderId, String newStatus) async {
    try {
      final auth = context.read<AuthProvider>();
      final dio = Dio();
      
      await dio.put(
        '${ApiConfig.baseUrl}/stockist/orders/$orderId/status',
        data: {'status': newStatus},
        options: Options(headers: {'Authorization': 'Bearer ${auth.token}'}),
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order status updated to $newStatus'),
            backgroundColor: AppTheme.success,
          ),
        );
        _loadData(); // Refresh data
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating order: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  void _showOrderDetails(dynamic order) {
    // Show detailed order view
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: AppTheme.bgDark,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Order Details',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order details content
                    Text('Order #${order['id']}'),
                    // Add more details as needed
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateOrderDialog() {
    // Show create order dialog
    _tabController.animateTo(1); // Switch to create order tab
  }
}
