import 'dart:async';
import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../domain/entities/mr_location.dart';
import '../../domain/repositories/mr_location_repository.dart';

/// Medical Representative Location Repository Implementation
/// SQLite-based implementation for MR location tracking and geospatial data
class MRLocationRepositoryImpl implements MRLocationRepository {
  final DatabaseHelper _databaseHelper;
  
  MRLocationRepositoryImpl(this._databaseHelper);
  
  @override
  Future<Either<Failure, void>> saveLocation(MRLocation location) async {
    try {
      print('💾 Saving MR location: ${location.id}');
      
      final db = await _databaseHelper.database;
      
      await db.insert(
        'mr_locations',
        location.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      
      print('✅ MR location saved successfully');
      return const Right(null);
    } catch (e) {
      print('❌ Failed to save MR location: $e');
      return Left(Failure(
        message: 'Failed to save location',
        code: 'SAVE_ERROR',
        details: e,
      ));
    }
  }
  
  @override
  Future<Either<Failure, MRLocation?>> getLocationById(String id) async {
    try {
      print('🔍 Getting MR location by ID: $id');
      
      final db = await _databaseHelper.database;
      
      final maps = await db.query(
        'mr_locations',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      
      if (maps.isEmpty) {
        print('⚠️ MR location not found: $id');
        return const Right(null);
      }
      
      final location = MRLocation.fromMap(maps.first);
      print('✅ MR location retrieved: ${location.id}');
      return Right(location);
    } catch (e) {
      print('❌ Failed to get MR location: $e');
      return Left(Failure(
        message: 'Failed to retrieve location',
        code: 'RETRIEVE_ERROR',
        details: e,
      ));
    }
  }
  
  @override
  Future<Either<Failure, List<MRLocation>>> getLocationsByMrId({
    required String mrId,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    try {
      print('🔍 Getting locations for MR: $mrId');
      
      final db = await _databaseHelper.database;
      
      String whereClause = 'mr_id = ?';
      List<dynamic> whereArgs = [mrId];
      
      if (startDate != null) {
        whereClause += ' AND timestamp >= ?';
        whereArgs.add(startDate!.toIso8601String());
      }
      
      if (endDate != null) {
        whereClause += ' AND timestamp <= ?';
        whereArgs.add(endDate!.toIso8601String());
      }
      
      final maps = await db.query(
        'mr_locations',
        where: whereClause,
        whereArgs: whereArgs,
        orderBy: 'timestamp DESC',
        limit: limit,
      );
      
      final locations = maps.map((map) => MRLocation.fromMap(map)).toList();
      print('✅ Retrieved ${locations.length} locations for MR: $mrId');
      return Right(locations);
    } catch (e) {
      print('❌ Failed to get MR locations: $e');
      return Left(Failure(
        message: 'Failed to retrieve locations',
        code: 'RETRIEVE_ERROR',
        details: e,
      ));
    }
  }
  
  @override
  Future<Either<Failure, List<MRLocation>>> getLocationsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
    String? mrId,
  }) async {
    try {
      print('🔍 Getting locations by date range: $startDate to $endDate');
      
      final db = await _databaseHelper.database;
      
      String whereClause = 'timestamp >= ? AND timestamp <= ?';
      List<dynamic> whereArgs = [startDate.toIso8601String(), endDate.toIso8601String()];
      
      if (mrId != null) {
        whereClause += ' AND mr_id = ?';
        whereArgs.add(mrId);
      }
      
      final maps = await db.query(
        'mr_locations',
        where: whereClause,
        whereArgs: whereArgs,
        orderBy: 'timestamp DESC',
      );
      
      final locations = maps.map((map) => MRLocation.fromMap(map)).toList();
      print('✅ Retrieved ${locations.length} locations for date range');
      return Right(locations);
    } catch (e) {
      print('❌ Failed to get locations by date range: $e');
      return Left(Failure(
        message: 'Failed to retrieve locations by date range',
        code: 'RETRIEVE_ERROR',
        details: e,
      ));
    }
  }
  
  @override
  Future<Either<Failure, List<MRLocation>>> getLocationsByBounds({
    required double northEastLat,
    required double northEastLng,
    required double southWestLat,
    required double southWestLng,
  }) async {
    try {
      print('🔍 Getting locations by bounds: NE($northEastLat, $northEastLng) SW($southWestLat, $southWestLng)');
      
      final db = await _databaseHelper.database;
      
      final maps = await db.query(
        'mr_locations',
        where: 'latitude BETWEEN ? AND ? AND longitude BETWEEN ? AND ?',
        whereArgs: [southWestLat, northEastLat, southWestLng, northEastLng],
        orderBy: 'timestamp DESC',
      );
      
      final locations = maps.map((map) => MRLocation.fromMap(map)).toList();
      print('✅ Retrieved ${locations.length} locations within bounds');
      return Right(locations);
    } catch (e) {
      print('❌ Failed to get locations by bounds: $e');
      return Left(Failure(
        message: 'Failed to retrieve locations by bounds',
        code: 'RETRIEVE_ERROR',
        details: e,
      ));
    }
  }
  
  @override
  Future<Either<Failure, List<MRLocation>>> getHighAccuracyLocations({
    String? mrId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      print('🔍 Getting high accuracy locations...');
      
      final db = await _databaseHelper.database;
      
      String whereClause = 'is_high_accuracy = 1';
      List<dynamic> whereArgs = [];
      
      if (mrId != null) {
        whereClause += ' AND mr_id = ?';
        whereArgs.add(mrId);
      }
      
      if (startDate != null) {
        whereClause += ' AND timestamp >= ?';
        whereArgs.add(startDate!.toIso8601String());
      }
      
      if (endDate != null) {
        whereClause += ' AND timestamp <= ?';
        whereArgs.add(endDate!.toIso8601String());
      }
      
      final maps = await db.query(
        'mr_locations',
        where: whereClause,
        whereArgs: whereArgs,
        orderBy: 'timestamp DESC',
      );
      
      final locations = maps.map((map) => MRLocation.fromMap(map)).toList();
      print('✅ Retrieved ${locations.length} high accuracy locations');
      return Right(locations);
    } catch (e) {
      print('❌ Failed to get high accuracy locations: $e');
      return Left(Failure(
        message: 'Failed to retrieve high accuracy locations',
        code: 'RETRIEVE_ERROR',
        details: e,
      ));
    }
  }
  
  @override
  Future<Either<Failure, List<MRLocation>>> getTrajectoryLocations({
    required String mrId,
    required DateTime date,
  }) async {
    try {
      print('🔍 Getting trajectory locations for MR: $mrId on date: $date');
      
      final db = await _databaseHelper.database;
      
      final startDate = DateTime(date.year, date.month, date.day, 0, 0, 0);
      final endDate = DateTime(date.year, date.month, date.day, 23, 59, 59);
      
      final maps = await db.query(
        'mr_locations',
        where: 'mr_id = ? AND timestamp >= ? AND timestamp <= ? AND is_high_accuracy = 1',
        whereArgs: [mrId, startDate.toIso8601String(), endDate.toIso8601String()],
        orderBy: 'timestamp ASC',
      );
      
      final locations = maps.map((map) => MRLocation.fromMap(map)).toList();
      print('✅ Retrieved ${locations.length} trajectory locations');
      return Right(locations);
    } catch (e) {
      print('❌ Failed to get trajectory locations: $e');
      return Left(Failure(
        message: 'Failed to retrieve trajectory locations',
        code: 'RETRIEVE_ERROR',
        details: e,
      ));
    }
  }
  
  @override
  Future<Either<Failure, MRLocation?>> getLatestLocation(String mrId) async {
    try {
      print('🔍 Getting latest location for MR: $mrId');
      
      final db = await _databaseHelper.database;
      
      final maps = await db.query(
        'mr_locations',
        where: 'mr_id = ?',
        whereArgs: [mrId],
        orderBy: 'timestamp DESC',
        limit: 1,
      );
      
      if (maps.isEmpty) {
        print('⚠️ No locations found for MR: $mrId');
        return const Right(null);
      }
      
      final location = MRLocation.fromMap(maps.first);
      print('✅ Latest location retrieved: ${location.id}');
      return Right(location);
    } catch (e) {
      print('❌ Failed to get latest location: $e');
      return Left(Failure(
        message: 'Failed to retrieve latest location',
        code: 'RETRIEVE_ERROR',
        details: e,
      ));
    }
  }
  
  @override
  Future<Either<Failure, void>> updateLocation(MRLocation location) async {
    try {
      print('📝 Updating MR location: ${location.id}');
      
      final db = await _databaseHelper.database;
      
      await db.update(
        'mr_locations',
        location.toMap(),
        where: 'id = ?',
        whereArgs: [location.id],
      );
      
      print('✅ MR location updated successfully');
      return const Right(null);
    } catch (e) {
      print('❌ Failed to update MR location: $e');
      return Left(Failure(
        message: 'Failed to update location',
        code: 'UPDATE_ERROR',
        details: e,
      ));
    }
  }
  
  @override
  Future<Either<Failure, void>> deleteLocation(String id) async {
    try {
      print('🗑️ Deleting MR location: $id');
      
      final db = await _databaseHelper.database;
      
      await db.delete(
        'mr_locations',
        where: 'id = ?',
        whereArgs: [id],
      );
      
      print('✅ MR location deleted successfully');
      return const Right(null);
    } catch (e) {
      print('❌ Failed to delete MR location: $e');
      return Left(Failure(
        message: 'Failed to delete location',
        code: 'DELETE_ERROR',
        details: e,
      ));
    }
  }
  
  @override
  Future<Either<Failure, Map<String, dynamic>>> getLocationStatistics({
    required String mrId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      print('📈 Getting location statistics for MR: $mrId');
      
      final db = await _databaseHelper.database;
      
      String whereClause = 'mr_id = ?';
      List<dynamic> whereArgs = [mrId];
      
      if (startDate != null) {
        whereClause += ' AND timestamp >= ?';
        whereArgs.add(startDate!.toIso8601String());
      }
      
      if (endDate != null) {
        whereClause += ' AND timestamp <= ?';
        whereArgs.add(endDate!.toIso8601String());
      }
      
      final maps = await db.query(
        'mr_locations',
        where: whereClause,
        whereArgs: whereArgs,
      );
      
      if (maps.isEmpty) {
        return const Right({
          'total_locations': 0,
          'high_accuracy_locations': 0,
          'average_accuracy': 0.0,
          'total_distance': 0.0,
          'coverage_percentage': 0.0,
        });
      }
      
      final locations = maps.map((map) => MRLocation.fromMap(map)).toList();
      
      // Calculate statistics
      final totalLocations = locations.length;
      final highAccuracyCount = locations.where((loc) => loc.isHighAccuracy).length;
      final averageAccuracy = locations
          .map((loc) => loc.accuracy)
          .reduce((a, b) => a + b, 0) / locations.length;
      
      // Calculate total distance
      double totalDistance = 0.0;
      for (int i = 1; i < locations.length; i++) {
        totalDistance += _calculateDistance(
          locations[i - 1].latitude,
          locations[i - 1].longitude,
          locations[i].latitude,
          locations[i].longitude,
        );
      }
      
      // Calculate coverage (locations within Janakpur area)
      final coverageCount = locations.where((loc) => loc.isWithinJanakpurArea()).length;
      final coveragePercentage = (coverageCount / locations.length) * 100;
      
      final statistics = {
        'total_locations': totalLocations,
        'high_accuracy_locations': highAccuracyCount,
        'average_accuracy': averageAccuracy,
        'total_distance': totalDistance,
        'coverage_percentage': coveragePercentage,
        'janakpur_coverage': coverageCount,
        'tracking_quality': averageAccuracy <= 10.0 ? 'Excellent' : 
                         averageAccuracy <= 15.0 ? 'Good' : 
                         averageAccuracy <= 20.0 ? 'Fair' : 'Poor',
      };
      
      print('✅ Location statistics calculated');
      return Right(statistics);
    } catch (e) {
      print('❌ Failed to calculate location statistics: $e');
      return Left(Failure(
        message: 'Failed to calculate location statistics',
        code: 'STATISTICS_ERROR',
        details: e,
      ));
    }
  }
  
  @override
  Future<Either<Failure, List<MRLocation>>> getDashboardLocations({
    String? mrId,
    int? limit = 10,
  }) async {
    try {
      print('📊 Getting dashboard locations...');
      
      final db = await _databaseHelper.database;
      
      String whereClause = 'is_high_accuracy = 1';
      List<dynamic> whereArgs = [];
      
      if (mrId != null) {
        whereClause += ' AND mr_id = ?';
        whereArgs.add(mrId);
      }
      
      final maps = await db.query(
        'mr_locations',
        where: whereClause,
        whereArgs: whereArgs,
        orderBy: 'timestamp DESC',
        limit: limit,
      );
      
      final locations = maps.map((map) => MRLocation.fromMap(map)).toList();
      print('✅ Retrieved ${locations.length} dashboard locations');
      return Right(locations);
    } catch (e) {
      print('❌ Failed to get dashboard locations: $e');
      return Left(Failure(
        message: 'Failed to retrieve dashboard locations',
        code: 'RETRIEVE_ERROR',
        details: e,
      ));
    }
  }
  
  @override
  Future<Either<Failure, void>> syncOfflineLocations(List<MRLocation> locations) async {
    try {
      print('🔄 Syncing ${locations.length} offline locations...');
      
      final db = await _databaseHelper.database;
      
      final batch = db.batch();
      
      for (final location in locations) {
        final syncedLocation = location.copyWith(
          syncedAt: DateTime.now(),
          isOffline: false,
        );
        
        batch.insert(
          'mr_locations',
          syncedLocation.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      
      await batch.commit(noResult: true);
      
      print('✅ Offline locations synced successfully');
      return const Right(null);
    } catch (e) {
      print('❌ Failed to sync offline locations: $e');
      return Left(Failure(
        message: 'Failed to sync offline locations',
        code: 'SYNC_ERROR',
        details: e,
      ));
    }
  }
  
  @override
  Future<Either<Failure, List<MRLocation>>> getLocationsNeedingAttention() async {
    try {
      print('⚠️ Getting locations needing attention...');
      
      final db = await _databaseHelper.database;
      
      final maps = await db.query(
        'mr_locations',
        where: 'accuracy > ? OR is_offline = 1',
        whereArgs: [20.0],
        orderBy: 'timestamp DESC',
      );
      
      final locations = maps.map((map) => MRLocation.fromMap(map)).toList();
      print('✅ Retrieved ${locations.length} locations needing attention');
      return Right(locations);
    } catch (e) {
      print('❌ Failed to get locations needing attention: $e');
      return Left(Failure(
        message: 'Failed to retrieve locations needing attention',
        code: 'RETRIEVE_ERROR',
        details: e,
      ));
    }
  }
  
  @override
  Future<Either<Failure, void>> bulkSaveLocations(List<MRLocation> locations) async {
    try {
      print('💾 Bulk saving ${locations.length} locations...');
      
      final db = await _databaseHelper.database;
      
      final batch = db.batch();
      
      for (final location in locations) {
        batch.insert(
          'mr_locations',
          location.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      
      await batch.commit(noResult: true);
      
      print('✅ Bulk save completed successfully');
      return const Right(null);
    } catch (e) {
      print('❌ Failed to bulk save locations: $e');
      return Left(Failure(
        message: 'Failed to bulk save locations',
        code: 'BULK_SAVE_ERROR',
        details: e,
      ));
    }
  }
  
  @override
  Future<Either<Failure, Map<String, dynamic>>> getLocationAnalytics({
    required String mrId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      print('📈 Getting location analytics for MR: $mrId');
      
      final locationsResult = await getLocationsByMrId(
        mrId: mrId,
        startDate: startDate,
        endDate: endDate,
      );
      
      return locationsResult.fold(
        (error) => Left(error),
        (locations) async {
          if (locations.isEmpty) {
            return const Right({
              'total_days': 0,
              'total_locations': 0,
              'average_locations_per_day': 0.0,
              'high_accuracy_percentage': 0.0,
              'janakpur_coverage_percentage': 0.0,
              'most_active_day': null,
              'least_active_day': null,
            });
          }
          
          // Group locations by day
          final Map<String, List<MRLocation>> locationsByDay = {};
          for (final location in locations) {
            final dayKey = location.timestamp.toString().substring(0, 10); // YYYY-MM-DD
            locationsByDay.putIfAbsent(dayKey, () => []).add(location);
          }
          
          final totalDays = locationsByDay.length;
          final averageLocationsPerDay = locations.length / totalDays;
          final highAccuracyCount = locations.where((loc) => loc.isHighAccuracy).length;
          final highAccuracyPercentage = (highAccuracyCount / locations.length) * 100;
          
          // Find most and least active days
          String? mostActiveDay;
          String? leastActiveDay;
          int maxLocations = 0;
          int minLocations = locations.length;
          
          locationsByDay.forEach((day, dayLocations) {
            if (dayLocations.length > maxLocations) {
              maxLocations = dayLocations.length;
              mostActiveDay = day;
            }
            if (dayLocations.length < minLocations) {
              minLocations = dayLocations.length;
              leastActiveDay = day;
            }
          });
          
          // Calculate Janakpur coverage
          final janakpurCoverageCount = locations
              .where((loc) => loc.isWithinJanakpurArea())
              .length;
          final janakpurCoveragePercentage = (janakpurCoverageCount / locations.length) * 100;
          
          final analytics = {
            'total_days': totalDays,
            'total_locations': locations.length,
            'average_locations_per_day': averageLocationsPerDay,
            'high_accuracy_percentage': highAccuracyPercentage,
            'janakpur_coverage_percentage': janakpurCoveragePercentage,
            'most_active_day': mostActiveDay,
            'least_active_day': leastActiveDay,
            'locations_by_day': locationsByDay.map((day, dayLocations) => 
              MapEntry(day, dayLocations.length)
            ),
          };
          
          print('✅ Location analytics calculated');
          return Right(analytics);
        },
      );
    } catch (e) {
      print('❌ Failed to get location analytics: $e');
      return Left(Failure(
        message: 'Failed to calculate location analytics',
        code: 'ANALYTICS_ERROR',
        details: e,
      ));
    }
  }
  
  /// Calculate distance between two points
  double _calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    const double earthRadius = 6371000; // Earth's radius in meters
    
    final double dLat = _toRadians(lat2 - lat1);
    final double dLng = _toRadians(lng2 - lng1);
    
    final double a = (sin(dLat / 2) * sin(dLat / 2)) +
        (cos(_toRadians(lat1)) * cos(_toRadians(lat2)) * sin(dLng / 2) * sin(dLng / 2));
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    
    return earthRadius * c;
  }
  
  /// Convert degrees to radians
  double _toRadians(double degrees) {
    return degrees * (pi / 180);
  }
}

/// Database helper for MR locations
class DatabaseHelper {
  static Database? _database;
  
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
    await db.execute('''
      CREATE TABLE mr_locations (
        id TEXT PRIMARY KEY,
        mr_id TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        accuracy REAL NOT NULL,
        altitude REAL DEFAULT 0.0,
        speed REAL DEFAULT 0.0,
        heading REAL DEFAULT 0.0,
        source TEXT NOT NULL,
        is_high_accuracy INTEGER DEFAULT 0,
        address TEXT,
        landmark TEXT,
        notes TEXT,
        is_offline INTEGER DEFAULT 0,
        synced_at TEXT,
        device_id TEXT
      )
    ''');
    
    // Create indexes for better performance
    await db.execute('CREATE INDEX idx_mr_id ON mr_locations (mr_id)');
    await db.execute('CREATE INDEX idx_timestamp ON mr_locations (timestamp)');
    await db.execute('CREATE INDEX idx_mr_timestamp ON mr_locations (mr_id, timestamp)');
    await db.execute('CREATE INDEX idx_high_accuracy ON mr_locations (is_high_accuracy)');
    
    print('✅ Database tables created successfully');
  }
  
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here
    print('🔄 Upgrading database from version $oldVersion to $newVersion');
  }
}
