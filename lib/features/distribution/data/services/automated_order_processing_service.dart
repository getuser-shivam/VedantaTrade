import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:vedanta_trade/core/api_config.dart';
import '../models/sales_models.dart';
import '../models/inventory_models.dart';

/// Automated Order Processing Service
/// Handles automated order validation, inventory checks, payment processing, and fulfillment
class AutomatedOrderProcessingService {
  static final AutomatedOrderProcessingService _instance = AutomatedOrderProcessingService._internal();
  factory AutomatedOrderProcessingService() => _instance;
  AutomatedOrderProcessingService._internal();

  final Dio _dio = Dio();
  final StreamController<OrderProcessingEvent> _eventsController = 
      StreamController<OrderProcessingEvent>.broadcast();
  final StreamController<List<OrderQueueItem>> _queueController = 
      StreamController<List<OrderQueueItem>>.broadcast();
  final StreamController<OrderProcessingMetrics> _metricsController = 
      StreamController<OrderProcessingMetrics>.broadcast();

  List<OrderQueueItem> _orderQueue = [];
  OrderProcessingMetrics _metrics = OrderProcessingMetrics();
  Timer? _processingTimer;
  String? _currentStockistId;

  // Stream getters
  Stream<OrderProcessingEvent> get eventsStream => _eventsController.stream;
  Stream<List<OrderQueueItem>> get queueStream => _queueController.stream;
  Stream<OrderProcessingMetrics> get metricsStream => _metricsController.stream;

  // Data getters
  List<OrderQueueItem> get orderQueue => List.unmodifiable(_orderQueue);
  OrderProcessingMetrics get metrics => _metrics;

  void initialize({String? stockistId}) {
    _currentStockistId = stockistId;
    _setupDioClient();
    _startOrderProcessing();
  }

