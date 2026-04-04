// Payment Method Model
class PaymentMethod {
  final String id;
  final String name;
  final PaymentType type;
  final String description;
  final String icon;
  final bool isEnabled;
  final double fee;
  final FeeType feeType;
  final double minAmount;
  final double maxAmount;
  final Duration processingTime;
  final List<String> supportedRegions;
  final Map<String, dynamic>? metadata;
  final List<String>? requiredFields;

  const PaymentMethod({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.icon,
    required this.isEnabled,
    required this.fee,
    required this.feeType,
    required this.minAmount,
    required this.maxAmount,
    required this.processingTime,
    required this.supportedRegions,
    this.metadata,
    this.requiredFields,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'] as String,
      name: json['name'] as String,
      type: PaymentType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => PaymentType.cod,
      ),
      description: json['description'] as String,
      icon: json['icon'] as String,
      isEnabled: json['isEnabled'] as bool,
      fee: (json['fee'] as num).toDouble(),
      feeType: FeeType.values.firstWhere(
        (e) => e.toString() == json['feeType'],
        orElse: () => FeeType.fixed,
      ),
      minAmount: (json['minAmount'] as num).toDouble(),
      maxAmount: (json['maxAmount'] as num).toDouble(),
      processingTime: Duration(
        milliseconds: (json['processingTimeMs'] as num?)?.toInt() ?? 0,
      ),
      supportedRegions: List<String>.from(json['supportedRegions'] as List),
      metadata: json['metadata'] as Map<String, dynamic>?,
      requiredFields: json['requiredFields'] != null
          ? List<String>.from(json['requiredFields'] as List)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.toString(),
      'description': description,
      'icon': icon,
      'isEnabled': isEnabled,
      'fee': fee,
      'feeType': feeType.toString(),
      'minAmount': minAmount,
      'maxAmount': maxAmount,
      'processingTimeMs': processingTime.inMilliseconds,
      'supportedRegions': supportedRegions,
      'metadata': metadata,
      'requiredFields': requiredFields,
    };
  }

  // Computed properties
  double calculateFee(double amount) {
    switch (feeType) {
      case FeeType.fixed:
        return fee;
      case FeeType.percentage:
        return amount * (fee / 100);
      case FeeType.tiered:
        return _calculateTieredFee(amount);
    }
  }

  double _calculateTieredFee(double amount) {
    // Mock tiered fee calculation
    if (amount <= 1000) return 10.0;
    if (amount <= 5000) return 25.0;
    if (amount <= 10000) return 50.0;
    return 100.0;
  }

  bool isAvailableForAmount(double amount) {
    return amount >= minAmount && amount <= maxAmount;
  }

  bool isAvailableForRegion(String region) {
    return supportedRegions.contains('All Nepal') || supportedRegions.contains(region);
  }

  String get processingTimeText {
    if (processingTime.inSeconds < 60) {
      return 'Instant';
    } else if (processingTime.inMinutes < 60) {
      return '${processingTime.inMinutes} min';
    } else {
      return '${processingTime.inHours} hours';
    }
  }
}

// Payment Request Model
class PaymentRequest {
  final String paymentMethodId;
  final double amount;
  final String currency;
  final String? transactionId;
  final Map<String, dynamic> paymentDetails;
  final String? returnUrl;
  final String? cancelUrl;
  final String? callbackUrl;
  final Map<String, dynamic>? metadata;

  const PaymentRequest({
    required this.paymentMethodId,
    required this.amount,
    required this.currency,
    this.transactionId,
    required this.paymentDetails,
    this.returnUrl,
    this.cancelUrl,
    this.callbackUrl,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'paymentMethodId': paymentMethodId,
      'amount': amount,
      'currency': currency,
      'transactionId': transactionId,
      'paymentDetails': paymentDetails,
      'returnUrl': returnUrl,
      'cancelUrl': cancelUrl,
      'callbackUrl': callbackUrl,
      'metadata': metadata,
    };
  }
}

// Payment Result Model
class PaymentResult {
  final bool success;
  final String? transactionId;
  final String paymentMethodId;
  final double amount;
  final String currency;
  final PaymentStatus status;
  final DateTime processedAt;
  final String? failureReason;
  final Map<String, dynamic> metadata;
  final String? gatewayResponse;
  final String? receiptUrl;

  const PaymentResult({
    required this.success,
    this.transactionId,
    required this.paymentMethodId,
    required this.amount,
    required this.currency,
    required this.status,
    required this.processedAt,
    this.failureReason,
    required this.metadata,
    this.gatewayResponse,
    this.receiptUrl,
  });

