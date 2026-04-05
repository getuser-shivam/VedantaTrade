import 'dart:async';
import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../entities/order.dart';
import '../repositories/order_repository.dart';

/// Order Service for real-time order lifecycle management
/// Handles order processing, status updates, and real-time notifications
class OrderService {
  final OrderRepository _repository;
  final WebSocketChannel? _webSocketChannel;
  final StreamController<Order> _orderStreamController;
  final StreamController<OrderStatusUpdate> _statusUpdateController;
  Timer? _statusCheckTimer;
  Map<String, Order> _pendingOrders = {};
  Map<String, Order> _activeOrders = {};

  OrderService(this._repository, {String? webSocketUrl}) 
    : _orderStreamController = StreamController<Order>.broadcast(),
      _statusUpdateController = StreamController<OrderStatusUpdate>.broadcast(),
      _webSocketChannel = webSocketUrl != null ? WebSocketChannel.connect(Uri.parse(webSocketUrl)) : null;

  /// Stream of order updates
  Stream<Order> get orderStream => _orderStreamController.stream;

  /// Stream of status updates
  Stream<OrderStatusUpdate> get statusUpdateStream => _statusUpdateController.stream;

  /// Initialize order service
  Future<void> initialize() async {
    try {
      print('🔍 Initializing Order Service...');
      
      // Load pending orders
      await _loadPendingOrders();
      
      // Load active orders
      await _loadActiveOrders();
      
      // Start status monitoring
      _startStatusMonitoring();
      
      // Connect to WebSocket if available
      if (_webSocketChannel != null) {
        _connectWebSocket();
      }
      
      print('✅ Order Service initialized successfully');
    } catch (e) {
      print('❌ Failed to initialize Order Service: $e');
      rethrow;
    }
  }

  /// Create new order
  Future<Either<Failure, Order>> createOrder({
    required String retailerId,
    required String stockistId,
    required String mrId,
    required List<OrderItem> items,
    required String deliveryAddress,
    String? notes,
    String? paymentMethod,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      print('🛒 Creating new order for retailer: $retailerId');
      
      // Calculate totals
      final totalAmount = items.fold(0.0, (sum, item) => sum + item.totalPrice);
      final taxAmount = totalAmount * 0.13; // 13% VAT
      final finalAmount = totalAmount + taxAmount;
      
      final order = Order(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        orderNumber: _generateOrderNumber(),
        retailerId: retailerId,
        stockistId: stockistId,
        mrId: mrId,
        items: items,
        status: OrderStatus.pending,
        createdAt: DateTime.now(),
        totalAmount: totalAmount,
        taxAmount: taxAmount,
        finalAmount: finalAmount,
        paymentMethod: paymentMethod ?? 'cash',
        deliveryAddress: deliveryAddress,
        notes: notes,
        metadata: metadata ?? {},
      );
      
      // Save to repository
      final result = await _repository.saveOrder(order);
      
      if (result.isRight()) {
        _pendingOrders[order.id] = order;
        _orderStreamController.add(order);
        
        // Send real-time notification
        _sendOrderNotification(order, 'created');
        
        print('✅ Order created successfully: ${order.orderNumber}');
        return Right(order);
      } else {
        return Left(result.fold((l) => l, (r) => r));
      }
    } catch (e) {
      print('❌ Failed to create order: $e');
      return Left(Failure(
        message: 'Failed to create order',
        code: 'CREATE_ERROR',
        details: e,
      ));
    }
  }

