import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../entities/mr_location.dart';
import '../repositories/mr_location_repository.dart';

/// Medical Representative Location Service
/// Handles GPS tracking, background location polling, and geospatial data management
class MRLocationService {
  final MRLocationRepository _repository;
  final StreamController<MRLocation> _locationStreamController;
  Timer? _locationTimer;
  MRLocation? _lastKnownLocation;
  bool _isTracking = false;
  bool _isHighAccuracyMode = false;
  List<MRLocation> _offlineLocations = [];
  
  MRLocationService(this._repository) 
    : _locationStreamController = StreamController<MRLocation>.broadcast();

  /// Stream of location updates
  Stream<MRLocation> get locationStream => _locationStreamController.stream;

  /// Current tracking status
  bool get isTracking => _isTracking;

  /// Last known location
  MRLocation? get lastKnownLocation => _lastKnownLocation;

  /// High accuracy mode status
  bool get isHighAccuracyMode => _isHighAccuracyMode;

  /// Initialize location service
  Future<void> initialize() async {
    try {
// print('🔍 Initializing MR Location Service...'); // Removed for production
      
      // Check location permissions
      final hasPermission = await _checkLocationPermission();
      if (!hasPermission) {
        throw Exception('Location permission denied');
      }
      
      // Check if location services are enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }
      
      // Load offline locations from local storage
      await _loadOfflineLocations();
      
// print('✅ MR Location Service initialized successfully'); // Removed for production
    } catch (e) {
// print('❌ Failed to initialize MR Location Service: $e'); // Removed for production
      rethrow;
    }
  }

  /// Start location tracking with background polling
  Future<void> startTracking({
    String? mrId,
    bool highAccuracy = false,
    Duration interval = const Duration(seconds: 30),
  }) async {
    if (_isTracking) {
// print('⚠️ Location tracking is already active'); // Removed for production
      return;
    }

    try {
// print('🚀 Starting location tracking...'); // Removed for production
      _isTracking = true;
      _isHighAccuracyMode = highAccuracy;
      
      // Get initial location
      final initialLocation = await _getCurrentHighAccuracyLocation();
      if (initialLocation != null) {
        _lastKnownLocation = MRLocation.fromPosition(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          mrId: mrId ?? 'default',
          position: initialLocation,
        );
        
        // Save to repository
        await _repository.saveLocation(_lastKnownLocation!);
        _locationStreamController.add(_lastKnownLocation!);
        
// print('📍 Initial location captured: ${_lastKnownLocation!.getFormattedLocation()}'); // Removed for production
      }
      
      // Start background location polling
      _startLocationPolling(interval);
      
// print('✅ Location tracking started (High Accuracy: $highAccuracy)'); // Removed for production
    } catch (e) {
// print('❌ Failed to start location tracking: $e'); // Removed for production
      _isTracking = false;
      rethrow;
    }
  }

  /// Stop location tracking
  Future<void> stopTracking() async {
    if (!_isTracking) {
// print('⚠️ Location tracking is not active'); // Removed for production
      return;
    }

    try {
// print('🛑 Stopping location tracking...'); // Removed for production
      _isTracking = false;
      
      // Stop background polling
      _locationTimer?.cancel();
      _locationTimer = null;
      
      // Sync any remaining offline locations
      if (_offlineLocations.isNotEmpty) {
        await _syncOfflineLocations();
      }
      
// print('✅ Location tracking stopped'); // Removed for production
    } catch (e) {
// print('❌ Failed to stop location tracking: $e'); // Removed for production
    }
  }

