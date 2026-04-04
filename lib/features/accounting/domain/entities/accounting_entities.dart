import 'package:equatable/equatable.dart';

/// Expense Entity - Core business object for expense management
class ExpenseEntity extends Equatable {
  final String id;
  final String mrId;
  final String mrName;
  final double amount;
  final String category;
  final String description;
  final DateTime date;
  final String status; // pending, approved, rejected
  final int receiptCount;
  final List<String> receiptUrls;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ExpenseEntity({
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

  @override
  List<Object?> get props => [
        id,
        mrId,
        mrName,
        amount,
        category,
        description,
        date,
        status,
        receiptCount,
        receiptUrls,
        notes,
        createdAt,
        updatedAt,
      ];

  ExpenseEntity copyWith({
    String? id,
    String? mrId,
    String? mrName,
    double? amount,
    String? category,
    String? description,
    DateTime? date,
    String? status,
    int? receiptCount,
    List<String>? receiptUrls,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ExpenseEntity(
      id: id ?? this.id,
      mrId: mrId ?? this.mrId,
      mrName: mrName ?? this.mrName,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      description: description ?? this.description,
      date: date ?? this.date,
      status: status ?? this.status,
      receiptCount: receiptCount ?? this.receiptCount,
      receiptUrls: receiptUrls ?? this.receiptUrls,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Check if expense is approved
  bool get isApproved => status == 'approved';

  /// Check if expense is pending
  bool get isPending => status == 'pending';

  /// Check if expense is rejected
  bool get isRejected => status == 'rejected';

  /// Check if expense has receipts
  bool get hasReceipts => receiptCount > 0;
}

/// VAT Return Entity - Core business object for VAT returns
class VatReturnEntity extends Equatable {
  final String id;
  final String period; // e.g., "Q1 2026"
  final double totalSales;
  final double vatAmount;
  final double totalPurchases;
  final double vatPaid;
  final double netVatPayable;
  final String status; // draft, filed, submitted, accepted
  final DateTime? filedDate;
  final DateTime dueDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const VatReturnEntity({
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

  @override
  List<Object?> get props => [
        id,
        period,
        totalSales,
        vatAmount,
        totalPurchases,
        vatPaid,
        netVatPayable,
        status,
        filedDate,
        dueDate,
        createdAt,
        updatedAt,
      ];

  VatReturnEntity copyWith({
    String? id,
    String? period,
    double? totalSales,
    double? vatAmount,
    double? totalPurchases,
    double? vatPaid,
    double? netVatPayable,
    String? status,
    DateTime? filedDate,
    DateTime? dueDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VatReturnEntity(
      id: id ?? this.id,
      period: period ?? this.period,
      totalSales: totalSales ?? this.totalSales,
      vatAmount: vatAmount ?? this.vatAmount,
      totalPurchases: totalPurchases ?? this.totalPurchases,
      vatPaid: vatPaid ?? this.vatPaid,
      netVatPayable: netVatPayable ?? this.netVatPayable,
      status: status ?? this.status,
      filedDate: filedDate ?? this.filedDate,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Check if VAT return is overdue
  bool get isOverdue => DateTime.now().isAfter(dueDate);

  /// Check if VAT return is filed
  bool get isFiled => filedDate != null;

  /// Check if VAT return is submitted
  bool get isSubmitted => ['submitted', 'accepted'].contains(status);

  /// Check if VAT return is accepted
  bool get isAccepted => status == 'accepted';
}

/// Invoice Entity - Core business object for invoice management
class InvoiceEntity extends Equatable {
  final String id;
  final String invoiceNumber;
  final String customerId;
  final String customerName;
  final double totalAmount;
  final double vatAmount;
  final double finalAmount;
  final DateTime dueDate;
  final String status; // draft, sent, paid, overdue, cancelled
  final List<InvoiceItemEntity> items;
  final DateTime createdAt;
  final DateTime updatedAt;

  const InvoiceEntity({
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

  @override
  List<Object?> get props => [
        id,
        invoiceNumber,
        customerId,
        customerName,
        totalAmount,
        vatAmount,
        finalAmount,
        dueDate,
        status,
        items,
        createdAt,
        updatedAt,
      ];

  InvoiceEntity copyWith({
    String? id,
    String? invoiceNumber,
    String? customerId,
    String? customerName,
    double? totalAmount,
    double? vatAmount,
    double? finalAmount,
    DateTime? dueDate,
    String? status,
    List<InvoiceItemEntity>? items,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return InvoiceEntity(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      totalAmount: totalAmount ?? this.totalAmount,
      vatAmount: vatAmount ?? this.vatAmount,
      finalAmount: finalAmount ?? this.finalAmount,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Check if invoice is overdue
  bool get isOverdue => !['paid', 'cancelled'].contains(status) && DateTime.now().isAfter(dueDate);

  /// Check if invoice is paid
  bool get isPaid => status == 'paid';

  /// Check if invoice is cancelled
  bool get isCancelled => status == 'cancelled';

  /// Get days until due
  int get daysUntilDue => dueDate.difference(DateTime.now()).inDays;
}

/// Invoice Item Entity - Core business object for invoice line items
class InvoiceItemEntity extends Equatable {
  final String id;
  final String productId;
  final String productName;
  final String sku;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final double vatRate;
  final double vatAmount;

  const InvoiceItemEntity({
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

  @override
  List<Object?> get props => [
        id,
        productId,
        productName,
        sku,
        quantity,
        unitPrice,
        totalPrice,
        vatRate,
        vatAmount,
      ];

  InvoiceItemEntity copyWith({
    String? id,
    String? productId,
    String? productName,
    String? sku,
    int? quantity,
    double? unitPrice,
    double? totalPrice,
    double? vatRate,
    double? vatAmount,
  }) {
    return InvoiceItemEntity(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      sku: sku ?? this.sku,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
      vatRate: vatRate ?? this.vatRate,
      vatAmount: vatAmount ?? this.vatAmount,
    );
  }
}

/// Ledger Entry Entity - Core business object for accounting ledger
class LedgerEntryEntity extends Equatable {
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

  const LedgerEntryEntity({
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

  @override
  List<Object?> get props => [
        id,
        accountNumber,
        accountName,
        description,
        debitAmount,
        creditAmount,
        balance,
        date,
        category,
        referenceNumber,
        createdAt,
      ];

  LedgerEntryEntity copyWith({
    String? id,
    String? accountNumber,
    String? accountName,
    String? description,
    double? debitAmount,
    double? creditAmount,
    double? balance,
    DateTime? date,
    String? category,
    String? referenceNumber,
    DateTime? createdAt,
  }) {
    return LedgerEntryEntity(
      id: id ?? this.id,
      accountNumber: accountNumber ?? this.accountNumber,
      accountName: accountName ?? this.accountName,
      description: description ?? this.description,
      debitAmount: debitAmount ?? this.debitAmount,
      creditAmount: creditAmount ?? this.creditAmount,
      balance: balance ?? this.balance,
      date: date ?? this.date,
      category: category ?? this.category,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Check if entry is a debit
  bool get isDebit => debitAmount > 0;

  /// Check if entry is a credit
  bool get isCredit => creditAmount > 0;
}
