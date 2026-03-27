import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:vedanta_trade/features/orders/domain/models/order.dart';
import 'package:vedanta_trade/features/cart/domain/models/cart_item.dart';

class OrderProvider extends ChangeNotifier {
  List<Order> _orders = [];
  bool _isLoading = false;

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;

  OrderProvider() {
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ordersData = prefs.getString('orders');
      
      if (ordersData != null) {
        final List<dynamic> decoded = json.decode(ordersData);
        _orders = decoded.map((order) => Order.fromJson(order)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading orders: $e');
    }
  }

  Future<void> _saveOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ordersData = json.encode(_orders.map((order) => order.toJson()).toList());
      await prefs.setString('orders', ordersData);
    } catch (e) {
      debugPrint('Error saving orders: $e');
    }
  }

  Future<String> createOrder({
    required List<CartItem> cartItems,
    required double totalAmount,
    required double deliveryFee,
    required double finalAmount,
    required String deliveryAddress,
    String paymentMethod = 'Cash on Delivery',
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      final orderItems = cartItems.map((cartItem) => OrderItem(
        productId: cartItem.productId,
        productName: cartItem.productName,
        productForm: cartItem.productForm,
        price: cartItem.price,
        quantity: cartItem.quantity,
        imageUrl: cartItem.imageUrl,
      )).toList();

      final order = Order(
        id: 'ORD${DateTime.now().millisecondsSinceEpoch}',
        items: orderItems,
        totalAmount: totalAmount,
        deliveryFee: deliveryFee,
        finalAmount: finalAmount,
        status: 'Processing',
        orderDate: DateTime.now(),
        deliveryAddress: deliveryAddress,
        paymentMethod: paymentMethod,
        trackingNumber: 'TRK${DateTime.now().millisecondsSinceEpoch}',
      );

      _orders.insert(0, order);
      await _saveOrders();
      
      _isLoading = false;
      notifyListeners();
      
      return order.id;
    } catch (e) {
      debugPrint('Error creating order: $e');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      final orderIndex = _orders.indexWhere((order) => order.id == orderId);
      if (orderIndex != -1) {
        // Update status
        final updatedOrder = Order(
          id: _orders[orderIndex].id,
          items: _orders[orderIndex].items,
          totalAmount: _orders[orderIndex].totalAmount,
          deliveryFee: _orders[orderIndex].deliveryFee,
          finalAmount: _orders[orderIndex].finalAmount,
          status: newStatus,
          orderDate: _orders[orderIndex].orderDate,
          deliveryDate: newStatus == 'Delivered' ? DateTime.now() : null,
          deliveryAddress: _orders[orderIndex].deliveryAddress,
          paymentMethod: _orders[orderIndex].paymentMethod,
          trackingNumber: _orders[orderIndex].trackingNumber,
        );

        _orders[orderIndex] = updatedOrder;
        await _saveOrders();
        notifyListeners();
      }
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
