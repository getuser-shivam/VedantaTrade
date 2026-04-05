import 'dart:async';
import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../domain/entities/order.dart';
import '../../domain/repositories/order_repository.dart';

/// Order Repository Implementation
/// SQLite-based implementation with real-time order management and WebSocket integration
class OrderRepositoryImpl implements OrderRepository {
  final DatabaseHelper _databaseHelper;
  final WebSocketChannel? _webSocketChannel;
  final StreamController<Order> _orderStreamController;
  final Map<String, Order> _cachedOrders = {};
  final Map<String, List<Order>> _ordersByStatus = {};
  Timer? _syncTimer;
  bool _isConnected = false;

  OrderRepositoryImpl(this._databaseHelper, {String? webSocketUrl})
    : _orderStreamController = StreamController<Order>.broadcast(),
      _webSocketChannel = webSocketUrl != null 
          ? WebSocketChannel.connect(Uri.parse(webSocketUrl))
          : null;

  /// Stream of order updates
  Stream<Order> get orderStream => _orderStreamController.stream;

  /// Initialize repository
  Future<void> initialize() async {
    try {
      print('🔍 Initializing Order Repository...');
      
      await _databaseHelper.initialize();
      await _createTables();
      await _loadCachedOrders();
      
      if (_webSocketChannel != null) {
        await _connectWebSocket();
      }
      
      // Start periodic sync
      _startPeriodicSync();
      
      print('✅ Order Repository initialized successfully');
    } catch (e) {
      print('❌ Failed to initialize Order Repository: $e');
      rethrow;
    }
  }

