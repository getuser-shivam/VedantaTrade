import 'package:vedanta_trade/core/constants/app_constants.dart';
import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Real-time inventory service with WebSocket connections
class RealtimeInventoryService {
  static final RealtimeInventoryService _instance = RealtimeInventoryService._internal();
  factory RealtimeInventoryService() => _instance;
  RealtimeInventoryService._internal();

  late Dio _dio;
  WebSocketChannel? _webSocketChannel;
  final StreamController<InventoryUpdate> _inventoryController = 
      StreamController<InventoryUpdate>.broadcast();
  final StreamController<StockAlert> _alertController = 
      StreamController<StockAlert>.broadcast();
  final StreamController<List<InventoryItem>> _inventoryListController = 
      StreamController<List<InventoryItem>>.broadcast();
  
  List<InventoryItem> _inventory = [];
  List<StockAlert> _alerts = [];
  bool _isConnected = false;
  Timer? _reconnectTimer;
  String? _stockistId;
  
  Stream<InventoryUpdate> get inventoryStream => _inventoryController.stream;
  Stream<StockAlert> get alertStream => _alertController.stream;
  Stream<List<InventoryItem>> get inventoryListStream => _inventoryListController.stream;
  List<InventoryItem> get inventory => List.unmodifiable(_inventory);
  List<StockAlert> get alerts => List.unmodifiable(_alerts);
  bool get isConnected => _isConnected;

  /// Initialize real-time inventory service
  Future<void> initialize({String? stockistId}) async {
    try {

      _stockistId = stockistId;
      
      // Setup Dio client
      _setupDioClient();
      
      // Load initial inventory
      await _loadInitialInventory();
      
      // Load initial alerts
      await _loadInitialAlerts();
      
      // Connect to WebSocket
      await _connectWebSocket();
      
      // Start reconnection timer
      _startReconnectionTimer();

    } catch (e) {
      
      _inventoryController.addError(e);
    }
  }

  /// Setup Dio client
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

  /// Load initial inventory
  Future<void> _loadInitialInventory() async {
    try {

      if (_stockistId == null) {
        final prefs = await SharedPreferences.getInstance();
        _stockistId = prefs.getString('stockist_id');
      }
      
      if (_stockistId != null) {
        final response = await _dio.get(
          '/api/inventory/stockist/$_stockistId',
        );
        
        if (response.statusCode == 200) {
          final inventoryData = response.data['inventory'] as List;
          _inventory = inventoryData
              .map((item) => InventoryItem.fromJson(item))
              .toList();
          
          _inventoryListController.add(_inventory);
          
        }
      }
      
    } catch (e) {
      
    }
  }

  /// Load initial alerts
  Future<void> _loadInitialAlerts() async {
    try {

      if (_stockistId != null) {
        final response = await _dio.get(
          '/api/inventory/alerts/stockist/$_stockistId',
        );
        
        if (response.statusCode == 200) {
          final alertsData = response.data['alerts'] as List;
          _alerts = alertsData
              .map((alert) => StockAlert.fromJson(alert))
              .toList();
          
          _alertController.add(_alerts);
          
        }
      }
      
    } catch (e) {
      
    }
  }

  /// Connect to WebSocket
  Future<void> _connectWebSocket() async {
    try {

      if (_stockistId == null) {
        final prefs = await SharedPreferences.getInstance();
        _stockistId = prefs.getString('stockist_id');
      }
      
      if (_stockistId != null) {
        final wsUrl = 'wss://api.vedantatrade.com.np/ws/inventory/stockist/$_stockistId';
        _webSocketChannel = WebSocketChannel.connect(Uri.parse(wsUrl));
        
        await _webSocketChannel!.ready;
        
        _isConnected = true;

        // Listen to WebSocket messages
        _webSocketChannel!.stream.listen(
          _handleWebSocketMessage,
          onError: _handleWebSocketError,
          onDone: _handleWebSocketClose,
        );
        
        // Send authentication message
        _sendAuthenticationMessage();
      }
      
    } catch (e) {
      
      _isConnected = false;
    }
  }

