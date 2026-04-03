import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/premium_glassmorphic_theme.dart';

class DistributionCenter {
  final String id;
  final String name;
  final String address;
  final String city;
  final String district;
  final String phone;
  final String email;
  final String manager;
  final int capacity;
  final double latitude;
  final double longitude;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastUpdated;
  final List<String> operatingHours;
  final Map<String, dynamic> inventory;

  DistributionCenter({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.district,
    required this.phone,
    required this.email,
    required this.manager,
    required this.capacity,
    required this.latitude,
    required this.longitude,
    this.isActive = true,
    required this.createdAt,
    this.lastUpdated,
    this.operatingHours = const ['9:00 AM - 6:00 PM'],
    this.inventory = const {},
  });

  factory DistributionCenter.fromJson(Map<String, dynamic> json) {
    return DistributionCenter(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      district: json['district']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      manager: json['manager']?.toString() ?? '',
      capacity: json['capacity'] ?? 0,
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      lastUpdated: json['lastUpdated'] != null 
          ? DateTime.tryParse(json['lastUpdated'].toString())
          : null,
      operatingHours: List<String>.from(json['operatingHours'] ?? []),
      inventory: Map<String, dynamic>.from(json['inventory'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'city': city,
      'district': district,
      'phone': phone,
      'email': email,
      'manager': manager,
      'capacity': capacity,
      'latitude': latitude,
      'longitude': longitude,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'lastUpdated': lastUpdated?.toIso8601String(),
      'operatingHours': operatingHours,
      'inventory': inventory,
    };
  }

  DistributionCenter copyWith({
    String? id,
    String? name,
    String? address,
    String? city,
    String? district,
    String? phone,
    String? email,
    String? manager,
    int? capacity,
    double? latitude,
    double? longitude,
    bool? isActive,
    DateTime? createdAt,
    DateTime? lastUpdated,
    List<String>? operatingHours,
    Map<String, dynamic>? inventory,
  }) {
    return DistributionCenter(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      city: city ?? this.city,
      district: district ?? this.district,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      manager: manager ?? this.manager,
      capacity: capacity ?? this.capacity,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      operatingHours: operatingHours ?? this.operatingHours,
      inventory: inventory ?? this.inventory,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DistributionCenter && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  String get status {
    if (!isActive) return 'Inactive';
    if (lastUpdated == null) return 'Active';
    final daysSinceUpdate = DateTime.now().difference(lastUpdated!);
    if (daysSinceUpdate.inDays > 30) return 'Needs Update';
    return 'Active';
  }

  String get formattedCapacity {
    return '${capacity.toString()} units';
  }

  String get fullAddress {
    return '$address, $city, $district';
  }

  double get inventoryUtilization {
    if (capacity == 0) return 0.0;
    final totalItems = inventory.values.fold(0, (sum, item) {
      if (item is Map) {
        return sum + (item as Map<String, dynamic>)['quantity'] ?? 0;
      }
      return sum + (item as int);
    });
    return (totalItems / capacity) * 100;
  }

  bool get isLowStock {
    return inventoryUtilization > 80;
  }

  bool get isOverStock {
    return inventoryUtilization > 100;
  }

  List<String> get lowStockItems {
    return inventory.entries
        .where((entry) => entry.value is Map && (entry.value as Map<String, dynamic>)['quantity'] < 10)
        .map((entry) => entry.key)
        .toList();
  }

  String get operatingHoursDisplay {
    if (operatingHours.isEmpty) return 'Not specified';
    return operatingHours.join(', ');
  }
}
