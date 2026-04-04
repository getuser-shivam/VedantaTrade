import 'package:dartz/dartz.dart';
import 'package:vedanta_trade/core/errors/failures.dart';
import 'package:vedanta_trade/features/mr/domain/entities/mr_entities.dart';
import 'package:vedanta_trade/features/mr/domain/repositories/mr_repository.dart';

/// Use case for getting all visits for a specific MR
class GetVisitsByMrIdUseCase {
  final MrVisitRepository _repository;

  GetVisitsByMrIdUseCase(this._repository);

  Future<Either<Failure, List<MrVisitEntity>>> call(String mrId) async {
    if (mrId.isEmpty) {
      return Left(ValidationFailure('MR ID cannot be empty'));
    }
    return await _repository.getVisitsByMrId(mrId);
  }
}

/// Use case for getting visit by ID
class GetVisitByIdUseCase {
  final MrVisitRepository _repository;

  GetVisitByIdUseCase(this._repository);

  Future<Either<Failure, MrVisitEntity>> call(String visitId) async {
    if (visitId.isEmpty) {
      return Left(ValidationFailure('Visit ID cannot be empty'));
    }
    return await _repository.getVisitById(visitId);
  }
}

/// Use case for creating a new visit
class CreateVisitUseCase {
  final MrVisitRepository _repository;

  CreateVisitUseCase(this._repository);

  Future<Either<Failure, MrVisitEntity>> call(MrVisitEntity visit) async {
    // Validate visit data
    final validationFailure = _validateVisit(visit);
    if (validationFailure != null) {
      return Left(validationFailure);
    }

    return await _repository.createVisit(visit);
  }

  ValidationFailure? _validateVisit(MrVisitEntity visit) {
    if (visit.mrId.isEmpty) {
      return const ValidationFailure('MR ID is required');
    }
    if (visit.doctorId.isEmpty) {
      return const ValidationFailure('Doctor ID is required');
    }
    if (visit.doctorName.isEmpty) {
      return const ValidationFailure('Doctor name is required');
    }
    if (visit.clinicName.isEmpty) {
      return const ValidationFailure('Clinic name is required');
    }
    if (visit.address.isEmpty) {
      return const ValidationFailure('Address is required');
    }
    return null;
  }
}

/// Use case for updating an existing visit
class UpdateVisitUseCase {
  final MrVisitRepository _repository;

  UpdateVisitUseCase(this._repository);

  Future<Either<Failure, MrVisitEntity>> call(MrVisitEntity visit) async {
    if (visit.id.isEmpty) {
      return Left(ValidationFailure('Visit ID cannot be empty'));
    }

    // Validate visit data
    final validationFailure = _validateVisit(visit);
    if (validationFailure != null) {
      return Left(validationFailure);
    }

    return await _repository.updateVisit(visit);
  }

  ValidationFailure? _validateVisit(MrVisitEntity visit) {
    if (visit.mrId.isEmpty) {
      return const ValidationFailure('MR ID is required');
    }
    if (visit.doctorId.isEmpty) {
      return const ValidationFailure('Doctor ID is required');
    }
    if (visit.doctorName.isEmpty) {
      return const ValidationFailure('Doctor name is required');
    }
    if (visit.clinicName.isEmpty) {
      return const ValidationFailure('Clinic name is required');
    }
    if (visit.address.isEmpty) {
      return const ValidationFailure('Address is required');
    }
    return null;
  }
}

/// Use case for deleting a visit
class DeleteVisitUseCase {
  final MrVisitRepository _repository;

  DeleteVisitUseCase(this._repository);

  Future<Either<Failure, void>> call(String visitId) async {
    if (visitId.isEmpty) {
      return Left(ValidationFailure('Visit ID cannot be empty'));
    }
    return await _repository.deleteVisit(visitId);
  }
}

/// Use case for getting visits by date range
class GetVisitsByDateRangeUseCase {
  final MrVisitRepository _repository;

  GetVisitsByDateRangeUseCase(this._repository);

