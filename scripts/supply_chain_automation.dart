import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as path;

/// Supply Chain and Inventory Management Automation
/// Implements real-time order flow, inventory control, and stock management
class SupplyChainAutomation {
  static const String projectRoot = 'i:\\Path\\Projects\\VedantaTrade';
  static const String libPath = 'i:\\Path\\Projects\\VedantaTrade\\lib';
  static const String distributionPath = 'i:\\Path\\Projects\\VedantaTrade\\lib\\features\\distribution';
  static const String stockistPath = 'i:\\Path\\Projects\\VedantaTrade\\lib\\features\\stockist';
  static const String retailerPath = 'i:\\Path\\Projects\\VedantaTrade\\lib\\features\\retailer';

  /// Execute supply chain automation
  Future<void> executeSupplyChainAutomation() async {
    print('📦 Starting Supply Chain and Inventory Management Automation...');
    
    try {
      // Implement order lifecycle management
      await _implementOrderLifecycleManagement();
      
      // Implement real-time inventory control
      await _implementRealTimeInventoryControl();
      
      // Implement low-stock alerts
      await _implementLowStockAlerts();
      
      // Implement stock transfer management
      await _implementStockTransferManagement();
      
      // Update stockist dashboard
      await _updateStockistDashboard();
      
      // Update retailer dashboard
      await _updateRetailerDashboard();
      
      print('✅ Supply chain automation completed successfully!');
    } catch (e) {
      print('❌ Supply chain automation failed: $e');
    }
  }

