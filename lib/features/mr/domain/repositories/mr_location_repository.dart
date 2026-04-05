import 'package:dartz/dartz.dart';
import '../entities/mr_location.dart';

/// Medical Representative Location Repository
/// Handles data operations for MR location tracking and geospatial data
abstract class MRLocationRepository {
  /// Save location to repository
  Future<Either<Failure, void>> saveLocation(MRLocation location);
  
  /// Get location by ID
  Future<Either<Failure, MRLocation?>> getLocationById(String id);
  
  /// Get locations by MR ID
  Future<Either<Failure, List<MRLocation>>> getLocationsByMrId({
    required String mrId,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  });
  
  /// Get locations within date range
  Future<Either<Failure, List<MRLocation>>> getLocationsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
    String? mrId,
  });
  
  /// Get locations within geographic bounds
  Future<Either<Failure, List<MRLocation>>> getLocationsByBounds({
    required double northEastLat,
    required double northEastLng,
    required double southWestLat,
    required double southWestLng,
  });
  
  /// Get high accuracy locations
  Future<Either<Failure, List<MRLocation>>> getHighAccuracyLocations({
    String? mrId,
    DateTime? startDate,
    DateTime? endDate,
  });
  
  /// Get locations for trajectory calculation
  Future<Either<Failure, List<MRLocation>>> getTrajectoryLocations({
    required String mrId,
    required DateTime date,
  });
  
  /// Get latest location for MR
  Future<Either<Failure, MRLocation?>> getLatestLocation(String mrId);
  
  /// Update location
  Future<Either<Failure, void>> updateLocation(MRLocation location);
  
  /// Delete location
  Future<Either<Failure, void>> deleteLocation(String id);
  
  /// Get location statistics
  Future<Either<Failure, Map<String, dynamic>>> getLocationStatistics({
    required String mrId,
    DateTime? startDate,
    DateTime? endDate,
  });
  
  /// Get locations for dashboard
  Future<Either<Failure, List<MRLocation>>> getDashboardLocations({
    String? mrId,
    int? limit = 10,
  });
  
  /// Sync offline locations
  Future<Either<Failure, void>> syncOfflineLocations(List<MRLocation> locations);
  
  /// Get locations needing attention
  Future<Either<Failure, List<MRLocation>>> getLocationsNeedingAttention();
  
  /// Bulk save locations
  Future<Either<Failure, void>> bulkSaveLocations(List<MRLocation> locations);
  
  /// Get location analytics
  Future<Either<Failure, Map<String, dynamic>>> getLocationAnalytics({
    required String mrId,
    required DateTime startDate,
    required DateTime endDate,
  });
}

/// Failure class for location operations
class Failure {
  final String message;
  final String? code;
  final dynamic details;
  
  const Failure({
    required this.message,
    this.code,
    this.details,
  });
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Failure && other.message == message;
  }
  
  @override
  int get hashCode => message.hashCode;
  
  @override
  String toString() => 'Failure: $message';
}