  void _setupDioClient() {
    _dio.options.baseUrl = ApiConfig.baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'X-Country': 'NP',
      'X-Currency': 'NPR',
      'X-Timezone': 'Asia/Kathmandu',
    };
  }

  void _startOrderProcessing() {
    // Process orders every 30 seconds
    _processingTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _processOrderQueue();
    });
  }

  /// Add order to processing queue
  Future<OrderProcessingResult> addOrderToQueue(SalesOrder order) async {
    try {
      // Validate order
      final validationResult = await _validateOrder(order);
      if (!validationResult.isValid) {
        return OrderProcessingResult(
          success: false,
          orderId: order.orderId,
          error: validationResult.errorMessage,
          status: OrderProcessingStatus.validationFailed,
        );
      }

      // Check inventory
      final inventoryResult = await _checkInventoryAvailability(order);
      if (!inventoryResult.isAvailable) {
        return OrderProcessingResult(
          success: false,
          orderId: order.orderId,
          error: inventoryResult.errorMessage,
          status: OrderProcessingStatus.insufficientInventory,
          unavailableItems: inventoryResult.unavailableItems,
        );
      }

      // Add to queue
      final queueItem = OrderQueueItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        order: order,
        status: OrderQueueStatus.pending,
        priority: _calculateOrderPriority(order),
        addedAt: DateTime.now(),
        estimatedProcessingTime: _calculateEstimatedProcessingTime(order),
      );

      _orderQueue.add(queueItem);
      _queueController.add(_orderQueue);

      _emitEvent(OrderProcessingEvent(
        type: OrderEventType.orderQueued,
        orderId: order.orderId,
        message: 'Order added to processing queue',
        timestamp: DateTime.now(),
      ));

      return OrderProcessingResult(
        success: true,
        orderId: order.orderId,
        status: OrderProcessingStatus.queued,
        estimatedProcessingTime: queueItem.estimatedProcessingTime,
      );
    } catch (e) {
      return OrderProcessingResult(
        success: false,
        orderId: order.orderId,
        error: 'Failed to add order to queue: ${e.toString()}',
        status: OrderProcessingStatus.error,
      );
    }
  }

  /// Process order queue
  Future<void> _processOrderQueue() async {
    if (_orderQueue.isEmpty) return;

    // Sort by priority
    _orderQueue.sort((a, b) => b.priority.compareTo(a.priority));

    // Process orders one by one
    for (final queueItem in List.from(_orderQueue)) {
      if (queueItem.status == OrderQueueStatus.pending) {
        await _processOrder(queueItem);
      }
    }
  }

  /// Process individual order
  Future<void> _processOrder(OrderQueueItem queueItem) async {
    try {
      // Update status to processing
      queueItem = queueItem.copyWith(status: OrderQueueStatus.processing);
      _queueController.add(_orderQueue);

      _emitEvent(OrderProcessingEvent(
        type: OrderEventType.orderProcessingStarted,
        orderId: queueItem.order.orderId,
        message: 'Order processing started',
        timestamp: DateTime.now(),
      ));

      // Step 1: Reserve inventory
      final reservationResult = await _reserveInventory(queueItem.order);
      if (!reservationResult.success) {
        await _handleOrderFailure(queueItem, reservationResult.error ?? 'Inventory reservation failed');
        return;
      }

      // Step 2: Process payment
      final paymentResult = await _processPayment(queueItem.order);
      if (!paymentResult.success) {
        await _releaseInventory(queueItem.order);
        await _handleOrderFailure(queueItem, paymentResult.error ?? 'Payment processing failed');
        return;
      }

      // Step 3: Confirm order
      final confirmationResult = await _confirmOrder(queueItem.order);
      if (!confirmationResult.success) {
        await _refundPayment(queueItem.order);
        await _releaseInventory(queueItem.order);
        await _handleOrderFailure(queueItem, confirmationResult.error ?? 'Order confirmation failed');
        return;
      }

      // Step 4: Schedule shipment
      final shipmentResult = await _scheduleShipment(queueItem.order);
      if (!shipmentResult.success) {
        // Order is confirmed but shipment scheduling failed - mark for manual review
        queueItem = queueItem.copyWith(
          status: OrderQueueStatus.manualReview,
          notes: 'Order confirmed but shipment scheduling failed',
        );
        _queueController.add(_orderQueue);
        
        _emitEvent(OrderProcessingEvent(
          type: OrderEventType.orderRequiresManualReview,
          orderId: queueItem.order.orderId,
          message: 'Order requires manual review for shipment',
          timestamp: DateTime.now(),
        ));
        
        await _updateMetrics(queueItem, true);
        return;
      }

      // Order successfully processed
      queueItem = queueItem.copyWith(
        status: OrderQueueStatus.completed,
        completedAt: DateTime.now(),
      );
      _queueController.add(_orderQueue);

      _emitEvent(OrderProcessingEvent(
        type: OrderEventType.orderCompleted,
        orderId: queueItem.order.orderId,
        message: 'Order processed successfully',
        timestamp: DateTime.now(),
      ));

      await _updateMetrics(queueItem, true);

      // Remove from queue after completion
      _orderQueue.removeWhere((item) => item.id == queueItem.id);
      _queueController.add(_orderQueue);
    } catch (e) {
      await _handleOrderFailure(queueItem, 'Order processing error: ${e.toString()}');
    }
  }

  /// Validate order
  Future<OrderValidationResult> _validateOrder(SalesOrder order) async {
    // Check if order has items
    if (order.items.isEmpty) {
      return OrderValidationResult(
        isValid: false,
        errorMessage: 'Order has no items',
      );
    }

    // Check if retailer is valid
    if (order.retailerId.isEmpty) {
      return OrderValidationResult(
        isValid: false,
        errorMessage: 'Invalid retailer ID',
      );
    }

    // Check if delivery address is valid
    if (order.deliveryAddress.isEmpty) {
      return OrderValidationResult(
        isValid: false,
        errorMessage: 'Invalid delivery address',
      );
    }

    // Validate item quantities
    for (final item in order.items) {
      if (item.quantity <= 0) {
        return OrderValidationResult(
          isValid: false,
          errorMessage: 'Invalid quantity for item ${item.productName}',
        );
      }
    }

    // Check minimum order value
    final orderValue = order.items.fold<double>(0.0, (sum, item) => sum + item.totalPrice);
    if (orderValue < 1000) {
      return OrderValidationResult(
        isValid: false,
        errorMessage: 'Order value below minimum (NPR 1,000)',
      );
    }

    return OrderValidationResult(isValid: true);
  }

  /// Check inventory availability
  Future<InventoryCheckResult> _checkInventoryAvailability(SalesOrder order) async {
    try {
      final unavailableItems = <String>[];

      for (final item in order.items) {
        final response = await _dio.get('/api/inventory/check/${item.sku}');
        
        if (response.statusCode == 200) {
          final availableStock = response.data['available_stock'] as int;
          if (availableStock < item.quantity) {
            unavailableItems.add(item.productName);
          }
        } else {
          unavailableItems.add(item.productName);
        }
      }

      if (unavailableItems.isNotEmpty) {
        return InventoryCheckResult(
          isAvailable: false,
          errorMessage: 'Insufficient inventory for: ${unavailableItems.join(", ")}',
          unavailableItems: unavailableItems,
        );
      }

      return InventoryCheckResult(isAvailable: true);
    } catch (e) {
      return InventoryCheckResult(
        isAvailable: false,
        errorMessage: 'Inventory check failed: ${e.toString()}',
      );
    }
  }

  /// Reserve inventory
  Future<OperationResult> _reserveInventory(SalesOrder order) async {
    try {
      final response = await _dio.post(
        '/api/inventory/reserve',
        data: {
          'order_id': order.orderId,
          'items': order.items.map((item) => {
            'sku': item.sku,
            'quantity': item.quantity,
          }).toList(),
        },
      );

      if (response.statusCode == 200) {
        return OperationResult(success: true);
      }

      return OperationResult(
        success: false,
        error: response.data['message'] ?? 'Inventory reservation failed',
      );
    } catch (e) {
      return OperationResult(
        success: false,
        error: 'Inventory reservation error: ${e.toString()}',
      );
    }
  }

  /// Release inventory
  Future<void> _releaseInventory(SalesOrder order) async {
    try {
      await _dio.post(
        '/api/inventory/release',
        data: {
          'order_id': order.orderId,
        },
      );
    } catch (e) {
      debugPrint('Error releasing inventory: $e');
    }
  }

  /// Process payment
  Future<OperationResult> _processPayment(SalesOrder order) async {
    try {
      final response = await _dio.post(
        '/api/payments/process',
        data: {
          'order_id': order.orderId,
          'amount': order.totalAmount,
          'payment_method': order.paymentMethod,
          'retailer_id': order.retailerId,
        },
      );

      if (response.statusCode == 200) {
        return OperationResult(success: true);
      }

      return OperationResult(
        success: false,
        error: response.data['message'] ?? 'Payment processing failed',
      );
    } catch (e) {
      return OperationResult(
        success: false,
        error: 'Payment processing error: ${e.toString()}',
      );
    }
  }

  /// Refund payment
  Future<void> _refundPayment(SalesOrder order) async {
    try {
      await _dio.post(
        '/api/payments/refund',
        data: {
          'order_id': order.orderId,
        },
      );
    } catch (e) {
      debugPrint('Error refunding payment: $e');
    }
  }

  /// Confirm order
  Future<OperationResult> _confirmOrder(SalesOrder order) async {
    try {
      final response = await _dio.post(
        '/api/orders/confirm',
        data: {
          'order_id': order.orderId,
          'retailer_id': order.retailerId,
        },
      );

      if (response.statusCode == 200) {
        return OperationResult(success: true);
      }

      return OperationResult(
        success: false,
        error: response.data['message'] ?? 'Order confirmation failed',
      );
    } catch (e) {
      return OperationResult(
        success: false,
        error: 'Order confirmation error: ${e.toString()}',
      );
    }
  }

  /// Schedule shipment
  Future<OperationResult> _scheduleShipment(SalesOrder order) async {
    try {
      final response = await _dio.post(
        '/api/shipments/schedule',
        data: {
          'order_id': order.orderId,
          'delivery_address': order.deliveryAddress,
          'preferred_delivery_date': order.preferredDeliveryDate?.toIso8601String(),
        },
      );

      if (response.statusCode == 200) {
        return OperationResult(success: true);
      }

      return OperationResult(
        success: false,
        error: response.data['message'] ?? 'Shipment scheduling failed',
      );
    } catch (e) {
      return OperationResult(
        success: false,
        error: 'Shipment scheduling error: ${e.toString()}',
      );
    }
  }

  /// Handle order failure
  Future<void> _handleOrderFailure(OrderQueueItem queueItem, String errorMessage) async {
    queueItem = queueItem.copyWith(
      status: OrderQueueStatus.failed,
      errorMessage: errorMessage,
      failedAt: DateTime.now(),
    );
    _queueController.add(_orderQueue);

    _emitEvent(OrderProcessingEvent(
      type: OrderEventType.orderFailed,
      orderId: queueItem.order.orderId,
      message: errorMessage,
      timestamp: DateTime.now(),
    ));

    await _updateMetrics(queueItem, false);
  }

  /// Calculate order priority
  int _calculateOrderPriority(SalesOrder order) {
    var priority = 5; // Default priority

    // High value orders get higher priority
    if (order.totalAmount > 50000) priority += 3;
    if (order.totalAmount > 20000) priority += 2;

    // Urgent delivery gets higher priority
    if (order.isUrgent) priority += 4;

    // Regular customers get higher priority
    if (order.isRegularCustomer) priority += 2;

    return priority.clamp(1, 10);
  }

  /// Calculate estimated processing time
  Duration _calculateEstimatedProcessingTime(SalesOrder order) {
    // Base time: 5 minutes
    var minutes = 5;

    // Add time for each item
    minutes += order.items.length * 2;

    // Add time for high value orders
    if (order.totalAmount > 50000) minutes += 5;

    // Add time for urgent orders
    if (order.isUrgent) minutes -= 2; // Urgent orders are processed faster

    return Duration(minutes: minutes.clamp(5, 60));
  }

  /// Update processing metrics
  Future<void> _updateMetrics(OrderQueueItem queueItem, bool success) async {
    _metrics = OrderProcessingMetrics(
      totalOrdersProcessed: _metrics.totalOrdersProcessed + 1,
      successfulOrders: success ? _metrics.successfulOrders + 1 : _metrics.successfulOrders,
      failedOrders: success ? _metrics.failedOrders : _metrics.failedOrders + 1,
      averageProcessingTime: _calculateAverageProcessingTime(),
      ordersInQueue: _orderQueue.length,
      lastUpdated: DateTime.now(),
    );
    _metricsController.add(_metrics);
  }

  Duration _calculateAverageProcessingTime() {
    final completedOrders = _orderQueue.where((item) => item.status == OrderQueueStatus.completed);
    if (completedOrders.isEmpty) return Duration.zero;

    final totalDuration = completedOrders.fold<Duration>(
      Duration.zero,
      (sum, item) => sum + (item.completedAt?.difference(item.addedAt) ?? Duration.zero),
    );

    return Duration(
      microseconds: (totalDuration.inMicroseconds / completedOrders.length).round(),
    );
  }

  /// Emit processing event
  void _emitEvent(OrderProcessingEvent event) {
    _eventsController.add(event);
  }

  /// Get order queue by status
  List<OrderQueueItem> getQueueByStatus(OrderQueueStatus status) {
    return _orderQueue.where((item) => item.status == status).toList();
  }

  /// Cancel order in queue
  Future<bool> cancelOrder(String orderId) async {
    try {
      final queueItem = _orderQueue.firstWhere((item) => item.order.orderId == orderId);
      
      if (queueItem.status == OrderQueueStatus.processing) {
        // Cannot cancel processing orders
        return false;
      }

      // Release inventory if reserved
      if (queueItem.status == OrderQueueStatus.pending) {
        await _releaseInventory(queueItem.order);
      }

      _orderQueue.removeWhere((item) => item.order.orderId == orderId);
      _queueController.add(_orderQueue);

      _emitEvent(OrderProcessingEvent(
        type: OrderEventType.orderCancelled,
        orderId: orderId,
        message: 'Order cancelled',
        timestamp: DateTime.now(),
      ));

      return true;
    } catch (e) {
      return false;
    }
  }

  void dispose() {
    _processingTimer?.cancel();
    _eventsController.close();
    _queueController.close();
    _metricsController.close();
  }
}