  Future<Either<Failure, List<MrVisitEntity>>> call(
    String mrId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    if (mrId.isEmpty) {
      return Left(ValidationFailure('MR ID cannot be empty'));
    }
    if (startDate.isAfter(endDate)) {
      return Left(ValidationFailure('Start date must be before end date'));
    }
    return await _repository.getVisitsByDateRange(mrId, startDate, endDate);
  }
}

/// Use case for getting today's visits
class GetTodayVisitsUseCase {
  final MrVisitRepository _repository;

  GetTodayVisitsUseCase(this._repository);

  Future<Either<Failure, List<MrVisitEntity>>> call(String mrId) async {
    if (mrId.isEmpty) {
      return Left(ValidationFailure('MR ID cannot be empty'));
    }
    return await _repository.getTodayVisits(mrId);
  }
}

/// Use case for getting pending visits
class GetPendingVisitsUseCase {
  final MrVisitRepository _repository;

  GetPendingVisitsUseCase(this._repository);

  Future<Either<Failure, List<MrVisitEntity>>> call(String mrId) async {
    if (mrId.isEmpty) {
      return Left(ValidationFailure('MR ID cannot be empty'));
    }
    return await _repository.getPendingVisits(mrId);
  }
}

/// Use case for getting completed visits
class GetCompletedVisitsUseCase {
  final MrVisitRepository _repository;

  GetCompletedVisitsUseCase(this._repository);

  Future<Either<Failure, List<MrVisitEntity>>> call(String mrId) async {
    if (mrId.isEmpty) {
      return Left(ValidationFailure('MR ID cannot be empty'));
    }
    return await _repository.getCompletedVisits(mrId);
  }
}

/// Use case for submitting visit with GPS validation
class SubmitVisitWithLocationUseCase {
  final MrVisitRepository _repository;

  SubmitVisitWithLocationUseCase(this._repository);

  Future<Either<Failure, MrVisitEntity>> call(
    String visitId,
    double latitude,
    double longitude,
    double accuracy,
  ) async {
    if (visitId.isEmpty) {
      return Left(ValidationFailure('Visit ID cannot be empty'));
    }

    // Validate GPS coordinates
    if (accuracy > 50.0) {
      return Left(ValidationFailure('GPS accuracy must be within 50 meters'));
    }

    return await _repository.submitVisitWithLocation(
      visitId,
      latitude,
      longitude,
      accuracy,
    );
  }
}

/// Use case for getting all doctors
class GetAllDoctorsUseCase {
  final DoctorRepository _repository;

  GetAllDoctorsUseCase(this._repository);

  Future<Either<Failure, List<DoctorEntity>>> call() async {
    return await _repository.getAllDoctors();
  }
}

/// Use case for getting doctors by MR ID
class GetDoctorsByMrIdUseCase {
  final DoctorRepository _repository;

  GetDoctorsByMrIdUseCase(this._repository);

  Future<Either<Failure, List<DoctorEntity>>> call(String mrId) async {
    if (mrId.isEmpty) {
      return Left(ValidationFailure('MR ID cannot be empty'));
    }
    return await _repository.getDoctorsByMrId(mrId);
  }
}

/// Use case for searching doctors
class SearchDoctorsUseCase {
  final DoctorRepository _repository;

  SearchDoctorsUseCase(this._repository);

  Future<Either<Failure, List<DoctorEntity>>> call(String query) async {
    if (query.isEmpty) {
      return Left(ValidationFailure('Search query cannot be empty'));
    }
    return await _repository.searchDoctors(query);
  }
}

/// Use case for starting GPS tracking
class StartGpsTrackingUseCase {
  final GpsTrackingRepository _repository;

  StartGpsTrackingUseCase(this._repository);

  Future<Either<Failure, void>> call(String mrId) async {
    if (mrId.isEmpty) {
      return Left(ValidationFailure('MR ID cannot be empty'));
    }
    return await _repository.startTracking(mrId);
  }
}

/// Use case for stopping GPS tracking
class StopGpsTrackingUseCase {
  final GpsTrackingRepository _repository;