  /// Approve order
  Future<Either<Failure, void>> approveOrder(String orderId) async {
    try {
      print('✅ Approving order: $orderId');
      
      final orderResult = await _repository.getOrderById(orderId);
      
      return orderResult.fold(
        (error) => Left(error),
        (order) async {
          if (!order.canBeApproved()) {
            return Left(Failure(
              message: 'Order cannot be approved in current status',
              code: 'INVALID_STATUS',
            ));
          }
          
          final approvedOrder = order.copyWith(
            status: OrderStatus.approved,
            approvedAt: DateTime.now(),
          );
          
          final result = await _repository.updateOrder(approvedOrder);
          
          if (result.isRight()) {
            _pendingOrders.remove(orderId);
            _activeOrders[orderId] = approvedOrder;
            _orderStreamController.add(approvedOrder);
            
            // Send real-time notification
            _sendOrderNotification(approvedOrder, 'approved');
            
            print('✅ Order approved successfully: ${approvedOrder.orderNumber}');
            return const Right(null);
          } else {
            return Left(result.fold((l) => l, (r) => r));
          }
        },
      );
    } catch (e) {
      print('❌ Failed to approve order: $e');
      return Left(Failure(
        message: 'Failed to approve order',
        code: 'APPROVE_ERROR',
        details: e,
      ));
    }
  }

  /// Dispatch order
  Future<Either<Failure, void>> dispatchOrder(String orderId, {
    String? trackingNumber,
    String? notes,
  }) async {
    try {
      print('🚚 Dispatching order: $orderId');
      
      final orderResult = await _repository.getOrderById(orderId);
      
      return orderResult.fold(
        (error) => Left(error),
        (order) async {
          if (!order.canBeDispatched()) {
            return Left(Failure(
              message: 'Order cannot be dispatched in current status',
              code: 'INVALID_STATUS',
            ));
          }
          
          final dispatchedOrder = order.copyWith(
            status: OrderStatus.dispatched,
            dispatchedAt: DateTime.now(),
            trackingNumber: trackingNumber,
            deliveryNotes: notes,
          );
          
          final result = await _repository.updateOrder(dispatchedOrder);
          
          if (result.isRight()) {
            _activeOrders[orderId] = dispatchedOrder;
            _orderStreamController.add(dispatchedOrder);
            
            // Send real-time notification
            _sendOrderNotification(dispatchedOrder, 'dispatched');
            
            print('✅ Order dispatched successfully: ${dispatchedOrder.orderNumber}');
            return const Right(null);
          } else {
            return Left(result.fold((l) => l, (r) => r));
          }
        },
      );
    } catch (e) {
      print('❌ Failed to dispatch order: $e');
      return Left(Failure(
        message: 'Failed to dispatch order',
        code: 'DISPATCH_ERROR',
        details: e,
      ));
    }
  }

  /// Mark order as delivered
  Future<Either<Failure, void>> markOrderAsDelivered(String orderId, {
    String? notes,
    List<String>? attachments,
  }) async {
    try {
      print('📦 Marking order as delivered: $orderId');
      
      final OrderResult = await _repository.getOrderById(orderId);
      
      return OrderResult.fold(
        (error) => Left(error),
        (order) async {
          if (!order.canBeDelivered()) {
            return Left(Failure(
              message: 'Order cannot be marked as delivered in current status',
              code: 'INVALID_STATUS',
            ));
          }
          
          final deliveredOrder = order.copyWith(
            status: OrderStatus.delivered,
            deliveredAt: DateTime.now(),
            deliveryNotes: notes,
            attachments: attachments ?? [],
          );
          
          final result = await _repository.updateOrder(deliveredOrder);
          
          if (result.isRight()) {
            _activeOrders[orderId] = deliveredOrder;
            _orderStreamController.add(deliveredOrder);
            
            // Send real-time notification
            _sendOrderNotification(deliveredOrder, 'delivered');
            
            print('✅ Order marked as delivered: ${deliveredOrder.orderNumber}');
            return const Right(null);
          } else {
            return Left(result.fold((l) => l, (r) => r));
          }
        },
      );
    } catch (e) {
      print('❌ Failed to mark order as delivered: $e');
      return Left(Failure(
        message: 'Failed to mark order as delivered',
        code: 'DELIVER_ERROR',
        details: e,
      ));
    }
  }