  /// Handle WebSocket messages
  void _handleWebSocketMessage(dynamic message) {
    try {
      final data = jsonDecode(message);
      final type = data['type'] as String;
      
      switch (type) {
        case 'inventory_update':
          _handleInventoryUpdate(data['data']);
          break;
        case 'stock_alert':
          _handleStockAlert(data['data']);
          break;
        case 'inventory_sync':
          _handleInventorySync(data['data']);
          break;
        case 'heartbeat':
          _handleHeartbeat();
          break;
      }
      
    } catch (e) {
      
    }
  }

  /// Handle inventory update
  void _handleInventoryUpdate(Map<String, dynamic> data) {
    try {
      final update = InventoryUpdate.fromJson(data);
      
      // Update local inventory
      final itemIndex = _inventory.indexWhere(
        (item) => item.sku == update.sku,
      );
      
      if (itemIndex != -1) {
        final oldItem = _inventory[itemIndex];
        _inventory[itemIndex] = oldItem.copyWith(
          currentStock: update.newStock,
          lastUpdated: DateTime.parse(update.timestamp),
        );
      } else {
        // Add new item
        final newItem = InventoryItem(
          sku: update.sku,
          productName: update.productName,
          brand: update.brand,
          currentStock: update.newStock,
          minStock: update.minStock ?? 0,
          maxStock: update.maxStock ?? 1000,
          unitPrice: update.unitPrice ?? 0.0,
          batchNumber: update.batchNumber,
          expiryDate: update.expiryDate != null 
              ? DateTime.parse(update.expiryDate)
              : null,
          lastUpdated: DateTime.parse(update.timestamp),
        );
        _inventory.add(newItem);
      }
      
      // Emit update
      _inventoryController.add(update);
      _inventoryListController.add(_inventory);

    } catch (e) {
      
    }
  }

  /// Handle stock alert
  void _handleStockAlert(Map<String, dynamic> data) {
    try {
      final alert = StockAlert.fromJson(data);
      
      // Update local alerts
      final existingIndex = _alerts.indexWhere(
        (a) => a.sku == alert.sku && a.type == alert.type,
      );
      
      if (existingIndex != -1) {
        _alerts[existingIndex] = alert;
      } else {
        _alerts.insert(0, alert);
      }
      
      // Keep only last 100 alerts
      if (_alerts.length > 100) {
        _alerts = _alerts.sublist(0, 100);
      }
      
      // Emit alert
      _alertController.add(alert);

    } catch (e) {
      
    }
  }

  /// Handle inventory sync
  void _handleInventorySync(Map<String, dynamic> data) {
    try {
      final inventoryData = data['inventory'] as List;
      _inventory = inventoryData
          .map((item) => InventoryItem.fromJson(item))
          .toList();
      
      _inventoryListController.add(_inventory);

    } catch (e) {
      
    }
  }

  /// Handle heartbeat
  void _handleHeartbeat() {

    // Send heartbeat response
    _sendHeartbeatResponse();
  }

  /// Handle WebSocket error
  void _handleWebSocketError(dynamic error) {
    
    _isConnected = false;
  }

  /// Handle WebSocket close
  void _handleWebSocketClose() {
    
    _isConnected = false;
    
    // Attempt to reconnect
    _scheduleReconnection();
  }

