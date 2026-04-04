// Sales Record Model
class SalesRecord {
  final String id;
  final String orderId;
  final String retailerId;
  final String retailerName;
  final String retailerLocation;
  final List<SalesItem> items;
  final double totalAmount;
  final double vatAmount;
  final double finalAmount;
  final SalesStatus status;
  final PaymentStatus paymentStatus;
  final DateTime date;
  final DateTime? deliveryDate;
  final String? notes;
  final String createdBy;
  final String? deliveryAddress;
  final DeliveryMethod deliveryMethod;
  final String? trackingNumber;

  const SalesRecord({
    required this.id,
    required this.orderId,
    required this.retailerId,
    required this.retailerName,
    required this.retailerLocation,
    required this.items,
    required this.totalAmount,
    required this.vatAmount,
    required this.finalAmount,
    required this.status,
    required this.paymentStatus,
    required this.date,
    this.deliveryDate,
    this.notes,
    required this.createdBy,
    this.deliveryAddress,
    required this.deliveryMethod,
    this.trackingNumber,
  });

  factory SalesRecord.fromJson(Map<String, dynamic> json) {
    return SalesRecord(
      id: json['id'] as String,
      orderId: json['orderId'] as String,
      retailerId: json['retailerId'] as String,
      retailerName: json['retailerName'] as String,
      retailerLocation: json['retailerLocation'] as String,
      items: (json['items'] as List)
          .map((item) => SalesItem.fromJson(item))
          .toList(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      vatAmount: (json['vatAmount'] as num).toDouble(),
      finalAmount: (json['finalAmount'] as num).toDouble(),
      status: SalesStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => SalesStatus.pending,
      ),
      paymentStatus: PaymentStatus.values.firstWhere(
        (e) => e.toString() == json['paymentStatus'],
        orElse: () => PaymentStatus.pending,
      ),
      date: DateTime.parse(json['date'] as String),
      deliveryDate: json['deliveryDate'] != null
          ? DateTime.parse(json['deliveryDate'] as String)
          : null,
      notes: json['notes'] as String?,
      createdBy: json['createdBy'] as String,
      deliveryAddress: json['deliveryAddress'] as String?,
      deliveryMethod: DeliveryMethod.values.firstWhere(
        (e) => e.toString() == json['deliveryMethod'],
        orElse: () => DeliveryMethod.standard,
      ),
      trackingNumber: json['trackingNumber'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'retailerId': retailerId,
      'retailerName': retailerName,
      'retailerLocation': retailerLocation,
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'vatAmount': vatAmount,
      'finalAmount': finalAmount,
      'status': status.toString(),
      'paymentStatus': paymentStatus.toString(),
      'date': date.toIso8601String(),
      'deliveryDate': deliveryDate?.toIso8601String(),
      'notes': notes,
      'createdBy': createdBy,
      'deliveryAddress': deliveryAddress,
      'deliveryMethod': deliveryMethod.toString(),
      'trackingNumber': trackingNumber,
    };
  }

  SalesRecord copyWith({
    String? id,
    String? orderId,
    String? retailerId,
    String? retailerName,
    String? retailerLocation,
    List<SalesItem>? items,
    double? totalAmount,
    double? vatAmount,
    double? finalAmount,
    SalesStatus? status,
    PaymentStatus? paymentStatus,
    DateTime? date,
    DateTime? deliveryDate,
    String? notes,
    String? createdBy,
    String? deliveryAddress,
    DeliveryMethod? deliveryMethod,
    String? trackingNumber,
  }) {
    return SalesRecord(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      retailerId: retailerId ?? this.retailerId,
      retailerName: retailerName ?? this.retailerName,
      retailerLocation: retailerLocation ?? this.retailerLocation,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      vatAmount: vatAmount ?? this.vatAmount,
      finalAmount: finalAmount ?? this.finalAmount,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      date: date ?? this.date,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      notes: notes ?? this.notes,
      createdBy: createdBy ?? this.createdBy,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      deliveryMethod: deliveryMethod ?? this.deliveryMethod,
      trackingNumber: trackingNumber ?? this.trackingNumber,
    );
  }

  // Computed properties
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);
  
  bool get isDelivered => status == SalesStatus.completed;
  
  bool get isPaid => paymentStatus == PaymentStatus.paid;
  
  bool get isOverdue => !isDelivered && deliveryDate != null && DateTime.now().isAfter(deliveryDate!);
  
