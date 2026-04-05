import 'package:equatable/equatable.dart';

enum OrderStatus {
  pending,
  confirmed,
  processing,
  shipped,
  delivered,
  cancelled,
  returned,
  refunded,
}

enum OrderType {
  regular,
  urgent,
  emergency,
  recurring,
}

enum PaymentStatus {
  pending,
  processing,
  completed,
  failed,
  refunded,
  partial,
}

enum DeliveryType {
  standard,
  express,
  overnight,
  pickup,
}

class OrderEntity extends Equatable {
  final String id;
  final String orderNumber;
  final String customerId;
  final List<OrderItem> items;
  final OrderStatus status;
  final OrderType type;
  final DeliveryType deliveryType;
  final PaymentStatus paymentStatus;
  final double subtotal;
  final double taxAmount;
  final double shippingCost;
  final double discountAmount;
  final double totalAmount;
  final String currency;
  final String? customerName;
  final String? customerEmail;
  final String? customerPhone;
  final String? billingAddress;
  final String? shippingAddress;
  final DateTime? orderDate;
  final DateTime? estimatedDeliveryDate;
  final DateTime? actualDeliveryDate;
  final String? trackingNumber;
  final String? carrierId;
  final String? notes;
  final Map<String, dynamic> specifications;
  final List<String> images;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;
  final String? approvedBy;
  final DateTime? approvedAt;
  final String? cancelledBy;
  final DateTime? cancelledAt;
  final String? deliveredBy;
  final DateTime? deliveredAt;
  final Map<String, dynamic> metadata;
  final bool isPriorityProcessing;
  final int? estimatedProcessingTime;
  final String? paymentMethod;
  final String? paymentReference;
  final DateTime? paymentDate;
  final Map<String, dynamic> paymentDetails;

  const OrderEntity({
    required this.id,
    required this.orderNumber,
    required this.customerId,
    required this.items,
    required this.status,
    required this.type,
    required this.deliveryType,
    required this.paymentStatus,
    required this.subtotal,
    required this.taxAmount,
    required this.shippingCost,
    required this.discountAmount,
    required this.totalAmount,
    required this.currency,
    required this.createdAt,
    required this.updatedAt,
    this.customerName,
    this.customerEmail,
    this.customerPhone,
    this.billingAddress,
    this.shippingAddress,
    this.orderDate,
    this.estimatedDeliveryDate,
    this.actualDeliveryDate,
    this.trackingNumber,
    this.carrierId,
    this.notes,
    this.specifications,
    this.images,
    this.createdBy,
    this.approvedBy,
    this.approvedAt,
    this.cancelledBy,
    this.cancelledAt,
    this.deliveredBy,
    this.deliveredAt,
    this.metadata,
    this.isPriorityProcessing,
    this.estimatedProcessingTime,
    this.paymentMethod,
    this.paymentReference,
    this.paymentDate,
    this.paymentDetails,
  });

  OrderEntity copyWith({
    String? id,
    String? orderNumber,
    String? customerId,
    List<OrderItem>? items,
    OrderStatus? status,
    OrderType? type,
    DeliveryType? deliveryType,
    PaymentStatus? paymentStatus,
    double? subtotal,
    double? taxAmount,
    double? shippingCost,
    double? discountAmount,
    double? totalAmount,
    String? currency,
    String? customerName,
    String? customerEmail,
    String? customerPhone,
    String? billingAddress,
    String? shippingAddress,
    DateTime? orderDate,
    DateTime? estimatedDeliveryDate,
    DateTime? actualDeliveryDate,
    String? trackingNumber,
    String? carrierId,
    String? notes,
    Map<String, dynamic>? specifications,
    List<String>? images,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? approvedBy,
    DateTime? approvedAt,
    String? cancelledBy,
    DateTime? cancelledAt,
    String? deliveredBy,
    DateTime? deliveredAt,
    Map<String, dynamic>? metadata,
    bool? isPriorityProcessing,
    int? estimatedProcessingTime,
    String? paymentMethod,
    String? paymentReference,
    DateTime? paymentDate,
    Map<String, dynamic>? paymentDetails,
  }) {
    return OrderEntity(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      customerId: customerId ?? this.customerId,
      items: items ?? this.items,
      status: status ?? this.status,
      type: type ?? this.type,
      deliveryType: deliveryType ?? this.deliveryType,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      subtotal: subtotal ?? this.subtotal,
      taxAmount: taxAmount ?? this.taxAmount,
      shippingCost: shippingCost ?? this.shippingCost,
      discountAmount: discountAmount ?? this.discountAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      currency: currency ?? this.currency,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      customerPhone: customerPhone ?? this.customerPhone,
      billingAddress: billingAddress ?? this.billingAddress,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      orderDate: orderDate ?? this.orderDate,
      estimatedDeliveryDate: estimatedDeliveryDate ?? this.estimatedDeliveryDate,
      actualDeliveryDate: actualDeliveryDate ?? this.actualDeliveryDate,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      carrierId: carrierId ?? this.carrierId,
      notes: notes ?? this.notes,
      specifications: specifications ?? this.specifications,
      images: images ?? this.images,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      approvedBy: approvedBy ?? this.approvedBy,
      approvedAt: approvedAt ?? this.approvedAt,
      cancelledBy: cancelledBy ?? this.cancelledBy,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      deliveredBy: deliveredBy ?? this.deliveredBy,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      metadata: metadata ?? this.metadata,
      isPriorityProcessing: isPriorityProcessing ?? this.isPriorityProcessing,
      estimatedProcessingTime: estimatedProcessingTime ?? this.estimatedProcessingTime,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentReference: paymentReference ?? this.paymentReference,
      paymentDate: paymentDate ?? this.paymentDate,
      paymentDetails: paymentDetails ?? this.paymentDetails,
    );
  }

