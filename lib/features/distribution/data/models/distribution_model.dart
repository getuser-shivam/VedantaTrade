import 'package:equatable/equatable.dart';

class DistributionNetwork extends Equatable {
  final String id;
  final String name;
  final String type; // direct, indirect, hybrid, franchise, agency
  final String tier; // primary, secondary, tertiary
  final String status; // active, inactive, suspended, terminated
  final String region;
  final String territory;
  final String address;
  final String city;
  final String state;
  final String country;
  final String postalCode;
  final String contactPerson;
  final String contactEmail;
  final String contactPhone;
  final String distributorId;
  final String distributorName;
  final String distributorType; // wholesaler, retailer, hospital, pharmacy, chain
  final List<String> specializations;
  final List<String> productCategories;
  final int capacity;
  final int currentLoad;
  final double marketShare;
  final String performanceRating; // excellent, good, average, poor
  final double creditLimit;
  final double currentCredit;
  final String paymentTerms;
  final List<String> paymentMethods;
  final DateTime contractStartDate;
  final DateTime? contractEndDate;
  final String contractType; // exclusive, non_exclusive, selective
  final List<String> exclusiveProducts;
  final List<String> targetMarkets;
  final List<DistributionCenter> distributionCenters;
  final List<SalesRepresentative> salesRepresentatives;
  final Map<String, dynamic> performanceMetrics;
  final List<String> certifications;
  final List<String> licenses;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DistributionNetwork({
    required this.id,
    required this.name,
    required this.type,
    required this.tier,
    required this.status,
    required this.region,
    required this.territory,
    required this.address,
    required this.city,
    required this.state,
    required this.country,
    required this.postalCode,
    required this.contactPerson,
    required this.contactEmail,
    required this.contactPhone,
    required this.distributorId,
    required this.distributorName,
    required this.distributorType,
    required this.specializations,
    required this.productCategories,
    required this.capacity,
    required this.currentLoad,
    required this.marketShare,
    required this.performanceRating,
    required this.creditLimit,
    required this.currentCredit,
    required this.paymentTerms,
    required this.paymentMethods,
    required this.contractStartDate,
    this.contractEndDate,
    required this.contractType,
    required this.exclusiveProducts,
    required this.targetMarkets,
    required this.distributionCenters,
    required this.salesRepresentatives,
    required this.performanceMetrics,
    required this.certifications,
    required this.licenses,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DistributionNetwork.fromJson(Map<String, dynamic> json) {
    return DistributionNetwork(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      tier: json['tier'] ?? '',
      status: json['status'] ?? 'active',
      region: json['region'] ?? '',
      territory: json['territory'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      country: json['country'] ?? '',
      postalCode: json['postalCode'] ?? '',
      contactPerson: json['contactPerson'] ?? '',
      contactEmail: json['contactEmail'] ?? '',
      contactPhone: json['contactPhone'] ?? '',
      distributorId: json['distributorId'] ?? '',
      distributorName: json['distributorName'] ?? '',
      distributorType: json['distributorType'] ?? '',
      specializations: List<String>.from(json['specializations'] ?? []),
      productCategories: List<String>.from(json['productCategories'] ?? []),
      capacity: json['capacity'] ?? 0,
      currentLoad: json['currentLoad'] ?? 0,
      marketShare: (json['marketShare'] ?? 0.0).toDouble(),
      performanceRating: json['performanceRating'] ?? 'average',
      creditLimit: (json['creditLimit'] ?? 0.0).toDouble(),
      currentCredit: (json['currentCredit'] ?? 0.0).toDouble(),
      paymentTerms: json['paymentTerms'] ?? '',
      paymentMethods: List<String>.from(json['paymentMethods'] ?? []),
      contractStartDate: DateTime.parse(json['contractStartDate'] ?? DateTime.now().toIso8601String()),
      contractEndDate: json['contractEndDate'] != null
          ? DateTime.parse(json['contractEndDate'])
          : null,
      contractType: json['contractType'] ?? '',
      exclusiveProducts: List<String>.from(json['exclusiveProducts'] ?? []),
      targetMarkets: List<String>.from(json['targetMarkets'] ?? []),
      distributionCenters: (json['distributionCenters'] as List?)
              ?.map((center) => DistributionCenter.fromJson(center))
              .toList() ??
          [],
      salesRepresentatives: (json['salesRepresentatives'] as List?)
              ?.map((rep) => SalesRepresentative.fromJson(rep))
              .toList() ??
          [],
      performanceMetrics: Map<String, dynamic>.from(json['performanceMetrics'] ?? {}),
      certifications: List<String>.from(json['certifications'] ?? []),
      licenses: List<String>.from(json['licenses'] ?? []),
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'tier': tier,
      'status': status,
      'region': region,
      'territory': territory,
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'postalCode': postalCode,
      'contactPerson': contactPerson,
      'contactEmail': contactEmail,
      'contactPhone': contactPhone,
      'distributorId': distributorId,
      'distributorName': distributorName,
      'distributorType': distributorType,
      'specializations': specializations,
      'productCategories': productCategories,
      'capacity': capacity,
      'currentLoad': currentLoad,
      'marketShare': marketShare,
      'performanceRating': performanceRating,
      'creditLimit': creditLimit,
      'currentCredit': currentCredit,
      'paymentTerms': paymentTerms,
      'paymentMethods': paymentMethods,
      'contractStartDate': contractStartDate.toIso8601String(),
      'contractEndDate': contractEndDate?.toIso8601String(),
      'contractType': contractType,
      'exclusiveProducts': exclusiveProducts,
      'targetMarkets': targetMarkets,
      'distributionCenters': distributionCenters.map((center) => center.toJson()).toList(),
      'salesRepresentatives': salesRepresentatives.map((rep) => rep.toJson()).toList(),
      'performanceMetrics': performanceMetrics,
      'certifications': certifications,
      'licenses': licenses,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Computed properties
  bool get isActive => status == 'active';
  bool get isInactive => status == 'inactive';
  bool get isSuspended => status == 'suspended';
  bool get isTerminated => status == 'terminated';
  
  double get utilizationRate => capacity > 0 ? (currentLoad / capacity) * 100 : 0;
  bool get isAtCapacity => utilizationRate >= 90;
  bool get hasCapacity => utilizationRate < 80;
  
  double get creditUtilization => creditLimit > 0 ? (currentCredit / creditLimit) * 100 : 0;
  bool get isCreditLimitReached => currentCredit >= creditLimit;
  bool get hasAvailableCredit => currentCredit < creditLimit;
  
  bool get isContractExpired => contractEndDate != null && DateTime.now().isAfter(contractEndDate!);
  bool get isContractExpiringSoon => contractEndDate != null && 
      contractEndDate!.difference(DateTime.now()).inDays <= 30;

  @override
  List<Object?> get props => [
        id,
        name,
        type,
        tier,
        status,
        region,
        territory,
        address,
        city,
        state,
        country,
        postalCode,
        contactPerson,
        contactEmail,
        contactPhone,
        distributorId,
        distributorName,
        distributorType,
        specializations,
        productCategories,
        capacity,
        currentLoad,
        marketShare,
        performanceRating,
        creditLimit,
        currentCredit,
        paymentTerms,
        paymentMethods,
        contractStartDate,
        contractEndDate,
        contractType,
        exclusiveProducts,
        targetMarkets,
        distributionCenters,
        salesRepresentatives,
        performanceMetrics,
        certifications,
        licenses,
        notes,
        createdAt,
        updatedAt,
      ];
}

class DistributionCenter extends Equatable {
  final String id;
  final String name;
  final String code;
  final String type; // warehouse, fulfillment_center, cross_dock, retail_store
  final String location;
  final String address;
  final String city;
  final String state;
  final String country;
  final String postalCode;
  final double storageCapacity;
  final double currentStorage;
  final int orderProcessingCapacity;
  final int currentOrders;
  final List<String> operatingHours;
  final String managerId;
  final String managerName;
  final String managerEmail;
  final String managerPhone;
  final List<String> services;
  final List<String> equipment;
  final bool isClimateControlled;
  final double temperature;
  final double humidity;
  final List<String> certifications;
  final String status;
  final DateTime establishedDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DistributionCenter({
    required this.id,
    required this.name,
    required this.code,
    required this.type,
    required this.location,
    required this.address,
    required this.city,
    required this.state,
    required this.country,
    required this.postalCode,
    required this.storageCapacity,
    required this.currentStorage,
    required this.orderProcessingCapacity,
    required this.currentOrders,
    required this.operatingHours,
    required this.managerId,
    required this.managerName,
    required this.managerEmail,
    required this.managerPhone,
    required this.services,
    required this.equipment,
    required this.isClimateControlled,
    required this.temperature,
    required this.humidity,
    required this.certifications,
    required this.status,
    required this.establishedDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DistributionCenter.fromJson(Map<String, dynamic> json) {
    return DistributionCenter(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      type: json['type'] ?? '',
      location: json['location'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      country: json['country'] ?? '',
      postalCode: json['postalCode'] ?? '',
      storageCapacity: (json['storageCapacity'] ?? 0.0).toDouble(),
      currentStorage: (json['currentStorage'] ?? 0.0).toDouble(),
      orderProcessingCapacity: json['orderProcessingCapacity'] ?? 0,
      currentOrders: json['currentOrders'] ?? 0,
      operatingHours: List<String>.from(json['operatingHours'] ?? []),
      managerId: json['managerId'] ?? '',
      managerName: json['managerName'] ?? '',
      managerEmail: json['managerEmail'] ?? '',
      managerPhone: json['managerPhone'] ?? '',
      services: List<String>.from(json['services'] ?? []),
      equipment: List<String>.from(json['equipment'] ?? []),
      isClimateControlled: json['isClimateControlled'] ?? false,
      temperature: (json['temperature'] ?? 0.0).toDouble(),
      humidity: (json['humidity'] ?? 0.0).toDouble(),
      certifications: List<String>.from(json['certifications'] ?? []),
      status: json['status'] ?? 'active',
      establishedDate: DateTime.parse(json['establishedDate'] ?? DateTime.now().toIso8601String()),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'type': type,
      'location': location,
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'postalCode': postalCode,
      'storageCapacity': storageCapacity,
      'currentStorage': currentStorage,
      'orderProcessingCapacity': orderProcessingCapacity,
      'currentOrders': currentOrders,
      'operatingHours': operatingHours,
      'managerId': managerId,
      'managerName': managerName,
      'managerEmail': managerEmail,
      'managerPhone': managerPhone,
      'services': services,
      'equipment': equipment,
      'isClimateControlled': isClimateControlled,
      'temperature': temperature,
      'humidity': humidity,
      'certifications': certifications,
      'status': status,
      'establishedDate': establishedDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Computed properties
  double get storageUtilization => storageCapacity > 0 ? (currentStorage / storageCapacity) * 100 : 0;
  double get orderUtilization => orderProcessingCapacity > 0 ? (currentOrders / orderProcessingCapacity) * 100 : 0;
  bool get isStorageFull => storageUtilization >= 95;
  bool get hasStorageCapacity => storageUtilization < 80;
  bool get isOrderCapacityFull => orderUtilization >= 95;
  bool get hasOrderCapacity => orderUtilization < 80;

  @override
  List<Object?> get props => [
        id,
        name,
        code,
        type,
        location,
        address,
        city,
        state,
        country,
        postalCode,
        storageCapacity,
        currentStorage,
        orderProcessingCapacity,
        currentOrders,
        operatingHours,
        managerId,
        managerName,
        managerEmail,
        managerPhone,
        services,
        equipment,
        isClimateControlled,
        temperature,
        humidity,
        certifications,
        status,
        establishedDate,
        createdAt,
        updatedAt,
      ];
}

class SalesRepresentative extends Equatable {
  final String id;
  final String employeeId;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String region;
  final String territory;
  final String distributorId;
  final String distributorName;
  final String position;
  final String department;
  final DateTime hireDate;
  final String status; // active, inactive, on_leave, terminated
  final List<String> productCategories;
  final List<String> targetCustomers;
  final double salesTarget;
  final double currentSales;
  final double commissionRate;
  final String performanceRating;
  final List<String> skills;
  final List<String> certifications;
  final String education;
  final String experience;
  final String managerId;
  final String managerName;
  final Map<String, dynamic> performanceMetrics;
  final List<String> achievements;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SalesRepresentative({
    required this.id,
    required this.employeeId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.region,
    required this.territory,
    required this.distributorId,
    required this.distributorName,
    required this.position,
    required this.department,
    required this.hireDate,
    required this.status,
    required this.productCategories,
    required this.targetCustomers,
    required this.salesTarget,
    required this.currentSales,
    required this.commissionRate,
    required this.performanceRating,
    required this.skills,
    required this.certifications,
    required this.education,
    required this.experience,
    required this.managerId,
    required this.managerName,
    required this.performanceMetrics,
    required this.achievements,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SalesRepresentative.fromJson(Map<String, dynamic> json) {
    return SalesRepresentative(
      id: json['id'] ?? '',
      employeeId: json['employeeId'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      region: json['region'] ?? '',
      territory: json['territory'] ?? '',
      distributorId: json['distributorId'] ?? '',
      distributorName: json['distributorName'] ?? '',
      position: json['position'] ?? '',
      department: json['department'] ?? '',
      hireDate: DateTime.parse(json['hireDate'] ?? DateTime.now().toIso8601String()),
      status: json['status'] ?? 'active',
      productCategories: List<String>.from(json['productCategories'] ?? []),
      targetCustomers: List<String>.from(json['targetCustomers'] ?? []),
      salesTarget: (json['salesTarget'] ?? 0.0).toDouble(),
      currentSales: (json['currentSales'] ?? 0.0).toDouble(),
      commissionRate: (json['commissionRate'] ?? 0.0).toDouble(),
      performanceRating: json['performanceRating'] ?? 'average',
      skills: List<String>.from(json['skills'] ?? []),
      certifications: List<String>.from(json['certifications'] ?? []),
      education: json['education'] ?? '',
      experience: json['experience'] ?? '',
      managerId: json['managerId'] ?? '',
      managerName: json['managerName'] ?? '',
      performanceMetrics: Map<String, dynamic>.from(json['performanceMetrics'] ?? {}),
      achievements: List<String>.from(json['achievements'] ?? []),
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeId': employeeId,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'region': region,
      'territory': territory,
      'distributorId': distributorId,
      'distributorName': distributorName,
      'position': position,
      'department': department,
      'hireDate': hireDate.toIso8601String(),
      'status': status,
      'productCategories': productCategories,
      'targetCustomers': targetCustomers,
      'salesTarget': salesTarget,
      'currentSales': currentSales,
      'commissionRate': commissionRate,
      'performanceRating': performanceRating,
      'skills': skills,
      'certifications': certifications,
      'education': education,
      'experience': experience,
      'managerId': managerId,
      'managerName': managerName,
      'performanceMetrics': performanceMetrics,
      'achievements': achievements,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Computed properties
  String get fullName => '$firstName $lastName';
  bool get isActive => status == 'active';
  bool get isInactive => status == 'inactive';
  bool get isOnLeave => status == 'on_leave';
  bool get isTerminated => status == 'terminated';
  
  double get salesAchievement => salesTarget > 0 ? (currentSales / salesTarget) * 100 : 0;
  bool get isMeetingTarget => salesAchievement >= 100;
  bool get isExceedingTarget => salesAchievement >= 110;
  bool get isBelowTarget => salesAchievement < 80;
  
  int get yearsOfExperience => DateTime.now().difference(hireDate).inDays ~/ 365;

  @override
  List<Object?> get props => [
        id,
        employeeId,
        firstName,
        lastName,
        email,
        phone,
        region,
        territory,
        distributorId,
        distributorName,
        position,
        department,
        hireDate,
        status,
        productCategories,
        targetCustomers,
        salesTarget,
        currentSales,
        commissionRate,
        performanceRating,
        skills,
        certifications,
        education,
        experience,
        managerId,
        managerName,
        performanceMetrics,
        achievements,
        notes,
        createdAt,
        updatedAt,
      ];
}

class Route extends Equatable {
  final String id;
  final String name;
  final String code;
  final String type; // delivery, pickup, sales, service
  final String region;
  final List<String> territories;
  final List<String> waypoints;
  final String startPoint;
  final String endPoint;
  final double totalDistance;
  final Duration estimatedDuration;
  final String vehicleId;
  final String vehicleType;
  final String driverId;
  final String driverName;
  final List<String> assignedOrders;
  final String status; // planned, in_progress, completed, cancelled
  final DateTime plannedDate;
  final DateTime? actualStartTime;
  final DateTime? actualEndTime;
  final int capacity;
  final int currentLoad;
  final List<String> constraints;
  final Map<String, dynamic> optimizationMetrics;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Route({
    required this.id,
    required this.name,
    required this.code,
    required this.type,
    required this.region,
    required this.territories,
    required this.waypoints,
    required this.startPoint,
    required this.endPoint,
    required this.totalDistance,
    required this.estimatedDuration,
    required this.vehicleId,
    required this.vehicleType,
    required this.driverId,
    required this.driverName,
    required this.assignedOrders,
    required this.status,
    required this.plannedDate,
    this.actualStartTime,
    this.actualEndTime,
    required this.capacity,
    required this.currentLoad,
    required this.constraints,
    required this.optimizationMetrics,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Route.fromJson(Map<String, dynamic> json) {
    return Route(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      type: json['type'] ?? '',
      region: json['region'] ?? '',
      territories: List<String>.from(json['territories'] ?? []),
      waypoints: List<String>.from(json['waypoints'] ?? []),
      startPoint: json['startPoint'] ?? '',
      endPoint: json['endPoint'] ?? '',
      totalDistance: (json['totalDistance'] ?? 0.0).toDouble(),
      estimatedDuration: Duration(hours: json['estimatedDurationHours'] ?? 0, minutes: json['estimatedDurationMinutes'] ?? 0),
      vehicleId: json['vehicleId'] ?? '',
      vehicleType: json['vehicleType'] ?? '',
      driverId: json['driverId'] ?? '',
      driverName: json['driverName'] ?? '',
      assignedOrders: List<String>.from(json['assignedOrders'] ?? []),
      status: json['status'] ?? 'planned',
      plannedDate: DateTime.parse(json['plannedDate'] ?? DateTime.now().toIso8601String()),
      actualStartTime: json['actualStartTime'] != null
          ? DateTime.parse(json['actualStartTime'])
          : null,
      actualEndTime: json['actualEndTime'] != null
          ? DateTime.parse(json['actualEndTime'])
          : null,
      capacity: json['capacity'] ?? 0,
      currentLoad: json['currentLoad'] ?? 0,
      constraints: List<String>.from(json['constraints'] ?? []),
      optimizationMetrics: Map<String, dynamic>.from(json['optimizationMetrics'] ?? {}),
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'type': type,
      'region': region,
      'territories': territories,
      'waypoints': waypoints,
      'startPoint': startPoint,
      'endPoint': endPoint,
      'totalDistance': totalDistance,
      'estimatedDurationHours': estimatedDuration.inHours,
      'estimatedDurationMinutes': estimatedDuration.inMinutes % 60,
      'vehicleId': vehicleId,
      'vehicleType': vehicleType,
      'driverId': driverId,
      'driverName': driverName,
      'assignedOrders': assignedOrders,
      'status': status,
      'plannedDate': plannedDate.toIso8601String(),
      'actualStartTime': actualStartTime?.toIso8601String(),
      'actualEndTime': actualEndTime?.toIso8601String(),
      'capacity': capacity,
      'currentLoad': currentLoad,
      'constraints': constraints,
      'optimizationMetrics': optimizationMetrics,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Computed properties
  bool get isPlanned => status == 'planned';
  bool get isInProgress => status == 'in_progress';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';
  
  double get utilizationRate => capacity > 0 ? (currentLoad / capacity) * 100 : 0;
  bool get isAtCapacity => utilizationRate >= 90;
  bool get hasCapacity => utilizationRate < 80;
  
  Duration? get actualDuration {
    if (actualStartTime != null && actualEndTime != null) {
      return actualEndTime!.difference(actualStartTime!);
    }
    return null;
  }

  @override
  List<Object?> get props => [
        id,
        name,
        code,
        type,
        region,
        territories,
        waypoints,
        startPoint,
        endPoint,
        totalDistance,
        estimatedDuration,
        vehicleId,
        vehicleType,
        driverId,
        driverName,
        assignedOrders,
        status,
        plannedDate,
        actualStartTime,
        actualEndTime,
        capacity,
        currentLoad,
        constraints,
        optimizationMetrics,
        notes,
        createdAt,
        updatedAt,
      ];
}