  int get daysSinceOrder => DateTime.now().difference(date).inDays;
}

// Sales Item Model
class SalesItem {
  final String sku;
  final String productName;
  final String brand;
  final String category;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final double discount;
  final String? batchNumber;
  final DateTime? expiryDate;

  const SalesItem({
    required this.sku,
    required this.productName,
    required this.brand,
    required this.category,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.discount,
    this.batchNumber,
    this.expiryDate,
  });

  factory SalesItem.fromJson(Map<String, dynamic> json) {
    return SalesItem(
      sku: json['sku'] as String,
      productName: json['productName'] as String,
      brand: json['brand'] as String,
      category: json['category'] as String,
      quantity: (json['quantity'] as num).toInt(),
      unitPrice: (json['unitPrice'] as num).toDouble(),
      totalPrice: (json['totalPrice'] as num).toDouble(),
      discount: (json['discount'] as num).toDouble(),
      batchNumber: json['batchNumber'] as String?,
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sku': sku,
      'productName': productName,
      'brand': brand,
      'category': category,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
      'discount': discount,
      'batchNumber': batchNumber,
      'expiryDate': expiryDate?.toIso8601String(),
    };
  }

  double get effectivePrice => unitPrice - discount;
  
  double get discountPercentage => unitPrice > 0 ? (discount / unitPrice) * 100 : 0;
}

// Sales Order Model
class SalesOrder {
  final String id;
  final String retailerId;
  final String retailerName;
  final String retailerLocation;
  final List<OrderItem> items;
  final double subtotal;
  final double discountAmount;
  final double vatAmount;
  final double totalAmount;
  final OrderStatus status;
  final DateTime orderDate;
  final DateTime? expectedDeliveryDate;
  final String? deliveryAddress;
  final DeliveryMethod deliveryMethod;
  final String? notes;
  final String createdBy;
  final String? assignedTo;
  final PaymentTerms paymentTerms;

  const SalesOrder({
    required this.id,
    required this.retailerId,
    required this.retailerName,
    required this.retailerLocation,
    required this.items,
    required this.subtotal,
    required this.discountAmount,
    required this.vatAmount,
    required this.totalAmount,
    required this.status,
    required this.orderDate,
    this.expectedDeliveryDate,
    this.deliveryAddress,
    required this.deliveryMethod,
    this.notes,
    required this.createdBy,
    this.assignedTo,
    required this.paymentTerms,
  });

  factory SalesOrder.fromJson(Map<String, dynamic> json) {
    return SalesOrder(
      id: json['id'] as String,
      retailerId: json['retailerId'] as String,
      retailerName: json['retailerName'] as String,
      retailerLocation: json['retailerLocation'] as String,
      items: (json['items'] as List)
          .map((item) => OrderItem.fromJson(item))
          .toList(),
      subtotal: (json['subtotal'] as num).toDouble(),
      discountAmount: (json['discountAmount'] as num).toDouble(),
      vatAmount: (json['vatAmount'] as num).toDouble(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      status: OrderStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => OrderStatus.pending,
      ),
      orderDate: DateTime.parse(json['orderDate'] as String),
      expectedDeliveryDate: json['expectedDeliveryDate'] != null
          ? DateTime.parse(json['expectedDeliveryDate'] as String)
          : null,
      deliveryAddress: json['deliveryAddress'] as String?,
      deliveryMethod: DeliveryMethod.values.firstWhere(
        (e) => e.toString() == json['deliveryMethod'],
        orElse: () => DeliveryMethod.standard,
      ),
      notes: json['notes'] as String?,
      createdBy: json['createdBy'] as String,
      assignedTo: json['assignedTo'] as String?,
      paymentTerms: PaymentTerms.values.firstWhere(
        (e) => e.toString() == json['paymentTerms'],
        orElse: () => PaymentTerms.net30,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'retailerId': retailerId,
      'retailerName': retailerName,
      'retailerLocation': retailerLocation,
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'discountAmount': discountAmount,
      'vatAmount': vatAmount,
      'totalAmount': totalAmount,
      'status': status.toString(),
      'orderDate': orderDate.toIso8601String(),
      'expectedDeliveryDate': expectedDeliveryDate?.toIso8601String(),
      'deliveryAddress': deliveryAddress,
      'deliveryMethod': deliveryMethod.toString(),
      'notes': notes,
      'createdBy': createdBy,
      'assignedTo': assignedTo,
      'paymentTerms': paymentTerms.toString(),
    };
  }

  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);
  
