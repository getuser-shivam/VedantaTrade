import 'package:dartz/dartz.dart';
import '../entities/inventory.dart';

/// Inventory Repository Interface
/// Handles SKU-level inventory management with low-stock alerts and expiration monitoring
abstract class InventoryRepository {
  /// Save inventory item
  Future<Either<Failure, void>> saveInventory(Inventory inventory);
  
  /// Get inventory by ID
  Future<Either<Failure, Inventory?>> getInventoryById(String id);
  
  /// Get inventory by SKU
  Future<Either<Failure, Inventory?>> getInventoryBySku(String sku);
  
  /// Get inventory by product ID
  Future<Either<Failure, List<Inventory>>> getInventoryByProductId(String productId);
  
  /// Get inventory by stockist
  Future<Either<Failure, List<Inventory>>> getInventoryByStockist({
    required String stockistId,
    InventoryStatus? status,
    int? limit,
  });
  
  /// Get inventory by category
  Future<Either<Failure, List<Inventory>>> getInventoryByCategory({
    required String category,
    String? stockistId,
    InventoryStatus? status,
    int? limit,
  });
  
  /// Get low stock items
  Future<Either<Failure, List<Inventory>>> getLowStockItems({
    String? stockistId,
    int? limit,
  });
  
  /// Get out of stock items
  Future<Either<Failure, List<Inventory>>> getOutOfStockItems({
    String? stockistId,
    int? limit,
  });
  
  /// Get expiring items
  Future<Either<Failure, List<Inventory>>> getExpiringItems({
    int? daysThreshold,
    String? stockistId,
    int? limit,
  });
  
  /// Get expired items
  Future<Either<Failure, List<Inventory>>> getExpiredItems({
    String? stockistId,
    int? limit,
  });
  
  /// Update inventory stock
  Future<Either<Failure, void>> updateInventoryStock({
    required String id,
    required int newStock,
    String? reason,
  });
  
  /// Update inventory status
  Future<Either<Failure, void>> updateInventoryStatus({
    required String id,
    required InventoryStatus status,
    String? reason,
  });
  
  /// Batch update inventory
  Future<Either<Failure, void>> batchUpdateInventory(List<Inventory> items);
  
  /// Search inventory
  Future<Either<Failure, List<Inventory>>> searchInventory({
    required String query,
    String? stockistId,
    String? category,
    InventoryStatus? status,
    int? limit,
  });
  
  /// Get inventory statistics
  Future<Either<Failure, Map<String, dynamic>>> getInventoryStatistics({
    String? stockistId,
    String? category,
    InventoryStatus? status,
  });
  
  /// Get stock alerts
  Future<Either<Failure, List<StockAlert>>> getStockAlerts({
    String? stockistId,
    StockAlertType? type,
    bool? active,
    int? limit,
  });
  
  /// Create stock alert
  Future<Either<Failure, void>> createStockAlert(StockAlert alert);
  
  /// Update stock alert
  Future<Either<Failure, void>> updateStockAlert(StockAlert alert);
  
  /// Resolve stock alert
  Future<Either<Failure, void>> resolveStockAlert(String alertId, String? resolution);
  
  /// Get inventory movements
  Future<Either<Failure, List<InventoryMovement>>> getInventoryMovements({
    String? inventoryId,
    String? stockistId,
    DateTime? startDate,
    DateTime? endDate,
    MovementType? type,
    int? limit,
  });
  
  /// Record inventory movement
  Future<Either<Failure, void>> recordInventoryMovement(InventoryMovement movement);
  
  /// Get inventory valuation
  Future<Either<Failure, Map<String, dynamic>>> getInventoryValuation({
    String? stockistId,
    String? category,
    InventoryStatus? status,
  });
  
  /// Get inventory turnover
  Future<Either<Failure, Map<String, dynamic>>> getInventoryTurnover({
    String? stockistId,
    String? category,
    DateTime? startDate,
    DateTime? endDate,
  });
  
  /// Delete inventory item
  Future<Either<Failure, void>> deleteInventory(String id);
  
  /// Archive inventory item
  Future<Either<Failure, void>> archiveInventory(String id);
  
  /// Restore inventory item
  Future<Either<Failure, void>> restoreInventory(String id);
  
  /// Get inventory history
  Future<Either<Failure, List<InventoryHistory>>> getInventoryHistory({
    required String inventoryId,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  });
  
  /// Create inventory history record
  Future<Either<Failure, void>> createInventoryHistory(InventoryHistory history);
  
  /// Get inventory recommendations
  Future<Either<Failure, List<InventoryRecommendation>>> getInventoryRecommendations({
    String? stockistId,
    RecommendationType? type,
    int? limit,
  });
  
  /// Create inventory recommendation
  Future<Either<Failure, void>> createInventoryRecommendation(InventoryRecommendation recommendation);
  
  /// Update inventory recommendation
  Future<Either<Failure, void>> updateInventoryRecommendation(InventoryRecommendation recommendation);
  
