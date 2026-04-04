import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../domain/models/distribution_models.dart';

class RealtimeInventoryService {
  static final RealtimeInventoryService _instance = RealtimeInventoryService._internal();
  factory RealtimeInventoryService() => _instance;
  RealtimeInventoryService._internal();

  WebSocketChannel? _channel;
  final StreamController<InventoryUpdate> _inventoryUpdateController = StreamController.broadcast();
  final StreamController<RouteUpdate> _routeUpdateController = StreamController.broadcast();
  final StreamController<CampaignUpdate> _campaignUpdateController = StreamController.broadcast();
  
  // Streams
  Stream<InventoryUpdate> get inventoryUpdates => _inventoryUpdateController.stream;
  Stream<RouteUpdate> get routeUpdates => _routeUpdateController.stream;
  Stream<CampaignUpdate> get campaignUpdates => _campaignUpdateController.stream;

  bool _isConnected = false;
  String? _userId;
  String? _token;

  // Connection status
  bool get isConnected => _isConnected;

  // Initialize real-time connection
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('auth_token');
      _userId = prefs.getString('user_id');

      if (_token != null && _userId != null) {
        await _connectWebSocket();
      }
    } catch (e) {
      
    }
  }

  // Connect to WebSocket
  Future<void> _connectWebSocket() async {
    try {
      // Replace with your WebSocket server URL
      final wsUrl = 'ws://localhost:3001/ws/inventory?token=$_token&userId=$_userId';
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      
      _channel!.stream.listen(
        _handleWebSocketMessage,
        onError: (error) {
          
          _isConnected = false;
          _scheduleReconnect();
        },
        onDone: () {
          
          _isConnected = false;
          _scheduleReconnect();
        },
      );

      _isConnected = true;
      
    } catch (e) {
      
      _isConnected = false;
      _scheduleReconnect();
    }
  }

  // Handle WebSocket messages
  void _handleWebSocketMessage(dynamic message) {
    try {
      final data = json.decode(message);
      final type = data['type'] as String?;
      final payload = data['data'];

      switch (type) {
        case 'inventory_update':
          _handleInventoryUpdate(payload);
          break;
        case 'route_update':
          _handleRouteUpdate(payload);
          break;
        case 'campaign_update':
          _handleCampaignUpdate(payload);
          break;
        case 'stock_alert':
          _handleStockAlert(payload);
          break;
        case 'delivery_update':
          _handleDeliveryUpdate(payload);
          break;
      }
    } catch (e) {
      
    }
  }

  // Handle inventory updates
  void _handleInventoryUpdate(Map<String, dynamic> payload) {
    final update = InventoryUpdate.fromJson(payload);
    _inventoryUpdateController.add(update);
  }

  // Handle route updates
  void _handleRouteUpdate(Map<String, dynamic> payload) {
    final update = RouteUpdate.fromJson(payload);
    _routeUpdateController.add(update);
  }

  // Handle campaign updates
  void _handleCampaignUpdate(Map<String, dynamic> payload) {
    final update = CampaignUpdate.fromJson(payload);
    _campaignUpdateController.add(update);
  }

  // Handle stock alerts
  void _handleStockAlert(Map<String, dynamic> payload) {
    final alert = StockAlert.fromJson(payload);
    // Show notification or update UI
    _showStockAlert(alert);
  }

  // Handle delivery updates
  void _handleDeliveryUpdate(Map<String, dynamic> payload) {
    final update = DeliveryUpdate.fromJson(payload);
    // Update delivery status
    _showDeliveryUpdate(update);
  }

  // Schedule reconnection
  void _scheduleReconnect() {
    Future.delayed(const Duration(seconds: 5), () {
      if (!_isConnected) {
        _connectWebSocket();
      }
    });
  }

  // Send inventory update
  Future<void> sendInventoryUpdate(InventoryUpdate update) async {
    if (_isConnected && _channel != null) {
      try {
        final message = json.encode({
          'type': 'inventory_update',
          'data': update.toJson(),
        });
        _channel!.sink.add(message);
      } catch (e) {
        
      }
    }
  }

  // Send route update
  Future<void> sendRouteUpdate(RouteUpdate update) async {
    if (_isConnected && _channel != null) {
      try {
        final message = json.encode({
          'type': 'route_update',
          'data': update.toJson(),
        });
        _channel!.sink.add(message);
      } catch (e) {
        
      }
    }
  }

  // Send campaign update
  Future<void> sendCampaignUpdate(CampaignUpdate update) async {
    if (_isConnected && _channel != null) {
      try {
        final message = json.encode({
          'type': 'campaign_update',
          'data': update.toJson(),
        });
        _channel!.sink.add(message);
      } catch (e) {
        
      }
    }
  }

  // Subscribe to specific inventory updates
  void subscribeToInventoryUpdates(int centerId) {
    if (_isConnected && _channel != null) {
      try {
        final message = json.encode({
          'type': 'subscribe_inventory',
          'data': {'center_id': centerId},
        });
        _channel!.sink.add(message);
      } catch (e) {
        
      }
    }
  }

  // Subscribe to route updates
  void subscribeToRouteUpdates(int routeId) {
    if (_isConnected && _channel != null) {
      try {
        final message = json.encode({
          'type': 'subscribe_route',
          'data': {'route_id': routeId},
        });
        _channel!.sink.add(message);
      } catch (e) {
        
      }
    }
  }

  // Unsubscribe from updates
  void unsubscribeFromUpdates(String type) {
    if (_isConnected && _channel != null) {
      try {
        final message = json.encode({
          'type': 'unsubscribe',
          'data': {'update_type': type},
        });
        _channel!.sink.add(message);
      } catch (e) {
        
      }
    }
  }

  // Show stock alert
  void _showStockAlert(StockAlert alert) {

  }

  // Show delivery update
  void _showDeliveryUpdate(DeliveryUpdate update) {

  }

  // Disconnect WebSocket
  void disconnect() {
    if (_channel != null) {
      _channel!.sink.close();
      _channel = null;
    }
    _isConnected = false;
  }

  // Dispose
  void dispose() {
    _channel?.sink.close();
    _inventoryUpdateController.close();
    _routeUpdateController.close();
    _campaignUpdateController.close();
  }
}

