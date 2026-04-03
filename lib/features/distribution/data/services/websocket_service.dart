import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class WebSocketMessage {
  final String type;
  final dynamic data;
  final DateTime timestamp;

  WebSocketMessage({
    required this.type,
    required this.data,
    required this.timestamp,
  });

  factory WebSocketMessage.fromJson(Map<String, dynamic> json) {
    return WebSocketMessage(
      type: json['type'] ?? '',
      data: json['data'],
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  bool _isConnected = false;
  bool _isReconnecting = false;
  Timer? _reconnectTimer;
  Timer? _heartbeatTimer;
  final Set<String> _subscriptions = {};
  final Map<String, List<void Function(WebSocketMessage)>> _listeners = {};

  // Connection status
  bool get isConnected => _isConnected;
  Stream<bool> get connectionStatus => _connectionController.stream;
  final _connectionController = StreamController<bool>.broadcast();

  // Message streams
  Stream<WebSocketMessage> get messages => _messageController.stream;
  final _messageController = StreamController<WebSocketMessage>.broadcast();

  // Specific streams
  Stream<WebSocketMessage> get inventoryUpdates => 
      _messageController.stream.where((msg) => msg.type == 'inventory_update');
  Stream<WebSocketMessage> get stockAlerts => 
      _messageController.stream.where((msg) => msg.type == 'stock_alert');
  Stream<WebSocketMessage> get routeUpdates => 
      _messageController.stream.where((msg) => msg.type == 'route_update');
  Stream<WebSocketMessage> get campaignUpdates => 
      _messageController.stream.where((msg) => msg.type == 'campaign_update');
  Stream<WebSocketMessage> get analyticsUpdates => 
      _messageController.stream.where((msg) => msg.type == 'analytics_update');

  Future<void> connect() async {
    if (_isConnected) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final wsUrl = Uri.parse('${_getWebSocketUrl()}?token=$token');
      _channel = WebSocketChannel.connect(wsUrl);

      _subscription = _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDisconnect,
        cancelOnError: true,
      );

      _isConnected = true;
      _connectionController.add(true);
      _startHeartbeat();
      
      print('WebSocket connected successfully');
    } catch (e) {
      print('WebSocket connection failed: $e');
      _isConnected = false;
      _connectionController.add(false);
      _scheduleReconnect();
    }
  }

  void _handleMessage(dynamic message) {
    try {
      final data = jsonDecode(message);
      final wsMessage = WebSocketMessage.fromJson(data);
      
      _messageController.add(wsMessage);
      
      // Notify specific listeners
      final listeners = _listeners[wsMessage.type] ?? [];
      for (final listener in listeners) {
        try {
          listener(wsMessage);
        } catch (e) {
          print('Error in WebSocket listener: $e');
        }
      }
    } catch (e) {
      print('Error parsing WebSocket message: $e');
    }
  }

  void _handleError(dynamic error) {
    print('WebSocket error: $error');
    _isConnected = false;
    _connectionController.add(false);
    _scheduleReconnect();
  }

  void _handleDisconnect() {
    print('WebSocket disconnected');
    _isConnected = false;
    _connectionController.add(false);
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_isReconnecting) return;
    
    _isReconnecting = true;
    _reconnectTimer?.cancel();
    
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      _isReconnecting = false;
      print('Attempting to reconnect WebSocket...');
      connect();
    });
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_isConnected) {
        send({'type': 'ping'});
      }
    });
  }

  Future<void> subscribe(List<String> channels) async {
    if (!_isConnected) {
      await connect();
    }

    for (final channel in channels) {
      _subscriptions.add(channel);
    }

    send({
      'type': 'subscribe',
      'channels': channels,
    });
  }

  Future<void> unsubscribe(List<String> channels) async {
    for (final channel in channels) {
      _subscriptions.remove(channel);
    }

    send({
      'type': 'unsubscribe',
      'channels': channels,
    });
  }

  void send(Map<String, dynamic> message) {
    if (_isConnected && _channel != null) {
      try {
        _channel!.sink.add(jsonEncode(message));
      } catch (e) {
        print('Error sending WebSocket message: $e');
      }
    } else {
      print('WebSocket not connected, cannot send message');
    }
  }

  void addListener(String messageType, void Function(WebSocketMessage) listener) {
    _listeners.putIfAbsent(messageType, () => []).add(listener);
  }

  void removeListener(String messageType, void Function(WebSocketMessage) listener) {
    _listeners[messageType]?.remove(listener);
    if (_listeners[messageType]?.isEmpty == true) {
      _listeners.remove(messageType);
    }
  }

  Future<void> disconnect() async {
    _reconnectTimer?.cancel();
    _heartbeatTimer?.cancel();
    _subscription?.cancel();
    _channel?.sink.close();
    
    _isConnected = false;
    _connectionController.add(false);
    
    await _messageController.close();
    await _connectionController.close();
  }

  String _getWebSocketUrl() {
    // Get the base URL from your API configuration
    const String wsUrl = 'ws://localhost:3001/ws';
    return wsUrl;
  }

  // Utility methods for common operations
  void subscribeToInventory() {
    subscribe(['inventory']);
  }

  void subscribeToRoutes() {
    subscribe(['routes']);
  }

  void subscribeToCampaigns() {
    subscribe(['campaigns']);
  }

  void subscribeToAnalytics() {
    subscribe(['analytics']);
  }

  void subscribeToAll() {
    subscribe(['inventory', 'routes', 'campaigns', 'analytics']);
  }

  // Status and statistics
  Map<String, dynamic> getStatus() {
    return {
      'isConnected': _isConnected,
      'isReconnecting': _isReconnecting,
      'subscriptions': _subscriptions.toList(),
      'listenersCount': _listeners.values.fold(0, (sum, listeners) => sum + listeners.length),
    };
  }

  // Test connection
  Future<bool> testConnection() async {
    try {
      if (!_isConnected) {
        await connect();
      }

      final completer = Completer<bool>();
      
      void onPong(WebSocketMessage message) {
        if (message.type == 'pong') {
          completer.complete(true);
          removeListener('pong', onPong);
        }
      }

      addListener('pong', onPong);
      send({'type': 'ping'});

      // Timeout after 5 seconds
      Timer(const Duration(seconds: 5), () {
        if (!completer.isCompleted) {
          completer.complete(false);
          removeListener('pong', onPong);
        }
      });

      return await completer.future;
    } catch (e) {
      print('Error testing WebSocket connection: $e');
      return false;
    }
  }

  // Batch operations
  Future<void> subscribeToBatch(List<String> channels) async {
    if (!_isConnected) {
      await connect();
    }

    for (final channel in channels) {
      _subscriptions.add(channel);
    }

    send({
      'type': 'subscribe',
      'channels': channels,
    });
  }

  // Reconnect with new token
  Future<void> reconnectWithNewToken(String newToken) async {
    await disconnect();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', newToken);
    
    await connect();
  }

  // Cleanup
  void dispose() {
    disconnect();
    _listeners.clear();
    _subscriptions.clear();
  }
}

// Extension methods for easier usage
extension WebSocketServiceExtensions on WebSocketService {
  Stream<T> onMessage<T>(String messageType, T Function(WebSocketMessage) converter) {
    return messages
        .where((msg) => msg.type == messageType)
        .map(converter);
  }

  void onInventoryUpdate(void Function(dynamic data) callback) {
    addListener('inventory_update', (msg) => callback(msg.data));
  }

  void onStockAlert(void Function(dynamic data) callback) {
    addListener('stock_alert', (msg) => callback(msg.data));
  }

  void onRouteUpdate(void Function(dynamic data) callback) {
    addListener('route_update', (msg) => callback(msg.data));
  }

  void onCampaignUpdate(void Function(dynamic data) callback) {
    addListener('campaign_update', (msg) => callback(msg.data));
  }

  void onAnalyticsUpdate(void Function(dynamic data) callback) {
    addListener('analytics_update', (msg) => callback(msg.data));
  }
}