  /// Mark order as paid
  Future<Either<Failure, void>> markOrderAsPaid(String orderId, {
    required String paymentMethod,
    String? notes,
    List<String>? attachments,
  }) async {
    try {
      print('💳 Marking order as paid: $orderId');
      
      final OrderResult = await _repository.getOrderById(orderId);
      
      return OrderResult.fold(
        (error) => Left(error),
        (order) async {
          if (!order.canBePaid()) {
            return Left(Failure(
              message: 'Order cannot be marked as paid in current status',
              code: 'INVALID_STATUS',
            ));
          }
          
          final paidOrder = order.copyWith(
            status: OrderStatus.paid,
            paidAt: DateTime.now(),
            paymentMethod: paymentMethod,
            deliveryNotes: notes,
            attachments: attachments ?? [],
          );
          
          final result = await _repository.updateOrder(paidOrder);
          
          if (result.isRight()) {
            _activeOrders[orderId] = paidOrder;
            _orderStreamController.add(paidOrder);
            
            // Send real-time notification
            _sendOrderNotification(paidOrder, 'paid');
            
            print('✅ Order marked as paid: ${paidOrder.orderNumber}');
            return const Right(null);
          } else {
            return Left(result.fold((l) => l, (r) => r));
          }
        },
      );
    } catch (e) {
      print('❌ Failed to mark order as paid: $e');
      return Left(Failure(
        message: 'Failed to mark order as paid',
        code: 'PAY_ERROR',
        details: e,
      ));
    }
  }

  /// Cancel order
  Future<Either<Failure, void>> cancelOrder(String orderId, {String? reason}) async {
    try {
      print('❌ Cancelling order: $orderId');
      
      final OrderResult = await _repository.getOrderById(orderId);
      
      return OrderResult.fold(
        (error) => Left(error),
        (order) async {
          if (!order.canBeCancelled()) {
            return Left(Failure(
              message: 'Order cannot be cancelled in current status',
              code: 'INVALID_STATUS',
            ));
          }
          
          final cancelledOrder = order.copyWith(
            status: OrderStatus.cancelled,
            metadata: {
              ...order.metadata,
              'cancellation_reason': reason ?? 'User requested',
              'cancelled_at': DateTime.now().toIso8601String(),
            },
          );
          
          final result = await _repository.updateOrder(cancelledOrder);
          
          if (result.isRight()) {
            _pendingOrders.remove(orderId);
            _activeOrders.remove(orderId);
            _orderStreamController.add(cancelledOrder);
            
            // Send real-time notification
            _sendOrderNotification(cancelledOrder, 'cancelled');
            
            print('✅ Order cancelled successfully: ${cancelledOrder.orderNumber}');
            return const Right(null);
          } else {
            return Left(result.fold((l) => l, (r) => r));
          }
        },
      );
    } catch (e) {
      print('❌ Failed to cancel order: $e');
      return Left(Failure(
        message: 'Failed to cancel order',
        code: 'CANCEL_ERROR',
        details: e,
      ));
    }
  }

  /// Get orders by retailer
  Future<Either<Failure, List<Order>>> getOrdersByRetailer({
    required String retailerId,
    OrderStatus? status,
    int? limit,
  }) async {
    try {
      print('🔍 Getting orders for retailer: $retailerId');
      
      final result = await _repository.getOrdersByRetailer(
        retailerId: retailerId,
        status: status,
        limit: limit,
      );
      
      return result.fold(
        (error) => Left(error),
        (orders) {
          print('✅ Retrieved ${orders.length} orders for retailer: $retailerId');
          return Right(orders);
        },
      );
    } catch (e) {
      print('❌ Failed to get orders for retailer: $e');
      return Left(Failure(
        message: 'Failed to get orders for retailer',
        code: 'RETRIEVE_ERROR',
        details: e,
      ));
    }
  }

