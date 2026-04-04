import 'package:vedanta_trade/core/constants/app_constants.dart';
import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Order management service for real-time order lifecycle
class OrderManagementService {
  static final OrderManagementService _instance = OrderManagementService._internal();
  factory OrderManagementService() => _instance;
  OrderManagementService._internal();

  final StreamController<List<Order>> _ordersController = 
      StreamController<List<Order>>.broadcast();
  final StreamController<Order> _orderUpdateController = 
      StreamController<Order>.broadcast();
  final StreamController<List<StockAlert>> _stockAlertsController = 
      StreamController<List<StockAlert>>.broadcast();
  
  late Dio _dio;
  List<Order> _orders = [];
  List<StockAlert> _stockAlerts = [];
  Timer? _realtimeTimer;
  String? _currentStockistId;
  
  Stream<List<Order>> get ordersStream => _ordersController.stream;
  Stream<Order> get orderUpdateStream => _orderUpdateController.stream;
  Stream<List<StockAlert>> get stockAlertsStream => _stockAlertsController.stream;
  List<Order> get orders => List.unmodifiable(_orders);
  List<StockAlert> get stockAlerts => List.unmodifiable(_stockAlerts);

  /// Initialize order management service
  Future<void> initialize({String? stockistId}) async {
    try {

      _currentStockistId = stockistId;
      
      // Setup Dio client
      _setupDioClient();
      
      // Load cached orders
      await _loadCachedOrders();
      
      // Load cached stock alerts
      await _loadCachedStockAlerts();
      
      // Start real-time updates
      _startRealtimeUpdates();

    } catch (e) {
      
      _ordersController.addError(e);
    }
  }

  /// Setup Dio client with Nepal-specific configurations
  void _setupDioClient() {
    _dio = Dio(BaseOptions(
      baseUrl: 'AppConstants.apiBaseUrl',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'X-Country': 'NP',
        'X-Currency': 'NPR',
        'X-Timezone': 'Asia/Kathmandu',
      },
    ));