// Update models
class InventoryUpdate {
  final int centerId;
  final int productId;
  final double quantityAllocated;
  final double quantityAvailable;
  final String updateType;
  final DateTime timestamp;

  InventoryUpdate({
    required this.centerId,
    required this.productId,
    required this.quantityAllocated,
    required this.quantityAvailable,
    required this.updateType,
    required this.timestamp,
  });

  factory InventoryUpdate.fromJson(Map<String, dynamic> json) {
    return InventoryUpdate(
      centerId: json['center_id'] ?? 0,
      productId: json['product_id'] ?? 0,
      quantityAllocated: (json['quantity_allocated'] ?? 0).toDouble(),
      quantityAvailable: (json['quantity_available'] ?? 0).toDouble(),
      updateType: json['update_type'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'center_id': centerId,
      'product_id': productId,
      'quantity_allocated': quantityAllocated,
      'quantity_available': quantityAvailable,
      'update_type': updateType,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

class RouteUpdate {
  final int routeId;
  final String status;
  final String? driverName;
  final DateTime timestamp;

  RouteUpdate({
    required this.routeId,
    required this.status,
    this.driverName,
    required this.timestamp,
  });

  factory RouteUpdate.fromJson(Map<String, dynamic> json) {
    return RouteUpdate(
      routeId: json['route_id'] ?? 0,
      status: json['status'] ?? '',
      driverName: json['driver_name'],
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'route_id': routeId,
      'status': status,
      'driver_name': driverName,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

class CampaignUpdate {
  final int campaignId;
  final String status;
  final DateTime timestamp;

  CampaignUpdate({
    required this.campaignId,
    required this.status,
    required this.timestamp,
  });

  factory CampaignUpdate.fromJson(Map<String, dynamic> json) {
    return CampaignUpdate(
      campaignId: json['campaign_id'] ?? 0,
      status: json['status'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'campaign_id': campaignId,
      'status': status,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

class StockAlert {
  final int productId;
  final String productName;
  final String message;
  final String alertType;
  final DateTime timestamp;

  StockAlert({
    required this.productId,
    required this.productName,
    required this.message,
    required this.alertType,
    required this.timestamp,
  });

  factory StockAlert.fromJson(Map<String, dynamic> json) {
    return StockAlert(
      productId: json['product_id'] ?? 0,
      productName: json['product_name'] ?? '',
      message: json['message'] ?? '',
      alertType: json['alert_type'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class DeliveryUpdate {
  final String orderId;
  final String status;
  final String? location;
  final DateTime timestamp;

  DeliveryUpdate({
    required this.orderId,
    required this.status,
    this.location,
    required this.timestamp,
  });

  factory DeliveryUpdate.fromJson(Map<String, dynamic> json) {
    return DeliveryUpdate(
      orderId: json['order_id'] ?? '',
      status: json['status'] ?? '',
      location: json['location'],
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }
}
