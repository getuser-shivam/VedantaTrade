import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/theme/modern_design_system.dart';
import '../../../shared/widgets/micro_interactions.dart';
import '../../domain/services/order_service.dart';
import '../../domain/entities/order.dart';

/// Order Management Screen
/// Real-time order management with WebSocket integration
class OrderManagementScreen extends StatefulWidget {
  const OrderManagementScreen({Key? key}) : super(key: key);

  @override
  _OrderManagementScreenState createState() => _OrderManagementScreenState();
}

class _OrderManagementScreenState extends State<OrderManagementScreen> 
    with TickerProviderStateMixin {
  late OrderService _orderService;
  late TabController _tabController;
  List<Order> _orders = [];
  List<Order> _pendingOrders = [];
  List<Order> _activeOrders = [];
  List<Order> _completedOrders = [];
  bool _isLoading = false;
  String _searchQuery = '';
  OrderStatus? _selectedStatus;
  String _selectedFilter = 'all';
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initializeOrderService();
    _loadOrders();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _refreshTimer?.cancel();
    _orderService.dispose();
    super.dispose();
  }

  Future<void> _initializeOrderService() async {
    _orderService = OrderService(
      OrderRepositoryImpl(DatabaseHelper()),
      webSocketUrl: 'ws://localhost:8080/orders',
    );
    
    await _orderService.initialize();
    
    // Listen to order updates
    _orderService.orderStream.listen((order) {
      if (mounted) {
        setState(() {
          _updateOrderInList(order);
        });
      }
    });
    
    // Listen to status updates
    _orderService.statusUpdateStream.listen((update) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order status updated: ${update.data['order']['orderNumber']}'),
            backgroundColor: ModernDesignSystem.infoColor,
          ),
        );
      }
    });
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    
    try {
      // Load orders based on current filter
      if (_selectedFilter == 'pending') {
        final result = await _orderService.getOrdersByStatus(status: OrderStatus.pending);
        result.fold(
          (error) => _showError(error.message),
          (orders) => setState(() {
            _pendingOrders = orders;
            _orders = orders;
          }),
        );
      } else if (_selectedFilter == 'active') {
        final result = await _orderService.getOrdersByStatus(status: OrderStatus.approved);
        result.fold(
          (error) => _showError(error.message),
          (orders) => setState(() {
            _activeOrders = orders;
            _orders = orders;
          }),
        );
      } else if (_selectedFilter == 'completed') {
        final result = await _orderService.getOrdersByStatus(status: OrderStatus.paid);
        result.fold(
          (error) => _showError(error.message),
          (orders) => setState(() {
            _completedOrders = orders;
            _orders = orders;
          }),
        );
      } else {
        // Load all orders
        final pendingResult = await _orderService.getOrdersByStatus(status: OrderStatus.pending);
        final activeResult = await _orderService.getOrdersByStatus(status: OrderStatus.approved);
        final completedResult = await _orderService.getOrdersByStatus(status: OrderStatus.paid);
        
        final allOrders = <Order>[];
        pendingResult.fold((error) => _showError(error.message), (orders) => allOrders.addAll(orders));
        activeResult.fold((error) => _showError(error.message), (orders) => allOrders.addAll(orders));
        completedResult.fold((error) => _showError(error.message), (orders) => allOrders.addAll(orders));
        
        setState(() {
          _pendingOrders = pendingResult.fold((l) => l, (r) => r);
          _activeOrders = activeResult.fold((l) => l, (r) => r);
          _completedOrders = completedResult.fold((l) => l, (r) => r);
          _orders = allOrders;
        });
      }
    } catch (e) {
      _showError('Failed to load orders: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        _loadOrders();
      }
    });
  }

  void _updateOrderInList(Order updatedOrder) {
    // Update in appropriate list based on status
    switch (updatedOrder.status) {
      case OrderStatus.pending:
        _updateOrderInListHelper(updatedOrder, _pendingOrders);
        break;
      case OrderStatus.approved:
      case OrderStatus.dispatched:
      case OrderStatus.delivered:
        _updateOrderInListHelper(updatedOrder, _activeOrders);
        break;
      case OrderStatus.paid:
        _updateOrderInListHelper(updatedOrder, _completedOrders);
        break;
      default:
        break;
    }
    
    // Update main list
    final index = _orders.indexWhere((order) => order.id == updatedOrder.id);
    if (index != -1) {
      _orders[index] = updatedOrder;
    }
  }

  void _updateOrderInListHelper(Order updatedOrder, List<Order> orderList) {
    final index = orderList.indexWhere((order) => order.id == updatedOrder.id);
    if (index != -1) {
      orderList[index] = updatedOrder;
    } else {
      orderList.insert(0, updatedOrder);
    }
  }

  List<Order> get _filteredOrders {
    var filtered = _orders;
    
    // Apply status filter
    if (_selectedStatus != null) {
      filtered = filtered.where((order) => order.status == _selectedStatus).toList();
    }
    
    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((order) {
        return order.orderNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               order.retailerId.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               order.stockistId.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }
    
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ModernDesignSystem.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Order Management',
          style: ModernDesignSystem.headlineSmall.copyWith(
            color: Colors.white,
          ),
        ),
        backgroundColor: ModernDesignSystem.primaryColor,
        elevation: 0,
        actions: [
          AnimatedButton(
            text: 'Refresh',
            onPressed: _loadOrders,
            showScale: true,
            backgroundColor: ModernDesignSystem.secondaryColor,
            textColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          const SizedBox(width: 8),
          AnimatedButton(
            text: 'Create Order',
            onPressed: _navigateToCreateOrder,
            showScale: true,
            backgroundColor: ModernDesignSystem.successColor,
            textColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilterBar(),
          const SizedBox(height: 16),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOrdersTab(_pendingOrders, 'Pending'),
                _buildOrdersTab(_activeOrders, 'Active'),
                _buildOrdersTab(_completedOrders, 'Completed'),
                _buildOrdersTab(_filteredOrders, 'All'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilterBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ModernDesignSystem.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: ModernDesignSystem.cardShadow,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Search Orders',
                    hintText: 'Enter order number, retailer, or stockist',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: ModernDesignSystem.borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: ModernDesignSystem.primaryColor, width: 2),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                  },
                ),
              ),
              const SizedBox(width: 16),
              DropdownButton<String>(
                value: _selectedFilter,
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('All Orders')),
                  DropdownMenuItem(value: 'pending', child: Text('Pending')),
                  DropdownMenuItem(value: 'active', child: Text('Active')),
                  DropdownMenuItem(value: 'completed', child: Text('Completed')),
                ],
                onChanged: (value) {
                  setState(() => _selectedFilter = value!);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 8,
                  children: OrderStatus.values.map((status) {
                    final isSelected = _selectedStatus == status;
                    return FilterChip(
                      label: Text(status.displayName),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedStatus = selected ? status : null;
                        });
                      },
                      backgroundColor: isSelected 
                          ? ModernDesignSystem.primaryColor 
                          : ModernDesignSystem.cardColor,
                      labelStyle: TextStyle(
                        color: isSelected 
                            ? Colors.white 
                            : ModernDesignSystem.textPrimaryColor,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersTab(List<Order> orders, String title) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ModernDesignSystem.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: ModernDesignSystem.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getTabIcon(title),
                color: ModernDesignSystem.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                '$title Orders',
                style: ModernDesignSystem.headlineSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '${orders.length}',
                style: ModernDesignSystem.bodyMedium.copyWith(
                  color: ModernDesignSystem.textSecondaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: ModernDesignSystem.primaryColor,
                    ),
                  )
                : orders.isEmpty
                    ? const Center(
                        child: Text(
                          'No orders found',
                          style: TextStyle(
                            color: ModernDesignSystem.textSecondaryColor,
                            fontSize: 16,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: orders.length,
                        itemBuilder: (context, index) {
                          final order = orders[index];
                          return _buildOrderCard(order);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ModernDesignSystem.backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getStatusColor(order.status).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getStatusIcon(order.status),
                color: _getStatusColor(order.status),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.getFormattedOrderNumber(),
                      style: ModernDesignSystem.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order.getStatusDisplayName(),
                      style: ModernDesignSystem.bodySmall.copyWith(
                        color: _getStatusColor(order.status),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(order.status),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${order.getCompletionPercentage().toStringAsFixed(0)}%',
                  style: ModernDesignSystem.bodySmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildOrderInfoItem('Retailer', order.retailerId),
              const SizedBox(width: 16),
              _buildOrderInfoItem('Stockist', order.stockistId),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildOrderInfoItem('Created', _formatDate(order.createdAt)),
              const SizedBox(width: 16),
              _buildOrderInfoItem('Amount', order.getFormattedFinalAmount()),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildOrderInfoItem('Items', '${order.items.length}'),
              const SizedBox(width: 16),
              _buildOrderInfoItem('Payment', order.paymentMethod),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: AnimatedButton(
                  text: 'View Details',
                  onPressed: () => _navigateToOrderDetails(order),
                  showScale: true,
                  backgroundColor: ModernDesignSystem.infoColor,
                  textColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
              const SizedBox(width: 8),
              if (order.canBeApproved())
                Expanded(
                  child: AnimatedButton(
                    text: 'Approve',
                    onPressed: () => _approveOrder(order),
                    showScale: true,
                    backgroundColor: ModernDesignSystem.successColor,
                    textColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
              if (order.canBeDispatched())
                Expanded(
                  child: AnimatedButton(
                    text: 'Dispatch',
                    onPressed: () => _dispatchOrder(order),
                    showScale: true,
                    backgroundColor: ModernDesignSystem.accentColor,
                    textColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
              if (order.canBeDelivered())
                Expanded(
                  child: AnimatedButton(
                    text: 'Mark Delivered',
                    onPressed: () => _markAsDelivered(order),
                    showScale: true,
                    backgroundColor: ModernDesignSystem.secondaryColor,
                    textColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
              if (order.canBePaid())
                Expanded(
                  child: AnimatedButton(
                    text: 'Mark Paid',
                    onPressed: () => _markAsPaid(order),
                    showScale: true,
                    backgroundColor: ModernDesignSystem.successColor,
                    textColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
              if (order.canBeCancelled())
                Expanded(
                  child: AnimatedButton(
                    text: 'Cancel',
                    onPressed: () => _cancelOrder(order),
                    showScale: true,
                    backgroundColor: ModernDesignSystem.errorColor,
                    textColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderInfoItem(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: ModernDesignSystem.bodySmall.copyWith(
              color: ModernDesignSystem.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: ModernDesignSystem.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getTabIcon(String title) {
    switch (title) {
      case 'Pending':
        return Icons.pending;
      case 'Active':
        return Icons.play_circle;
      case 'Completed':
        return Icons.check_circle;
      case 'All':
        return Icons.list;
      default:
        return Icons.list;
    }
  }

  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Icons.pending;
      case OrderStatus.approved:
        return Icons.check_circle;
      case OrderStatus.dispatched:
        return Icons.local_shipping;
      case OrderStatus.delivered:
        return Icons.check_circle;
      case OrderStatus.paid:
        return Icons.payments;
      case OrderStatus.cancelled:
        return Icons.cancel;
      case OrderStatus.returned:
        return Icons.replay;
      default:
        return Icons.help;
    }
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return ModernDesignSystem.warningColor;
      case OrderStatus.approved:
        return ModernDesignSystem.infoColor;
      case OrderStatus.dispatched:
        return ModernDesignSystem.accentColor;
      case OrderStatus.delivered:
        return ModernDesignSystem.successColor;
      case OrderStatus.paid:
        return ModernDesignSystem.successColor;
      case OrderStatus.cancelled:
        return ModernDesignSystem.errorColor;
      case OrderStatus.returned:
        return ModernDesignSystem.warningColor;
      default:
        return ModernDesignSystem.textSecondaryColor;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _navigateToCreateOrder() {
    Navigator.of(context).pushNamed('/create-order');
  }

  void _navigateToOrderDetails(Order order) {
    Navigator.of(context).pushNamed('/order-details', arguments: order);
  }

  Future<void> _approveOrder(Order order) async {
    try {
      final result = await _orderService.approveOrder(order.id);
      result.fold(
        (error) => _showError(error.message),
        (_) => _showSuccess('Order approved successfully'),
      );
    } catch (e) {
      _showError('Failed to approve order: $e');
    }
  }

  Future<void> _dispatchOrder(Order order) async {
    try {
      final result = await _orderService.dispatchOrder(order.id);
      result.fold(
        (error) => _showError(error.message),
        (_) => _showSuccess('Order dispatched successfully'),
      );
    } catch (e) {
      _showError('Failed to dispatch order: $e');
    }
  }

  Future<void> _markAsDelivered(Order order) async {
    try {
      final result = await _orderService.markOrderAsDelivered(order.id);
      result.fold(
        (error) => _showError(error.message),
        (_) => _showSuccess('Order marked as delivered'),
      );
    } catch (e) {
      _showError('Failed to mark order as delivered: $e');
    }
  }

  Future<void> _markAsPaid(Order order) async {
    try {
      final result = await _orderService.markOrderAsPaid(order.id, paymentMethod: 'cash');
      result.fold(
        (error) => _showError(error.message),
        (_) => _showSuccess('Order marked as paid'),
      );
    } catch (e) {
      _showError('Failed to mark order as paid: $e');
    }
  }

  Future<void> _cancelOrder(Order order) async {
    try {
      final result = await _orderService.cancelOrder(order.id);
      result.fold(
        (error) => _showError(error.message),
        (_) => _showSuccess('Order cancelled successfully'),
      );
    } catch (e) {
      _showError('Failed to cancel order: $e');
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: ModernDesignSystem.successColor,
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: ModernDesignSystem.errorColor,
      ),
    );
  }
}
