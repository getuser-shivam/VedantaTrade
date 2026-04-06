import 'package:equatable/equatable.dart';

/// MR Visit Entity - Core business object for medical representative visits
class MrVisitEntity extends Equatable {
  final String id;
  final String mrId;
  final String doctorId;
  final String doctorName;
  final String clinicName;
  final String specialty;
  final String address;
  final DateTime visitDate;
  final String? notes;
  final double? latitude;
  final double? longitude;
  final double? accuracy;
  final List<String> sampleProducts;
  final List<String> promotionalMaterials;
  final String status; // planned, completed, cancelled
  final DateTime createdAt;
  final DateTime updatedAt;

  const MrVisitEntity({
    required this.id,
    required this.mrId,
    required this.doctorId,
    required this.doctorName,
    required this.clinicName,
    required this.specialty,
    required this.address,
    required this.visitDate,
    this.notes,
    this.latitude,
    this.longitude,
    this.accuracy,
    this.sampleProducts = const [],
    this.promotionalMaterials = const [],
    this.status = 'planned',
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        mrId,
        doctorId,
        doctorName,
        clinicName,
        specialty,
        address,
        visitDate,
        notes,
        latitude,
        longitude,
        accuracy,
        sampleProducts,
        promotionalMaterials,
        status,
        createdAt,
        updatedAt,
      ];

  MrVisitEntity copyWith({
    String? id,
    String? mrId,
    String? doctorId,
    String? doctorName,
    String? clinicName,
    String? specialty,
    String? address,
    DateTime? visitDate,
    String? notes,
    double? latitude,
    double? longitude,
    double? accuracy,
    List<String>? sampleProducts,
    List<String>? promotionalMaterials,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MrVisitEntity(
      id: id ?? this.id,
      mrId: mrId ?? this.mrId,
      doctorId: doctorId ?? this.doctorId,
      doctorName: doctorName ?? this.doctorName,
      clinicName: clinicName ?? this.clinicName,
      specialty: specialty ?? this.specialty,
      address: address ?? this.address,
      visitDate: visitDate ?? this.visitDate,
      notes: notes ?? this.notes,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      accuracy: accuracy ?? this.accuracy,
      sampleProducts: sampleProducts ?? this.sampleProducts,
      promotionalMaterials: promotionalMaterials ?? this.promotionalMaterials,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Check if visit has valid GPS coordinates
  bool get hasValidLocation {
    return latitude != null && 
           longitude != null && 
           accuracy != null && 
           accuracy! <= 50.0;
  }

  /// Check if visit is completed
  bool get isCompleted => status == 'completed';

  /// Check if visit is cancelled
  bool get isCancelled => status == 'cancelled';

  /// Check if visit is planned
  bool get isPlanned => status == 'planned';
}

/// Doctor Entity - Core business object for doctors
class DoctorEntity extends Equatable {
  final String id;
  final String name;
  final String clinicName;
  final String specialty;
  final String address;
  final double latitude;
  final double longitude;
  final String phone;
  final String email;
  final int targetVisitsPerMonth;
  final int completedVisits;
  final String status; // active, inactive
  final DateTime createdAt;
  final DateTime updatedAt;

  const DoctorEntity({
    required this.id,
    required this.name,
    required this.clinicName,
    required this.specialty,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.phone,
    required this.email,
    required this.targetVisitsPerMonth,
    required this.completedVisits,
    this.status = 'active',
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        clinicName,
        specialty,
        address,
        latitude,
        longitude,
        phone,
        email,
        targetVisitsPerMonth,
        completedVisits,
        status,
        createdAt,
        updatedAt,
      ];

  DoctorEntity copyWith({
    String? id,
    String? name,
    String? clinicName,
    String? specialty,
    String? address,
    double? latitude,
    double? longitude,
    String? phone,
    String? email,
    int? targetVisitsPerMonth,
    int? completedVisits,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DoctorEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      clinicName: clinicName ?? this.clinicName,
      specialty: specialty ?? this.specialty,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      targetVisitsPerMonth: targetVisitsPerMonth ?? this.targetVisitsPerMonth,
      completedVisits: completedVisits ?? this.completedVisits,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Calculate visit completion rate
  double get completionRate {
    if (targetVisitsPerMonth == 0) return 0.0;
    return completedVisits / targetVisitsPerMonth;
  }

  /// Check if target is met
  bool get isTargetMet => completedVisits >= targetVisitsPerMonth;

  /// Check if doctor is active
  bool get isActive => status == 'active';
}

/// GPS Tracking Entity - Core business object for GPS tracking
class GpsTrackingEntity extends Equatable {
  final String id;
  final String mrId;
  final double latitude;
  final double longitude;
  final double accuracy;
  final DateTime timestamp;
  final bool isTracking;
  final List<LocationPointEntity> trajectory;

  const GpsTrackingEntity({
    required this.id,
    required this.mrId,
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.timestamp,
    this.isTracking = false,
    this.trajectory = const [],
  });

  @override
  List<Object?> get props => [
        id,
        mrId,
        latitude,
        longitude,
        accuracy,
        timestamp,
        isTracking,
        trajectory,
      ];

  GpsTrackingEntity copyWith({
    String? id,
    String? mrId,
    double? latitude,
    double? longitude,
    double? accuracy,
    DateTime? timestamp,
    bool? isTracking,
    List<LocationPointEntity>? trajectory,
  }) {
    return GpsTrackingEntity(
      id: id ?? this.id,
      mrId: mrId ?? this.mrId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      accuracy: accuracy ?? this.accuracy,
      timestamp: timestamp ?? this.timestamp,
      isTracking: isTracking ?? this.isTracking,
      trajectory: trajectory ?? this.trajectory,
    );
  }

  /// Check if location is accurate enough
  bool get isAccurate => accuracy <= 50.0;

  /// Get latest location point
  LocationPointEntity? get latestPoint {
    if (trajectory.isEmpty) return null;
    return trajectory.last;
  }
}

/// Location Point Entity - Single GPS point in trajectory
class LocationPointEntity extends Equatable {
  final double latitude;
  final double longitude;
  final double accuracy;
  final DateTime timestamp;

  const LocationPointEntity({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [latitude, longitude, accuracy, timestamp];

  /// Check if point is accurate
  bool get isAccurate => accuracy <= 50.0;
}

/// MR Target Entity - Core business object for MR targets
class MrTargetEntity extends Equatable {
  final String id;
  final String mrId;
  final String period; // e.g., "2026-03"
  final int targetDoctors;
  final int targetVisits;
  final int completedDoctors;
  final int completedVisits;
  final double targetSales;
  final double actualSales;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MrTargetEntity({
    required this.id,
    required this.mrId,
    required this.period,
    required this.targetDoctors,
    required this.targetVisits,
    required this.completedDoctors,
    required this.completedVisits,
    required this.targetSales,
    required this.actualSales,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        mrId,
        period,
        targetDoctors,
        targetVisits,
        completedDoctors,
        completedVisits,
        targetSales,
        actualSales,
        createdAt,
        updatedAt,
      ];

  MrTargetEntity copyWith({
    String? id,
    String? mrId,
    String? period,
    int? targetDoctors,
    int? targetVisits,
    int? completedDoctors,
    int? completedVisits,
    double? targetSales,
    double? actualSales,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MrTargetEntity(
      id: id ?? this.id,
      mrId: mrId ?? this.mrId,
      period: period ?? this.period,
      targetDoctors: targetDoctors ?? this.targetDoctors,
      targetVisits: targetVisits ?? this.targetVisits,
      completedDoctors: completedDoctors ?? this.completedDoctors,
      completedVisits: completedVisits ?? this.completedVisits,
      targetSales: targetSales ?? this.targetSales,
      actualSales: actualSales ?? this.actualSales,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Calculate doctor completion rate
  double get doctorCompletionRate {
    if (targetDoctors == 0) return 0.0;
    return completedDoctors / targetDoctors;
  }

  /// Calculate visit completion rate
  double get visitCompletionRate {
    if (targetVisits == 0) return 0.0;
    return completedVisits / targetVisits;
  }

  /// Calculate sales completion rate
  double get salesCompletionRate {
    if (targetSales == 0) return 0.0;
    return actualSales / targetSales;
  }

  /// Check if all targets are met
  bool get areAllTargetsMet {
    return completedDoctors >= targetDoctors &&
           completedVisits >= targetVisits &&
           actualSales >= targetSales;
  }
}
