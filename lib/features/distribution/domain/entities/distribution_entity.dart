import 'package:equatable/equatable.dart';

class DistributionEntity extends Equatable {
  final String id;
  final String productId;
  final String productName;
  final String distributorId;
  final String distributorName;
  final String retailerId;
  final String retailerName;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final String status; // pending, shipped, delivered, cancelled
  final DateTime orderDate;
  final DateTime? expectedDeliveryDate;
  final DateTime? actualDeliveryDate;
  final String trackingNumber;
  final String? notes;
  final double? discountAmount;
  final double? taxAmount;
  final String paymentStatus; // pending, paid, partially_paid, overdue
  final DateTime? paymentDueDate;
  final String? warehouseId;
  final String? warehouseName;
  final List<DistributionItemEntity> items;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DistributionEntity({
    required this.id,
    required this.productId,
    required this.productName,
    required this.distributorId,
    required this.distributorName,
    required this.retailerId,
    required this.retailerName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.status,
    required this.orderDate,
    this.expectedDeliveryDate,
    this.actualDeliveryDate,
    required this.trackingNumber,
    this.notes,
    this.discountAmount,
    this.taxAmount,
    required this.paymentStatus,
    this.paymentDueDate,
    this.warehouseId,
    this.warehouseName,
    required this.items,
    required this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        productId,
        productName,
        distributorId,
        distributorName,
        retailerId,
        retailerName,
        quantity,
        unitPrice,
        totalPrice,
        status,
        orderDate,
        expectedDeliveryDate,
        actualDeliveryDate,
        trackingNumber,
        notes,
        discountAmount,
        taxAmount,
        paymentStatus,
        paymentDueDate,
        warehouseId,
        warehouseName,
        items,
        metadata,
        createdAt,
        updatedAt,
      ];

  // Computed properties
  bool get isPending => status == 'pending';
  bool get isShipped => status == 'shipped';
  bool get isDelivered => status == 'delivered';
  bool get isCancelled => status == 'cancelled';
  bool get isOverdue => paymentDueDate != null && DateTime.now().isAfter(paymentDueDate!);
  bool get isPaid => paymentStatus == 'paid';
  bool get isPartiallyPaid => paymentStatus == 'partially_paid';

  double get finalPrice => totalPrice - (discountAmount ?? 0) + (taxAmount ?? 0);

  int get daysUntilDelivery {
    if (expectedDeliveryDate == null) return -1;
    return expectedDeliveryDate!.difference(DateTime.now()).inDays;
  }

  String get statusDisplay {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'shipped':
        return 'Shipped';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  String get paymentStatusDisplay {
    switch (paymentStatus) {
      case 'pending':
        return 'Pending';
      case 'paid':
        return 'Paid';
      case 'partially_paid':
        return 'Partially Paid';
      case 'overdue':
        return 'Overdue';
      default:
        return 'Unknown';
    }
  }

  DistributionEntity copyWith({
    String? id,
    String? productId,
    String? productName,
    String? distributorId,
    String? distributorName,
    String? retailerId,
    String? retailerName,
    int? quantity,
    double? unitPrice,
    double? totalPrice,
    String? status,
    DateTime? orderDate,
    DateTime? expectedDeliveryDate,
    DateTime? actualDeliveryDate,
    String? trackingNumber,
    String? notes,
    double? discountAmount,
    double? taxAmount,
    String? paymentStatus,
    DateTime? paymentDueDate,
    String? warehouseId,
    String? warehouseName,
    List<DistributionItemEntity>? items,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DistributionEntity(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      distributorId: distributorId ?? this.distributorId,
      distributorName: distributorName ?? this.distributorName,
      retailerId: retailerId ?? this.retailerId,
      retailerName: retailerName ?? this.retailerName,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      orderDate: orderDate ?? this.orderDate,
      expectedDeliveryDate: expectedDeliveryDate ?? this.expectedDeliveryDate,
      actualDeliveryDate: actualDeliveryDate ?? this.actualDeliveryDate,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      notes: notes ?? this.notes,
      discountAmount: discountAmount ?? this.discountAmount,
      taxAmount: taxAmount ?? this.taxAmount,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentDueDate: paymentDueDate ?? this.paymentDueDate,
      warehouseId: warehouseId ?? this.warehouseId,
      warehouseName: warehouseName ?? this.warehouseName,
      items: items ?? this.items,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'product_name': productName,
      'distributor_id': distributorId,
      'distributor_name': distributorName,
      'retailer_id': retailerId,
      'retailer_name': retailerName,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_price': totalPrice,
      'status': status,
      'order_date': orderDate.toIso8601String(),
      'expected_delivery_date': expectedDeliveryDate?.toIso8601String(),
      'actual_delivery_date': actualDeliveryDate?.toIso8601String(),
      'tracking_number': trackingNumber,
      'notes': notes,
      'discount_amount': discountAmount,
      'tax_amount': taxAmount,
      'payment_status': paymentStatus,
      'payment_due_date': paymentDueDate?.toIso8601String(),
      'warehouse_id': warehouseId,
      'warehouse_name': warehouseName,
      'items': items.map((item) => item.toJson()).toList(),
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory DistributionEntity.fromJson(Map<String, dynamic> json) {
    return DistributionEntity(
      id: json['id'] ?? '',
      productId: json['product_id'] ?? json['productId'] ?? '',
      productName: json['product_name'] ?? json['productName'] ?? '',
      distributorId: json['distributor_id'] ?? json['distributorId'] ?? '',
      distributorName: json['distributor_name'] ?? json['distributorName'] ?? '',
      retailerId: json['retailer_id'] ?? json['retailerId'] ?? '',
      retailerName: json['retailer_name'] ?? json['retailerName'] ?? '',
      quantity: json['quantity'] ?? 0,
      unitPrice: (json['unit_price'] ?? json['unitPrice'] ?? 0).toDouble(),
      totalPrice: (json['total_price'] ?? json['totalPrice'] ?? 0).toDouble(),
      status: json['status'] ?? 'pending',
      orderDate: DateTime.parse(json['order_date'] ?? json['orderDate']),
      expectedDeliveryDate: json['expected_delivery_date'] != null 
          ? DateTime.parse(json['expected_delivery_date'])
          : json['expectedDeliveryDate'] != null
              ? DateTime.parse(json['expectedDeliveryDate'])
              : null,
      actualDeliveryDate: json['actual_delivery_date'] != null
          ? DateTime.parse(json['actual_delivery_date'])
          : json['actualDeliveryDate'] != null
              ? DateTime.parse(json['actualDeliveryDate'])
              : null,
      trackingNumber: json['tracking_number'] ?? json['trackingNumber'] ?? '',
      notes: json['notes'],
      discountAmount: json['discount_amount']?.toDouble() ?? json['discountAmount']?.toDouble(),
      taxAmount: json['tax_amount']?.toDouble() ?? json['taxAmount']?.toDouble(),
      paymentStatus: json['payment_status'] ?? json['paymentStatus'] ?? 'pending',
      paymentDueDate: json['payment_due_date'] != null
          ? DateTime.parse(json['payment_due_date'])
          : json['paymentDueDate'] != null
              ? DateTime.parse(json['paymentDueDate'])
              : null,
      warehouseId: json['warehouse_id'] ?? json['warehouseId'],
      warehouseName: json['warehouse_name'] ?? json['warehouseName'],
      items: (json['items'] as List<dynamic>?)
          ?.map((item) => DistributionItemEntity.fromJson(item))
          .toList() ?? [],
      metadata: json['metadata'] ?? {},
      createdAt: DateTime.parse(json['created_at'] ?? json['createdAt']),
      updatedAt: DateTime.parse(json['updated_at'] ?? json['updatedAt']),
    );
  }
}

class DistributionItemEntity extends Equatable {
  final String id;
  final String distributionId;
  final String productId;
  final String productName;
  final String sku;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final double? discountAmount;
  final String? batchNumber;
  final DateTime? expiryDate;
  final String? warehouseLocation;
  final Map<String, dynamic> metadata;

  const DistributionItemEntity({
    required this.id,
    required this.distributionId,
    required this.productId,
    required this.productName,
    required this.sku,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.discountAmount,
    this.batchNumber,
    this.expiryDate,
    this.warehouseLocation,
    required this.metadata,
  });

  @override
  List<Object?> get props => [
        id,
        distributionId,
        productId,
        productName,
        sku,
        quantity,
        unitPrice,
        totalPrice,
        discountAmount,
        batchNumber,
        expiryDate,
        warehouseLocation,
        metadata,
      ];

  double get finalPrice => totalPrice - (discountAmount ?? 0);

  bool get isExpiringSoon {
    if (expiryDate == null) return false;
    final daysUntilExpiry = expiryDate!.difference(DateTime.now()).inDays;
    return daysUntilExpiry <= 30; // 30 days before expiry
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'distribution_id': distributionId,
      'product_id': productId,
      'product_name': productName,
      'sku': sku,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_price': totalPrice,
      'discount_amount': discountAmount,
      'batch_number': batchNumber,
      'expiry_date': expiryDate?.toIso8601String(),
      'warehouse_location': warehouseLocation,
      'metadata': metadata,
    };
  }

  factory DistributionItemEntity.fromJson(Map<String, dynamic> json) {
    return DistributionItemEntity(
      id: json['id'] ?? '',
      distributionId: json['distribution_id'] ?? json['distributionId'] ?? '',
      productId: json['product_id'] ?? json['productId'] ?? '',
      productName: json['product_name'] ?? json['productName'] ?? '',
      sku: json['sku'] ?? '',
      quantity: json['quantity'] ?? 0,
      unitPrice: (json['unit_price'] ?? json['unitPrice'] ?? 0).toDouble(),
      totalPrice: (json['total_price'] ?? json['totalPrice'] ?? 0).toDouble(),
      discountAmount: json['discount_amount']?.toDouble() ?? json['discountAmount']?.toDouble(),
      batchNumber: json['batch_number'] ?? json['batchNumber'],
      expiryDate: json['expiry_date'] != null
          ? DateTime.parse(json['expiry_date'])
          : json['expiryDate'] != null
              ? DateTime.parse(json['expiryDate'])
              : null,
      warehouseLocation: json['warehouse_location'] ?? json['warehouseLocation'],
      metadata: json['metadata'] ?? {},
    );
  }
}
