import 'package:vedanta_trade/features/accounting/domain/entities/accounting_entities.dart';

/// Expense Model - Data transfer object for API and database
class ExpenseModel {
  final String id;
  final String mrId;
  final String mrName;
  final double amount;
  final String category;
  final String description;
  final DateTime date;
  final String status;
  final int receiptCount;
  final List<String> receiptUrls;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ExpenseModel({
    required this.id,
    required this.mrId,
    required this.mrName,
    required this.amount,
    required this.category,
    required this.description,
    required this.date,
    this.status = 'pending',
    this.receiptCount = 0,
    this.receiptUrls = const [],
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create from JSON
  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'] as String,
      mrId: json['mrId'] as String,
      mrName: json['mrName'] as String,
      amount: (json['amount'] as num).toDouble(),
      category: json['category'] as String,
      description: json['description'] as String,
      date: DateTime.parse(json['date'] as String),
      status: json['status'] as String? ?? 'pending',
      receiptCount: json['receiptCount'] as int? ?? 0,
      receiptUrls: (json['receiptUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mrId': mrId,
      'mrName': mrName,
      'amount': amount,
      'category': category,
      'description': description,
      'date': date.toIso8601String(),
      'status': status,
      'receiptCount': receiptCount,
      'receiptUrls': receiptUrls,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Convert to entity
  ExpenseEntity toEntity() {
    return ExpenseEntity(
      id: id,
      mrId: mrId,
      mrName: mrName,
      amount: amount,
      category: category,
      description: description,
      date: date,
      status: status,
      receiptCount: receiptCount,
      receiptUrls: receiptUrls,
      notes: notes,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Create from entity
  factory ExpenseModel.fromEntity(ExpenseEntity entity) {
    return ExpenseModel(
      id: entity.id,
      mrId: entity.mrId,
      mrName: entity.mrName,
      amount: entity.amount,
      category: entity.category,
      description: entity.description,
      date: entity.date,
      status: entity.status,
      receiptCount: entity.receiptCount,
      receiptUrls: entity.receiptUrls,
      notes: entity.notes,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}

/// VAT Return Model - Data transfer object for API and database
class VatReturnModel {
  final String id;
  final String period;
  final double totalSales;
  final double vatAmount;
  final double totalPurchases;
  final double vatPaid;
  final double netVatPayable;
  final String status;
  final DateTime? filedDate;
  final DateTime dueDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const VatReturnModel({
    required this.id,
    required this.period,
    required this.totalSales,
    required this.vatAmount,
    required this.totalPurchases,
    required this.vatPaid,
    required this.netVatPayable,
    this.status = 'draft',
    this.filedDate,
    required this.dueDate,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create from JSON
  factory VatReturnModel.fromJson(Map<String, dynamic> json) {
    return VatReturnModel(
      id: json['id'] as String,
      period: json['period'] as String,
      totalSales: (json['totalSales'] as num).toDouble(),
      vatAmount: (json['vatAmount'] as num).toDouble(),
      totalPurchases: (json['totalPurchases'] as num).toDouble(),
      vatPaid: (json['vatPaid'] as num).toDouble(),
      netVatPayable: (json['netVatPayable'] as num).toDouble(),
      status: json['status'] as String? ?? 'draft',
      filedDate: json['filedDate'] != null ? DateTime.parse(json['filedDate'] as String) : null,
      dueDate: DateTime.parse(json['dueDate'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'period': period,
      'totalSales': totalSales,
      'vatAmount': vatAmount,
      'totalPurchases': totalPurchases,
      'vatPaid': vatPaid,
      'netVatPayable': netVatPayable,
      'status': status,
      'filedDate': filedDate?.toIso8601String(),
      'dueDate': dueDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Convert to entity
  VatReturnEntity toEntity() {
    return VatReturnEntity(
      id: id,
      period: period,
      totalSales: totalSales,
      vatAmount: vatAmount,
      totalPurchases: totalPurchases,
      vatPaid: vatPaid,
      netVatPayable: netVatPayable,
      status: status,
      filedDate: filedDate,
      dueDate: dueDate,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Create from entity
  factory VatReturnModel.fromEntity(VatReturnEntity entity) {
    return VatReturnModel(
      id: entity.id,
      period: entity.period,
      totalSales: entity.totalSales,
      vatAmount: entity.vatAmount,
      totalPurchases: entity.totalPurchases,
      vatPaid: entity.vatPaid,
      netVatPayable: entity.netVatPayable,
      status: entity.status,
      filedDate: entity.filedDate,
      dueDate: entity.dueDate,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}

/// Invoice Model - Data transfer object for API and database
class InvoiceModel {
  final String id;
  final String invoiceNumber;
  final String customerId;
  final String customerName;
  final double totalAmount;
  final double vatAmount;
  final double finalAmount;
  final DateTime dueDate;
  final String status;
  final List<InvoiceItemModel> items;
  final DateTime createdAt;
  final DateTime updatedAt;

  const InvoiceModel({
    required this.id,
    required this.invoiceNumber,
    required this.customerId,
    required this.customerName,
    required this.totalAmount,
    required this.vatAmount,
    required this.finalAmount,
    required this.dueDate,
    this.status = 'draft',
    this.items = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create from JSON
  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      id: json['id'] as String,
      invoiceNumber: json['invoiceNumber'] as String,
      customerId: json['customerId'] as String,
      customerName: json['customerName'] as String,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      vatAmount: (json['vatAmount'] as num).toDouble(),
      finalAmount: (json['finalAmount'] as num).toDouble(),
      dueDate: DateTime.parse(json['dueDate'] as String),
      status: json['status'] as String? ?? 'draft',
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => InvoiceItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoiceNumber': invoiceNumber,
      'customerId': customerId,
      'customerName': customerName,
      'totalAmount': totalAmount,
      'vatAmount': vatAmount,
      'finalAmount': finalAmount,
      'dueDate': dueDate.toIso8601String(),
      'status': status,
      'items': items.map((item) => item.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Convert to entity
  InvoiceEntity toEntity() {
    return InvoiceEntity(
      id: id,
      invoiceNumber: invoiceNumber,
      customerId: customerId,
      customerName: customerName,
      totalAmount: totalAmount,
      vatAmount: vatAmount,
      finalAmount: finalAmount,
      dueDate: dueDate,
      status: status,
      items: items.map((item) => item.toEntity()).toList(),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Create from entity
  factory InvoiceModel.fromEntity(InvoiceEntity entity) {
    return InvoiceModel(
      id: entity.id,
      invoiceNumber: entity.invoiceNumber,
      customerId: entity.customerId,
      customerName: entity.customerName,
      totalAmount: entity.totalAmount,
      vatAmount: entity.vatAmount,
      finalAmount: entity.finalAmount,
      dueDate: entity.dueDate,
      status: entity.status,
      items: entity.items.map((item) => InvoiceItemModel.fromEntity(item)).toList(),
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}

/// Invoice Item Model - Data transfer object for API and database
class InvoiceItemModel {
  final String id;
  final String productId;
  final String productName;
  final String sku;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final double vatRate;
  final double vatAmount;

  const InvoiceItemModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.sku,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.vatRate = 0.13,
    required this.vatAmount,
  });

  /// Create from JSON
  factory InvoiceItemModel.fromJson(Map<String, dynamic> json) {
    return InvoiceItemModel(
      id: json['id'] as String,
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      sku: json['sku'] as String,
      quantity: json['quantity'] as int,
      unitPrice: (json['unitPrice'] as num).toDouble(),
      totalPrice: (json['totalPrice'] as num).toDouble(),
      vatRate: (json['vatRate'] as num?)?.toDouble() ?? 0.13,
      vatAmount: (json['vatAmount'] as num).toDouble(),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'sku': sku,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
      'vatRate': vatRate,
      'vatAmount': vatAmount,
    };
  }

  /// Convert to entity
  InvoiceItemEntity toEntity() {
    return InvoiceItemEntity(
      id: id,
      productId: productId,
      productName: productName,
      sku: sku,
      quantity: quantity,
      unitPrice: unitPrice,
      totalPrice: totalPrice,
      vatRate: vatRate,
      vatAmount: vatAmount,
    );
  }

  /// Create from entity
  factory InvoiceItemModel.fromEntity(InvoiceItemEntity entity) {
    return InvoiceItemModel(
      id: entity.id,
      productId: entity.productId,
      productName: entity.productName,
      sku: entity.sku,
      quantity: entity.quantity,
      unitPrice: entity.unitPrice,
      totalPrice: entity.totalPrice,
      vatRate: entity.vatRate,
      vatAmount: entity.vatAmount,
    );
  }
}

/// Ledger Entry Model - Data transfer object for API and database
class LedgerEntryModel {
  final String id;
  final String accountNumber;
  final String accountName;
  final String description;
  final double debitAmount;
  final double creditAmount;
  final double balance;
  final DateTime date;
  final String category;
  final String referenceNumber;
  final DateTime createdAt;

  const LedgerEntryModel({
    required this.id,
    required this.accountNumber,
    required this.accountName,
    required this.description,
    required this.debitAmount,
    required this.creditAmount,
    required this.balance,
    required this.date,
    required this.category,
    required this.referenceNumber,
    required this.createdAt,
  });

  /// Create from JSON
  factory LedgerEntryModel.fromJson(Map<String, dynamic> json) {
    return LedgerEntryModel(
      id: json['id'] as String,
      accountNumber: json['accountNumber'] as String,
      accountName: json['accountName'] as String,
      description: json['description'] as String,
      debitAmount: (json['debitAmount'] as num).toDouble(),
      creditAmount: (json['creditAmount'] as num).toDouble(),
      balance: (json['balance'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      category: json['category'] as String,
      referenceNumber: json['referenceNumber'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'accountNumber': accountNumber,
      'accountName': accountName,
      'description': description,
      'debitAmount': debitAmount,
      'creditAmount': creditAmount,
      'balance': balance,
      'date': date.toIso8601String(),
      'category': category,
      'referenceNumber': referenceNumber,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Convert to entity
  LedgerEntryEntity toEntity() {
    return LedgerEntryEntity(
      id: id,
      accountNumber: accountNumber,
      accountName: accountName,
      description: description,
      debitAmount: debitAmount,
      creditAmount: creditAmount,
      balance: balance,
      date: date,
      category: category,
      referenceNumber: referenceNumber,
      createdAt: createdAt,
    );
  }

  /// Create from entity
  factory LedgerEntryModel.fromEntity(LedgerEntryEntity entity) {
    return LedgerEntryModel(
      id: entity.id,
      accountNumber: entity.accountNumber,
      accountName: entity.accountName,
      description: entity.description,
      debitAmount: entity.debitAmount,
      creditAmount: entity.creditAmount,
      balance: entity.balance,
      date: entity.date,
      category: entity.category,
      referenceNumber: entity.referenceNumber,
      createdAt: entity.createdAt,
    );
  }
}
