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

  // Computed properties
  bool get isPlanned => status == 'planned';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';
  bool get isOverdue => DateTime.now().isAfter(visitDate) && !isCompleted;
  bool get hasLocation => latitude != null && longitude != null;
  int get daysUntilVisit => visitDate.difference(DateTime.now()).inDays;

  String get statusDisplay {
    switch (status) {
      case 'planned':
        return 'Planned';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mr_id': mrId,
      'doctor_id': doctorId,
      'doctor_name': doctorName,
      'clinic_name': clinicName,
      'specialty': specialty,
      'address': address,
      'visit_date': visitDate.toIso8601String(),
      'notes': notes,
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'sample_products': sampleProducts,
      'promotional_materials': promotionalMaterials,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory MrVisitEntity.fromJson(Map<String, dynamic> json) {
    return MrVisitEntity(
      id: json['id'] ?? '',
      mrId: json['mr_id'] ?? json['mrId'] ?? '',
      doctorId: json['doctor_id'] ?? json['doctorId'] ?? '',
      doctorName: json['doctor_name'] ?? json['doctorName'] ?? '',
      clinicName: json['clinic_name'] ?? json['clinicName'] ?? '',
      specialty: json['specialty'] ?? '',
      address: json['address'] ?? '',
      visitDate: DateTime.parse(json['visit_date'] ?? json['visitDate']),
      notes: json['notes'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      accuracy: json['accuracy']?.toDouble(),
      sampleProducts: List<String>.from(json['sample_products'] ?? json['sampleProducts'] ?? []),
      promotionalMaterials: List<String>.from(json['promotional_materials'] ?? json['promotionalMaterials'] ?? []),
      status: json['status'] ?? 'planned',
      createdAt: DateTime.parse(json['created_at'] ?? json['createdAt']),
      updatedAt: DateTime.parse(json['updated_at'] ?? json['updatedAt']),
    );
  }
}