  @override
  List<Object?> get props => [
        id,
        orderNumber,
        customerId,
        items,
        status,
        type,
        deliveryType,
        paymentStatus,
        subtotal,
        taxAmount,
        shippingCost,
        discountAmount,
        totalAmount,
        currency,
        customerName,
        customerEmail,
        customerPhone,
        billingAddress,
        shippingAddress,
        orderDate,
        estimatedDeliveryDate,
        actualDeliveryDate,
        trackingNumber,
        carrierId,
        notes,
        specifications,
        images,
        createdAt,
        updatedAt,
        createdBy,
        approvedBy,
        approvedAt,
        cancelledBy,
        cancelledAt,
        deliveredBy,
        deliveredAt,
        metadata,
        isPriorityProcessing,
        estimatedProcessingTime,
        paymentMethod,
        paymentReference,
        paymentDate,
        paymentDetails,
      ];

  @override
  String toString() {
    return 'OrderEntity(id: $id, orderNumber: $orderNumber, status: $status)';
  }

  // Computed properties
  bool get isPending => status == OrderStatus.pending;
  bool get isConfirmed => status == OrderStatus.confirmed;
  bool get isProcessing => status == OrderStatus.processing;
  bool get isShipped => status == OrderStatus.shipped;
  bool get isDelivered => status == OrderStatus.delivered;
  bool get isCancelled => status == OrderStatus.cancelled;
  bool get isReturned => status == OrderStatus.returned;
  bool get isRefunded => status == OrderStatus.refunded;
  bool get isCompleted => status == OrderStatus.delivered || status == OrderStatus.returned || status == OrderStatus.refunded;
  bool get isUrgent => type == OrderType.urgent;
  bool get isEmergency => type == OrderType.emergency;
  bool get isRecurring => type == OrderType.recurring;
  bool get isPaymentCompleted => paymentStatus == PaymentStatus.completed;
  bool get isPaymentPending => paymentStatus == PaymentStatus.pending;
  bool get isPaymentFailed => paymentStatus == PaymentStatus.failed;
  bool get isPriorityOrder => isPriorityProcessing || isUrgent || isEmergency;
  
  double get totalItems => items.fold(0, (sum, item) => sum + item.quantity);
  double get totalWeight => items.fold(0, (sum, item) => sum + (item.weight ?? 0));
  double get totalVolume => items.fold(0, (sum, item) => sum + (item.volume ?? 0));
  
  String get statusDisplay => status.name.split('').map((word) => 
      word[0].toUpperCase() + word.substring(1)).join(' ');
  String get typeDisplay => type.name.split('').map((word) => 
      word[0].toUpperCase() + word.substring(1)).join(' ');
  String get deliveryTypeDisplay => deliveryType.name.split('').map((word) => 
      word[0].toUpperCase() + word.substring(1)).join(' ');
  String get paymentStatusDisplay => paymentStatus.name.split('').map((word) => 
      word[0].toUpperCase() + word.substring(1)).join(' ');
  String get formattedSubtotal => '$currency ${subtotal.toStringAsFixed(2)}';
  String get formattedTaxAmount => '$currency ${taxAmount.toStringAsFixed(2)}';
  String get formattedShippingCost => '$currency ${shippingCost.toStringAsFixed(2)}';
  String get formattedDiscountAmount => '$currency ${discountAmount.toStringAsFixed(2)}';
  String get formattedTotalAmount => '$currency ${totalAmount.toStringAsFixed(2)}';
  
  Duration? getProcessingTime {
    if (orderDate != null && (isProcessing || isShipped)) {
      return DateTime.now().difference(orderDate!);
    }
    return null;
  }
  
