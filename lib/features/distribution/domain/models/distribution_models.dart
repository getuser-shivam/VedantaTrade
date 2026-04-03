class DistributionCenter {
  final int id;
  final String name;
  final String code;
  final String address;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final String? phone;
  final String? email;
  final String? managerName;
  final double capacity;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  DistributionCenter({
    required this.id,
    required this.name,
    required this.code,
    required this.address,
    required this.city,
    required this.state,
    required this.postalCode,
    this.country = 'India',
    this.phone,
    this.email,
    this.managerName,
    this.capacity = 0.0,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DistributionCenter.fromJson(Map<String, dynamic> json) {
    return DistributionCenter(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      postalCode: json['postal_code']?.toString() ?? '',
      country: json['country']?.toString() ?? 'India',
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
      managerName: json['manager_name']?.toString(),
      capacity: (json['capacity'] as num?)?.toDouble() ?? 0.0,
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']?.toString() ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at']?.toString() ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'address': address,
      'city': city,
      'state': state,
      'postal_code': postalCode,
      'country': country,
      'phone': phone,
      'email': email,
      'manager_name': managerName,
      'capacity': capacity,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class InventoryAllocation {
  final int id;
  final int productId;
  final int centerId;
  final int quantityAllocated;
  final int quantityAvailable;
  final DateTime allocatedAt;
  final DateTime lastUpdated;
  final String? productName;
  final double? mrp;
  final int? stockQuantity;

  InventoryAllocation({
    required this.id,
    required this.productId,
    required this.centerId,
    required this.quantityAllocated,
    required this.quantityAvailable,
    required this.allocatedAt,
    required this.lastUpdated,
    this.productName,
    this.mrp,
    this.stockQuantity,
  });

  factory InventoryAllocation.fromJson(Map<String, dynamic> json) {
    return InventoryAllocation(
      id: json['id'] ?? 0,
      productId: json['product_id'] ?? 0,
      centerId: json['center_id'] ?? 0,
      quantityAllocated: json['quantity_allocated'] ?? 0,
      quantityAvailable: json['quantity_available'] ?? 0,
      allocatedAt: DateTime.parse(json['allocated_at']?.toString() ?? DateTime.now().toIso8601String()),
      lastUpdated: DateTime.parse(json['last_updated']?.toString() ?? DateTime.now().toIso8601String()),
      productName: json['product_name']?.toString(),
      mrp: (json['mrp'] as num?)?.toDouble(),
      stockQuantity: json['stock_quantity'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'center_id': centerId,
      'quantity_allocated': quantityAllocated,
      'quantity_available': quantityAvailable,
      'allocated_at': allocatedAt.toIso8601String(),
      'last_updated': lastUpdated.toIso8601String(),
      'product_name': productName,
      'mrp': mrp,
      'stock_quantity': stockQuantity,
    };
  }
}

class DistributionRoute {
  final int id;
  final String name;
  final int centerId;
  final String routeType;
  final List<String> areasCovered;
  final double estimatedTimeHours;
  final String? vehicleType;
  final int? driverId;
  final String? driverName;
  final String? driverPhone;
  final String? centerName;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  DistributionRoute({
    required this.id,
    required this.name,
    required this.centerId,
    this.routeType = 'DELIVERY',
    this.areasCovered = const [],
    this.estimatedTimeHours = 0.0,
    this.vehicleType,
    this.driverId,
    this.driverName,
    this.driverPhone,
    this.centerName,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DistributionRoute.fromJson(Map<String, dynamic> json) {
    final areasCoveredJson = json['areas_covered'] as String?;
    List<String> areasCovered = [];
    if (areasCoveredJson != null) {
      try {
        areasCovered = List<String>.from(json.decode(areasCoveredJson));
      } catch (e) {
        // Handle parsing error
      }
    }

    return DistributionRoute(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ?? '',
      centerId: json['center_id'] ?? 0,
      routeType: json['route_type']?.toString() ?? 'DELIVERY',
      areasCovered: areasCovered,
      estimatedTimeHours: (json['estimated_time_hours'] as num?)?.toDouble() ?? 0.0,
      vehicleType: json['vehicle_type']?.toString(),
      driverId: json['driver_id'],
      driverName: json['driver_name']?.toString(),
      driverPhone: json['driver_phone']?.toString(),
      centerName: json['center_name']?.toString(),
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']?.toString() ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at']?.toString() ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'center_id': centerId,
      'route_type': routeType,
      'areas_covered': json.encode(areasCovered),
      'estimated_time_hours': estimatedTimeHours,
      'vehicle_type': vehicleType,
      'driver_id': driverId,
      'driver_name': driverName,
      'driver_phone': driverPhone,
      'center_name': centerName,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class MarketingCampaign {
  final int id;
  final String name;
  final String? description;
  final String campaignType;
  final String status;
  final DateTime? startDate;
  final DateTime? endDate;
  final double budget;
  final double actualCost;
  final String targetAudience;
  final int? createdBy;
  final String? createdByName;
  final DateTime createdAt;
  final DateTime updatedAt;

  MarketingCampaign({
    required this.id,
    required this.name,
    this.description,
    required this.campaignType,
    this.status = 'DRAFT',
    this.startDate,
    this.endDate,
    this.budget = 0.0,
    this.actualCost = 0.0,
    this.targetAudience = '',
    this.createdBy,
    this.createdByName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MarketingCampaign.fromJson(Map<String, dynamic> json) {
    return MarketingCampaign(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      campaignType: json['campaign_type']?.toString() ?? 'PROMOTION',
      status: json['status']?.toString() ?? 'DRAFT',
      startDate: json['start_date'] != null ? DateTime.parse(json['start_date']) : null,
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
      budget: (json['budget'] as num?)?.toDouble() ?? 0.0,
      actualCost: (json['actual_cost'] as num?)?.toDouble() ?? 0.0,
      targetAudience: json['target_audience']?.toString() ?? '',
      createdBy: json['created_by'],
      createdByName: json['created_by_name']?.toString(),
      createdAt: DateTime.parse(json['created_at']?.toString() ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at']?.toString() ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'campaign_type': campaignType,
      'status': status,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'budget': budget,
      'actual_cost': actualCost,
      'target_audience': targetAudience,
      'created_by': createdBy,
      'created_by_name': createdByName,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