  /// Get orders by stockist
  Future<Either<Failure, List<Order>>> getOrdersByStockist({
    required String stockistId,
    OrderStatus? status,
    int? limit,
  }) async {
    try {
      print('🔍 Getting orders for stockist: $stockistId');
      
      final result = await _repository.getOrdersByStockist(
        stockistId: stockistId,
        status: status,
        limit: limit,
      );
      
      return result.fold(
        (error) => Left(error),
        (orders) {
          print('✅ Retrieved ${orders.length} orders for stockist: $stockistId');
          return Right(orders);
        },
      );
    } catch (e) {
      print('❌ Failed to get orders for stockist: $e');
      return Left(Failure(
        message: 'Failed to get orders for stockist',
        code: 'RETRIEVE_ERROR',
        details: e,
      ));
    }
  }

  /// Get order statistics
  Future<Either<Failure, Map<String, dynamic>>> getOrderStatistics({
    String? retailerId,
    String? stockistId,
    String? mrId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      print('📈 Getting order statistics...');
      
      final result = await _repository.getOrderStatistics(
        retailerId: retailerId,
        stockistId: stockistId,
        mrId: mrId,
        startDate: startDate,
        endDate: endDate,
      );
      
      return result.fold(
        (error) => Left(error),
        (stats) {
          print('✅ Order statistics calculated');
          return Right(stats);
        },
      );
    } catch (e) {
      print('❌ Failed to get order statistics: $e');
      return Left(Failure(
        message: 'Failed to get order statistics',
        code: 'STATISTICS_ERROR',
        details: e,
      ));
    }
  }

  /// Get pending orders
  Future<Either<Failure, List<Order>>> getPendingOrders({int? limit}) async {
    try {
      print('🔍 Getting pending orders...');
      
      final result = await _repository.getOrdersByStatus(
        status: OrderStatus.pending,
        limit: limit,
      );
      
      return result.fold(
        (error) => Left(error),
        (orders) {
          print('✅ Retrieved ${orders.length} pending orders');
          return Right(orders);
        },
      );
    } catch (e) {
      print('❌ Failed to get pending orders: $e');
      return Left(Failure(
        message: 'Failed to get pending orders',
        code: 'RETRIEVE_ERROR',
        details: e,
      ));
    }
  }

  /// Get active orders
  Future<Either<Failure, List<Order>>> getActiveOrders({int? limit}) async {
    try {
      print('🔍 Getting active orders...');
      
      final result = await _repository.getOrdersByStatus(
        status: OrderStatus.approved,
        limit: limit,
      );
      
      return result.fold(
        (error) => Left(error),
        (orders) {
          print('✅ Retrieved ${orders.length} active orders');
          return Right(orders);
        },
      );
    } catch (e) {
      print('❌ Failed to get active orders: $e');
      return Left(Failure(
        message: 'Failed to get active orders',
        code: 'RETRIEVE_ERROR',
        details: e,
      ));
    }
  }

  /// Load pending orders from repository
  Future<void> _loadPendingOrders() async {
    try {
      final result = await _repository.getOrdersByStatus(status: OrderStatus.pending);
      
      result.fold(
        (error) => print('❌ Failed to load pending orders: ${error.message}'),
        (orders) {
          _pendingOrders.clear();
          for (final order in orders) {
            _pendingOrders[order.id] = order;
          }
          print('✅ Loaded ${orders.length} pending orders');
        },
      );
    } catch (e) {
      print('❌ Failed to load pending orders: $e');
    }
  }

  /// Load active orders from repository
  Future<void> _loadActiveOrders() async {
    try {
      final result = await _repository.getOrdersByStatus(status: OrderStatus.approved);
      
      result.fold(
        (error) => print('❌ Failed to load active orders: ${error.message}'),
        (orders) {
          _activeOrders.clear();
          for (final order in orders) {
            _activeOrders[order.id] = order;
          }
          print('✅ Loaded ${orders.length} active orders');
        },
      );
    } catch (e) {
      print('❌ Failed to load active orders: $e');
    }
  }

