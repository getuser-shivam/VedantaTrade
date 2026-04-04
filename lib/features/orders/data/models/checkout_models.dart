// Checkout Request Model
class CheckoutRequest {
  final String retailerId;
  final String retailerName;
  final List<CheckoutItem> items;
  final double subtotal;
  final double discountAmount;
  final double vatAmount;
  final double deliveryFee;
  final double totalAmount;
  final String? promoCode;
  final Address shippingAddress;
  final Address? billingAddress;
  final String deliveryOption;
  final String? notes;

  const CheckoutRequest({
    required this.retailerId,
    required this.retailerName,
    required this.items,
    required this.subtotal,
    required this.discountAmount,
    required this.vatAmount,
    required this.deliveryFee,
    required this.totalAmount,
    this.promoCode,
    required this.shippingAddress,
    this.billingAddress,
    required this.deliveryOption,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'retailerId': retailerId,
      'retailerName': retailerName,
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'discountAmount': discountAmount,
      'vatAmount': vatAmount,
      'deliveryFee': deliveryFee,
      'totalAmount': totalAmount,
      'promoCode': promoCode,
      'shippingAddress': shippingAddress.toJson(),
      'billingAddress': billingAddress?.toJson(),
      'deliveryOption': deliveryOption,
      'notes': notes,
    };
  }
}

// Checkout Item Model
class CheckoutItem {
  final String sku;
  final String productName;
  final String brand;
  final String category;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final String? batchNumber;
  final DateTime? expiryDate;
  final bool available;
  final int availableStock;

  const CheckoutItem({
    required this.sku,
    required this.productName,
    required this.brand,
    required this.category,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.batchNumber,
    this.expiryDate,
    required this.available,
    required this.availableStock,
  });

  Map<String, dynamic> toJson() {
    return {
      'sku': sku,
      'productName': productName,
      'brand': brand,
      'category': category,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
      'batchNumber': batchNumber,
      'expiryDate': expiryDate?.toIso8601String(),
      'available': available,
      'availableStock': availableStock,
    };
  }
}

// Checkout Session Model
class CheckoutSession {
  final String id;
  final String retailerId;
  final String retailerName;
  final List<CheckoutItem> items;
  final double subtotal;
  final double discountAmount;
  final double vatAmount;
  final double deliveryFee;
  final double totalAmount;
  final String currency;
  final CheckoutStatus status;
  final DateTime createdAt;
  final DateTime expiresAt;
  final String? paymentMethod;
  final Address shippingAddress;
  final Address? billingAddress;
  final String? notes;
  final DateTime? completedAt;

  const CheckoutSession({
    required this.id,
    required this.retailerId,
    required this.retailerName,
    required this.items,
    required this.subtotal,
    required this.discountAmount,
    required this.vatAmount,
    required this.deliveryFee,
    required this.totalAmount,
    required this.currency,
    required this.status,
    required this.createdAt,
    required this.expiresAt,
    this.paymentMethod,
    required this.shippingAddress,
    this.billingAddress,
    this.notes,
    this.completedAt,
  });