    // Add request interceptor for authentication
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('auth_token');
          
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          
          handler.next(options);
        },
        onError: (error, handler) async {
          
          handler.next(error);
        },
      ),
    );
  }

  /// Load cached orders from storage
  Future<void> _loadCachedOrders() async {
    try {

      final prefs = await SharedPreferences.getInstance();
      final ordersJson = prefs.getString('cached_orders');
      
      if (ordersJson != null) {
        final ordersList = List<Map<String, dynamic>>.from(
          jsonDecode(ordersJson)
        );
        
        _orders = ordersList
            .map((json) => Order.fromJson(json))
            .toList();
        
        _ordersController.add(_orders);
        
      }
      
    } catch (e) {
      
    }
  }

  /// Load cached stock alerts from storage
  Future<void> _loadCachedStockAlerts() async {
    try {

      final prefs = await SharedPreferences.getInstance();
      final alertsJson = prefs.getString('cached_stock_alerts');
      
      if (alertsJson != null) {
        final alertsList = List<Map<String, dynamic>>.from(
          jsonDecode(alertsJson)
        );
        
        _stockAlerts = alertsList
            .map((json) => StockAlert.fromJson(json))
            .toList();
        
        _stockAlertsController.add(_stockAlerts);
        
      }
      
    } catch (e) {
      
    }
  }

  /// Start real-time updates
  void _startRealtimeUpdates() {

    _realtimeTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _fetchOrdersFromServer();
      _fetchStockAlertsFromServer();
    });

  }

  /// Fetch orders from server
  Future<void> _fetchOrdersFromServer() async {
    try {
      if (_currentStockistId == null) return;

      final response = await _dio.get(
        '/api/orders/stockist/$_currentStockistId',
      );
      
      if (response.statusCode == 200) {
        final ordersData = response.data['orders'] as List;
        final newOrders = ordersData
            .map((json) => Order.fromJson(json))
            .toList();
        
        // Check for updates
        _checkForOrderUpdates(newOrders);
        
        _orders = newOrders;
        _ordersController.add(_orders);
        
        // Cache orders
        await _cacheOrders();

      }
      
    } catch (e) {
      
    }
  }

  /// Fetch stock alerts from server
  Future<void> _fetchStockAlertsFromServer() async {
    try {
      if (_currentStockistId == null) return;

      final response = await _dio.get(
        '/api/stock/alerts/stockist/$_currentStockistId',
      );
      
      if (response.statusCode == 200) {
        final alertsData = response.data['alerts'] as List;
        final newAlerts = alertsData
            .map((json) => StockAlert.fromJson(json))
            .toList();
        
        _stockAlerts = newAlerts;
        _stockAlertsController.add(_stockAlerts);
        
        // Cache alerts
        await _cacheStockAlerts();

      }
      
    } catch (e) {
      
    }
  }

  /// Check for order updates
  void _checkForOrderUpdates(List<Order> newOrders) {
    for (final newOrder in newOrders) {
      final existingOrder = _orders.firstWhere(
        (order) => order.id == newOrder.id,
        orElse: () => null,
      );
      
      if (existingOrder != null && existingOrder.status != newOrder.status) {
        
        _orderUpdateController.add(newOrder);
      }
    }
  }

  /// Create new order
  Future<Order?> createOrder(CreateOrderRequest request) async {
    try {

      final response = await _dio.post(
        '/api/orders',
        data: request.toJson(),
      );
      
      if (response.statusCode == 201) {
        final orderData = response.data['order'];
        final newOrder = Order.fromJson(orderData);
        
        _orders.insert(0, newOrder);
        _ordersController.add(_orders);
        
        // Cache updated orders
        await _cacheOrders();

        return newOrder;
      }
      
    } catch (e) {
      
      throw Exception('Failed to create order: $e');
    }
    
    return null;
  }

  /// Update order status
  Future<bool> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    try {

      final response = await _dio.put(
        '/api/orders/$orderId/status',
        data: {'status': newStatus.toString()},
      );
      
      if (response.statusCode == 200) {
        final orderIndex = _orders.indexWhere((order) => order.id == orderId);
        if (orderIndex != -1) {
          _orders[orderIndex] = _orders[orderIndex].copyWith(status: newStatus);
          _ordersController.add(_orders);
          
          // Emit update
          _orderUpdateController.add(_orders[orderIndex]);
          
          // Cache updated orders
          await _cacheOrders();

          return true;
        }
      }
      
    } catch (e) {
      
      throw Exception('Failed to update order status: $e');
    }
    
    return false;
  }

  /// Process payment for order
  Future<bool> processPayment(String orderId, PaymentRequest paymentRequest) async {
    try {

      final response = await _dio.post(
        '/api/orders/$orderId/payment',
        data: paymentRequest.toJson(),
      );
      
      if (response.statusCode == 200) {
        final orderIndex = _orders.indexWhere((order) => order.id == orderId);
        if (orderIndex != -1) {
          _orders[orderIndex] = _orders[orderIndex].copyWith(
            status: OrderStatus.paid,
            paymentStatus: PaymentStatus.paid,
          );
          _ordersController.add(_orders);
          
          // Emit update
          _orderUpdateController.add(_orders[orderIndex]);
          
          // Cache updated orders
          await _cacheOrders();

          return true;
        }
      }
      
    } catch (e) {
      
      throw Exception('Failed to process payment: $e');
    }
    
    return false;
  }

  /// Get orders by status
  List<Order> getOrdersByStatus(OrderStatus status) {
    return _orders.where((order) => order.status == status).toList();
  }

  /// Get orders by date range
  List<Order> getOrdersByDateRange(DateTime startDate, DateTime endDate) {
    return _orders.where((order) {
      return order.createdAt.isAfter(startDate) && order.createdAt.isBefore(endDate);
    }).toList();
  }

  /// Get pending orders
  List<Order> getPendingOrders() {
    return getOrdersByStatus(OrderStatus.pending);
  }

  /// Get approved orders
  List<Order> getApprovedOrders() {
    return getOrdersByStatus(OrderStatus.approved);
  }

  /// Get dispatched orders
  List<Order> getDispatchedOrders() {
    return getOrdersByStatus(OrderStatus.dispatched);
  }

  /// Get paid orders
  List<Order> getPaidOrders() {
    return getOrdersByStatus(OrderStatus.paid);
  }

  /// Get critical stock alerts
  List<StockAlert> getCriticalStockAlerts() {
    return _stockAlerts.where((alert) => alert.severity == StockAlertSeverity.critical).toList();
  }

  /// Get low stock alerts
  List<StockAlert> getLowStockAlerts() {
    return _stockAlerts.where((alert) => alert.severity == StockAlertSeverity.low).toList();
  }

  /// Cache orders to storage
  Future<void> _cacheOrders() async {
    try {

      final prefs = await SharedPreferences.getInstance();
      final ordersJson = jsonEncode(
        _orders.map((order) => order.toJson()).toList(),
      );
      
      await prefs.setString('cached_orders', ordersJson);
      await prefs.setString('last_orders_update', DateTime.now().toIso8601String());

    } catch (e) {
      
    }
  }

  /// Cache stock alerts to storage
  Future<void> _cacheStockAlerts() async {
    try {

      final prefs = await SharedPreferences.getInstance();
      final alertsJson = jsonEncode(
        _stockAlerts.map((alert) => alert.toJson()).toList(),
      );
      
      await prefs.setString('cached_stock_alerts', alertsJson);
      await prefs.setString('last_alerts_update', DateTime.now().toIso8601String());

    } catch (e) {
      
    }
  }

  /// Clear cached data
  Future<void> clearCache() async {
    try {

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('cached_orders');
      await prefs.remove('cached_stock_alerts');
      await prefs.remove('last_orders_update');
      await prefs.remove('last_alerts_update');
      
      _orders.clear();
      _stockAlerts.clear();
      
      _ordersController.add(_orders);
      _stockAlertsController.add(_stockAlerts);

    } catch (e) {
      
    }
  }

  /// Dispose resources
  void dispose() {

    _realtimeTimer?.cancel();
    _ordersController.close();
    _orderUpdateController.close();
    _stockAlertsController.close();

  }
}