  @override
  Future<Either<Failure, void>> saveOrder(Order order) async {
    try {
      print('💾 Saving order: ${order.orderNumber}');
      
      // Save to database
      final db = await _databaseHelper.database;
      await db.insert(
        'orders',
        order.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      
      // Update cache
      _cachedOrders[order.id] = order;
      _updateStatusCache(order);
      
      // Send WebSocket notification
      await _sendOrderNotification(order, 'created');
      
      // Add to stream
      _orderStreamController.add(order);
      
      print('✅ Order saved successfully: ${order.orderNumber}');
      return const Right(null);
    } catch (e) {
      print('❌ Failed to save order: $e');
      return Left(Failure(
        message: 'Failed to save order',
        code: 'SAVE_ERROR',
        details: e,
      ));
    }
  }

  @override
  Future<Either<Failure, Order?>> getOrderById(String id) async {
    try {
      print('🔍 Getting order by ID: $id');
      
      // Check cache first
      if (_cachedOrders.containsKey(id)) {
        print('✅ Order found in cache: $id');
        return Right(_cachedOrders[id]);
      }
      
      // Query database
      final db = await _databaseHelper.database;
      final maps = await db.query(
        'orders',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      
      if (maps.isEmpty) {
        print('⚠️ Order not found: $id');
        return const Right(null);
      }
      
      final order = Order.fromMap(maps.first);
      _cachedOrders[id] = order;
      
      print('✅ Order retrieved: ${order.orderNumber}');
      return Right(order);
    } catch (e) {
      print('❌ Failed to get order: $e');
      return Left(Failure(
        message: 'Failed to get order',
        code: 'RETRIEVE_ERROR',
        details: e,
      ));
    }
  }

  @override
  Future<Either<Failure, List<Order>>> getOrdersByRetailer({
    required String retailerId,
    OrderStatus? status,
    int? limit,
  }) async {
    try {
      print('🔍 Getting orders for retailer: $retailerId');
      
      String whereClause = 'retailer_id = ?';
      List<dynamic> whereArgs = [retailerId];
      
      if (status != null) {
        whereClause += ' AND status = ?';
        whereArgs.add(status.name);
      }
      
      final db = await _databaseHelper.database;
      final maps = await db.query(
        'orders',
        where: whereClause,
        whereArgs: whereArgs,
        orderBy: 'created_at DESC',
        limit: limit,
      );
      
      final orders = maps.map((map) => Order.fromMap(map)).toList();
      
      print('✅ Retrieved ${orders.length} orders for retailer: $retailerId');
      return Right(orders);
    } catch (e) {
      print('❌ Failed to get orders for retailer: $e');
      return Left(Failure(
        message: 'Failed to get orders for retailer',
        code: 'RETRIEVE_ERROR',
        details: e,
      ));
    }
  }

  @override
  Future<Either<Failure, List<Order>>> getOrdersByStockist({
    required String stockistId,
    OrderStatus? status,
    int? limit,
  }) async {
    try {
      print('🔍 Getting orders for stockist: $stockistId');
      
      String whereClause = 'stockist_id = ?';
      List<dynamic> whereArgs = [stockistId];
      
      if (status != null) {
        whereClause += ' AND status = ?';
        whereArgs.add(status.name);
      }
      
      final db = await _databaseHelper.database;
      final maps = await db.query(
        'orders',
        where: whereClause,
        whereArgs: whereArgs,
        orderBy: 'created_at DESC',
        limit: limit,
      );
      
      final orders = maps.map((map) => Order.fromMap(map)).toList();
      
      print('✅ Retrieved ${orders.length} orders for stockist: $stockistId');
      return Right(orders);
    } catch (e) {
      print('❌ Failed to get orders for stockist: $e');
      return Left(Failure(
        message: 'Failed to get orders for stockist',
        code: 'RETRIEVE_ERROR',
        details: e,
      ));
    }
  }

  @override
  Future<Either<Failure, List<Order>>> getOrdersByStatus({
    required OrderStatus status,
    int? limit,
  }) async {
    try {
      print('🔍 Getting orders by status: ${status.name}');
      
      final db = await _databaseHelper.database;
      final maps = await db.query(
        'orders',
        where: 'status = ?',
        whereArgs: [status.name],
        orderBy: 'created_at DESC',
        limit: limit,
      );
      
      final orders = maps.map((map) => Order.fromMap(map)).toList();
      
      print('✅ Retrieved ${orders.length} orders with status: ${status.name}');
      return Right(orders);
    } catch (e) {
      print('❌ Failed to get orders by status: $e');
      return Left(Failure(
        message: 'Failed to get orders by status',
        code: 'RETRIEVE_ERROR',
        details: e,
      ));
    }
  }

  @override
  Future<Either<Failure, List<Order>>> getOrdersByDateRange({
    required DateTime startDate,
    required DateTime endDate,
    String? mrId,
  }) async {
    try {
      print('🔍 Getting orders by date range: $startDate to $endDate');
      
      String whereClause = 'created_at >= ? AND created_at <= ?';
      List<dynamic> whereArgs = [startDate.toIso8601String(), endDate.toIso8601String()];
      
      if (mrId != null) {
        whereClause += ' AND mr_id = ?';
        whereArgs.add(mrId);
      }
      
      final db = await _databaseHelper.database;
      final maps = await db.query(
        'orders',
        where: whereClause,
        whereArgs: whereArgs,
        orderBy: 'created_at DESC',
      );
      
      final orders = maps.map((map) => Order.fromMap(map)).toList();
      
      print('✅ Retrieved ${orders.length} orders for date range');
      return Right(orders);
    } catch (e) {
      print('❌ Failed to get orders by date range: $e');
      return Left(Failure(
        message: 'Failed to get orders by date range',
        code: 'RETRIEVE_ERROR',
        details: e,
      ));
    }
  }

  @override
  Future<Either<Failure, void>> updateOrder(Order order) async {
    try {
      print('📝 Updating order: ${order.orderNumber}');
      
      // Update database
      final db = await _databaseHelper.database;
      await db.update(
        'orders',
        order.toMap(),
        where: 'id = ?',
        whereArgs: [order.id],
      );
      
      // Update cache
      _cachedOrders[order.id] = order;
      _updateStatusCache(order);
      
      // Send WebSocket notification
      await _sendOrderNotification(order, 'updated');
      
      // Add to stream
      _orderStreamController.add(order);
      
      print('✅ Order updated successfully: ${order.orderNumber}');
      return const Right(null);
    } catch (e) {
      print('❌ Failed to update order: $e');
      return Left(Failure(
        message: 'Failed to update order',
        code: 'UPDATE_ERROR',
        details: e,
      ));
    }
  }

  @override
  Future<Either<Failure, void>> deleteOrder(String id) async {
    try {
      print('🗑️ Deleting order: $id');
      
      // Delete from database
      final db = await _databaseHelper.database;
      await db.delete(
        'orders',
        where: 'id = ?',
        whereArgs: [id],
      );
      
      // Remove from cache
      _cachedOrders.remove(id);
      _removeFromStatusCache(id);
      
      // Send WebSocket notification
      final order = _cachedOrders[id];
      if (order != null) {
        await _sendOrderNotification(order, 'deleted');
      }
      
      print('✅ Order deleted successfully: $id');
      return const Right(null);
    } catch (e) {
      print('❌ Failed to delete order: $e');
      return Left(Failure(
        message: 'Failed to delete order',
        code: 'DELETE_ERROR',
        details: e,
      ));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getOrderStatistics({
    String? retailerId,
    String? stockistId,
    String? mrId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      print('📊 Getting order statistics...');
      
      String whereClause = '1=1';
      List<dynamic> whereArgs = [];
      
      if (retailerId != null) {
        whereClause += ' AND retailer_id = ?';
        whereArgs.add(retailerId);
      }
      
      if (stockistId != null) {
        whereClause += ' AND stockist_id = ?';
        whereArgs.add(stockistId);
      }
      
      if (mrId != null) {
        whereClause += ' AND mr_id = ?';
        whereArgs.add(mrId);
      }
      
      if (startDate != null) {
        whereClause += ' AND created_at >= ?';
        whereArgs.add(startDate.toIso8601String());
      }
      
      if (endDate != null) {
        whereClause += ' AND created_at <= ?';
        whereArgs.add(endDate.toIso8601String());
      }
      
      final db = await _databaseHelper.database;
      
      // Get total orders
      final totalResult = await db.rawQuery(
        'SELECT COUNT(*) as total FROM orders WHERE $whereClause',
        whereArgs,
      );
      
      // Get orders by status
      final statusResult = await db.rawQuery('''
        SELECT status, COUNT(*) as count 
        FROM orders 
        WHERE $whereClause 
        GROUP BY status
        ORDER BY count DESC
      ''', whereArgs);
      
      // Get total amount
      final amountResult = await db.rawQuery(
        'SELECT SUM(final_amount) as total_amount FROM orders WHERE $whereClause',
        whereArgs,
      );
      
      // Get recent orders
      final recentResult = await db.rawQuery('''
        SELECT COUNT(*) as recent_count 
        FROM orders 
        WHERE $whereClause 
        AND created_at >= date('now', '-7 days')
      ''', whereArgs);
      
      final totalOrders = totalResult.first['total'] as int;
      final totalAmount = amountResult.first['total_amount'] as double;
      final recentOrders = recentResult.first['recent_count'] as int;
      
      final statistics = {
        'total_orders': totalOrders,
        'total_amount': totalAmount,
        'recent_orders': recentOrders,
        'orders_by_status': Map.fromEntries(
          statusResult.map((row) => MapEntry(
            row['status'] as String,
            {
              'count': row['count'] as int,
              'percentage': ((row['count'] as int) / totalOrders * 100).toStringAsFixed(1),
            },
          )),
        ),
        'retailer_id': retailerId,
        'stockist_id': stockistId,
        'mr_id': mrId,
        'start_date': startDate?.toIso8601String(),
        'end_date': endDate?.toIso8601String(),
        'generated_at': DateTime.now().toIso8601String(),
      };
      
      print('✅ Order statistics calculated');
      return Right(statistics);
    } catch (e) {
      print('❌ Failed to get order statistics: $e');
      return Left(Failure(
        message: 'Failed to get order statistics',
        code: 'STATISTICS_ERROR',
        details: e,
      ));
    }
  }

  /// Create database tables
  Future<void> _createTables() async {
    try {
      final db = await _databaseHelper.database;
      
      await db.execute('''
        CREATE TABLE IF NOT EXISTS orders (
          id TEXT PRIMARY KEY,
          order_number TEXT UNIQUE NOT NULL,
          retailer_id TEXT NOT NULL,
          stockist_id TEXT NOT NULL,
          mr_id TEXT NOT NULL,
          items TEXT NOT NULL,
          status TEXT NOT NULL,
          created_at TEXT NOT NULL,
          approved_at TEXT,
          dispatched_at TEXT,
          delivered_at TEXT,
          paid_at TEXT,
          total_amount REAL NOT NULL,
          discount_amount REAL DEFAULT 0.0,
          tax_amount REAL DEFAULT 0.0,
          final_amount REAL NOT NULL,
          payment_method TEXT NOT NULL,
          payment_status TEXT NOT NULL,
          delivery_address TEXT,
          delivery_notes TEXT,
          invoice_number TEXT,
          tracking_number TEXT,
          attachments TEXT DEFAULT '[]',
          metadata TEXT DEFAULT '{}'
        )
      ''');
      
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_orders_retailer_id ON orders (retailer_id)
      ''');
      
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_orders_stockist_id ON orders (stockist_id)
      ''');
      
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_orders_mr_id ON orders (mr_id)
      ''');
      
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_orders_status ON orders (status)
      ''');
      
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_orders_created_at ON orders (created_at)
      ''');
      
      print('✅ Database tables created successfully');
    } catch (e) {
      print('❌ Failed to create database tables: $e');
      rethrow;
    }
  }

  /// Load cached orders
  Future<void> _loadCachedOrders() async {
    try {
      final db = await _databaseHelper.database;
      final maps = await db.query('orders');
      
      for (final map in maps) {
        final order = Order.fromMap(map);
        _cachedOrders[order.id] = order;
        _updateStatusCache(order);
      }
      
      print('✅ Loaded ${_cachedOrders.length} orders into cache');
    } catch (e) {
      print('❌ Failed to load cached orders: $e');
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

  /// Remove from status cache
  void _removeFromStatusCache(String orderId) {
    _ordersByStatus.forEach((status, orders) {
      orders.removeWhere((order) => order.id == orderId);
    });
  }

  /// Connect to WebSocket
  Future<void> _connectWebSocket() async {
    try {
      if (_webSocketChannel == null) return;
      
      print('🌐 Connecting to WebSocket...');
      
      _webSocketChannel!.stream.listen(
        (data) {
          try {
            final message = jsonDecode(data as String);
            _handleWebSocketMessage(message);
          } catch (e) {
            print('❌ Failed to handle WebSocket message: $e');
          }
        },
        onError: (error) {
          print('❌ WebSocket error: $error');
          _isConnected = false;
        },
        onDone: () {
          print('🔌 WebSocket connection closed');
          _isConnected = false;
        },
      );
      
      _webSocketChannel!.sink.add(jsonEncode({
        'type': 'connect',
        'timestamp': DateTime.now().toIso8601String(),
        'client': 'vedantatrade-app',
        'version': '1.0.0',
      }));
      
      print('✅ WebSocket connected successfully');
      _isConnected = true;
    } catch (e) {
      print('❌ Failed to connect to WebSocket: $e');
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
          print('⚠️ Unknown WebSocket message type: $type');
      }
    } catch (e) {
      print('❌ Failed to handle WebSocket message: $e');
    }
  }

  /// Handle order update
  void _handleOrderUpdate(Map<String, dynamic> data) {
    try {
      final orderData = data['order'] as Map<String, dynamic>;
      
      if (orderData.isEmpty) return;
      
      final order = Order.fromMap(orderData);
      
      // Update cache
      _cachedOrders[order.id] = order;
      _updateStatusCache(order);
      
      // Add to stream
      _orderStreamController.add(order);
      
      print('✅ Order updated via WebSocket: ${order.orderNumber}');
    } catch (e) {
      print('❌ Failed to handle order update: $e');
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
      print('❌ Failed to handle ping: $e');
    }
  }

  /// Handle sync request
  void _handleSyncRequest(Map<String, dynamic> data) {
    try {
      final lastSyncTime = data['last_sync_time'] as String?;
      final limit = data['limit'] as int? ?? 100;
      
      // Get recent orders
      final db = await _databaseHelper.database;
      final maps = await db.query(
        'orders',
        where: lastSyncTime != null 
            ? 'created_at > ?' 
            : '1=1',
        whereArgs: lastSyncTime != null ? [lastSyncTime] : [],
        orderBy: 'created_at DESC',
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
      
      print('✅ Sync response sent: ${orders.length} orders');
    } catch (e) {
      print('❌ Failed to handle sync request: $e');
    }
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
      };
      
      _webSocketChannel!.sink.add(jsonEncode(notification));
      
      print('✅ Order notification sent: $action - ${order.orderNumber}');
    } catch (e) {
      print('❌ Failed to send order notification: $e');
    }
  }

  /// Start periodic sync
  void _startPeriodicSync() {
    _syncTimer?.cancel();
    
    _syncTimer = Timer.periodic(const Duration(minutes: 5), (timer) async {
      if (!_isConnected) return;
      
      try {
        final db = await _databaseHelper.database;
        final maps = await db.query(
          'orders',
          where: 'updated_at > ?',
          whereArgs: [DateTime.now().subtract(const Duration(minutes: 5)).toIso8601String()],
          limit: 50,
        );
        
        final orders = maps.map((map) => Order.fromMap(map)).toList();
        
        if (orders.isNotEmpty) {
          for (final order in orders) {
            await _sendOrderNotification(order, 'sync');
          }
        }
      } catch (e) {
        print('❌ Failed to sync orders: $e');
      }
    });
  }

  /// Dispose resources
  void dispose() {
    print('🗑️ Disposing Order Repository...');
    
    _syncTimer?.cancel();
    _webSocketChannel?.sink.close();
    _orderStreamController.close();
    
    print('✅ Order Repository disposed');
  }
}

/// Database helper for order management
class DatabaseHelper {
  Database? _database;
  
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }
  
  Future<Database> _initDatabase() async {
    try {
      final databasesPath = await getDatabasesPath();
      final path = join(databasesPath, 'vedantatrade.db');
      
      final database = await openDatabase(
        path,
        version: 1,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
      
      print('✅ Database initialized: $path');
      return database;
    } catch (e) {
      print('❌ Failed to initialize database: $e');
      rethrow;
    }
  }
  
  Future<void> _onCreate(Database db, int version) async {
    try {
      await db.execute('PRAGMA foreign_keys = ON');
      print('✅ Database created with version $version');
    } catch (e) {
      print('❌ Failed to create database: $e');
    }
  }
  
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    try {
      print('🔄 Upgrading database from version $oldVersion to $newVersion');
      
      // Handle database upgrades here
      await db.execute('DROP TABLE IF EXISTS orders');
      await _createTables();
      
      print('✅ Database upgraded to version $newVersion');
    } catch (e) {
      print('❌ Failed to upgrade database: $e');
    }
  }
}