  /// Get current location with high accuracy
  Future<Position?> _getCurrentHighAccuracyLocation() async {
    try {
// print('🔍 Getting high accuracy location...'); // Removed for production
      
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation,
        timeLimit: const Duration(seconds: 30),
      );
      
      if (position.accuracy <= 10.0) {
// print('✅ High accuracy location obtained: ${position.accuracy}m'); // Removed for production
        return position;
      } else {
// print('⚠️ Location accuracy is poor: ${position.accuracy}m'); // Removed for production
        return position;
      }
    } catch (e) {
// print('❌ Failed to get current location: $e'); // Removed for production
      return null;
    }
  }

  /// Start background location polling
  void _startLocationPolling(Duration interval) {
    _locationTimer?.cancel();
    
    _locationTimer = Timer.periodic(interval, (timer) async {
      if (!_isTracking) return;
      
      try {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: _isHighAccuracyMode 
            ? LocationAccuracy.bestForNavigation 
            : LocationAccuracy.high,
          timeLimit: const Duration(seconds: 15),
        );
        
        final location = MRLocation.fromPosition(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          mrId: 'tracking',
          position: position,
        );
        
        // Validate location quality
        if (location.isSuitableForVisit()) {
          _lastKnownLocation = location;
          
          // Save to repository
          await _repository.saveLocation(location);
          _locationStreamController.add(location);
          
// print('📍 Location updated: ${location.getFormattedLocation()} (${location.getFormattedAccuracy()})'); // Removed for production
        } else {
// print('⚠️ Location quality poor: ${location.getFormattedAccuracy()}'); // Removed for production
          
          // Add to offline cache for later sync
          _offlineLocations.add(location);
        }
        
      } catch (e) {
// print('❌ Location polling failed: $e'); // Removed for production
      }
    });
  }

  /// Check location permission
  Future<bool> _checkLocationPermission() async {
    try {
      final permission = await Geolocator.checkPermission();
      
      switch (permission) {
        case LocationPermission.always:
        case LocationPermission.whileInUse:
          return true;
        case LocationPermission.denied:
          final requestResult = await Geolocator.requestPermission();
          return requestResult == LocationPermission.always || 
                 requestResult == LocationPermission.whileInUse;
        case LocationPermission.deniedForever:
          return false;
        case LocationPermission.unableToDetermine:
          return false;
      }
    } catch (e) {
// print('❌ Permission check failed: $e'); // Removed for production
      return false;
    }
  }

  /// Load offline locations from local storage
  Future<void> _loadOfflineLocations() async {
    try {
// print('📂 Loading offline locations...'); // Removed for production
      
      // This would load from local storage/database
      // For now, we'll use an empty list
      _offlineLocations = [];
      
// print('✅ Loaded ${_offlineLocations.length} offline locations'); // Removed for production
    } catch (e) {
// print('❌ Failed to load offline locations: $e'); // Removed for production
    }
  }

  /// Sync offline locations to server
  Future<void> _syncOfflineLocations() async {
    if (_offlineLocations.isEmpty) return;
    
    try {
// print('🔄 Syncing ${_offlineLocations.length} offline locations...'); // Removed for production
      
      for (final location in _offlineLocations) {
        final syncedLocation = location.copyWith(
          syncedAt: DateTime.now(),
          isOffline: false,
        );
        
        await _repository.saveLocation(syncedLocation);
      }
      
      _offlineLocations.clear();
// print('✅ Offline locations synced successfully'); // Removed for production
    } catch (e) {
// print('❌ Failed to sync offline locations: $e'); // Removed for production
    }
  }

  /// Get location history for MR
  Future<List<MRLocation>> getLocationHistory({
    required String mrId,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    try {
// print('📊 Getting location history for MR: $mrId'); // Removed for production
      
      final locations = await _repository.getLocationsByMrId(
        mrId,
        startDate: startDate,
        endDate: endDate,
        limit: limit,
      );
      
// print('✅ Retrieved ${locations.length} location records'); // Removed for production
      return locations;
    } catch (e) {
// print('❌ Failed to get location history: $e'); // Removed for production
      return [];
    }
  }

  /// Calculate daily trajectory for MR
  Future<List<LatLng>> calculateDailyTrajectory({
    required String mrId,
    DateTime? date,
  }) async {
    try {
// print('🗺️ Calculating daily trajectory for MR: $mrId'); // Removed for production
      
      final targetDate = date ?? DateTime.now();
      final startDate = DateTime(
        targetDate.year,
        targetDate.month,
        targetDate.day,
        0, 0, 0,
      );
      final endDate = DateTime(
        targetDate.year,
        targetDate.month,
        targetDate.day,
        23, 59, 59,
      );
      
      final locations = await _repository.getLocationsByMrId(
        mrId,
        startDate: startDate,
        endDate: endDate,
      );
      
      if (locations.isEmpty) {
// print('⚠️ No locations found for trajectory calculation'); // Removed for production
        return [];
      }
      
      // Filter for high accuracy locations
      final highAccuracyLocations = locations
          .where((loc) => loc.isHighAccuracy)
          .toList();
      
      // Create trajectory points
      final trajectory = highAccuracyLocations
          .map((loc) => loc.toLatLng())
          .toList();
      
// print('✅ Calculated trajectory with ${trajectory.length} points'); // Removed for production
      return trajectory;
    } catch (e) {
// print('❌ Failed to calculate trajectory: $e'); // Removed for production
      return [];
    }
  }

  /// Get location statistics for MR
  Future<Map<String, dynamic>> getLocationStatistics({
    required String mrId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
// print('📈 Getting location statistics for MR: $mrId'); // Removed for production
      
      final locations = await _repository.getLocationsByMrId(
        mrId,
        startDate: startDate,
        endDate: endDate,
      );
      
      if (locations.isEmpty) {
        return {
          'total_locations': 0,
          'high_accuracy_locations': 0,
          'average_accuracy': 0.0,
          'total_distance': 0.0,
          'coverage_percentage': 0.0,
        };
      }
      
      final highAccuracyCount = locations
          .where((loc) => loc.isHighAccuracy)
          .length;
      
      final averageAccuracy = locations
          .map((loc) => loc.accuracy)
          .reduce((a, b) => a + b, 0) / locations.length;
      
      // Calculate total distance traveled
      double totalDistance = 0.0;
      for (int i = 1; i < locations.length; i++) {
        totalDistance += Geolocator.distanceBetween(
          locations[i - 1].latitude,
          locations[i - 1].longitude,
          locations[i].latitude,
          locations[i].longitude,
        );
      }
      
      // Calculate coverage percentage (locations within Janakpur area)
      final coverageCount = locations
          .where((loc) => loc.isWithinJanakpurArea())
          .length;
      final coveragePercentage = (coverageCount / locations.length) * 100;
      
      final statistics = {
        'total_locations': locations.length,
        'high_accuracy_locations': highAccuracyCount,
        'average_accuracy': averageAccuracy.toStringAsFixed(2),
        'total_distance': totalDistance.toStringAsFixed(2),
        'coverage_percentage': coveragePercentage.toStringAsFixed(1),
        'janakpur_coverage': coverageCount,
        'tracking_quality': averageAccuracy <= 10.0 ? 'Excellent' : 
                         averageAccuracy <= 15.0 ? 'Good' : 
                         averageAccuracy <= 20.0 ? 'Fair' : 'Poor',
      };
      
// print('✅ Location statistics calculated'); // Removed for production
      return statistics;
    } catch (e) {
// print('❌ Failed to get location statistics: $e'); // Removed for production
      return {};
    }
  }

  /// Add manual location entry
  Future<void> addManualLocation({
    required String mrId,
    required double latitude,
    required double longitude,
    required String address,
    String? landmark,
    String? notes,
  }) async {
    try {
// print('📍 Adding manual location entry...'); // Removed for production
      
      final location = MRLocation(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        mrId: mrId,
        timestamp: DateTime.now(),
        latitude: latitude,
        longitude: longitude,
        accuracy: 0.0, // Manual entry assumed accurate
        source: LocationSource.manual,
        address: address,
        landmark: landmark,
        notes: notes,
      );
      
      await _repository.saveLocation(location);
      _locationStreamController.add(location);
      
// print('✅ Manual location added: ${location.getFormattedLocation()}'); // Removed for production
    } catch (e) {
// print('❌ Failed to add manual location: $e'); // Removed for production
    }
  }

  /// Delete location record
  Future<void> deleteLocation(String locationId) async {
    try {
// print('🗑️ Deleting location: $locationId'); // Removed for production
      
      await _repository.deleteLocation(locationId);
      
// print('✅ Location deleted successfully'); // Removed for production
    } catch (e) {
// print('❌ Failed to delete location: $e'); // Removed for production
    }
  }

  /// Export location data
  Future<void> exportLocationData({
    required String mrId,
    DateTime? startDate,
    DateTime? endDate,
    String format = 'json',
  }) async {
    try {
// print('📤 Exporting location data for MR: $mrId'); // Removed for production
      
      final locations = await _repository.getLocationsByMrId(
        mrId,
        startDate: startDate,
        endDate: endDate,
      );
      
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filename = '${mrId}_locations_$timestamp.$format';
      
      if (format.toLowerCase() == 'json') {
        final jsonData = {
          'mr_id': mrId,
          'export_date': DateTime.now().toIso8601String(),
          'total_locations': locations.length,
          'locations': locations.map((loc) => loc.toMap()).toList(),
        };
        
        final file = File(filename);
        await file.writeAsString(jsonEncode(jsonData));
        
// print('✅ Location data exported to: $filename'); // Removed for production
      } else if (format.toLowerCase() == 'csv') {
        final csvData = [
          'Timestamp,Latitude,Longitude,Accuracy,Address,Landmark,Notes',
          ...locations.map((loc) => 
            '${loc.timestamp.toIso8601String()},'
            '${loc.latitude},'
            '${loc.longitude},'
            '${loc.accuracy},'
            '"${loc.address ?? ''}",'
            '"${loc.landmark ?? ''}",'
            '"${loc.notes ?? ''}"'
          ),
        ].join('\n');
        
        final file = File(filename);
        await file.writeAsString(csvData);
        
// print('✅ Location data exported to: $filename'); // Removed for production
      }
    } catch (e) {
// print('❌ Failed to export location data: $e'); // Removed for production
    }
  }

  /// Dispose resources
  void dispose() {
// print('🗑️ Disposing MR Location Service...'); // Removed for production
    
    _locationTimer?.cancel();
    _locationStreamController.close();
    _isTracking = false;
    
// print('✅ MR Location Service disposed'); // Removed for production
  }
}
