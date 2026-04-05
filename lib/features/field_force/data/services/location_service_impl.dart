import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../domain/services/location_service.dart';
import '../../domain/entities/location_data.dart';

/// Location Service Implementation
/// Enhanced with robust database connection handling and offline caching
class LocationServiceImpl implements LocationService {
  final DatabaseHelper _databaseHelper;
  final SharedPreferences _preferences;
  final StreamController<LocationData> _locationStreamController;
  final StreamController<LocationServiceEvent> _eventStreamController;
  final Map<String, LocationData> _locationCache = {};
  final Map<String, List<LocationData>> _offlineCache = {};
  final Map<String, Timer> _syncTimers = {};
  Position? _currentPosition;
  Timer? _locationUpdateTimer;
  Timer? _connectionCheckTimer;
  bool _isTracking = false;
  bool _isConnected = true;
  int _retryCount = 0;
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 5);

  LocationServiceImpl(this._databaseHelper, this._preferences)
    : _locationStreamController = StreamController<LocationData>.broadcast(),
      _eventStreamController = StreamController<LocationServiceEvent>.broadcast();

  /// Stream of location updates
  Stream<LocationData> get locationStream => _locationStreamController.stream;

  /// Stream of service events
  Stream<LocationServiceEvent> get eventStream => _eventStreamController.stream;

  /// Initialize location service
  Future<void> initialize() async {
    try {
// print('🔍 Initializing Location Service...'); // Removed for production
      
      // Initialize database connection
      await _initializeDatabase();
      
      // Check location permissions
      await _checkPermissions();
      
      // Load cached locations
      await _loadCachedLocations();
      
      // Start connectivity monitoring
      _startConnectivityMonitoring();
      
      // Start location tracking
      await _startLocationTracking();
      
// print('✅ Location Service initialized successfully'); // Removed for production
    } catch (e) {
// print('❌ Failed to initialize Location Service: $e'); // Removed for production
      _emitEvent(LocationServiceEvent(
        type: LocationServiceEventType.initializationFailed,
        message: 'Failed to initialize location service',
        timestamp: DateTime.now(),
        metadata: {'error': e.toString()},
      ));
      rethrow;
    }
  }

  /// Initialize database with retry logic
  Future<void> _initializeDatabase() async {
    for (int attempt = 1; attempt <= _maxRetries; attempt++) {
      try {
// print('📊 Attempting database connection (attempt $attempt/$_maxRetries)...'); // Removed for production
        
        await _databaseHelper.initialize();
        await _createTables();
        
// print('✅ Database connection established successfully'); // Removed for production
        _isConnected = true;
        _retryCount = 0;
        return;
      } catch (e) {
// print('❌ Database connection failed (attempt $attempt/$_maxRetries): $e'); // Removed for production
        
        if (attempt == _maxRetries) {
          // Final attempt failed, switch to offline mode
// print('⚠️ All database connection attempts failed, switching to offline mode'); // Removed for production
          _isConnected = false;
          _emitEvent(LocationServiceEvent(
            type: LocationServiceEventType.connectionLost,
            message: 'Database connection failed, switched to offline mode',
            timestamp: DateTime.now(),
            metadata: {'error': e.toString(), 'attempts': attempt},
          ));
          return;
        }
        
        // Wait before retry
        await Future.delayed(_retryDelay * attempt);
      }
    }
  }

  /// Create database tables
  Future<void> _createTables() async {
    try {
      final db = await _databaseHelper.database;
      
      await db.execute('''
        CREATE TABLE IF NOT EXISTS location_data (
          id TEXT PRIMARY KEY,
          user_id TEXT NOT NULL,
          latitude REAL NOT NULL,
          longitude REAL NOT NULL,
          altitude REAL,
          accuracy REAL,
          speed REAL,
          heading REAL,
          timestamp TEXT NOT NULL,
          is_synced INTEGER DEFAULT 0,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL,
          metadata TEXT DEFAULT '{}'
        )
      ''');
      
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_location_data_user_id ON location_data (user_id)
      ''');
      
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_location_data_timestamp ON location_data (timestamp)
      ''');
      
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_location_data_is_synced ON location_data (is_synced)
      ''');
      
// print('✅ Database tables created successfully'); // Removed for production
    } catch (e) {
// print('❌ Failed to create database tables: $e'); // Removed for production
      rethrow;
    }
  }

  /// Check location permissions
  Future<void> _checkPermissions() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }
      
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }
      
// print('✅ Location permissions verified'); // Removed for production
    } catch (e) {
// print('❌ Failed to check location permissions: $e'); // Removed for production
      rethrow;
    }
  }

  /// Load cached locations
  Future<void> _loadCachedLocations() async {
    try {
      if (!_isConnected) {
// print('⚠️ Skipping cache load - database not connected'); // Removed for production
        return;
      }
      
      final db = await _databaseHelper.database;
      final maps = await db.query('location_data', limit: 100);
      
      for (final map in maps) {
        final location = LocationData.fromMap(map);
        _locationCache[location.id] = location;
      }
      
// print('✅ Loaded ${_locationCache.length} cached locations'); // Removed for production
    } catch (e) {
// print('❌ Failed to load cached locations: $e'); // Removed for production
      // Don't rethrow - continue with empty cache
    }
  }

  /// Start connectivity monitoring
  void _startConnectivityMonitoring() {
    _connectionCheckTimer?.cancel();
    
    _connectionCheckTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      try {
        final connectivityResult = await Connectivity().checkConnectivity();
        final wasConnected = _isConnected;
        _isConnected = connectivityResult != ConnectivityResult.none;
        
        if (wasConnected && !_isConnected) {
// print('⚠️ Connection lost'); // Removed for production
          _emitEvent(LocationServiceEvent(
            type: LocationServiceEventType.connectionLost,
            message: 'Network connection lost',
            timestamp: DateTime.now(),
          ));
        } else if (!wasConnected && _isConnected) {
// print('✅ Connection restored'); // Removed for production
          _emitEvent(LocationServiceEvent(
            type: LocationServiceEventType.connectionRestored,
            message: 'Network connection restored',
            timestamp: DateTime.now(),
          ));
          // Try to reconnect database
          await _reconnectDatabase();
          // Sync offline data
          await _syncOfflineData();
        }
      } catch (e) {
// print('❌ Connectivity check failed: $e'); // Removed for production
      }
    });
    
// print('✅ Connectivity monitoring started'); // Removed for production
  }

  /// Start location tracking
  Future<void> _startLocationTracking() async {
    try {
      if (_isTracking) return;
      
// print('📍 Starting location tracking...'); // Removed for production
      
      const LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
        timeLimit: Duration(seconds: 30),
      );
      
      _locationUpdateTimer?.cancel();
      _locationUpdateTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
        if (!_isTracking) return;
        
        try {
          final position = await Geolocator.getCurrentPosition(
            locationSettings: locationSettings,
          );
          
          await _handleLocationUpdate(position);
        } catch (e) {
// print('❌ Failed to get location: $e'); // Removed for production
          _emitEvent(LocationServiceEvent(
            type: LocationServiceEventType.locationUpdateFailed,
            message: 'Failed to get current location',
            timestamp: DateTime.now(),
            metadata: {'error': e.toString()},
          ));
        }
      });
      
      // Get initial position
      final position = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );
      await _handleLocationUpdate(position);
      
      _isTracking = true;
// print('✅ Location tracking started'); // Removed for production
    } catch (e) {
// print('❌ Failed to start location tracking: $e'); // Removed for production
      rethrow;
    }
  }

  /// Handle location update
  Future<void> _handleLocationUpdate(Position position) async {
    try {
      _currentPosition = position;
      
      final locationData = LocationData(
        id: _generateLocationId(),
        userId: _preferences.getString('user_id') ?? 'unknown',
        latitude: position.latitude,
        longitude: position.longitude,
        altitude: position.altitude,
        accuracy: position.accuracy,
        speed: position.speed,
        heading: position.heading,
        timestamp: DateTime.now(),
        isSynced: _isConnected,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // Update cache
      _locationCache[locationData.id] = locationData;
      
      // Save to database or offline cache
      if (_isConnected) {
        await _saveLocationToDatabase(locationData);
      } else {
        await _saveLocationToOfflineCache(locationData);
      }
      
      // Emit location update
      _locationStreamController.add(locationData);
      
// print('📍 Location updated: ${position.latitude}, ${position.longitude}'); // Removed for production
    } catch (e) {
// print('❌ Failed to handle location update: $e'); // Removed for production
    }
  }

  /// Save location to database
  Future<void> _saveLocationToDatabase(LocationData locationData) async {
    try {
      final db = await _databaseHelper.database;
      
      await db.insert(
        'location_data',
        locationData.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      
// print('💾 Location saved to database: ${locationData.id}'); // Removed for production
    } catch (e) {
// print('❌ Failed to save location to database: $e'); // Removed for production
      
      // Fall back to offline cache
      await _saveLocationToOfflineCache(locationData);
    }
  }

  /// Save location to offline cache
  Future<void> _saveLocationToOfflineCache(LocationData locationData) async {
    try {
      final userId = locationData.userId;
      
      if (!_offlineCache.containsKey(userId)) {
        _offlineCache[userId] = [];
      }
      
      _offlineCache[userId]!.add(locationData);
      
      // Keep only last 1000 locations per user
      if (_offlineCache[userId]!.length > 1000) {
        _offlineCache[userId]!.removeRange(0, _offlineCache[userId]!.length - 1000);
      }
      
      // Save to SharedPreferences for persistence
      final cacheJson = jsonEncode(
        _offlineCache.map((k, v) => MapEntry(k, v.map((l) => l.toMap()))),
      );
      await _preferences.setString('location_offline_cache', cacheJson);
      
// print('💾 Location saved to offline cache: ${locationData.id}'); // Removed for production
    } catch (e) {
// print('❌ Failed to save location to offline cache: $e'); // Removed for production
    }
  }

  /// Get current location
  @override
  Future<Either<LocationServiceError, LocationData>> getCurrentLocation() async {
    try {
      if (_currentPosition == null) {
        return Left(LocationServiceError(
          code: 'NO_LOCATION',
          message: 'No current location available',
          details: 'Location tracking may not be started',
        ));
      }
      
      final locationData = LocationData(
        id: _generateLocationId(),
        userId: _preferences.getString('user_id') ?? 'unknown',
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
        altitude: _currentPosition!.altitude,
        accuracy: _currentPosition!.accuracy,
        speed: _currentPosition!.speed,
        heading: _currentPosition!.heading,
        timestamp: DateTime.now(),
        isSynced: _isConnected,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      return Right(locationData);
    } catch (e) {
// print('❌ Failed to get current location: $e'); // Removed for production
      return Left(LocationServiceError(
        code: 'GET_LOCATION_FAILED',
        message: 'Failed to get current location',
        details: e.toString(),
      ));
    }
  }

  /// Get location history
  @override
  Future<Either<LocationServiceError, List<LocationData>>> getLocationHistory({
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    try {
      if (!_isConnected) {
        // Return from offline cache
        return _getLocationHistoryFromOfflineCache(
          userId: userId,
          startDate: startDate,
          endDate: endDate,
          limit: limit,
        );
      }
      
      final db = await _databaseHelper.database;
      
      String whereClause = '1=1';
      List<dynamic> whereArgs = [];
      
      if (userId != null) {
        whereClause += ' AND user_id = ?';
        whereArgs.add(userId);
      }
      
      if (startDate != null) {
        whereClause += ' AND timestamp >= ?';
        whereArgs.add(startDate.toIso8601String());
      }
      
      if (endDate != null) {
        whereClause += ' AND timestamp <= ?';
        whereArgs.add(endDate.toIso8601String());
      }
      
      final maps = await db.query(
        'location_data',
        where: whereClause,
        whereArgs: whereArgs,
        orderBy: 'timestamp DESC',
        limit: limit,
      );
      
      final locations = maps.map((map) => LocationData.fromMap(map)).toList();
      
// print('✅ Retrieved ${locations.length} locations from database'); // Removed for production
      return Right(locations);
    } catch (e) {
// print('❌ Failed to get location history: $e'); // Removed for production
      
      // Try offline cache as fallback
      return _getLocationHistoryFromOfflineCache(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
        limit: limit,
      );
    }
  }

  /// Get location history from offline cache
  Future<Either<LocationServiceError, List<LocationData>>> _getLocationHistoryFromOfflineCache({
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    try {
      List<LocationData> locations = [];
      
      if (userId != null) {
        locations = _offlineCache[userId] ?? [];
      } else {
        // Get all locations from offline cache
        for (final userLocations in _offlineCache.values) {
          locations.addAll(userLocations);
        }
      }
      
      // Filter by date range
      if (startDate != null) {
        locations = locations.where((l) => l.timestamp.isAfter(startDate)).toList();
      }
      
      if (endDate != null) {
        locations = locations.where((l) => l.timestamp.isBefore(endDate)).toList();
      }
      
      // Sort by timestamp (newest first)
      locations.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      // Apply limit
      if (limit != null && locations.length > limit) {
        locations = locations.take(limit).toList();
      }
      
// print('✅ Retrieved ${locations.length} locations from offline cache'); // Removed for production
      return Right(locations);
    } catch (e) {
// print('❌ Failed to get location history from offline cache: $e'); // Removed for production
      return Left(LocationServiceError(
        code: 'OFFLINE_CACHE_FAILED',
        message: 'Failed to get location history from offline cache',
        details: e.toString(),
      ));
    }
  }

  /// Start location tracking for user
  @override
  Future<Either<LocationServiceError, void>> startTracking({String? userId}) async {
    try {
      if (_isTracking) {
        return const Right(null);
      }
      
// print('📍 Starting location tracking for user: ${userId ?? 'current'}'); // Removed for production
      
      // Save user ID if provided
      if (userId != null) {
        await _preferences.setString('user_id', userId);
      }
      
      await _startLocationTracking();
      
      _emitEvent(LocationServiceEvent(
        type: LocationServiceEventType.trackingStarted,
        message: 'Location tracking started',
        timestamp: DateTime.now(),
        metadata: {'user_id': userId},
      ));
      
      return const Right(null);
    } catch (e) {
// print('❌ Failed to start tracking: $e'); // Removed for production
      return Left(LocationServiceError(
        code: 'START_TRACKING_FAILED',
        message: 'Failed to start location tracking',
        details: e.toString(),
      ));
    }
  }

  /// Stop location tracking
  @override
  Future<Either<LocationServiceError, void>> stopTracking() async {
    try {
      if (!_isTracking) {
        return const Right(null);
      }
      
// print('⏹️ Stopping location tracking'); // Removed for production
      
      _locationUpdateTimer?.cancel();
      _isTracking = false;
      
      _emitEvent(LocationServiceEvent(
        type: LocationServiceEventType.trackingStopped,
        message: 'Location tracking stopped',
        timestamp: DateTime.now(),
      ));
      
      return const Right(null);
    } catch (e) {
// print('❌ Failed to stop tracking: $e'); // Removed for production
      return Left(LocationServiceError(
        code: 'STOP_TRACKING_FAILED',
        message: 'Failed to stop location tracking',
        details: e.toString(),
      ));
    }
  }

  /// Sync offline data
  @override
  Future<Either<LocationServiceError, void>> syncOfflineData() async {
    try {
      if (!_isConnected) {
        return Left(LocationServiceError(
          code: 'NO_CONNECTION',
          message: 'No network connection available',
          details: 'Cannot sync offline data without connection',
        ));
      }
      
// print('🔄 Syncing offline data...'); // Removed for production
      
      int syncedCount = 0;
      
      for (final userId in _offlineCache.keys) {
        final locations = _offlineCache[userId]!;
        
        for (final location in locations) {
          if (!location.isSynced) {
            try {
              await _saveLocationToDatabase(location);
              
              // Mark as synced
              final syncedLocation = location.copyWith(
                isSynced: true,
                updatedAt: DateTime.now(),
              );
              
              // Update in cache
              _locationCache[location.id] = syncedLocation;
              
              // Update in offline cache
              final index = locations.indexWhere((l) => l.id == location.id);
              if (index != -1) {
                locations[index] = syncedLocation;
              }
              
              syncedCount++;
            } catch (e) {
// print('❌ Failed to sync location ${location.id}: $e'); // Removed for production
            }
          }
        }
      }
      
      // Clear synced locations from offline cache
      for (final userId in _offlineCache.keys) {
        _offlineCache[userId]!.removeWhere((location) => location.isSynced);
      }
      
      // Save updated offline cache
      await _saveOfflineCacheToPreferences();
      
// print('✅ Synced $syncedCount locations'); // Removed for production
      
      _emitEvent(LocationServiceEvent(
        type: LocationServiceEventType.syncCompleted,
        message: 'Offline data sync completed',
        timestamp: DateTime.now(),
        metadata: {'synced_count': syncedCount},
      ));
      
      return const Right(null);
    } catch (e) {
// print('❌ Failed to sync offline data: $e'); // Removed for production
      return Left(LocationServiceError(
        code: 'SYNC_FAILED',
        message: 'Failed to sync offline data',
        details: e.toString(),
      ));
    }
  }

  /// Reconnect database
  Future<void> _reconnectDatabase() async {
    try {
// print('🔄 Attempting to reconnect database...'); // Removed for production
      
      await _initializeDatabase();
      
// print('✅ Database reconnected successfully'); // Removed for production
    } catch (e) {
// print('❌ Failed to reconnect database: $e'); // Removed for production
    }
  }

  /// Save offline cache to preferences
  Future<void> _saveOfflineCacheToPreferences() async {
    try {
      final cacheJson = jsonEncode(
        _offlineCache.map((k, v) => MapEntry(k, v.map((l) => l.toMap()))),
      );
      await _preferences.setString('location_offline_cache', cacheJson);
    } catch (e) {
// print('❌ Failed to save offline cache to preferences: $e'); // Removed for production
    }
  }

  /// Emit service event
  void _emitEvent(LocationServiceEvent event) {
    _eventStreamController.add(event);
  }

  /// Generate location ID
  String _generateLocationId() {
    return 'loc_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Dispose resources
  void dispose() {
// print('🗑️ Disposing Location Service...'); // Removed for production
    
    _locationUpdateTimer?.cancel();
    _connectionCheckTimer?.cancel();
    _locationStreamController.close();
    _eventStreamController.close();
    
    for (final timer in _syncTimers.values) {
      timer.cancel();
    }
    _syncTimers.clear();
    
// print('✅ Location Service disposed'); // Removed for production
  }
}

/// Database Helper with enhanced connection handling
class DatabaseHelper {
  Database? _database;
  bool _isInitialized = false;
  int _connectionAttempts = 0;
  static const int _maxConnectionAttempts = 3;

  Future<Database> get database async {
    if (_database != null && _isInitialized) {
      return _database!;
    }
    
    return await _initializeDatabase();
  }

  Future<Database> _initializeDatabase() async {
    for (int attempt = 1; attempt <= _maxConnectionAttempts; attempt++) {
      try {
// print('📊 Initializing database (attempt $attempt/$_maxConnectionAttempts)...'); // Removed for production
        
        final databasesPath = await getDatabasesPath();
        final path = join(databasesPath, 'vedantatrade_location.db');
        
        final database = await openDatabase(
          path,
          version: 1,
          onCreate: _onCreate,
          onUpgrade: _onUpgrade,
          onConfigure: _onConfigure,
        );
        
        _database = database;
        _isInitialized = true;
        _connectionAttempts = 0;
        
// print('✅ Database initialized successfully: $path'); // Removed for production
        return database;
      } catch (e) {
// print('❌ Database initialization failed (attempt $attempt/$_maxConnectionAttempts): $e'); // Removed for production
        _connectionAttempts++;
        
        if (attempt == _maxConnectionAttempts) {
// print('⚠️ All database initialization attempts failed'); // Removed for production
          rethrow;
        }
        
        // Wait before retry
        await Future.delayed(Duration(seconds: 2 * attempt));
      }
    }
    
    throw Exception('Failed to initialize database after $_maxConnectionAttempts attempts');
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
    await db.execute('PRAGMA journal_mode = WAL');
    await db.execute('PRAGMA synchronous = NORMAL');
    await db.execute('PRAGMA cache_size = 10000');
    await db.execute('PRAGMA temp_store = MEMORY');
  }

  Future<void> _onCreate(Database db, int version) async {
// print('📝 Creating database tables...'); // Removed for production
    
    // Tables will be created by the service
// print('✅ Database created with version $version'); // Removed for production
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
// print('🔄 Upgrading database from version $oldVersion to $newVersion'); // Removed for production
    
    // Handle database upgrades here
// print('✅ Database upgraded to version $newVersion'); // Removed for production
  }

  Future<void> initialize() async {
    await _initializeDatabase();
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
      _isInitialized = false;
// print('📁 Database connection closed'); // Removed for production
    }
  }

  Future<bool> testConnection() async {
    try {
      final db = await database;
      await db.rawQuery('SELECT 1');
      return true;
    } catch (e) {
// print('❌ Database connection test failed: $e'); // Removed for production
      _isInitialized = false;
      return false;
    }
  }
}
