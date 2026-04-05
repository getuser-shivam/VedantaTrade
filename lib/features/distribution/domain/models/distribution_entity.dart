import 'package:equatable/equatable.dart';

enum DistributionStatus {
  pending,
  inTransit,
  delivered,
  cancelled,
  returned,
  failed,
}

enum ShipmentStatus {
  preparing,
  shipped,
  inTransit,
  outForDelivery,
  delivered,
  failed,
  returned,
}

enum InventoryStatus {
  inStock,
  lowStock,
  outOfStock,
  onOrder,
  reserved,
}

class DistributionEntity extends Equatable {
  final String id;
  final String orderId;
  final String productId;
  final String fromWarehouseId;
  final String toWarehouseId;
  final String? carrierId;
  final String? trackingNumber;
  final DistributionStatus status;
  final ShipmentStatus shipmentStatus;
  final int quantity;
  final double unitPrice;
  final String currency;
  final DateTime? shippedAt;
  final DateTime? estimatedDeliveryAt;
  final DateTime? deliveredAt;
  final String? notes;
  final Map<String, dynamic> specifications;
  final String? batchNumber;
  final DateTime? expiryDate;
  final String? storageConditions;
  final double? shippingCost;
  final String? shippingMethod;
  final String? priority;
  final List<String> images;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DistributionEntity({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.fromWarehouseId,
    required this.toWarehouseId,
    this.carrierId,
    this.trackingNumber,
    required this.status,
    required this.shipmentStatus,
    required this.quantity,
    required this.unitPrice,
    required this.currency,
    this.shippedAt,
    this.estimatedDeliveryAt,
    this.deliveredAt,
    this.notes,
    this.specifications = const {},
    this.batchNumber,
    this.expiryDate,
    this.storageConditions,
    this.shippingCost,
    this.shippingMethod,
    this.priority,
    this.images = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  DistributionEntity copyWith({
    String? id,
    String? orderId,
    String? productId,
    String? fromWarehouseId,
    String? toWarehouseId,
    String? carrierId,
    String? trackingNumber,
    DistributionStatus? status,
    ShipmentStatus? shipmentStatus,
    int? quantity,
    double? unitPrice,
    String? currency,
    DateTime? shippedAt,
    DateTime? estimatedDeliveryAt,
    DateTime? deliveredAt,
    String? notes,
    Map<String, dynamic>? specifications,
    String? batchNumber,
    DateTime? expiryDate,
    String? storageConditions,
    double? shippingCost,
    String? shippingMethod,
    String? priority,
    List<String>? images,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DistributionEntity(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      productId: productId ?? this.productId,
      fromWarehouseId: fromWarehouseId ?? this.fromWarehouseId,
      toWarehouseId: toWarehouseId ?? this.toWarehouseId,
      carrierId: carrierId ?? this.carrierId,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      status: status ?? this.status,
      shipmentStatus: shipmentStatus ?? this.shipmentStatus,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      currency: currency ?? this.currency,
      shippedAt: shippedAt ?? this.shippedAt,
      estimatedDeliveryAt: estimatedDeliveryAt ?? this.estimatedDeliveryAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      notes: notes ?? this.notes,
      specifications: specifications ?? this.specifications,
      batchNumber: batchNumber ?? this.batchNumber,
      expiryDate: expiryDate ?? this.expiryDate,
      storageConditions: storageConditions ?? this.storageConditions,
      shippingCost: shippingCost ?? this.shippingCost,
      shippingMethod: shippingMethod ?? this.shippingMethod,
      priority: priority ?? this.priority,
      images: images ?? this.images,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        orderId,
        productId,
        fromWarehouseId,
        toWarehouseId,
        carrierId,
        trackingNumber,
        status,
        shipmentStatus,
        quantity,
        unitPrice,
        currency,
        shippedAt,
        estimatedDeliveryAt,
        deliveredAt,
        notes,
        specifications,
        batchNumber,
        expiryDate,
        storageConditions,
        shippingCost,
        shippingMethod,
        priority,
        images,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() {
    return 'DistributionEntity(id: $id, orderId: $orderId, status: $status)';
  }

  // Computed properties
  bool get isPending => status == DistributionStatus.pending;
  bool get isInTransit => status == DistributionStatus.inTransit;
  bool get isDelivered => status == DistributionStatus.delivered;
  bool get isCancelled => status == DistributionStatus.cancelled;
  bool get isFailed => status == DistributionStatus.failed;
  bool get isReturned => status == DistributionStatus.returned;
  
  bool get isShipped => shipmentStatus == ShipmentStatus.shipped;
  bool get isOutForDelivery => shipmentStatus == ShipmentStatus.outForDelivery;
  bool get isPreparing => shipmentStatus == ShipmentStatus.preparing;
  
  double get totalValue => quantity * unitPrice;
  String get formattedTotalValue => '$currency ${totalValue.toStringAsFixed(2)}';
  String get formattedUnitPrice => '$currency ${unitPrice.toStringAsFixed(2)}';
  String get statusDisplay => status.name.split('').map((word) => 
      word[0].toUpperCase() + word.substring(1)).join(' ');
  String get shipmentStatusDisplay => shipmentStatus.name.split('').map((word) => 
      word[0].toUpperCase() + word.substring(1)).join(' ');
  String get priorityDisplay => priority?.split('').map((word) => 
      word[0].toUpperCase() + word.substring(1)).join(' ') ?? 'Normal';
  
  bool get hasTracking => trackingNumber != null && trackingNumber!.isNotEmpty;
  bool get hasEstimatedDelivery => estimatedDeliveryAt != null;
  bool get isOverdue => estimatedDeliveryAt != null && 
      estimatedDeliveryAt!.isBefore(DateTime.now());
  bool get requiresExpiryTracking => expiryDate != null && 
      expiryDate!.isBefore(DateTime.now().add(const Duration(days: 30)));
  
  Duration? get deliveryTime {
    if (shippedAt != null && deliveredAt != null) {
      return deliveredAt!.difference(shippedAt!);
    }
    return null;
  }
  
  String get deliveryTimeDisplay {
    if (deliveryTime != null) {
      final days = deliveryTime!.inDays;
      final hours = deliveryTime!.inHours.remainder(24);
      if (days > 0) {
        return '${days}d ${hours}h';
      } else {
        return '${hours}h';
      }
    }
    return 'N/A';
  }
}
