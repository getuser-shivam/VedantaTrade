import 'package:equatable/equatable.dart';

/// Order entity for distribution system
/// Represents a complete order with real-time lifecycle management
class Order extends Equatable {
  final String id;
  final String orderNumber;
  final String retailerId;
  final String stockistId;
  final String mrId;
  final List<OrderItem> items;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime? approvedAt;
  final DateTime? dispatchedAt;
  final DateTime? deliveredAt;
  final DateTime? paidAt;
  final double totalAmount;
  final double discountAmount;
  final double taxAmount;
  final double finalAmount;
  final String paymentMethod;
  final String paymentStatus;
  final String? deliveryAddress;
  final String? deliveryNotes;
  final String? invoiceNumber;
  final String? trackingNumber;
  final List<String> attachments;
  final Map<String, dynamic> metadata;

  const Order({
    required this.id,
    required this.orderNumber,
    required this.retailerId,
    required this.stockistId,
    required this.mrId,
    required this.items,
    required this.status,
    required this.createdAt,
    required this.totalAmount,
    required this.paymentMethod,
    this.approvedAt,
    this.dispatchedAt,
    this.deliveredAt,
    this.paidAt,
    this.discountAmount = 0.0,
    this.taxAmount = 0.0,
    this.finalAmount,
    this.deliveryAddress,
    this.deliveryNotes,
    this.invoiceNumber,
    this.trackingNumber,
    this.attachments = const [],
    this.paymentStatus = 'pending',
    this.metadata = const {},
  });

