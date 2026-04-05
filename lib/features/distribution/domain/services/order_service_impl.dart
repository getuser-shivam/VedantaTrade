import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../entities/order.dart';
import '../repositories/order_repository.dart';

/// Order Service Implementation
/// Real-time order management with WebSocket integration and lifecycle management
class OrderServiceImpl implements OrderService {
  final OrderRepository _repository;
  final WebSocketChannel? _webSocketChannel;
  final StreamController<Order> _orderStreamController;
  final StreamController<OrderStatusUpdate> _statusUpdateController;
  final Map<String, Order> _activeOrders = {};
  final Map<String, Order> _pendingOrders = {};
  final Map<String, Order> _ordersByStatus = {};
  Timer? _statusCheckTimer;
  bool _isConnected = false;
  String? _currentUserId;
  String? _currentUserRole;

  OrderServiceImpl(this._repository, {String? webSocketUrl})
    : _orderStreamController = StreamController<Order>.broadcast(),
      _statusUpdateController = StreamController<OrderStatusUpdate>.broadcast(),
      _webSocketChannel = webSocketUrl != null 
          ? WebSocketChannel.connect(Uri.parse(webSocketUrl))
          : null;

  /// Stream of order updates
  Stream<Order> get orderStream => _orderStreamController.stream;

  /// Stream of status updates
  Stream<OrderStatusUpdate> get statusUpdateStream => _statusUpdateController.stream;

  /// Initialize order service
  Future<void> initialize() async {
    try {
// print('🔍 Initializing Order Service...'); // Removed for production
      
      // Load existing orders
      await _loadExistingOrders();
      
      // Start status monitoring
      _startStatusMonitoring();
      
      // Connect to WebSocket if available
      if (_webSocketChannel != null) {
        await _connectWebSocket();
      }
      
// print('✅ Order Service initialized successfully'); // Removed for production
    } catch (e) {
// print('❌ Failed to initialize Order Service: $e'); // Removed for production
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
// print('🛒 Creating new order for retailer: $retailerId'); // Removed for production
      
      // Generate unique order number
      final orderNumber = _generateOrderNumber();
      final orderId = DateTime.now().millisecondsSinceEpoch.toString();
      
      // Calculate totals
      final totalAmount = items.fold(0.0, (sum, item) => sum + item.totalPrice);
      final taxAmount = totalAmount * 0.13; // 13% VAT for Nepal
      final finalAmount = totalAmount + taxAmount;
      
      final order = Order(
        id: orderId,
        orderNumber: orderNumber,
        retailerId: retailerId,
        stockistId: stockistId,
        mrId: mrId,
        items: items,
        status: OrderStatus.pending,
        createdAt: DateTime.now(),
        totalAmount: totalAmount,
        discountAmount: 0.0,
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
        // Update local cache
        _pendingOrders[order.id] = order;
        
        // Send WebSocket notification
        await _sendOrderNotification(order, 'created');
        
        // Add to stream
        _orderStreamController.add(order);
        
// print('✅ Order created successfully: ${order.orderNumber}'); // Removed for production
        return Right(order);
      } else {
        return Left(result.fold((l) => l, (r) => r));
      }
    } catch (e) {
// print('❌ Failed to create order: $e'); // Removed for production
      return Left(Failure(
        message: 'Failed to create order',
        code: 'CREATE_ERROR',
        details: e,
      ));
    }
  }

