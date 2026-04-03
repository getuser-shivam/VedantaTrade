import 'dart:convert';

class Distribution {
  final String id;
  final String productId;
  final String productName;
  final String distributorId;
  final String distributorName;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final DateTime distributionDate;
  final String status; // pending, in_transit, delivered, cancelled
  final String? trackingNumber;
  final String? notes;
  final DateTime? expectedDeliveryDate;
  final DateTime? actualDeliveryDate;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  Distribution({
    required this.id,
    required this.productId,
    required this.productName,
    required this.distributorId,
    required this.distributorName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.distributionDate,
    required this.status,
    this.trackingNumber,
    this.notes,
    this.expectedDeliveryDate,
    this.actualDeliveryDate,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Distribution.fromJson(Map<String, dynamic> json) {
    return Distribution(
      id: json['id'] as String,
      productId: json['product_id'] as String,
      productName: json['product_name'] as String,
      distributorId: json['distributor_id'] as String,
      distributorName: json['distributor_name'] as String,
      quantity: json['quantity'] as int,
      unitPrice: (json['unit_price'] as num).toDouble(),
      totalPrice: (json['total_price'] as num).toDouble(),
      distributionDate: DateTime.parse(json['distribution_date'] as String),
      status: json['status'] as String,
      trackingNumber: json['tracking_number'] as String?,
      notes: json['notes'] as String?,
      expectedDeliveryDate: json['expected_delivery_date'] != null 
          ? DateTime.parse(json['expected_delivery_date'] as String)
          : null,
      actualDeliveryDate: json['actual_delivery_date'] != null 
          ? DateTime.parse(json['actual_delivery_date'] as String)
          : null,
      createdBy: json['created_by'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'product_name': productName,
      'distributor_id': distributorId,
      'distributor_name': distributorName,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_price': totalPrice,
      'distribution_date': distributionDate.toIso8601String(),
      'status': status,
      'tracking_number': trackingNumber,
      'notes': notes,
      'expected_delivery_date': expectedDeliveryDate?.toIso8601String(),
      'actual_delivery_date': actualDeliveryDate?.toIso8601String(),
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Distribution copyWith({
    String? id,
    String? productId,
    String? productName,
    String? distributorId,
    String? distributorName,
    int? quantity,
    double? unitPrice,
    double? totalPrice,
    DateTime? distributionDate,
    String? status,
    String? trackingNumber,
    String? notes,
    DateTime? expectedDeliveryDate,
    DateTime? actualDeliveryDate,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Distribution(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      distributorId: distributorId ?? this.distributorId,
      distributorName: distributorName ?? this.distributorName,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
      distributionDate: distributionDate ?? this.distributionDate,
      status: status ?? this.status,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      notes: notes ?? this.notes,
      expectedDeliveryDate: expectedDeliveryDate ?? this.expectedDeliveryDate,
      actualDeliveryDate: actualDeliveryDate ?? this.actualDeliveryDate,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // UI Helper Properties
  String get statusDisplay {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'in_transit':
        return 'In Transit';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  String get formattedTotalPrice => 'NPR ${totalPrice.toStringAsFixed(2)}';
  String get formattedUnitPrice => 'NPR ${unitPrice.toStringAsFixed(2)}';
  String get formattedQuantity => quantity.toString();
  String get formattedDistributionDate => '${distributionDate.day}/${distributionDate.month}/${distributionDate.year}';
  
  bool get isDelivered => status == 'delivered';
  bool get isInTransit => status == 'in_transit';
  bool get isPending => status == 'pending';
  bool get isCancelled => status == 'cancelled';
  bool get isOverdue {
    if (expectedDeliveryDate == null || isDelivered || isCancelled) return false;
    return DateTime.now().isAfter(expectedDeliveryDate!);
  }

  // Search helpers
  String get searchableText => 
      '$productName $distributorName $trackingNumber $status'.toLowerCase();
}