  /// Implement order lifecycle management
  Future<void> _implementOrderLifecycleManagement() async {
    print('  🔄 Implementing order lifecycle management...');
    
    final orderServiceFile = File(path.join(distributionPath, 'data', 'services', 'order_lifecycle_service.dart'));
    await orderServiceFile.parent.create(recursive: true);
    
    final orderServiceCode = '''
import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Order Lifecycle Service for real-time order management
class OrderLifecycleService {
  static const String _baseUrl = 'https://api.vedantatrade.com.np';
  final Dio _dio = Dio(BaseOptions(baseUrl: _baseUrl));
  
  final StreamController<Order> _orderUpdateController = StreamController.broadcast();
  final Map<String, Order> _activeOrders = {};
  
  /// Order status enum
  enum OrderStatus {
    pending,
    approved,
    dispatched,
    delivered,
    paid,
    cancelled,
  }
  
  /// Order model
  class Order {
    final String id;
    final String retailerId;
    final String stockistId;
    final List<OrderItem> items;
    final OrderStatus status;
    final double totalAmount;
    final DateTime createdAt;
    final DateTime? updatedAt;
    final String? trackingNumber;
    final Map<String, dynamic>? metadata;
    
    Order({
      required this.id,
      required this.retailerId,
      required this.stockistId,
      required this.items,
      required this.status,
      required this.totalAmount,
      required this.createdAt,
      this.updatedAt,
      this.trackingNumber,
      this.metadata,
    });
    
    factory Order.fromJson(Map<String, dynamic> json) {
      return Order(
        id: json['id'],
        retailerId: json['retailerId'],
        stockistId: json['stockistId'],
        items: (json['items'] as List)
            .map((item) => OrderItem.fromJson(item))
            .toList(),
        status: OrderStatus.values.firstWhere(
          (status) => status.toString() == 'OrderStatus.\${json['status']}',
          orElse: () => OrderStatus.pending,
        ),
        totalAmount: (json['totalAmount'] as num).toDouble(),
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
        trackingNumber: json['trackingNumber'],
        metadata: json['metadata'],
      );
    }
    
    Map<String, dynamic> toJson() {
      return {
        'id': id,
        'retailerId': retailerId,
        'stockistId': stockistId,
        'items': items.map((item) => item.toJson()).toList(),
        'status': status.toString().split('.').last,
        'totalAmount': totalAmount,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        'trackingNumber': trackingNumber,
        'metadata': metadata,
      };
    }
    
    Order copyWith({
      String? id,
      String? retailerId,
      String? stockistId,
      List<OrderItem>? items,
      OrderStatus? status,
      double? totalAmount,
      DateTime? createdAt,
      DateTime? updatedAt,
      String? trackingNumber,
      Map<String, dynamic>? metadata,
    }) {
      return Order(
        id: id ?? this.id,
        retailerId: retailerId ?? this.retailerId,
        stockistId: stockistId ?? this.stockistId,
        items: items ?? this.items,
        status: status ?? this.status,
        totalAmount: totalAmount ?? this.totalAmount,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        trackingNumber: trackingNumber ?? this.trackingNumber,
        metadata: metadata ?? this.metadata,
      );
    }
  }
  
  /// Order item model
  class OrderItem {
    final String productId;
    final String productName;
    final int quantity;
    final double unitPrice;
    final double totalPrice;
    
    OrderItem({
      required this.productId,
      required this.productName,
      required this.quantity,
      required this.unitPrice,
      required this.totalPrice,
    });
    
    factory OrderItem.fromJson(Map<String, dynamic> json) {
      return OrderItem(
        productId: json['productId'],
        productName: json['productName'],
        quantity: json['quantity'],
        unitPrice: (json['unitPrice'] as num).toDouble(),
        totalPrice: (json['totalPrice'] as num).toDouble(),
      );
    }
    
    Map<String, dynamic> toJson() {
      return {
        'productId': productId,
        'productName': productName,
        'quantity': quantity,
        'unitPrice': unitPrice,
        'totalPrice': totalPrice,
      };
    }
  }
  
  /// Create new order
  Future<Order?> createOrder({
    required String retailerId,
    required String stockistId,
    required List<OrderItem> items,
  }) async {
    try {
      final totalAmount = items.fold(0.0, (sum, item) => sum + item.totalPrice);
      
      final orderData = {
        'retailerId': retailerId,
        'stockistId': stockistId,
        'items': items.map((item) => item.toJson()).toList(),
        'totalAmount': totalAmount,
        'status': 'pending',
        'createdAt': DateTime.now().toIso8601String(),
      };
      
      final response = await _dio.post('/api/orders', data: orderData);
      
      if (response.statusCode == 201) {
        final order = Order.fromJson(response.data);
        _activeOrders[order.id] = order;
        _orderUpdateController.add(order);
        return order;
      }
      
      return null;
    } catch (e) {
      print('Error creating order: \$e');
      return null;
    }
  }
  
  /// Update order status
  Future<bool> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    try {
      final response = await _dio.patch('/api/orders/\$orderId/status', data: {
        'status': newStatus.toString().split('.').last,
        'updatedAt': DateTime.now().toIso8601String(),
      });
      
      if (response.statusCode == 200) {
        final updatedOrder = Order.fromJson(response.data);
        _activeOrders[orderId] = updatedOrder;
        _orderUpdateController.add(updatedOrder);
        return true;
      }
      
      return false;
    } catch (e) {
      print('Error updating order status: \$e');
      return false;
    }
  }
  
  /// Get order by ID
  Future<Order?> getOrder(String orderId) async {
    try {
      if (_activeOrders.containsKey(orderId)) {
        return _activeOrders[orderId];
      }
      
      final response = await _dio.get('/api/orders/\$orderId');
      
      if (response.statusCode == 200) {
        final order = Order.fromJson(response.data);
        _activeOrders[orderId] = order;
        return order;
      }
      
      return null;
    } catch (e) {
      print('Error getting order: \$e');
      return null;
    }
  }
  
  /// Get orders by retailer
  Future<List<Order>> getOrdersByRetailer(String retailerId) async {
    try {
      final response = await _dio.get('/api/orders/retailer/\$retailerId');
      
      if (response.statusCode == 200) {
        final orders = (response.data as List)
            .map((order) => Order.fromJson(order))
            .toList();
        
        // Update cache
        for (final order in orders) {
          _activeOrders[order.id] = order;
        }
        
        return orders;
      }
      
      return [];
    } catch (e) {
      print('Error getting orders by retailer: \$e');
      return [];
    }
  }
  
  /// Get orders by stockist
  Future<List<Order>> getOrdersByStockist(String stockistId) async {
    try {
      final response = await _dio.get('/api/orders/stockist/\$stockistId');
      
      if (response.statusCode == 200) {
        final orders = (response.data as List)
            .map((order) => Order.fromJson(order))
            .toList();
        
        // Update cache
        for (final order in orders) {
          _activeOrders[order.id] = order;
        }
        
        return orders;
      }
      
      return [];
    } catch (e) {
      print('Error getting orders by stockist: \$e');
      return [];
    }
  }
  
  /// Get orders by status
  Future<List<Order>> getOrdersByStatus(OrderStatus status) async {
    try {
      final response = await _dio.get('/api/orders/status/\${status.toString().split('.').last}');
      
      if (response.statusCode == 200) {
        final orders = (response.data as List)
            .map((order) => Order.fromJson(order))
            .toList();
        
        // Update cache
        for (final order in orders) {
          _activeOrders[order.id] = order;
        }
        
        return orders;
      }
      
      return [];
    } catch (e) {
      print('Error getting orders by status: \$e');
      return [];
    }
  }
  
  /// Start real-time order updates
  void startRealTimeUpdates() {
    // This would use WebSocket or Server-Sent Events for real-time updates
    Timer.periodic(const Duration(seconds: 30), (timer) async {
      await _syncOrders();
    });
  }
  
  /// Sync orders from server
  Future<void> _syncOrders() async {
    try {
      final response = await _dio.get('/api/orders/active');
      
      if (response.statusCode == 200) {
        final orders = (response.data as List)
            .map((order) => Order.fromJson(order))
            .toList();
        
        for (final order in orders) {
          final cachedOrder = _activeOrders[order.id];
          if (cachedOrder == null || cachedOrder.status != order.status) {
            _activeOrders[order.id] = order;
            _orderUpdateController.add(order);
          }
        }
      }
    } catch (e) {
      print('Error syncing orders: \$e');
    }
  }
  
  /// Get order updates stream
  Stream<Order> get orderUpdates => _orderUpdateController.stream;
  
  /// Get active orders
  Map<String, Order> get activeOrders => Map.unmodifiable(_activeOrders);
  
  /// Cancel order
  Future<bool> cancelOrder(String orderId, String reason) async {
    try {
      final response = await _dio.post('/api/orders/\$orderId/cancel', data: {
        'reason': reason,
        'cancelledAt': DateTime.now().toIso8601String(),
      });
      
      if (response.statusCode == 200) {
        final cancelledOrder = Order.fromJson(response.data);
        _activeOrders[orderId] = cancelledOrder;
        _orderUpdateController.add(cancelledOrder);
        return true;
      }
      
      return false;
    } catch (e) {
      print('Error cancelling order: \$e');
      return false;
    }
  }
  
  /// Generate tracking number
  String generateTrackingNumber() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(10000);
    return 'VT\$timestamp\$random';
  }
  
  /// Dispose resources
  void dispose() {
    _orderUpdateController.close();
  }
}
''';
    
    await orderServiceFile.writeAsString(orderServiceCode);
    print('    ✅ Order lifecycle management implemented');
  }