  /// Approve order
  Future<Either<Failure, void>> approveOrder(String orderId, {String? approvedBy}) async {
    try {
// print('✅ Approving order: $orderId'); // Removed for production
      
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
            metadata: {
              ...order.metadata,
              'approved_by': approvedBy,
              'approved_at': DateTime.now().toIso8601String(),
            },
          );
          
          // Update repository
          final result = await _repository.updateOrder(approvedOrder);
          
          if (result.isRight()) {
            // Update local cache
            _pendingOrders.remove(orderId);
            _activeOrders[orderId] = approvedOrder;
            
            // Send WebSocket notification
            await _sendOrderNotification(approvedOrder, 'approved');
            
            // Add to stream
            _orderStreamController.add(approvedOrder);
            
// print('✅ Order approved successfully: ${approvedOrder.orderNumber}'); // Removed for production
            return const Right(null);
          } else {
            return Left(result.fold((l) => l, (r) => r));
          }
        },
      );
    } catch (e) {
// print('❌ Failed to approve order: $e'); // Removed for production
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
// print('🚚 Dispatching order: $orderId'); // Removed for production
      
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
            metadata: {
              ...order.metadata,
              'dispatched_at': DateTime.now().toIso8601String(),
              'dispatched_by': _currentUserId,
            },
          );
          
          // Update repository
          final result = await _repository.updateOrder(dispatchedOrder);
          
          if (result.isRight()) {
            // Update local cache
            _activeOrders[orderId] = dispatchedOrder;
            
            // Send WebSocket notification
            await _sendOrderNotification(dispatchedOrder, 'dispatched');
            
            // Add to stream
            _orderStreamController.add(dispatchedOrder);
            
// print('✅ Order dispatched successfully: ${dispatchedOrder.orderNumber}'); // Removed for production
            return const Right(null);
          } else {
            return Left(result.fold((l) => l, (r) => r));
          }
        },
      );
    } catch (e) {
// print('❌ Failed to dispatch order: $e'); // Removed for production
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
// print('📦 Marking order as delivered: $orderId'); // Removed for production
      
      final orderResult = await _repository.getOrderById(orderId);
      
      return orderResult.fold(
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
            metadata: {
              ...order.metadata,
              'delivered_at': DateTime.now().toIso8601String(),
              'delivered_by': _currentUserId,
            },
          );
          
          // Update repository
          final result = await _repository.updateOrder(deliveredOrder);
          
          if (result.isRight()) {
            // Update local cache
            _activeOrders[orderId] = deliveredOrder;
            
            // Send WebSocket notification
            await _sendOrderNotification(deliveredOrder, 'delivered');
            
            // Add to stream
            _orderStreamController.add(deliveredOrder);
            
// print('✅ Order marked as delivered: ${deliveredOrder.orderNumber}'); // Removed for production
            return const Right(null);
          } else {
            return Left(result.fold((l) => l, (r) => r));
          }
        },
      );
    } catch (e) {
// print('❌ Failed to mark order as delivered: $e'); // Removed for production
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
// print('💳 Marking order as paid: $orderId'); // Removed for production
      
      final orderResult = await _repository.getOrderById(orderId);
      
      return orderResult.fold(
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
            paymentStatus: 'completed',
            deliveryNotes: notes,
            attachments: attachments ?? [],
            metadata: {
              ...order.metadata,
              'paid_at': DateTime.now().toIso8601String(),
              'paid_by': _currentUserId,
              'payment_method': paymentMethod,
            },
          );
          
          // Update repository
          final result = await _repository.updateOrder(paidOrder);
          
          if (result.isRight()) {
            // Update local cache
            _activeOrders[orderId] = paidOrder;
            
            // Send WebSocket notification
            await _sendOrderNotification(paidOrder, 'paid');
            
            // Add to stream
            _orderStreamController.add(paidOrder);
            
// print('✅ Order marked as paid: ${paidOrder.orderNumber}'); // Removed for production
            return const Right(null);
          } else {
            return Left(result.fold((l) => l, (r) => r));
          }
        },
      );
    } catch (e) {
// print('❌ Failed to mark order as paid: $e'); // Removed for production
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
// print('❌ Cancelling order: $orderId'); // Removed for production
      
      final orderResult = await _repository.getOrderById(orderId);
      
      return orderResult.fold(
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
              'cancelled_at': DateTime.now().toIso8601String(),
              'cancelled_by': _currentUserId,
              'cancellation_reason': reason ?? 'User requested',
            },
          );
          
          // Update repository
          final result = await _repository.updateOrder(cancelledOrder);
          
          if (result.isRight()) {
            // Update local cache
            _pendingOrders.remove(orderId);
            _activeOrders.remove(orderId);
            
            // Send WebSocket notification
            await _sendOrderNotification(cancelledOrder, 'cancelled');
            
            // Add to stream
            _orderStreamController.add(cancelledOrder);
            
// print('✅ Order cancelled successfully: ${cancelledOrder.orderNumber}'); // Removed for production
            return const Right(null);
          } else {
            return Left(result.fold((l) => l, (r) => r));
          }
        },
      );
    } catch (e) {
// print('❌ Failed to cancel order: $e'); // Removed for production
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
// print('🔍 Getting orders for retailer: $retailerId'); // Removed for production
      
      final result = await _repository.getOrdersByRetailer(
        retailerId: retailerId,
        status: status,
        limit: limit,
      );
      
      if (result.isRight()) {
// print('✅ Retrieved ${result.length} orders for retailer: $retailerId'); // Removed for production
        return Right(result);
      } else {
        return Left(result.fold((l) => l, (r) => r));
      }
    } catch (e) {
// print('❌ Failed to get orders for retailer: $e'); // Removed for production
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
// print('🔍 Getting orders for stockist: $stockistId'); // Removed for production
      
      final result = await _repository.getOrdersByStockist(
        stockistId: stockistId,
        status: status,
        limit: limit,
      );
      
      if (result.isRight()) {
// print('✅ Retrieved ${result.length} orders for stockist: $stockistId'); // Removed for production
        return Right(result);
      } else {
        return Left(result.fold((l) => l, (r) => r));
      }
    } catch (e) {
// print('❌ Failed to get orders for stockist: $e'); // Removed for production
      return Left(Failure(
        message: 'Failed to get orders for stockist',
        code: 'RETRIEVE_ERROR',
        details: e,
      ));
    }
  }

  /// Get orders by status
  Future<Either<Failure, List<Order>>> getOrdersByStatus({
    required OrderStatus status,
    int? limit,
  }) async {
    try {
// print('🔍 Getting orders by status: ${status.name}'); // Removed for production
      
      final result = await _repository.getOrdersByStatus(
        status: status,
        limit: limit,
      );
      
      if (result.isRight()) {
// print('✅ Retrieved ${result.length} orders with status: ${status.name}'); // Removed for production
        return Right(result);
      } else {
        return Left(result.fold((l) => l, (r) => r));
      }
    } catch (e) {
// print('❌ Failed to get orders by status: $e'); // Removed for production
      return Left(Failure(
        message: 'Failed to get orders by status',
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
// print('📊 Getting order statistics...'); // Removed for production
      
      final result = await _repository.getOrderStatistics(
        retailerId: retailerId,
        stockistId: stockistId,
        mrId: mrId,
        startDate: startDate,
        endDate: endDate,
      );
      
      if (result.isRight()) {
// print('✅ Order statistics retrieved successfully'); // Removed for production
        return Right(result);
      } else {
        return Left(result.fold((l) => l, (r) => r));
      }
    } catch (e) {
// print('❌ Failed to get order statistics: $e'); // Removed for production
      return Left(Failure(
        message: 'Failed to get order statistics',
        code: 'STATISTICS_ERROR',
        details: e,
      ));
    }
  }

  /// Set current user
  void setCurrentUser(String userId, String role) {
    _currentUserId = userId;
    _currentUserRole = role;
// print('✅ Current user set: $userId ($role)'); // Removed for production
  }

  /// Generate unique order number
  String _generateOrderNumber() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = DateTime.now().millisecond % 1000;
    return 'ORD-${timestamp}-$random';
  }

  /// Load existing orders
  Future<void> _loadExistingOrders() async {
    try {
// print('📂 Loading existing orders...'); // Removed for production
      
      final pendingResult = await _repository.getOrdersByStatus(status: OrderStatus.pending);
      final activeResult = await _repository.getOrdersByStatus(status: OrderStatus.approved);
      
      if (pendingResult.isRight()) {
        for (final order in pendingResult) {
          _pendingOrders[order.id] = order;
        }
      }
      
      if (activeResult.isRight()) {
        for (final order in activeResult) {
          _activeOrders[order.id] = order;
        }
      }
      
// print('✅ Loaded ${_pendingOrders.length + _activeOrders.length} existing orders'); // Removed for production
    } catch (e) {
// print('❌ Failed to load existing orders: $e'); // Removed for production
    }
  }

  /// Start status monitoring
  void _startStatusMonitoring() {
    _statusCheckTimer?.cancel();
    
    _statusCheckTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      if (_webSocketChannel == null) return;
      
      try {
        await _checkOrderStatuses();
      } catch (e) {
// print('❌ Failed to check order statuses: $e'); // Removed for production
      }
    });
  }

  /// Check order statuses
  Future<void> _checkOrderStatuses() async {
    try {
      final db = await _repository._databaseHelper.database;
      
      // Check for status changes
      for (final orderId in _activeOrders.keys) {
        final cachedOrder = _activeOrders[orderId];
        final result = await _repository.getOrderById(orderId);
        
        result.fold(
          (error) => print('❌ Failed to check order status: ${error.message}'),
          (dbOrder) {
            if (dbOrder.status != cachedOrder.status) {
              // Update cache
              _activeOrders[orderId] = dbOrder;
              
              // Send WebSocket notification
              await _sendOrderNotification(dbOrder, 'status_updated');
              
              // Add to stream
              _orderStreamController.add(dbOrder);
              
// print('🔄 Order status updated: ${dbOrder.orderNumber} -> ${dbOrder.status.name}'); // Removed for production
            }
          },
        );
      }
    } catch (e) {
// print('❌ Failed to check order statuses: $e'); // Removed for production
    }
  }

  /// Connect to WebSocket
  Future<void> _connectWebSocket() async {
    try {
      if (_webSocketChannel == null) return;
      
// print('🌐 Connecting to WebSocket...'); // Removed for production
      
      _webSocketChannel!.stream.listen(
        (data) {
          try {
            final message = jsonDecode(data as String);
            _handleWebSocketMessage(message);
          } catch (e) {
// print('❌ Failed to handle WebSocket message: $e'); // Removed for production
          }
        },
        onError: (error) {
// print('❌ WebSocket error: $error'); // Removed for production
          _isConnected = false;
        },
        onDone: () {
// print('🔌 WebSocket connection closed'); // Removed for production
          _isConnected = false;
        },
      );
      
      _webSocketChannel!.sink.add(jsonEncode({
        'type': 'connect',
        'timestamp': DateTime.now().toIso8601String(),
        'client': 'vedantatrade-app',
        'version': '1.0.0',
      }));
      
      _isConnected = true;
// print('✅ WebSocket connected successfully'); // Removed for production
    } catch (e) {
// print('❌ Failed to connect to WebSocket: $e'); // Removed for production
      _isConnected = false;
    }
  }

  /// Handle WebSocket message
  void _handleWebSocketMessage(Map<String, dynamic> message) {
    try {
      final type = message['type'] as String;
      
      switch (type) {
        case 'order_update':
          _handleOrderUpdate(message['data'] as Map<String, dynamic>);
          break;
        case 'ping':
          _handlePing();
          break;
        case 'sync_request':
          _handleSyncRequest(message['data'] as Map<String, dynamic>);
          break;
        default:
// print('⚠️ Unknown WebSocket message type: $type'); // Removed for production
      }
    } catch (e) {
// print('❌ Failed to handle WebSocket message: $e'); // Removed for production
    }
  }

  /// Handle order update
  void _handleOrderUpdate(Map<String, dynamic> data) {
    try {
      final orderData = data['order'] as Map<String, dynamic>;
      final order = Order.fromMap(orderData);
      
      // Update local cache
      _activeOrders[order.id] = order;
      _updateStatusCache(order);
      
      // Add to stream
      _orderStreamController.add(order);
      
// print('📥 Order updated via WebSocket: ${order.orderNumber} -> ${order.status.name}'); // Removed for production
    } catch (e) {
// print('❌ Failed to handle order update: $e'); // Removed for production
    }
  }

  /// Handle ping
  void _handlePing() {
    try {
      _webSocketChannel?.sink.add(jsonEncode({
        'type': 'pong',
        'timestamp': DateTime.now().toIso8601String(),
      }));
    } catch (e) {
// print('❌ Failed to handle ping: $e'); // Removed for production
    }
  }

  /// Handle sync request
  void _handleSyncRequest(Map<String, dynamic> data) {
    try {
      final lastSyncTime = data['last_sync_time'] as String?;
      final limit = data['limit'] as int? ?? 100;
      
      final db = await _repository._databaseHelper.database;
      final maps = await db.query(
        'orders',
        where: lastSyncTime != null 
            ? 'updated_at > ?' 
            : '1=1',
        whereArgs: lastSyncTime != null ? [lastSyncTime] : [],
        orderBy: 'updated_at DESC',
        limit: limit,
      );
      
      final orders = maps.map((map) => Order.fromMap(map)).toList();
      
      // Send sync response
      _webSocketChannel?.sink.add(jsonEncode({
        'type': 'sync_response',
        'timestamp': DateTime.now().toIso8601String(),
        'orders': orders.map((order) => order.toMap()).toList(),
        'count': orders.length,
      }));
      
// print('📤 Sync response sent: ${orders.length} orders'); // Removed for production
    } catch (e) {
// print('❌ Failed to handle sync request: $e'); // Removed for production
    }
  }

  /// Update status cache
  void _updateStatusCache(Order order) {
    final status = order.status;
    
    if (!_ordersByStatus.containsKey(status)) {
      _ordersByStatus[status] = [];
    }
    
    _ordersByStatus[status]!.removeWhere((cachedOrder) => cachedOrder.id == order.id);
    _ordersByStatus[status]!.add(order);
  }

  /// Send order notification via WebSocket
  Future<void> _sendOrderNotification(Order order, String action) async {
    try {
      if (!_isConnected || _webSocketChannel == null) return;
      
      final notification = {
        'type': 'order_notification',
        'action': action,
        'timestamp': DateTime.now().toIso8601String(),
        'order': order.toMap(),
        'user_id': _currentUserId,
        'user_role': _currentUserRole,
      };
      
      _webSocketChannel!.sink.add(jsonEncode(notification));
      
// print('📢 Order notification sent: $action - ${order.orderNumber}'); // Removed for production
    } catch (e) {
// print('❌ Failed to send order notification: $e'); // Removed for production
    }
  }

  /// Dispose resources
  void dispose() {
// print('🗑️ Disposing Order Service...'); // Removed for production
    
    _statusCheckTimer?.cancel();
    _webSocketChannel?.sink.close();
    _orderStreamController.close();
    _statusUpdateController.close();
    
// print('✅ Order Service disposed'); // Removed for production
  }
}