  bool get canBeCancelled => status == OrderStatus.pending || status == OrderStatus.confirmed;
  
  bool get isOverdue => expectedDeliveryDate != null && 
      DateTime.now().isAfter(expectedDeliveryDate!) && 
      status != OrderStatus.completed;
}

// Order Item Model
class OrderItem {
  final String sku;
  final String productName;
  final String brand;
  final String category;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final double discount;
  final String? batchNumber;
  final DateTime? expiryDate;
  final bool available;

  const OrderItem({
    required this.sku,
    required this.productName,
    required this.brand,
    required this.category,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.discount,
    this.batchNumber,
    this.expiryDate,
    required this.available,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      sku: json['sku'] as String,
      productName: json['productName'] as String,
      brand: json['brand'] as String,
      category: json['category'] as String,
      quantity: (json['quantity'] as num).toInt(),
      unitPrice: (json['unitPrice'] as num).toDouble(),
      totalPrice: (json['totalPrice'] as num).toDouble(),
      discount: (json['discount'] as num).toDouble(),
      batchNumber: json['batchNumber'] as String?,
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'] as String)
          : null,
      available: json['available'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sku': sku,
      'productName': productName,
      'brand': brand,
      'category': category,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
      'discount': discount,
      'batchNumber': batchNumber,
      'expiryDate': expiryDate?.toIso8601String(),
      'available': available,
    };
  }
}

// Sales Analytics Model
class SalesAnalytics {
  final DateTime period;
  final int totalOrders;
  final double totalRevenue;
  final double totalVAT;
  final double averageOrderValue;
  final int uniqueCustomers;
  final int returningCustomers;
  final Map<String, double> revenueByCategory;
  final Map<String, int> ordersByRegion;
  final List<TopProduct> topProducts;
  final List<MonthlyTrend> monthlyTrends;
  final CustomerMetrics customerMetrics;

  const SalesAnalytics({
    required this.period,
    required this.totalOrders,
    required this.totalRevenue,
    required this.totalVAT,
    required this.averageOrderValue,
    required this.uniqueCustomers,
    required this.returningCustomers,
    required this.revenueByCategory,
    required this.ordersByRegion,
    required this.topProducts,
    required this.monthlyTrends,
    required this.customerMetrics,
  });

  factory SalesAnalytics.fromJson(Map<String, dynamic> json) {
    return SalesAnalytics(
      period: DateTime.parse(json['period'] as String),
      totalOrders: (json['totalOrders'] as num).toInt(),
      totalRevenue: (json['totalRevenue'] as num).toDouble(),
      totalVAT: (json['totalVAT'] as num).toDouble(),
      averageOrderValue: (json['averageOrderValue'] as num).toDouble(),
      uniqueCustomers: (json['uniqueCustomers'] as num).toInt(),
      returningCustomers: (json['returningCustomers'] as num).toInt(),
      revenueByCategory: Map<String, double>.from(json['revenueByCategory']),
      ordersByRegion: Map<String, int>.from(json['ordersByRegion']),
      topProducts: (json['topProducts'] as List)
          .map((product) => TopProduct.fromJson(product))
          .toList(),
      monthlyTrends: (json['monthlyTrends'] as List)
          .map((trend) => MonthlyTrend.fromJson(trend))
          .toList(),
      customerMetrics: CustomerMetrics.fromJson(json['customerMetrics']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'period': period.toIso8601String(),
      'totalOrders': totalOrders,
      'totalRevenue': totalRevenue,
      'totalVAT': totalVAT,
      'averageOrderValue': averageOrderValue,
      'uniqueCustomers': uniqueCustomers,
      'returningCustomers': returningCustomers,
      'revenueByCategory': revenueByCategory,
      'ordersByRegion': ordersByRegion,
      'topProducts': topProducts.map((product) => product.toJson()).toList(),
      'monthlyTrends': monthlyTrends.map((trend) => trend.toJson()).toList(),
      'customerMetrics': customerMetrics.toJson(),
    };
  }

  double get customerRetentionRate => uniqueCustomers > 0 
      ? (returningCustomers / uniqueCustomers) * 100 
      : 0;
}

// Top Product Model
class TopProduct {
  final String sku;
  final String productName;
  final String brand;
  final int unitsSold;
  final double revenue;
  final int rank;

  const TopProduct({
    required this.sku,
    required this.productName,
    required this.brand,
    required this.unitsSold,
    required this.revenue,
    required this.rank,
  });