// Order Queue Status Enum
enum OrderQueueStatus {
  pending,
  processing,
  completed,
  failed,
  manualReview,
}

// Order Processing Status Enum
enum OrderProcessingStatus {
  queued,
  processing,
  completed,
  validationFailed,
  insufficientInventory,
  paymentFailed,
  error,
}

// Order Event Type Enum
enum OrderEventType {
  orderQueued,
  orderProcessingStarted,
  orderCompleted,
  orderFailed,
  orderCancelled,
  orderRequiresManualReview,
}

// Order Queue Item Model
class OrderQueueItem {
  final String id;
  final SalesOrder order;
  final OrderQueueStatus status;
  final int priority;
  final DateTime addedAt;
  final Duration estimatedProcessingTime;
  final DateTime? completedAt;
  final DateTime? failedAt;
  final String? errorMessage;
  final String? notes;

  const OrderQueueItem({
    required this.id,
    required this.order,
    required this.status,
    required this.priority,
    required this.addedAt,
    required this.estimatedProcessingTime,
    this.completedAt,
    this.failedAt,
    this.errorMessage,
    this.notes,
  });

  OrderQueueItem copyWith({
    OrderQueueStatus? status,
    DateTime? completedAt,
    DateTime? failedAt,
    String? errorMessage,
    String? notes,
  }) {
    return OrderQueueItem(
      id: id,
      order: order,
      status: status ?? this.status,
      priority: priority,
      addedAt: addedAt,
      estimatedProcessingTime: estimatedProcessingTime,
      completedAt: completedAt ?? this.completedAt,
      failedAt: failedAt ?? this.failedAt,
      errorMessage: errorMessage ?? this.errorMessage,
      notes: notes ?? this.notes,
    );
  }
}