  factory PaymentResult.fromJson(Map<String, dynamic> json) {
    return PaymentResult(
      success: json['success'] as bool,
      transactionId: json['transactionId'] as String?,
      paymentMethodId: json['paymentMethodId'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      status: PaymentStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => PaymentStatus.pending,
      ),
      processedAt: DateTime.parse(json['processedAt'] as String),
      failureReason: json['failureReason'] as String?,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map),
      gatewayResponse: json['gatewayResponse'] as String?,
      receiptUrl: json['receiptUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'transactionId': transactionId,
      'paymentMethodId': paymentMethodId,
      'amount': amount,
      'currency': currency,
      'status': status.toString(),
      'processedAt': processedAt.toIso8601String(),
      'failureReason': failureReason,
      'metadata': metadata,
      'gatewayResponse': gatewayResponse,
      'receiptUrl': receiptUrl,
    };
  }
}

// Payment Details Models
class DigitalWalletPaymentDetails {
  final String walletId;
  final String phoneNumber;
  final String? verificationCode;

  const DigitalWalletPaymentDetails({
    required this.walletId,
    required this.phoneNumber,
    this.verificationCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'walletId': walletId,
      'phoneNumber': phoneNumber,
      'verificationCode': verificationCode,
    };
  }
}

class CardPaymentDetails {
  final String cardNumber;
  final String expiryMonth;
  final String expiryYear;
  final String cvv;
  final String cardholderName;
  final String? billingAddress;

  const CardPaymentDetails({
    required this.cardNumber,
    required this.expiryMonth,
    required this.expiryYear,
    required this.cvv,
    required this.cardholderName,
    this.billingAddress,
  });

  Map<String, dynamic> toJson() {
    return {
      'cardNumber': cardNumber,
      'expiryMonth': expiryMonth,
      'expiryYear': expiryYear,
      'cvv': cvv,
      'cardholderName': cardholderName,
      'billingAddress': billingAddress,
    };
  }
}

class BankTransferDetails {
  final String bankName;
  final String accountNumber;
  final String accountHolderName;
  final String? branchName;
  final String? transactionReference;

  const BankTransferDetails({
    required this.bankName,
    required this.accountNumber,
    required this.accountHolderName,
    this.branchName,
    this.transactionReference,
  });

  Map<String, dynamic> toJson() {
    return {
      'bankName': bankName,
      'accountNumber': accountNumber,
      'accountHolderName': accountHolderName,
      'branchName': branchName,
      'transactionReference': transactionReference,
    };
  }
}

// Payment Transaction Model
class PaymentTransaction {
  final String id;
  final String orderId;
  final String paymentMethodId;
  final double amount;
  final String currency;
  final PaymentStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? transactionId;
  final String? gatewayTransactionId;
  final String? failureReason;
  final Map<String, dynamic> metadata;
  final List<PaymentAttempt> attempts;

  const PaymentTransaction({
    required this.id,
    required this.orderId,
    required this.paymentMethodId,
    required this.amount,
    required this.currency,
    required this.status,
    required this.createdAt,
    this.completedAt,
    this.transactionId,
    this.gatewayTransactionId,
    this.failureReason,
    required this.metadata,
    required this.attempts,
  });

  factory PaymentTransaction.fromJson(Map<String, dynamic> json) {
    return PaymentTransaction(
      id: json['id'] as String,
      orderId: json['orderId'] as String,
      paymentMethodId: json['paymentMethodId'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      status: PaymentStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => PaymentStatus.pending,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      transactionId: json['transactionId'] as String?,
      gatewayTransactionId: json['gatewayTransactionId'] as String?,
      failureReason: json['failureReason'] as String?,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map),
      attempts: (json['attempts'] as List)
          .map((attempt) => PaymentAttempt.fromJson(attempt))
          .toList(),
    );
  }

  // Computed properties
  bool get isCompleted => status == PaymentStatus.completed;
  
  bool get isFailed => status == PaymentStatus.failed;
  
  bool get isPending => status == PaymentStatus.pending;
  
  int get totalAttempts => attempts.length;
  
  Duration? get processingDuration {
    if (completedAt != null) {
      return completedAt!.difference(createdAt);
    }
    return null;
  }
}

// Payment Attempt Model
class PaymentAttempt {
  final String id;
  final DateTime timestamp;
  final PaymentStatus status;
  final String? gatewayResponse;
  final String? errorMessage;
  final Map<String, dynamic> requestPayload;
  final Duration processingTime;

  const PaymentAttempt({
    required this.id,
    required this.timestamp,
    required this.status,
    this.gatewayResponse,
    this.errorMessage,
    required this.requestPayload,
    required this.processingTime,
  });