  factory CheckoutSession.fromJson(Map<String, dynamic> json) {
    return CheckoutSession(
      id: json['id'] as String,
      retailerId: json['retailerId'] as String,
      retailerName: json['retailerName'] as String,
      items: (json['items'] as List)
          .map((item) => CheckoutItem.fromJson(item))
          .toList(),
      subtotal: (json['subtotal'] as num).toDouble(),
      discountAmount: (json['discountAmount'] as num).toDouble(),
      vatAmount: (json['vatAmount'] as num).toDouble(),
      deliveryFee: (json['deliveryFee'] as num).toDouble(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      currency: json['currency'] as String,
      status: CheckoutStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => CheckoutStatus.pending,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      paymentMethod: json['paymentMethod'] as String?,
      shippingAddress: Address.fromJson(json['shippingAddress']),
      billingAddress: json['billingAddress'] != null
          ? Address.fromJson(json['billingAddress'])
          : null,
      notes: json['notes'] as String?,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }

  CheckoutSession copyWith({
    String? id,
    String? retailerId,
    String? retailerName,
    List<CheckoutItem>? items,
    double? subtotal,
    double? discountAmount,
    double? vatAmount,
    double? deliveryFee,
    double? totalAmount,
    String? currency,
    CheckoutStatus? status,
    DateTime? createdAt,
    DateTime? expiresAt,
    String? paymentMethod,
    Address? shippingAddress,
    Address? billingAddress,
    String? notes,
    DateTime? completedAt,
  }) {
    return CheckoutSession(
      id: id ?? this.id,
      retailerId: retailerId ?? this.retailerId,
      retailerName: retailerName ?? this.retailerName,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      discountAmount: discountAmount ?? this.discountAmount,
      vatAmount: vatAmount ?? this.vatAmount,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      totalAmount: totalAmount ?? this.totalAmount,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      billingAddress: billingAddress ?? this.billingAddress,
      notes: notes ?? this.notes,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  // Computed properties
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);
  
  bool get isExpired => DateTime.now().isAfter(expiresAt);
  
  bool get isActive => !isExpired && status == CheckoutStatus.pending;
  
  int get minutesUntilExpiry => expiresAt.difference(DateTime.now()).inMinutes;
  
  double get discountPercentage => subtotal > 0 ? (discountAmount / subtotal) * 100 : 0;
}

// Address Model
class Address {
  final String street;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final double? latitude;
  final double? longitude;
  final String? landmark;
  final String? phone;

  const Address({
    required this.street,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    this.latitude,
    this.longitude,
    this.landmark,
    this.phone,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      street: json['street'] as String,
      city: json['city'] as String,
      state: json['state'] as String,
      postalCode: json['postalCode'] as String,
      country: json['country'] as String,
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
      landmark: json['landmark'] as String?,
      phone: json['phone'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'street': street,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'landmark': landmark,
      'phone': phone,
    };
  }

  String get fullAddress {
    final parts = [street, city, state, postalCode, country];
    return parts.where((part) => part.isNotEmpty).join(', ');
  }
}

// Delivery Option Model
class DeliveryOption {
  final String id;
  final String name;
  final String description;
  final double price;
  final int estimatedDays;
  final bool available;
  final List<String> regions;
  final String? icon;
  final Map<String, dynamic>? metadata;

  const DeliveryOption({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.estimatedDays,
    required this.available,
    required this.regions,
    this.icon,
    this.metadata,
  });

  factory DeliveryOption.fromJson(Map<String, dynamic> json) {
    return DeliveryOption(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      estimatedDays: (json['estimatedDays'] as num).toInt(),
      available: json['available'] as bool,
      regions: List<String>.from(json['regions'] as List),
      icon: json['icon'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'estimatedDays': estimatedDays,
      'available': available,
      'regions': regions,
      'icon': icon,
      'metadata': metadata,
    };
  }

  String get estimatedDeliveryText {
    if (estimatedDays == 0) return 'Same day';
    if (estimatedDays == 1) return 'Next day';
    return '$estimatedDays business days';
  }
}

// Order Summary Model
class OrderSummary {
  final String orderId;
  final String retailerId;
  final String retailerName;
  final List<CheckoutItem> items;
  final double subtotal;
  final double discountAmount;
  final double vatAmount;
  final double deliveryFee;
  final double totalAmount;
  final String currency;
  final OrderStatus status;
  final String? paymentMethod;
  final PaymentStatus paymentStatus;
  final DateTime createdAt;
  final DateTime estimatedDelivery;
  final String? trackingNumber;
  final Address shippingAddress;
  final String? notes;

  const OrderSummary({
    required this.orderId,
    required this.retailerId,
    required this.retailerName,
    required this.items,
    required this.subtotal,
    required this.discountAmount,
    required this.vatAmount,
    required this.deliveryFee,
    required this.totalAmount,
    required this.currency,
    required this.status,
    this.paymentMethod,
    required this.paymentStatus,
    required this.createdAt,
    required this.estimatedDelivery,
    this.trackingNumber,
    required this.shippingAddress,
    this.notes,
  });

  factory OrderSummary.fromJson(Map<String, dynamic> json) {
    return OrderSummary(
      orderId: json['orderId'] as String,
      retailerId: json['retailerId'] as String,
      retailerName: json['retailerName'] as String,
      items: (json['items'] as List)
          .map((item) => CheckoutItem.fromJson(item))
          .toList(),
      subtotal: (json['subtotal'] as num).toDouble(),
      discountAmount: (json['discountAmount'] as num).toDouble(),
      vatAmount: (json['vatAmount'] as num).toDouble(),
      deliveryFee: (json['deliveryFee'] as num).toDouble(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      currency: json['currency'] as String,
      status: OrderStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => OrderStatus.pending,
      ),
      paymentMethod: json['paymentMethod'] as String?,
      paymentStatus: PaymentStatus.values.firstWhere(
        (e) => e.toString() == json['paymentStatus'],
        orElse: () => PaymentStatus.pending,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      estimatedDelivery: DateTime.parse(json['estimatedDelivery'] as String),
      trackingNumber: json['trackingNumber'] as String?,
      shippingAddress: Address.fromJson(json['shippingAddress']),
      notes: json['notes'] as String?,
    );
  }

  // Computed properties
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);
  
  bool get isDelivered => status == OrderStatus.delivered;
  
  bool get isShipped => status == OrderStatus.shipped || isDelivered;
  
  int get daysUntilDelivery => estimatedDelivery.difference(DateTime.now()).inDays;
  
  String get deliveryStatusText {
    switch (status) {
      case OrderStatus.pending:
        return 'Order Placed';
      case OrderStatus.confirmed:
        return 'Order Confirmed';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
      case OrderStatus.returned:
        return 'Returned';
    }
  }
}

// Checkout Status Enum
enum CheckoutStatus {
  pending,
  processing,
  paid,
  expired,
  cancelled,
  completed,
}

// Order Status Enum
enum OrderStatus {
  pending,
  confirmed,
  processing,
  shipped,
  delivered,
  cancelled,
  returned,
}

// Payment Status Enum
enum PaymentStatus {
  pending,
  processing,
  paid,
  failed,
  refunded,
  partially_refunded,
}

// Checkout Item Factory
class CheckoutItemFactory {
  static CheckoutItem fromInventoryItem(Map<String, dynamic> inventoryItem, int quantity) {
    return CheckoutItem(
      sku: inventoryItem['sku'] as String,
      productName: inventoryItem['productName'] as String,
      brand: inventoryItem['brand'] as String,
      category: inventoryItem['category'] as String,
      quantity: quantity,
      unitPrice: (inventoryItem['unitPrice'] as num).toDouble(),
      totalPrice: (inventoryItem['unitPrice'] as num).toDouble() * quantity,
      batchNumber: inventoryItem['batchNumber'] as String?,
      expiryDate: inventoryItem['expiryDate'] != null
          ? DateTime.parse(inventoryItem['expiryDate'] as String)
          : null,
      available: inventoryItem['available'] as bool? ?? true,
      availableStock: (inventoryItem['currentStock'] as num?)?.toInt() ?? 0,
    );
  }

  static List<CheckoutItem> fromCartItems(List<Map<String, dynamic>> cartItems) {
    return cartItems.map((item) => CheckoutItem(
      sku: item['sku'] as String,
      productName: item['productName'] as String,
      brand: item['brand'] as String,
      category: item['category'] as String,
      quantity: (item['quantity'] as num).toInt(),
      unitPrice: (item['unitPrice'] as num).toDouble(),
      totalPrice: (item['totalPrice'] as num).toDouble(),
      batchNumber: item['batchNumber'] as String?,
      expiryDate: item['expiryDate'] != null
          ? DateTime.parse(item['expiryDate'] as String)
          : null,
      available: item['available'] as bool? ?? true,
      availableStock: (item['availableStock'] as num?)?.toInt() ?? 0,
    )).toList();
  }
}

// Checkout Validation Result
class CheckoutValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;
  final Map<String, dynamic> metadata;

  const CheckoutValidationResult({
    required this.isValid,
    required this.errors,
    required this.warnings,
    required this.metadata,
  });

  static CheckoutValidationResult success({List<String> warnings = const [], Map<String, dynamic>? metadata}) {
    return CheckoutValidationResult(
      isValid: true,
      errors: [],
      warnings: warnings,
      metadata: metadata ?? {},
    );
  }

  static CheckoutValidationResult failure(List<String> errors, {List<String> warnings = const [], Map<String, dynamic>? metadata}) {
    return CheckoutValidationResult(
      isValid: false,
      errors: errors,
      warnings: warnings,
      metadata: metadata ?? {},
    );
  }
}
