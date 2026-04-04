// Inventory Item Model
class InventoryItem {
  final String id;
  final String sku;
  final String productName;
  final String brand;
  final String category;
  final String description;
  final double unitPrice;
  final int currentStock;
  final int minStock;
  final int maxStock;
  final int reorderLevel;
  final String batchNumber;
  final DateTime expiryDate;
  final String manufacturer;
  final String storageConditions;
  final DateTime lastUpdated;

  const InventoryItem({
    required this.id,
    required this.sku,
    required this.productName,
    required this.brand,
    required this.category,
    required this.description,
    required this.unitPrice,
    required this.currentStock,
    required this.minStock,
    required this.maxStock,
    required this.reorderLevel,
    required this.batchNumber,
    required this.expiryDate,
    required this.manufacturer,
    required this.storageConditions,
    required this.lastUpdated,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: json['id'] as String,
      sku: json['sku'] as String,
      productName: json['productName'] as String,
      brand: json['brand'] as String,
      category: json['category'] as String,
      description: json['description'] as String,
      unitPrice: (json['unitPrice'] as num).toDouble(),
      currentStock: (json['currentStock'] as num).toInt(),
      minStock: (json['minStock'] as num).toInt(),
      maxStock: (json['maxStock'] as num).toInt(),
      reorderLevel: (json['reorderLevel'] as num).toInt(),
      batchNumber: json['batchNumber'] as String,
      expiryDate: DateTime.parse(json['expiryDate'] as String),
      manufacturer: json['manufacturer'] as String,
      storageConditions: json['storageConditions'] as String,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sku': sku,
      'productName': productName,
      'brand': brand,
      'category': category,
      'description': description,
      'unitPrice': unitPrice,
      'currentStock': currentStock,
      'minStock': minStock,
      'maxStock': maxStock,
      'reorderLevel': reorderLevel,
      'batchNumber': batchNumber,
      'expiryDate': expiryDate.toIso8601String(),
      'manufacturer': manufacturer,
      'storageConditions': storageConditions,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  InventoryItem copyWith({
    String? id,
    String? sku,
    String? productName,
    String? brand,
    String? category,
    String? description,
    double? unitPrice,
    int? currentStock,
    int? minStock,
    int? maxStock,
    int? reorderLevel,
    String? batchNumber,
    DateTime? expiryDate,
    String? manufacturer,
    String? storageConditions,
    DateTime? lastUpdated,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      sku: sku ?? this.sku,
      productName: productName ?? this.productName,
      brand: brand ?? this.brand,
      category: category ?? this.category,
      description: description ?? this.description,
      unitPrice: unitPrice ?? this.unitPrice,
      currentStock: currentStock ?? this.currentStock,
      minStock: minStock ?? this.minStock,
      maxStock: maxStock ?? this.maxStock,
      reorderLevel: reorderLevel ?? this.reorderLevel,
      batchNumber: batchNumber ?? this.batchNumber,
      expiryDate: expiryDate ?? this.expiryDate,
      manufacturer: manufacturer ?? this.manufacturer,
      storageConditions: storageConditions ?? this.storageConditions,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  // Computed properties
  double get totalValue => currentStock * unitPrice;
  
  StockStatus get stockStatus {
    if (currentStock == 0) return StockStatus.outOfStock;
    if (currentStock <= minStock) return StockStatus.critical;
    if (currentStock <= reorderLevel) return StockStatus.low;
    if (currentStock >= maxStock * 0.8) return StockStatus.high;
    return StockStatus.normal;
  }

  int get daysUntilExpiry {
    return expiryDate.difference(DateTime.now()).inDays;
  }

  ExpiryStatus get expiryStatus {
    final days = daysUntilExpiry;
    if (days < 0) return ExpiryStatus.expired;
    if (days < 30) return ExpiryStatus.expiringSoon;
    if (days < 90) return ExpiryStatus.moderate;
    return ExpiryStatus.good;
  }

  bool get needsReorder => currentStock <= reorderLevel;
  
  double get stockUtilization => maxStock > 0 ? (currentStock / maxStock) * 100 : 0;
}

// Stock Status Enum
enum StockStatus {
  normal,
  low,
  critical,
  outOfStock,
  high,
}

// Expiry Status Enum
enum ExpiryStatus {
  good,
  moderate,
  expiringSoon,
  expired,
}

// Stock Alert Model
class StockAlert {
  final String id;
  final String sku;
  final String productName;
  final int currentStock;
  final int minStock;
  final int maxStock;
  final AlertSeverity severity;
  final String message;
  final String recommendation;
  final DateTime createdAt;
  final bool acknowledged;
  final DateTime? acknowledgedAt;
  final String? acknowledgedBy;

  const StockAlert({
    required this.id,
    required this.sku,
    required this.productName,
    required this.currentStock,
    required this.minStock,
    required this.maxStock,
    required this.severity,
    required this.message,
    required this.recommendation,
    required this.createdAt,
    required this.acknowledged,
    this.acknowledgedAt,
    this.acknowledgedBy,
  });

  factory StockAlert.fromJson(Map<String, dynamic> json) {
    return StockAlert(
      id: json['id'] as String,
      sku: json['sku'] as String,
      productName: json['productName'] as String,
      currentStock: (json['currentStock'] as num).toInt(),
      minStock: (json['minStock'] as num).toInt(),
      maxStock: (json['maxStock'] as num).toInt(),
      severity: AlertSeverity.values.firstWhere(
        (e) => e.toString() == json['severity'],
        orElse: () => AlertSeverity.info,
      ),
      message: json['message'] as String,
      recommendation: json['recommendation'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      acknowledged: json['acknowledged'] as bool,
      acknowledgedAt: json['acknowledgedAt'] != null
          ? DateTime.parse(json['acknowledgedAt'] as String)
          : null,
      acknowledgedBy: json['acknowledgedBy'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sku': sku,
      'productName': productName,
      'currentStock': currentStock,
      'minStock': minStock,
      'maxStock': maxStock,
      'severity': severity.toString(),
      'message': message,
      'recommendation': recommendation,
      'createdAt': createdAt.toIso8601String(),
      'acknowledged': acknowledged,
      'acknowledgedAt': acknowledgedAt?.toIso8601String(),
      'acknowledgedBy': acknowledgedBy,
    };
  }

  StockAlert copyWith({
    String? id,
    String? sku,
    String? productName,
    int? currentStock,
    int? minStock,
    int? maxStock,
    AlertSeverity? severity,
    String? message,
    String? recommendation,
    DateTime? createdAt,
    bool? acknowledged,
    DateTime? acknowledgedAt,
    String? acknowledgedBy,
  }) {
    return StockAlert(
      id: id ?? this.id,
      sku: sku ?? this.sku,
      productName: productName ?? this.productName,
      currentStock: currentStock ?? this.currentStock,
      minStock: minStock ?? this.minStock,
      maxStock: maxStock ?? this.maxStock,
      severity: severity ?? this.severity,
      message: message ?? this.message,
      recommendation: recommendation ?? this.recommendation,
      createdAt: createdAt ?? this.createdAt,
      acknowledged: acknowledged ?? this.acknowledged,
      acknowledgedAt: acknowledgedAt ?? this.acknowledgedAt,
      acknowledgedBy: acknowledgedBy ?? this.acknowledgedBy,
    );
  }
}

// Alert Severity Enum
enum AlertSeverity {
  info,
  warning,
  critical,
  urgent,
}

// Stock Movement Model
class StockMovement {
  final String id;
  final String sku;
  final String productName;
  final MovementType type;
  final int quantity;
  final String referenceId;
  final String referenceType;
  final String fromLocation;
  final String? toLocation;
  final DateTime movementDate;
  final String? performedBy;
  final String? notes;
  final String batchNumber;

  const StockMovement({
    required this.id,
    required this.sku,
    required this.productName,
    required this.type,
    required this.quantity,
    required this.referenceId,
    required this.referenceType,
    required this.fromLocation,
    this.toLocation,
    required this.movementDate,
    this.performedBy,
    this.notes,
    required this.batchNumber,
  });

  factory StockMovement.fromJson(Map<String, dynamic> json) {
    return StockMovement(
      id: json['id'] as String,
      sku: json['sku'] as String,
      productName: json['productName'] as String,
      type: MovementType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => MovementType.adjustment,
      ),
      quantity: (json['quantity'] as num).toInt(),
      referenceId: json['referenceId'] as String,
      referenceType: json['referenceType'] as String,
      fromLocation: json['fromLocation'] as String,
      toLocation: json['toLocation'] as String?,
      movementDate: DateTime.parse(json['movementDate'] as String),
      performedBy: json['performedBy'] as String?,
      notes: json['notes'] as String?,
      batchNumber: json['batchNumber'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sku': sku,
      'productName': productName,
      'type': type.toString(),
      'quantity': quantity,
      'referenceId': referenceId,
      'referenceType': referenceType,
      'fromLocation': fromLocation,
      'toLocation': toLocation,
      'movementDate': movementDate.toIso8601String(),
      'performedBy': performedBy,
      'notes': notes,
      'batchNumber': batchNumber,
    };
  }
}

// Movement Type Enum
enum MovementType {
  purchase,
  sale,
  transfer,
  adjustment,
  return_,
  damage,
  expiry,
  recall,
}

// Batch Information Model
class BatchInfo {
  final String batchNumber;
  final String sku;
  final String productName;
  final int initialQuantity;
  final int currentQuantity;
  final DateTime manufactureDate;
  final DateTime expiryDate;
  final String manufacturer;
  final String? storageLocation;
  final List<QualityCheck> qualityChecks;

  const BatchInfo({
    required this.batchNumber,
    required this.sku,
    required this.productName,
    required this.initialQuantity,
    required this.currentQuantity,
    required this.manufactureDate,
    required this.expiryDate,
    required this.manufacturer,
    this.storageLocation,
    required this.qualityChecks,
  });

  factory BatchInfo.fromJson(Map<String, dynamic> json) {
    return BatchInfo(
      batchNumber: json['batchNumber'] as String,
      sku: json['sku'] as String,
      productName: json['productName'] as String,
      initialQuantity: (json['initialQuantity'] as num).toInt(),
      currentQuantity: (json['currentQuantity'] as num).toInt(),
      manufactureDate: DateTime.parse(json['manufactureDate'] as String),
      expiryDate: DateTime.parse(json['expiryDate'] as String),
      manufacturer: json['manufacturer'] as String,
      storageLocation: json['storageLocation'] as String?,
      qualityChecks: (json['qualityChecks'] as List)
          .map((check) => QualityCheck.fromJson(check))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'batchNumber': batchNumber,
      'sku': sku,
      'productName': productName,
      'initialQuantity': initialQuantity,
      'currentQuantity': currentQuantity,
      'manufactureDate': manufactureDate.toIso8601String(),
      'expiryDate': expiryDate.toIso8601String(),
      'manufacturer': manufacturer,
      'storageLocation': storageLocation,
      'qualityChecks': qualityChecks.map((check) => check.toJson()).toList(),
    };
  }

  double get utilizationRate => initialQuantity > 0 ? (currentQuantity / initialQuantity) * 100 : 0;
  
  int get daysUntilExpiry => expiryDate.difference(DateTime.now()).inDays;
  
  bool get isExpired => daysUntilExpiry < 0;
  
  bool get isExpiringSoon => daysUntilExpiry < 30 && daysUntilExpiry >= 0;
}

// Quality Check Model
class QualityCheck {
  final String id;
  final DateTime checkDate;
  final String checkedBy;
  final QualityStatus status;
  final double? temperature;
  final double? humidity;
  final String? observations;
  final bool passed;
  final List<String> testResults;

  const QualityCheck({
    required this.id,
    required this.checkDate,
    required this.checkedBy,
    required this.status,
    this.temperature,
    this.humidity,
    this.observations,
    required this.passed,
    required this.testResults,
  });

  factory QualityCheck.fromJson(Map<String, dynamic> json) {
    return QualityCheck(
      id: json['id'] as String,
      checkDate: DateTime.parse(json['checkDate'] as String),
      checkedBy: json['checkedBy'] as String,
      status: QualityStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => QualityStatus.pending,
      ),
      temperature: json['temperature'] != null ? (json['temperature'] as num).toDouble() : null,
      humidity: json['humidity'] != null ? (json['humidity'] as num).toDouble() : null,
      observations: json['observations'] as String?,
      passed: json['passed'] as bool,
      testResults: List<String>.from(json['testResults'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'checkDate': checkDate.toIso8601String(),
      'checkedBy': checkedBy,
      'status': status.toString(),
      'temperature': temperature,
      'humidity': humidity,
      'observations': observations,
      'passed': passed,
      'testResults': testResults,
    };
  }
}

// Quality Status Enum
enum QualityStatus {
  pending,
  inProgress,
  passed,
  failed,
  requiresRetest,
}

// Reorder Point Model
class ReorderPoint {
  final String id;
  final String sku;
  final String productName;
  final int reorderPoint;
  final int reorderQuantity;
  final int leadTimeDays;
  final String preferredSupplier;
  final double? unitCost;
  final DateTime lastReorderDate;
  final DateTime? nextReorderDate;
  final bool autoReorder;
  final ReorderStatus status;

  const ReorderPoint({
    required this.id,
    required this.sku,
    required this.productName,
    required this.reorderPoint,
    required this.reorderQuantity,
    required this.leadTimeDays,
    required this.preferredSupplier,
    this.unitCost,
    required this.lastReorderDate,
    this.nextReorderDate,
    required this.autoReorder,
    required this.status,
  });

  factory ReorderPoint.fromJson(Map<String, dynamic> json) {
    return ReorderPoint(
      id: json['id'] as String,
      sku: json['sku'] as String,
      productName: json['productName'] as String,
      reorderPoint: (json['reorderPoint'] as num).toInt(),
      reorderQuantity: (json['reorderQuantity'] as num).toInt(),
      leadTimeDays: (json['leadTimeDays'] as num).toInt(),
      preferredSupplier: json['preferredSupplier'] as String,
      unitCost: json['unitCost'] != null ? (json['unitCost'] as num).toDouble() : null,
      lastReorderDate: DateTime.parse(json['lastReorderDate'] as String),
      nextReorderDate: json['nextReorderDate'] != null
          ? DateTime.parse(json['nextReorderDate'] as String)
          : null,
      autoReorder: json['autoReorder'] as bool,
      status: ReorderStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => ReorderStatus.active,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sku': sku,
      'productName': productName,
      'reorderPoint': reorderPoint,
      'reorderQuantity': reorderQuantity,
      'leadTimeDays': leadTimeDays,
      'preferredSupplier': preferredSupplier,
      'unitCost': unitCost,
      'lastReorderDate': lastReorderDate.toIso8601String(),
      'nextReorderDate': nextReorderDate?.toIso8601String(),
      'autoReorder': autoReorder,
      'status': status.toString(),
    };
  }
}

// Reorder Status Enum
enum ReorderStatus {
  active,
  inactive,
  pending,
  ordered,
  received,
}