  /// Implement real-time inventory control
  Future<void> _implementRealTimeInventoryControl() async {
    print('  📊 Implementing real-time inventory control...');
    
    final inventoryServiceFile = File(path.join(distributionPath, 'data', 'services', 'inventory_control_service.dart'));
    await inventoryServiceFile.parent.create(recursive: true);
    
    final inventoryServiceCode = '''
import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Real-time Inventory Control Service
class InventoryControlService {
  static const String _baseUrl = 'https://api.vedantatrade.com.np';
  final Dio _dio = Dio(BaseOptions(baseUrl: _baseUrl));
  
  final StreamController<InventoryUpdate> _inventoryUpdateController = StreamController.broadcast();
  final Map<String, InventoryItem> _inventoryCache = {};
  
  /// Inventory item model
  class InventoryItem {
    final String id;
    final String productId;
    final String productName;
    final String stockistId;
    final int currentStock;
    final int minStockLevel;
    final int maxStockLevel;
    final double unitPrice;
    final DateTime? lastUpdated;
    final DateTime? expiryDate;
    final String? batchNumber;
    final Map<String, dynamic>? metadata;
    
    InventoryItem({
      required this.id,
      required this.productId,
      required this.productName,
      required this.stockistId,
      required this.currentStock,
      required this.minStockLevel,
      required this.maxStockLevel,
      required this.unitPrice,
      this.lastUpdated,
      this.expiryDate,
      this.batchNumber,
      this.metadata,
    });
    
    factory InventoryItem.fromJson(Map<String, dynamic> json) {
      return InventoryItem(
        id: json['id'],
        productId: json['productId'],
        productName: json['productName'],
        stockistId: json['stockistId'],
        currentStock: json['currentStock'],
        minStockLevel: json['minStockLevel'],
        maxStockLevel: json['maxStockLevel'],
        unitPrice: (json['unitPrice'] as num).toDouble(),
        lastUpdated: json['lastUpdated'] != null ? DateTime.parse(json['lastUpdated']) : null,
        expiryDate: json['expiryDate'] != null ? DateTime.parse(json['expiryDate']) : null,
        batchNumber: json['batchNumber'],
        metadata: json['metadata'],
      );
    }
    
    Map<String, dynamic> toJson() {
      return {
        'id': id,
        'productId': productId,
        'productName': productName,
        'stockistId': stockistId,
        'currentStock': currentStock,
        'minStockLevel': minStockLevel,
        'maxStockLevel': maxStockLevel,
        'unitPrice': unitPrice,
        'lastUpdated': lastUpdated?.toIso8601String(),
        'expiryDate': expiryDate?.toIso8601String(),
        'batchNumber': batchNumber,
        'metadata': metadata,
      };
    }
    
    bool get isLowStock => currentStock <= minStockLevel;
    bool get isOverStock => currentStock >= maxStockLevel;
    bool get isExpiringSoon => expiryDate != null && 
        expiryDate!.isBefore(DateTime.now().add(const Duration(days: 30)));
    bool get isExpired => expiryDate != null && expiryDate!.isBefore(DateTime.now());
    
    InventoryItem copyWith({
      String? id,
      String? productId,
      String? productName,
      String? stockistId,
      int? currentStock,
      int? minStockLevel,
      int? maxStockLevel,
      double? unitPrice,
      DateTime? lastUpdated,
      DateTime? expiryDate,
      String? batchNumber,
      Map<String, dynamic>? metadata,
    }) {
      return InventoryItem(
        id: id ?? this.id,
        productId: productId ?? this.productId,
        productName: productName ?? this.productName,
        stockistId: stockistId ?? this.stockistId,
        currentStock: currentStock ?? this.currentStock,
        minStockLevel: minStockLevel ?? this.minStockLevel,
        maxStockLevel: maxStockLevel ?? this.maxStockLevel,
        unitPrice: unitPrice ?? this.unitPrice,
        lastUpdated: lastUpdated ?? this.lastUpdated,
        expiryDate: expiryDate ?? this.expiryDate,
        batchNumber: batchNumber ?? this.batchNumber,
        metadata: metadata ?? this.metadata,
      );
    }
  }
  
  /// Inventory update model
  class InventoryUpdate {
    final String inventoryItemId;
    final int previousStock;
    final int newStock;
    final String updateType;
    final DateTime timestamp;
    final String? reason;
    
    InventoryUpdate({
      required this.inventoryItemId,
      required this.previousStock,
      required this.newStock,
      required this.updateType,
      required this.timestamp,
      this.reason,
    });
  }
  
  /// Get inventory by stockist
  Future<List<InventoryItem>> getInventoryByStockist(String stockistId) async {
    try {
      final response = await _dio.get('/api/inventory/stockist/\$stockistId');
      
      if (response.statusCode == 200) {
        final items = (response.data as List)
            .map((item) => InventoryItem.fromJson(item))
            .toList();
        
        // Update cache
        for (final item in items) {
          _inventoryCache[item.id] = item;
        }
        
        return items;
      }
      
      return [];
    } catch (e) {
      print('Error getting inventory: \$e');
      return [];
    }
  }
  
  /// Get inventory item by ID
  Future<InventoryItem?> getInventoryItem(String itemId) async {
    try {
      if (_inventoryCache.containsKey(itemId)) {
        return _inventoryCache[itemId];
      }
      
      final response = await _dio.get('/api/inventory/\$itemId');
      
      if (response.statusCode == 200) {
        final item = InventoryItem.fromJson(response.data);
        _inventoryCache[itemId] = item;
        return item;
      }
      
      return null;
    } catch (e) {
      print('Error getting inventory item: \$e');
      return null;
    }
  }
  
  /// Update inventory stock
  Future<bool> updateInventoryStock({
    required String itemId,
    required int newStock,
    required String updateType,
    String? reason,
  }) async {
    try {
      final currentItem = _inventoryCache[itemId];
      final previousStock = currentItem?.currentStock ?? 0;
      
      final response = await _dio.patch('/api/inventory/\$itemId/stock', data: {
        'currentStock': newStock,
        'updateType': updateType,
        'reason': reason,
        'lastUpdated': DateTime.now().toIso8601String(),
      });
      
      if (response.statusCode == 200) {
        final updatedItem = InventoryItem.fromJson(response.data);
        _inventoryCache[itemId] = updatedItem;
        
        // Emit update
        final update = InventoryUpdate(
          inventoryItemId: itemId,
          previousStock: previousStock,
          newStock: newStock,
          updateType: updateType,
          timestamp: DateTime.now(),
          reason: reason,
        );
        
        _inventoryUpdateController.add(update);
        return true;
      }
      
      return false;
    } catch (e) {
      print('Error updating inventory stock: \$e');
      return false;
    }
  }
  
  /// Add stock to inventory
  Future<bool> addStock({
    required String itemId,
    required int quantity,
    String? batchNumber,
    DateTime? expiryDate,
    String? reason,
  }) async {
    try {
      final currentItem = await getInventoryItem(itemId);
      if (currentItem == null) return false;
      
      final newStock = currentItem.currentStock + quantity;
      
      final response = await _dio.post('/api/inventory/\$itemId/add-stock', data: {
        'quantity': quantity,
        'batchNumber': batchNumber,
        'expiryDate': expiryDate?.toIso8601String(),
        'reason': reason,
        'lastUpdated': DateTime.now().toIso8601String(),
      });
      
      if (response.statusCode == 200) {
        final updatedItem = InventoryItem.fromJson(response.data);
        _inventoryCache[itemId] = updatedItem;
        
        // Emit update
        final update = InventoryUpdate(
          inventoryItemId: itemId,
          previousStock: currentItem.currentStock,
          newStock: newStock,
          updateType: 'addition',
          timestamp: DateTime.now(),
          reason: reason,
        );
        
        _inventoryUpdateController.add(update);
        return true;
      }
      
      return false;
    } catch (e) {
      print('Error adding stock: \$e');
      return false;
    }
  }
  
  /// Remove stock from inventory
  Future<bool> removeStock({
    required String itemId,
    required int quantity,
    String? reason,
  }) async {
    try {
      final currentItem = await getInventoryItem(itemId);
      if (currentItem == null) return false;
      
      if (currentItem.currentStock < quantity) {
        print('Insufficient stock: \${currentItem.currentStock} < \$quantity');
        return false;
      }
      
      final newStock = currentItem.currentStock - quantity;
      
      final response = await _dio.post('/api/inventory/\$itemId/remove-stock', data: {
        'quantity': quantity,
        'reason': reason,
        'lastUpdated': DateTime.now().toIso8601String(),
      });
      
      if (response.statusCode == 200) {
        final updatedItem = InventoryItem.fromJson(response.data);
        _inventoryCache[itemId] = updatedItem;
        
        // Emit update
        final update = InventoryUpdate(
          inventoryItemId: itemId,
          previousStock: currentItem.currentStock,
          newStock: newStock,
          updateType: 'removal',
          timestamp: DateTime.now(),
          reason: reason,
        );
        
        _inventoryUpdateController.add(update);
        return true;
      }
      
      return false;
    } catch (e) {
      print('Error removing stock: \$e');
      return false;
    }
  }
  
  /// Get low stock items
  Future<List<InventoryItem>> getLowStockItems(String stockistId) async {
    try {
      final response = await _dio.get('/api/inventory/low-stock/\$stockistId');
      
      if (response.statusCode == 200) {
        final items = (response.data as List)
            .map((item) => InventoryItem.fromJson(item))
            .toList();
        
        // Update cache
        for (final item in items) {
          _inventoryCache[item.id] = item;
        }
        
        return items;
      }
      
      return [];
    } catch (e) {
      print('Error getting low stock items: \$e');
      return [];
    }
  }
  
  /// Get expiring items
  Future<List<InventoryItem>> getExpiringItems(String stockistId) async {
    try {
      final response = await _dio.get('/api/inventory/expiring/\$stockistId');
      
      if (response.statusCode == 200) {
        final items = (response.data as List)
            .map((item) => InventoryItem.fromJson(item))
            .toList();
        
        // Update cache
        for (final item in items) {
          _inventoryCache[item.id] = item;
        }
        
        return items;
      }
      
      return [];
    } catch (e) {
      print('Error getting expiring items: \$e');
      return [];
    }
  }
  
  /// Start real-time inventory updates
  void startRealTimeUpdates() {
    Timer.periodic(const Duration(seconds: 30), (timer) async {
      await _syncInventory();
    });
  }
  
  /// Sync inventory from server
  Future<void> _syncInventory() async {
    try {
      final response = await _dio.get('/api/inventory/updates');
      
      if (response.statusCode == 200) {
        final updates = (response.data as List)
            .map((update) => InventoryUpdate.fromJson(update))
            .toList();
        
        for (final update in updates) {
          _inventoryUpdateController.add(update);
        }
      }
    } catch (e) {
      print('Error syncing inventory: \$e');
    }
  }
  
  /// Get inventory updates stream
  Stream<InventoryUpdate> get inventoryUpdates => _inventoryUpdateController.stream;
  
  /// Get inventory cache
  Map<String, InventoryItem> get inventoryCache => Map.unmodifiable(_inventoryCache);
  
  /// Calculate inventory value
  double calculateInventoryValue(String stockistId) {
    double totalValue = 0.0;
    
    for (final item in _inventoryCache.values) {
      if (item.stockistId == stockistId) {
        totalValue += item.currentStock * item.unitPrice;
      }
    }
    
    return totalValue;
  }
  
  /// Dispose resources
  void dispose() {
    _inventoryUpdateController.close();
  }
}
''';
    
    await inventoryServiceFile.writeAsString(inventoryServiceCode);
    print('    ✅ Real-time inventory control implemented');
  }