  /// Send authentication message
  void _sendAuthenticationMessage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token != null && _webSocketChannel != null) {
        final authMessage = {
          'type': 'auth',
          'token': token,
          'stockistId': _stockistId,
        };
        
        _webSocketChannel!.sink.add(jsonEncode(authMessage));
        
      }
      
    } catch (e) {
      
    }
  }

  /// Send heartbeat response
  void _sendHeartbeatResponse() {
    try {
      if (_webSocketChannel != null) {
        final heartbeatResponse = {
          'type': 'heartbeat_response',
          'timestamp': DateTime.now().toIso8601String(),
        };
        
        _webSocketChannel!.sink.add(jsonEncode(heartbeatResponse));
      }
      
    } catch (e) {
      
    }
  }

  /// Start reconnection timer
  void _startReconnectionTimer() {
    _reconnectTimer = Timer.periodic(
      const Duration(seconds: 30),
      (timer) {
        if (!_isConnected) {
          
          _connectWebSocket();
        }
      },
    );
  }

  /// Schedule reconnection
  void _scheduleReconnection() {
    Timer(const Duration(seconds: 5), () {
      if (!_isConnected) {
        _connectWebSocket();
      }
    });
  }

  /// Update inventory item
  Future<bool> updateInventoryItem({
    required String sku,
    required int newStock,
    String? batchNumber,
    DateTime? expiryDate,
  }) async {
    try {

      final updateData = {
        'sku': sku,
        'stockistId': _stockistId,
        'newStock': newStock,
        'batchNumber': batchNumber,
        'expiryDate': expiryDate?.toIso8601String(),
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      final response = await _dio.put(
        '/api/inventory/update',
        data: updateData,
      );
      
      if (response.statusCode == 200) {
        
        return true;
      }
      
    } catch (e) {
      
    }
    
    return false;
  }

  /// Add new inventory item
  Future<bool> addInventoryItem({
    required String sku,
    required String productName,
    required String brand,
    required int currentStock,
    required int minStock,
    required int maxStock,
    required double unitPrice,
    String? batchNumber,
    DateTime? expiryDate,
  }) async {
    try {

      final itemData = {
        'sku': sku,
        'productName': productName,
        'brand': brand,
        'stockistId': _stockistId,
        'currentStock': currentStock,
        'minStock': minStock,
        'maxStock': maxStock,
        'unitPrice': unitPrice,
        'batchNumber': batchNumber,
        'expiryDate': expiryDate?.toIso8601String(),
        'createdAt': DateTime.now().toIso8601String(),
      };
      
      final response = await _dio.post(
        '/api/inventory/add',
        data: itemData,
      );
      
      if (response.statusCode == 201) {
        
        return true;
      }
      
    } catch (e) {
      
    }
    
    return false;
  }

  /// Delete inventory item
  Future<bool> deleteInventoryItem(String sku) async {
    try {

      final response = await _dio.delete(
        '/api/inventory/item/$sku',
        queryParameters: {
          'stockistId': _stockistId,
        },
      );
      
      if (response.statusCode == 200) {
        
        return true;
      }
      
    } catch (e) {
      
    }
    
    return false;
  }

  /// Get low stock items
  List<InventoryItem> getLowStockItems() {
    return _inventory.where((item) => 
        item.currentStock <= item.minStock
    ).toList();
  }

  /// Get expired items
  List<InventoryItem> getExpiredItems() {
    final now = DateTime.now();
    return _inventory.where((item) => 
        item.expiryDate != null && item.expiryDate!.isBefore(now)
    ).toList();
  }

  /// Get items expiring soon (within 30 days)
  List<InventoryItem> getItemsExpiringSoon() {
    final thirtyDaysFromNow = DateTime.now().add(const Duration(days: 30));
    return _inventory.where((item) => 
        item.expiryDate != null && 
        item.expiryDate!.isAfter(DateTime.now()) &&
        item.expiryDate!.isBefore(thirtyDaysFromNow)
    ).toList();
  }

  /// Get critical alerts
  List<StockAlert> getCriticalAlerts() {
    return _alerts.where((alert) => 
        alert.severity == StockAlertSeverity.critical
    ).toList();
  }

  /// Get low stock alerts
  List<StockAlert> getLowStockAlerts() {
    return _alerts.where((alert) => 
        alert.type == StockAlertType.lowStock
    ).toList();
  }

  /// Get expiration alerts
  List<StockAlert> getExpirationAlerts() {
    return _alerts.where((alert) => 
        alert.type == StockAlertType.expiration
    ).toList();
  }

  /// Dismiss alert
  Future<bool> dismissAlert(String alertId) async {
    try {

      final response = await _dio.put(
        '/api/inventory/alerts/$alertId/dismiss',
        data: {
          'dismissedAt': DateTime.now().toIso8601String(),
        },
      );
      
      if (response.statusCode == 200) {
        // Remove from local alerts
        _alerts.removeWhere((alert) => alert.id == alertId);
        _alertController.add(_alerts);

        return true;
      }
      
    } catch (e) {
      
    }
    
    return false;
  }

  /// Get inventory statistics
  Map<String, dynamic> getInventoryStatistics() {
    final totalItems = _inventory.length;
    final lowStockItems = getLowStockItems().length;
    final expiredItems = getExpiredItems().length;
    final expiringSoonItems = getItemsExpiringSoon().length;
    final totalValue = _inventory.fold(0.0, (sum, item) => 
        sum + (item.currentStock * item.unitPrice)
    );
    
    return {
      'totalItems': totalItems,
      'lowStockItems': lowStockItems,
      'expiredItems': expiredItems,
      'expiringSoonItems': expiringSoonItems,
      'totalValue': totalValue,
      'healthScore': _calculateHealthScore(),
      'lastUpdated': DateTime.now().toIso8601String(),
    };
  }

  /// Calculate inventory health score
  double _calculateHealthScore() {
    if (_inventory.isEmpty) return 0.0;
    
    final totalItems = _inventory.length;
    final lowStockItems = getLowStockItems().length;
    final expiredItems = getExpiredItems().length;
    
    // Health score: 100 - (lowStock% + expired%)
    final lowStockPercentage = (lowStockItems / totalItems) * 100;
    final expiredPercentage = (expiredItems / totalItems) * 100;
    
    return (100 - (lowStockPercentage + expiredPercentage)).clamp(0.0, 100.0);
  }

  /// Sync inventory with server
  Future<void> syncInventory() async {
    try {

      final response = await _dio.post(
        '/api/inventory/sync',
        data: {
          'stockistId': _stockistId,
          'lastSync': DateTime.now().toIso8601String(),
        },
      );
      
      if (response.statusCode == 200) {
        final syncData = response.data;
        
        // Update local inventory
        if (syncData['inventory'] != null) {
          final inventoryData = syncData['inventory'] as List;
          _inventory = inventoryData
              .map((item) => InventoryItem.fromJson(item))
              .toList();
          
          _inventoryListController.add(_inventory);
        }
        
        // Update local alerts
        if (syncData['alerts'] != null) {
          final alertsData = syncData['alerts'] as List;
          _alerts = alertsData
              .map((alert) => StockAlert.fromJson(alert))
              .toList();
          
          _alertController.add(_alerts);
        }

      }
      
    } catch (e) {
      
    }
  }

  /// Dispose resources
  void dispose() {

    _reconnectTimer?.cancel();
    _webSocketChannel?.sink.close();
    _inventoryController.close();
    _alertController.close();
    _inventoryListController.close();

  }
}

