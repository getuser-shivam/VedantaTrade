import 'package:equatable/equatable.dart';
import '../models/distribution_entity.dart';

enum InventoryStatus {
  inStock,
  lowStock,
  outOfStock,
  reserved,
  onOrder,
  damaged,
  expired,
}

enum StockMovementType {
  in,
  out,
  transfer,
  adjustment,
  return,
  damage,
  expiry,
}

class StockMovement extends Equatable {
  final String id;
  final String productId;
  final String warehouseId;
  final StockMovementType type;
  final int quantity;
  final double unitCost;
  final String currency;
  final DateTime timestamp;
  final String? reason;
  final String? referenceNumber;
  final String? performedBy;
  final String? batchNumber;
  final DateTime? expiryDate;
  final Map<String, dynamic> metadata;

  const StockMovement({
    required this.id,
    required this.productId,
    required this.warehouseId,
    required this.type,
    required this.quantity,
    required this.unitCost,
    required this.currency,
    required this.timestamp,
    this.reason,
    this.referenceNumber,
    this.performedBy,
    this.batchNumber,
    this.expiryDate,
    this.metadata = const {},
  });

  @override
  List<Object?> get props => [
        id,
        productId,
        warehouseId,
        type,
        quantity,
        unitCost,
        currency,
        timestamp,
        reason,
        referenceNumber,
        performedBy,
        batchNumber,
        expiryDate,
        metadata,
      ];
}

class InventoryEntity extends Equatable {
  final String id;
  final String productId;
  final String warehouseId;
  final String location;
  final int currentStock;
  final int reservedStock;
  final int availableStock;
  final int minimumStock;
  final int maximumStock;
  final int reorderPoint;
  final double averageCost;
  final String currency;
  final double totalValue;
  final InventoryStatus status;
  final DateTime lastStockUpdate;
  final DateTime lastMovementDate;
  final List<StockMovement> recentMovements;
  final String? batchNumber;
  final DateTime? expiryDate;
  final String? storageConditions;
  final String? storageLocation;
  final double? storageTemperature;
  final String? storageHumidity;
  final Map<String, dynamic> specifications;
  final List<String> images;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool requiresTemperatureControl;
  final bool requiresHumidityControl;
  final int daysOfStock;
  final double turnoverRate;
  final double stockoutRisk;

  const InventoryEntity({
    required this.id,
    required this.productId,
    required this.warehouseId,
    required this.location,
    required this.currentStock,
    required this.reservedStock,
    required this.availableStock,
    required this.minimumStock,
    required this.maximumStock,
    required this.reorderPoint,
    required this.averageCost,
    required this.currency,
    required this.totalValue,
    required this.status,
    required this.lastStockUpdate,
    required this.lastMovementDate,
    this.recentMovements,
    this.batchNumber,
    this.expiryDate,
    this.storageConditions,
    this.storageLocation,
    this.storageTemperature,
    this.storageHumidity,
    this.specifications,
    this.images,
    required this.createdAt,
    required this.updatedAt,
    this.requiresTemperatureControl,
    this.requiresHumidityControl,
    this.daysOfStock,
    this.turnoverRate,
    this.stockoutRisk,
  });

  @override
  List<Object?> get props => [
        id,
        productId,
        warehouseId,
        location,
        currentStock,
        reservedStock,
        availableStock,
        minimumStock,
        maximumStock,
        reorderPoint,
        averageCost,
        currency,
        totalValue,
        status,
        lastStockUpdate,
        lastMovementDate,
        recentMovements,
        batchNumber,
        expiryDate,
        storageConditions,
        storageLocation,
        storageTemperature,
        storageHumidity,
        specifications,
        images,
        createdAt,
        updatedAt,
        requiresTemperatureControl,
        requiresHumidityControl,
        daysOfStock,
        turnoverRate,
        stockoutRisk,
      ];

  @override
  String toString() {
    return 'InventoryEntity(id: $id, productId: $productId, stock: $currentStock)';
  }

