import 'dart:async';
import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';

/// GPS tracking service for MR field force engineering
class GPSTrackingService {
  static final GPSTrackingService _instance = GPSTrackingService._internal();
  factory GPSTrackingService() => _instance;
  GPSTrackingService._internal();

  final StreamController<GPSTrackingData> _trackingController = 
      StreamController<GPSTrackingData>.broadcast();
  final StreamController<LocationPermissionStatus> _permissionController = 
      StreamController<LocationPermissionStatus>.broadcast();
  
  LocationSettings? _locationSettings;
  Timer? _trackingTimer;
  List<GPSCoordinate> _todayCoordinates = [];
  List<GPSCoordinate> _cachedCoordinates = [];
  bool _isTracking = false;
  bool _isHighAccuracyMode = false;
  
  Stream<GPSTrackingData> get trackingStream => _trackingController.stream;
  Stream<LocationPermissionStatus> get permissionStream => _permissionController.stream;
  bool get isTracking => _isTracking;
  bool get isHighAccuracyMode => _isHighAccuracyMode;
  List<GPSCoordinate> get todayCoordinates => List.unmodifiable(_todayCoordinates);
  List<GPSCoordinate> get cachedCoordinates => List.unmodifiable(_cachedCoordinates);

  /// Initialize GPS tracking service
  Future<void> initialize() async {
    try {
      print('🛰️ Initializing GPS tracking service...');
      
      // Request location permissions
      await _requestLocationPermissions();
      
      // Load cached coordinates
      await _loadCachedCoordinates();
      
      // Setup location settings
      await _setupLocationSettings();
      
      // Check if location services are enabled
      await _checkLocationServices();
      
      print('✅ GPS tracking service initialized');
      
    } catch (e) {
      print('❌ Failed to initialize GPS tracking: $e');
      _trackingController.addError(e);
    }
  }

  /// Request location permissions
  Future<void> _requestLocationPermissions() async {
    try {
      print('🔍 Requesting location permissions...');
      
      final permissions = [
        Permission.locationWhenInUse,
        Permission.locationAlways,
        Permission.location,
      ];
      
      final status = await permissions.request();
      
      for (final permission in permissions) {
        final permissionStatus = status[permission];
        _permissionController.add(permissionStatus);
        
        if (permissionStatus == PermissionStatus.granted) {
          print('✅ Permission granted: $permission');
        } else if (permissionStatus == PermissionStatus.denied) {
          print('❌ Permission denied: $permission');
        } else if (permissionStatus == PermissionStatus.permanentlyDenied) {
          print('⚠️ Permission permanently denied: $permission');
        }
      }
      
    } catch (e) {
      print('❌ Failed to request permissions: $e');
    }
  }

