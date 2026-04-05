import 'package:equatable/equatable.dart';

/// Expense Reconciliation Entity
/// Comprehensive expense management with multi-photo receipt approval
class ExpenseReconciliation extends Equatable {
  final String id;
  final String expenseNumber;
  final String mrId;
  final String mrName;
  final String stockistId;
  final String stockistName;
  final String period;
  final DateTime expenseDate;
  final String category;
  final String subcategory;
  final double amount;
  final String currency;
  final double exchangeRate;
  final double amountInNPR;
  final String description;
  final String purpose;
  final List<ExpenseReceipt> receipts;
  final ExpenseStatus status;
  final String? approvedBy;
  final DateTime? approvedAt;
  final String? rejectionReason;
  final String? paymentMethod;
  final String? bankName;
  final String? accountNumber;
  final String? chequeNumber;
  final String? transactionId;
  final DateTime? paymentDate;
  final double? approvedAmount;
  final double? rejectedAmount;
  final String? notes;
  final List<String> attachments;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ExpenseReconciliation({
    required this.id,
    required this.expenseNumber,
    required this.mrId,
    required this.mrName,
    required this.stockistId,
    required this.stockistName,
    required this.period,
    required this.expenseDate,
    required this.category,
    required this.subcategory,
    required this.amount,
    required this.currency,
    required this.exchangeRate,
    required this.amountInNPR,
    required this.description,
    required this.purpose,
    required this.receipts,
    required this.status,
    this.approvedBy,
    this.approvedAt,
    this.rejectionReason,
    this.paymentMethod,
    this.bankName,
    this.accountNumber,
    this.chequeNumber,
    this.transactionId,
    this.paymentDate,
    this.approvedAmount,
    this.rejectedAmount,
    this.notes,
    this.attachments = const [],
    this.metadata = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates ExpenseReconciliation from database record
  factory ExpenseReconciliation.fromMap(Map<String, dynamic> map) {
    return ExpenseReconciliation(
      id: map['id'] as String,
      expenseNumber: map['expense_number'] as String,
      mrId: map['mr_id'] as String,
      mrName: map['mr_name'] as String,
      stockistId: map['stockist_id'] as String,
      stockistName: map['stockist_name'] as String,
      period: map['period'] as String,
      expenseDate: DateTime.parse(map['expense_date'] as String),
      category: map['category'] as String,
      subcategory: map['subcategory'] as String,
      amount: double.parse(map['amount'].toString()),
      currency: map['currency'] as String,
      exchangeRate: double.parse(map['exchange_rate'].toString()),
      amountInNPR: double.parse(map['amount_in_npr'].toString()),
      description: map['description'] as String,
      purpose: map['purpose'] as String,
      receipts: (map['receipts'] as List<dynamic>?)
          ?.map((item) => ExpenseReceipt.fromMap(item as Map<String, dynamic>))
          .toList() ?? [],
      status: ExpenseStatus.values.firstWhere(
        (status) => status.name == map['status'],
        orElse: () => ExpenseStatus.pending,
      ),
      approvedBy: map['approved_by'] as String?,
      approvedAt: map['approved_at'] != null 
        ? DateTime.parse(map['approved_at'] as String) 
        : null,
      rejectionReason: map['rejection_reason'] as String?,
      paymentMethod: map['payment_method'] as String?,
      bankName: map['bank_name'] as String?,
      accountNumber: map['account_number'] as String?,
      chequeNumber: map['cheque_number'] as String?,
      transactionId: map['transaction_id'] as String?,
      paymentDate: map['payment_date'] != null 
        ? DateTime.parse(map['payment_date'] as String) 
        : null,
      approvedAmount: map['approved_amount'] != null 
        ? double.parse(map['approved_amount'].toString()) 
        : null,
      rejectedAmount: map['rejected_amount'] != null 
        ? double.parse(map['rejected_amount'].toString()) 
        : null,
      notes: map['notes'] as String?,
      attachments: List<String>.from(map['attachments'] as List<dynamic>? ?? []),
      metadata: map['metadata'] as Map<String, dynamic>? ?? {},
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  /// Converts to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'expense_number': expenseNumber,
      'mr_id': mrId,
      'mr_name': mrName,
      'stockist_id': stockistId,
      'stockist_name': stockistName,
      'period': period,
      'expense_date': expenseDate.toIso8601String(),
      'category': category,
      'subcategory': subcategory,
      'amount': amount,
      'currency': currency,
      'exchange_rate': exchangeRate,
      'amount_in_npr': amountInNPR,
      'description': description,
      'purpose': purpose,
      'receipts': receipts.map((receipt) => receipt.toMap()).toList(),
      'status': status.name,
      'approved_by': approvedBy,
      'approved_at': approvedAt?.toIso8601String(),
      'rejection_reason': rejectionReason,
      'payment_method': paymentMethod,
      'bank_name': bankName,
      'account_number': accountNumber,
      'cheque_number': chequeNumber,
      'transaction_id': transactionId,
      'payment_date': paymentDate?.toIso8601String(),
      'approved_amount': approvedAmount,
      'rejected_amount': rejectedAmount,
      'notes': notes,
      'attachments': attachments,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Creates copy with updated fields
  ExpenseReconciliation copyWith({
    String? id,
    String? expenseNumber,
    String? mrId,
    String? mrName,
    String? stockistId,
    String? stockistName,
    String? period,
    DateTime? expenseDate,
    String? category,
    String? subcategory,
    double? amount,
    String? currency,
    double? exchangeRate,
    double? amountInNPR,
    String? description,
    String? purpose,
    List<ExpenseReceipt>? receipts,
    ExpenseStatus? status,
    String? approvedBy,
    DateTime? approvedAt,
    String? rejectionReason,
    String? paymentMethod,
    String? bankName,
    String? accountNumber,
    String? chequeNumber,
    String? transactionId,
    DateTime? paymentDate,
    double? approvedAmount,
    double? rejectedAmount,
    String? notes,
    List<String>? attachments,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ExpenseReconciliation(
      id: id ?? this.id,
      expenseNumber: expenseNumber ?? this.expenseNumber,
      mrId: mrId ?? this.mrId,
      mrName: mrName ?? this.mrName,
      stockistId: stockistId ?? this.stockistId,
      stockistName: stockistName ?? this.stockistName,
      period: period ?? this.period,
      expenseDate: expenseDate ?? this.expenseDate,
      category: category ?? this.category,
      subcategory: subcategory ?? this.subcategory,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      exchangeRate: exchangeRate ?? this.exchangeRate,
      amountInNPR: amountInNPR ?? this.amountInNPR,
      description: description ?? this.description,
      purpose: purpose ?? this.purpose,
      receipts: receipts ?? this.receipts,
      status: status ?? this.status,
      approvedBy: approvedBy ?? this.approvedBy,
      approvedAt: approvedAt ?? this.approvedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      bankName: bankName ?? this.bankName,
      accountNumber: accountNumber ?? this.accountNumber,
      chequeNumber: chequeNumber ?? this.chequeNumber,
      transactionId: transactionId ?? this.transactionId,
      paymentDate: paymentDate ?? this.paymentDate,
      approvedAmount: approvedAmount ?? this.approvedAmount,
      rejectedAmount: rejectedAmount ?? this.rejectedAmount,
      notes: notes ?? this.notes,
      attachments: attachments ?? this.attachments,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Gets formatted amount
  String getFormattedAmount() {
    return '$currency ${amount.toStringAsFixed(2)}';
  }

  /// Gets formatted amount in NPR
  String getFormattedAmountInNPR() {
    return 'NPR ${amountInNPR.toStringAsFixed(2)}';
  }

  /// Gets formatted approved amount
  String getFormattedApprovedAmount() {
    if (approvedAmount == null) return 'N/A';
    return 'NPR ${approvedAmount!.toStringAsFixed(2)}';
  }

  /// Gets formatted rejected amount
  String getFormattedRejectedAmount() {
    if (rejectedAmount == null) return 'N/A';
    return 'NPR ${rejectedAmount!.toStringAsFixed(2)}';
  }

  /// Gets formatted exchange rate
  String getFormattedExchangeRate() {
    return '1 $currency = ${exchangeRate.toStringAsFixed(4)} NPR';
  }

  /// Gets formatted expense date
  String getFormattedExpenseDate() {
    return '${expenseDate.day}/${expenseDate.month}/${expenseDate.year}';
  }

  /// Gets formatted approved date
  String getFormattedApprovedDate() {
    if (approvedAt == null) return 'N/A';
    return '${approvedAt!.day}/${approvedAt!.month}/${approvedAt!.year}';
  }

  /// Gets formatted payment date
  String getFormattedPaymentDate() {
    if (paymentDate == null) return 'N/A';
    return '${paymentDate!.day}/${paymentDate!.month}/${paymentDate!.year}';
  }

  /// Gets receipt count
  int getReceiptCount() {
    return receipts.length;
  }

  /// Gets attachment count
  int getAttachmentCount() {
    return attachments.length;
  }

  /// Gets total receipt amount
  double getTotalReceiptAmount() {
    return receipts.fold(0.0, (sum, receipt) => sum + receipt.totalAmount);
  }

  /// Gets formatted total receipt amount
  String getFormattedTotalReceiptAmount() {
    return 'NPR ${getTotalReceiptAmount().toStringAsFixed(2)}';
  }

  /// Gets receipt validation status
  ReceiptValidationStatus getReceiptValidationStatus() {
    if (receipts.isEmpty) {
      return ReceiptValidationStatus.noReceipts;
    }
    
    final totalReceiptAmount = getTotalReceiptAmount();
    final difference = (amountInNPR - totalReceiptAmount).abs();
    final tolerance = amountInNPR * 0.05; // 5% tolerance
    
    if (difference <= tolerance) {
      return ReceiptValidationStatus.valid;
    } else if (totalReceiptAmount > amountInNPR) {
      return ReceiptValidationStatus.overAmount;
    } else {
      return ReceiptValidationStatus.underAmount;
    }
  }

  /// Gets receipt validation status color
  String getReceiptValidationStatusColor() {
    switch (getReceiptValidationStatus()) {
      case ReceiptValidationStatus.valid:
        return '#4CAF50';
      case ReceiptValidationStatus.noReceipts:
        return '#FF9800';
      case ReceiptValidationStatus.overAmount:
        return '#F44336';
      case ReceiptValidationStatus.underAmount:
        return '#FF9800';
      case ReceiptValidationStatus.missingRequired:
        return '#F44336';
    }
  }

  /// Gets receipt validation status display name
  String getReceiptValidationStatusDisplayName() {
    switch (getReceiptValidationStatus()) {
      case ReceiptValidationStatus.valid:
        return 'Valid';
      case ReceiptValidationStatus.noReceipts:
        return 'No Receipts';
      case ReceiptValidationStatus.overAmount:
        return 'Over Amount';
      case ReceiptValidationStatus.underAmount:
        return 'Under Amount';
      case ReceiptValidationStatus.missingRequired:
        return 'Missing Required';
    }
  }

  /// Checks if expense can be approved
  bool canBeApproved() {
    return status == ExpenseStatus.pending ||
           status == ExpenseStatus.reviewed;
  }

  /// Checks if expense can be rejected
  bool canBeRejected() {
    return status == ExpenseStatus.pending ||
           status == ExpenseStatus.reviewed;
  }

  /// Checks if expense is approved
  bool isApproved() {
    return status == ExpenseStatus.approved ||
           status == ExpenseStatus.paid;
  }

  /// Checks if expense is rejected
  bool isRejected() {
    return status == ExpenseStatus.rejected;
  }

  /// Checks if expense is paid
  bool isPaid() {
    return status == ExpenseStatus.paid;
  }

  /// Gets days since submission
  int getDaysSinceSubmission() {
    return DateTime.now().difference(createdAt).inDays;
  }

  /// Gets formatted days since submission
  String getFormattedDaysSinceSubmission() {
    final days = getDaysSinceSubmission();
    if (days == 0) return 'Today';
    if (days == 1) return 'Yesterday';
    return '$days days ago';
  }

  /// Gets approval status
  ApprovalStatus getApprovalStatus() {
    if (isApproved()) {
      return ApprovalStatus.approved;
    } else if (isRejected()) {
      return ApprovalStatus.rejected;
    } else if (status == ExpenseStatus.reviewed) {
      return ApprovalStatus.reviewed;
    } else {
      return ApprovalStatus.pending;
    }
  }

  /// Gets approval status color
  String getApprovalStatusColor() {
    switch (getApprovalStatus()) {
      case ApprovalStatus.approved:
        return '#4CAF50';
      case ApprovalStatus.rejected:
        return '#F44336';
      case ApprovalStatus.reviewed:
        return '#2196F3';
      case ApprovalStatus.pending:
        return '#FF9800';
    }
  }

  /// Gets approval status display name
  String getApprovalStatusDisplayName() {
    switch (getApprovalStatus()) {
      case ApprovalStatus.approved:
        return 'Approved';
      case ApprovalStatus.rejected:
        return 'Rejected';
      case ApprovalStatus.reviewed:
        return 'Reviewed';
      case ApprovalStatus.pending:
        return 'Pending';
    }
  }

  @override
  List<Object> get props => [
        id,
        expenseNumber,
        mrId,
        mrName,
        stockistId,
        stockistName,
        period,
        expenseDate,
        category,
        subcategory,
        amount,
        currency,
        exchangeRate,
        amountInNPR,
        description,
        purpose,
        receipts,
        status,
        approvedBy,
        approvedAt,
        rejectionReason,
        paymentMethod,
        bankName,
        accountNumber,
        chequeNumber,
        transactionId,
        paymentDate,
        approvedAmount,
        rejectedAmount,
        notes,
        attachments,
        metadata,
        createdAt,
        updatedAt,
      ];

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExpenseReconciliation && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ExpenseReconciliation(id: $id, expenseNumber: $expenseNumber, amount: $amountInNPR)';
  }
}

/// Expense Receipt Entity
class ExpenseReceipt extends Equatable {
  final String id;
  final String expenseId;
  final String receiptNumber;
  final String vendorName;
  final String vendorAddress;
  final String vendorPhone;
  final String vendorEmail;
  final double totalAmount;
  final String currency;
  final double exchangeRate;
  final double amountInNPR;
  final DateTime receiptDate;
  final String receiptType;
  final List<String> photos;
  final List<ReceiptItem> items;
  final String? notes;
  final ReceiptStatus status;
  final String? verifiedBy;
  final DateTime? verifiedAt;
  final String? verificationNotes;
  final Map<String, dynamic> metadata;

  const ExpenseReceipt({
    required this.id,
    required this.expenseId,
    required this.receiptNumber,
    required this.vendorName,
    required this.vendorAddress,
    required this.vendorPhone,
    required this.vendorEmail,
    required this.totalAmount,
    required this.currency,
    required this.exchangeRate,
    required this.amountInNPR,
    required this.receiptDate,
    required this.receiptType,
    required this.photos,
    required this.items,
    this.notes,
    required this.status,
    this.verifiedBy,
    this.verifiedAt,
    this.verificationNotes,
    this.metadata = const {},
  });

  /// Creates ExpenseReceipt from database record
  factory ExpenseReceipt.fromMap(Map<String, dynamic> map) {
    return ExpenseReceipt(
      id: map['id'] as String,
      expenseId: map['expense_id'] as String,
      receiptNumber: map['receipt_number'] as String,
      vendorName: map['vendor_name'] as String,
      vendorAddress: map['vendor_address'] as String,
      vendorPhone: map['vendor_phone'] as String,
      vendorEmail: map['vendor_email'] as String,
      totalAmount: double.parse(map['total_amount'].toString()),
      currency: map['currency'] as String,
      exchangeRate: double.parse(map['exchange_rate'].toString()),
      amountInNPR: double.parse(map['amount_in_npr'].toString()),
      receiptDate: DateTime.parse(map['receipt_date'] as String),
      receiptType: map['receipt_type'] as String,
      photos: List<String>.from(map['photos'] as List<dynamic>? ?? []),
      items: (map['items'] as List<dynamic>?)
          ?.map((item) => ReceiptItem.fromMap(item as Map<String, dynamic>))
          .toList() ?? [],
      notes: map['notes'] as String?,
      status: ReceiptStatus.values.firstWhere(
        (status) => status.name == map['status'],
        orElse: () => ReceiptStatus.pending,
      ),
      verifiedBy: map['verified_by'] as String?,
      verifiedAt: map['verified_at'] != null 
        ? DateTime.parse(map['verified_at'] as String) 
        : null,
      verificationNotes: map['verification_notes'] as String?,
      metadata: map['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  /// Converts to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'expense_id': expenseId,
      'receipt_number': receiptNumber,
      'vendor_name': vendorName,
      'vendor_address': vendorAddress,
      'vendor_phone': vendorPhone,
      'vendor_email': vendorEmail,
      'total_amount': totalAmount,
      'currency': currency,
      'exchange_rate': exchangeRate,
      'amount_in_npr': amountInNPR,
      'receipt_date': receiptDate.toIso8601String(),
      'receipt_type': receiptType,
      'photos': photos,
      'items': items.map((item) => item.toMap()).toList(),
      'notes': notes,
      'status': status.name,
      'verified_by': verifiedBy,
      'verified_at': verifiedAt?.toIso8601String(),
      'verification_notes': verificationNotes,
      'metadata': metadata,
    };
  }

  /// Gets formatted total amount
  String getFormattedTotalAmount() {
    return '$currency ${totalAmount.toStringAsFixed(2)}';
  }

  /// Gets formatted amount in NPR
  String getFormattedAmountInNPR() {
    return 'NPR ${amountInNPR.toStringAsFixed(2)}';
  }

  /// Gets formatted receipt date
  String getFormattedReceiptDate() {
    return '${receiptDate.day}/${receiptDate.month}/${receiptDate.year}';
  }

  /// Gets photo count
  int getPhotoCount() {
    return photos.length;
  }

  /// Gets item count
  int getItemCount() {
    return items.length;
  }

  /// Gets verification status display name
  String getVerificationStatusDisplayName() {
    switch (status) {
      case ReceiptStatus.pending:
        return 'Pending';
      case ReceiptStatus.verified:
        return 'Verified';
      case ReceiptStatus.rejected:
        return 'Rejected';
      case ReceiptStatus.approved:
        return 'Approved';
    }
  }

  /// Gets verification status color
  String getVerificationStatusColor() {
    switch (status) {
      case ReceiptStatus.pending:
        return '#FF9800';
      case ReceiptStatus.verified:
        return '#4CAF50';
      case ReceiptStatus.rejected:
        return '#F44336';
      case ReceiptStatus.approved:
        return '#2196F3';
    }
  }

  @override
  List<Object> get props => [
        id,
        expenseId,
        receiptNumber,
        vendorName,
        vendorAddress,
        vendorPhone,
        vendorEmail,
        totalAmount,
        currency,
        exchangeRate,
        amountInNPR,
        receiptDate,
        receiptType,
        photos,
        items,
        notes,
        status,
        verifiedBy,
        verifiedAt,
        verificationNotes,
        metadata,
      ];

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExpenseReceipt && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ExpenseReceipt(id: $id, receiptNumber: $receiptNumber, amount: $amountInNPR)';
  }
}

/// Receipt Item Entity
class ReceiptItem extends Equatable {
  final String id;
  final String receiptId;
  final String description;
  final String category;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final String? sku;
  final String? notes;
  final Map<String, dynamic> metadata;

  const ReceiptItem({
    required this.id,
    required this.receiptId,
    required this.description,
    required this.category,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.sku,
    this.notes,
    this.metadata = const {},
  });

  /// Creates ReceiptItem from database record
  factory ReceiptItem.fromMap(Map<String, dynamic> map) {
    return ReceiptItem(
      id: map['id'] as String,
      receiptId: map['receipt_id'] as String,
      description: map['description'] as String,
      category: map['category'] as String,
      quantity: int.parse(map['quantity'].toString()),
      unitPrice: double.parse(map['unit_price'].toString()),
      totalPrice: double.parse(map['total_price'].toString()),
      sku: map['sku'] as String?,
      notes: map['notes'] as String?,
      metadata: map['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  /// Converts to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'receipt_id': receiptId,
      'description': description,
      'category': category,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_price': totalPrice,
      'sku': sku,
      'notes': notes,
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

  @override
  List<Object> get props => [
        id,
        receiptId,
        description,
        category,
        quantity,
        unitPrice,
        totalPrice,
        sku,
        notes,
        metadata,
      ];

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReceiptItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ReceiptItem(id: $id, description: $description, quantity: $quantity)';
  }
}

/// Expense Status enumeration
enum ExpenseStatus {
  pending,
  reviewed,
  approved,
  rejected,
  paid,
  reimbursed,
  cancelled,
}

/// Expense Status extension
extension ExpenseStatusExtension on ExpenseStatus {
  String get displayName {
    switch (this) {
      case ExpenseStatus.pending:
        return 'Pending';
      case ExpenseStatus.reviewed:
        return 'Reviewed';
      case ExpenseStatus.approved:
        return 'Approved';
      case ExpenseStatus.rejected:
        return 'Rejected';
      case ExpenseStatus.paid:
        return 'Paid';
      case ExpenseStatus.reimbursed:
        return 'Reimbursed';
      case ExpenseStatus.cancelled:
        return 'Cancelled';
    }
  }

  String get color {
    switch (this) {
      case ExpenseStatus.pending:
        return '#FF9800';
      case ExpenseStatus.reviewed:
        return '#2196F3';
      case ExpenseStatus.approved:
        return '#4CAF50';
      case ExpenseStatus.rejected:
        return '#F44336';
      case ExpenseStatus.paid:
        return '#00BCD4';
      case ExpenseStatus.reimbursed:
        return '#9C27B0';
      case ExpenseStatus.cancelled:
        return '#9E9E9E';
    }
  }

  String get icon {
    switch (this) {
      case ExpenseStatus.pending:
        return 'schedule';
      case ExpenseStatus.reviewed:
        return 'visibility';
      case ExpenseStatus.approved:
        return 'check_circle';
      case ExpenseStatus.rejected:
        return 'cancel';
      case ExpenseStatus.paid:
        return 'payments';
      case ExpenseStatus.reimbursed:
        return 'account_balance';
      case ExpenseStatus.cancelled:
        return 'block';
    }
  }
}

/// Receipt Status enumeration
enum ReceiptStatus {
  pending,
  verified,
  rejected,
  approved,
}

/// Receipt Status extension
extension ReceiptStatusExtension on ReceiptStatus {
  String get displayName {
    switch (this) {
      case ReceiptStatus.pending:
        return 'Pending';
      case ReceiptStatus.verified:
        return 'Verified';
      case ReceiptStatus.rejected:
        return 'Rejected';
      case ReceiptStatus.approved:
        return 'Approved';
    }
  }

  String get color {
    switch (this) {
      case ReceiptStatus.pending:
        return '#FF9800';
      case ReceiptStatus.verified:
        return '#4CAF50';
      case ReceiptStatus.rejected:
        return '#F44336';
      case ReceiptStatus.approved:
        return '#2196F3';
    }
  }

  String get icon {
    switch (this) {
      case ReceiptStatus.pending:
        return 'hourglass_empty';
      case ReceiptStatus.verified:
        return 'verified';
      case ReceiptStatus.rejected:
        return 'close';
      case ReceiptStatus.approved:
        return 'check_circle';
    }
  }
}

/// Receipt Validation Status enumeration
enum ReceiptValidationStatus {
  valid,
  noReceipts,
  overAmount,
  underAmount,
  missingRequired,
}

/// Approval Status enumeration
enum ApprovalStatus {
  pending,
  reviewed,
  approved,
  rejected,
}
