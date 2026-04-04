import 'package:dartz/dartz.dart';
import 'package:vedanta_trade/core/errors/failures.dart';
import 'package:vedanta_trade/features/mr/domain/entities/mr_entities.dart';

/// Abstract repository for MR visit operations
abstract class MrVisitRepository {
  /// Get all visits for a specific MR
  Future<Either<Failure, List<MrVisitEntity>>> getVisitsByMrId(String mrId);

  /// Get visit by ID
  Future<Either<Failure, MrVisitEntity>> getVisitById(String visitId);

  /// Create a new visit
  Future<Either<Failure, MrVisitEntity>> createVisit(MrVisitEntity visit);

  /// Update an existing visit
  Future<Either<Failure, MrVisitEntity>> updateVisit(MrVisitEntity visit);

  /// Delete a visit
  Future<Either<Failure, void>> deleteVisit(String visitId);

  /// Get visits by date range
  Future<Either<Failure, List<MrVisitEntity>>> getVisitsByDateRange(
    String mrId,
    DateTime startDate,
    DateTime endDate,
  );

  /// Get visits for today
  Future<Either<Failure, List<MrVisitEntity>>> getTodayVisits(String mrId);

  /// Get pending visits
  Future<Either<Failure, List<MrVisitEntity>>> getPendingVisits(String mrId);

  /// Get completed visits
  Future<Either<Failure, List<MrVisitEntity>>> getCompletedVisits(String mrId);

  /// Submit visit with GPS validation
  Future<Either<Failure, MrVisitEntity>> submitVisitWithLocation(
    String visitId,
    double latitude,
    double longitude,
    double accuracy,
  );
}

/// Abstract repository for doctor operations
abstract class DoctorRepository {
  /// Get all doctors
  Future<Either<Failure, List<DoctorEntity>>> getAllDoctors();

  /// Get doctor by ID
  Future<Either<Failure, DoctorEntity>> getDoctorById(String doctorId);

  /// Get doctors by MR ID
  Future<Either<Failure, List<DoctorEntity>>> getDoctorsByMrId(String mrId);

  /// Get doctors by specialty
  Future<Either<Failure, List<DoctorEntity>>> getDoctorsBySpecialty(String specialty);

  /// Search doctors by name or clinic
  Future<Either<Failure, List<DoctorEntity>>> searchDoctors(String query);

  /// Create a new doctor
  Future<Either<Failure, DoctorEntity>> createDoctor(DoctorEntity doctor);

  /// Update an existing doctor
  Future<Either<Failure, DoctorEntity>> updateDoctor(DoctorEntity doctor);

  /// Delete a doctor
  Future<Either<Failure, void>> deleteDoctor(String doctorId);

  /// Get nearby doctors based on location
  Future<Either<Failure, List<DoctorEntity>>> getNearbyDoctors(
    double latitude,
    double longitude,
    double radiusKm,
  );

  /// Update doctor visit statistics
  Future<Either<Failure, DoctorEntity>> updateVisitStats(
    String doctorId,
    int completedVisits,
  );
}

/// Abstract repository for GPS tracking operations
abstract class GpsTrackingRepository {
  /// Start GPS tracking for MR
  Future<Either<Failure, void>> startTracking(String mrId);

  /// Stop GPS tracking for MR
  Future<Either<Failure, void>> stopTracking(String mrId);

  /// Get current tracking status
  Future<Either<Failure, GpsTrackingEntity>> getTrackingStatus(String mrId);

  /// Get tracking trajectory for MR
  Future<Either<Failure, List<LocationPointEntity>>> getTrajectory(String mrId);

  /// Add location point to trajectory
  Future<Either<Failure, void>> addLocationPoint(
    String mrId,
    LocationPointEntity point,
  );

  /// Clear trajectory for MR
  Future<Either<Failure, void>> clearTrajectory(String mrId);

  /// Get current location
  Future<Either<Failure, LocationPointEntity>> getCurrentLocation();

  /// Validate GPS accuracy
  Future<Either<Failure, bool>> validateAccuracy(double accuracy);

  /// Get tracking history for date range
  Future<Either<Failure, List<GpsTrackingEntity>>> getTrackingHistory(
    String mrId,
    DateTime startDate,
    DateTime endDate,
  );

  /// Save offline trajectory points
  Future<Either<Failure, void>> saveOfflineTrajectory(
    String mrId,
    List<LocationPointEntity> points,
  );

  /// Sync offline trajectory when online
  Future<Either<Failure, void>> syncOfflineTrajectory(String mrId);

  /// Get offline trajectory points
  Future<Either<Failure, List<LocationPointEntity>>> getOfflineTrajectory(String mrId);
}

/// Abstract repository for MR target operations
abstract class MrTargetRepository {
  /// Get targets for MR by period
  Future<Either<Failure, MrTargetEntity>> getTargetByPeriod(String mrId, String period);

  /// Get all targets for MR
  Future<Either<Failure, List<MrTargetEntity>>> getAllTargets(String mrId);

  /// Create new target
  Future<Either<Failure, MrTargetEntity>> createTarget(MrTargetEntity target);

  /// Update existing target
  Future<Either<Failure, MrTargetEntity>> updateTarget(MrTargetEntity target);

  /// Delete target
  Future<Either<Failure, void>> deleteTarget(String targetId);

  /// Get current period target
  Future<Either<Failure, MrTargetEntity>> getCurrentTarget(String mrId);

  /// Update target progress
  Future<Either<Failure, MrTargetEntity>> updateTargetProgress(
    String targetId,
    int completedDoctors,
    int completedVisits,
    double actualSales,
  );

  /// Get target achievement summary
  Future<Either<Failure, Map<String, dynamic>>> getTargetSummary(String mrId);

  /// Calculate target completion rates
  Future<Either<Failure, Map<String, double>>> getCompletionRates(String mrId);
}
