import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import '../../app/theme/app_theme.dart';
import '../../shared/widgets/glassmorphic_widgets.dart';

/// Enhanced background GPS service for real-time MR tracking
class EnhancedBackgroundGpsService {
  static const Duration _locationUpdateInterval = Duration(seconds: 10);
  static const Duration _maxAge = Duration(hours: 24);
  static const double _requiredAccuracy = 50.0; // 50 meters
  
  final StreamController<List<LatLng>> _trajectoryController = 
      StreamController<List<LatLng>>.broadcast();
  final StreamController<bool> _trackingStatusController = 
      StreamController<bool>.broadcast();
  final StreamController<Map<String, dynamic>> _locationDataController = 
      StreamController<Map<String, dynamic>>.broadcast();
  
  List<LatLng> _trajectoryPoints = [];
  List<Map<String, dynamic>> _locationHistory = [];
  bool _isTracking = false;
  Timer? _locationTimer;
  Position? _lastPosition;
  String? _currentMrId;
  
  Stream<List<LatLng>> get trajectoryStream => _trajectoryController.stream;
  Stream<bool> get trackingStatusStream => _trackingStatusController.stream;
  Stream<Map<String, dynamic>> get locationDataStream => _locationDataController.stream;
  
  List<LatLng> get trajectoryPoints => List.unmodifiable(_trajectoryPoints);
  bool get isTracking => _isTracking;
  List<Map<String, dynamic>> get locationHistory => List.unmodifiable(_locationHistory);
  
