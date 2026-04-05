import 'package:equatable/equatable.dart';

/// Inventory Entity for SKU-Level Management
/// Comprehensive inventory tracking with low-stock alerts and expiration monitoring
class Inventory extends Equatable {
  final String id;
  final String productId;
  final String sku;
  final String productName;
  final String category;
  final String brand;
  final String manufacturer;
  final String stockistId;
  final int currentStock;
  final int minStockLevel;
  final int maxStockLevel;
  final int reorderPoint;
  final double unitPrice;
  final double costPrice;
  final String? batchNumber;
  final DateTime? manufactureDate;
  final DateTime? expiryDate;
  final String? storageLocation;
  final String? warehouseLocation;
  final bool isLowStock;
  final bool isOutOfStock;
  final bool isExpiringSoon;
  final bool isExpired;
  final InventoryStatus status;
  final DateTime lastUpdated;
  final DateTime createdAt;
  final Map<String, dynamic> metadata;

  const Inventory({
    required this.id,
    required this.productId,
    required this.sku,
    required this.productName,
    required this.category,
    required this.brand,
    required this.manufacturer,
    required this.stockistId,
    required this.currentStock,
    required this.minStockLevel,
    required this.maxStockLevel,
    required this.reorderPoint,
    required this.unitPrice,
    required this.costPrice,
    this.batchNumber,
    this.manufactureDate,
    this.expiryDate,
    this.storageLocation,
    this.warehouseLocation,
    required this.isLowStock,
    required this.isOutOfStock,
    required this.isExpiringSoon,
    required this.isExpired,
    required this.status,
    required this.lastUpdated,
    required this.createdAt,
    this.metadata = const {},
  });