  String get processingTimeDisplay {
    final duration = getProcessingTime;
    if (duration == null) return 'N/A';
    
    final days = duration.inDays;
    final hours = duration.inHours.remainder(24);
    final minutes = duration.inMinutes.remainder(60);
    
    if (days > 0) {
      return '${days}d ${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }
  
  bool get isOverdue => estimatedDeliveryDate != null && 
      estimatedDeliveryDate!.isBefore(DateTime.now()) && 
      !isDelivered;
  
  bool get requiresExpeditedShipping => isUrgent || isEmergency;
  bool get canBeCancelled => isPending || isConfirmed;
  bool get canBeReturned => isDelivered && !isReturned;
  bool get canBeRefunded => (isDelivered || isReturned) && !isRefunded;
  
  // Risk assessment
  double get fraudRiskScore {
    double score = 0.0;
    
    // High value orders
    if (totalAmount > 10000) score += 30;
    else if (totalAmount > 5000) score += 20;
    else if (totalAmount > 1000) score += 10;
    
    // Urgent/Emergency orders
    if (isUrgent) score += 15;
    if (isEmergency) score += 25;
    
    // New customer
    if (customerName == null || customerEmail == null) score += 20;
    
    // Unusual shipping address
    if (shippingAddress != null && shippingAddress!.length < 10) score += 15;
    
    return score;
  }
  
  String get riskLevel {
    final score = fraudRiskScore;
    if (score >= 50) return 'High';
    if (score >= 30) return 'Medium';
    if (score >= 15) return 'Low';
    return 'Minimal';
  }
  
  // Delivery estimates
  DateTime? getEstimatedDelivery {
    if (estimatedDeliveryDate != null) return estimatedDeliveryDate;
    
    // Calculate based on processing time and shipping method
    final processingTime = estimatedProcessingTime ?? const Duration(hours: 24);
    final baseTime = DateTime.now().add(processingTime);
    
    switch (deliveryType) {
      case DeliveryType.standard:
        return baseTime.add(const Duration(days: 3));
      case DeliveryType.express:
        return baseTime.add(const Duration(days: 1));
      case DeliveryType.overnight:
        return baseTime.add(const Duration(hours: 24));
      case DeliveryType.pickup:
        return baseTime.add(const Duration(hours: 2));
    }
  }
  
  // Customer communication
  List<String> getRequiredCommunications {
    final communications = <String>[];
    
    if (isPending) {
      communications.add('Order confirmation pending');
    }
    
    if (isConfirmed) {
      communications.add('Order confirmed - Processing started');
    }
    
    if (isProcessing) {
      communications.add('Order is being processed');
    }
    
    if (isShipped) {
      communications.add('Order has been shipped - Tracking: ${trackingNumber ?? 'N/A'}');
    }
    
    if (isDelivered) {
      communications.add('Order delivered successfully');
    }
    
    if (isOverdue) {
      communications.add('Order is overdue - Follow up required');
    }
    
    if (canBeReturned) {
      communications.add('Return window available');
    }
    
    return communications;
  }
}

class OrderItem extends Equatable {
  final String id;
  final String productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final String currency;
  final double? weight;
  final double? volume;
  final String? batchNumber;
  final DateTime? expiryDate;
  final String? specifications;
  final double? discountAmount;
  final double? discountPercentage;
  final Map<String, dynamic> metadata;

  const OrderItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.currency,
    this.weight,
    this.volume,
    this.batchNumber,
    this.expiryDate,
    this.specifications,
    this.discountAmount,
    this.discountPercentage,
    this.metadata = const {},
  });

  OrderItem copyWith({
    String? id,
    String? productId,
    String? productName,
    int? quantity,
    double? unitPrice,
    String? currency,
    double? weight,
    double? volume,
    String? batchNumber,
    DateTime? expiryDate,
    String? specifications,
    double? discountAmount,
    double? discountPercentage,
    Map<String, dynamic>? metadata,
  }) {
    return OrderItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      currency: currency ?? this.currency,
      weight: weight ?? this.weight,
      volume: volume ?? this.volume,
      batchNumber: batchNumber ?? this.batchNumber,
      expiryDate: expiryDate ?? this.expiryDate,
      specifications: specifications ?? this.specifications,
      discountAmount: discountAmount ?? this.discountAmount,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
        id,
        productId,
        productName,
        quantity,
        unitPrice,
        currency,
        weight,
        volume,
        batchNumber,
        expiryDate,
        specifications,
        discountAmount,
        discountPercentage,
        metadata,
      ];

  @override
  String toString() {
    return 'OrderItem(id: $id, product: $productName, qty: $quantity)';
  }

  // Computed properties
  double get totalCost => quantity * unitPrice;
  double get discountedTotalCost => discountAmount != null 
      ? (unitPrice - discountAmount!) * quantity 
      : totalCost;
  double get totalWeight => (weight ?? 0) * quantity;
  double get totalVolume => (volume ?? 0) * quantity;
  String get formattedUnitPrice => '$currency ${unitPrice.toStringAsFixed(2)}';
  String get formattedTotalCost => '$currency ${totalCost.toStringAsFixed(2)}';
  String get formattedDiscountedTotalCost => '$currency ${discountedTotalCost.toStringAsFixed(2)}';
  String get formattedTotalWeight => '${totalWeight.toStringAsFixed(2)} kg';
  String get formattedTotalVolume => '${totalVolume.toStringAsFixed(2)} m³';
  bool get hasDiscount => discountAmount != null && discountAmount! > 0;
  bool get isExpiringSoon => expiryDate != null && 
      expiryDate!.isBefore(DateTime.now().add(const Duration(days: 30)));
  bool get requiresSpecialHandling => weight != null && weight! > 10; // > 10kg requires special handling
  
  String get discountDisplay => hasDiscount 
      ? '${discountPercentage!.toStringAsFixed(1)}% OFF'
      : 'No Discount';
}
