import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Background GPS Service for continuous MR tracking
/// Runs independently of UI - persists even when app is backgrounded
class BackgroundGpsService {
  static final BackgroundGpsService _instance = BackgroundGpsService._internal();
  factory BackgroundGpsService() => _instance;
  BackgroundGpsService._internal();

  StreamSubscription<Position>? _positionStream;
  final List<LatLng> _trajectoryPoints = [];
  bool _isTracking = false;
  DateTime? _trackingStartedAt;
  String? _currentMrId;
  
  // Callbacks for UI updates
  final _trajectoryController = StreamController<List<LatLng>>.broadcast();
  final _trackingStatusController = StreamController<bool>.broadcast();
  final _locationController = StreamController<Position>.broadcast();
  
  Stream<List<LatLng>> get trajectoryStream => _trajectoryController.stream;
  Stream<bool> get trackingStatusStream => _trackingStatusController.stream;
  Stream<Position> get locationStream => _locationController.stream;
  
  bool get isTracking => _isTracking;
  List<LatLng> get trajectoryPoints => List.unmodifiable(_trajectoryPoints);
  DateTime? get trackingStartedAt => _trackingStartedAt;

  /// Initialize and check permissions
  Future<bool> initialize() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await Geolocator.openLocationSettings();
        return serviceEnabled;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      
      if (permission == LocationPermission.deniedForever) {
        return false;
      }

      // Load persisted trajectory
      await _loadPersistedTrajectory();
      
      return permission == LocationPermission.whileInUse || 
             permission == LocationPermission.always;
    } catch (e) {
      debugPrint('BackgroundGPS: Initialization error: $e');
      return false;
    }
  }

  /// Start continuous background tracking
  Future<bool> startTracking({String? mrId}) async {
    if (_isTracking) return true;
    
    final hasPermission = await initialize();
    if (!hasPermission) {
      debugPrint('BackgroundGPS: Permission denied');
      return false;
    }

    try {
      _currentMrId = mrId;
      _trackingStartedAt = DateTime.now();
      _isTracking = true;
      
      // Settings optimized for field force tracking
      const LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      );

      _positionStream = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen(
        _onPositionUpdate,
        onError: (error) {
          debugPrint('BackgroundGPS: Stream error: $error');
        },
        cancelOnError: false,
      );

      _trackingStatusController.add(true);
      
      return true;
    } catch (e) {
      _isTracking = false;
      return false;
    }
  }

  /// Stop tracking
  Future<void> stopTracking() async {
    await _positionStream?.cancel();
    _positionStream = null;
    _isTracking = false;
    _trackingStatusController.add(false);
    
    // Persist final trajectory
    await _persistTrajectory();
  }

  /// Handle position updates
  void _onPositionUpdate(Position position) {
    if (!_isTracking) return;
    
    final point = LatLng(position.latitude, position.longitude);
    _trajectoryPoints.add(point);
    
    // Keep only last 500 points to prevent memory issues
    if (_trajectoryPoints.length > 500) {
      _trajectoryPoints.removeAt(0);
    }
    
    // Broadcast to UI listeners
    _trajectoryController.add(List.unmodifiable(_trajectoryPoints));
    _locationController.add(position);
    
    // Persist every 10 points
    if (_trajectoryPoints.length % 10 == 0) {
      _persistTrajectory();
    }
    
    // TODO: Sync to backend
    _syncToBackend(position);
  }

  /// Persist trajectory to local storage
  Future<void> _persistTrajectory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pointsJson = _trajectoryPoints.map((p) => {
        'lat': p.latitude,
        'lng': p.longitude,
      }).toList();
      
      await prefs.setString('bg_gps_trajectory', jsonEncode(pointsJson));
      await prefs.setString('bg_gps_started_at', _trackingStartedAt?.toIso8601String() ?? '');
      await prefs.setString('bg_gps_mr_id', _currentMrId ?? '');
    } catch (e) {
      // Silent fail - will retry on next persist cycle
    }
  }

  /// Load persisted trajectory
  Future<void> _loadPersistedTrajectory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final trajectoryJson = prefs.getString('bg_gps_trajectory');
      final startedAt = prefs.getString('bg_gps_started_at');
      final mrId = prefs.getString('bg_gps_mr_id');
      
      if (trajectoryJson != null) {
        final List<dynamic> points = jsonDecode(trajectoryJson);
        _trajectoryPoints.clear();
        _trajectoryPoints.addAll(
          points.map((p) => LatLng(p['lat'], p['lng'])),
        );
      }
      
      if (startedAt != null && startedAt.isNotEmpty) {
        _trackingStartedAt = DateTime.parse(startedAt);
      }
      
      _currentMrId = mrId;
    } catch (e) {
      // Silent fail on load - start fresh
    }
  }

  /// Clear persisted data
  Future<void> clearTrajectory() async {
    _trajectoryPoints.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('bg_gps_trajectory');
    await prefs.remove('bg_gps_started_at');
    _trajectoryController.add([]);
  }

  /// Sync position to backend (placeholder for API integration)
  Future<void> _syncToBackend(Position position) async {
    // TODO: Implement backend sync
    // POST /api/mr/location with MR ID, lat, lng, accuracy, timestamp
    if (kDebugMode) {
      debugPrint('BackgroundGPS: Sync ${position.latitude}, ${position.longitude}');
    }
  }

  /// Get current position with high accuracy
  Future<Position?> getCurrentPosition() async {
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );
    } catch (e) {
      return null;
    }
  }

  /// Get distance traveled
  double getTotalDistance() {
    if (_trajectoryPoints.length < 2) return 0;
    
    const Distance distance = Distance();
    double total = 0;
    
    for (int i = 1; i < _trajectoryPoints.length; i++) {
      total += distance(_trajectoryPoints[i - 1], _trajectoryPoints[i]);
    }
    
    return total; // in meters
  }

  /// Get tracking duration
  Duration? getTrackingDuration() {
    if (_trackingStartedAt == null) return null;
    return DateTime.now().difference(_trackingStartedAt!);
  }

  /// Format duration for display
  String getFormattedDuration() {
    final duration = getTrackingDuration();
    if (duration == null) return '0h 0m';
    
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
  }

  /// Dispose streams
  void dispose() {
    _positionStream?.cancel();
    _trajectoryController.close();
    _trackingStatusController.close();
    _locationController.close();
  }
}
