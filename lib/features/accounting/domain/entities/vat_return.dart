import 'package:equatable/equatable.dart';

/// VAT Return Entity for Nepal Compliance
/// Comprehensive VAT return management with IRDN compliance
class VATReturn extends Equatable {
  final String id;
  final String returnNumber;
  final String stockistId;
  final String stockistName;
  final String period;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime filingDate;
  final VATReturnStatus status;
  final double totalSales;
  final double totalPurchases;
  final double totalVATCollected;
  final double totalVATPaid;
  final double netVATPayable;
  final double vatRate;
  final List<VATTransaction> salesTransactions;
  final List<VATTransaction> purchaseTransactions;
  final String? irdnReference;
  final DateTime? irdnSubmissionDate;
  final String? irdnAcknowledgementNumber;
  final String? paymentReference;
  final DateTime? paymentDate;
  final double? paymentAmount;
  final String? bankName;
  final String? accountNumber;
  final String? chequeNumber;
  final String? transactionId;
  final List<String> attachments;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const VATReturn({
    required this.id,
    required this.returnNumber,
    required this.stockistId,
    required this.stockistName,
    required this.period,
    required this.startDate,
    required this.endDate,
    required this.filingDate,
    required this.status,
    required this.totalSales,
    required this.totalPurchases,
    required this.totalVATCollected,
    required this.totalVATPaid,
    required this.netVATPayable,
    required this.vatRate,
    required this.salesTransactions,
    required this.purchaseTransactions,
    this.irdnReference,
    this.irdnSubmissionDate,
    this.irdnAcknowledgementNumber,
    this.paymentReference,
    this.paymentDate,
    this.paymentAmount,
    this.bankName,
    this.accountNumber,
    this.chequeNumber,
    this.transactionId,
    this.attachments = const [],
    this.metadata = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates VATReturn from database record
  factory VATReturn.fromMap(Map<String, dynamic> map) {
    return VATReturn(
      id: map['id'] as String,
      returnNumber: map['return_number'] as String,
      stockistId: map['stockist_id'] as String,
      stockistName: map['stockist_name'] as String,
      period: map['period'] as String,
      startDate: DateTime.parse(map['start_date'] as String),
      endDate: DateTime.parse(map['end_date'] as String),
      filingDate: DateTime.parse(map['filing_date'] as String),
      status: VATReturnStatus.values.firstWhere(
        (status) => status.name == map['status'],
        orElse: () => VATReturnStatus.draft,
      ),
      totalSales: double.parse(map['total_sales'].toString()),
      totalPurchases: double.parse(map['total_purchases'].toString()),
      totalVATCollected: double.parse(map['total_vat_collected'].toString()),
      totalVATPaid: double.parse(map['total_vat_paid'].toString()),
      netVATPayable: double.parse(map['net_vat_payable'].toString()),
      vatRate: double.parse(map['vat_rate'].toString()),
      salesTransactions: (map['sales_transactions'] as List<dynamic>?)
          ?.map((item) => VATTransaction.fromMap(item as Map<String, dynamic>))
          .toList() ?? [],
      purchaseTransactions: (map['purchase_transactions'] as List<dynamic>?)
          ?.map((item) => VATTransaction.fromMap(item as Map<String, dynamic>))
          .toList() ?? [],
      irdnReference: map['irdn_reference'] as String?,
      irdnSubmissionDate: map['irdn_submission_date'] != null 
        ? DateTime.parse(map['irdn_submission_date'] as String) 
        : null,
      irdnAcknowledgementNumber: map['irdn_acknowledgement_number'] as String?,
      paymentReference: map['payment_reference'] as String?,
      paymentDate: map['payment_date'] != null 
        ? DateTime.parse(map['payment_date'] as String) 
        : null,
      paymentAmount: map['payment_amount'] != null 
        ? double.parse(map['payment_amount'].toString()) 
        : null,
      bankName: map['bank_name'] as String?,
      accountNumber: map['account_number'] as String?,
      chequeNumber: map['cheque_number'] as String?,
      transactionId: map['transaction_id'] as String?,
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
      'return_number': returnNumber,
      'stockist_id': stockistId,
      'stockist_name': stockistName,
      'period': period,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'filing_date': filingDate.toIso8601String(),
      'status': status.name,
      'total_sales': totalSales,
      'total_purchases': totalPurchases,
      'total_vat_collected': totalVATCollected,
      'total_vat_paid': totalVATPaid,
      'net_vat_payable': netVATPayable,
      'vat_rate': vatRate,
      'sales_transactions': salesTransactions.map((t) => t.toMap()).toList(),
      'purchase_transactions': purchaseTransactions.map((t) => t.toMap()).toList(),
      'irdn_reference': irdnReference,
      'irdn_submission_date': irdnSubmissionDate?.toIso8601String(),
      'irdn_acknowledgement_number': irdnAcknowledgementNumber,
      'payment_reference': paymentReference,
      'payment_date': paymentDate?.toIso8601String(),
      'payment_amount': paymentAmount,
      'bank_name': bankName,
      'account_number': accountNumber,
      'cheque_number': chequeNumber,
      'transaction_id': transactionId,
      'attachments': attachments,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Creates copy with updated fields
  VATReturn copyWith({
    String? id,
    String? returnNumber,
    String? stockistId,
    String? stockistName,
    String? period,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? filingDate,
    VATReturnStatus? status,
    double? totalSales,
    double? totalPurchases,
    double? totalVATCollected,
    double? totalVATPaid,
    double? netVATPayable,
    double? vatRate,
    List<VATTransaction>? salesTransactions,
    List<VATTransaction>? purchaseTransactions,
    String? irdnReference,
    DateTime? irdnSubmissionDate,
    String? irdnAcknowledgementNumber,
    String? paymentReference,
    DateTime? paymentDate,
    double? paymentAmount,
    String? bankName,
    String? accountNumber,
    String? chequeNumber,
    String? transactionId,
    List<String>? attachments,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VATReturn(
      id: id ?? this.id,
      returnNumber: returnNumber ?? this.returnNumber,
      stockistId: stockistId ?? this.stockistId,
      stockistName: stockistName ?? this.stockistName,
      period: period ?? this.period,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      filingDate: filingDate ?? this.filingDate,
      status: status ?? this.status,
      totalSales: totalSales ?? this.totalSales,
      totalPurchases: totalPurchases ?? this.totalPurchases,
      totalVATCollected: totalVATCollected ?? this.totalVATCollected,
      totalVATPaid: totalVATPaid ?? this.totalVATPaid,
      netVATPayable: netVATPayable ?? this.netVATPayable,
      vatRate: vatRate ?? this.vatRate,
      salesTransactions: salesTransactions ?? this.salesTransactions,
      purchaseTransactions: purchaseTransactions ?? this.purchaseTransactions,
      irdnReference: irdnReference ?? this.irdnReference,
      irdnSubmissionDate: irdnSubmissionDate ?? this.irdnSubmissionDate,
      irdnAcknowledgementNumber: irdnAcknowledgementNumber ?? this.irdnAcknowledgementNumber,
      paymentReference: paymentReference ?? this.paymentReference,
      paymentDate: paymentDate ?? this.paymentDate,
      paymentAmount: paymentAmount ?? this.paymentAmount,
      bankName: bankName ?? this.bankName,
      accountNumber: accountNumber ?? this.accountNumber,
      chequeNumber: chequeNumber ?? this.chequeNumber,
      transactionId: transactionId ?? this.transactionId,
      attachments: attachments ?? this.attachments,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Gets formatted total sales
  String getFormattedTotalSales() {
    return 'NPR ${totalSales.toStringAsFixed(2)}';
  }

  /// Gets formatted total purchases
  String getFormattedTotalPurchases() {
    return 'NPR ${totalPurchases.toStringAsFixed(2)}';
  }

  /// Gets formatted total VAT collected
  String getFormattedTotalVATCollected() {
    return 'NPR ${totalVATCollected.toStringAsFixed(2)}';
  }

  /// Gets formatted total VAT paid
  String getFormattedTotalVATPaid() {
    return 'NPR ${totalVATPaid.toStringAsFixed(2)}';
  }

  /// Gets formatted net VAT payable
  String getFormattedNetVATPayable() {
    return 'NPR ${netVATPayable.toStringAsFixed(2)}';
  }

  /// Gets formatted payment amount
  String getFormattedPaymentAmount() {
    if (paymentAmount == null) return 'N/A';
    return 'NPR ${paymentAmount!.toStringAsFixed(2)}';
  }

  /// Gets formatted dates
  String getFormattedStartDate() {
    return '${startDate.day}/${startDate.month}/${startDate.year}';
  }

  String getFormattedEndDate() {
    return '${endDate.day}/${endDate.month}/${endDate.year}';
  }

  String getFormattedFilingDate() {
    return '${filingDate.day}/${filingDate.month}/${filingDate.year}';
  }

  String getFormattedPaymentDate() {
    if (paymentDate == null) return 'N/A';
    return '${paymentDate!.day}/${paymentDate!.month}/${paymentDate!.year}';
  }

  String getFormattedIRDNSubmissionDate() {
    if (irdnSubmissionDate == null) return 'N/A';
    return '${irdnSubmissionDate!.day}/${irdnSubmissionDate!.month}/${irdnSubmissionDate!.year}';
  }

  /// Gets VAT rate as percentage
  String getFormattedVATRate() {
    return '${(vatRate * 100).toStringAsFixed(1)}%';
  }

  /// Gets transaction counts
  int getSalesTransactionCount() {
    return salesTransactions.length;
  }

  int getPurchaseTransactionCount() {
    return purchaseTransactions.length;
  }

  int getTotalTransactionCount() {
    return salesTransactions.length + purchaseTransactions.length;
  }

  /// Checks if return is submitted
  bool isSubmitted() {
    return status == VATReturnStatus.submitted ||
           status == VATReturnStatus.irdnSubmitted ||
           status == VATReturnStatus.irdnAcknowledged ||
           status == VATReturnStatus.paid ||
           status == VATReturnStatus.completed;
  }

  /// Checks if return is paid
  bool isPaid() {
    return status == VATReturnStatus.paid ||
           status == VATReturnStatus.completed;
  }

  /// Checks if return is overdue
  bool isOverdue() {
    final now = DateTime.now();
    final dueDate = endDate.add(const Duration(days: 30)); // 30 days after period end
    return now.isAfter(dueDate) && !isPaid();
  }

  /// Gets days until due
  int getDaysUntilDue() {
    final now = DateTime.now();
    final dueDate = endDate.add(const Duration(days: 30));
    return dueDate.difference(now).inDays;
  }

  /// Gets formatted days until due
  String getFormattedDaysUntilDue() {
    final days = getDaysUntilDue();
    if (days < 0) return 'Overdue by ${days.abs()} days';
    return 'Due in $days days';
  }

  /// Gets compliance status
  VATComplianceStatus getComplianceStatus() {
    if (status == VATReturnStatus.completed) {
      return VATComplianceStatus.compliant;
    } else if (status == VATReturnStatus.paid) {
      return VATComplianceStatus.compliant;
    } else if (isOverdue()) {
      return VATComplianceStatus.overdue;
    } else if (status == VATReturnStatus.draft) {
      return VATComplianceStatus.pending;
    } else {
      return VATComplianceStatus.inProgress;
    }
  }

  /// Gets compliance status color
  String getComplianceStatusColor() {
    switch (getComplianceStatus()) {
      case VATComplianceStatus.compliant:
        return '#4CAF50';
      case VATComplianceStatus.overdue:
        return '#F44336';
      case VATComplianceStatus.pending:
        return '#FF9800';
      case VATComplianceStatus.inProgress:
        return '#2196F3';
      case VATComplianceStatus.nonCompliant:
        return '#F44336';
    }
  }

  /// Gets status color
  String getStatusColor() {
    switch (status) {
      case VATReturnStatus.draft:
        return '#9E9E9E';
      case VATReturnStatus.ready:
        return '#2196F3';
      case VATReturnStatus.submitted:
        return '#FF9800';
      case VATReturnStatus.irdnSubmitted:
        return '#9C27B0';
      case VATReturnStatus.irdnAcknowledged:
        return '#4CAF50';
      case VATReturnStatus.paid:
        return '#00BCD4';
      case VATReturnStatus.completed:
        return '#4CAF50';
      case VATReturnStatus.rejected:
        return '#F44336';
      case VATReturnStatus.amended:
        return '#FFC107';
    }
  }

  @override
  List<Object> get props => [
        id,
        returnNumber,
        stockistId,
        stockistName,
        period,
        startDate,
        endDate,
        filingDate,
        status,
        totalSales,
        totalPurchases,
        totalVATCollected,
        totalVATPaid,
        netVATPayable,
        vatRate,
        salesTransactions,
        purchaseTransactions,
        irdnReference,
        irdnSubmissionDate,
        irdnAcknowledgementNumber,
        paymentReference,
        paymentDate,
        paymentAmount,
        bankName,
        accountNumber,
        chequeNumber,
        transactionId,
        attachments,
        metadata,
        createdAt,
        updatedAt,
      ];

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VATReturn && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'VATReturn(id: $id, returnNumber: $returnNumber, period: $period)';
  }
}

/// VAT Transaction Entity
class VATTransaction extends Equatable {
  final String id;
  final String transactionNumber;
  final String invoiceNumber;
  final String customerId;
  final String customerName;
  final String? productId;
  final String? productName;
  final double amount;
  final double vatAmount;
  final double totalAmount;
  final DateTime transactionDate;
  final VATTransactionType type;
  final String? description;
  final String? category;
  final bool isVATApplicable;
  final double vatRate;
  final String? referenceNumber;
  final Map<String, dynamic> metadata;

  const VATTransaction({
    required this.id,
    required this.transactionNumber,
    required this.invoiceNumber,
    required this.customerId,
    required this.customerName,
    this.productId,
    this.productName,
    required this.amount,
    required this.vatAmount,
    required this.totalAmount,
    required this.transactionDate,
    required this.type,
    this.description,
    this.category,
    required this.isVATApplicable,
    required this.vatRate,
    this.referenceNumber,
    this.metadata = const {},
  });

  /// Creates VATTransaction from database record
  factory VATTransaction.fromMap(Map<String, dynamic> map) {
    return VATTransaction(
      id: map['id'] as String,
      transactionNumber: map['transaction_number'] as String,
      invoiceNumber: map['invoice_number'] as String,
      customerId: map['customer_id'] as String,
      customerName: map['customer_name'] as String,
      productId: map['product_id'] as String?,
      productName: map['product_name'] as String?,
      amount: double.parse(map['amount'].toString()),
      vatAmount: double.parse(map['vat_amount'].toString()),
      totalAmount: double.parse(map['total_amount'].toString()),
      transactionDate: DateTime.parse(map['transaction_date'] as String),
      type: VATTransactionType.values.firstWhere(
        (type) => type.name == map['type'],
        orElse: () => VATTransactionType.sale,
      ),
      description: map['description'] as String?,
      category: map['category'] as String?,
      isVATApplicable: map['is_vat_applicable'] as bool? ?? true,
      vatRate: double.parse(map['vat_rate'].toString()),
      referenceNumber: map['reference_number'] as String?,
      metadata: map['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  /// Converts to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'transaction_number': transactionNumber,
      'invoice_number': invoiceNumber,
      'customer_id': customerId,
      'customer_name': customerName,
      'product_id': productId,
      'product_name': productName,
      'amount': amount,
      'vat_amount': vatAmount,
      'total_amount': totalAmount,
      'transaction_date': transactionDate.toIso8601String(),
      'type': type.name,
      'description': description,
      'category': category,
      'is_vat_applicable': isVATApplicable,
      'vat_rate': vatRate,
      'reference_number': referenceNumber,
      'metadata': metadata,
    };
  }

  /// Gets formatted amount
  String getFormattedAmount() {
    return 'NPR ${amount.toStringAsFixed(2)}';
  }

  /// Gets formatted VAT amount
  String getFormattedVATAmount() {
    return 'NPR ${vatAmount.toStringAsFixed(2)}';
  }

  /// Gets formatted total amount
  String getFormattedTotalAmount() {
    return 'NPR ${totalAmount.toStringAsFixed(2)}';
  }

  /// Gets formatted transaction date
  String getFormattedTransactionDate() {
    return '${transactionDate.day}/${transactionDate.month}/${transactionDate.year}';
  }

  /// Gets formatted VAT rate
  String getFormattedVATRate() {
    return '${(vatRate * 100).toStringAsFixed(1)}%';
  }

  @override
  List<Object> get props => [
        id,
        transactionNumber,
        invoiceNumber,
        customerId,
        customerName,
        productId,
        productName,
        amount,
        vatAmount,
        totalAmount,
        transactionDate,
        type,
        description,
        category,
        isVATApplicable,
        vatRate,
        referenceNumber,
        metadata,
      ];

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VATTransaction && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'VATTransaction(id: $id, transactionNumber: $transactionNumber, amount: $amount)';
  }
}

/// VAT Return Status enumeration
enum VATReturnStatus {
  draft,
  ready,
  submitted,
  irdnSubmitted,
  irdnAcknowledged,
  paid,
  completed,
  rejected,
  amended,
}

/// VAT Return Status extension
extension VATReturnStatusExtension on VATReturnStatus {
  String get displayName {
    switch (this) {
      case VATReturnStatus.draft:
        return 'Draft';
      case VATReturnStatus.ready:
        return 'Ready';
      case VATReturnStatus.submitted:
        return 'Submitted';
      case VATReturnStatus.irdnSubmitted:
        return 'IRDN Submitted';
      case VATReturnStatus.irdnAcknowledged:
        return 'IRDN Acknowledged';
      case VATReturnStatus.paid:
        return 'Paid';
      case VATReturnStatus.completed:
        return 'Completed';
      case VATReturnStatus.rejected:
        return 'Rejected';
      case VATReturnStatus.amended:
        return 'Amended';
    }
  }

  String get color {
    switch (this) {
      case VATReturnStatus.draft:
        return '#9E9E9E';
      case VATReturnStatus.ready:
        return '#2196F3';
      case VATReturnStatus.submitted:
        return '#FF9800';
      case VATReturnStatus.irdnSubmitted:
        return '#9C27B0';
      case VATReturnStatus.irdnAcknowledged:
        return '#4CAF50';
      case VATReturnStatus.paid:
        return '#00BCD4';
      case VATReturnStatus.completed:
        return '#4CAF50';
      case VATReturnStatus.rejected:
        return '#F44336';
      case VATReturnStatus.amended:
        return '#FFC107';
    }
  }

  String get icon {
    switch (this) {
      case VATReturnStatus.draft:
        return 'edit';
      case VATReturnStatus.ready:
        return 'check_circle';
      case VATReturnStatus.submitted:
        return 'send';
      case VATReturnStatus.irdnSubmitted:
        return 'cloud_upload';
      case VATReturnStatus.irdnAcknowledged:
        return 'verified';
      case VATReturnStatus.paid:
        return 'payments';
      case VATReturnStatus.completed:
        return 'done_all';
      case VATReturnStatus.rejected:
        return 'cancel';
      case VATReturnStatus.amended:
        return 'update';
    }
  }
}

/// VAT Transaction Type enumeration
enum VATTransactionType {
  sale,
  purchase,
  return,
  adjustment,
}

/// VAT Transaction Type extension
extension VATTransactionTypeExtension on VATTransactionType {
  String get displayName {
    switch (this) {
      case VATTransactionType.sale:
        return 'Sale';
      case VATTransactionType.purchase:
        return 'Purchase';
      case VATTransactionType.return:
        return 'Return';
      case VATTransactionType.adjustment:
        return 'Adjustment';
    }
  }

  String get color {
    switch (this) {
      case VATTransactionType.sale:
        return '#4CAF50';
      case VATTransactionType.purchase:
        return '#F44336';
      case VATTransactionType.return:
        return '#FF9800';
      case VATTransactionType.adjustment:
        return '#2196F3';
    }
  }

  String get icon {
    switch (this) {
      case VATTransactionType.sale:
        return 'trending_up';
      case VATTransactionType.purchase:
        return 'trending_down';
      case VATTransactionType.return:
        return 'replay';
      case VATTransactionType.adjustment:
        return 'tune';
    }
  }
}

/// VAT Compliance Status enumeration
enum VATComplianceStatus {
  compliant,
  nonCompliant,
  overdue,
  pending,
  inProgress,
}

/// VAT Compliance Status extension
extension VATComplianceStatusExtension on VATComplianceStatus {
  String get displayName {
    switch (this) {
      case VATComplianceStatus.compliant:
        return 'Compliant';
      case VATComplianceStatus.nonCompliant:
        return 'Non-Compliant';
      case VATComplianceStatus.overdue:
        return 'Overdue';
      case VATComplianceStatus.pending:
        return 'Pending';
      case VATComplianceStatus.inProgress:
        return 'In Progress';
    }
  }

  String get color {
    switch (this) {
      case VATComplianceStatus.compliant:
        return '#4CAF50';
      case VATComplianceStatus.nonCompliant:
        return '#F44336';
      case VATComplianceStatus.overdue:
        return '#F44336';
      case VATComplianceStatus.pending:
        return '#FF9800';
      case VATComplianceStatus.inProgress:
        return '#2196F3';
    }
  }

  String get icon {
    switch (this) {
      case VATComplianceStatus.compliant:
        return 'check_circle';
      case VATComplianceStatus.nonCompliant:
        return 'error';
      case VATComplianceStatus.overdue:
        return 'warning';
      case VATComplianceStatus.pending:
        return 'schedule';
      case VATComplianceStatus.inProgress:
        return 'hourglass_empty';
    }
  }
}