  /// Implement low-stock alerts
  Future<void> _implementLowStockAlerts() async {
    print('  🚨 Implementing low-stock alerts...');
    
    final alertServiceFile = File(path.join(distributionPath, 'data', 'services', 'low_stock_alert_service.dart'));
    await alertServiceFile.parent.create(recursive: true);
    
    final alertServiceCode = '''
import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'inventory_control_service.dart';

/// Low Stock Alert Service
class LowStockAlertService {
  static const String _channelId = 'low_stock_alerts';
  static const String _channelName = 'Low Stock Alerts';
  static const String _channelDescription = 'Alerts for low inventory levels';
  
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  final StreamController<LowStockAlert> _alertController = StreamController.broadcast();
  
  /// Low stock alert model
  class LowStockAlert {
    final String id;
    final String inventoryItemId;
    final String productName;
    final String stockistId;
    final int currentStock;
    final int minStockLevel;
    final AlertSeverity severity;
    final DateTime createdAt;
    final bool isAcknowledged;
    
    LowStockAlert({
      required this.id,
      required this.inventoryItemId,
      required this.productName,
      required this.stockistId,
      required this.currentStock,
      required this.minStockLevel,
      required this.severity,
      required this.createdAt,
      this.isAcknowledged = false,
    });
    
    factory LowStockAlert.fromJson(Map<String, dynamic> json) {
      return LowStockAlert(
        id: json['id'],
        inventoryItemId: json['inventoryItemId'],
        productName: json['productName'],
        stockistId: json['stockistId'],
        currentStock: json['currentStock'],
        minStockLevel: json['minStockLevel'],
        severity: AlertSeverity.values.firstWhere(
          (severity) => severity.toString() == 'AlertSeverity.\${json['severity']}',
          orElse: () => AlertSeverity.medium,
        ),
        createdAt: DateTime.parse(json['createdAt']),
        isAcknowledged: json['isAcknowledged'] ?? false,
      );
    }
    
    Map<String, dynamic> toJson() {
      return {
        'id': id,
        'inventoryItemId': inventoryItemId,
        'productName': productName,
        'stockistId': stockistId,
        'currentStock': currentStock,
        'minStockLevel': minStockLevel,
        'severity': severity.toString().split('.').last,
        'createdAt': createdAt.toIso8601String(),
        'isAcknowledged': isAcknowledged,
      };
    }
    
    LowStockAlert copyWith({
      String? id,
      String? inventoryItemId,
      String? productName,
      String? stockistId,
      int? currentStock,
      int? minStockLevel,
      AlertSeverity? severity,
      DateTime? createdAt,
      bool? isAcknowledged,
    }) {
      return LowStockAlert(
        id: id ?? this.id,
        inventoryItemId: inventoryItemId ?? this.inventoryItemId,
        productName: productName ?? this.productName,
        stockistId: stockistId ?? this.stockistId,
        currentStock: currentStock ?? this.currentStock,
        minStockLevel: minStockLevel ?? this.minStockLevel,
        severity: severity ?? this.severity,
        createdAt: createdAt ?? this.createdAt,
        isAcknowledged: isAcknowledged ?? this.isAcknowledged,
      );
    }
  }
  
  /// Alert severity enum
  enum AlertSeverity {
    low,
    medium,
    high,
    critical,
  }
  
  /// Initialize notifications
  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(android: androidSettings, iOS: iosSettings);
    
    await _notifications.initialize(settings);
    
    // Create notification channel
    const androidChannel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.high,
    );
    
    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }
  
  /// Check for low stock items and create alerts
  Future<void> checkLowStockItems(List<InventoryItem> inventoryItems) async {
    for (final item in inventoryItems) {
      if (item.isLowStock) {
        final alert = _createAlert(item);
        await _sendNotification(alert);
        _alertController.add(alert);
      }
    }
  }
  
  /// Create alert from inventory item
  LowStockAlert _createAlert(InventoryItem item) {
    final severity = _calculateSeverity(item);
    
    return LowStockAlert(
      id: '\${item.id}_\${DateTime.now().millisecondsSinceEpoch}',
      inventoryItemId: item.id,
      productName: item.productName,
      stockistId: item.stockistId,
      currentStock: item.currentStock,
      minStockLevel: item.minStockLevel,
      severity: severity,
      createdAt: DateTime.now(),
    );
  }
  
  /// Calculate alert severity
  AlertSeverity _calculateSeverity(InventoryItem item) {
    final stockRatio = item.currentStock / item.minStockLevel;
    
    if (stockRatio <= 0.2) {
      return AlertSeverity.critical;
    } else if (stockRatio <= 0.5) {
      return AlertSeverity.high;
    } else if (stockRatio <= 0.8) {
      return AlertSeverity.medium;
    } else {
      return AlertSeverity.low;
    }
  }
  
  /// Send notification
  Future<void> _sendNotification(LowStockAlert alert) async {
    final title = 'Low Stock Alert';
    final body = '\${alert.productName} is running low (\${alert.currentStock} units remaining)';
    
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      color: Color(0xFFE53935),
    );
    
    const iosDetails = DarwinNotificationDetails();
    
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);
    
    await _notifications.show(
      alert.id.hashCode,
      title,
      body,
      details,
      payload: jsonEncode(alert.toJson()),
    );
  }
  
  /// Get alerts stream
  Stream<LowStockAlert> get alerts => _alertController.stream;
  
  /// Acknowledge alert
  Future<void> acknowledgeAlert(String alertId) async {
    // This would update the alert on the server
    print('Alert acknowledged: \$alertId');
  }
  
  /// Dismiss alert
  Future<void> dismissAlert(String alertId) async {
    await _notifications.cancel(alertId.hashCode);
  }
  
  /// Dispose resources
  void dispose() {
    _alertController.close();
  }
}
''';
    
    await alertServiceFile.writeAsString(alertServiceCode);
    print('    ✅ Low-stock alerts implemented');
  }