  /// Delete inventory recommendation
  Future<Either<Failure, void>> deleteInventoryRecommendation(String recommendationId);
  
  /// Get inventory reports
  Future<Either<Failure, Map<String, dynamic>>> getInventoryReports({
    required String reportType,
    String? stockistId,
    String? category,
    DateTime? startDate,
    DateTime? endDate,
  });
  
  /// Export inventory data
  Future<Either<Failure, void>> exportInventoryData({
    String? stockistId,
    String? category,
    InventoryStatus? status,
    String format,
    String? filePath,
  });
  
  /// Import inventory data
  Future<Either<Failure, void>> importInventoryData({
    required List<Map<String, dynamic>> data,
    String? stockistId,
    bool overwrite,
  });
  
  /// Sync inventory with external system
  Future<Either<Failure, void>> syncInventoryWithExternal({
    required String externalSystem,
    Map<String, dynamic>? config,
  });
  
  /// Get inventory audit trail
  Future<Either<Failure, List<InventoryAudit>>> getInventoryAuditTrail({
    String? inventoryId,
    String? stockistId,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  });
  
  /// Create inventory audit record
  Future<Either<Failure, void>> createInventoryAudit(InventoryAudit audit);
}

/// Stock Alert Entity
class StockAlert {
  final String id;
  final String inventoryId;
  final String stockistId;
  final StockAlertType type;
  final String title;
  final String message;
  final String? recommendation;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final String? resolvedBy;
  final String? resolution;
  final Map<String, dynamic> metadata;

  const StockAlert({
    required this.id,
    required this.inventoryId,
    required this.stockistId,
    required this.type,
    required this.title,
    required this.message,
    this.recommendation,
    required this.isActive,
    required this.createdAt,
    this.resolvedAt,
    this.resolvedBy,
    this.resolution,
    this.metadata = const {},
  });
}

/// Stock Alert Type enumeration
enum StockAlertType {
  lowStock,
  outOfStock,
  expiringSoon,
  expired,
  overstock,
  damaged,
  missing,
}

/// Inventory Movement Entity
class InventoryMovement {
  final String id;
  final String inventoryId;
  final String stockistId;
  final MovementType type;
  final int quantity;
  final int previousStock;
  final int newStock;
  final String? reason;
  final String? referenceId;
  final String? referenceType;
  final DateTime createdAt;
  final String? createdBy;
  final Map<String, dynamic> metadata;

  const InventoryMovement({
    required this.id,
    required this.inventoryId,
    required this.stockistId,
    required this.type,
    required this.quantity,
    required this.previousStock,
    required this.newStock,
    this.reason,
    this.referenceId,
    this.referenceType,
    required this.createdAt,
    this.createdBy,
    this.metadata = const {},
  });
}

/// Movement Type enumeration
enum MovementType {
  stockIn,
  stockOut,
  adjustment,
  transfer,
  return,
  damage,
  loss,
}

/// Inventory History Entity
class InventoryHistory {
  final String id;
  final String inventoryId;
  final String field;
  final String oldValue;
  final String newValue;
  final String? reason;
  final DateTime createdAt;
  final String? changedBy;
  final Map<String, dynamic> metadata;

  const InventoryHistory({
    required this.id,
    required this.inventoryId,
    required this.field,
    required this.oldValue,
    required this.newValue,
    this.reason,
    required this.createdAt,
    this.changedBy,
    this.metadata = const {},
  });
}

/// Inventory Recommendation Entity
class InventoryRecommendation {
  final String id;
  final String inventoryId;
  final String stockistId;
  final RecommendationType type;
  final String title;
  final String description;
  final int? recommendedQuantity;
  final String? recommendedAction;
  final int? priority;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final DateTime? actionedAt;
  final String? actionedBy;
  final Map<String, dynamic> metadata;

  const InventoryRecommendation({
    required this.id,
    required this.inventoryId,
    required this.stockistId,
    required this.type,
    required this.title,
    required this.description,
    this.recommendedQuantity,
    this.recommendedAction,
    this.priority,
    required this.isActive,
    required this.createdAt,
    this.expiresAt,
    this.actionedAt,
    this.actionedBy,
    this.metadata = const {},
  });
}

/// Recommendation Type enumeration
enum RecommendationType {
  reorder,
  priceAdjustment,
  promotion,
  clearance,
  transfer,
  qualityCheck,
}

/// Inventory Audit Entity
class InventoryAudit {
  final String id;
  final String inventoryId;
  final String stockistId;
  final AuditType type;
  final String description;
  final String? details;
  final DateTime createdAt;
  final String? auditedBy;
  final Map<String, dynamic> metadata;

  const InventoryAudit({
    required this.id,
    required this.inventoryId,
    required this.stockistId,
    required this.type,
    required this.description,
    this.details,
    required this.createdAt,
    this.auditedBy,
    this.metadata = const {},
  });
}

/// Audit Type enumeration
enum AuditType {
  stockCount,
  qualityCheck,
  expiryCheck,
  movementVerification,
  compliance,
  investigation,
}