/// Order model
class Order {
  final String id;
  final String retailerId;
  final String retailerName;
  final String retailerAddress;
  final List<OrderItem> items;
  final double totalAmount;
  final double vatAmount; // 13% VAT for Nepal
  final double finalAmount;
  final OrderStatus status;
  final PaymentStatus paymentStatus;
  final DateTime createdAt;
  final DateTime? approvedAt;
  final DateTime? dispatchedAt;
  final DateTime? paidAt;
  final String? notes;
  
  Order({
    required this.id,
    required this.retailerId,
    required this.retailerName,
    required this.retailerAddress,
    required this.items,
    required this.totalAmount,
    required this.vatAmount,
    required this.finalAmount,
    required this.status,
    required this.paymentStatus,
    required this.createdAt,
    this.approvedAt,
    this.dispatchedAt,
    this.paidAt,
    this.notes,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      retailerId: json['retailerId'] as String,
      retailerName: json['retailerName'] as String,
      retailerAddress: json['retailerAddress'] as String,
      items: (json['items'] as List)
          .map((item) => OrderItem.fromJson(item))
          .toList(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      vatAmount: (json['vatAmount'] as num).toDouble(),
      finalAmount: (json['finalAmount'] as num).toDouble(),
      status: OrderStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => OrderStatus.pending,
      ),
      paymentStatus: PaymentStatus.values.firstWhere(
        (e) => e.toString() == json['paymentStatus'],
        orElse: () => PaymentStatus.pending,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      approvedAt: json['approvedAt'] != null
          ? DateTime.parse(json['approvedAt'] as String)
          : null,
      dispatchedAt: json['dispatchedAt'] != null
          ? DateTime.parse(json['dispatchedAt'] as String)
          : null,
      paidAt: json['paidAt'] != null
          ? DateTime.parse(json['paidAt'] as String)
          : null,
      notes: json['notes'] as String?,
    );
  }

  Order copyWith({
    String? id,
    String? retailerId,
    String? retailerName,
    String? retailerAddress,
    List<OrderItem>? items,
    double? totalAmount,
    double? vatAmount,
    double? finalAmount,
    OrderStatus? status,
    PaymentStatus? paymentStatus,
    DateTime? createdAt,
    DateTime? approvedAt,
    DateTime? dispatchedAt,
    DateTime? paidAt,
    String? notes,
  }) {
    return Order(
      id: id ?? this.id,
      retailerId: retailerId ?? this.retailerId,
      retailerName: retailerName ?? this.retailerName,
      retailerAddress: retailerAddress ?? this.retailerAddress,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      vatAmount: vatAmount ?? this.vatAmount,
      finalAmount: finalAmount ?? this.finalAmount,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      createdAt: createdAt ?? this.createdAt,
      approvedAt: approvedAt ?? this.approvedAt,
      dispatchedAt: dispatchedAt ?? this.dispatchedAt,
      paidAt: paidAt ?? this.paidAt,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'retailerId': retailerId,
      'retailerName': retailerName,
      'retailerAddress': retailerAddress,
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'vatAmount': vatAmount,
      'finalAmount': finalAmount,
      'status': status.toString(),
      'paymentStatus': paymentStatus.toString(),
      'createdAt': createdAt.toIso8601String(),
      'approvedAt': approvedAt?.toIso8601String(),
      'dispatchedAt': dispatchedAt?.toIso8601String(),
      'paidAt': paidAt?.toIso8601String(),
      'notes': notes,
    };
  }
}

/// Order item model
class OrderItem {
  final String sku;
  final String productName;
  final String brand;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final String? batchNumber;
  final DateTime? expiryDate;
  
