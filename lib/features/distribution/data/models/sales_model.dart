import 'package:equatable/equatable.dart';

class SalesOrder extends Equatable {
  final String id;
  final String orderNumber;
  final String customerId;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final List<SalesOrderItem> items;
  final double totalAmount;
  final double discountAmount;
  final double taxAmount;
  final double finalAmount;
  final String status; // pending, confirmed, processing, shipped, delivered, cancelled
  final String paymentStatus; // pending, paid, failed, refunded
  final String paymentMethod;
  final DateTime orderDate;
  final DateTime? expectedDeliveryDate;
  final DateTime? actualDeliveryDate;
  final String shippingAddress;
  final String billingAddress;
  final String? notes;
  final String? salesRepresentativeId;
  final String salesRepresentativeName;
  final String distributionChannel; // retail, wholesale, online, hospital
  final String? promotionCode;
  final double? promotionDiscount;
  final String deliveryMethod; // standard, express, pickup
  final double deliveryCost;
  final bool isUrgent;
  final String? priority;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SalesOrder({
    required this.id,
    required this.orderNumber,
    required this.customerId,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.items,
    required this.totalAmount,
    required this.discountAmount,
    required this.taxAmount,
    required this.finalAmount,
    required this.status,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.orderDate,
    this.expectedDeliveryDate,
    this.actualDeliveryDate,
    required this.shippingAddress,
    required this.billingAddress,
    this.notes,
    this.salesRepresentativeId,
    required this.salesRepresentativeName,
    required this.distributionChannel,
    this.promotionCode,
    this.promotionDiscount,
    required this.deliveryMethod,
    required this.deliveryCost,
    this.isUrgent = false,
    this.priority,
    this.tags = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory SalesOrder.fromJson(Map<String, dynamic> json) {
    return SalesOrder(
      id: json['id'] ?? '',
      orderNumber: json['orderNumber'] ?? '',
      customerId: json['customerId'] ?? '',
      customerName: json['customerName'] ?? '',
      customerEmail: json['customerEmail'] ?? '',
      customerPhone: json['customerPhone'] ?? '',
      items: (json['items'] as List?)
              ?.map((item) => SalesOrderItem.fromJson(item))
              .toList() ??
          [],
      totalAmount: (json['totalAmount'] ?? 0.0).toDouble(),
      discountAmount: (json['discountAmount'] ?? 0.0).toDouble(),
      taxAmount: (json['taxAmount'] ?? 0.0).toDouble(),
      finalAmount: (json['finalAmount'] ?? 0.0).toDouble(),
      status: json['status'] ?? 'pending',
      paymentStatus: json['paymentStatus'] ?? 'pending',
      paymentMethod: json['paymentMethod'] ?? '',
      orderDate: DateTime.parse(json['orderDate'] ?? DateTime.now().toIso8601String()),
      expectedDeliveryDate: json['expectedDeliveryDate'] != null
          ? DateTime.parse(json['expectedDeliveryDate'])
          : null,
      actualDeliveryDate: json['actualDeliveryDate'] != null
          ? DateTime.parse(json['actualDeliveryDate'])
          : null,
      shippingAddress: json['shippingAddress'] ?? '',
      billingAddress: json['billingAddress'] ?? '',
      notes: json['notes'],
      salesRepresentativeId: json['salesRepresentativeId'],
      salesRepresentativeName: json['salesRepresentativeName'] ?? '',
      distributionChannel: json['distributionChannel'] ?? '',
      promotionCode: json['promotionCode'],
      promotionDiscount: json['promotionDiscount']?.toDouble(),
      deliveryMethod: json['deliveryMethod'] ?? 'standard',
      deliveryCost: (json['deliveryCost'] ?? 0.0).toDouble(),
      isUrgent: json['isUrgent'] ?? false,
      priority: json['priority'],
      tags: List<String>.from(json['tags'] ?? []),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderNumber': orderNumber,
      'customerId': customerId,
      'customerName': customerName,
      'customerEmail': customerEmail,
      'customerPhone': customerPhone,
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'discountAmount': discountAmount,
      'taxAmount': taxAmount,
      'finalAmount': finalAmount,
      'status': status,
      'paymentStatus': paymentStatus,
      'paymentMethod': paymentMethod,
      'orderDate': orderDate.toIso8601String(),
      'expectedDeliveryDate': expectedDeliveryDate?.toIso8601String(),
      'actualDeliveryDate': actualDeliveryDate?.toIso8601String(),
      'shippingAddress': shippingAddress,
      'billingAddress': billingAddress,
      'notes': notes,
      'salesRepresentativeId': salesRepresentativeId,
      'salesRepresentativeName': salesRepresentativeName,
      'distributionChannel': distributionChannel,
      'promotionCode': promotionCode,
      'promotionDiscount': promotionDiscount,
      'deliveryMethod': deliveryMethod,
      'deliveryCost': deliveryCost,
      'isUrgent': isUrgent,
      'priority': priority,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  SalesOrder copyWith({
    String? id,
    String? orderNumber,
    String? customerId,
    String? customerName,
    String? customerEmail,
    String? customerPhone,
    List<SalesOrderItem>? items,
    double? totalAmount,
    double? discountAmount,
    double? taxAmount,
    double? finalAmount,
    String? status,
    String? paymentStatus,
    String? paymentMethod,
    DateTime? orderDate,
    DateTime? expectedDeliveryDate,
    DateTime? actualDeliveryDate,
    String? shippingAddress,
    String? billingAddress,
    String? notes,
    String? salesRepresentativeId,
    String? salesRepresentativeName,
    String? distributionChannel,
    String? promotionCode,
    double? promotionDiscount,
    String? deliveryMethod,
    double? deliveryCost,
    bool? isUrgent,
    String? priority,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SalesOrder(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      customerPhone: customerPhone ?? this.customerPhone,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      taxAmount: taxAmount ?? this.taxAmount,
      finalAmount: finalAmount ?? this.finalAmount,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      orderDate: orderDate ?? this.orderDate,
      expectedDeliveryDate: expectedDeliveryDate ?? this.expectedDeliveryDate,
      actualDeliveryDate: actualDeliveryDate ?? this.actualDeliveryDate,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      billingAddress: billingAddress ?? this.billingAddress,
      notes: notes ?? this.notes,
      salesRepresentativeId: salesRepresentativeId ?? this.salesRepresentativeId,
      salesRepresentativeName: salesRepresentativeName ?? this.salesRepresentativeName,
      distributionChannel: distributionChannel ?? this.distributionChannel,
      promotionCode: promotionCode ?? this.promotionCode,
      promotionDiscount: promotionDiscount ?? this.promotionDiscount,
      deliveryMethod: deliveryMethod ?? this.deliveryMethod,
      deliveryCost: deliveryCost ?? this.deliveryCost,
      isUrgent: isUrgent ?? this.isUrgent,
      priority: priority ?? this.priority,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Computed properties
  bool get isPending => status == 'pending';
  bool get isConfirmed => status == 'confirmed';
  bool get isProcessing => status == 'processing';
  bool get isShipped => status == 'shipped';
  bool get isDelivered => status == 'delivered';
  bool get isCancelled => status == 'cancelled';
  
  bool get isPaymentPending => paymentStatus == 'pending';
  bool get isPaid => paymentStatus == 'paid';
  bool get isPaymentFailed => paymentStatus == 'failed';
  bool get isRefunded => paymentStatus == 'refunded';
  
  bool get isOverdue => expectedDeliveryDate != null && 
      DateTime.now().isAfter(expectedDeliveryDate!) && !isDelivered;
  
  int get totalQuantity => items.fold(0, (sum, item) => sum + item.quantity);
  
  Duration? get deliveryTime {
    if (actualDeliveryDate != null && expectedDeliveryDate != null) {
      return actualDeliveryDate!.difference(expectedDeliveryDate!);
    }
    return null;
  }

  @override
  List<Object?> get props => [
        id,
        orderNumber,
        customerId,
        customerName,
        customerEmail,
        customerPhone,
        items,
        totalAmount,
        discountAmount,
        taxAmount,
        finalAmount,
        status,
        paymentStatus,
        paymentMethod,
        orderDate,
        expectedDeliveryDate,
        actualDeliveryDate,
        shippingAddress,
        billingAddress,
        notes,
        salesRepresentativeId,
        salesRepresentativeName,
        distributionChannel,
        promotionCode,
        promotionDiscount,
        deliveryMethod,
        deliveryCost,
        isUrgent,
        priority,
        tags,
        createdAt,
        updatedAt,
      ];
}

class SalesOrderItem extends Equatable {
  final String id;
  final String productId;
  final String productName;
  final String productGenericName;
  final String productManufacturer;
  final String productCategory;
  final String productStrength;
  final String productDosageForm;
  final double unitPrice;
  final int quantity;
  final double discountPercentage;
  final double discountAmount;
  final double taxRate;
  final double taxAmount;
  final double totalPrice;
  final String batchNumber;
  final DateTime? expiryDate;
  final bool isPrescriptionRequired;
  final String? prescriptionNumber;
  final String? doctorName;
  final String? doctorRegistration;

  const SalesOrderItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productGenericName,
    required this.productManufacturer,
    required this.productCategory,
    required this.productStrength,
    required this.productDosageForm,
    required this.unitPrice,
    required this.quantity,
    this.discountPercentage = 0.0,
    required this.discountAmount,
    required this.taxRate,
    required this.taxAmount,
    required this.totalPrice,
    required this.batchNumber,
    this.expiryDate,
    this.isPrescriptionRequired = false,
    this.prescriptionNumber,
    this.doctorName,
    this.doctorRegistration,
  });

  factory SalesOrderItem.fromJson(Map<String, dynamic> json) {
    return SalesOrderItem(
      id: json['id'] ?? '',
      productId: json['productId'] ?? '',
      productName: json['productName'] ?? '',
      productGenericName: json['productGenericName'] ?? '',
      productManufacturer: json['productManufacturer'] ?? '',
      productCategory: json['productCategory'] ?? '',
      productStrength: json['productStrength'] ?? '',
      productDosageForm: json['productDosageForm'] ?? '',
      unitPrice: (json['unitPrice'] ?? 0.0).toDouble(),
      quantity: json['quantity'] ?? 0,
      discountPercentage: (json['discountPercentage'] ?? 0.0).toDouble(),
      discountAmount: (json['discountAmount'] ?? 0.0).toDouble(),
      taxRate: (json['taxRate'] ?? 0.0).toDouble(),
      taxAmount: (json['taxAmount'] ?? 0.0).toDouble(),
      totalPrice: (json['totalPrice'] ?? 0.0).toDouble(),
      batchNumber: json['batchNumber'] ?? '',
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'])
          : null,
      isPrescriptionRequired: json['isPrescriptionRequired'] ?? false,
      prescriptionNumber: json['prescriptionNumber'],
      doctorName: json['doctorName'],
      doctorRegistration: json['doctorRegistration'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'productGenericName': productGenericName,
      'productManufacturer': productManufacturer,
      'productCategory': productCategory,
      'productStrength': productStrength,
      'productDosageForm': productDosageForm,
      'unitPrice': unitPrice,
      'quantity': quantity,
      'discountPercentage': discountPercentage,
      'discountAmount': discountAmount,
      'taxRate': taxRate,
      'taxAmount': taxAmount,
      'totalPrice': totalPrice,
      'batchNumber': batchNumber,
      'expiryDate': expiryDate?.toIso8601String(),
      'isPrescriptionRequired': isPrescriptionRequired,
      'prescriptionNumber': prescriptionNumber,
      'doctorName': doctorName,
      'doctorRegistration': doctorRegistration,
    };
  }

  @override
  List<Object?> get props => [
        id,
        productId,
        productName,
        productGenericName,
        productManufacturer,
        productCategory,
        productStrength,
        productDosageForm,
        unitPrice,
        quantity,
        discountPercentage,
        discountAmount,
        taxRate,
        taxAmount,
        totalPrice,
        batchNumber,
        expiryDate,
        isPrescriptionRequired,
        prescriptionNumber,
        doctorName,
        doctorRegistration,
      ];
}

class SalesAnalytics extends Equatable {
  final String id;
  final DateTime period;
  final String periodType; // daily, weekly, monthly, quarterly, yearly
  final double totalRevenue;
  final double totalOrders;
  final double averageOrderValue;
  final int totalCustomers;
  final int newCustomers;
  final int returningCustomers;
  final Map<String, double> revenueByCategory;
  final Map<String, double> revenueByChannel;
  final Map<String, int> ordersByStatus;
  final List<String> topSellingProducts;
  final List<String> topCustomers;
  final double conversionRate;
  final double customerRetentionRate;
  final double averageOrderProcessingTime;
  final double onTimeDeliveryRate;
  final double customerSatisfactionScore;
  final Map<String, double> salesByRegion;
  final Map<String, double> salesBySalesRep;
  final double totalDiscounts;
  final double totalReturns;
  final double returnRate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SalesAnalytics({
    required this.id,
    required this.period,
    required this.periodType,
    required this.totalRevenue,
    required this.totalOrders,
    required this.averageOrderValue,
    required this.totalCustomers,
    required this.newCustomers,
    required this.returningCustomers,
    required this.revenueByCategory,
    required this.revenueByChannel,
    required this.ordersByStatus,
    required this.topSellingProducts,
    required this.topCustomers,
    required this.conversionRate,
    required this.customerRetentionRate,
    required this.averageOrderProcessingTime,
    required this.onTimeDeliveryRate,
    required this.customerSatisfactionScore,
    required this.salesByRegion,
    required this.salesBySalesRep,
    required this.totalDiscounts,
    required this.totalReturns,
    required this.returnRate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SalesAnalytics.fromJson(Map<String, dynamic> json) {
    return SalesAnalytics(
      id: json['id'] ?? '',
      period: DateTime.parse(json['period'] ?? DateTime.now().toIso8601String()),
      periodType: json['periodType'] ?? '',
      totalRevenue: (json['totalRevenue'] ?? 0.0).toDouble(),
      totalOrders: (json['totalOrders'] ?? 0.0).toDouble(),
      averageOrderValue: (json['averageOrderValue'] ?? 0.0).toDouble(),
      totalCustomers: json['totalCustomers'] ?? 0,
      newCustomers: json['newCustomers'] ?? 0,
      returningCustomers: json['returningCustomers'] ?? 0,
      revenueByCategory: Map<String, double>.from(json['revenueByCategory'] ?? {}),
      revenueByChannel: Map<String, double>.from(json['revenueByChannel'] ?? {}),
      ordersByStatus: Map<String, int>.from(json['ordersByStatus'] ?? {}),
      topSellingProducts: List<String>.from(json['topSellingProducts'] ?? []),
      topCustomers: List<String>.from(json['topCustomers'] ?? []),
      conversionRate: (json['conversionRate'] ?? 0.0).toDouble(),
      customerRetentionRate: (json['customerRetentionRate'] ?? 0.0).toDouble(),
      averageOrderProcessingTime: (json['averageOrderProcessingTime'] ?? 0.0).toDouble(),
      onTimeDeliveryRate: (json['onTimeDeliveryRate'] ?? 0.0).toDouble(),
      customerSatisfactionScore: (json['customerSatisfactionScore'] ?? 0.0).toDouble(),
      salesByRegion: Map<String, double>.from(json['salesByRegion'] ?? {}),
      salesBySalesRep: Map<String, double>.from(json['salesBySalesRep'] ?? {}),
      totalDiscounts: (json['totalDiscounts'] ?? 0.0).toDouble(),
      totalReturns: (json['totalReturns'] ?? 0.0).toDouble(),
      returnRate: (json['returnRate'] ?? 0.0).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'period': period.toIso8601String(),
      'periodType': periodType,
      'totalRevenue': totalRevenue,
      'totalOrders': totalOrders,
      'averageOrderValue': averageOrderValue,
      'totalCustomers': totalCustomers,
      'newCustomers': newCustomers,
      'returningCustomers': returningCustomers,
      'revenueByCategory': revenueByCategory,
      'revenueByChannel': revenueByChannel,
      'ordersByStatus': ordersByStatus,
      'topSellingProducts': topSellingProducts,
      'topCustomers': topCustomers,
      'conversionRate': conversionRate,
      'customerRetentionRate': customerRetentionRate,
      'averageOrderProcessingTime': averageOrderProcessingTime,
      'onTimeDeliveryRate': onTimeDeliveryRate,
      'customerSatisfactionScore': customerSatisfactionScore,
      'salesByRegion': salesByRegion,
      'salesBySalesRep': salesBySalesRep,
      'totalDiscounts': totalDiscounts,
      'totalReturns': totalReturns,
      'returnRate': returnRate,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        period,
        periodType,
        totalRevenue,
        totalOrders,
        averageOrderValue,
        totalCustomers,
        newCustomers,
        returningCustomers,
        revenueByCategory,
        revenueByChannel,
        ordersByStatus,
        topSellingProducts,
        topCustomers,
        conversionRate,
        customerRetentionRate,
        averageOrderProcessingTime,
        onTimeDeliveryRate,
        customerSatisfactionScore,
        salesByRegion,
        salesBySalesRep,
        totalDiscounts,
        totalReturns,
        returnRate,
        createdAt,
        updatedAt,
      ];
}