  // Computed properties
  bool get isLowStock => status == InventoryStatus.lowStock;
  bool get isOutOfStock => status == InventoryStatus.outOfStock;
  bool get isOnOrder => status == InventoryStatus.onOrder;
  bool get needsReorder => availableStock <= reorderPoint;
  bool get isOverstocked => availableStock > maximumStock;
  bool get isExpiringSoon => expiryDate != null && 
      expiryDate!.isBefore(DateTime.now().add(const Duration(days: 30)));
  bool get requiresSpecialStorage => requiresTemperatureControl || requiresHumidityControl;
  double get stockUtilization => maximumStock > 0 ? (currentStock / maximumStock) * 100 : 0.0;
  String get formattedTotalValue => '$currency ${totalValue.toStringAsFixed(2)}';
  String get formattedAverageCost => '$currency ${averageCost.toStringAsFixed(2)}';
  String get statusDisplay => status.name.split('').map((word) => 
      word[0].toUpperCase() + word.substring(1)).join(' ');
  String get stockLevel => isOverstocked ? 'Overstocked' : 
      isLowStock ? 'Low Stock' : 
      isOutOfStock ? 'Out of Stock' : 
      isOnOrder ? 'On Order' : 'Normal';
  
  // Risk assessment
  double get stockoutRiskScore {
    if (isOutOfStock) return 100.0;
    if (isLowStock) return 75.0;
    if (isExpiringSoon) return 50.0;
    if (isOverstocked) return 25.0;
    return stockoutRisk;
  }
  
  String get riskLevel {
    final score = stockoutRiskScore;
    if (score >= 80) return 'Critical';
    if (score >= 60) return 'High';
    if (score >= 40) return 'Medium';
    if (score >= 20) return 'Low';
    return 'Minimal';
  }
  
  // Inventory turnover metrics
  double get inventoryTurnover => daysOfStock > 0 ? (365.0 / daysOfStock) : 0.0;
  String get turnoverPerformance => inventoryTurnover >= 12 ? 'Excellent' :
      inventoryTurnover >= 8 ? 'Good' :
      inventoryTurnover >= 4 ? 'Average' : 'Poor';
  
  // Storage compliance
  bool get isStorageCompliant {
    if (!requiresSpecialStorage) return true;
    
    if (requiresTemperatureControl && storageTemperature != null) {
      final temp = storageTemperature!;
      return temp >= 15.0 && temp <= 25.0; // Typical pharmaceutical range
    }
    
    if (requiresHumidityControl && storageHumidity != null) {
      final humidity = storageHumidity!;
      return humidity >= 30.0 && humidity <= 60.0; // Typical pharmaceutical range
    }
    
    return false;
  }
  
  String get storageComplianceStatus => isStorageCompliant ? 'Compliant' : 'Non-Compliant';
  
  // Movement analysis
  Map<String, int> get movementSummary {
    final summary = <String, int>{};
    for (final movement in recentMovements) {
      final typeKey = movement.type.name;
      summary[typeKey] = (summary[typeKey] ?? 0) + movement.quantity;
    }
    return summary;
  }
  
  int getTotalMovementType(StockMovementType type) {
    return recentMovements
        .where((m) => m.type == type)
        .fold(0, (sum, m) => sum + m.quantity);
  }
  
  // Forecasting
  int getDaysUntilOutOfStock {
    if (availableStock <= 0) return 0;
    return (availableStock / getDailyUsageRate()).floor();
  }
  
  double getDailyUsageRate {
    if (recentMovements.isEmpty) return 0.0;
    
    final totalOut = getTotalMovementType(StockMovementType.out);
    final days = DateTime.now().difference(recentMovements.first.timestamp).inDays;
    return days > 0 ? totalOut / days : 0.0;
  }
  
  // Cost analysis
  double getHoldingCost {
    return averageCost * (currentStock / 2);
  }
  
  double getCarryingCost {
    return averageCost * (reorderPoint / 2);
  }
  
  // Recommendations
  List<String> getRecommendations {
    final recommendations = <String>[];
    
    if (needsReorder) {
      recommendations.add('Reorder recommended - Stock below reorder point');
    }
    
    if (isExpiringSoon) {
      recommendations.add('Expiring products detected - Consider promotion');
    }
    
    if (isOverstocked) {
      recommendations.add('Overstocked - Consider discount or transfer');
    }
    
    if (!isStorageCompliant) {
      recommendations.add('Storage conditions not compliant - Check temperature/humidity');
    }
    
    if (turnoverRate < 4) {
      recommendations.add('Low turnover - Review ordering patterns');
    }
    
    if (stockoutRiskScore > 50) {
      recommendations.add('High stockout risk - Increase safety stock');
    }
    
    return recommendations;
  }
}
