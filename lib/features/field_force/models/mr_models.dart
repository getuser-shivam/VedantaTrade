import 'package:vedanta_trade/features/mr/domain/entities/mr_entities.dart';

/// MR Visit Model - Data transfer object for API and database
class MrVisitModel {
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
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MrVisitModel({
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

  /// Create from JSON
  factory MrVisitModel.fromJson(Map<String, dynamic> json) {
    return MrVisitModel(
      id: json['id'] as String,
      mrId: json['mrId'] as String,
      doctorId: json['doctorId'] as String,
      doctorName: json['doctorName'] as String,
      clinicName: json['clinicName'] as String,
      specialty: json['specialty'] as String,
      address: json['address'] as String,
      visitDate: DateTime.parse(json['visitDate'] as String),
      notes: json['notes'] as String?,
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
      accuracy: json['accuracy'] as double?,
      sampleProducts: (json['sampleProducts'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      promotionalMaterials: (json['promotionalMaterials'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      status: json['status'] as String? ?? 'planned',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mrId': mrId,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'clinicName': clinicName,
      'specialty': specialty,
      'address': address,
      'visitDate': visitDate.toIso8601String(),
      'notes': notes,
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'sampleProducts': sampleProducts,
      'promotionalMaterials': promotionalMaterials,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Convert to entity
  MrVisitEntity toEntity() {
    return MrVisitEntity(
      id: id,
      mrId: mrId,
      doctorId: doctorId,
      doctorName: doctorName,
      clinicName: clinicName,
      specialty: specialty,
      address: address,
      visitDate: visitDate,
      notes: notes,
      latitude: latitude,
      longitude: longitude,
      accuracy: accuracy,
      sampleProducts: sampleProducts,
      promotionalMaterials: promotionalMaterials,
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Create from entity
  factory MrVisitModel.fromEntity(MrVisitEntity entity) {
    return MrVisitModel(
      id: entity.id,
      mrId: entity.mrId,
      doctorId: entity.doctorId,
      doctorName: entity.doctorName,
      clinicName: entity.clinicName,
      specialty: entity.specialty,
      address: entity.address,
      visitDate: entity.visitDate,
      notes: entity.notes,
      latitude: entity.latitude,
      longitude: entity.longitude,
      accuracy: entity.accuracy,
      sampleProducts: entity.sampleProducts,
      promotionalMaterials: entity.promotionalMaterials,
      status: entity.status,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}

/// Doctor Model - Data transfer object for API and database
class DoctorModel {
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
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DoctorModel({
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

  /// Create from JSON
  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    return DoctorModel(
      id: json['id'] as String,
      name: json['name'] as String,
      clinicName: json['clinicName'] as String,
      specialty: json['specialty'] as String,
      address: json['address'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      phone: json['phone'] as String,
      email: json['email'] as String,
      targetVisitsPerMonth: json['targetVisitsPerMonth'] as int,
      completedVisits: json['completedVisits'] as int,
      status: json['status'] as String? ?? 'active',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'clinicName': clinicName,
      'specialty': specialty,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'phone': phone,
      'email': email,
      'targetVisitsPerMonth': targetVisitsPerMonth,
      'completedVisits': completedVisits,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Convert to entity
  DoctorEntity toEntity() {
    return DoctorEntity(
      id: id,
      name: name,
      clinicName: clinicName,
      specialty: specialty,
      address: address,
      latitude: latitude,
      longitude: longitude,
      phone: phone,
      email: email,
      targetVisitsPerMonth: targetVisitsPerMonth,
      completedVisits: completedVisits,
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Create from entity
  factory DoctorModel.fromEntity(DoctorEntity entity) {
    return DoctorModel(
      id: entity.id,
      name: entity.name,
      clinicName: entity.clinicName,
      specialty: entity.specialty,
      address: entity.address,
      latitude: entity.latitude,
      longitude: entity.longitude,
      phone: entity.phone,
      email: entity.email,
      targetVisitsPerMonth: entity.targetVisitsPerMonth,
      completedVisits: entity.completedVisits,
      status: entity.status,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}

/// GPS Tracking Model - Data transfer object for API and database
class GpsTrackingModel {
  final String id;
  final String mrId;
  final double latitude;
  final double longitude;
  final double accuracy;
  final DateTime timestamp;
  final bool isTracking;
  final List<LocationPointModel> trajectory;

  const GpsTrackingModel({
    required this.id,
    required this.mrId,
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.timestamp,
    this.isTracking = false,
    this.trajectory = const [],
  });

  /// Create from JSON
  factory GpsTrackingModel.fromJson(Map<String, dynamic> json) {
    return GpsTrackingModel(
      id: json['id'] as String,
      mrId: json['mrId'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      accuracy: (json['accuracy'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      isTracking: json['isTracking'] as bool? ?? false,
      trajectory: (json['trajectory'] as List<dynamic>?)
              ?.map((e) => LocationPointModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mrId': mrId,
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'timestamp': timestamp.toIso8601String(),
      'isTracking': isTracking,
      'trajectory': trajectory.map((point) => point.toJson()).toList(),
    };
  }

  /// Convert to entity
  GpsTrackingEntity toEntity() {
    return GpsTrackingEntity(
      id: id,
      mrId: mrId,
      latitude: latitude,
      longitude: longitude,
      accuracy: accuracy,
      timestamp: timestamp,
      isTracking: isTracking,
      trajectory: trajectory.map((point) => point.toEntity()).toList(),
    );
  }

  /// Create from entity
  factory GpsTrackingModel.fromEntity(GpsTrackingEntity entity) {
    return GpsTrackingModel(
      id: entity.id,
      mrId: entity.mrId,
      latitude: entity.latitude,
      longitude: entity.longitude,
      accuracy: entity.accuracy,
      timestamp: entity.timestamp,
      isTracking: entity.isTracking,
      trajectory: entity.trajectory
          .map((point) => LocationPointModel.fromEntity(point))
          .toList(),
    );
  }
}

/// Location Point Model - Data transfer object for API and database
class LocationPointModel {
  final double latitude;
  final double longitude;
  final double accuracy;
  final DateTime timestamp;

  const LocationPointModel({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.timestamp,
  });

  /// Create from JSON
  factory LocationPointModel.fromJson(Map<String, dynamic> json) {
    return LocationPointModel(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      accuracy: (json['accuracy'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Convert to entity
  LocationPointEntity toEntity() {
    return LocationPointEntity(
      latitude: latitude,
      longitude: longitude,
      accuracy: accuracy,
      timestamp: timestamp,
    );
  }

  /// Create from entity
  factory LocationPointModel.fromEntity(LocationPointEntity entity) {
    return LocationPointModel(
      latitude: entity.latitude,
      longitude: entity.longitude,
      accuracy: entity.accuracy,
      timestamp: entity.timestamp,
    );
  }
}

/// MR Target Model - Data transfer object for API and database
class MrTargetModel {
  final String id;
  final String mrId;
  final String period;
  final int targetDoctors;
  final int targetVisits;
  final int completedDoctors;
  final int completedVisits;
  final double targetSales;
  final double actualSales;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MrTargetModel({
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

  /// Create from JSON
  factory MrTargetModel.fromJson(Map<String, dynamic> json) {
    return MrTargetModel(
      id: json['id'] as String,
      mrId: json['mrId'] as String,
      period: json['period'] as String,
      targetDoctors: json['targetDoctors'] as int,
      targetVisits: json['targetVisits'] as int,
      completedDoctors: json['completedDoctors'] as int,
      completedVisits: json['completedVisits'] as int,
      targetSales: (json['targetSales'] as num).toDouble(),
      actualSales: (json['actualSales'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mrId': mrId,
      'period': period,
      'targetDoctors': targetDoctors,
      'targetVisits': targetVisits,
      'completedDoctors': completedDoctors,
      'completedVisits': completedVisits,
      'targetSales': targetSales,
      'actualSales': actualSales,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Convert to entity
  MrTargetEntity toEntity() {
    return MrTargetEntity(
      id: id,
      mrId: mrId,
      period: period,
      targetDoctors: targetDoctors,
      targetVisits: targetVisits,
      completedDoctors: completedDoctors,
      completedVisits: completedVisits,
      targetSales: targetSales,
      actualSales: actualSales,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Create from entity
  factory MrTargetModel.fromEntity(MrTargetEntity entity) {
    return MrTargetModel(
      id: entity.id,
      mrId: entity.mrId,
      period: entity.period,
      targetDoctors: entity.targetDoctors,
      targetVisits: entity.targetVisits,
      completedDoctors: entity.completedDoctors,
      completedVisits: entity.completedVisits,
      targetSales: entity.targetSales,
      actualSales: entity.actualSales,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
