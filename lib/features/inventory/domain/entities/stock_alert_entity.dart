import 'package:equatable/equatable.dart';

/// Stock Alert Entity for VedantaTrade
/// Represents real-time stock level alerts and notifications

class StockAlertEntity extends Equatable {
  final String id;
  final String productId;
  final String productName;
  final String productSku;
  final String productCategory;
  final String warehouseId;
  final String warehouseName;
  final StockAlertType alertType;
  final StockAlertSeverity severity;
  final double currentStock;
  final double minThreshold;
  final double maxThreshold;
  final double reorderLevel;
  final double reorderQuantity;
  final String? supplierId;
  final String? supplierName;
  final String? batchNumber;
  final DateTime? expiryDate;
  final int daysToExpiry;
  final String message;
  final String? description;
  final bool isAcknowledged;
  final String? acknowledgedBy;
  final DateTime? acknowledgedAt;
  final bool isResolved;
  final String? resolvedBy;
  final DateTime? resolvedAt;
  final String? resolutionNotes;
  final List<StockAlertAction> actions;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const StockAlertEntity({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productSku,
    required this.productCategory,
    required this.warehouseId,
    required this.warehouseName,
    required this.alertType,
    required this.severity,
    required this.currentStock,
    required this.minThreshold,
    required this.maxThreshold,
    required this.reorderLevel,
    required this.reorderQuantity,
    this.supplierId,
    this.supplierName,
    this.batchNumber,
    this.expiryDate,
    required this.daysToExpiry,
    required this.message,
    this.description,
    required this.isAcknowledged,
    this.acknowledgedBy,
    this.acknowledgedAt,
    required this.isResolved,
    this.resolvedBy,
    this.resolvedAt,
    this.resolutionNotes,
    required this.actions,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        productId,
        productName,
        productSku,
        productCategory,
        warehouseId,
        warehouseName,
        alertType,
        severity,
        currentStock,
        minThreshold,
        maxThreshold,
        reorderLevel,
        reorderQuantity,
        supplierId,
        supplierName,
        batchNumber,
        expiryDate,
        daysToExpiry,
        message,
        description,
        isAcknowledged,
        acknowledgedBy,
        acknowledgedAt,
        isResolved,
        resolvedBy,
        resolvedAt,
        resolutionNotes,
        actions,
        metadata,
        createdAt,
        updatedAt,
      ];

  StockAlertEntity copyWith({
    String? id,
    String? productId,
    String? productName,
    String? productSku,
    String? productCategory,
    String? warehouseId,
    String? warehouseName,
    StockAlertType? alertType,
    StockAlertSeverity? severity,
    double? currentStock,
    double? minThreshold,
    double? maxThreshold,
    double? reorderLevel,
    double? reorderQuantity,
    String? supplierId,
    String? supplierName,
    String? batchNumber,
    DateTime? expiryDate,
    int? daysToExpiry,
    String? message,
    String? description,
    bool? isAcknowledged,
    String? acknowledgedBy,
    DateTime? acknowledgedAt,
    bool? isResolved,
    String? resolvedBy,
    DateTime? resolvedAt,
    String? resolutionNotes,
    List<StockAlertAction>? actions,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StockAlertEntity(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productSku: productSku ?? this.productSku,
      productCategory: productCategory ?? this.productCategory,
      warehouseId: warehouseId ?? this.warehouseId,
      warehouseName: warehouseName ?? this.warehouseName,
      alertType: alertType ?? this.alertType,
      severity: severity ?? this.severity,
      currentStock: currentStock ?? this.currentStock,
      minThreshold: minThreshold ?? this.minThreshold,
      maxThreshold: maxThreshold ?? this.maxThreshold,
      reorderLevel: reorderLevel ?? this.reorderLevel,
      reorderQuantity: reorderQuantity ?? this.reorderQuantity,
      supplierId: supplierId ?? this.supplierId,
      supplierName: supplierName ?? this.supplierName,
      batchNumber: batchNumber ?? this.batchNumber,
      expiryDate: expiryDate ?? this.expiryDate,
      daysToExpiry: daysToExpiry ?? this.daysToExpiry,
      message: message ?? this.message,
      description: description ?? this.description,
      isAcknowledged: isAcknowledged ?? this.isAcknowledged,
      acknowledgedBy: acknowledgedBy ?? this.acknowledgedBy,
      acknowledgedAt: acknowledgedAt ?? this.acknowledgedAt,
      isResolved: isResolved ?? this.isResolved,
      resolvedBy: resolvedBy ?? this.resolvedBy,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      resolutionNotes: resolutionNotes ?? this.resolutionNotes,
      actions: actions ?? this.actions,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'productSku': productSku,
      'productCategory': productCategory,
      'warehouseId': warehouseId,
      'warehouseName': warehouseName,
      'alertType': alertType.name,
      'severity': severity.name,
      'currentStock': currentStock,
      'minThreshold': minThreshold,
      'maxThreshold': maxThreshold,
      'reorderLevel': reorderLevel,
      'reorderQuantity': reorderQuantity,
      'supplierId': supplierId,
      'supplierName': supplierName,
      'batchNumber': batchNumber,
      'expiryDate': expiryDate?.toIso8601String(),
      'daysToExpiry': daysToExpiry,
      'message': message,
      'description': description,
      'isAcknowledged': isAcknowledged,
      'acknowledgedBy': acknowledgedBy,
      'acknowledgedAt': acknowledgedAt?.toIso8601String(),
      'isResolved': isResolved,
      'resolvedBy': resolvedBy,
      'resolvedAt': resolvedAt?.toIso8601String(),
      'resolutionNotes': resolutionNotes,
      'actions': actions.map((action) => action.toMap()).toList(),
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory StockAlertEntity.fromMap(Map<String, dynamic> map) {
    return StockAlertEntity(
      id: map['id'] ?? '',
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      productSku: map['productSku'] ?? '',
      productCategory: map['productCategory'] ?? '',
      warehouseId: map['warehouseId'] ?? '',
      warehouseName: map['warehouseName'] ?? '',
      alertType: StockAlertType.values.firstWhere(
        (type) => type.name == map['alertType'],
        orElse: () => StockAlertType.lowStock,
      ),
      severity: StockAlertSeverity.values.firstWhere(
        (severity) => severity.name == map['severity'],
        orElse: () => StockAlertSeverity.medium,
      ),
      currentStock: (map['currentStock'] ?? 0.0).toDouble(),
      minThreshold: (map['minThreshold'] ?? 0.0).toDouble(),
      maxThreshold: (map['maxThreshold'] ?? 0.0).toDouble(),
      reorderLevel: (map['reorderLevel'] ?? 0.0).toDouble(),
      reorderQuantity: (map['reorderQuantity'] ?? 0.0).toDouble(),
      supplierId: map['supplierId'],
      supplierName: map['supplierName'],
      batchNumber: map['batchNumber'],
      expiryDate: map['expiryDate'] != null
          ? DateTime.parse(map['expiryDate'])
          : null,
      daysToExpiry: map['daysToExpiry'] ?? 0,
      message: map['message'] ?? '',
      description: map['description'],
      isAcknowledged: map['isAcknowledged'] ?? false,
      acknowledgedBy: map['acknowledgedBy'],
      acknowledgedAt: map['acknowledgedAt'] != null
          ? DateTime.parse(map['acknowledgedAt'])
          : null,
      isResolved: map['isResolved'] ?? false,
      resolvedBy: map['resolvedBy'],
      resolvedAt: map['resolvedAt'] != null
          ? DateTime.parse(map['resolvedAt'])
          : null,
      resolutionNotes: map['resolutionNotes'],
      actions: (map['actions'] as List<dynamic>?)
              ?.map((action) => StockAlertAction.fromMap(action))
              .toList() ??
          [],
      metadata: map['metadata'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }
}

/// Stock Alert Type Enum
enum StockAlertType {
  lowStock,
  outOfStock,
  overstock,
  expiryAlert,
  reorderPoint,
  stockMovement,
  qualityIssue,
  demandSpike,
  slowMoving,
  batchExpiry,
  temperatureAlert,
  humidityAlert,
  securityAlert,
}

/// Stock Alert Severity Enum
enum StockAlertSeverity {
  critical,
  high,
  medium,
  low,
  info,
}

/// Stock Alert Action Entity
class StockAlertAction extends Equatable {
  final String id;
  final String alertId;
  final StockAlertActionType actionType;
  final String description;
  final String? userId;
  final String? userName;
  final Map<String, dynamic>? parameters;
  final bool isCompleted;
  final DateTime? completedAt;
  final String? result;
  final String? notes;
  final DateTime createdAt;

  const StockAlertAction({
    required this.id,
    required this.alertId,
    required this.actionType,
    required this.description,
    this.userId,
    this.userName,
    this.parameters,
    required this.isCompleted,
    this.completedAt,
    this.result,
    this.notes,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        alertId,
        actionType,
        description,
        userId,
        userName,
        parameters,
        isCompleted,
        completedAt,
        result,
        notes,
        createdAt,
      ];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'alertId': alertId,
      'actionType': actionType.name,
      'description': description,
      'userId': userId,
      'userName': userName,
      'parameters': parameters,
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
      'result': result,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory StockAlertAction.fromMap(Map<String, dynamic> map) {
    return StockAlertAction(
      id: map['id'] ?? '',
      alertId: map['alertId'] ?? '',
      actionType: StockAlertActionType.values.firstWhere(
        (type) => type.name == map['actionType'],
        orElse: () => StockAlertActionType.notify,
      ),
      description: map['description'] ?? '',
      userId: map['userId'],
      userName: map['userName'],
      parameters: map['parameters'],
      isCompleted: map['isCompleted'] ?? false,
      completedAt: map['completedAt'] != null
          ? DateTime.parse(map['completedAt'])
          : null,
      result: map['result'],
      notes: map['notes'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}

/// Stock Alert Action Type Enum
enum StockAlertActionType {
  notify,
  acknowledge,
  resolve,
  reorder,
  transfer,
  adjust,
  investigate,
  escalate,
  document,
  qualityCheck,
  dispose,
  recall,
}

/// Stock Monitoring Configuration Entity
class StockMonitoringConfig extends Equatable {
  final String id;
  final String productId;
  final String warehouseId;
  final bool isEnabled;
  final double minThreshold;
  final double maxThreshold;
  final double reorderLevel;
  final double reorderQuantity;
  final int expiryWarningDays;
  final bool enableLowStockAlerts;
  final bool enableOverstockAlerts;
  final bool enableExpiryAlerts;
  final bool enableMovementAlerts;
  final bool enableQualityAlerts;
  final List<String> notificationEmails;
  final List<String> notificationPhones;
  final String alertFrequency;
  final Map<String, dynamic>? customRules;
  final DateTime createdAt;
  final DateTime updatedAt;

  const StockMonitoringConfig({
    required this.id,
    required this.productId,
    required this.warehouseId,
    required this.isEnabled,
    required this.minThreshold,
    required this.maxThreshold,
    required this.reorderLevel,
    required this.reorderQuantity,
    required this.expiryWarningDays,
    required this.enableLowStockAlerts,
    required this.enableOverstockAlerts,
    required this.enableExpiryAlerts,
    required this.enableMovementAlerts,
    required this.enableQualityAlerts,
    required this.notificationEmails,
    required this.notificationPhones,
    required this.alertFrequency,
    this.customRules,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        productId,
        warehouseId,
        isEnabled,
        minThreshold,
        maxThreshold,
        reorderLevel,
        reorderQuantity,
        expiryWarningDays,
        enableLowStockAlerts,
        enableOverstockAlerts,
        enableExpiryAlerts,
        enableMovementAlerts,
        enableQualityAlerts,
        notificationEmails,
        notificationPhones,
        alertFrequency,
        customRules,
        createdAt,
        updatedAt,
      ];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'warehouseId': warehouseId,
      'isEnabled': isEnabled,
      'minThreshold': minThreshold,
      'maxThreshold': maxThreshold,
      'reorderLevel': reorderLevel,
      'reorderQuantity': reorderQuantity,
      'expiryWarningDays': expiryWarningDays,
      'enableLowStockAlerts': enableLowStockAlerts,
      'enableOverstockAlerts': enableOverstockAlerts,
      'enableExpiryAlerts': enableExpiryAlerts,
      'enableMovementAlerts': enableMovementAlerts,
      'enableQualityAlerts': enableQualityAlerts,
      'notificationEmails': notificationEmails,
      'notificationPhones': notificationPhones,
      'alertFrequency': alertFrequency,
      'customRules': customRules,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory StockMonitoringConfig.fromMap(Map<String, dynamic> map) {
    return StockMonitoringConfig(
      id: map['id'] ?? '',
      productId: map['productId'] ?? '',
      warehouseId: map['warehouseId'] ?? '',
      isEnabled: map['isEnabled'] ?? true,
      minThreshold: (map['minThreshold'] ?? 0.0).toDouble(),
      maxThreshold: (map['maxThreshold'] ?? 0.0).toDouble(),
      reorderLevel: (map['reorderLevel'] ?? 0.0).toDouble(),
      reorderQuantity: (map['reorderQuantity'] ?? 0.0).toDouble(),
      expiryWarningDays: map['expiryWarningDays'] ?? 30,
      enableLowStockAlerts: map['enableLowStockAlerts'] ?? true,
      enableOverstockAlerts: map['enableOverstockAlerts'] ?? true,
      enableExpiryAlerts: map['enableExpiryAlerts'] ?? true,
      enableMovementAlerts: map['enableMovementAlerts'] ?? false,
      enableQualityAlerts: map['enableQualityAlerts'] ?? false,
      notificationEmails: List<String>.from(map['notificationEmails'] ?? []),
      notificationPhones: List<String>.from(map['notificationPhones'] ?? []),
      alertFrequency: map['alertFrequency'] ?? 'immediate',
      customRules: map['customRules'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }
}

/// Stock Level History Entity
class StockLevelHistory extends Equatable {
  final String id;
  final String productId;
  final String warehouseId;
  final double previousStock;
  final double newStock;
  final double changeAmount;
  final StockChangeType changeType;
  final String? referenceId;
  final String? referenceType;
  final String? reason;
  final String? userId;
  final String? userName;
  final Map<String, dynamic>? metadata;
  final DateTime timestamp;

  const StockLevelHistory({
    required this.id,
    required this.productId,
    required this.warehouseId,
    required this.previousStock,
    required this.newStock,
    required this.changeAmount,
    required this.changeType,
    this.referenceId,
    this.referenceType,
    this.reason,
    this.userId,
    this.userName,
    this.metadata,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [
        id,
        productId,
        warehouseId,
        previousStock,
        newStock,
        changeAmount,
        changeType,
        referenceId,
        referenceType,
        reason,
        userId,
        userName,
        metadata,
        timestamp,
      ];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'warehouseId': warehouseId,
      'previousStock': previousStock,
      'newStock': newStock,
      'changeAmount': changeAmount,
      'changeType': changeType.name,
      'referenceId': referenceId,
      'referenceType': referenceType,
      'reason': reason,
      'userId': userId,
      'userName': userName,
      'metadata': metadata,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory StockLevelHistory.fromMap(Map<String, dynamic> map) {
    return StockLevelHistory(
      id: map['id'] ?? '',
      productId: map['productId'] ?? '',
      warehouseId: map['warehouseId'] ?? '',
      previousStock: (map['previousStock'] ?? 0.0).toDouble(),
      newStock: (map['newStock'] ?? 0.0).toDouble(),
      changeAmount: (map['changeAmount'] ?? 0.0).toDouble(),
      changeType: StockChangeType.values.firstWhere(
        (type) => type.name == map['changeType'],
        orElse: () => StockChangeType.adjustment,
      ),
      referenceId: map['referenceId'],
      referenceType: map['referenceType'],
      reason: map['reason'],
      userId: map['userId'],
      userName: map['userName'],
      metadata: map['metadata'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}

/// Stock Change Type Enum
enum StockChangeType {
  purchase,
  sale,
  transfer,
  adjustment,
  return,
  damage,
  expiry,
  recall,
  manufacture,
  disposal,
  audit,
}