  /// Setup location settings for high accuracy
  Future<void> _setupLocationSettings() async {
    try {
      print('⚙️ Setting up location settings...');
      
      _locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5.0, // 5 meters
        timeInterval: Duration(seconds: 10), // Update every 10 seconds
        forceAndroidLocationManager: true,
      );
      
      // Check if high accuracy is available
      final isHighAccuracyAvailable = await _checkHighAccuracyAvailability();
      _isHighAccuracyMode = isHighAccuracyAvailable;
      
      if (!isHighAccuracyAvailable) {
        print('⚠️ High accuracy GPS not available, using standard accuracy');
        _locationSettings = const LocationSettings(
          accuracy: LocationAccuracy.best,
          distanceFilter: 10.0, // 10 meters
          timeInterval: Duration(seconds: 30), // Update every 30 seconds
          forceAndroidLocationManager: true,
        );
      }
      
      print('✅ Location settings configured');
      
    } catch (e) {
      print('❌ Failed to setup location settings: $e');
    }
  }

  /// Check if high accuracy GPS is available
  Future<bool> _checkHighAccuracyAvailability() async {
    try {
      // Check device capabilities
      final isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();
      final locationPermission = await Geolocator.checkPermission();
      
      // High accuracy requires GPS and proper permissions
      return isLocationServiceEnabled && 
             locationPermission == LocationPermission.always &&
             await _hasGPSHardware();
    } catch (e) {
      print('❌ Failed to check high accuracy availability: $e');
      return false;
    }
  }

  /// Check if device has GPS hardware
  Future<bool> _hasGPSHardware() async {
    try {
      // This is a simplified check - in real implementation,
      // we'd use device info plugins to check for GPS
      return true; // Assume GPS is available for now
    } catch (e) {
      print('❌ Failed to check GPS hardware: $e');
      return false;
    }
  }

  /// Check if location services are enabled
  Future<void> _checkLocationServices() async {
    try {
      print('🔍 Checking location services...');
      
      final isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();
      
      if (!isLocationServiceEnabled) {
        print('⚠️ Location services are disabled');
        _permissionController.add(LocationPermissionStatus.denied);
        
        // Request user to enable location services
        await _requestLocationServiceEnable();
      } else {
        print('✅ Location services are enabled');
        _permissionController.add(LocationPermissionStatus.granted);
      }
      
    } catch (e) {
      print('❌ Failed to check location services: $e');
    }
  }

  /// Request user to enable location services
  Future<void> _requestLocationServiceEnable() async {
    try {
      final bool opened = await Geolocator.openLocationSettings();
      if (opened) {
        print('📱 Location settings opened');
      } else {
        print('❌ Could not open location settings');
      }
    } catch (e) {
      print('❌ Failed to open location settings: $e');
    }
  }

  /// Start GPS tracking with high accuracy
  Future<void> startHighAccuracyTracking() async {
    if (_isTracking) {
      print('⚠️ GPS tracking is already active');
      return;
    }

    try {
      print('🛰️ Starting high accuracy GPS tracking...');
      
      // Ensure high accuracy settings
      await _setupLocationSettings();
      
      // Start position stream
      final positionStream = Geolocator.getPositionStream(
        locationSettings: _locationSettings,
      );
      
      _isTracking = true;
      
      // Start tracking timer
      _trackingTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
        _processTrackingData();
      });
      
      // Listen to position updates
      await for (final position in positionStream) {
        await _handlePositionUpdate(position);
      }
      
      print('✅ High accuracy GPS tracking started');
      
    } catch (e) {
      print('❌ Failed to start GPS tracking: $e');
      _isTracking = false;
      _trackingController.addError(e);
    }
  }

  /// Handle position updates
  Future<void> _handlePositionUpdate(Position position) async {
    try {
      final coordinate = GPSCoordinate(
        latitude: position.latitude,
        longitude: position.longitude,
        altitude: position.altitude,
        accuracy: position.accuracy,
        timestamp: DateTime.now(),
        speed: position.speed,
        heading: position.heading,
      );
      
      // Add to today's coordinates
      _todayCoordinates.add(coordinate);
      _cachedCoordinates.add(coordinate);
      
      // Emit tracking data
      final trackingData = GPSTrackingData(
        currentCoordinate: coordinate,
        todayCoordinates: _todayCoordinates,
        isTracking: true,
        accuracy: position.accuracy,
        isHighAccuracy: _isHighAccuracyMode,
      );
      
      _trackingController.add(trackingData);
      
      // Save to cache
      await _saveCachedCoordinates();
      
      print('📍 Position updated: ${coordinate.latitude}, ${coordinate.longitude} (Accuracy: ${coordinate.accuracy}m)');
      
    } catch (e) {
      print('❌ Failed to handle position update: $e');
    }
  }

  /// Process tracking data for analysis
  void _processTrackingData() {
    if (_todayCoordinates.length < 2) return;
    
    try {
      // Calculate today's distance traveled
      final totalDistance = _calculateTotalDistance(_todayCoordinates);
      
      // Calculate average accuracy
      final averageAccuracy = _calculateAverageAccuracy(_todayCoordinates);
      
      // Generate tracking insights
      final insights = GPSTrackingInsights(
        totalDistance: totalDistance,
        averageAccuracy: averageAccuracy,
        coordinatesCount: _todayCoordinates.length,
        trackingDuration: _calculateTrackingDuration(),
        efficiency: _calculateTrackingEfficiency(),
      );
      
      // Emit insights
      _trackingController.add(GPSTrackingData(
        insights: insights,
        currentCoordinate: _todayCoordinates.last,
        todayCoordinates: _todayCoordinates,
        isTracking: true,
        accuracy: averageAccuracy,
        isHighAccuracy: _isHighAccuracyMode,
      ));
      
    } catch (e) {
      print('❌ Failed to process tracking data: $e');
    }
  }

  /// Calculate total distance traveled today
  double _calculateTotalDistance(List<GPSCoordinate> coordinates) {
    if (coordinates.length < 2) return 0.0;
    
    double totalDistance = 0.0;
    
    for (int i = 1; i < coordinates.length; i++) {
      final distance = _calculateDistance(
        coordinates[i - 1],
        coordinates[i],
      );
      totalDistance += distance;
    }
    
    return totalDistance;
  }

  /// Calculate distance between two coordinates
  double _calculateDistance(GPSCoordinate coord1, GPSCoordinate coord2) {
    const double earthRadius = 6371000; // Earth's radius in meters
    
    final double lat1Rad = coord1.latitude * pi / 180;
    final double lat2Rad = coord2.latitude * pi / 180;
    final double deltaLatRad = (coord2.latitude - coord1.latitude) * pi / 180;
    final double deltaLonRad = (coord2.longitude - coord1.longitude) * pi / 180;
    
    final double a = sin(deltaLatRad / 2) * sin(deltaLatRad / 2) +
        cos(lat1Rad) * cos(lat2Rad) *
        sin(deltaLonRad / 2) * sin(deltaLonRad / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    
    return earthRadius * c;
  }

  /// Calculate average accuracy
  double _calculateAverageAccuracy(List<GPSCoordinate> coordinates) {
    if (coordinates.isEmpty) return 0.0;
    
    final totalAccuracy = coordinates
        .map((coord) => coord.accuracy)
        .reduce((a, b) => a + b);
    
    return totalAccuracy / coordinates.length;
  }

  /// Calculate tracking duration
  Duration _calculateTrackingDuration() {
    if (_todayCoordinates.isEmpty) return Duration.zero;
    
    final startTime = _todayCoordinates.first.timestamp;
    final currentTime = DateTime.now();
    
    return currentTime.difference(startTime);
  }

  /// Calculate tracking efficiency
  double _calculateTrackingEfficiency() {
    if (_todayCoordinates.length < 10) return 0.0;
    
    // Efficiency based on accuracy consistency and tracking continuity
    final accuracyVariance = _calculateAccuracyVariance(_todayCoordinates);
    final timeGaps = _calculateTimeGaps(_todayCoordinates);
    
    // Higher efficiency = lower variance and fewer gaps
    return (100.0 - accuracyVariance) / (1.0 + timeGaps);
  }

  /// Calculate accuracy variance
  double _calculateAccuracyVariance(List<GPSCoordinate> coordinates) {
    if (coordinates.length < 2) return 0.0;
    
    final meanAccuracy = _calculateAverageAccuracy(coordinates);
    final squaredDifferences = coordinates
        .map((coord) => pow(coord.accuracy - meanAccuracy, 2))
        .toList();
    
    final variance = squaredDifferences.reduce((a, b) => a + b) / coordinates.length;
    
    return variance;
  }

  /// Calculate time gaps between coordinates
  double _calculateTimeGaps(List<GPSCoordinate> coordinates) {
    if (coordinates.length < 2) return 0.0;
    
    int totalGaps = 0;
    
    for (int i = 1; i < coordinates.length; i++) {
      final timeDiff = coordinates[i].timestamp.difference(coordinates[i - 1].timestamp);
      
      // Count gaps larger than expected interval (30 seconds)
      if (timeDiff.inSeconds > 30) {
        totalGaps++;
      }
    }
    
    return totalGaps.toDouble();
  }

  /// Stop GPS tracking
  Future<void> stopTracking() async {
    if (!_isTracking) {
      print('⚠️ GPS tracking is not active');
      return;
    }

    try {
      print('🛑 Stopping GPS tracking...');
      
      _isTracking = false;
      
      // Cancel tracking timer
      _trackingTimer?.cancel();
      _trackingTimer = null;
      
      // Save final coordinates
      await _saveCachedCoordinates();
      
      // Emit stopped state
      _trackingController.add(GPSTrackingData(
        isTracking: false,
        todayCoordinates: _todayCoordinates,
        currentCoordinate: _todayCoordinates.isNotEmpty ? _todayCoordinates.last : null,
        isHighAccuracy: _isHighAccuracyMode,
      ));
      
      print('✅ GPS tracking stopped');
      
    } catch (e) {
      print('❌ Failed to stop GPS tracking: $e');
    }
  }

  /// Clear today's coordinates
  Future<void> clearTodayCoordinates() async {
    try {
      print('🗑️ Clearing today's coordinates...');
      
      _todayCoordinates.clear();
      
      // Save cleared state
      await _saveCachedCoordinates();
      
      // Emit cleared state
      _trackingController.add(GPSTrackingData(
        todayCoordinates: [],
        isTracking: _isTracking,
        isHighAccuracy: _isHighAccuracyMode,
      ));
      
      print('✅ Today's coordinates cleared');
      
    } catch (e) {
      print('❌ Failed to clear coordinates: $e');
    }
  }

  /// Load cached coordinates from storage
  Future<void> _loadCachedCoordinates() async {
    try {
      print('📂 Loading cached coordinates...');
      
      final prefs = await SharedPreferences.getInstance();
      final coordinatesJson = prefs.getString('cached_coordinates');
      
      if (coordinatesJson != null) {
        final coordinatesList = List<Map<String, dynamic>>.from(
          jsonDecode(coordinatesJson)
        );
        
        _cachedCoordinates = coordinatesList
            .map((json) => GPSCoordinate.fromJson(json))
            .toList();
        
        // Filter today's coordinates
        final today = DateTime.now();
        _todayCoordinates = _cachedCoordinates
            .where((coord) => _isSameDay(coord.timestamp, today))
            .toList();
        
        print('✅ Loaded ${_cachedCoordinates.length} cached coordinates');
        print('✅ Loaded ${_todayCoordinates.length} today's coordinates');
      }
      
    } catch (e) {
      print('❌ Failed to load cached coordinates: $e');
    }
  }

  /// Save cached coordinates to storage
  Future<void> _saveCachedCoordinates() async {
    try {
      print('💾 Saving cached coordinates...');
      
      final prefs = await SharedPreferences.getInstance();
      final coordinatesJson = jsonEncode(
        _cachedCoordinates.map((coord) => coord.toJson()).toList(),
      );
      
      await prefs.setString('cached_coordinates', coordinatesJson);
      await prefs.setString('last_coordinates_update', DateTime.now().toIso8601String());
      
      print('✅ Saved ${_cachedCoordinates.length} cached coordinates');
      
    } catch (e) {
      print('❌ Failed to save cached coordinates: $e');
    }
  }

  /// Check if two dates are the same day
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  /// Get current GPS status
  Future<GPSStatus> getCurrentStatus() async {
    try {
      final isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();
      final locationPermission = await Geolocator.checkPermission();
      final currentPosition = await Geolocator.getCurrentPosition(
        locationSettings: _locationSettings,
      );
      
      return GPSStatus(
        isLocationServiceEnabled: isLocationServiceEnabled,
        permissionStatus: _mapPermissionStatus(locationPermission),
        currentPosition: currentPosition,
        isHighAccuracyAvailable: _isHighAccuracyMode,
        isTracking: _isTracking,
        todayCoordinatesCount: _todayCoordinates.length,
        lastUpdate: DateTime.now(),
      );
      
    } catch (e) {
      print('❌ Failed to get GPS status: $e');
      return GPSStatus(
        isLocationServiceEnabled: false,
        permissionStatus: LocationPermissionStatus.denied,
        isTracking: _isTracking,
        lastUpdate: DateTime.now(),
        error: e.toString(),
      );
    }
  }

  /// Map location permission status
  LocationPermissionStatus _mapPermissionStatus(LocationPermission permission) {
    switch (permission) {
      case LocationPermission.always:
        return LocationPermissionStatus.granted;
      case LocationPermission.whileInUse:
        return LocationPermissionStatus.granted;
      case LocationPermission.denied:
        return LocationPermissionStatus.denied;
      case LocationPermission.deniedForever:
        return LocationPermissionStatus.permanentlyDenied;
      case LocationPermission.unableToDetermine:
        return LocationPermissionStatus.denied;
      default:
        return LocationPermissionStatus.denied;
    }
  }

  /// Dispose resources
  void dispose() {
    print('🗑️ Disposing GPS tracking service...');
    
    _trackingTimer?.cancel();
    _trackingController.close();
    _permissionController.close();
    
    print('✅ GPS tracking service disposed');
  }
}

/// GPS coordinate data model
class GPSCoordinate {
  final double latitude;
  final double longitude;
  final double? altitude;
  final double accuracy;
  final DateTime timestamp;
  final double? speed;
  final double? heading;
  
  GPSCoordinate({
    required this.latitude,
    required this.longitude,
    this.altitude,
    required this.accuracy,
    required this.timestamp,
    this.speed,
    this.heading,
  });

  factory GPSCoordinate.fromJson(Map<String, dynamic> json) {
    return GPSCoordinate(
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
      altitude: json['altitude']?.toDouble(),
      accuracy: json['accuracy']?.toDouble() ?? 0.0,
      timestamp: DateTime.parse(json['timestamp']),
      speed: json['speed']?.toDouble(),
      heading: json['heading']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'altitude': altitude,
      'accuracy': accuracy,
      'timestamp': timestamp.toIso8601String(),
      'speed': speed,
      'heading': heading,
    };
  }

  @override
  String toString() {
    return 'GPSCoordinate(lat: $latitude, lng: $longitude, accuracy: ${accuracy}m, time: $timestamp)';
  }
}

/// GPS tracking data model
class GPSTrackingData {
  final GPSCoordinate? currentCoordinate;
  final List<GPSCoordinate> todayCoordinates;
  final bool isTracking;
  final double accuracy;
  final bool isHighAccuracy;
  final GPSTrackingInsights? insights;
  
  GPSTrackingData({
    this.currentCoordinate,
    required this.todayCoordinates,
    required this.isTracking,
    required this.accuracy,
    required this.isHighAccuracy,
    this.insights,
  });
}

/// GPS tracking insights model
class GPSTrackingInsights {
  final double totalDistance; // in meters
  final double averageAccuracy; // in meters
  final int coordinatesCount;
  final Duration trackingDuration;
  final double efficiency; // 0-100 scale
  
  GPSTrackingInsights({
    required this.totalDistance,
    required this.averageAccuracy,
    required this.coordinatesCount,
    required this.trackingDuration,
    required this.efficiency,
  });
}

/// GPS status model
class GPSStatus {
  final bool isLocationServiceEnabled;
  final LocationPermissionStatus permissionStatus;
  final Position? currentPosition;
  final bool isHighAccuracyAvailable;
  final bool isTracking;
  final int todayCoordinatesCount;
  final DateTime lastUpdate;
  final String? error;
  
  GPSStatus({
    required this.isLocationServiceEnabled,
    required this.permissionStatus,
    this.currentPosition,
    required this.isHighAccuracyAvailable,
    required this.isTracking,
    required this.todayCoordinatesCount,
    required this.lastUpdate,
    this.error,
  });
}

/// Location permission status enum
enum LocationPermissionStatus {
  granted,
  denied,
  permanentlyDenied,
}