  factory PaymentAttempt.fromJson(Map<String, dynamic> json) {
    return PaymentAttempt(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      status: PaymentStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => PaymentStatus.pending,
      ),
      gatewayResponse: json['gatewayResponse'] as String?,
      errorMessage: json['errorMessage'] as String?,
      requestPayload: Map<String, dynamic>.from(json['requestPayload'] as Map),
      processingTime: Duration(
        milliseconds: (json['processingTimeMs'] as num).toInt(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'status': status.toString(),
      'gatewayResponse': gatewayResponse,
      'errorMessage': errorMessage,
      'requestPayload': requestPayload,
      'processingTimeMs': processingTime.inMilliseconds,
    };
  }
}

// Payment Gateway Configuration
class PaymentGatewayConfig {
  final String gatewayId;
  final String name;
  final bool isEnabled;
  final Map<String, String> credentials;
  final Map<String, dynamic> settings;
  final List<String> supportedMethods;
  final String environment;

  const PaymentGatewayConfig({
    required this.gatewayId,
    required this.name,
    required this.isEnabled,
    required this.credentials,
    required this.settings,
    required this.supportedMethods,
    required this.environment,
  });

  factory PaymentGatewayConfig.fromJson(Map<String, dynamic> json) {
    return PaymentGatewayConfig(
      gatewayId: json['gatewayId'] as String,
      name: json['name'] as String,
      isEnabled: json['isEnabled'] as bool,
      credentials: Map<String, String>.from(json['credentials'] as Map),
      settings: Map<String, dynamic>.from(json['settings'] as Map),
      supportedMethods: List<String>.from(json['supportedMethods'] as List),
      environment: json['environment'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gatewayId': gatewayId,
      'name': name,
      'isEnabled': isEnabled,
      'credentials': credentials,
      'settings': settings,
      'supportedMethods': supportedMethods,
      'environment': environment,
    };
  }
}

// Payment Analytics
class PaymentAnalytics {
  final DateTime period;
  final int totalTransactions;
  final double totalRevenue;
  final double successRate;
  final double averageProcessingTime;
  final Map<String, int> transactionsByMethod;
  final Map<PaymentStatus, int> transactionsByStatus;
  final List<PaymentMethod> topMethods;

  const PaymentAnalytics({
    required this.period,
    required this.totalTransactions,
    required this.totalRevenue,
    required this.successRate,
    required this.averageProcessingTime,
    required this.transactionsByMethod,
    required this.transactionsByStatus,
    required this.topMethods,
  });

  factory PaymentAnalytics.fromJson(Map<String, dynamic> json) {
    return PaymentAnalytics(
      period: DateTime.parse(json['period'] as String),
      totalTransactions: (json['totalTransactions'] as num).toInt(),
      totalRevenue: (json['totalRevenue'] as num).toDouble(),
      successRate: (json['successRate'] as num).toDouble(),
      averageProcessingTime: Duration(
        milliseconds: (json['averageProcessingTimeMs'] as num).toInt(),
      ),
      transactionsByMethod: Map<String, int>.from(json['transactionsByMethod'] as Map),
      transactionsByStatus: Map.from(
        (json['transactionsByStatus'] as Map).map(
          (key, value) => MapEntry(
            PaymentStatus.values.firstWhere(
              (e) => e.toString() == key,
              orElse: () => PaymentStatus.pending,
            ),
            value as int,
          ),
        ),
      ),
      topMethods: (json['topMethods'] as List)
          .map((method) => PaymentMethod.fromJson(method))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'period': period.toIso8601String(),
      'totalTransactions': totalTransactions,
      'totalRevenue': totalRevenue,
      'successRate': successRate,
      'averageProcessingTimeMs': averageProcessingTime.inMilliseconds,
      'transactionsByMethod': transactionsByMethod,
      'transactionsByStatus': transactionsByStatus.map(
        (key, value) => MapEntry(key.toString(), value),
      ),
      'topMethods': topMethods.map((method) => method.toJson()).toList(),
    };
  }
}

// Enums
enum PaymentType {
  cod, // Cash on Delivery
  digital, // Digital Wallet (Khalti, eSewa)
  bank, // Bank Transfer
  card, // Credit/Debit Card
  upi, // Unified Payment Interface
  crypto, // Cryptocurrency
}

enum FeeType {
  fixed,
  percentage,
  tiered,
}

enum PaymentStatus {
  pending,
  processing,
  completed,
  failed,
  cancelled,
  refunded,
  partially_refunded,
}

// Payment Validation Result
class PaymentValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;
  final Map<String, dynamic> metadata;

  const PaymentValidationResult({
    required this.isValid,
    required this.errors,
    required this.warnings,
    required this.metadata,
  });

  static PaymentValidationResult success({List<String> warnings = const [], Map<String, dynamic>? metadata}) {
    return PaymentValidationResult(
      isValid: true,
      errors: [],
      warnings: warnings,
      metadata: metadata ?? {},
    );
  }

  static PaymentValidationResult failure(List<String> errors, {List<String> warnings = const [], Map<String, dynamic>? metadata}) {
    return PaymentValidationResult(
      isValid: false,
      errors: errors,
      warnings: warnings,
      metadata: metadata ?? {},
    );
  }
}
