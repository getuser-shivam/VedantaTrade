import 'package:equatable/equatable.dart';

/// Expense Entity for VedantaTrade
/// Represents expense transactions with receipt management

class ExpenseEntity extends Equatable {
  final String id;
  final String mrId;
  final String mrName;
  final String retailerId;
  final String retailerName;
  final String expenseType;
  final ExpenseCategory category;
  final double amount;
  final String currency;
  final DateTime expenseDate;
  final String description;
  final List<ExpenseReceipt> receipts;
  final ExpenseStatus status;
  final String? approvedBy;
  final DateTime? approvedAt;
  final String? rejectedBy;
  final DateTime? rejectedAt;
  final String? rejectionReason;
  final String? referenceNumber;
  final String? supplierName;
  final String? supplierInvoice;
  final List<ExpenseItem> items;
  final PaymentMethod paymentMethod;
  final String? paymentReference;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ExpenseEntity({
    required this.id,
    required this.mrId,
    required this.mrName,
    required this.retailerId,
    required this.retailerName,
    required this.expenseType,
    required this.category,
    required this.amount,
    required this.currency,
    required this.expenseDate,
    required this.description,
    required this.receipts,
    required this.status,
    required this.items,
    required this.paymentMethod,
    this.approvedBy,
    this.approvedAt,
    this.rejectedBy,
    this.rejectedAt,
    this.rejectionReason,
    this.referenceNumber,
    this.supplierName,
    this.supplierInvoice,
    this.paymentReference,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        mrId,
        mrName,
        retailerId,
        retailerName,
        expenseType,
        category,
        amount,
        currency,
        expenseDate,
        description,
        receipts,
        status,
        approvedBy,
        approvedAt,
        rejectedBy,
        rejectedAt,
        rejectionReason,
        referenceNumber,
        supplierName,
        supplierInvoice,
        items,
        paymentMethod,
        paymentReference,
        metadata,
        createdAt,
        updatedAt,
      ];

  ExpenseEntity copyWith({
    String? id,
    String? mrId,
    String? mrName,
    String? retailerId,
    String? retailerName,
    String? expenseType,
    ExpenseCategory? category,
    double? amount,
    String? currency,
    DateTime? expenseDate,
    String? description,
    List<ExpenseReceipt>? receipts,
    ExpenseStatus? status,
    String? approvedBy,
    DateTime? approvedAt,
    String? rejectedBy,
    DateTime? rejectedAt,
    String? rejectionReason,
    String? referenceNumber,
    String? supplierName,
    String? supplierInvoice,
    List<ExpenseItem>? items,
    PaymentMethod? paymentMethod,
    String? paymentReference,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ExpenseEntity(
      id: id ?? this.id,
      mrId: mrId ?? this.mrId,
      mrName: mrName ?? this.mrName,
      retailerId: retailerId ?? this.retailerId,
      retailerName: retailerName ?? this.retailerName,
      expenseType: expenseType ?? this.expenseType,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      expenseDate: expenseDate ?? this.expenseDate,
      description: description ?? this.description,
      receipts: receipts ?? this.receipts,
      status: status ?? this.status,
      approvedBy: approvedBy ?? this.approvedBy,
      approvedAt: approvedAt ?? this.approvedAt,
      rejectedBy: rejectedBy ?? this.rejectedBy,
      rejectedAt: rejectedAt ?? this.rejectedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      supplierName: supplierName ?? this.supplierName,
      supplierInvoice: supplierInvoice ?? this.supplierInvoice,
      items: items ?? this.items,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentReference: paymentReference ?? this.paymentReference,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'mrId': mrId,
      'mrName': mrName,
      'retailerId': retailerId,
      'retailerName': retailerName,
      'expenseType': expenseType,
      'category': category.name,
      'amount': amount,
      'currency': currency,
      'expenseDate': expenseDate.toIso8601String(),
      'description': description,
      'receipts': receipts.map((receipt) => receipt.toMap()).toList(),
      'status': status.name,
      'approvedBy': approvedBy,
      'approvedAt': approvedAt?.toIso8601String(),
      'rejectedBy': rejectedBy,
      'rejectedAt': rejectedAt?.toIso8601String(),
      'rejectionReason': rejectionReason,
      'referenceNumber': referenceNumber,
      'supplierName': supplierName,
      'supplierInvoice': supplierInvoice,
      'items': items.map((item) => item.toMap()).toList(),
      'paymentMethod': paymentMethod.name,
      'paymentReference': paymentReference,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ExpenseEntity.fromMap(Map<String, dynamic> map) {
    return ExpenseEntity(
      id: map['id'] ?? '',
      mrId: map['mrId'] ?? '',
      mrName: map['mrName'] ?? '',
      retailerId: map['retailerId'] ?? '',
      retailerName: map['retailerName'] ?? '',
      expenseType: map['expenseType'] ?? '',
      category: ExpenseCategory.values.firstWhere(
        (category) => category.name == map['category'],
        orElse: () => ExpenseCategory.travel,
      ),
      amount: (map['amount'] ?? 0.0).toDouble(),
      currency: map['currency'] ?? 'NPR',
      expenseDate: DateTime.parse(map['expenseDate']),
      description: map['description'] ?? '',
      receipts: (map['receipts'] as List<dynamic>?)
              ?.map((receipt) => ExpenseReceipt.fromMap(receipt))
              .toList() ??
          [],
      status: ExpenseStatus.values.firstWhere(
        (status) => status.name == map['status'],
        orElse: () => ExpenseStatus.pending,
      ),
      approvedBy: map['approvedBy'],
      approvedAt: map['approvedAt'] != null
          ? DateTime.parse(map['approvedAt'])
          : null,
      rejectedBy: map['rejectedBy'],
      rejectedAt: map['rejectedAt'] != null
          ? DateTime.parse(map['rejectedAt'])
          : null,
      rejectionReason: map['rejectionReason'],
      referenceNumber: map['referenceNumber'],
      supplierName: map['supplierName'],
      supplierInvoice: map['supplierInvoice'],
      items: (map['items'] as List<dynamic>?)
              ?.map((item) => ExpenseItem.fromMap(item))
              .toList() ??
          [],
      paymentMethod: PaymentMethod.values.firstWhere(
        (method) => method.name == map['paymentMethod'],
        orElse: () => PaymentMethod.cash,
      ),
      paymentReference: map['paymentReference'],
      metadata: map['metadata'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }
}

/// Expense Status Enum
enum ExpenseStatus {
  pending,
  submitted,
  underReview,
  approved,
  rejected,
  paid,
  reimbursed,
  archived,
}

/// Expense Category Enum
enum ExpenseCategory {
  travel,
  accommodation,
  meals,
  transportation,
  communication,
  office,
  marketing,
  entertainment,
  training,
  equipment,
  supplies,
  utilities,
  insurance,
  taxes,
  other,
}

/// Payment Method Enum
enum PaymentMethod {
  cash,
  creditCard,
  debitCard,
  bankTransfer,
  mobileWallet,
  cheque,
  companyCard,
  reimbursement,
}

/// Expense Receipt Entity
class ExpenseReceipt extends Equatable {
  final String id;
  final String expenseId;
  final String receiptType;
  final List<String> imageUrls;
  final List<String> thumbnailUrls;
  final DateTime? receiptDate;
  final String? merchantName;
  final String? merchantAddress;
  final double? amount;
  final String? currency;
  final String? receiptNumber;
  final String? notes;
  final ReceiptStatus status;
  final String? uploadedBy;
  final DateTime? uploadedAt;
  final String? verifiedBy;
  final DateTime? verifiedAt;
  final String? rejectionReason;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ExpenseReceipt({
    required this.id,
    required this.expenseId,
    required this.receiptType,
    required this.imageUrls,
    required this.thumbnailUrls,
    this.receiptDate,
    this.merchantName,
    this.merchantAddress,
    this.amount,
    this.currency,
    this.receiptNumber,
    this.notes,
    required this.status,
    this.uploadedBy,
    this.uploadedAt,
    this.verifiedBy,
    this.verifiedAt,
    this.rejectionReason,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        expenseId,
        receiptType,
        imageUrls,
        thumbnailUrls,
        receiptDate,
        merchantName,
        merchantAddress,
        amount,
        currency,
        receiptNumber,
        notes,
        status,
        uploadedBy,
        uploadedAt,
        verifiedBy,
        verifiedAt,
        rejectionReason,
        metadata,
        createdAt,
        updatedAt,
      ];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'expenseId': expenseId,
      'receiptType': receiptType,
      'imageUrls': imageUrls,
      'thumbnailUrls': thumbnailUrls,
      'receiptDate': receiptDate?.toIso8601String(),
      'merchantName': merchantName,
      'merchantAddress': merchantAddress,
      'amount': amount,
      'currency': currency,
      'receiptNumber': receiptNumber,
      'notes': notes,
      'status': status.name,
      'uploadedBy': uploadedBy,
      'uploadedAt': uploadedAt?.toIso8601String(),
      'verifiedBy': verifiedBy,
      'verifiedAt': verifiedAt?.toIso8601String(),
      'rejectionReason': rejectionReason,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ExpenseReceipt.fromMap(Map<String, dynamic> map) {
    return ExpenseReceipt(
      id: map['id'] ?? '',
      expenseId: map['expenseId'] ?? '',
      receiptType: map['receiptType'] ?? '',
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      thumbnailUrls: List<String>.from(map['thumbnailUrls'] ?? []),
      receiptDate: map['receiptDate'] != null
          ? DateTime.parse(map['receiptDate'])
          : null,
      merchantName: map['merchantName'],
      merchantAddress: map['merchantAddress'],
      amount: map['amount']?.toDouble(),
      currency: map['currency'],
      receiptNumber: map['receiptNumber'],
      notes: map['notes'],
      status: ReceiptStatus.values.firstWhere(
        (status) => status.name == map['status'],
        orElse: () => ReceiptStatus.uploaded,
      ),
      uploadedBy: map['uploadedBy'],
      uploadedAt: map['uploadedAt'] != null
          ? DateTime.parse(map['uploadedAt'])
          : null,
      verifiedBy: map['verifiedBy'],
      verifiedAt: map['verifiedAt'] != null
          ? DateTime.parse(map['verifiedAt'])
          : null,
      rejectionReason: map['rejectionReason'],
      metadata: map['metadata'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }
}

/// Receipt Status Enum
enum ReceiptStatus {
  uploaded,
  processing,
  verified,
  rejected,
  approved,
}

/// Expense Item Entity
class ExpenseItem extends Equatable {
  final String id;
  final String expenseId;
  final String itemName;
  final String? description;
  final String? category;
  final double quantity;
  final double unitPrice;
  final double totalPrice;
  final String? uom; // Unit of Measure
  final String? sku;
  final Map<String, dynamic>? metadata;

  const ExpenseItem({
    required this.id,
    required this.expenseId,
    required this.itemName,
    this.description,
    this.category,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.uom,
    this.sku,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        expenseId,
        itemName,
        description,
        category,
        quantity,
        unitPrice,
        totalPrice,
        uom,
        sku,
        metadata,
        createdAt,
        updatedAt,
      ];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'expenseId': expenseId,
      'itemName': itemName,
      'description': description,
      'category': category,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
      'uom': uom,
      'sku': sku,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ExpenseItem.fromMap(Map<String, dynamic> map) {
    return ExpenseItem(
      id: map['id'] ?? '',
      expenseId: map['expenseId'] ?? '',
      itemName: map['itemName'] ?? '',
      description: map['description'],
      category: map['category'],
      quantity: (map['quantity'] ?? 0.0).toDouble(),
      unitPrice: (map['unitPrice'] ?? 0.0).toDouble(),
      totalPrice: (map['totalPrice'] ?? 0.0).toDouble(),
      uom: map['uom'],
      sku: map['sku'],
      metadata: map['metadata'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }
}

/// Expense Report Entity
class ExpenseReport extends Equatable {
  final String id;
  final String mrId;
  final String mrName;
  final String retailerId;
  final String retailerName;
  final DateTime reportPeriodStart;
  final DateTime reportPeriodEnd;
  final double totalExpenses;
  final double approvedExpenses;
  final double pendingExpenses;
  final double rejectedExpenses;
  final Map<ExpenseCategory, double> expensesByCategory;
  final List<ExpenseEntity> expenses;
  final ReportStatus status;
  final String? generatedBy;
  final DateTime? generatedAt;
  final String? approvedBy;
  final DateTime? approvedAt;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ExpenseReport({
    required this.id,
    required this.mrId,
    required this.mrName,
    required this.retailerId,
    required this.retailerName,
    required this.reportPeriodStart,
    required this.reportPeriodEnd,
    required this.totalExpenses,
    required this.approvedExpenses,
    required this.pendingExpenses,
    required this.rejectedExpenses,
    required this.expensesByCategory,
    required this.expenses,
    required this.status,
    this.generatedBy,
    this.generatedAt,
    this.approvedBy,
    this.approvedAt,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        mrId,
        mrName,
        retailerId,
        retailerName,
        reportPeriodStart,
        reportPeriodEnd,
        totalExpenses,
        approvedExpenses,
        pendingExpenses,
        rejectedExpenses,
        expensesByCategory,
        expenses,
        status,
        generatedBy,
        generatedAt,
        approvedBy,
        approvedAt,
        metadata,
        createdAt,
        updatedAt,
      ];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'mrId': mrId,
      'mrName': mrName,
      'retailerId': retailerId,
      'retailerName': retailerName,
      'reportPeriodStart': reportPeriodStart.toIso8601String(),
      'reportPeriodEnd': reportPeriodEnd.toIso8601String(),
      'totalExpenses': totalExpenses,
      'approvedExpenses': approvedExpenses,
      'pendingExpenses': pendingExpenses,
      'rejectedExpenses': rejectedExpenses,
      'expensesByCategory': expensesByCategory.map(
        (key, value) => MapEntry(key.name, value),
      ),
      'expenses': expenses.map((expense) => expense.toMap()).toList(),
      'status': status.name,
      'generatedBy': generatedBy,
      'generatedAt': generatedAt?.toIso8601String(),
      'approvedBy': approvedBy,
      'approvedAt': approvedAt?.toIso8601String(),
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ExpenseReport.fromMap(Map<String, dynamic> map) {
    return ExpenseReport(
      id: map['id'] ?? '',
      mrId: map['mrId'] ?? '',
      mrName: map['mrName'] ?? '',
      retailerId: map['retailerId'] ?? '',
      retailerName: map['retailerName'] ?? '',
      reportPeriodStart: DateTime.parse(map['reportPeriodStart']),
      reportPeriodEnd: DateTime.parse(map['reportPeriodEnd']),
      totalExpenses: (map['totalExpenses'] ?? 0.0).toDouble(),
      approvedExpenses: (map['approvedExpenses'] ?? 0.0).toDouble(),
      pendingExpenses: (map['pendingExpenses'] ?? 0.0).toDouble(),
      rejectedExpenses: (map['rejectedExpenses'] ?? 0.0).toDouble(),
      expensesByCategory: (map['expensesByCategory'] as Map<String, dynamic>?)
              ?.map((key, value) => MapEntry(
                    ExpenseCategory.values.firstWhere(
                      (category) => category.name == key,
                      orElse: () => ExpenseCategory.other,
                    ),
                    value.toDouble(),
                  )) ??
          {},
      expenses: (map['expenses'] as List<dynamic>?)
              ?.map((expense) => ExpenseEntity.fromMap(expense))
              .toList() ??
          [],
      status: ReportStatus.values.firstWhere(
        (status) => status.name == map['status'],
        orElse: () => ReportStatus.draft,
      ),
      generatedBy: map['generatedBy'],
      generatedAt: map['generatedAt'] != null
          ? DateTime.parse(map['generatedAt'])
          : null,
      approvedBy: map['approvedBy'],
      approvedAt: map['approvedAt'] != null
          ? DateTime.parse(map['approvedAt'])
          : null,
      metadata: map['metadata'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }
}

/// Report Status Enum
enum ReportStatus {
  draft,
  generated,
  submitted,
  underReview,
  approved,
  rejected,
  archived,
}
