import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:vedanta_trade/core/api_config.dart';
import 'package:vedanta_trade/features/orders/domain/models/order.dart';
import 'package:vedanta_trade/features/cart/domain/models/cart_item.dart';

class OrderProvider extends ChangeNotifier {
  List<Order> _orders = [];
  bool _isLoading = false;
  String? _authToken;

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;

  void setAuthToken(String token) {
    _authToken = token;
  }

  Future<void> fetchOrders() async {
    if (_authToken == null) return;
    
    _isLoading = true;
    notifyListeners();
    
    try {
      final dio = Dio();
      final res = await dio.get(
        '${ApiConfig.baseUrl}/orders',
        options: Options(headers: {'Authorization': 'Bearer $_authToken'}),
      );
      
      final List<dynamic> data = res.data['data'] ?? [];
      _orders = data.map((json) => Order.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching orders: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> createOrder({
    required List<CartItem> cartItems,
    required double totalAmount,
    required double deliveryFee,
    required double finalAmount,
    required String deliveryAddress,
    required String retailerId,
    String paymentMethod = 'Cash on Delivery',
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final dio = Dio();
      final headers = {'Authorization': 'Bearer $_authToken'};
      
      // Check stock availability first
      final stockCheck = await _checkStockAvailability(cartItems);
      if (!stockCheck['available']) {
        return {
          'success': false,
          'message': 'Insufficient stock: ${stockCheck['message']}',
        };
      }
      
      final orderItems = cartItems.map((item) => {
        'productId': item.productId,
        'productName': item.productName,
        'quantity': item.quantity,
        'price': item.price,
      }).toList();
      
      final payload = {
        'retailerId': retailerId,
        'items': orderItems,
        'totalAmount': totalAmount,
        'deliveryFee': deliveryFee,
        'finalAmount': finalAmount,
        'deliveryAddress': deliveryAddress,
        'paymentMethod': paymentMethod,
        'status': 'PENDING',
      };
      
      final res = await dio.post(
        '${ApiConfig.baseUrl}/stockist/orders',
        data: payload,
        options: Options(headers: headers),
      );
      
      await fetchOrders();
      
      return {
        'success': true,
        'orderId': res.data['data']?['id'],
        'message': 'Order created successfully',
      };
    } catch (e) {
      debugPrint('Error creating order: $e');
      return {
        'success': false,
        'message': 'Failed to create order: $e',
      };
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<Map<String, dynamic>> _checkStockAvailability(List<CartItem> items) async {
    try {
      final dio = Dio();
      final headers = {'Authorization': 'Bearer $_authToken'};
      
      final productIds = items.map((i) => i.productId).toList();
      final res = await dio.post(
        '${ApiConfig.baseUrl}/stockist/check-stock',
        data: {'productIds': productIds},
        options: Options(headers: headers),
      );
      
      final stockData = res.data['data'] ?? {};
      
      for (final item in items) {
        final availableStock = stockData[item.productId]?['quantity'] ?? 0;
        if (item.quantity > availableStock) {
          return {
            'available': false,
            'message': '${item.productName} - Requested: ${item.quantity}, Available: $availableStock',
          };
        }
      }
      
      return {'available': true};
    } catch (e) {
      return {
        'available': false,
        'message': 'Stock check failed: $e',
      };
    }
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      final dio = Dio();
      final headers = {'Authorization': 'Bearer $_authToken'};
      
      await dio.patch(
        '${ApiConfig.baseUrl}/stockist/orders/$orderId',
        data: {'status': newStatus},
        options: Options(headers: headers),
      );
      
      await fetchOrders();
    } catch (e) {
      debugPrint('Error updating order status: $e');
    }
  }

  Order? getOrderById(String orderId) {
    try {
      return _orders.firstWhere((order) => order.id == orderId);
    } catch (e) {
      return null;
    }
  }

  List<Order> getOrdersByStatus(String status) {
    return _orders.where((order) => order.status == status).toList();
  }

  int getOrderCount() {
    return _orders.length;
  }

  double getTotalSpent() {
    return _orders.fold(0.0, (sum, order) => sum + order.finalAmount);
  }

  void clearOrders() {
    _orders.clear();
    _saveOrders();
    notifyListeners();
  }

  // Get status color for UI
  Color getStatusColor(String status) {
    switch (status) {
      case 'Processing':
        return const Color(0xFF2196F3); // Blue
      case 'Shipped':
        return const Color(0xFFFF9800); // Orange
      case 'Out for Delivery':
        return const Color(0xFF9C27B0); // Purple
      case 'Delivered':
        return const Color(0xFF4CAF50); // Green
      case 'Cancelled':
        return const Color(0xFFF44336); // Red
      default:
        return Colors.grey;
    }
  }

  // Get status icon for UI
  String getStatusIcon(String status) {
    switch (status) {
      case 'Processing':
        return '⏳';
      case 'Shipped':
        return '📦';
      case 'Out for Delivery':
        return '🚚';
      case 'Delivered':
        return '✅';
      case 'Cancelled':
        return '❌';
      default:
        return '📋';
    }
  }
}
