import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// WebSocket Manager with Enhanced Error Handling
/// Provides robust WebSocket connections with automatic reconnection and error recovery
class WebSocketManager {
  final String url;
  final Map<String, dynamic>? headers;
  final Duration connectionTimeout;
  final Duration reconnectDelay;
  final int maxReconnectAttempts;
  final bool enableLogging;
  final StreamController<WebSocketMessage> _messageController;
  final StreamController<WebSocketEvent> _eventController;
  final Map<String, Completer<WebSocketMessage>> _pendingRequests = {};
  final Map<String, Timer> _requestTimeouts = {};
  final List<WebSocketMessage> _messageQueue = [];
  WebSocketChannel? _channel;
  bool _isConnected = false;
  bool _isConnecting = false;
  bool _shouldReconnect = true;
  int _reconnectAttempts = 0;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  Timer? _connectionCheckTimer;
  StreamSubscription? _connectivitySubscription;
  DateTime? _lastMessageTime;
  int _messageIdCounter = 0;

  WebSocketManager({
    required this.url,
    this.headers,
    this.connectionTimeout = const Duration(seconds: 10),
    this.reconnectDelay = const Duration(seconds: 3),
    this.maxReconnectAttempts = 5,
    this.enableLogging = true,
  }) : _messageController = StreamController<WebSocketMessage>.broadcast(),
       _eventController = StreamController<WebSocketEvent>.broadcast();

  /// Stream of WebSocket messages
  Stream<WebSocketMessage> get messageStream => _messageController.stream;

  /// Stream of WebSocket events
  Stream<WebSocketEvent> get eventStream => _eventController.stream;

  /// Current connection status
  bool get isConnected => _isConnected;

  /// Connection state
  WebSocketConnectionState get connectionState {
    if (_isConnected) return WebSocketConnectionState.connected;
    if (_isConnecting) return WebSocketConnectionState.connecting;
    return WebSocketConnectionState.disconnected;
  }