/// Inventory item model
class InventoryItem {
  final String sku;
  final String productName;
  final String brand;
  final int currentStock;
  final int minStock;
  final int maxStock;
  final double unitPrice;
  final String? batchNumber;
  final DateTime? expiryDate;
  final DateTime lastUpdated;
  
  InventoryItem({
    required this.sku,
    required this.productName,
    required this.brand,
    required this.currentStock,
    required this.minStock,
    required this.maxStock,
    required this.unitPrice,
    this.batchNumber,
    this.expiryDate,
    required this.lastUpdated,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      sku: json['sku'] as String,
      productName: json['productName'] as String,
      brand: json['brand'] as String,
      currentStock: json['currentStock'] as int,
      minStock: json['minStock'] as int,
      maxStock: json['maxStock'] as int,
      unitPrice: (json['unitPrice'] as num).toDouble(),
      batchNumber: json['batchNumber'] as String?,
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'] as String)
          : null,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }

  InventoryItem copyWith({
    String? sku,
    String? productName,
    String? brand,
    int? currentStock,
    int? minStock,
    int? maxStock,
    double? unitPrice,
    String? batchNumber,
    DateTime? expiryDate,
    DateTime? lastUpdated,
  }) {
    return InventoryItem(
      sku: sku ?? this.sku,
      productName: productName ?? this.productName,
      brand: brand ?? this.brand,
      currentStock: currentStock ?? this.currentStock,
      minStock: minStock ?? this.minStock,
      maxStock: maxStock ?? this.maxStock,
      unitPrice: unitPrice ?? this.unitPrice,
      batchNumber: batchNumber ?? this.batchNumber,
      expiryDate: expiryDate ?? this.expiryDate,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sku': sku,
      'productName': productName,
      'brand': brand,
      'currentStock': currentStock,
      'minStock': minStock,
      'maxStock': maxStock,
      'unitPrice': unitPrice,
      'batchNumber': batchNumber,
      'expiryDate': expiryDate?.toIso8601String(),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}

/// Inventory update model
class InventoryUpdate {
  final String sku;
  final String productName;
  final String? brand;
  final int oldStock;
  final int newStock;
  final int? minStock;
  final int? maxStock;
  final double? unitPrice;
  final String? batchNumber;
  final String? expiryDate;
  final String timestamp;
  final String updateType;
  
  InventoryUpdate({
    required this.sku,
    required this.productName,
    this.brand,
    required this.oldStock,
    required this.newStock,
    this.minStock,
    this.maxStock,
    this.unitPrice,
    this.batchNumber,
    this.expiryDate,
    required this.timestamp,
    required this.updateType,
  });

  factory InventoryUpdate.fromJson(Map<String, dynamic> json) {
    return InventoryUpdate(
      sku: json['sku'] as String,
      productName: json['productName'] as String,
      brand: json['brand'] as String?,
      oldStock: json['oldStock'] as int,
      newStock: json['newStock'] as int,
      minStock: json['minStock'] as int?,
      maxStock: json['maxStock'] as int?,
      unitPrice: (json['unitPrice'] as num?)?.toDouble(),
      batchNumber: json['batchNumber'] as String?,
      expiryDate: json['expiryDate'] as String?,
      timestamp: json['timestamp'] as String,
      updateType: json['updateType'] as String,
    );
  }
}

/// Stock alert model
class StockAlert {
  final String id;
  final String sku;
  final String productName;
  final String? brand;
  final StockAlertType type;
  final StockAlertSeverity severity;
  final String message;
  final DateTime createdAt;
  final DateTime? dismissedAt;
  final Map<String, dynamic>? metadata;
  
  StockAlert({
    required this.id,
    required this.sku,
    required this.productName,
    this.brand,
    required this.type,
    required this.severity,
    required this.message,
    required this.createdAt,
    this.dismissedAt,
    this.metadata,
  });

  factory StockAlert.fromJson(Map<String, dynamic> json) {
    return StockAlert(
      id: json['id'] as String,
      sku: json['sku'] as String,
      productName: json['productName'] as String,
      brand: json['brand'] as String?,
      type: StockAlertType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => StockAlertType.lowStock,
      ),
      severity: StockAlertSeverity.values.firstWhere(
        (e) => e.toString() == json['severity'],
        orElse: () => StockAlertSeverity.low,
      ),
      message: json['message'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      dismissedAt: json['dismissedAt'] != null
          ? DateTime.parse(json['dismissedAt'] as String)
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sku': sku,
      'productName': productName,
      'brand': brand,
      'type': type.toString(),
      'severity': severity.toString(),
      'message': message,
      'createdAt': createdAt.toIso8601String(),
      'dismissedAt': dismissedAt?.toIso8601String(),
      'metadata': metadata,
    };
  }
}

/// Stock alert type enum
enum StockAlertType {
  lowStock,
  outOfStock,
  expiration,
  criticalLow,
  overstock,
}

/// Stock alert severity enum
enum StockAlertSeverity {
  low,
  medium,
  high,
  critical,
}