  /// Start status monitoring
  void _startStatusMonitoring() {
    _statusCheckTimer?.cancel();
    
    _statusCheckTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      await _checkOrderStatuses();
    });
  }

  /// Check order statuses
  Future<void> _checkOrderStatuses() async {
    try {
      // Check for status updates in pending orders
      for (final orderId in _pendingOrders.keys) {
        final currentOrder = _pendingOrders[orderId]!;
        final result = await _repository.getOrderById(orderId);
        
        result.fold(
          (error) => print('❌ Failed to check order status: ${error.message}'),
          (latestOrder) {
            if (latestOrder.status != currentOrder.status) {
              _pendingOrders[orderId] = latestOrder;
              _orderStreamController.add(latestOrder);
              
              // Send status update notification
              _sendStatusUpdateNotification(currentOrder, latestOrder);
            }
          },
        );
      }
      
      // Check for status updates in active orders
      for (final orderId in _activeOrders.keys) {
        final currentOrder = _activeOrders[orderId]!;
        final result = await _repository.getOrderById(orderId);
        
        result.fold(
          (error) => print('❌ Failed to check order status: ${error.message}'),
          (latestOrder) {
            if (latestOrder.status != currentOrder.status) {
              _activeOrders[orderId] = latestOrder;
              _orderStreamController.add(latestOrder);
              
              // Send status update notification
              _sendStatusUpdateNotification(currentOrder, latestOrder);
            }
          },
        );
      }
    } catch (e) {
      print('❌ Failed to check order statuses: $e');
    }
  }

  /// Connect to WebSocket for real-time updates
  void _connectWebSocket() {
    if (_webSocketChannel == null) return;
    
    _webSocketChannel!.stream.listen(
      (data) {
        try {
          final message = jsonDecode(data as String);
          
          if (message['type'] == 'order_update') {
            final orderData = message['data'] as Map<String, dynamic>;
            final order = Order.fromMap(orderData);
            
            // Update local cache
            if (_pendingOrders.containsKey(order.id)) {
              _pendingOrders[order.id] = order;
              _orderStreamController.add(order);
            } else if (_activeOrders.containsKey(order.id)) {
              _activeOrders[order.id] = order;
              _orderStreamController.add(order);
            }
            
            // Send status update notification
            _sendStatusUpdateNotification(order, order);
          }
        } catch (e) {
          print('❌ Failed to process WebSocket message: $e');
        }
      },
      onError: (error) {
        print('❌ WebSocket error: $error');
      },
      onDone: () {
        print('🔌 WebSocket connection closed');
      },
    );
    
    print('✅ Connected to WebSocket for real-time order updates');
  }

  /// Send order notification
  void _sendOrderNotification(Order order, String action) {
    final notification = {
      'type': 'order',
      'action': action,
      'order_id': order.id,
      'order_number': order.orderNumber,
      'retailer_id': order.retailerId,
      'status': order.status.name,
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    _statusUpdateController.add(OrderStatusUpdate(
      type: 'order_notification',
      data: notification,
    ));
    
    print('📢 Order notification sent: $action - ${order.orderNumber}');
  }

  /// Send status update notification
  void _sendStatusUpdateNotification(Order oldOrder, Order newOrder) {
    final notification = {
      'type': 'status_update',
      'order_id': newOrder.id,
      'order_number': newOrder.orderNumber,
      'old_status': oldOrder.status.name,
      'new_status': newOrder.status.name,
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    _statusUpdateController.add(OrderStatusUpdate(
      type: 'status_update',
      data: notification,
    ));
    
    print('📢 Status update sent: ${oldOrder.status.name} -> ${newOrder.status.name}');
  }

  /// Generate unique order number
  String _generateOrderNumber() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = DateTime.now().millisecond % 1000;
    return 'ORD-${timestamp}-${random}';
  }

  /// Dispose resources
  void dispose() {
    print('🗑️ Disposing Order Service...');
    
    _statusCheckTimer?.cancel();
    _orderStreamController.close();
    _statusUpdateController.close();
    _webSocketChannel?.sink.close();
    
    print('✅ Order Service disposed');
  }
}

/// Order status update entity
class OrderStatusUpdate {
  final String type;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  const OrderStatusUpdate({
    required this.type,
    required this.data,
    required this.timestamp,
  });
}