  /// Creates Order from database record
  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'] as String,
      orderNumber: map['order_number'] as String,
      retailerId: map['retailer_id'] as String,
      stockistId: map['stockist_id'] as String,
      mrId: map['mr_id'] as String,
      items: (map['items'] as List<dynamic>)
          .map((item) => OrderItem.fromMap(item as Map<String, dynamic>))
          .toList(),
      status: OrderStatus.values.firstWhere(
        (status) => status.name == map['status'],
        orElse: () => OrderStatus.pending,
      ),
      createdAt: DateTime.parse(map['created_at'] as String),
      approvedAt: map['approved_at'] != null 
        ? DateTime.parse(map['approved_at'] as String) 
        : null,
      dispatchedAt: map['dispatched_at'] != null 
        ? DateTime.parse(map['dispatched_at'] as String) 
        : null,
      deliveredAt: map['delivered_at'] != null 
        ? DateTime.parse(map['delivered_at'] as String) 
        : null,
      paidAt: map['paid_at'] != null 
        ? DateTime.parse(map['paid_at'] as String) 
        : null,
      totalAmount: double.parse(map['total_amount'].toString()),
      discountAmount: double.parse(map['discount_amount'].toString()),
      taxAmount: double.parse(map['tax_amount'].toString()),
      finalAmount: double.parse(map['final_amount'].toString()),
      paymentMethod: map['payment_method'] as String,
      paymentStatus: map['payment_status'] as String,
      deliveryAddress: map['delivery_address'] as String?,
      deliveryNotes: map['delivery_notes'] as String?,
      invoiceNumber: map['invoice_number'] as String?,
      trackingNumber: map['tracking_number'] as String?,
      attachments: (map['attachments'] as List<dynamic>?)?.cast<String>() ?? [],
      metadata: map['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  /// Converts to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order_number': orderNumber,
      'retailer_id': retailerId,
      'stockist_id': stockistId,
      'mr_id': mrId,
      'items': items.map((item) => item.toMap()).toList(),
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
      'approved_at': approvedAt?.toIso8601String(),
      'dispatched_at': dispatchedAt?.toIso8601String(),
      'delivered_at': deliveredAt?.toIso8601String(),
      'paid_at': paidAt?.toIso8601String(),
      'total_amount': totalAmount,
      'discount_amount': discountAmount,
      'tax_amount': taxAmount,
      'final_amount': finalAmount,
      'payment_method': paymentMethod,
      'payment_status': paymentStatus,
      'delivery_address': deliveryAddress,
      'delivery_notes': deliveryNotes,
      'invoice_number': invoiceNumber,
      'tracking_number': trackingNumber,
      'attachments': attachments,
      'metadata': metadata,
    };
  }

  /// Creates copy with updated fields
  Order copyWith({
    String? id,
    String? orderNumber,
    String? retailerId,
    String? stockistId,
    String? mrId,
    List<OrderItem>? items,
    OrderStatus? status,
    DateTime? createdAt,
    DateTime? approvedAt,
    DateTime? dispatchedAt,
    DateTime? deliveredAt,
    DateTime? paidAt,
    double? totalAmount,
    double? discountAmount,
    double? taxAmount,
    double? finalAmount,
    String? paymentMethod,
    String? paymentStatus,
    String? deliveryAddress,
    String? deliveryNotes,
    String? invoiceNumber,
    String? trackingNumber,
    List<String>? attachments,
    Map<String, dynamic>? metadata,
  }) {
    return Order(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      retailerId: retailerId ?? this.retailerId,
      stockistId: stockistId ?? this.stockistId,
      mrId: mrId ?? this.mrId,
      items: items ?? this.items,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      approvedAt: approvedAt ?? this.approvedAt,
      dispatchedAt: dispatchedAt ?? this.dispatchedAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      paidAt: paidAt ?? this.paidAt,
      totalAmount: totalAmount ?? this.totalAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      taxAmount: taxAmount ?? this.taxAmount,
      finalAmount: finalAmount ?? this.finalAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      deliveryNotes: deliveryNotes ?? this.deliveryNotes,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      attachments: attachments ?? this.attachments,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Gets formatted order number
  String getFormattedOrderNumber() {
    return 'ORD-${orderNumber.padLeft(6, '0')}';
  }

  /// Gets formatted total amount
  String getFormattedTotalAmount() {
    return 'NPR ${totalAmount.toStringAsFixed(2)}';
  }

  /// Gets formatted final amount
  String getFormattedFinalAmount() {
    return 'NPR ${finalAmount.toStringAsFixed(2)}';
  }

  /// Gets formatted tax amount
  String getFormattedTaxAmount() {
    return 'NPR ${taxAmount.toStringAsFixed(2)}';
  }

  /// Gets formatted discount amount
  String getFormattedDiscountAmount() {
    return 'NPR ${discountAmount.toStringAsFixed(2)}';
  }

  /// Gets status display name
  String getStatusDisplayName() {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.approved:
        return 'Approved';
      case OrderStatus.dispatched:
        return 'Dispatched';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.paid:
        return 'Paid';
      case OrderStatus.cancelled:
        return 'Cancelled';
      case OrderStatus.returned:
        return 'Returned';
    }
  }

  /// Gets status color
  String getStatusColor() {
    switch (status) {
      case OrderStatus.pending:
        return '#FF9800';
      case OrderStatus.approved:
        return '#2196F3';
      case OrderStatus.dispatched:
        return '#1976D2';
      case OrderStatus.delivered:
        return '#4CAF50';
      case OrderStatus.paid:
        return '#4CAF50';
      case OrderStatus.cancelled:
        return '#F44336';
      case OrderStatus.returned:
        return '#FF9800';
    }
  }

  /// Gets status icon
  String getStatusIcon() {
    switch (status) {
      case OrderStatus.pending:
        return 'pending';
      case OrderStatus.approved:
        return 'check_circle';
      case OrderStatus.dispatched:
        return 'local_shipping';
      case OrderStatus.delivered:
        return 'check_circle';
      case OrderStatus.paid:
        return 'payments';
      case OrderStatus.cancelled:
        return 'cancel';
      case OrderStatus.returned:
        return 'replay';
    }
  }

  /// Checks if order can be cancelled
  bool canBeCancelled() {
    return status == OrderStatus.pending || status == OrderStatus.approved;
  }

  /// Checks if order can be approved
  bool canBeApproved() {
    return status == OrderStatus.pending;
  }

  /// Checks if order can be dispatched
  bool canBeDispatched() {
    return status == OrderStatus.approved;
  }

  /// Checks if order can be marked as delivered
  bool canBeDelivered() {
    return status == OrderStatus.dispatched;
  }

  /// Checks if order can be marked as paid
  bool canBePaid() {
    return status == OrderStatus.delivered;
  }

  /// Gets order completion percentage
  double getCompletionPercentage() {
    switch (status) {
      case OrderStatus.pending:
        return 0.0;
      case OrderStatus.approved:
        return 25.0;
      case OrderStatus.dispatched:
        return 50.0;
      case OrderStatus.delivered:
        return 75.0;
      case OrderStatus.paid:
        return 100.0;
      case OrderStatus.cancelled:
        return 0.0;
      case OrderStatus.returned:
        return 0.0;
    }
  }

  @override
  List<Object> get props => [
        id,
        orderNumber,
        retailerId,
        stockistId,
        mrId,
        items,
        status,
        createdAt,
        approvedAt,
        dispatchedAt,
        deliveredAt,
        paidAt,
        totalAmount,
        discountAmount,
        taxAmount,
        finalAmount,
        paymentMethod,
        paymentStatus,
        deliveryAddress,
        deliveryNotes,
        invoiceNumber,
        trackingNumber,
        attachments,
        metadata,
      ];

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Order && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Order(id: $id, number: $orderNumber, status: $status)';
  }
}

/// Order item entity
class OrderItem extends Equatable {
  final String id;
  final String orderId;
  final String productId;
  final String productName;
  final String sku;
  final String category;
  final String brand;
  final double unitPrice;
  final int quantity;
  final double totalPrice;
  final double discountAmount;
  final double taxAmount;
  final double finalPrice;
  final String? batchNumber;
  final DateTime? expiryDate;
  final String? manufacturer;
  final Map<String, dynamic> metadata;