  StopGpsTrackingUseCase(this._repository);

  Future<Either<Failure, void>> call(String mrId) async {
    if (mrId.isEmpty) {
      return Left(ValidationFailure('MR ID cannot be empty'));
    }
    return await _repository.stopTracking(mrId);
  }
}

/// Use case for getting current tracking status
class GetTrackingStatusUseCase {
  final GpsTrackingRepository _repository;

  GetTrackingStatusUseCase(this._repository);

  Future<Either<Failure, GpsTrackingEntity>> call(String mrId) async {
    if (mrId.isEmpty) {
      return Left(ValidationFailure('MR ID cannot be empty'));
    }
    return await _repository.getTrackingStatus(mrId);
  }
}

/// Use case for getting GPS trajectory
class GetGpsTrajectoryUseCase {
  final GpsTrackingRepository _repository;

  GetGpsTrajectoryUseCase(this._repository);

  Future<Either<Failure, List<LocationPointEntity>>> call(String mrId) async {
    if (mrId.isEmpty) {
      return Left(ValidationFailure('MR ID cannot be empty'));
    }
    return await _repository.getTrajectory(mrId);
  }
}

/// Use case for adding location point to trajectory
class AddLocationPointUseCase {
  final GpsTrackingRepository _repository;

  AddLocationPointUseCase(this._repository);

  Future<Either<Failure, void>> call(
    String mrId,
    LocationPointEntity point,
  ) async {
    if (mrId.isEmpty) {
      return Left(ValidationFailure('MR ID cannot be empty'));
    }

    // Validate location point
    if (!point.isAccurate) {
      return Left(ValidationFailure('GPS accuracy must be within 50 meters'));
    }

    return await _repository.addLocationPoint(mrId, point);
  }
}

/// Use case for getting current location
class GetCurrentLocationUseCase {
  final GpsTrackingRepository _repository;

  GetCurrentLocationUseCase(this._repository);

  Future<Either<Failure, LocationPointEntity>> call() async {
    return await _repository.getCurrentLocation();
  }
}

/// Use case for getting current MR target
class GetCurrentTargetUseCase {
  final MrTargetRepository _repository;

  GetCurrentTargetUseCase(this._repository);

  Future<Either<Failure, MrTargetEntity>> call(String mrId) async {
    if (mrId.isEmpty) {
      return Left(ValidationFailure('MR ID cannot be empty'));
    }
    return await _repository.getCurrentTarget(mrId);
  }
}

/// Use case for updating target progress
class UpdateTargetProgressUseCase {
  final MrTargetRepository _repository;

  UpdateTargetProgressUseCase(this._repository);

  Future<Either<Failure, MrTargetEntity>> call(
    String targetId,
    int completedDoctors,
    int completedVisits,
    double actualSales,
  ) async {
    if (targetId.isEmpty) {
      return Left(ValidationFailure('Target ID cannot be empty'));
    }

    if (completedDoctors < 0 || completedVisits < 0 || actualSales < 0) {
      return Left(ValidationFailure('Progress values cannot be negative'));
    }

    return await _repository.updateTargetProgress(
      targetId,
      completedDoctors,
      completedVisits,
      actualSales,
    );
  }
}

/// Use case for getting target achievement summary
class GetTargetSummaryUseCase {
  final MrTargetRepository _repository;

  GetTargetSummaryUseCase(this._repository);

  Future<Either<Failure, Map<String, dynamic>>> call(String mrId) async {
    if (mrId.isEmpty) {
      return Left(ValidationFailure('MR ID cannot be empty'));
    }
    return await _repository.getTargetSummary(mrId);
  }
}

/// Use case for syncing offline trajectory
class SyncOfflineTrajectoryUseCase {
  final GpsTrackingRepository _repository;

  SyncOfflineTrajectoryUseCase(this._repository);

  Future<Either<Failure, void>> call(String mrId) async {
    if (mrId.isEmpty) {
      return Left(ValidationFailure('MR ID cannot be empty'));
    }
    return await _repository.syncOfflineTrajectory(mrId);
  }
}
