import 'dart:async';
import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../domain/entities/inventory.dart';
import '../../domain/repositories/inventory_repository.dart';

/// Inventory Repository Implementation
/// SQLite-based implementation with real-time stock monitoring and alerts
class InventoryRepositoryImpl implements InventoryRepository {
  final DatabaseHelper _databaseHelper;
  final StreamController<Inventory> _inventoryStreamController;
  final StreamController<StockAlert> _alertStreamController;
  final Map<String, Inventory> _cachedInventory = {};
  final Map<String, StockAlert> _activeAlerts = {};
  Timer? _stockCheckTimer;
  Timer? _expiryCheckTimer;
  bool _isInitialized = false;

  InventoryRepositoryImpl(this._databaseHelper)
    : _inventoryStreamController = StreamController<Inventory>.broadcast(),
      _alertStreamController = StreamController<StockAlert>.broadcast();

  /// Stream of inventory updates
  Stream<Inventory> get inventoryStream => _inventoryStreamController.stream;

  /// Stream of stock alerts
  Stream<StockAlert> get alertStream => _alertStreamController.stream;

  /// Initialize repository
  Future<void> initialize() async {
    try {
      if (_isInitialized) return;
      
// print('🔍 Initializing Inventory Repository...'); // Removed for production
      
      await _databaseHelper.initialize();
      await _createTables();
      await _loadCachedInventory();
      await _loadActiveAlerts();
      
      // Start monitoring
      _startStockMonitoring();
      _startExpiryMonitoring();
      
      _isInitialized = true;
// print('✅ Inventory Repository initialized successfully'); // Removed for production
    } catch (e) {
// print('❌ Failed to initialize Inventory Repository: $e'); // Removed for production
      rethrow;
    }
  }