  factory TopProduct.fromJson(Map<String, dynamic> json) {
    return TopProduct(
      sku: json['sku'] as String,
      productName: json['productName'] as String,
      brand: json['brand'] as String,
      unitsSold: (json['unitsSold'] as num).toInt(),
      revenue: (json['revenue'] as num).toDouble(),
      rank: (json['rank'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sku': sku,
      'productName': productName,
      'brand': brand,
      'unitsSold': unitsSold,
      'revenue': revenue,
      'rank': rank,
    };
  }
}

// Monthly Trend Model
class MonthlyTrend {
  final DateTime month;
  final int orders;
  final double revenue;
  final int customers;

  const MonthlyTrend({
    required this.month,
    required this.orders,
    required this.revenue,
    required this.customers,
  });

  factory MonthlyTrend.fromJson(Map<String, dynamic> json) {
    return MonthlyTrend(
      month: DateTime.parse(json['month'] as String),
      orders: (json['orders'] as num).toInt(),
      revenue: (json['revenue'] as num).toDouble(),
      customers: (json['customers'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'month': month.toIso8601String(),
      'orders': orders,
      'revenue': revenue,
      'customers': customers,
    };
  }
}

// Customer Metrics Model
class CustomerMetrics {
  final int totalCustomers;
  final int activeCustomers;
  final int newCustomers;
  final double averageOrderFrequency;
  final double averageCustomerLifetimeValue;
  final Map<String, int> customersByRegion;
  final List<CustomerSegment> segments;

  const CustomerMetrics({
    required this.totalCustomers,
    required this.activeCustomers,
    required this.newCustomers,
    required this.averageOrderFrequency,
    required this.averageCustomerLifetimeValue,
    required this.customersByRegion,
    required this.segments,
  });

  factory CustomerMetrics.fromJson(Map<String, dynamic> json) {
    return CustomerMetrics(
      totalCustomers: (json['totalCustomers'] as num).toInt(),
      activeCustomers: (json['activeCustomers'] as num).toInt(),
      newCustomers: (json['newCustomers'] as num).toInt(),
      averageOrderFrequency: (json['averageOrderFrequency'] as num).toDouble(),
      averageCustomerLifetimeValue: (json['averageCustomerLifetimeValue'] as num).toDouble(),
      customersByRegion: Map<String, int>.from(json['customersByRegion']),
      segments: (json['segments'] as List)
          .map((segment) => CustomerSegment.fromJson(segment))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalCustomers': totalCustomers,
      'activeCustomers': activeCustomers,
      'newCustomers': newCustomers,
      'averageOrderFrequency': averageOrderFrequency,
      'averageCustomerLifetimeValue': averageCustomerLifetimeValue,
      'customersByRegion': customersByRegion,
      'segments': segments.map((segment) => segment.toJson()).toList(),
    };
  }
}

// Customer Segment Model
class CustomerSegment {
  final String name;
  final int customerCount;
  final double averageOrderValue;
  final double totalRevenue;
  final double growthRate;

  const CustomerSegment({
    required this.name,
    required this.customerCount,
    required this.averageOrderValue,
    required this.totalRevenue,
    required this.growthRate,
  });

  factory CustomerSegment.fromJson(Map<String, dynamic> json) {
    return CustomerSegment(
      name: json['name'] as String,
      customerCount: (json['customerCount'] as num).toInt(),
      averageOrderValue: (json['averageOrderValue'] as num).toDouble(),
      totalRevenue: (json['totalRevenue'] as num).toDouble(),
      growthRate: (json['growthRate'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'customerCount': customerCount,
      'averageOrderValue': averageOrderValue,
      'totalRevenue': totalRevenue,
      'growthRate': growthRate,
    };
  }
}

// Enums
enum SalesStatus {
  pending,
  confirmed,
  processing,
  shipped,
  delivered,
  cancelled,
  returned,
}

enum PaymentStatus {
  pending,
  processing,
  paid,
  failed,
  refunded,
  partiallyRefunded,
}

enum OrderStatus {
  pending,
  confirmed,
  processing,
  shipped,
  delivered,
  cancelled,
  returned,
}

enum DeliveryMethod {
  standard,
  express,
  overnight,
  pickup,
  digital,
}

enum PaymentTerms {
  cod, // Cash on Delivery
  net15, // Net 15 days
  net30, // Net 30 days
  net60, // Net 60 days
  prepaid, // Prepaid
}