  /// Initialize GPS service with permission handling
  Future<bool> initialize() async {
    try {
      // Check location permissions
      final hasPermission = await _checkLocationPermission();
      if (!hasPermission) {
        
        return false;
      }
      
      // Check location services
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        
        return false;
      }
      
      // Load cached trajectory data
      await _loadCachedTrajectory();

      return true;
    } catch (e) {
      
      return false;
    }
  }
  
  /// Start tracking MR with enhanced features
  Future<bool> startTracking({required String mrId}) async {
    if (_isTracking) {
      
      return true;
    }
    
    try {
      _currentMrId = mrId;
      
      // Request high accuracy location
      final locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5.0, // 5 meters
        interval: Duration(seconds: 5), // Update every 5 seconds
      );
      
      // Start periodic location updates
      _locationTimer = Timer.periodic(_locationUpdateInterval, (_) {
        _updateLocation();
      });
      
      // Get initial position
      await _updateLocation();
      
      _isTracking = true;
      _trackingStatusController.add(true);

      return true;
    } catch (e) {
      
      return false;
    }
  }
  
  /// Stop tracking and save data
  Future<void> stopTracking() async {
    if (!_isTracking) return;
    
    try {
      _locationTimer?.cancel();
      _locationTimer = null;
      
      _isTracking = false;
      _trackingStatusController.add(false);
      
      // Save trajectory to cache
      await _saveTrajectory();

    } catch (e) {
      
    }
  }
  
  /// Get current position with accuracy validation
  Future<Position?> getCurrentPosition() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      
      // Validate accuracy
      if (position.accuracy > _requiredAccuracy) {
        
        return null;
      }
      
      _lastPosition = position;
      return position;
    } catch (e) {
      
      return null;
    }
  }
  
  /// Update location with enhanced validation
  Future<void> _updateLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      
      if (position.accuracy > _requiredAccuracy) {
        
        return;
      }
      
      final newPoint = LatLng(position.latitude, position.longitude);
      
      // Add to trajectory if significantly different from last point
      if (_shouldAddPoint(newPoint)) {
        _trajectoryPoints.add(newPoint);
        
        // Add to location history with metadata
        final locationData = {
          'timestamp': DateTime.now().toIso8601String(),
          'latitude': position.latitude,
          'longitude': position.longitude,
          'accuracy': position.accuracy,
          'altitude': position.altitude,
          'speed': position.speed,
          'heading': position.heading,
          'mrId': _currentMrId,
        };
        
        _locationHistory.add(locationData);
        
        // Keep only last 1000 points in memory
        if (_trajectoryPoints.length > 1000) {
          _trajectoryPoints.removeAt(0);
        }
        
        if (_locationHistory.length > 1000) {
          _locationHistory.removeAt(0);
        }
        
        // Update streams
        _trajectoryController.add(List.from(_trajectoryPoints));
        _locationDataController.add(locationData);

      }
      
      _lastPosition = position;
    } catch (e) {
      
    }
  }
  
  /// Check if point should be added to trajectory
  bool _shouldAddPoint(LatLng newPoint) {
    if (_trajectoryPoints.isEmpty) return true;
    
    final lastPoint = _trajectoryPoints.last;
    final distance = Geolocator.distanceBetween(
      lastPoint.latitude,
      lastPoint.longitude,
      newPoint.latitude,
      newPoint.longitude,
    );
    
    // Add point if moved at least 10 meters
    return distance > 10.0;
  }
  
  /// Check location permission
  Future<bool> _checkLocationPermission() async {
    final permission = await Geolocator.checkPermission();
    
    switch (permission) {
      case LocationPermission.always:
      case LocationPermission.whileInUse:
        return true;
      case LocationPermission.denied:
        await Geolocator.requestPermission();
        return false;
      case LocationPermission.deniedForever:
        
        return false;
      case LocationPermission.unableToDetermine:
        
        return false;
      default:
        return false;
    }
  }
  
  /// Load cached trajectory from storage
  Future<void> _loadCachedTrajectory() async {
    try {
      // This would integrate with SharedPreferences or local storage
      // For now, initialize empty trajectory
      _trajectoryPoints = [];
      _locationHistory = [];

    } catch (e) {
      
    }
  }
  
  /// Save trajectory to storage
  Future<void> _saveTrajectory() async {
    try {
      // This would integrate with SharedPreferences or local storage
      // For now, just log the save

      // Clean old data (older than 24 hours)
      final now = DateTime.now();
      _locationHistory.removeWhere((location) {
        final timestamp = DateTime.parse(location['timestamp']);
        return now.difference(timestamp) > _maxAge;
      });

    } catch (e) {
      
    }
  }
  
  /// Get trajectory statistics
  Map<String, dynamic> getTrajectoryStats() {
    if (_trajectoryPoints.isEmpty) {
      return {
        'totalPoints': 0,
        'totalDistance': 0.0,
        'averageAccuracy': 0.0,
        'duration': Duration.zero,
        'startTime': null,
        'endTime': null,
      };
    }
    
    double totalDistance = 0.0;
    double totalAccuracy = 0.0;
    
    for (int i = 1; i < _trajectoryPoints.length; i++) {
      totalDistance += Geolocator.distanceBetween(
        _trajectoryPoints[i - 1].latitude,
        _trajectoryPoints[i - 1].longitude,
        _trajectoryPoints[i].latitude,
        _trajectoryPoints[i].longitude,
      );
    }
    
    for (final location in _locationHistory) {
      totalAccuracy += location['accuracy'] ?? 0.0;
    }
    
    final averageAccuracy = _locationHistory.isNotEmpty 
        ? totalAccuracy / _locationHistory.length 
        : 0.0;
    
    final startTime = _locationHistory.isNotEmpty 
        ? DateTime.parse(_locationHistory.first['timestamp'])
        : null;
    
    final endTime = _locationHistory.isNotEmpty 
        ? DateTime.parse(_locationHistory.last['timestamp'])
        : null;
    
    final duration = startTime != null && endTime != null 
        ? endTime!.difference(startTime!)
        : Duration.zero;
    
    return {
      'totalPoints': _trajectoryPoints.length,
      'totalDistance': totalDistance,
      'averageAccuracy': averageAccuracy,
      'duration': duration,
      'startTime': startTime,
      'endTime': endTime,
    };
  }
  
  /// Export trajectory data
  Future<Map<String, dynamic>> exportTrajectory() async {
    final stats = getTrajectoryStats();
    
    return {
      'mrId': _currentMrId,
      'exportTime': DateTime.now().toIso8601String(),
      'statistics': stats,
      'trajectory': _trajectoryPoints.map((point) => {
        'latitude': point.latitude,
        'longitude': point.longitude,
      }).toList(),
      'locationHistory': _locationHistory,
    };
  }
  
  /// Clear all tracking data
  Future<void> clearTrackingData() async {
    _trajectoryPoints.clear();
    _locationHistory.clear();
    _lastPosition = null;
    
    _trajectoryController.add([]);
    _locationDataController.add({});

  }
  
  /// Dispose resources
  void dispose() {
    _locationTimer?.cancel();
    _trajectoryController.close();
    _trackingStatusController.close();
    _locationDataController.close();
  }
}