  /// Connect to WebSocket server
  Future<Either<WebSocketError, void>> connect() async {
    try {
      if (_isConnected || _isConnecting) {
        return const Right(null);
      }

      _log('🔌 Connecting to WebSocket: $url');
      _isConnecting = true;
      _shouldReconnect = true;
      _reconnectAttempts = 0;

      // Emit connecting event
      _emitEvent(WebSocketEvent(
        type: WebSocketEventType.connecting,
        message: 'Connecting to WebSocket server',
        timestamp: DateTime.now(),
      ));

      // Create connection with timeout
      _channel = await _createConnectionWithTimeout();

      if (_channel == null) {
        throw WebSocketException('Failed to create WebSocket connection');
      }

      // Set up message listener
      _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleClose,
      );

      // Send connection handshake
      await _sendHandshake();

      _isConnected = true;
      _isConnecting = false;
      _reconnectAttempts = 0;
      _lastMessageTime = DateTime.now();

      // Start heartbeat
      _startHeartbeat();

      // Start connection monitoring
      _startConnectionMonitoring();

      // Start connectivity monitoring
      _startConnectivityMonitoring();

      // Process message queue
      await _processMessageQueue();

      _log('✅ Connected to WebSocket successfully');
      _emitEvent(WebSocketEvent(
        type: WebSocketEventType.connected,
        message: 'Connected to WebSocket server',
        timestamp: DateTime.now(),
      ));

      return const Right(null);
    } catch (e) {
      _isConnecting = false;
      _isConnected = false;
      
      _log('❌ Failed to connect to WebSocket: $e');
      _emitEvent(WebSocketEvent(
        type: WebSocketEventType.connectionFailed,
        message: 'Failed to connect to WebSocket server',
        timestamp: DateTime.now(),
        metadata: {'error': e.toString()},
      ));

      // Attempt reconnection if enabled
      if (_shouldReconnect) {
        _scheduleReconnect();
      }

      return Left(WebSocketError(
        code: 'CONNECTION_FAILED',
        message: 'Failed to connect to WebSocket server',
        details: e.toString(),
      ));
    }
  }

  /// Create connection with timeout
  Future<WebSocketChannel?> _createConnectionWithTimeout() async {
    try {
      return await _createConnection().timeout(
        connectionTimeout,
        onTimeout: () {
          throw WebSocketException('Connection timeout');
        },
      );
    } catch (e) {
      _log('❌ Connection creation failed: $e');
      return null;
    }
  }

  /// Create WebSocket connection
  Future<WebSocketChannel> _createConnection() async {
    try {
      Uri uri = Uri.parse(url);
      
      // Add headers if provided
      if (headers != null && headers!.isNotEmpty) {
        uri = uri.replace(
          queryParameters: {
            ...uri.queryParameters,
            ...headers,
          },
        );
      }

      WebSocketChannel channel;
      
      if (uri.scheme == 'wss') {
        // Secure WebSocket connection
        channel = WebSocketChannel.connect(
          uri,
          protocols: ['vedantatrade-v1'],
        );
      } else {
        // Regular WebSocket connection
        channel = WebSocketChannel.connect(uri);
      }

      return channel;
    } catch (e) {
      throw WebSocketException('Failed to create WebSocket channel: $e');
    }
  }

  /// Send handshake message
  Future<void> _sendHandshake() async {
    try {
      final handshake = WebSocketMessage(
        id: _generateMessageId(),
        type: WebSocketMessageType.handshake,
        data: {
          'client': 'vedantatrade-app',
          'version': '1.0.0',
          'timestamp': DateTime.now().toIso8601String(),
          'platform': Platform.operatingSystem,
        },
        timestamp: DateTime.now(),
      );

      await _sendMessage(handshake);
      _log('🤝 Handshake sent');
    } catch (e) {
      _log('❌ Failed to send handshake: $e');
      throw WebSocketException('Handshake failed: $e');
    }
  }

  /// Disconnect from WebSocket server
  Future<Either<WebSocketError, void>> disconnect() async {
    try {
      _shouldReconnect = false;
      _reconnectTimer?.cancel();
      _heartbeatTimer?.cancel();
      _connectionCheckTimer?.cancel();
      _connectivitySubscription?.cancel();

      if (_channel != null) {
        // Send disconnect message
        try {
          final disconnectMessage = WebSocketMessage(
            id: _generateMessageId(),
            type: WebSocketMessageType.disconnect,
            data: {'reason': 'client_disconnect'},
            timestamp: DateTime.now(),
          );
          await _sendMessage(disconnectMessage);
        } catch (e) {
          _log('⚠️ Failed to send disconnect message: $e');
        }

        // Close connection
        await _channel!.sink.close();
        _channel = null;
      }

      _isConnected = false;
      _isConnecting = false;

      // Clear pending requests
      for (final completer in _pendingRequests.values) {
        completer.completeError(
          WebSocketException('Connection closed'),
        );
      }
      _pendingRequests.clear();

      // Clear request timeouts
      for (final timer in _requestTimeouts.values) {
        timer.cancel();
      }
      _requestTimeouts.clear();

      _log('🔌 Disconnected from WebSocket');
      _emitEvent(WebSocketEvent(
        type: WebSocketEventType.disconnected,
        message: 'Disconnected from WebSocket server',
        timestamp: DateTime.now(),
      ));

      return const Right(null);
    } catch (e) {
      _log('❌ Failed to disconnect: $e');
      return Left(WebSocketError(
        code: 'DISCONNECT_FAILED',
        message: 'Failed to disconnect from WebSocket server',
        details: e.toString(),
      ));
    }
  }

  /// Send message
  Future<Either<WebSocketError, void>> sendMessage(WebSocketMessage message) async {
    try {
      if (!_isConnected) {
        // Queue message for later
        _messageQueue.add(message);
        _log('📝 Message queued: ${message.type}');
        return const Right(null);
      }

      await _sendMessage(message);
      return const Right(null);
    } catch (e) {
      _log('❌ Failed to send message: $e');
      return Left(WebSocketError(
        code: 'SEND_FAILED',
        message: 'Failed to send message',
        details: e.toString(),
      ));
    }
  }

  /// Send message implementation
  Future<void> _sendMessage(WebSocketMessage message) async {
    try {
      if (_channel == null) {
        throw WebSocketException('No active connection');
      }

      final jsonMessage = jsonEncode(message.toMap());
      _channel!.sink.add(jsonMessage);
      
      _log('📤 Message sent: ${message.type} (${message.id})');
      
      _emitEvent(WebSocketEvent(
        type: WebSocketEventType.messageSent,
        message: 'Message sent to server',
        timestamp: DateTime.now(),
        metadata: {
          'message_type': message.type.name,
          'message_id': message.id,
        },
      ));
    } catch (e) {
      _log('❌ Failed to send message: $e');
      throw WebSocketException('Failed to send message: $e');
    }
  }

  /// Send request and wait for response
  Future<Either<WebSocketError, WebSocketMessage>> sendRequest(
    WebSocketMessage request, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    try {
      final completer = Completer<WebSocketMessage>();
      _pendingRequests[request.id] = completer;

      // Set timeout
      _requestTimeouts[request.id] = Timer(timeout, () {
        _pendingRequests.remove(request.id);
        _requestTimeouts.remove(request.id);
        completer.completeError(
          WebSocketException('Request timeout'),
        );
      });

      // Send request
      final sendResult = await sendMessage(request);
      
      return sendResult.fold(
        (error) => Left(error),
        (_) => Right(await completer.future),
      );
    } catch (e) {
      _log('❌ Failed to send request: $e');
      return Left(WebSocketError(
        code: 'REQUEST_FAILED',
        message: 'Failed to send request',
        details: e.toString(),
      ));
    }
  }

  /// Handle incoming message
  void _handleMessage(dynamic data) {
    try {
      if (data == null) return;

      final jsonString = data.toString();
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
      
      final message = WebSocketMessage.fromMap(jsonData);
      _lastMessageTime = DateTime.now();

      _log('📥 Message received: ${message.type} (${message.id})');

      // Handle response to pending request
      if (message.type == WebSocketMessageType.response && 
          message.data.containsKey('request_id')) {
        final requestId = message.data['request_id'] as String;
        final completer = _pendingRequests.remove(requestId);
        
        if (completer != null) {
          final timeoutTimer = _requestTimeouts.remove(requestId);
          timeoutTimer?.cancel();
          completer.complete(message);
        }
      }

      // Handle heartbeat
      if (message.type == WebSocketMessageType.heartbeat) {
        _handleHeartbeat(message);
        return;
      }

      // Emit message to stream
      _messageController.add(message);

      _emitEvent(WebSocketEvent(
        type: WebSocketEventType.messageReceived,
        message: 'Message received from server',
        timestamp: DateTime.now(),
        metadata: {
          'message_type': message.type.name,
          'message_id': message.id,
        },
      ));
    } catch (e) {
      _log('❌ Failed to handle message: $e');
      _emitEvent(WebSocketEvent(
        type: WebSocketEventType.messageError,
        message: 'Failed to handle message',
        timestamp: DateTime.now(),
        metadata: {'error': e.toString()},
      ));
    }
  }

  /// Handle WebSocket error
  void _handleError(dynamic error) {
    _log('❌ WebSocket error: $error');
    
    _isConnected = false;
    _isConnecting = false;

    _emitEvent(WebSocketEvent(
      type: WebSocketEventType.error,
      message: 'WebSocket error occurred',
      timestamp: DateTime.now(),
      metadata: {'error': error.toString()},
    ));

    // Attempt reconnection if enabled
    if (_shouldReconnect) {
      _scheduleReconnect();
    }
  }

  /// Handle WebSocket close
  void _handleClose() {
    _log('🔌 WebSocket connection closed');
    
    _isConnected = false;
    _isConnecting = false;

    _emitEvent(WebSocketEvent(
      type: WebSocketEventType.disconnected,
      message: 'WebSocket connection closed',
      timestamp: DateTime.now(),
    ));

    // Attempt reconnection if enabled
    if (_shouldReconnect) {
      _scheduleReconnect();
    }
  }

  /// Handle heartbeat message
  void _handleHeartbeat(WebSocketMessage message) {
    try {
      // Send pong response
      final pongMessage = WebSocketMessage(
        id: _generateMessageId(),
        type: WebSocketMessageType.pong,
        data: {
          'timestamp': DateTime.now().toIso8601String(),
          'original_timestamp': message.data['timestamp'],
        },
        timestamp: DateTime.now(),
      );

      _sendMessage(pongMessage);
      _log('💓 Heartbeat response sent');
    } catch (e) {
      _log('❌ Failed to handle heartbeat: $e');
    }
  }

  /// Start heartbeat
  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (!_isConnected) return;

      try {
        final heartbeatMessage = WebSocketMessage(
          id: _generateMessageId(),
          type: WebSocketMessageType.heartbeat,
          data: {
            'timestamp': DateTime.now().toIso8601String(),
            'client_id': 'vedantatrade-app',
          },
          timestamp: DateTime.now(),
        );

        _sendMessage(heartbeatMessage);
        _log('💓 Heartbeat sent');
      } catch (e) {
        _log('❌ Failed to send heartbeat: $e');
      }
    });

    _log('💓 Heartbeat started');
  }

  /// Start connection monitoring
  void _startConnectionMonitoring() {
    _connectionCheckTimer?.cancel();
    
    _connectionCheckTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (!_isConnected) return;

      // Check if we've received a message recently
      if (_lastMessageTime != null) {
        final timeSinceLastMessage = DateTime.now().difference(_lastMessageTime!);
        
        // If no message for 60 seconds, consider connection stale
        if (timeSinceLastMessage.inSeconds > 60) {
          _log('⚠️ Connection appears stale, reconnecting...');
          _reconnect();
        }
      }
    });

    _log('🔍 Connection monitoring started');
  }

  /// Start connectivity monitoring
  void _startConnectivityMonitoring() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((result) {
      if (result == ConnectivityResult.none) {
        _log('📵 Network connection lost');
        _emitEvent(WebSocketEvent(
          type: WebSocketEventType.networkLost,
          message: 'Network connection lost',
          timestamp: DateTime.now(),
        ));
      } else {
        _log('📵 Network connection restored');
        _emitEvent(WebSocketEvent(
          type: WebSocketEventType.networkRestored,
          message: 'Network connection restored',
          timestamp: DateTime.now(),
        ));
        
        // Reconnect if not connected
        if (!_isConnected && !_isConnecting) {
          _reconnect();
        }
      }
    });

    _log('📵 Connectivity monitoring started');
  }

  /// Schedule reconnection
  void _scheduleReconnect() {
    if (_reconnectAttempts >= maxReconnectAttempts) {
      _log('❌ Max reconnection attempts reached');
      _emitEvent(WebSocketEvent(
        type: WebSocketEventType.reconnectFailed,
        message: 'Max reconnection attempts reached',
        timestamp: DateTime.now(),
      ));
      return;
    }

    _reconnectTimer?.cancel();
    
    final delay = reconnectDelay * (_reconnectAttempts + 1);
    _reconnectTimer = Timer(delay, () {
      _reconnect();
    });

    _log('⏰ Reconnection scheduled in ${delay.inSeconds} seconds (attempt ${_reconnectAttempts + 1}/$maxReconnectAttempts)');
  }

  /// Reconnect to WebSocket server
  Future<void> _reconnect() async {
    if (_isConnecting) return;

    _log('🔄 Reconnecting to WebSocket...');
    _reconnectAttempts++;

    // Close existing connection
    if (_channel != null) {
      await _channel!.sink.close();
      _channel = null;
    }

    _isConnected = false;
    _isConnecting = false;

    // Attempt to reconnect
    final result = await connect();
    
    result.fold(
      (error) => _log('❌ Reconnection failed: ${error.message}'),
      (_) => _log('✅ Reconnection successful'),
    );
  }

  /// Process message queue
  Future<void> _processMessageQueue() async {
    if (_messageQueue.isEmpty) return;

    _log('📝 Processing ${_messageQueue.length} queued messages');

    final messages = List.from(_messageQueue);
    _messageQueue.clear();

    for (final message in messages) {
      final result = await sendMessage(message);
      result.fold(
        (error) => _log('❌ Failed to send queued message: ${error.message}'),
        (_) => _log('✅ Queued message sent: ${message.type}'),
      );
    }
  }

  /// Generate unique message ID
  String _generateMessageId() {
    return 'msg_${DateTime.now().millisecondsSinceEpoch}_${_messageIdCounter++}';
  }

  /// Emit event
  void _emitEvent(WebSocketEvent event) {
    _eventController.add(event);
  }

  /// Log message
  void _log(String message) {
    if (enableLogging) {
      print('[WebSocketManager] $message');
    }
  }

  /// Dispose resources
  void dispose() {
    _log('🗑️ Disposing WebSocket Manager...');
    
    disconnect();
    _messageController.close();
    _eventController.close();
    
    _log('✅ WebSocket Manager disposed');
  }
}