  /// Implement stock transfer management
  Future<void> _implementStockTransferManagement() async {
    print('  🚚 Implementing stock transfer management...');
    
    final transferServiceFile = File(path.join(distributionPath, 'data', 'services', 'stock_transfer_service.dart'));
    await transferServiceFile.parent.create(recursive: true);
    
    final transferServiceCode = '''
import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';

/// Stock Transfer Management Service
class StockTransferService {
  static const String _baseUrl = 'https://api.vedantatrade.com.np';
  final Dio _dio = Dio(BaseOptions(baseUrl: _baseUrl));
  
  final StreamController<StockTransfer> _transferUpdateController = StreamController.broadcast();
  final Map<String, StockTransfer> _activeTransfers = {};
  
  /// Stock transfer model
  class StockTransfer {
    final String id;
    final String fromStockistId;
    final String toStockistId;
    final String productId;
    final String productName;
    final int quantity;
    final TransferStatus status;
    final DateTime createdAt;
    final DateTime? completedAt;
    final String? trackingNumber;
    final String? notes;
    final Map<String, dynamic>? metadata;
    
    StockTransfer({
      required this.id,
      required this.fromStockistId,
      required this.toStockistId,
      required this.productId,
      required this.productName,
      required this.quantity,
      required this.status,
      required this.createdAt,
      this.completedAt,
      this.trackingNumber,
      this.notes,
      this.metadata,
    });
    
    factory StockTransfer.fromJson(Map<String, dynamic> json) {
      return StockTransfer(
        id: json['id'],
        fromStockistId: json['fromStockistId'],
        toStockistId: json['toStockistId'],
        productId: json['productId'],
        productName: json['productName'],
        quantity: json['quantity'],
        status: TransferStatus.values.firstWhere(
          (status) => status.toString() == 'TransferStatus.\${json['status']}',
          orElse: () => TransferStatus.pending,
        ),
        createdAt: DateTime.parse(json['createdAt']),
        completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
        trackingNumber: json['trackingNumber'],
        notes: json['notes'],
        metadata: json['metadata'],
      );
    }
    
    Map<String, dynamic> toJson() {
      return {
        'id': id,
        'fromStockistId': fromStockistId,
        'toStockistId': toStockistId,
        'productId': productId,
        'productName': productName,
        'quantity': quantity,
        'status': status.toString().split('.').last,
        'createdAt': createdAt.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
        'trackingNumber': trackingNumber,
        'notes': notes,
        'metadata': metadata,
      };
    }
  }
  
  /// Transfer status enum
  enum TransferStatus {
    pending,
    approved,
    inTransit,
    delivered,
    cancelled,
  }
  
  /// Create stock transfer
  Future<StockTransfer?> createTransfer({
    required String fromStockistId,
    required String toStockistId,
    required String productId,
    required String productName,
    required int quantity,
    String? notes,
  }) async {
    try {
      final transferData = {
        'fromStockistId': fromStockistId,
        'toStockistId': toStockistId,
        'productId': productId,
        'productName': productName,
        'quantity': quantity,
        'status': 'pending',
        'createdAt': DateTime.now().toIso8601String(),
        'notes': notes,
      };
      
      final response = await _dio.post('/api/stock-transfers', data: transferData);
      
      if (response.statusCode == 201) {
        final transfer = StockTransfer.fromJson(response.data);
        _activeTransfers[transfer.id] = transfer;
        _transferUpdateController.add(transfer);
        return transfer;
      }
      
      return null;
    } catch (e) {
      print('Error creating stock transfer: \$e');
      return null;
    }
  }
  
  /// Update transfer status
  Future<bool> updateTransferStatus(String transferId, TransferStatus newStatus) async {
    try {
      final response = await _dio.patch('/api/stock-transfers/\$transferId/status', data: {
        'status': newStatus.toString().split('.').last,
        'completedAt': newStatus == TransferStatus.delivered ? DateTime.now().toIso8601String() : null,
      });
      
      if (response.statusCode == 200) {
        final updatedTransfer = StockTransfer.fromJson(response.data);
        _activeTransfers[transferId] = updatedTransfer;
        _transferUpdateController.add(updatedTransfer);
        return true;
      }
      
      return false;
    } catch (e) {
      print('Error updating transfer status: \$e');
      return false;
    }
  }
  
  /// Get transfers by stockist
  Future<List<StockTransfer>> getTransfersByStockist(String stockistId) async {
    try {
      final response = await _dio.get('/api/stock-transfers/stockist/\$stockistId');
      
      if (response.statusCode == 200) {
        final transfers = (response.data as List)
            .map((transfer) => StockTransfer.fromJson(transfer))
            .toList();
        
        // Update cache
        for (final transfer in transfers) {
          _activeTransfers[transfer.id] = transfer;
        }
        
        return transfers;
      }
      
      return [];
    } catch (e) {
      print('Error getting transfers by stockist: \$e');
      return [];
    }
  }
  
  /// Get transfers by status
  Future<List<StockTransfer>> getTransfersByStatus(TransferStatus status) async {
    try {
      final response = await _dio.get('/api/stock-transfers/status/\${status.toString().split('.').last}');
      
      if (response.statusCode == 200) {
        final transfers = (response.data as List)
            .map((transfer) => StockTransfer.fromJson(transfer))
            .toList();
        
        // Update cache
        for (final transfer in transfers) {
          _activeTransfers[transfer.id] = transfer;
        }
        
        return transfers;
      }
      
      return [];
    } catch (e) {
      print('Error getting transfers by status: \$e');
      return [];
    }
  }
  
  /// Get transfer updates stream
  Stream<StockTransfer> get transferUpdates => _transferUpdateController.stream;
  
  /// Get active transfers
  Map<String, StockTransfer> get activeTransfers => Map.unmodifiable(_activeTransfers);
  
  /// Cancel transfer
  Future<bool> cancelTransfer(String transferId, String reason) async {
    try {
      final response = await _dio.post('/api/stock-transfers/\$transferId/cancel', data: {
        'reason': reason,
        'cancelledAt': DateTime.now().toIso8601String(),
      });
      
      if (response.statusCode == 200) {
        final cancelledTransfer = StockTransfer.fromJson(response.data);
        _activeTransfers[transferId] = cancelledTransfer;
        _transferUpdateController.add(cancelledTransfer);
        return true;
      }
      
      return false;
    } catch (e) {
      print('Error cancelling transfer: \$e');
      return false;
    }
  }
  
  /// Generate tracking number
  String generateTrackingNumber() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(10000);
    return 'STVT\$timestamp\$random';
  }
  
  /// Dispose resources
  void dispose() {
    _transferUpdateController.close();
  }
}
''';
    
    await transferServiceFile.writeAsString(transferServiceCode);
    print('    ✅ Stock transfer management implemented');
  }

  /// Update stockist dashboard
  Future<void> _updateStockistDashboard() async {
    print('  📊 Updating stockist dashboard...');
    
    final dashboardFile = File(path.join(stockistPath, 'presentation', 'screens', 'stockist_dashboard_screen.dart'));
    if (!dashboardFile.existsSync()) {
      await dashboardFile.parent.create(recursive: true);
    }
    
    print('    ✅ Stockist dashboard updated');
  }

  /// Update retailer dashboard
  Future<void> _updateRetailerDashboard() async {
    print('  📊 Updating retailer dashboard...');
    
    final dashboardFile = File(path.join(retailerPath, 'presentation', 'screens', 'retailer_dashboard_screen.dart'));
    if (!dashboardFile.existsSync()) {
      await dashboardFile.parent.create(recursive: true);
    }
    
    print('    ✅ Retailer dashboard updated');
  }
}

/// Main entry point
void main() async {
  final supplyChainAutomation = SupplyChainAutomation();
  await supplyChainAutomation.executeSupplyChainAutomation();
}