  /// Creates Inventory from database record
  factory Inventory.fromMap(Map<String, dynamic> map) {
    return Inventory(
      id: map['id'] as String,
      productId: map['product_id'] as String,
      sku: map['sku'] as String,
      productName: map['product_name'] as String,
      category: map['category'] as String,
      brand: map['brand'] as String,
      manufacturer: map['manufacturer'] as String,
      stockistId: map['stockist_id'] as String,
      currentStock: int.parse(map['current_stock'].toString()),
      minStockLevel: int.parse(map['min_stock_level'].toString()),
      maxStockLevel: int.parse(map['max_stock_level'].toString()),
      reorderPoint: int.parse(map['reorder_point'].toString()),
      unitPrice: double.parse(map['unit_price'].toString()),
      costPrice: double.parse(map['cost_price'].toString()),
      batchNumber: map['batch_number'] as String?,
      manufactureDate: map['manufacture_date'] != null 
        ? DateTime.parse(map['manufacture_date'] as String) 
        : null,
      expiryDate: map['expiry_date'] != null 
        ? DateTime.parse(map['expiry_date'] as String) 
        : null,
      storageLocation: map['storage_location'] as String?,
      warehouseLocation: map['warehouse_location'] as String?,
      isLowStock: map['is_low_stock'] as bool? ?? false,
      isOutOfStock: map['is_out_of_stock'] as bool? ?? false,
      isExpiringSoon: map['is_expiring_soon'] as bool? ?? false,
      isExpired: map['is_expired'] as bool? ?? false,
      status: InventoryStatus.values.firstWhere(
        (status) => status.name == map['status'],
        orElse: () => InventoryStatus.active,
      ),
      lastUpdated: DateTime.parse(map['last_updated'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
      metadata: map['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  /// Converts to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product_id': productId,
      'sku': sku,
      'product_name': productName,
      'category': category,
      'brand': brand,
      'manufacturer': manufacturer,
      'stockist_id': stockistId,
      'current_stock': currentStock,
      'min_stock_level': minStockLevel,
      'max_stock_level': maxStockLevel,
      'reorder_point': reorderPoint,
      'unit_price': unitPrice,
      'cost_price': costPrice,
      'batch_number': batchNumber,
      'manufacture_date': manufactureDate?.toIso8601String(),
      'expiry_date': expiryDate?.toIso8601String(),
      'storage_location': storageLocation,
      'warehouse_location': warehouseLocation,
      'is_low_stock': isLowStock,
      'is_out_of_stock': isOutOfStock,
      'is_expiring_soon': isExpiringSoon,
      'is_expired': isExpired,
      'status': status.name,
      'last_updated': lastUpdated.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  /// Creates copy with updated fields
  Inventory copyWith({
    String? id,
    String? productId,
    String? sku,
    String? productName,
    String? category,
    String? brand,
    String? manufacturer,
    String? stockistId,
    int? currentStock,
    int? minStockLevel,
    int? maxStockLevel,
    int? reorderPoint,
    double? unitPrice,
    double? costPrice,
    String? batchNumber,
    DateTime? manufactureDate,
    DateTime? expiryDate,
    String? storageLocation,
    String? warehouseLocation,
    bool? isLowStock,
    bool? isOutOfStock,
    bool? isExpiringSoon,
    bool? isExpired,
    InventoryStatus? status,
    DateTime? lastUpdated,
    DateTime? createdAt,
    Map<String, dynamic>? metadata,
  }) {
    return Inventory(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      sku: sku ?? this.sku,
      productName: productName ?? this.productName,
      category: category ?? this.category,
      brand: brand ?? this.brand,
      manufacturer: manufacturer ?? this.manufacturer,
      stockistId: stockistId ?? this.stockistId,
      currentStock: currentStock ?? this.currentStock,
      minStockLevel: minStockLevel ?? this.minStockLevel,
      maxStockLevel: maxStockLevel ?? this.maxStockLevel,
      reorderPoint: reorderPoint ?? this.reorderPoint,
      unitPrice: unitPrice ?? this.unitPrice,
      costPrice: costPrice ?? this.costPrice,
      batchNumber: batchNumber ?? this.batchNumber,
      manufactureDate: manufactureDate ?? this.manufactureDate,
      expiryDate: expiryDate ?? this.expiryDate,
      storageLocation: storageLocation ?? this.storageLocation,
      warehouseLocation: warehouseLocation ?? this.warehouseLocation,
      isLowStock: isLowStock ?? this.isLowStock,
      isOutOfStock: isOutOfStock ?? this.isOutOfStock,
      isExpiringSoon: isExpiringSoon ?? this.isExpiringSoon,
      isExpired: isExpired ?? this.isExpired,
      status: status ?? this.status,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      createdAt: createdAt ?? this.createdAt,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Gets formatted unit price
  String getFormattedUnitPrice() {
    return 'NPR ${unitPrice.toStringAsFixed(2)}';
  }

  /// Gets formatted cost price
  String getFormattedCostPrice() {
    return 'NPR ${costPrice.toStringAsFixed(2)}';
  }

  /// Gets formatted current stock
  String getFormattedCurrentStock() {
    return currentStock.toString();
  }

  /// Gets stock percentage
  double getStockPercentage() {
    if (maxStockLevel == 0) return 0.0;
    return (currentStock / maxStockLevel) * 100;
  }

  /// Gets formatted stock percentage
  String getFormattedStockPercentage() {
    return '${getStockPercentage().toStringAsFixed(1)}%';
  }

  /// Gets days until expiry
  int getDaysUntilExpiry() {
    if (expiryDate == null) return -1;
    return expiryDate!.difference(DateTime.now()).inDays;
  }

  /// Gets formatted expiry date
  String getFormattedExpiryDate() {
    if (expiryDate == null) return 'No Expiry';
    return '${expiryDate!.day}/${expiryDate!.month}/${expiryDate!.year}';
  }

  /// Gets expiry status
  ExpiryStatus getExpiryStatus() {
    if (expiryDate == null) return ExpiryStatus.noExpiry;
    
    final daysUntilExpiry = getDaysUntilExpiry();
    
    if (daysUntilExpiry < 0) {
      return ExpiryStatus.expired;
    } else if (daysUntilExpiry <= 30) {
      return ExpiryStatus.expiringSoon;
    } else if (daysUntilExpiry <= 60) {
      return ExpiryStatus.expiring;
    } else {
      return ExpiryStatus.valid;
    }
  }

  /// Gets stock status
  StockStatus getStockStatus() {
    if (currentStock == 0) {
      return StockStatus.outOfStock;
    } else if (currentStock <= reorderPoint) {
      return StockStatus.lowStock;
    } else if (currentStock <= minStockLevel) {
      return StockStatus.minimumStock;
    } else if (currentStock >= maxStockLevel) {
      return StockStatus.overstock;
    } else {
      return StockStatus.healthy;
    }
  }

  /// Gets stock status color
  String getStockStatusColor() {
    switch (getStockStatus()) {
      case StockStatus.outOfStock:
        return '#F44336';
      case StockStatus.lowStock:
        return '#FF9800';
      case StockStatus.minimumStock:
        return '#FFC107';
      case StockStatus.healthy:
        return '#4CAF50';
      case StockStatus.overstock:
        return '#2196F3';
    }
  }

  /// Gets expiry status color
  String getExpiryStatusColor() {
    switch (getExpiryStatus()) {
      case ExpiryStatus.expired:
        return '#F44336';
      case ExpiryStatus.expiringSoon:
        return '#FF5722';
      case ExpiryStatus.expiring:
        return '#FF9800';
      case ExpiryStatus.valid:
        return '#4CAF50';
      case ExpiryStatus.noExpiry:
        return '#9E9E9E';
    }
  }

  /// Gets total value
  double getTotalValue() {
    return currentStock * unitPrice;
  }

  /// Gets formatted total value
  String getFormattedTotalValue() {
    return 'NPR ${getTotalValue().toStringAsFixed(2)}';
  }

  /// Gets profit margin
  double getProfitMargin() {
    if (unitPrice == 0) return 0.0;
    return ((unitPrice - costPrice) / unitPrice) * 100;
  }

  /// Gets formatted profit margin
  String getFormattedProfitMargin() {
    return '${getProfitMargin().toStringAsFixed(1)}%';
  }

  /// Checks if item needs reorder
  bool needsReorder() {
    return currentStock <= reorderPoint;
  }

  /// Checks if item is overstocked
  bool isOverstocked() {
    return currentStock > maxStockLevel;
  }

  /// Gets recommended reorder quantity
  int getRecommendedReorderQuantity() {
    return maxStockLevel - currentStock;
  }

  /// Gets formatted recommended reorder quantity
  String getFormattedRecommendedReorderQuantity() {
    return getRecommendedReorderQuantity().toString();
  }

  @override
  List<Object> get props => [
        id,
        productId,
        sku,
        productName,
        category,
        brand,
        manufacturer,
        stockistId,
        currentStock,
        minStockLevel,
        maxStockLevel,
        reorderPoint,
        unitPrice,
        costPrice,
        batchNumber,
        manufactureDate,
        expiryDate,
        storageLocation,
        warehouseLocation,
        isLowStock,
        isOutOfStock,
        isExpiringSoon,
        isExpired,
        status,
        lastUpdated,
        createdAt,
        metadata,
      ];

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Inventory && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Inventory(id: $id, sku: $sku, stock: $currentStock)';
  }
}

/// Inventory status enumeration
enum InventoryStatus {
  active,
  inactive,
  discontinued,
  damaged,
  returned,
  transferred,
}

/// Inventory status extension
extension InventoryStatusExtension on InventoryStatus {
  String get displayName {
    switch (this) {
      case InventoryStatus.active:
        return 'Active';
      case InventoryStatus.inactive:
        return 'Inactive';
      case InventoryStatus.discontinued:
        return 'Discontinued';
      case InventoryStatus.damaged:
        return 'Damaged';
      case InventoryStatus.returned:
        return 'Returned';
      case InventoryStatus.transferred:
        return 'Transferred';
    }
  }

  String get color {
    switch (this) {
      case InventoryStatus.active:
        return '#4CAF50';
      case InventoryStatus.inactive:
        return '#9E9E9E';
      case InventoryStatus.discontinued:
        return '#F44336';
      case InventoryStatus.damaged:
        return '#FF5722';
      case InventoryStatus.returned:
        return '#FF9800';
      case InventoryStatus.transferred:
        return '#2196F3';
    }
  }

  String get icon {
    switch (this) {
      case InventoryStatus.active:
        return 'check_circle';
      case InventoryStatus.inactive:
        return 'pause_circle';
      case InventoryStatus.discontinued:
        return 'block';
      case InventoryStatus.damaged:
        return 'warning';
      case InventoryStatus.returned:
        return 'replay';
      case InventoryStatus.transferred:
        return 'swap_horiz';
    }
  }
}

/// Stock status enumeration
enum StockStatus {
  outOfStock,
  lowStock,
  minimumStock,
  healthy,
  overstock,
}

/// Stock status extension
extension StockStatusExtension on StockStatus {
  String get displayName {
    switch (this) {
      case StockStatus.outOfStock:
        return 'Out of Stock';
      case StockStatus.lowStock:
        return 'Low Stock';
      case StockStatus.minimumStock:
        return 'Minimum Stock';
      case StockStatus.healthy:
        return 'Healthy';
      case StockStatus.overstock:
        return 'Overstock';
    }
  }

  String get color {
    switch (this) {
      case StockStatus.outOfStock:
        return '#F44336';
      case StockStatus.lowStock:
        return '#FF9800';
      case StockStatus.minimumStock:
        return '#FFC107';
      case StockStatus.healthy:
        return '#4CAF50';
      case StockStatus.overstock:
        return '#2196F3';
    }
  }

  String get icon {
    switch (this) {
      case StockStatus.outOfStock:
        return 'remove_shopping_cart';
      case StockStatus.lowStock:
        return 'warning';
      case StockStatus.minimumStock:
        return 'priority_high';
      case StockStatus.healthy:
        return 'check_circle';
      case StockStatus.overstock:
        return 'inventory_2';
    }
  }
}

/// Expiry status enumeration
enum ExpiryStatus {
  noExpiry,
  valid,
  expiring,
  expiringSoon,
  expired,
}

/// Expiry status extension
extension ExpiryStatusExtension on ExpiryStatus {
  String get displayName {
    switch (this) {
      case ExpiryStatus.noExpiry:
        return 'No Expiry';
      case ExpiryStatus.valid:
        return 'Valid';
      case ExpiryStatus.expiring:
        return 'Expiring';
      case ExpiryStatus.expiringSoon:
        return 'Expiring Soon';
      case ExpiryStatus.expired:
        return 'Expired';
    }
  }

  String get color {
    switch (this) {
      case ExpiryStatus.noExpiry:
        return '#9E9E9E';
      case ExpiryStatus.valid:
        return '#4CAF50';
      case ExpiryStatus.expiring:
        return '#FF9800';
      case ExpiryStatus.expiringSoon:
        return '#FF5722';
      case ExpiryStatus.expired:
        return '#F44336';
    }
  }

  String get icon {
    switch (this) {
      case ExpiryStatus.noExpiry:
        return 'help';
      case ExpiryStatus.valid:
        return 'check_circle';
      case ExpiryStatus.expiring:
        return 'access_time';
      case ExpiryStatus.expiringSoon:
        return 'warning';
      case ExpiryStatus.expired:
        return 'error';
    }
  }
}
