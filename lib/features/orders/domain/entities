import 'package:equatable/equatable.dart';

/// Payment Entity for VedantaTrade
/// Represents payment transactions and payment methods

class PaymentEntity extends Equatable {
  final String id;
  final String orderId;
  final String retailerId;
  final String retailerName;
  final String retailerEmail;
  final String retailerPhone;
  final PaymentMethod paymentMethod;
  final PaymentStatus status;
  final double amount;
  final double taxAmount;
  final double discountAmount;
  final double shippingAmount;
  final double totalAmount;
  final String currency;
  final String? transactionId;
  final String? gatewayTransactionId;
  final String? authorizationCode;
  final String? paymentToken;
  final String? billingAddress;
  final String? shippingAddress;
  final List<PaymentItem> items;
  final PaymentGateway gateway;
  final String? failureReason;
  final String? failureCode;
  final int? retryCount;
  final DateTime? processedAt;
  final DateTime? expiresAt;
  final DateTime? refundedAt;
  final double? refundedAmount;
  final String? refundReason;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PaymentEntity({
    required this.id,
    required this.orderId,
    required this.retailerId,
    required this.retailerName,
    required this.retailerEmail,
    required this.retailerPhone,
    required this.paymentMethod,
    required this.status,
    required this.amount,
    required this.taxAmount,
    required this.discountAmount,
    required this.shippingAmount,
    required this.totalAmount,
    required this.currency,
    this.transactionId,
    this.gatewayTransactionId,
    this.authorizationCode,
    this.paymentToken,
    this.billingAddress,
    this.shippingAddress,
    required this.items,
    required this.gateway,
    this.failureReason,
    this.failureCode,
    this.retryCount,
    this.processedAt,
    this.expiresAt,
    this.refundedAt,
    this.refundedAmount,
    this.refundReason,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        orderId,
        retailerId,
        retailerName,
        retailerEmail,
        retailerPhone,
        paymentMethod,
        status,
        amount,
        taxAmount,
        discountAmount,
        shippingAmount,
        totalAmount,
        currency,
        transactionId,
        gatewayTransactionId,
        authorizationCode,
        paymentToken,
        billingAddress,
        shippingAddress,
        items,
        gateway,
        failureReason,
        failureCode,
        retryCount,
        processedAt,
        expiresAt,
        refundedAt,
        refundedAmount,
        refundReason,
        metadata,
        createdAt,
        updatedAt,
      ];

  PaymentEntity copyWith({
    String? id,
    String? orderId,
    String? retailerId,
    String? retailerName,
    String? retailerEmail,
    String? retailerPhone,
    PaymentMethod? paymentMethod,
    PaymentStatus? status,
    double? amount,
    double? taxAmount,
    double? discountAmount,
    double? shippingAmount,
    double? totalAmount,
    String? currency,
    String? transactionId,
    String? gatewayTransactionId,
    String? authorizationCode,
    String? paymentToken,
    String? billingAddress,
    String? shippingAddress,
    List<PaymentItem>? items,
    PaymentGateway? gateway,
    String? failureReason,
    String? failureCode,
    int? retryCount,
    DateTime? processedAt,
    DateTime? expiresAt,
    DateTime? refundedAt,
    double? refundedAmount,
    String? refundReason,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PaymentEntity(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      retailerId: retailerId ?? this.retailerId,
      retailerName: retailerName ?? this.retailerName,
      retailerEmail: retailerEmail ?? this.retailerEmail,
      retailerPhone: retailerPhone ?? this.retailerPhone,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      amount: amount ?? this.amount,
      taxAmount: taxAmount ?? this.taxAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      shippingAmount: shippingAmount ?? this.shippingAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      currency: currency ?? this.currency,
      transactionId: transactionId ?? this.transactionId,
      gatewayTransactionId: gatewayTransactionId ?? this.gatewayTransactionId,
      authorizationCode: authorizationCode ?? this.authorizationCode,
      paymentToken: paymentToken ?? this.paymentToken,
      billingAddress: billingAddress ?? this.billingAddress,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      items: items ?? this.items,
      gateway: gateway ?? this.gateway,
      failureReason: failureReason ?? this.failureReason,
      failureCode: failureCode ?? this.failureCode,
      retryCount: retryCount ?? this.retryCount,
      processedAt: processedAt ?? this.processedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      refundedAt: refundedAt ?? this.refundedAt,
      refundedAmount: refundedAmount ?? this.refundedAmount,
      refundReason: refundReason ?? this.refundReason,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'orderId': orderId,
      'retailerId': retailerId,
      'retailerName': retailerName,
      'retailerEmail': retailerEmail,
      'retailerPhone': retailerPhone,
      'paymentMethod': paymentMethod.name,
      'status': status.name,
      'amount': amount,
      'taxAmount': taxAmount,
      'discountAmount': discountAmount,
      'shippingAmount': shippingAmount,
      'totalAmount': totalAmount,
      'currency': currency,
      'transactionId': transactionId,
      'gatewayTransactionId': gatewayTransactionId,
      'authorizationCode': authorizationCode,
      'paymentToken': paymentToken,
      'billingAddress': billingAddress,
      'shippingAddress': shippingAddress,
      'items': items.map((item) => item.toMap()).toList(),
      'gateway': gateway.name,
      'failureReason': failureReason,
      'failureCode': failureCode,
      'retryCount': retryCount,
      'processedAt': processedAt?.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'refundedAt': refundedAt?.toIso8601String(),
      'refundedAmount': refundedAmount,
      'refundReason': refundReason,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory PaymentEntity.fromMap(Map<String, dynamic> map) {
    return PaymentEntity(
      id: map['id'] ?? '',
      orderId: map['orderId'] ?? '',
      retailerId: map['retailerId'] ?? '',
      retailerName: map['retailerName'] ?? '',
      retailerEmail: map['retailerEmail'] ?? '',
      retailerPhone: map['retailerPhone'] ?? '',
      paymentMethod: PaymentMethod.values.firstWhere(
        (method) => method.name == map['paymentMethod'],
        orElse: () => PaymentMethod.creditCard,
      ),
      status: PaymentStatus.values.firstWhere(
        (status) => status.name == map['status'],
        orElse: () => PaymentStatus.pending,
      ),
      amount: (map['amount'] ?? 0.0).toDouble(),
      taxAmount: (map['taxAmount'] ?? 0.0).toDouble(),
      discountAmount: (map['discountAmount'] ?? 0.0).toDouble(),
      shippingAmount: (map['shippingAmount'] ?? 0.0).toDouble(),
      totalAmount: (map['totalAmount'] ?? 0.0).toDouble(),
      currency: map['currency'] ?? 'NPR',
      transactionId: map['transactionId'],
      gatewayTransactionId: map['gatewayTransactionId'],
      authorizationCode: map['authorizationCode'],
      paymentToken: map['paymentToken'],
      billingAddress: map['billingAddress'],
      shippingAddress: map['shippingAddress'],
      items: (map['items'] as List<dynamic>?)
              ?.map((item) => PaymentItem.fromMap(item))
              .toList() ??
          [],
      gateway: PaymentGateway.values.firstWhere(
        (gateway) => gateway.name == map['gateway'],
        orElse: () => PaymentGateway.stripe,
      ),
      failureReason: map['failureReason'],
      failureCode: map['failureCode'],
      retryCount: map['retryCount'],
      processedAt: map['processedAt'] != null
          ? DateTime.parse(map['processedAt'])
          : null,
      expiresAt: map['expiresAt'] != null
          ? DateTime.parse(map['expiresAt'])
          : null,
      refundedAt: map['refundedAt'] != null
          ? DateTime.parse(map['refundedAt'])
          : null,
      refundedAmount: map['refundedAmount'],
      refundReason: map['refundReason'],
      metadata: map['metadata'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }
}

/// Payment Method Enum
enum PaymentMethod {
  creditCard,
  debitCard,
  bankTransfer,
  mobileWallet,
  cashOnDelivery,
  paypal,
  khalti,
  esewa,
  imePay,
  connectIPS,
  cheque,
}

/// Payment Status Enum
enum PaymentStatus {
  pending,
  processing,
  completed,
  failed,
  cancelled,
  refunded,
  partiallyRefunded,
  expired,
  authorized,
  captured,
  voided,
}

/// Payment Gateway Enum
enum PaymentGateway {
  stripe,
  paypal,
  khalti,
  esewa,
  imePay,
  connectIPS,
  bankTransfer,
  cashOnDelivery,
}

/// Payment Item Entity
class PaymentItem extends Equatable {
  final String id;
  final String productId;
  final String productName;
  final String productSku;
  final String category;
  final double quantity;
  final double unitPrice;
  final double totalPrice;
  final double discount;
  final double tax;
  final Map<String, dynamic>? metadata;

  const PaymentItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productSku,
    required this.category,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.discount,
    required this.tax,
    this.metadata,
  });

  @override
  List<Object?> get props => [
        id,
        productId,
        productName,
        productSku,
        category,
        quantity,
        unitPrice,
        totalPrice,
        discount,
        tax,
        metadata,
      ];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'productSku': productSku,
      'category': category,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
      'discount': discount,
      'tax': tax,
      'metadata': metadata,
    };
  }

  factory PaymentItem.fromMap(Map<String, dynamic> map) {
    return PaymentItem(
      id: map['id'] ?? '',
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      productSku: map['productSku'] ?? '',
      category: map['category'] ?? '',
      quantity: (map['quantity'] ?? 0.0).toDouble(),
      unitPrice: (map['unitPrice'] ?? 0.0).toDouble(),
      totalPrice: (map['totalPrice'] ?? 0.0).toDouble(),
      discount: (map['discount'] ?? 0.0).toDouble(),
      tax: (map['tax'] ?? 0.0).toDouble(),
      metadata: map['metadata'],
    );
  }
}

/// Checkout Session Entity
class CheckoutSession extends Equatable {
  final String id;
  final String retailerId;
  final List<PaymentItem> items;
  final double subtotal;
  final double taxAmount;
  final double discountAmount;
  final double shippingAmount;
  final double totalAmount;
  final String currency;
  final String? couponCode;
  final double? couponDiscount;
  final Address? billingAddress;
  final Address? shippingAddress;
  final PaymentMethod? selectedPaymentMethod;
  final PaymentGateway? selectedGateway;
  final CheckoutStatus status;
  final String? paymentIntentId;
  final String? clientSecret;
  final DateTime expiresAt;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CheckoutSession({
    required this.id,
    required this.retailerId,
    required this.items,
    required this.subtotal,
    required this.taxAmount,
    required this.discountAmount,
    required this.shippingAddress,
    required this.totalAmount,
    required this.currency,
    this.couponCode,
    this.couponDiscount,
    this.billingAddress,
    this.shippingAddress,
    this.selectedPaymentMethod,
    this.selectedGateway,
    required this.status,
    this.paymentIntentId,
    this.clientSecret,
    required this.expiresAt,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        retailerId,
        items,
        subtotal,
        taxAmount,
        discountAmount,
        shippingAmount,
        totalAmount,
        currency,
        couponCode,
        couponDiscount,
        billingAddress,
        shippingAddress,
        selectedPaymentMethod,
        selectedGateway,
        status,
        paymentIntentId,
        clientSecret,
        expiresAt,
        metadata,
        createdAt,
        updatedAt,
      ];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'retailerId': retailerId,
      'items': items.map((item) => item.toMap()).toList(),
      'subtotal': subtotal,
      'taxAmount': taxAmount,
      'discountAmount': discountAmount,
      'shippingAmount': shippingAmount,
      'totalAmount': totalAmount,
      'currency': currency,
      'couponCode': couponCode,
      'couponDiscount': couponDiscount,
      'billingAddress': billingAddress?.toMap(),
      'shippingAddress': shippingAddress?.toMap(),
      'selectedPaymentMethod': selectedPaymentMethod?.name,
      'selectedGateway': selectedGateway?.name,
      'status': status.name,
      'paymentIntentId': paymentIntentId,
      'clientSecret': clientSecret,
      'expiresAt': expiresAt.toIso8601String(),
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory CheckoutSession.fromMap(Map<String, dynamic> map) {
    return CheckoutSession(
      id: map['id'] ?? '',
      retailerId: map['retailerId'] ?? '',
      items: (map['items'] as List<dynamic>?)
              ?.map((item) => PaymentItem.fromMap(item))
              .toList() ??
          [],
      subtotal: (map['subtotal'] ?? 0.0).toDouble(),
      taxAmount: (map['taxAmount'] ?? 0.0).toDouble(),
      discountAmount: (map['discountAmount'] ?? 0.0).toDouble(),
      shippingAmount: (map['shippingAmount'] ?? 0.0).toDouble(),
      totalAmount: (map['totalAmount'] ?? 0.0).toDouble(),
      currency: map['currency'] ?? 'NPR',
      couponCode: map['couponCode'],
      couponDiscount: map['couponDiscount'],
      billingAddress: map['billingAddress'] != null
          ? Address.fromMap(map['billingAddress'])
          : null,
      shippingAddress: map['shippingAddress'] != null
          ? Address.fromMap(map['shippingAddress'])
          : null,
      selectedPaymentMethod: map['selectedPaymentMethod'] != null
          ? PaymentMethod.values.firstWhere(
              (method) => method.name == map['selectedPaymentMethod'],
              orElse: () => PaymentMethod.creditCard,
            )
          : null,
      selectedGateway: map['selectedGateway'] != null
          ? PaymentGateway.values.firstWhere(
              (gateway) => gateway.name == map['selectedGateway'],
              orElse: () => PaymentGateway.stripe,
            )
          : null,
      status: CheckoutStatus.values.firstWhere(
        (status) => status.name == map['status'],
        orElse: () => CheckoutStatus.cart,
      ),
      paymentIntentId: map['paymentIntentId'],
      clientSecret: map['clientSecret'],
      expiresAt: DateTime.parse(map['expiresAt']),
      metadata: map['metadata'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }
}

/// Checkout Status Enum
enum CheckoutStatus {
  cart,
  address,
  shipping,
  payment,
  processing,
  completed,
  failed,
  cancelled,
  expired,
}

/// Address Entity
class Address extends Equatable {
  final String id;
  final String type; // billing, shipping
  final String name;
  final String phone;
  final String email;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final bool isDefault;
  final Map<String, dynamic>? metadata;

  const Address({
    required this.id,
    required this.type,
    required this.name,
    required this.phone,
    required this.email,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    required this.isDefault,
    this.metadata,
  });

  @override
  List<Object?> get props => [
        id,
        type,
        name,
        phone,
        email,
        addressLine1,
        addressLine2,
        city,
        state,
        postalCode,
        country,
        isDefault,
        metadata,
      ];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'name': name,
      'phone': phone,
      'email': email,
      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'country': country,
      'isDefault': isDefault,
      'metadata': metadata,
    };
  }

  factory Address.fromMap(Map<String, dynamic> map) {
    return Address(
      id: map['id'] ?? '',
      type: map['type'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      addressLine1: map['addressLine1'] ?? '',
      addressLine2: map['addressLine2'],
      city: map['city'] ?? '',
      state: map['state'] ?? '',
      postalCode: map['postalCode'] ?? '',
      country: map['country'] ?? '',
      isDefault: map['isDefault'] ?? false,
      metadata: map['metadata'],
    );
  }
}

/// Coupon Entity
class Coupon extends Equatable {
  final String id;
  final String code;
  final String description;
  final CouponType type;
  final double discountValue;
  final double minimumAmount;
  final double maximumDiscount;
  final int usageLimit;
  final int usedCount;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final List<String> applicableProducts;
  final List<String> applicableCategories;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Coupon({
    required this.id,
    required this.code,
    required this.description,
    required this.type,
    required this.discountValue,
    required this.minimumAmount,
    required this.maximumDiscount,
    required this.usageLimit,
    required this.usedCount,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    required this.applicableProducts,
    required this.applicableCategories,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        code,
        description,
        type,
        discountValue,
        minimumAmount,
        maximumDiscount,
        usageLimit,
        usedCount,
        startDate,
        endDate,
        isActive,
        applicableProducts,
        applicableCategories,
        metadata,
        createdAt,
        updatedAt,
      ];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'description': description,
      'type': type.name,
      'discountValue': discountValue,
      'minimumAmount': minimumAmount,
      'maximumDiscount': maximumDiscount,
      'usageLimit': usageLimit,
      'usedCount': usedCount,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'isActive': isActive,
      'applicableProducts': applicableProducts,
      'applicableCategories': applicableCategories,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Coupon.fromMap(Map<String, dynamic> map) {
    return Coupon(
      id: map['id'] ?? '',
      code: map['code'] ?? '',
      description: map['description'] ?? '',
      type: CouponType.values.firstWhere(
        (type) => type.name == map['type'],
        orElse: () => CouponType.percentage,
      ),
      discountValue: (map['discountValue'] ?? 0.0).toDouble(),
      minimumAmount: (map['minimumAmount'] ?? 0.0).toDouble(),
      maximumDiscount: (map['maximumDiscount'] ?? 0.0).toDouble(),
      usageLimit: map['usageLimit'] ?? 0,
      usedCount: map['usedCount'] ?? 0,
      startDate: DateTime.parse(map['startDate']),
      endDate: DateTime.parse(map['endDate']),
      isActive: map['isActive'] ?? true,
      applicableProducts: List<String>.from(map['applicableProducts'] ?? []),
      applicableCategories: List<String>.from(map['applicableCategories'] ?? []),
      metadata: map['metadata'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }
}

/// Coupon Type Enum
enum CouponType {
  percentage,
  fixedAmount,
  freeShipping,
  buyOneGetOne,
}