// Order Processing Event Model
class OrderProcessingEvent {
  final OrderEventType type;
  final String orderId;
  final String message;
  final DateTime timestamp;

  const OrderProcessingEvent({
    required this.type,
    required this.orderId,
    required this.message,
    required this.timestamp,
  });
}

// Order Processing Metrics Model
class OrderProcessingMetrics {
  final int totalOrdersProcessed;
  final int successfulOrders;
  final int failedOrders;
  final Duration averageProcessingTime;
  final int ordersInQueue;
  final DateTime lastUpdated;

  const OrderProcessingMetrics({
    this.totalOrdersProcessed = 0,
    this.successfulOrders = 0,
    this.failedOrders = 0,
    this.averageProcessingTime = Duration.zero,
    this.ordersInQueue = 0,
    required this.lastUpdated,
  });
}

// Order Processing Result Model
class OrderProcessingResult {
  final bool success;
  final String orderId;
  final String? error;
  final OrderProcessingStatus status;
  final Duration? estimatedProcessingTime;
  final List<String>? unavailableItems;

  const OrderProcessingResult({
    required this.success,
    required this.orderId,
    this.error,
    required this.status,
    this.estimatedProcessingTime,
    this.unavailableItems,
  });
}

// Order Validation Result Model
class OrderValidationResult {
  final bool isValid;
  final String? errorMessage;

  const OrderValidationResult({
    required this.isValid,
    this.errorMessage,
  });
}

// Inventory Check Result Model
class InventoryCheckResult {
  final bool isAvailable;
  final String? errorMessage;
  final List<String>? unavailableItems;

  const InventoryCheckResult({
    required this.isAvailable,
    this.errorMessage,
    this.unavailableItems,
  });
}

// Operation Result Model
class OperationResult {
  final bool success;
  final String? error;

  const OperationResult({
    required this.success,
    this.error,
  });
}
