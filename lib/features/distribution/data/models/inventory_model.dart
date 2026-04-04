import 'package:equatable/equatable.dart';

class Inventory extends Equatable {
  final String id;
  final String productId;
  final String productName;
  final String productGenericName;
  final String productCategory;
  final String productManufacturer;
  final String productStrength;
  final String productDosageForm;
  final String warehouseId;
  final String warehouseName;
  final String warehouseLocation;
  final int currentStock;
  final int reservedStock;
  final int availableStock;
  final int minimumStock;
  final int maximumStock;
  final int reorderPoint;
  final int reorderQuantity;
  final double unitCost;
  final double totalValue;
  final String batchNumber;
  final DateTime manufactureDate;
  final DateTime expiryDate;
  final String storageConditions;
  final String storageLocation; // specific location within warehouse
  final String supplierId;
  final String supplierName;
  final DateTime lastRestockDate;
  final DateTime? nextRestockDate;
  final int daysOfStock;
  final double turnoverRate;
  final String status; // active, low_stock, out_of_stock, expired, damaged
  final List<InventoryTransaction> transactions;
  final List<StockMovement> stockMovements;
  final String? qualityCheckStatus;
  final DateTime? lastQualityCheck;
  final List<String> alerts;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Inventory({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productGenericName,
    required this.productCategory,
    required this.productManufacturer,
    required this.productStrength,
    required this.productDosageForm,
    required this.warehouseId,
    required this.warehouseName,
    required this.warehouseLocation,
    required this.currentStock,
    required this.reservedStock,
    required this.availableStock,
    required this.minimumStock,
    required this.maximumStock,
    required this.reorderPoint,
    required this.reorderQuantity,
    required this.unitCost,
    required this.totalValue,
    required this.batchNumber,
    required this.manufactureDate,
    required this.expiryDate,
    required this.storageConditions,
    required this.storageLocation,
    required this.supplierId,
    required this.supplierName,
    required this.lastRestockDate,
    this.nextRestockDate,
    required this.daysOfStock,
    required this.turnoverRate,
    required this.status,
    required this.transactions,
    required this.stockMovements,
    this.qualityCheckStatus,
    this.lastQualityCheck,
    this.alerts = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory Inventory.fromJson(Map<String, dynamic> json) {
    return Inventory(
      id: json['id'] ?? '',
      productId: json['productId'] ?? '',
      productName: json['productName'] ?? '',
      productGenericName: json['productGenericName'] ?? '',
      productCategory: json['productCategory'] ?? '',
      productManufacturer: json['productManufacturer'] ?? '',
      productStrength: json['productStrength'] ?? '',
      productDosageForm: json['productDosageForm'] ?? '',
      warehouseId: json['warehouseId'] ?? '',
      warehouseName: json['warehouseName'] ?? '',
      warehouseLocation: json['warehouseLocation'] ?? '',
      currentStock: json['currentStock'] ?? 0,
      reservedStock: json['reservedStock'] ?? 0,
      availableStock: json['availableStock'] ?? 0,
      minimumStock: json['minimumStock'] ?? 0,
      maximumStock: json['maximumStock'] ?? 0,
      reorderPoint: json['reorderPoint'] ?? 0,
      reorderQuantity: json['reorderQuantity'] ?? 0,
      unitCost: (json['unitCost'] ?? 0.0).toDouble(),
      totalValue: (json['totalValue'] ?? 0.0).toDouble(),
      batchNumber: json['batchNumber'] ?? '',
      manufactureDate: DateTime.parse(json['manufactureDate'] ?? DateTime.now().toIso8601String()),
      expiryDate: DateTime.parse(json['expiryDate'] ?? DateTime.now().toIso8601String()),
      storageConditions: json['storageConditions'] ?? '',
      storageLocation: json['storageLocation'] ?? '',
      supplierId: json['supplierId'] ?? '',
      supplierName: json['supplierName'] ?? '',
      lastRestockDate: DateTime.parse(json['lastRestockDate'] ?? DateTime.now().toIso8601String()),
      nextRestockDate: json['nextRestockDate'] != null
          ? DateTime.parse(json['nextRestockDate'])
          : null,
      daysOfStock: json['daysOfStock'] ?? 0,
      turnoverRate: (json['turnoverRate'] ?? 0.0).toDouble(),
      status: json['status'] ?? 'active',
      transactions: (json['transactions'] as List?)
              ?.map((transaction) => InventoryTransaction.fromJson(transaction))
              .toList() ??
          [],
      stockMovements: (json['stockMovements'] as List?)
              ?.map((movement) => StockMovement.fromJson(movement))
              .toList() ??
          [],
      qualityCheckStatus: json['qualityCheckStatus'],
      lastQualityCheck: json['lastQualityCheck'] != null
          ? DateTime.parse(json['lastQualityCheck'])
          : null,
      alerts: List<String>.from(json['alerts'] ?? []),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'productGenericName': productGenericName,
      'productCategory': productCategory,
      'productManufacturer': productManufacturer,
      'productStrength': productStrength,
      'productDosageForm': productDosageForm,
      'warehouseId': warehouseId,
      'warehouseName': warehouseName,
      'warehouseLocation': warehouseLocation,
      'currentStock': currentStock,
      'reservedStock': reservedStock,
      'availableStock': availableStock,
      'minimumStock': minimumStock,
      'maximumStock': maximumStock,
      'reorderPoint': reorderPoint,
      'reorderQuantity': reorderQuantity,
      'unitCost': unitCost,
      'totalValue': totalValue,
      'batchNumber': batchNumber,
      'manufactureDate': manufactureDate.toIso8601String(),
      'expiryDate': expiryDate.toIso8601String(),
      'storageConditions': storageConditions,
      'storageLocation': storageLocation,
      'supplierId': supplierId,
      'supplierName': supplierName,
      'lastRestockDate': lastRestockDate.toIso8601String(),
      'nextRestockDate': nextRestockDate?.toIso8601String(),
      'daysOfStock': daysOfStock,
      'turnoverRate': turnoverRate,
      'status': status,
      'transactions': transactions.map((transaction) => transaction.toJson()).toList(),
      'stockMovements': stockMovements.map((movement) => movement.toJson()).toList(),
      'qualityCheckStatus': qualityCheckStatus,
      'lastQualityCheck': lastQualityCheck?.toIso8601String(),
      'alerts': alerts,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Computed properties
  bool get isLowStock => currentStock <= reorderPoint;
  bool get isOutOfStock => currentStock == 0;
  bool get isOverstocked => currentStock > maximumStock;
  bool get isExpired => expiryDate.isBefore(DateTime.now());
  bool get isExpiringSoon => expiryDate.difference(DateTime.now()).inDays <= 30;
  bool get needsReorder => currentStock <= reorderPoint;
  bool get hasQualityIssues => qualityCheckStatus == 'failed' || alerts.isNotEmpty;

  @override
  List<Object?> get props => [
        id,
        productId,
        productName,
        productGenericName,
        productCategory,
        productManufacturer,
        productStrength,
        productDosageForm,
        warehouseId,
        warehouseName,
        warehouseLocation,
        currentStock,
        reservedStock,
        availableStock,
        minimumStock,
        maximumStock,
        reorderPoint,
        reorderQuantity,
        unitCost,
        totalValue,
        batchNumber,
        manufactureDate,
        expiryDate,
        storageConditions,
        storageLocation,
        supplierId,
        supplierName,
        lastRestockDate,
        nextRestockDate,
        daysOfStock,
        turnoverRate,
        status,
        transactions,
        stockMovements,
        qualityCheckStatus,
        lastQualityCheck,
        alerts,
        createdAt,
        updatedAt,
      ];
}

class InventoryTransaction extends Equatable {
  final String id;
  final String inventoryId;
  final String transactionType; // in, out, adjustment, transfer, return
  final int quantity;
  final double unitCost;
  final double totalCost;
  final String referenceType; // purchase, sales, transfer, adjustment, return
  final String referenceId;
  final String referenceNumber;
  final String reason;
  final String performedBy;
  final String performedByName;
  final DateTime transactionDate;
  final String fromLocation;
  final String toLocation;
  final String batchNumber;
  final DateTime? expiryDate;
  final String? notes;
  final String status; // pending, completed, cancelled
  final DateTime createdAt;

  const InventoryTransaction({
    required this.id,
    required this.inventoryId,
    required this.transactionType,
    required this.quantity,
    required this.unitCost,
    required this.totalCost,
    required this.referenceType,
    required this.referenceId,
    required this.referenceNumber,
    required this.reason,
    required this.performedBy,
    required this.performedByName,
    required this.transactionDate,
    required this.fromLocation,
    required this.toLocation,
    required this.batchNumber,
    this.expiryDate,
    this.notes,
    required this.status,
    required this.createdAt,
  });

  factory InventoryTransaction.fromJson(Map<String, dynamic> json) {
    return InventoryTransaction(
      id: json['id'] ?? '',
      inventoryId: json['inventoryId'] ?? '',
      transactionType: json['transactionType'] ?? '',
      quantity: json['quantity'] ?? 0,
      unitCost: (json['unitCost'] ?? 0.0).toDouble(),
      totalCost: (json['totalCost'] ?? 0.0).toDouble(),
      referenceType: json['referenceType'] ?? '',
      referenceId: json['referenceId'] ?? '',
      referenceNumber: json['referenceNumber'] ?? '',
      reason: json['reason'] ?? '',
      performedBy: json['performedBy'] ?? '',
      performedByName: json['performedByName'] ?? '',
      transactionDate: DateTime.parse(json['transactionDate'] ?? DateTime.now().toIso8601String()),
      fromLocation: json['fromLocation'] ?? '',
      toLocation: json['toLocation'] ?? '',
      batchNumber: json['batchNumber'] ?? '',
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'])
          : null,
      notes: json['notes'],
      status: json['status'] ?? 'pending',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'inventoryId': inventoryId,
      'transactionType': transactionType,
      'quantity': quantity,
      'unitCost': unitCost,
      'totalCost': totalCost,
      'referenceType': referenceType,
      'referenceId': referenceId,
      'referenceNumber': referenceNumber,
      'reason': reason,
      'performedBy': performedBy,
      'performedByName': performedByName,
      'transactionDate': transactionDate.toIso8601String(),
      'fromLocation': fromLocation,
      'toLocation': toLocation,
      'batchNumber': batchNumber,
      'expiryDate': expiryDate?.toIso8601String(),
      'notes': notes,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        inventoryId,
        transactionType,
        quantity,
        unitCost,
        totalCost,
        referenceType,
        referenceId,
        referenceNumber,
        reason,
        performedBy,
        performedByName,
        transactionDate,
        fromLocation,
        toLocation,
        batchNumber,
        expiryDate,
        notes,
        status,
        createdAt,
      ];
}

class StockMovement extends Equatable {
  final String id;
  final String productId;
  final String productName;
  final String fromWarehouseId;
  final String fromWarehouseName;
  final String toWarehouseId;
  final String toWarehouseName;
  final int quantity;
  final String movementType; // transfer, issue, receive, return
  final String status; // pending, in_transit, completed, cancelled
  final DateTime initiatedDate;
  final DateTime? shippedDate;
  final DateTime? receivedDate;
  final String? trackingNumber;
  final String carrier;
  final double shippingCost;
  final String initiatedBy;
  final String initiatedByName;
  final String? approvedBy;
  final String? approvedByName;
  final DateTime? approvedDate;
  final String? notes;
  final List<String> documents;
  final DateTime createdAt;
  final DateTime updatedAt;

  const StockMovement({
    required this.id,
    required this.productId,
    required this.productName,
    required this.fromWarehouseId,
    required this.fromWarehouseName,
    required this.toWarehouseId,
    required this.toWarehouseName,
    required this.quantity,
    required this.movementType,
    required this.status,
    required this.initiatedDate,
    this.shippedDate,
    this.receivedDate,
    this.trackingNumber,
    required this.carrier,
    required this.shippingCost,
    required this.initiatedBy,
    required this.initiatedByName,
    this.approvedBy,
    this.approvedByName,
    this.approvedDate,
    this.notes,
    this.documents = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory StockMovement.fromJson(Map<String, dynamic> json) {
    return StockMovement(
      id: json['id'] ?? '',
      productId: json['productId'] ?? '',
      productName: json['productName'] ?? '',
      fromWarehouseId: json['fromWarehouseId'] ?? '',
      fromWarehouseName: json['fromWarehouseName'] ?? '',
      toWarehouseId: json['toWarehouseId'] ?? '',
      toWarehouseName: json['toWarehouseName'] ?? '',
      quantity: json['quantity'] ?? 0,
      movementType: json['movementType'] ?? '',
      status: json['status'] ?? 'pending',
      initiatedDate: DateTime.parse(json['initiatedDate'] ?? DateTime.now().toIso8601String()),
      shippedDate: json['shippedDate'] != null
          ? DateTime.parse(json['shippedDate'])
          : null,
      receivedDate: json['receivedDate'] != null
          ? DateTime.parse(json['receivedDate'])
          : null,
      trackingNumber: json['trackingNumber'],
      carrier: json['carrier'] ?? '',
      shippingCost: (json['shippingCost'] ?? 0.0).toDouble(),
      initiatedBy: json['initiatedBy'] ?? '',
      initiatedByName: json['initiatedByName'] ?? '',
      approvedBy: json['approvedBy'],
      approvedByName: json['approvedByName'],
      approvedDate: json['approvedDate'] != null
          ? DateTime.parse(json['approvedDate'])
          : null,
      notes: json['notes'],
      documents: List<String>.from(json['documents'] ?? []),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'fromWarehouseId': fromWarehouseId,
      'fromWarehouseName': fromWarehouseName,
      'toWarehouseId': toWarehouseId,
      'toWarehouseName': toWarehouseName,
      'quantity': quantity,
      'movementType': movementType,
      'status': status,
      'initiatedDate': initiatedDate.toIso8601String(),
      'shippedDate': shippedDate?.toIso8601String(),
      'receivedDate': receivedDate?.toIso8601String(),
      'trackingNumber': trackingNumber,
      'carrier': carrier,
      'shippingCost': shippingCost,
      'initiatedBy': initiatedBy,
      'initiatedByName': initiatedByName,
      'approvedBy': approvedBy,
      'approvedByName': approvedByName,
      'approvedDate': approvedDate?.toIso8601String(),
      'notes': notes,
      'documents': documents,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Computed properties
  bool get isPending => status == 'pending';
  bool get isInTransit => status == 'in_transit';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';
  
  Duration? get transitTime {
    if (shippedDate != null && receivedDate != null) {
      return receivedDate!.difference(shippedDate!);
    }
    return null;
  }

  @override
  List<Object?> get props => [
        id,
        productId,
        productName,
        fromWarehouseId,
        fromWarehouseName,
        toWarehouseId,
        toWarehouseName,
        quantity,
        movementType,
        status,
        initiatedDate,
        shippedDate,
        receivedDate,
        trackingNumber,
        carrier,
        shippingCost,
        initiatedBy,
        initiatedByName,
        approvedBy,
        approvedByName,
        approvedDate,
        notes,
        documents,
        createdAt,
        updatedAt,
      ];
}

class Warehouse extends Equatable {
  final String id;
  final String name;
  final String code;
  final String type; // main, regional, distribution, retail
  final String location;
  final String address;
  final String city;
  final String state;
  final String country;
  final String postalCode;
  final double capacity;
  final double currentUtilization;
  final String managerId;
  final String managerName;
  final String managerEmail;
  final String managerPhone;
  final List<String> operatingHours;
  final bool isActive;
  final bool isClimateControlled;
  final double temperature;
  final double humidity;
  final List<String> certifications;
  final List<String> specializations;
  final DateTime establishedDate;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Warehouse({
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
    required this.capacity,
    required this.currentUtilization,
    required this.managerId,
    required this.managerName,
    required this.managerEmail,
    required this.managerPhone,
    required this.operatingHours,
    required this.isActive,
    required this.isClimateControlled,
    required this.temperature,
    required this.humidity,
    required this.certifications,
    required this.specializations,
    required this.establishedDate,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Warehouse.fromJson(Map<String, dynamic> json) {
    return Warehouse(
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
      capacity: (json['capacity'] ?? 0.0).toDouble(),
      currentUtilization: (json['currentUtilization'] ?? 0.0).toDouble(),
      managerId: json['managerId'] ?? '',
      managerName: json['managerName'] ?? '',
      managerEmail: json['managerEmail'] ?? '',
      managerPhone: json['managerPhone'] ?? '',
      operatingHours: List<String>.from(json['operatingHours'] ?? []),
      isActive: json['isActive'] ?? false,
      isClimateControlled: json['isClimateControlled'] ?? false,
      temperature: (json['temperature'] ?? 0.0).toDouble(),
      humidity: (json['humidity'] ?? 0.0).toDouble(),
      certifications: List<String>.from(json['certifications'] ?? []),
      specializations: List<String>.from(json['specializations'] ?? []),
      establishedDate: DateTime.parse(json['establishedDate'] ?? DateTime.now().toIso8601String()),
      status: json['status'] ?? 'active',
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
      'capacity': capacity,
      'currentUtilization': currentUtilization,
      'managerId': managerId,
      'managerName': managerName,
      'managerEmail': managerEmail,
      'managerPhone': managerPhone,
      'operatingHours': operatingHours,
      'isActive': isActive,
      'isClimateControlled': isClimateControlled,
      'temperature': temperature,
      'humidity': humidity,
      'certifications': certifications,
      'specializations': specializations,
      'establishedDate': establishedDate.toIso8601String(),
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Computed properties
  double get utilizationRate => capacity > 0 ? (currentUtilization / capacity) * 100 : 0;
  bool get isNearCapacity => utilizationRate >= 80;
  bool get hasCapacity => utilizationRate < 90;

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
        capacity,
        currentUtilization,
        managerId,
        managerName,
        managerEmail,
        managerPhone,
        operatingHours,
        isActive,
        isClimateControlled,
        temperature,
        humidity,
        certifications,
        specializations,
        establishedDate,
        status,
        createdAt,
        updatedAt,
      ];
}
