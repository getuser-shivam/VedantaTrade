import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:vedanta_trade/core/api_config.dart';
import 'package:vedanta_trade/features/auth/presentation/providers/auth_provider.dart';

/// Order Provider for managing real-time order flow lifecycle
class OrderProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _orders = [];
  List<Map<String, dynamic>> _retailers = [];
  List<Map<String, dynamic>> _products = [];
  bool _loading = false;
  String? _error;
  Timer? _realtimeTimer;
  final Dio _dio = Dio();
  
  // Getters
  List<Map<String, dynamic>> get orders => _orders;
  List<Map<String, dynamic>> get retailers => _retailers;
  List<Map<String, dynamic>> get products => _products;
  bool get loading => _loading;
  String? get error => _error;
  
  // Order statistics
  int get pendingOrders => _orders.where((o) => o['status'] == 'pending').length;
  int get approvedOrders => _orders.where((o) => o['status'] == 'approved').length;
  int get dispatchedOrders => _orders.where((o) => o['status'] == 'dispatched').length;
  int get deliveredOrders => _orders.where((o) => o['status'] == 'delivered').length;
  
  double get totalOrderValue => _orders.fold(0.0, (sum, order) => sum + (order['finalAmount'] as double));
  double get pendingOrderValue => _orders
      .where((o) => o['status'] == 'pending')
      .fold(0.0, (sum, order) => sum + (order['finalAmount'] as double));
  
  OrderProvider() {
    _startRealtimeUpdates();
  }
  
  @override
  void dispose() {
    _realtimeTimer?.cancel();
    super.dispose();
  }
  
  /// Start real-time updates every 30 seconds
  void _startRealtimeUpdates() {
    _realtimeTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      loadOrders();
    });
  }
  
  /// Load all orders
  Future<void> loadOrders() async {
    try {
      _loading = true;
      _error = null;
      notifyListeners();
      
      final auth = AuthProvider.instance;
      if (auth.token == null) {
        _error = 'Authentication required';
        _loading = false;
        notifyListeners();
        return;
      }
      
      final response = await _dio.get(
        '${ApiConfig.baseUrl}/stockists/orders',
        options: Options(headers: {'Authorization': 'Bearer ${auth.token}'}),
      );
      
      if (response.statusCode == 200) {
        _orders = (response.data['data'] as List<dynamic>?)
                ?.map((order) => Map<String, dynamic>.from(order))
                .toList() ??
            [];
        _error = null;
      } else {
        _error = 'Failed to load orders: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Error loading orders: $e';
      debugPrint('OrderProvider Error: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
  
  /// Load retailers
  Future<void> loadRetailers() async {
    try {
      final auth = AuthProvider.instance;
      if (auth.token == null) {
        _error = 'Authentication required';
        notifyListeners();
        return;
      }
      
      final response = await _dio.get(
        '${ApiConfig.baseUrl}/stockists/retailers',
        options: Options(headers: {'Authorization': 'Bearer ${auth.token}'}),
      );
      
      if (response.statusCode == 200) {
        _retailers = (response.data['data'] as List<dynamic>?)
                ?.map((retailer) => Map<String, dynamic>.from(retailer))
                .toList() ??
            [];
        _error = null;
      } else {
        _error = 'Failed to load retailers: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Error loading retailers: $e';
      debugPrint('OrderProvider Error: $e');
    } finally {
      notifyListeners();
    }
  }
  
  /// Load products
  Future<void> loadProducts() async {
    try {
      final auth = AuthProvider.instance;
      if (auth.token == null) {
        _error = 'Authentication required';
        notifyListeners();
        return;
      }
      
      final response = await _dio.get(
        '${ApiConfig.baseUrl}/stockists/products',
        options: Options(headers: {'Authorization': 'Bearer ${auth.token}'}),
      );
      
      if (response.statusCode == 200) {
        _products = (response.data['data'] as List<dynamic>?)
                ?.map((product) => Map<String, dynamic>.from(product))
                .toList() ??
            [];
        _error = null;
      } else {
        _error = 'Failed to load products: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Error loading products: $e';
      debugPrint('OrderProvider Error: $e');
    } finally {
      notifyListeners();
    }
  }
  
  /// Create new order
  Future<bool> createOrder({
    required String retailerId,
    required List<Map<String, dynamic>> items,
    required String notes,
  }) async {
    try {
      _loading = true;
      _error = null;
      notifyListeners();
      
      final auth = AuthProvider.instance;
      if (auth.token == null) {
        _error = 'Authentication required';
        _loading = false;
        notifyListeners();
        return false;
      }
      
      // Calculate order totals
      final subtotal = items.fold(0.0, (sum, item) => sum + (item['unitPrice'] * item['quantity']));
      final vatAmount = subtotal * 0.13; // 13% VAT
      final totalAmount = subtotal + vatAmount;
      
      final orderData = {
        'retailerId': retailerId,
        'items': items,
        'subtotal': subtotal,
        'vatAmount': vatAmount,
        'totalAmount': totalAmount,
        'finalAmount': totalAmount,
        'notes': notes,
        'status': 'pending',
        'paymentStatus': 'pending',
        'deliveryStatus': 'pending',
      };
      
      final response = await _dio.post(
        '${ApiConfig.baseUrl}/stockists/orders',
        data: orderData,
        options: Options(headers: {'Authorization': 'Bearer ${auth.token}'}),
      );
      
      if (response.statusCode == 201) {
        await loadOrders();
        return true;
      } else {
        _error = 'Failed to create order: ${response.statusCode}';
        return false;
      }
    } catch (e) {
      _error = 'Error creating order: $e';
      debugPrint('OrderProvider Error: $e');
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
  
  /// Update order status
  Future<bool> updateOrderStatus(String orderId, String newStatus) async {
    try {
      _loading = true;
      _error = null;
      notifyListeners();
      
      final auth = AuthProvider.instance;
      if (auth.token == null) {
        _error = 'Authentication required';
        _loading = false;
        notifyListeners();
        return false;
      }
      
      final response = await _dio.patch(
        '${ApiConfig.baseUrl}/stockists/orders/$orderId',
        data: {
          'status': newStatus,
          // Update delivery status based on order status
          if (newStatus == 'dispatched') 'deliveryStatus': 'dispatched',
          if (newStatus == 'delivered') 'deliveryStatus': 'delivered',
        },
        options: Options(headers: {'Authorization': 'Bearer ${auth.token}'}),
      );
      
      if (response.statusCode == 200) {
        await loadOrders();
        return true;
      } else {
        _error = 'Failed to update order status: ${response.statusCode}';
        return false;
      }
    } catch (e) {
      _error = 'Error updating order status: $e';
      debugPrint('OrderProvider Error: $e');
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
  
  /// Update payment status
  Future<bool> updatePaymentStatus(String orderId, String paymentStatus) async {
    try {
      _loading = true;
      _error = null;
      notifyListeners();
      
      final auth = AuthProvider.instance;
      if (auth.token == null) {
        _error = 'Authentication required';
        _loading = false;
        notifyListeners();
        return false;
      }
      
      final response = await _dio.patch(
        '${ApiConfig.baseUrl}/stockists/orders/$orderId/payment',
        data: {'paymentStatus': paymentStatus},
        options: Options(headers: {'Authorization': 'Bearer ${auth.token}'}),
      );
      
      if (response.statusCode == 200) {
        await loadOrders();
        return true;
      } else {
        _error = 'Failed to update payment status: ${response.statusCode}';
        return false;
      }
    } catch (e) {
      _error = 'Error updating payment status: $e';
      debugPrint('OrderProvider Error: $e');
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
  
  /// Cancel order
  Future<bool> cancelOrder(String orderId, String reason) async {
    try {
      _loading = true;
      _error = null;
      notifyListeners();
      
      final auth = AuthProvider.instance;
      if (auth.token == null) {
        _error = 'Authentication required';
        _loading = false;
        notifyListeners();
        return false;
      }
      
      final response = await _dio.patch(
        '${ApiConfig.baseUrl}/stockists/orders/$orderId',
        data: {
          'status': 'cancelled',
          'cancellationReason': reason,
        },
        options: Options(headers: {'Authorization': 'Bearer ${auth.token}'}),
      );
      
      if (response.statusCode == 200) {
        await loadOrders();
        return true;
      } else {
        _error = 'Failed to cancel order: ${response.statusCode}';
        return false;
      }
    } catch (e) {
      _error = 'Error cancelling order: $e';
      debugPrint('OrderProvider Error: $e');
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
  
  /// Get order by ID
  Map<String, dynamic>? getOrderById(String orderId) {
    try {
      return _orders.firstWhere((order) => order['id'] == orderId);
    } catch (e) {
      return null;
    }
  }
  
  /// Get orders by status
  List<Map<String, dynamic>> getOrdersByStatus(String status) {
    return _orders.where((order) => order['status'] == status).toList();
  }
  
  /// Get orders by retailer
  List<Map<String, dynamic>> getOrdersByRetailer(String retailerId) {
    return _orders.where((order) => order['retailerId'] == retailerId).toList();
  }
  
  /// Search orders
  List<Map<String, dynamic>> searchOrders(String query) {
    if (query.isEmpty) return _orders;
    
    final searchLower = query.toLowerCase();
    return _orders.where((order) {
      return order['retailerName'].toString().toLowerCase().contains(searchLower) ||
             order['id'].toString().toLowerCase().contains(searchLower) ||
             order['status'].toString().toLowerCase().contains(searchLower);
    }).toList();
  }
  
  /// Refresh all data
  Future<void> refresh() async {
    await Future.wait([
      loadOrders(),
      loadRetailers(),
      loadProducts(),
    ]);
  }
  
  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

/// Order Status Enum
enum OrderStatus {
  pending,
  approved,
  dispatched,
  delivered,
  cancelled,
}

/// Payment Status Enum
enum PaymentStatus {
  pending,
  paid,
  overdue,
  refunded,
}

/// Order Status Helper
class OrderStatusHelper {
  static String getStatusDisplayName(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'approved':
        return 'Approved';
      case 'dispatched':
        return 'Dispatched';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }
  
  static Color getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'dispatched':
        return Colors.blue;
      case 'delivered':
        return Colors.purple;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
  
  static IconData getStatusIcon(String status) {
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
  
  static List<String> getNextStatuses(String currentStatus) {
    switch (currentStatus) {
      case 'pending':
        return ['approved', 'cancelled'];
      case 'approved':
        return ['dispatched'];
      case 'dispatched':
        return ['delivered'];
      case 'delivered':
        return [];
      case 'cancelled':
        return [];
      default:
        return [];
    }
  }
}

/// Payment Status Helper
class PaymentStatusHelper {
  static String getPaymentDisplayName(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'paid':
        return 'Paid';
      case 'overdue':
        return 'Overdue';
      case 'refunded':
        return 'Refunded';
      default:
        return status;
    }
  }
  
  static Color getPaymentColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'paid':
        return Colors.green;
      case 'overdue':
        return Colors.red;
      case 'refunded':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
  
  static IconData getPaymentIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.payment;
      case 'paid':
        return Icons.paid;
      case 'overdue':
        return Icons.warning;
      case 'refunded':
        return Icons.refresh;
      default:
        return Icons.help;
    }
  }
}

/// Order Validation Helper
class OrderValidator {
  static String? validateOrderItems(List<Map<String, dynamic>> items) {
    if (items.isEmpty) {
      return 'At least one item is required';
    }
    
    for (final item in items) {
      if (item['quantity'] <= 0) {
        return 'Quantity must be greater than 0';
      }
      
      if (item['unitPrice'] <= 0) {
        return 'Unit price must be greater than 0';
      }
    }
    
    return null;
  }
  
  static String? validateOrderData({
    required String? retailerId,
    required List<Map<String, dynamic>> items,
  }) {
    if (retailerId == null || retailerId.isEmpty) {
      return 'Retailer is required';
    }
    
    return validateOrderItems(items);
  }
  
  static Map<String, dynamic> calculateOrderTotals(List<Map<String, dynamic>> items) {
    final subtotal = items.fold(0.0, (sum, item) => sum + (item['unitPrice'] * item['quantity']));
    final vatAmount = subtotal * 0.13; // 13% VAT
    final totalAmount = subtotal + vatAmount;
    
    return {
      'subtotal': subtotal,
      'vatAmount': vatAmount,
      'totalAmount': totalAmount,
      'finalAmount': totalAmount,
    };
  }
}
