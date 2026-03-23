import 'package:flutter/material.dart';

enum NetworkEntityType { doctor, stockist, retailer, hospital }

extension NetworkEntityTypeX on NetworkEntityType {
  String get label => switch (this) {
    NetworkEntityType.doctor => 'Doctor',
    NetworkEntityType.stockist => 'Stockist',
    NetworkEntityType.retailer => 'Retailer',
    NetworkEntityType.hospital => 'Hospital',
  };

  IconData get icon => switch (this) {
    NetworkEntityType.doctor => Icons.medical_services_outlined,
    NetworkEntityType.stockist => Icons.inventory_2_outlined,
    NetworkEntityType.retailer => Icons.storefront_outlined,
    NetworkEntityType.hospital => Icons.local_hospital_outlined,
  };

  static NetworkEntityType fromValue(String? value) {
    return NetworkEntityType.values.firstWhere(
      (candidate) => candidate.name == value,
      orElse: () => NetworkEntityType.retailer,
    );
  }
}

class NetworkEntity {
  const NetworkEntity({
    required this.id,
    required this.name,
    required this.type,
    required this.specialty,
    required this.city,
    required this.territory,
    required this.owner,
    required this.phone,
    required this.status,
    required this.institution,
    required this.sourceLabel,
    required this.verified,
  });

  final String id;
  final String name;
  final NetworkEntityType type;
  final String specialty;
  final String city;
  final String territory;
  final String owner;
  final String phone;
  final String status;
  final String institution;
  final String sourceLabel;
  final bool verified;

  factory NetworkEntity.fromJson(Map<String, dynamic> json) {
    return NetworkEntity(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      type: NetworkEntityTypeX.fromValue(json['type']?.toString()),
      specialty: json['specialty']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      territory: json['territory']?.toString() ?? '',
      owner: json['owner']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      institution: json['institution']?.toString() ?? '',
      sourceLabel: json['sourceLabel']?.toString() ?? '',
      verified: json['verified'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'specialty': specialty,
      'city': city,
      'territory': territory,
      'owner': owner,
      'phone': phone,
      'status': status,
      'institution': institution,
      'sourceLabel': sourceLabel,
      'verified': verified,
    };
  }
}