/// WebSocket Message Entity
class WebSocketMessage {
  final String id;
  final WebSocketMessageType type;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  const WebSocketMessage({
    required this.id,
    required this.type,
    required this.data,
    required this.timestamp,
  });

  /// Create WebSocketMessage from JSON map
  factory WebSocketMessage.fromMap(Map<String, dynamic> map) {
    return WebSocketMessage(
      id: map['id'] as String,
      type: WebSocketMessageType.values.firstWhere(
        (type) => type.name == map['type'],
        orElse: () => WebSocketMessageType.unknown,
      ),
      data: map['data'] as Map<String, dynamic>? ?? {},
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }

  /// Convert to JSON map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Copy with updated fields
  WebSocketMessage copyWith({
    String? id,
    WebSocketMessageType? type,
    Map<String, dynamic>? data,
    DateTime? timestamp,
  }) {
    return WebSocketMessage(
      id: id ?? this.id,
      type: type ?? this.type,
      data: data ?? this.data,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

/// WebSocket Event Entity
class WebSocketEvent {
  final WebSocketEventType type;
  final String message;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  const WebSocketEvent({
    required this.type,
    required this.message,
    required this.timestamp,
    this.metadata = const {},
  });
}

/// WebSocket Error Entity
class WebSocketError {
  final String code;
  final String message;
  final String details;

  const WebSocketError({
    required this.code,
    required this.message,
    required this.details,
  });
}

/// WebSocket Exception
class WebSocketException implements Exception {
  final String message;
  
  const WebSocketException(this.message);
  
  @override
  String toString() => 'WebSocketException: $message';
}

// Enums
enum WebSocketMessageType {
  handshake,
  disconnect,
  heartbeat,
  pong,
  request,
  response,
  notification,
  data,
  error,
  unknown,
}

enum WebSocketEventType {
  connecting,
  connected,
  disconnected,
  connectionFailed,
  reconnectFailed,
  messageSent,
  messageReceived,
  messageError,
  error,
  networkLost,
  networkRestored,
}

enum WebSocketConnectionState {
  disconnected,
  connecting,
  connected,
  reconnecting,
  error,
}

// Either type for error handling
class Either<L, R> {
  final L? _left;
  final R? _right;
  final bool _isLeft;

  const Either.left(L value) : _left = value, _right = null, _isLeft = true;
  const Either.right(R value) : _left = null, _right = value, _isLeft = false;

  bool isLeft() => _isLeft;
  bool isRight() => !_isLeft;

  L? get left => _left;
  R? get right => _right;

  T fold<T>(T Function(L) ifLeft, T Function(R) ifRight) {
    return _isLeft ? ifLeft(_left!) : ifRight(_right!);
  }
}