  const OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.productName,
    required this.sku,
    required this.category,
    required this.brand,
    required this.unitPrice,
    required this.quantity,
    required this.totalPrice,
    required this.discountAmount,
    required this.taxAmount,
    required this.finalPrice,
    this.batchNumber,
    this.expiryDate,
    this.manufacturer,
    this.metadata = const {},
  });

  /// Creates OrderItem from database record
  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      id: map['id'] as String,
      orderId: map['order_id'] as String,
      productId: map['product_id'] as String,
      productName: map['product_name'] as String,
      sku: map['sku'] as String,
      category: map['category'] as String,
      brand: map['brand'] as String,
      unitPrice: double.parse(map['unit_price'].toString()),
      quantity: int.parse(map['quantity'].toString()),
      totalPrice: double.parse(map['total_price'].toString()),
      discountAmount: double.parse(map['discount_amount'].toString()),
      taxAmount: double.parse(map['tax_amount'].toString()),
      finalPrice: double.parse(map['final_price'].toString()),
      batchNumber: map['batch_number'] as String?,
      expiryDate: map['expiry_date'] != null 
        ? DateTime.parse(map['expiry_date'] as String) 
        : null,
      manufacturer: map['manufacturer'] as String?,
      metadata: map['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  /// Converts to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order_id': orderId,
      'product_id': productId,
      'product_name': productName,
      'sku': sku,
      'category': category,
      'brand': brand,
      'unit_price': unitPrice,
      'quantity': quantity,
      'total_price': totalPrice,
      'discount_amount': discountAmount,
      'tax_amount': taxAmount,
      'final_price': finalPrice,
      'batch_number': batchNumber,
      'expiry_date': expiryDate?.toIso8601String(),
      'manufacturer': manufacturer,
      'metadata': metadata,
    };
  }

  /// Gets formatted unit price
  String getFormattedUnitPrice() {
    return 'NPR ${unitPrice.toStringAsFixed(2)}';
  }

  /// Gets formatted total price
  String getFormattedTotalPrice() {
    return 'NPR ${totalPrice.toStringAsFixed(2)}';
  }

  /// Gets formatted final price
  String getFormattedFinalPrice() {
    return 'NPR ${finalPrice.toStringAsFixed(2)}';
  }

  /// Gets formatted discount amount
  String getFormattedDiscountAmount() {
    return 'NPR ${discountAmount.toStringAsFixed(2)}';
  }

  /// Gets formatted tax amount
  String getFormattedTaxAmount() {
    return 'NPR ${taxAmount.toStringAsFixed(2)}';
  }

  /// Checks if item is expiring soon
  bool isExpiringSoon() {
    if (expiryDate == null) return false;
    
    final daysUntilExpiry = expiryDate!.difference(DateTime.now()).inDays;
    return daysUntilExpiry <= 30; // Expiring within 30 days
  }

  /// Gets expiry status
  String getExpiryStatus() {
    if (expiryDate == null) return 'No Expiry';
    
    final daysUntilExpiry = expiryDate!.difference(DateTime.now()).inDays;
    
    if (daysUntilExpiry < 0) {
      return 'Expired';
    } else if (daysUntilExpiry <= 30) {
      return 'Expiring Soon';
    } else {
      return 'Valid';
    }
  }

  @override
  List<Object> get props => [
        id,
        orderId,
        productId,
        productName,
        sku,
        category,
        brand,
        unitPrice,
        quantity,
        totalPrice,
        discountAmount,
        taxAmount,
        finalPrice,
        batchNumber,
        expiryDate,
        manufacturer,
        metadata,
      ];

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OrderItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'OrderItem(id: $id, product: $productName, quantity: $quantity)';
  }
}

/// Order status enumeration
enum OrderStatus {
  pending,
  approved,
  dispatched,
  delivered,
  paid,
  cancelled,
  returned,
}

/// Order status extension
extension OrderStatusExtension on OrderStatus {
  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.approved:
        return 'Approved';
      case OrderStatus.dispatched:
        return 'Dispatched';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.paid:
        return 'Paid';
      case OrderStatus.cancelled:
        return 'Cancelled';
      case OrderStatus.returned:
        return 'Returned';
    }
  }

  String get color {
    switch (this) {
      case OrderStatus.pending:
        return '#FF9800';
      case OrderStatus.approved:
        return '#2196F3';
      case OrderStatus.dispatched:
        return '#1976D2';
      case OrderStatus.delivered:
        return '#4CAF50';
      case OrderStatus.paid:
        return '#4CAF50';
      case OrderStatus.cancelled:
        return '#F44336';
      case OrderStatus.returned:
        return '#FF9800';
    }
  }

  String get icon {
    switch (this) {
      case OrderStatus.pending:
        return 'pending';
      case OrderStatus.approved:
        return 'check_circle';
      case OrderStatus.dispatched:
        return 'local_shipping';
      case OrderStatus.delivered:
        return 'check_circle';
      case OrderStatus.paid:
        return 'payments';
      case OrderStatus.cancelled:
        return 'cancel';
      case OrderStatus.returned:
        return 'replay';
    }
  }
}