  @override
  Future<Either<Failure, void>> saveInventory(Inventory inventory) async {
    try {
// print('💾 Saving inventory: ${inventory.sku}'); // Removed for production
      
      // Save to database
      final db = await _databaseHelper.database;
      await db.insert(
        'inventory',
        inventory.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      
      // Update cache
      _cachedInventory[inventory.id] = inventory;
      
      // Send to stream
      _inventoryStreamController.add(inventory);
      
      // Check for alerts
      await _checkForAlerts(inventory);
      
// print('✅ Inventory saved successfully: ${inventory.sku}'); // Removed for production
      return const Right(null);
    } catch (e) {
// print('❌ Failed to save inventory: $e'); // Removed for production
      return Left(Failure(
        message: 'Failed to save inventory',
        code: 'SAVE_ERROR',
        details: e,
      ));
    }
  }

  @override
  Future<Either<Failure, Inventory?>> getInventoryById(String id) async {
    try {
// print('🔍 Getting inventory by ID: $id'); // Removed for production
      
      // Check cache first
      if (_cachedInventory.containsKey(id)) {
// print('✅ Inventory found in cache: $id'); // Removed for production
        return Right(_cachedInventory[id]);
      }
      
      // Query database
      final db = await _databaseHelper.database;
      final maps = await db.query(
        'inventory',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      
      if (maps.isEmpty) {
// print('⚠️ Inventory not found: $id'); // Removed for production
        return const Right(null);
      }
      
      final inventory = Inventory.fromMap(maps.first);
      _cachedInventory[id] = inventory;
      
// print('✅ Inventory retrieved: ${inventory.sku}'); // Removed for production
      return Right(inventory);
    } catch (e) {
// print('❌ Failed to get inventory: $e'); // Removed for production
      return Left(Failure(
        message: 'Failed to get inventory',
        code: 'RETRIEVE_ERROR',
        details: e,
      ));
    }
  }

  @override
  Future<Either<Failure, Inventory?>> getInventoryBySku(String sku) async {
    try {
// print('🔍 Getting inventory by SKU: $sku'); // Removed for production
      
      // Check cache first
      final cachedItem = _cachedInventory.values
          .where((item) => item.sku == sku)
          .firstOrNull;
      
      if (cachedItem != null) {
// print('✅ Inventory found in cache: $sku'); // Removed for production
        return Right(cachedItem);
      }
      
      // Query database
      final db = await _databaseHelper.database;
      final maps = await db.query(
        'inventory',
        where: 'sku = ?',
        whereArgs: [sku],
        limit: 1,
      );
      
      if (maps.isEmpty) {
// print('⚠️ Inventory not found: $sku'); // Removed for production
        return const Right(null);
      }
      
      final inventory = Inventory.fromMap(maps.first);
      _cachedInventory[inventory.id] = inventory;
      
// print('✅ Inventory retrieved: ${inventory.sku}'); // Removed for production
      return Right(inventory);
    } catch (e) {
// print('❌ Failed to get inventory by SKU: $e'); // Removed for production
      return Left(Failure(
        message: 'Failed to get inventory by SKU',
        code: 'RETRIEVE_ERROR',
        details: e,
      ));
    }
  }

  @override
  Future<Either<Failure, List<Inventory>>> getInventoryByProductId(String productId) async {
    try {
// print('🔍 Getting inventory by product ID: $productId'); // Removed for production
      
      final db = await _databaseHelper.database;
      final maps = await db.query(
        'inventory',
        where: 'product_id = ?',
        whereArgs: [productId],
        orderBy: 'created_at DESC',
      );
      
      final inventory = maps.map((map) => Inventory.fromMap(map)).toList();
      
// print('✅ Retrieved ${inventory.length} inventory items for product: $productId'); // Removed for production
      return Right(inventory);
    } catch (e) {
// print('❌ Failed to get inventory by product ID: $e'); // Removed for production
      return Left(Failure(
        message: 'Failed to get inventory by product ID',
        code: 'RETRIEVE_ERROR',
        details: e,
      ));
    }
  }

  @override
  Future<Either<Failure, List<Inventory>>> getInventoryByStockist({
    required String stockistId,
    InventoryStatus? status,
    int? limit,
  }) async {
    try {
// print('🔍 Getting inventory for stockist: $stockistId'); // Removed for production
      
      String whereClause = 'stockist_id = ?';
      List<dynamic> whereArgs = [stockistId];
      
      if (status != null) {
        whereClause += ' AND status = ?';
        whereArgs.add(status.name);
      }
      
      final db = await _databaseHelper.database;
      final maps = await db.query(
        'inventory',
        where: whereClause,
        whereArgs: whereArgs,
        orderBy: 'created_at DESC',
        limit: limit,
      );
      
      final inventory = maps.map((map) => Inventory.fromMap(map)).toList();
      
// print('✅ Retrieved ${inventory.length} inventory items for stockist: $stockistId'); // Removed for production
      return Right(inventory);
    } catch (e) {
// print('❌ Failed to get inventory for stockist: $e'); // Removed for production
      return Left(Failure(
        message: 'Failed to get inventory for stockist',
        code: 'RETRIEVE_ERROR',
        details: e,
      ));
    }
  }

  @override
  Future<Either<Failure, List<Inventory>>> getInventoryByCategory({
    required String category,
    String? stockistId,
    InventoryStatus? status,
    int? limit,
  }) async {
    try {
// print('🔍 Getting inventory by category: $category'); // Removed for production
      
      String whereClause = 'category = ?';
      List<dynamic> whereArgs = [category];
      
      if (stockistId != null) {
        whereClause += ' AND stockist_id = ?';
        whereArgs.add(stockistId);
      }
      
      if (status != null) {
        whereClause += ' AND status = ?';
        whereArgs.add(status.name);
      }
      
      final db = await _databaseHelper.database;
      final maps = await db.query(
        'inventory',
        where: whereClause,
        whereArgs: whereArgs,
        orderBy: 'created_at DESC',
        limit: limit,
      );
      
      final inventory = maps.map((map) => Inventory.fromMap(map)).toList();
      
// print('✅ Retrieved ${inventory.length} inventory items for category: $category'); // Removed for production
      return Right(inventory);
    } catch (e) {
// print('❌ Failed to get inventory by category: $e'); // Removed for production
      return Left(Failure(
        message: 'Failed to get inventory by category',
        code: 'RETRIEVE_ERROR',
        details: e,
      ));
    }
  }

  @override
  Future<Either<Failure, List<Inventory>>> getLowStockItems({
    String? stockistId,
    int? limit,
  }) async {
    try {
// print('🔍 Getting low stock items...'); // Removed for production
      
      String whereClause = 'is_low_stock = 1';
      List<dynamic> whereArgs = [];
      
      if (stockistId != null) {
        whereClause += ' AND stockist_id = ?';
        whereArgs.add(stockistId);
      }
      
      final db = await _databaseHelper.database;
      final maps = await db.query(
        'inventory',
        where: whereClause,
        whereArgs: whereArgs,
        orderBy: 'current_stock ASC',
        limit: limit,
      );
      
      final inventory = maps.map((map) => Inventory.fromMap(map)).toList();
      
// print('✅ Retrieved ${inventory.length} low stock items'); // Removed for production
      return Right(inventory);
    } catch (e) {
// print('❌ Failed to get low stock items: $e'); // Removed for production
      return Left(Failure(
        message: 'Failed to get low stock items',
        code: 'RETRIEVE_ERROR',
        details: e,
      ));
    }
  }

  @override
  Future<Either<Failure, List<Inventory>>> getOutOfStockItems({
    String? stockistId,
    int? limit,
  }) async {
    try {
// print('🔍 Getting out of stock items...'); // Removed for production
      
      String whereClause = 'is_out_of_stock = 1';
      List<dynamic> whereArgs = [];
      
      if (stockistId != null) {
        whereClause += ' AND stockist_id = ?';
        whereArgs.add(stockistId);
      }
      
      final db = await _databaseHelper.database;
      final maps = await db.query(
        'inventory',
        where: whereClause,
        whereArgs: whereArgs,
        orderBy: 'created_at DESC',
        limit: limit,
      );
      
      final inventory = maps.map((map) => Inventory.fromMap(map)).toList();
      
// print('✅ Retrieved ${inventory.length} out of stock items'); // Removed for production
      return Right(inventory);
    } catch (e) {
// print('❌ Failed to get out of stock items: $e'); // Removed for production
      return Left(Failure(
        message: 'Failed to get out of stock items',
        code: 'RETRIEVE_ERROR',
        details: e,
      ));
    }
  }

  @override
  Future<Either<Failure, List<Inventory>>> getExpiringItems({
    int? daysThreshold,
    String? stockistId,
    int? limit,
  }) async {
    try {
// print('🔍 Getting expiring items...'); // Removed for production
      
      final threshold = daysThreshold ?? 30;
      final thresholdDate = DateTime.now().add(Duration(days: threshold));
      
      String whereClause = 'expiry_date <= ? AND expiry_date > ?';
      List<dynamic> whereArgs = [thresholdDate.toIso8601String(), DateTime.now().toIso8601String()];
      
      if (stockistId != null) {
        whereClause += ' AND stockist_id = ?';
        whereArgs.add(stockistId);
      }
      
      final db = await _databaseHelper.database;
      final maps = await db.query(
        'inventory',
        where: whereClause,
        whereArgs: whereArgs,
        orderBy: 'expiry_date ASC',
        limit: limit,
      );
      
      final inventory = maps.map((map) => Inventory.fromMap(map)).toList();
      
// print('✅ Retrieved ${inventory.length} expiring items'); // Removed for production
      return Right(inventory);
    } catch (e) {
// print('❌ Failed to get expiring items: $e'); // Removed for production
      return Left(Failure(
        message: 'Failed to get expiring items',
        code: 'RETRIEVE_ERROR',
        details: e,
      ));
    }
  }

  @override
  Future<Either<Failure, List<Inventory>>> getExpiredItems({
    String? stockistId,
    int? limit,
  }) async {
    try {
// print('🔍 Getting expired items...'); // Removed for production
      
      String whereClause = 'is_expired = 1';
      List<dynamic> whereArgs = [];
      
      if (stockistId != null) {
        whereClause += ' AND stockist_id = ?';
        whereArgs.add(stockistId);
      }
      
      final db = await _databaseHelper.database;
      final maps = await db.query(
        'inventory',
        where: whereClause,
        whereArgs: whereArgs,
        orderBy: 'expiry_date ASC',
        limit: limit,
      );
      
      final inventory = maps.map((map) => Inventory.fromMap(map)).toList();
      
// print('✅ Retrieved ${inventory.length} expired items'); // Removed for production
      return Right(inventory);
    } catch (e) {
// print('❌ Failed to get expired items: $e'); // Removed for production
      return Left(Failure(
        message: 'Failed to get expired items',
        code: 'RETRIEVE_ERROR',
        details: e,
      ));
    }
  }

  @override
  Future<Either<Failure, void>> updateInventoryStock({
    required String id,
    required int newStock,
    String? reason,
  }) async {
    try {
// print('📝 Updating inventory stock: $id -> $newStock'); // Removed for production
      
      final inventoryResult = await getInventoryById(id);
      
      return inventoryResult.fold(
        (error) => Left(error),
        (inventory) async {
          final updatedInventory = inventory.copyWith(
            currentStock: newStock,
            lastUpdated: DateTime.now(),
            metadata: {
              ...inventory.metadata,
              'stock_updated_at': DateTime.now().toIso8601String(),
              'stock_update_reason': reason ?? 'Manual update',
            },
          );
          
          // Update stock status flags
          final stockStatus = updatedInventory.getStockStatus();
          final isLowStock = stockStatus == StockStatus.lowStock || stockStatus == StockStatus.outOfStock;
          final isOutOfStock = stockStatus == StockStatus.outOfStock;
          
          final finalInventory = updatedInventory.copyWith(
            isLowStock: isLowStock,
            isOutOfStock: isOutOfStock,
          );
          
          // Save to database
          final db = await _databaseHelper.database;
          await db.update(
            'inventory',
            finalInventory.toMap(),
            where: 'id = ?',
            whereArgs: [id],
          );
          
          // Update cache
          _cachedInventory[id] = finalInventory;
          
          // Send to stream
          _inventoryStreamController.add(finalInventory);
          
          // Check for alerts
          await _checkForAlerts(finalInventory);
          
// print('✅ Inventory stock updated successfully: ${finalInventory.sku}'); // Removed for production
          return const Right(null);
        },
      );
    } catch (e) {
// print('❌ Failed to update inventory stock: $e'); // Removed for production
      return Left(Failure(
        message: 'Failed to update inventory stock',
        code: 'UPDATE_ERROR',
        details: e,
      ));
    }
  }

  @override
  Future<Either<Failure, void>> updateInventoryStatus({
    required String id,
    required InventoryStatus status,
    String? reason,
  }) async {
    try {
// print('📝 Updating inventory status: $id -> ${status.name}'); // Removed for production
      
      final inventoryResult = await getInventoryById(id);
      
      return inventoryResult.fold(
        (error) => Left(error),
        (inventory) async {
          final updatedInventory = inventory.copyWith(
            status: status,
            lastUpdated: DateTime.now(),
            metadata: {
              ...inventory.metadata,
              'status_updated_at': DateTime.now().toIso8601String(),
              'status_update_reason': reason ?? 'Manual update',
            },
          );
          
          // Save to database
          final db = await _databaseHelper.database;
          await db.update(
            'inventory',
            updatedInventory.toMap(),
            where: 'id = ?',
            whereArgs: [id],
          );
          
          // Update cache
          _cachedInventory[id] = updatedInventory;
          
          // Send to stream
          _inventoryStreamController.add(updatedInventory);
          
          // Check for alerts
          await _checkForAlerts(updatedInventory);
          
// print('✅ Inventory status updated successfully: ${updatedInventory.sku}'); // Removed for production
          return const Right(null);
        },
      );
    } catch (e) {
// print('❌ Failed to update inventory status: $e'); // Removed for production
      return Left(Failure(
        message: 'Failed to update inventory status',
        code: 'UPDATE_ERROR',
        details: e,
      ));
    }
  }

  @override
  Future<Either<Failure, void>> batchUpdateInventory(List<Inventory> items) async {
    try {
// print('📝 Batch updating inventory: ${items.length} items'); // Removed for production
      
      final db = await _databaseHelper.database;
      final batch = db.batch();
      
      for (final item in items) {
        batch.update(
          'inventory',
          item.toMap(),
          where: 'id = ?',
          whereArgs: [item.id],
        );
        
        // Update cache
        _cachedInventory[item.id] = item;
        
        // Send to stream
        _inventoryStreamController.add(item);
        
        // Check for alerts
        await _checkForAlerts(item);
      }
      
      await batch.commit(noResult: true);
      
// print('✅ Batch update completed successfully'); // Removed for production
      return const Right(null);
    } catch (e) {
// print('❌ Failed to batch update inventory: $e'); // Removed for production
      return Left(Failure(
        message: 'Failed to batch update inventory',
        code: 'BATCH_UPDATE_ERROR',
        details: e,
      ));
    }
  }

  @override
  Future<Either<Failure, List<Inventory>>> searchInventory({
    required String query,
    String? stockistId,
    String? category,
    InventoryStatus? status,
    int? limit,
  }) async {
    try {
// print('🔍 Searching inventory: $query'); // Removed for production
      
      String whereClause = '(sku LIKE ? OR product_name LIKE ? OR brand LIKE ?)';
      List<dynamic> whereArgs = ['%$query%', '%$query%', '%$query%'];
      
      if (stockistId != null) {
        whereClause += ' AND stockist_id = ?';
        whereArgs.add(stockistId);
      }
      
      if (category != null) {
        whereClause += ' AND category = ?';
        whereArgs.add(category);
      }
      
      if (status != null) {
        whereClause += ' AND status = ?';
        whereArgs.add(status.name);
      }
      
      final db = await _databaseHelper.database;
      final maps = await db.query(
        'inventory',
        where: whereClause,
        whereArgs: whereArgs,
        orderBy: 'product_name ASC',
        limit: limit,
      );
      
      final inventory = maps.map((map) => Inventory.fromMap(map)).toList();
      
// print('✅ Search completed: ${inventory.length} items found'); // Removed for production
      return Right(inventory);
    } catch (e) {
// print('❌ Failed to search inventory: $e'); // Removed for production
      return Left(Failure(
        message: 'Failed to search inventory',
        code: 'SEARCH_ERROR',
        details: e,
      ));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getInventoryStatistics({
    String? stockistId,
    String? category,
    InventoryStatus? status,
  }) async {
    try {
// print('📊 Getting inventory statistics...'); // Removed for production
      
      String whereClause = '1=1';
      List<dynamic> whereArgs = [];
      
      if (stockistId != null) {
        whereClause += ' AND stockist_id = ?';
        whereArgs.add(stockistId);
      }
      
      if (category != null) {
        whereClause += ' AND category = ?';
        whereArgs.add(category);
      }
      
      if (status != null) {
        whereClause += ' AND status = ?';
        whereArgs.add(status.name);
      }
      
      final db = await _databaseHelper.database;
      
      // Get total items
      final totalResult = await db.rawQuery(
        'SELECT COUNT(*) as total FROM inventory WHERE $whereClause',
        whereArgs,
      );
      
      // Get items by status
      final statusResult = await db.rawQuery('''
        SELECT status, COUNT(*) as count 
        FROM inventory 
        WHERE $whereClause 
        GROUP BY status
        ORDER BY count DESC
      ''', whereArgs);
      
      // Get stock levels
      final stockResult = await db.rawQuery('''
        SELECT 
          SUM(CASE WHEN is_low_stock = 1 THEN 1 ELSE 0 END) as low_stock_count,
          SUM(CASE WHEN is_out_of_stock = 1 THEN 1 ELSE 0 END) as out_of_stock_count,
          SUM(CASE WHEN is_expiring_soon = 1 THEN 1 ELSE 0 END) as expiring_soon_count,
          SUM(CASE WHEN is_expired = 1 THEN 1 ELSE 0 END) as expired_count,
          SUM(current_stock) as total_stock,
          SUM(unit_price * current_stock) as total_value
        FROM inventory 
        WHERE $whereClause
      ''', whereArgs);
      
      final totalItems = totalResult.first['total'] as int;
      final stockData = stockResult.first;
      
      final statistics = {
        'total_items': totalItems,
        'items_by_status': Map.fromEntries(
          statusResult.map((row) => MapEntry(
            row['status'] as String,
            {
              'count': row['count'] as int,
              'percentage': ((row['count'] as int) / totalItems * 100).toStringAsFixed(1),
            },
          )),
        ),
        'stock_levels': {
          'low_stock_count': stockData['low_stock_count'] as int,
          'out_of_stock_count': stockData['out_of_stock_count'] as int,
          'expiring_soon_count': stockData['expiring_soon_count'] as int,
          'expired_count': stockData['expired_count'] as int,
          'total_stock': stockData['total_stock'] as int,
          'total_value': stockData['total_value'] as double,
        },
        'stockist_id': stockistId,
        'category': category,
        'status': status?.name,
        'generated_at': DateTime.now().toIso8601String(),
      };
      
// print('✅ Inventory statistics calculated'); // Removed for production
      return Right(statistics);
    } catch (e) {
// print('❌ Failed to get inventory statistics: $e'); // Removed for production
      return Left(Failure(
        message: 'Failed to get inventory statistics',
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
        CREATE TABLE IF NOT EXISTS inventory (
          id TEXT PRIMARY KEY,
          product_id TEXT NOT NULL,
          sku TEXT NOT NULL,
          product_name TEXT NOT NULL,
          category TEXT NOT NULL,
          brand TEXT NOT NULL,
          manufacturer TEXT NOT NULL,
          stockist_id TEXT NOT NULL,
          current_stock INTEGER NOT NULL,
          min_stock_level INTEGER NOT NULL,
          max_stock_level INTEGER NOT NULL,
          reorder_point INTEGER NOT NULL,
          unit_price REAL NOT NULL,
          cost_price REAL NOT NULL,
          batch_number TEXT,
          manufacture_date TEXT,
          expiry_date TEXT,
          storage_location TEXT,
          warehouse_location TEXT,
          is_low_stock INTEGER DEFAULT 0,
          is_out_of_stock INTEGER DEFAULT 0,
          is_expiring_soon INTEGER DEFAULT 0,
          is_expired INTEGER DEFAULT 0,
          status TEXT NOT NULL,
          last_updated TEXT NOT NULL,
          created_at TEXT NOT NULL,
          metadata TEXT DEFAULT '{}'
        )
      ''');
      
      await db.execute('''
        CREATE TABLE IF NOT EXISTS stock_alerts (
          id TEXT PRIMARY KEY,
          inventory_id TEXT NOT NULL,
          stockist_id TEXT NOT NULL,
          type TEXT NOT NULL,
          title TEXT NOT NULL,
          message TEXT NOT NULL,
          recommendation TEXT,
          is_active INTEGER DEFAULT 1,
          created_at TEXT NOT NULL,
          resolved_at TEXT,
          resolved_by TEXT,
          resolution TEXT,
          metadata TEXT DEFAULT '{}'
        )
      ''');
      
      await db.execute('''
        CREATE TABLE IF NOT EXISTS inventory_movements (
          id TEXT PRIMARY KEY,
          inventory_id TEXT NOT NULL,
          stockist_id TEXT NOT NULL,
          type TEXT NOT NULL,
          quantity INTEGER NOT NULL,
          previous_stock INTEGER NOT NULL,
          new_stock INTEGER NOT NULL,
          reason TEXT,
          reference_id TEXT,
          reference_type TEXT,
          created_at TEXT NOT NULL,
          created_by TEXT,
          metadata TEXT DEFAULT '{}'
        )
      ''');
      
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_inventory_sku ON inventory (sku)
      ''');
      
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_inventory_product_id ON inventory (product_id)
      ''');
      
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_inventory_stockist_id ON inventory (stockist_id)
      ''');
      
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_inventory_category ON inventory (category)
      ''');
      
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_inventory_status ON inventory (status)
      ''');
      
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_inventory_created_at ON inventory (created_at)
      ''');
      
// print('✅ Database tables created successfully'); // Removed for production
    } catch (e) {
// print('❌ Failed to create database tables: $e'); // Removed for production
      rethrow;
    }
  }

  /// Load cached inventory
  Future<void> _loadCachedInventory() async {
    try {
      final db = await _databaseHelper.database;
      final maps = await db.query('inventory');
      
      for (final map in maps) {
        final inventory = Inventory.fromMap(map);
        _cachedInventory[inventory.id] = inventory;
      }
      
// print('✅ Loaded ${_cachedInventory.length} inventory items into cache'); // Removed for production
    } catch (e) {
// print('❌ Failed to load cached inventory: $e'); // Removed for production
    }
  }

  /// Load active alerts
  Future<void> _loadActiveAlerts() async {
    try {
      final db = await _databaseHelper.database;
      final maps = await db.query(
        'stock_alerts',
        where: 'is_active = 1',
        orderBy: 'created_at DESC',
      );
      
      for (final map in maps) {
        final alert = StockAlert(
          id: map['id'] as String,
          inventoryId: map['inventory_id'] as String,
          stockistId: map['stockist_id'] as String,
          type: _mapAlertType(map['type'] as String),
          title: map['title'] as String,
          message: map['message'] as String,
          recommendation: map['recommendation'] as String?,
          isActive: map['is_active'] as int == 1,
          createdAt: DateTime.parse(map['created_at'] as String),
          resolvedAt: map['resolved_at'] != null 
            ? DateTime.parse(map['resolved_at'] as String) 
            : null,
          resolvedBy: map['resolved_by'] as String?,
          resolution: map['resolution'] as String?,
          metadata: map['metadata'] as Map<String, dynamic>? ?? {},
        );
        
        _activeAlerts[alert.id] = alert;
      }
      
// print('✅ Loaded ${_activeAlerts.length} active alerts'); // Removed for production
    } catch (e) {
// print('❌ Failed to load active alerts: $e'); // Removed for production
    }
  }

  /// Start stock monitoring
  void _startStockMonitoring() {
    _stockCheckTimer?.cancel();
    
    _stockCheckTimer = Timer.periodic(const Duration(minutes: 5), (timer) async {
      if (!_isInitialized) return;
      
      try {
        await _checkAllInventoryStockLevels();
      } catch (e) {
// print('❌ Failed to check stock levels: $e'); // Removed for production
      }
    });
    
// print('✅ Stock monitoring started'); // Removed for production
  }

  /// Start expiry monitoring
  void _startExpiryMonitoring() {
    _expiryCheckTimer?.cancel();
    
    _expiryCheckTimer = Timer.periodic(const Duration(hours: 1), (timer) async {
      if (!_isInitialized) return;
      
      try {
        await _checkAllInventoryExpiry();
      } catch (e) {
// print('❌ Failed to check expiry: $e'); // Removed for production
      }
    });
    
// print('✅ Expiry monitoring started'); // Removed for production
  }

  /// Check all inventory stock levels
  Future<void> _checkAllInventoryStockLevels() async {
    try {
      final db = await _databaseHelper.database;
      final maps = await db.query('inventory');
      
      for (final map in maps) {
        final inventory = Inventory.fromMap(map);
        await _checkForAlerts(inventory);
      }
    } catch (e) {
// print('❌ Failed to check all stock levels: $e'); // Removed for production
    }
  }

  /// Check all inventory expiry
  Future<void> _checkAllInventoryExpiry() async {
    try {
      final db = await _databaseHelper.database;
      final maps = await db.query('inventory');
      
      for (final map in maps) {
        final inventory = Inventory.fromMap(map);
        await _checkForAlerts(inventory);
      }
    } catch (e) {
// print('❌ Failed to check all expiry: $e'); // Removed for production
    }
  }

  /// Check for alerts
  Future<void> _checkForAlerts(Inventory inventory) async {
    try {
      final alerts = <StockAlert>[];
      
      // Check for low stock
      if (inventory.currentStock <= inventory.reorderPoint && !inventory.isLowStock) {
        alerts.add(_createLowStockAlert(inventory));
      }
      
      // Check for out of stock
      if (inventory.currentStock == 0 && !inventory.isOutOfStock) {
        alerts.add(_createOutOfStockAlert(inventory));
      }
      
      // Check for expiring soon
      if (inventory.expiryDate != null) {
        final daysUntilExpiry = inventory.getDaysUntilExpiry();
        if (daysUntilExpiry > 0 && daysUntilExpiry <= 30 && !inventory.isExpiringSoon) {
          alerts.add(_createExpiringSoonAlert(inventory));
        }
        
        // Check for expired
        if (daysUntilExpiry < 0 && !inventory.isExpired) {
          alerts.add(_createExpiredAlert(inventory));
        }
      }
      
      // Save alerts and send to stream
      for (final alert in alerts) {
        await _saveAlert(alert);
        _alertStreamController.add(alert);
      }
      
    } catch (e) {
// print('❌ Failed to check for alerts: $e'); // Removed for production
    }
  }

  /// Create low stock alert
  StockAlert _createLowStockAlert(Inventory inventory) {
    return StockAlert(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      inventoryId: inventory.id,
      stockistId: inventory.stockistId,
      type: StockAlertType.lowStock,
      title: 'Low Stock Alert',
      message: 'Item ${inventory.productName} (${inventory.sku}) is running low on stock. Current: ${inventory.currentStock}, Reorder at: ${inventory.reorderPoint}',
      recommendation: 'Reorder ${inventory.getRecommendedReorderQuantity()} units',
      isActive: true,
      createdAt: DateTime.now(),
    );
  }

  /// Create out of stock alert
  StockAlert _createOutOfStockAlert(Inventory inventory) {
    return StockAlert(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      inventoryId: inventory.id,
      stockistId: inventory.stockistId,
      type: StockAlertType.outOfStock,
      title: 'Out of Stock Alert',
      message: 'Item ${inventory.productName} (${inventory.sku}) is out of stock',
      recommendation: 'Reorder immediately',
      isActive: true,
      createdAt: DateTime.now(),
    );
  }

  /// Create expiring soon alert
  StockAlert _createExpiringSoonAlert(Inventory inventory) {
    return StockAlert(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      inventoryId: inventory.id,
      stockistId: inventory.stockistId,
      type: StockAlertType.expiringSoon,
      title: 'Expiring Soon Alert',
      message: 'Item ${inventory.productName} (${inventory.sku}) expires in ${inventory.getDaysUntilExpiry()} days',
      recommendation: 'Consider clearance or promotion',
      isActive: true,
      createdAt: DateTime.now(),
    );
  }

  /// Create expired alert
  StockAlert _createExpiredAlert(Inventory inventory) {
    return StockAlert(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      inventoryId: inventory.id,
      stockistId: inventory.stockistId,
      type: StockAlertType.expired,
      title: 'Expired Alert',
      message: 'Item ${inventory.productName} (${inventory.sku}) has expired',
      recommendation: 'Remove from inventory and dispose properly',
      isActive: true,
      createdAt: DateTime.now(),
    );
  }

  /// Map alert type
  StockAlertType _mapAlertType(String type) {
    switch (type) {
      case 'low_stock':
        return StockAlertType.lowStock;
      case 'out_of_stock':
        return StockAlertType.outOfStock;
      case 'expiring_soon':
        return StockAlertType.expiringSoon;
      case 'expired':
        return StockAlertType.expired;
      case 'overstock':
        return StockAlertType.overstock;
      case 'damaged':
        return StockAlertType.damaged;
      case 'missing':
        return StockAlertType.missing;
      default:
        return StockAlertType.lowStock;
    }
  }

  /// Save alert
  Future<void> _saveAlert(StockAlert alert) async {
    try {
      final db = await _databaseHelper.database;
      
      await db.insert(
        'stock_alerts',
        {
          'id': alert.id,
          'inventory_id': alert.inventoryId,
          'stockist_id': alert.stockistId,
          'type': alert.type.name,
          'title': alert.title,
          'message': alert.message,
          'recommendation': alert.recommendation,
          'is_active': alert.isActive ? 1 : 0,
          'created_at': alert.createdAt.toIso8601String(),
          'resolved_at': alert.resolvedAt?.toIso8601String(),
          'resolved_by': alert.resolvedBy,
          'resolution': alert.resolution,
          'metadata': jsonEncode(alert.metadata),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      
      _activeAlerts[alert.id] = alert;
      
// print('✅ Alert saved: ${alert.title}'); // Removed for production
    } catch (e) {
// print('❌ Failed to save alert: $e'); // Removed for production
    }
  }

  /// Dispose resources
  void dispose() {
// print('🗑️ Disposing Inventory Repository...'); // Removed for production
    
    _stockCheckTimer?.cancel();
    _expiryCheckTimer?.cancel();
    _inventoryStreamController.close();
    _alertStreamController.close();
    
// print('✅ Inventory Repository disposed'); // Removed for production
  }
}

/// Database helper for inventory management
class DatabaseHelper {
  Database? _database;
  
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }
  
  Future<Database> _initDatabase() async {
    try {
      final databasesPath = await getDatabasesPath();
      final path = join(databasesPath, 'vedantatrade_inventory.db');
      
      final database = await openDatabase(
        path,
        version: 1,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
      
// print('✅ Inventory database initialized: $path'); // Removed for production
      return database;
    } catch (e) {
// print('❌ Failed to initialize inventory database: $e'); // Removed for production
      rethrow;
    }
  }
  
  Future<void> _onCreate(Database db, int version) async {
    try {
      await db.execute('PRAGMA foreign_keys = ON');
// print('✅ Inventory database created with version $version'); // Removed for production
    } catch (e) {
// print('❌ Failed to create inventory database: $e'); // Removed for production
    }
  }
  
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    try {
// print('🔄 Upgrading inventory database from version $oldVersion to $newVersion'); // Removed for production
      
      // Handle database upgrades here
      await db.execute('DROP TABLE IF EXISTS inventory');
      await db.execute('DROP TABLE IF EXISTS stock_alerts');
      await db.execute('DROP TABLE IF EXISTS inventory_movements');
      
// print('✅ Inventory database upgraded to version $newVersion'); // Removed for production
    } catch (e) {
// print('❌ Failed to upgrade inventory database: $e'); // Removed for production
    }
  }
}
