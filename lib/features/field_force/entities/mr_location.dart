import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Medical Representative location tracking entity
/// Handles GPS coordinates, accuracy, and geospatial data for field force management
class MRLocation {
  final String id;
  final String mrId;
  final DateTime timestamp;
  final double latitude;
  final double longitude;
  final double accuracy;
  final double altitude;
  final double speed;
  final double heading;
  final LocationSource source;
  final bool isHighAccuracy;
  final String? address;
  final String? landmark;
  final String? notes;
  final bool isOffline;
  final DateTime? syncedAt;
  final String? deviceId;

  const MRLocation({
    required this.id,
    required this.mrId,
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    this.altitude = 0.0,
    this.speed = 0.0,
    this.heading = 0.0,
    this.source = LocationSource.gps,
    this.isHighAccuracy = false,
    this.address,
    this.landmark,
    this.notes,
    this.isOffline = false,
    this.syncedAt,
    this.deviceId,
  });

  /// Creates MRLocation from geolocator position
  factory MRLocation.fromPosition({
    required String id,
    required String mrId,
    required Position position,
    String? address,
    String? landmark,
    String? notes,
    String? deviceId,
  }) {
    return MRLocation(
      id: id,
      mrId: mrId,
      timestamp: DateTime.now(),
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
      altitude: position.altitude ?? 0.0,
      speed: position.speed ?? 0.0,
      heading: position.heading ?? 0.0,
      source: _getLocationSource(position),
      isHighAccuracy: position.accuracy <= 10.0,
      address: address,
      landmark: landmark,
      notes: notes,
      deviceId: deviceId,
    );
  }

  /// Creates MRLocation from database record
  factory MRLocation.fromMap(Map<String, dynamic> map) {
    return MRLocation(
      id: map['id'] as String,
      mrId: map['mr_id'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
      latitude: double.parse(map['latitude'].toString()),
      longitude: double.parse(map['longitude'].toString()),
      accuracy: double.parse(map['accuracy'].toString()),
      altitude: double.parse(map['altitude'].toString()),
      speed: double.parse(map['speed'].toString()),
      heading: double.parse(map['heading'].toString()),
      source: LocationSource.values.firstWhere(
        (source) => source.name == map['source'],
        orElse: () => LocationSource.gps,
      ),
      isHighAccuracy: map['is_high_accuracy'] as bool? ?? false,
      address: map['address'] as String?,
      landmark: map['landmark'] as String?,
      notes: map['notes'] as String?,
      isOffline: map['is_offline'] as bool? ?? false,
      syncedAt: map['synced_at'] != null 
        ? DateTime.parse(map['synced_at'] as String) 
        : null,
      deviceId: map['device_id'] as String?,
    );
  }

  /// Converts to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'mr_id': mrId,
      'timestamp': timestamp.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'altitude': altitude,
      'speed': speed,
      'heading': heading,
      'source': source.name,
      'is_high_accuracy': isHighAccuracy,
      'address': address,
      'landmark': landmark,
      'notes': notes,
      'is_offline': isOffline,
      'synced_at': syncedAt?.toIso8601String(),
      'device_id': deviceId,
    };
  }

  /// Converts to LatLng for map display
  LatLng toLatLng() {
    return LatLng(latitude, longitude);
  }

  /// Gets location quality based on accuracy
  LocationQuality getQuality() {
    if (accuracy <= 5.0) return LocationQuality.excellent;
    if (accuracy <= 10.0) return LocationQuality.good;
    if (accuracy <= 20.0) return LocationQuality.fair;
    return LocationQuality.poor;
  }

  /// Checks if location is within Janakpur area
  bool isWithinJanakpurArea() {
    // Janakpur approximate boundaries
    const double janakpurLat = 26.7146;
    const double janakpurLng = 85.9015;
    const double radius = 50.0; // 50km radius
    
    final distance = Geolocator.distanceBetween(
      latitude, longitude,
      janakpurLat, janakpurLng,
    );
    
    return distance <= radius * 1000; // Convert to meters
  }

  /// Determines if location is suitable for visit logging
  bool isSuitableForVisit() {
    return isHighAccuracy && 
           accuracy <= 15.0 && 
           !isOffline &&
           DateTime.now().difference(timestamp).inMinutes <= 5;
  }

  /// Gets formatted location string
  String getFormattedLocation() {
    return '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
  }

  /// Gets formatted accuracy string
  String getFormattedAccuracy() {
    return '${accuracy.toStringAsFixed(1)}m';
  }

  /// Gets formatted speed string
  String getFormattedSpeed() {
    if (speed == 0.0) return 'Stationary';
    return '${speed.toStringAsFixed(1)} km/h';
  }

  /// Converts geolocator position source to LocationSource enum
  static LocationSource _getLocationSource(Position position) {
    switch (position.isMocked) {
      case true:
        return LocationSource.mocked;
      case false:
        return LocationSource.gps;
    }
  }

  /// Creates copy with updated timestamp
  MRLocation copyWith({
    String? id,
    String? mrId,
    DateTime? timestamp,
    double? latitude,
    double? longitude,
    double? accuracy,
    double? altitude,
    double? speed,
    double? heading,
    LocationSource? source,
    bool? isHighAccuracy,
    String? address,
    String? landmark,
    String? notes,
    bool? isOffline,
    DateTime? syncedAt,
    String? deviceId,
  }) {
    return MRLocation(
      id: id ?? this.id,
      mrId: mrId ?? this.mrId,
      timestamp: timestamp ?? this.timestamp,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      accuracy: accuracy ?? this.accuracy,
      altitude: altitude ?? this.altitude,
      speed: speed ?? this.speed,
      heading: heading ?? this.heading,
      source: source ?? this.source,
      isHighAccuracy: isHighAccuracy ?? this.isHighAccuracy,
      address: address ?? this.address,
      landmark: landmark ?? this.landmark,
      notes: notes ?? this.notes,
      isOffline: isOffline ?? this.isOffline,
      syncedAt: syncedAt ?? this.syncedAt,
      deviceId: deviceId ?? this.deviceId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MRLocation && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'MRLocation(id: $id, mrId: $mrId, lat: $latitude, lng: $longitude, accuracy: $accuracy)';
  }
}

/// Location source enumeration
enum LocationSource {
  gps,
  network,
  passive,
  mocked,
}

/// Location quality enumeration
enum LocationQuality {
  excellent,
  good,
  fair,
  poor,
}

/// Location quality extension
extension LocationQualityExtension on LocationQuality {
  String get displayName {
    switch (this) {
      case LocationQuality.excellent:
        return 'Excellent';
      case LocationQuality.good:
        return 'Good';
      case LocationQuality.fair:
        return 'Fair';
      case LocationQuality.poor:
        return 'Poor';
    }
  }

  String get color {
    switch (this) {
      case LocationQuality.excellent:
        return '#4CAF50';
      case LocationQuality.good:
        return '#8BC34A';
      case LocationQuality.fair:
        return '#FF9800';
      case LocationQuality.poor:
        return '#F44336';
    }
  }
}