  OrderItem({
    required this.sku,
    required this.productName,
    required this.brand,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.batchNumber,
    this.expiryDate,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      sku: json['sku'] as String,
      productName: json['productName'] as String,
      brand: json['brand'] as String,
      quantity: json['quantity'] as int,
      unitPrice: (json['unitPrice'] as num).toDouble(),
      totalPrice: (json['totalPrice'] as num).toDouble(),
      batchNumber: json['batchNumber'] as String?,
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sku': sku,
      'productName': productName,
      'brand': brand,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
      'batchNumber': batchNumber,
      'expiryDate': expiryDate?.toIso8601String(),
    };
  }
}

/// Create order request model
class CreateOrderRequest {
  final String retailerId;
  final List<OrderItem> items;
  final String? notes;
  
  CreateOrderRequest({
    required this.retailerId,
    required this.items,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'retailerId': retailerId,
      'items': items.map((item) => item.toJson()).toList(),
      'notes': notes,
    };
  }
}

/// Payment request model
class PaymentRequest {
  final String method;
  final String? transactionId;
  final String? bankReference;
  final double amount;
  final String? notes;
  
  PaymentRequest({
    required this.method,
    this.transactionId,
    this.bankReference,
    required this.amount,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'method': method,
      'transactionId': transactionId,
      'bankReference': bankReference,
      'amount': amount,
      'notes': notes,
    };
  }
}

/// Stock alert model
class StockAlert {
  final String id;
  final String sku;
  final String productName;
  final String brand;
  final int currentStock;
  final int minStock;
  final int maxStock;
  final StockAlertSeverity severity;
  final DateTime createdAt;
  final String? notes;
  
  StockAlert({
    required this.id,
    required this.sku,
    required this.productName,
    required this.brand,
    required this.currentStock,
    required this.minStock,
    required this.maxStock,
    required this.severity,
    required this.createdAt,
    this.notes,
  });

  factory StockAlert.fromJson(Map<String, dynamic> json) {
    return StockAlert(
      id: json['id'] as String,
      sku: json['sku'] as String,
      productName: json['productName'] as String,
      brand: json['brand'] as String,
      currentStock: json['currentStock'] as int,
      minStock: json['minStock'] as int,
      maxStock: json['maxStock'] as int,
      severity: StockAlertSeverity.values.firstWhere(
        (e) => e.toString() == json['severity'],
        orElse: () => StockAlertSeverity.low,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sku': sku,
      'productName': productName,
      'brand': brand,
      'currentStock': currentStock,
      'minStock': minStock,
      'maxStock': maxStock,
      'severity': severity.toString(),
      'createdAt': createdAt.toIso8601String(),
      'notes': notes,
    };
  }
}

/// Order status enum
enum OrderStatus {
  pending,
  approved,
  dispatched,
  delivered,
  cancelled,
  paid,
}

/// Payment status enum
enum PaymentStatus {
  pending,
  paid,
  failed,
  refunded,
}

/// Stock alert severity enum
enum StockAlertSeverity {
  critical,
  low,
  normal,
}
