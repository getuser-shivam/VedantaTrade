import 'package:equatable/equatable.dart';

/// VAT Return Entity for VedantaTrade
/// Represents a VAT/Tax return document with IRDN compliance

class VatReturnEntity extends Equatable {
  final String id;
  final String businessId;
  final String businessName;
  final String businessAddress;
  final String businessPan;
  final String businessIrdn;
  final String taxPeriod;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime filingDate;
  final VatReturnType returnType;
  final VatReturnStatus status;
  final double totalSales;
  final double totalPurchases;
  final double taxableSales;
  final double exemptSales;
  final double zeroRatedSales;
  final double inputTax;
  final double outputTax;
  final double netTaxPayable;
  final double taxPaid;
  final double taxRefundable;
  final double penalty;
  final double interest;
  final double totalAmountDue;
  final List<VatReturnItem> salesItems;
  final List<VatReturnItem> purchaseItems;
  final List<VatTaxDetail> taxDetails;
  final VatReturnSummary summary;
  final String? generatedBy;
  final String? approvedBy;
  final String? submittedTo;
  final DateTime? submittedDate;
  final String? submissionReference;
  final String? irdnReference;
  final String? irdnStatus;
  final DateTime? irdnProcessedDate;
  final String? comments;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const VatReturnEntity({
    required this.id,
    required this.businessId,
    required this.businessName,
    required this.businessAddress,
    required this.businessPan,
    required this.businessIrdn,
    required this.taxPeriod,
    required this.startDate,
    required this.endDate,
    required this.filingDate,
    required this.returnType,
    required this.status,
    required this.totalSales,
    required this.totalPurchases,
    required this.taxableSales,
    required this.exemptSales,
    required this.zeroRatedSales,
    required this.inputTax,
    required this.outputTax,
    required this.netTaxPayable,
    required this.taxPaid,
    required this.taxRefundable,
    required this.penalty,
    required this.interest,
    required this.totalAmountDue,
    required this.salesItems,
    required this.purchaseItems,
    required this.taxDetails,
    required this.summary,
    this.generatedBy,
    this.approvedBy,
    this.submittedTo,
    this.submittedDate,
    this.submissionReference,
    this.irdnReference,
    this.irdnStatus,
    this.irdnProcessedDate,
    this.comments,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        businessId,
        businessName,
        businessAddress,
        businessPan,
        businessIrdn,
        taxPeriod,
        startDate,
        endDate,
        filingDate,
        returnType,
        status,
        totalSales,
        totalPurchases,
        taxableSales,
        exemptSales,
        zeroRatedSales,
        inputTax,
        outputTax,
        netTaxPayable,
        taxPaid,
        taxRefundable,
        penalty,
        interest,
        totalAmountDue,
        salesItems,
        purchaseItems,
        taxDetails,
        summary,
        generatedBy,
        approvedBy,
        submittedTo,
        submittedDate,
        submissionReference,
        irdnReference,
        irdnStatus,
        irdnProcessedDate,
        comments,
        metadata,
        createdAt,
        updatedAt,
      ];

  VatReturnEntity copyWith({
    String? id,
    String? businessId,
    String? businessName,
    String? businessAddress,
    String? businessPan,
    String? businessIrdn,
    String? taxPeriod,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? filingDate,
    VatReturnType? returnType,
    VatReturnStatus? status,
    double? totalSales,
    double? totalPurchases,
    double? taxableSales,
    double? exemptSales,
    double? zeroRatedSales,
    double? inputTax,
    double? outputTax,
    double? netTaxPayable,
    double? taxPaid,
    double? taxRefundable,
    double? penalty,
    double? interest,
    double? totalAmountDue,
    List<VatReturnItem>? salesItems,
    List<VatReturnItem>? purchaseItems,
    List<VatTaxDetail>? taxDetails,
    VatReturnSummary? summary,
    String? generatedBy,
    String? approvedBy,
    String? submittedTo,
    DateTime? submittedDate,
    String? submissionReference,
    String? irdnReference,
    String? irdnStatus,
    DateTime? irdnProcessedDate,
    String? comments,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VatReturnEntity(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      businessName: businessName ?? this.businessName,
      businessAddress: businessAddress ?? this.businessAddress,
      businessPan: businessPan ?? this.businessPan,
      businessIrdn: businessIrdn ?? this.businessIrdn,
      taxPeriod: taxPeriod ?? this.taxPeriod,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      filingDate: filingDate ?? this.filingDate,
      returnType: returnType ?? this.returnType,
      status: status ?? this.status,
      totalSales: totalSales ?? this.totalSales,
      totalPurchases: totalPurchases ?? this.totalPurchases,
      taxableSales: taxableSales ?? this.taxableSales,
      exemptSales: exemptSales ?? this.exemptSales,
      zeroRatedSales: zeroRatedSales ?? this.zeroRatedSales,
      inputTax: inputTax ?? this.inputTax,
      outputTax: outputTax ?? this.outputTax,
      netTaxPayable: netTaxPayable ?? this.netTaxPayable,
      taxPaid: taxPaid ?? this.taxPaid,
      taxRefundable: taxRefundable ?? this.taxRefundable,
      penalty: penalty ?? this.penalty,
      interest: interest ?? this.interest,
      totalAmountDue: totalAmountDue ?? this.totalAmountDue,
      salesItems: salesItems ?? this.salesItems,
      purchaseItems: purchaseItems ?? this.purchaseItems,
      taxDetails: taxDetails ?? this.taxDetails,
      summary: summary ?? this.summary,
      generatedBy: generatedBy ?? this.generatedBy,
      approvedBy: approvedBy ?? this.approvedBy,
      submittedTo: submittedTo ?? this.submittedTo,
      submittedDate: submittedDate ?? this.submittedDate,
      submissionReference: submissionReference ?? this.submissionReference,
      irdnReference: irdnReference ?? this.irdnReference,
      irdnStatus: irdnStatus ?? this.irdnStatus,
      irdnProcessedDate: irdnProcessedDate ?? this.irdnProcessedDate,
      comments: comments ?? this.comments,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'businessId': businessId,
      'businessName': businessName,
      'businessAddress': businessAddress,
      'businessPan': businessPan,
      'businessIrdn': businessIrdn,
      'taxPeriod': taxPeriod,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'filingDate': filingDate.toIso8601String(),
      'returnType': returnType.name,
      'status': status.name,
      'totalSales': totalSales,
      'totalPurchases': totalPurchases,
      'taxableSales': taxableSales,
      'exemptSales': exemptSales,
      'zeroRatedSales': zeroRatedSales,
      'inputTax': inputTax,
      'outputTax': outputTax,
      'netTaxPayable': netTaxPayable,
      'taxPaid': taxPaid,
      'taxRefundable': taxRefundable,
      'penalty': penalty,
      'interest': interest,
      'totalAmountDue': totalAmountDue,
      'salesItems': salesItems.map((item) => item.toMap()).toList(),
      'purchaseItems': purchaseItems.map((item) => item.toMap()).toList(),
      'taxDetails': taxDetails.map((detail) => detail.toMap()).toList(),
      'summary': summary.toMap(),
      'generatedBy': generatedBy,
      'approvedBy': approvedBy,
      'submittedTo': submittedTo,
      'submittedDate': submittedDate?.toIso8601String(),
      'submissionReference': submissionReference,
      'irdnReference': irdnReference,
      'irdnStatus': irdnStatus,
      'irdnProcessedDate': irdnProcessedDate?.toIso8601String(),
      'comments': comments,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory VatReturnEntity.fromMap(Map<String, dynamic> map) {
    return VatReturnEntity(
      id: map['id'] ?? '',
      businessId: map['businessId'] ?? '',
      businessName: map['businessName'] ?? '',
      businessAddress: map['businessAddress'] ?? '',
      businessPan: map['businessPan'] ?? '',
      businessIrdn: map['businessIrdn'] ?? '',
      taxPeriod: map['taxPeriod'] ?? '',
      startDate: DateTime.parse(map['startDate']),
      endDate: DateTime.parse(map['endDate']),
      filingDate: DateTime.parse(map['filingDate']),
      returnType: VatReturnType.values.firstWhere(
        (type) => type.name == map['returnType'],
        orElse: () => VatReturnType.monthly,
      ),
      status: VatReturnStatus.values.firstWhere(
        (status) => status.name == map['status'],
        orElse: () => VatReturnStatus.draft,
      ),
      totalSales: (map['totalSales'] ?? 0.0).toDouble(),
      totalPurchases: (map['totalPurchases'] ?? 0.0).toDouble(),
      taxableSales: (map['taxableSales'] ?? 0.0).toDouble(),
      exemptSales: (map['exemptSales'] ?? 0.0).toDouble(),
      zeroRatedSales: (map['zeroRatedSales'] ?? 0.0).toDouble(),
      inputTax: (map['inputTax'] ?? 0.0).toDouble(),
      outputTax: (map['outputTax'] ?? 0.0).toDouble(),
      netTaxPayable: (map['netTaxPayable'] ?? 0.0).toDouble(),
      taxPaid: (map['taxPaid'] ?? 0.0).toDouble(),
      taxRefundable: (map['taxRefundable'] ?? 0.0).toDouble(),
      penalty: (map['penalty'] ?? 0.0).toDouble(),
      interest: (map['interest'] ?? 0.0).toDouble(),
      totalAmountDue: (map['totalAmountDue'] ?? 0.0).toDouble(),
      salesItems: (map['salesItems'] as List<dynamic>?)
              ?.map((item) => VatReturnItem.fromMap(item))
              .toList() ??
          [],
      purchaseItems: (map['purchaseItems'] as List<dynamic>?)
              ?.map((item) => VatReturnItem.fromMap(item))
              .toList() ??
          [],
      taxDetails: (map['taxDetails'] as List<dynamic>?)
              ?.map((detail) => VatTaxDetail.fromMap(detail))
              .toList() ??
          [],
      summary: VatReturnSummary.fromMap(map['summary'] ?? {}),
      generatedBy: map['generatedBy'],
      approvedBy: map['approvedBy'],
      submittedTo: map['submittedTo'],
      submittedDate: map['submittedDate'] != null
          ? DateTime.parse(map['submittedDate'])
          : null,
      submissionReference: map['submissionReference'],
      irdnReference: map['irdnReference'],
      irdnStatus: map['irdnStatus'],
      irdnProcessedDate: map['irdnProcessedDate'] != null
          ? DateTime.parse(map['irdnProcessedDate'])
          : null,
      comments: map['comments'],
      metadata: map['metadata'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }
}

/// VAT Return Type Enum
enum VatReturnType {
  monthly,
  quarterly,
  halfYearly,
  yearly,
  adHoc,
}

/// VAT Return Status Enum
enum VatReturnStatus {
  draft,
  pending,
  submitted,
  processing,
  approved,
  rejected,
  paid,
  refunded,
  cancelled,
  archived,
}

/// VAT Return Item Entity
class VatReturnItem extends Equatable {
  final String id;
  final String description;
  final String? invoiceNumber;
  final DateTime? invoiceDate;
  final double amount;
  final double quantity;
  final double unitPrice;
  final VatRate vatRate;
  final double vatAmount;
  final double netAmount;
  final String? supplierName;
  final String? customerName;
  final String? category;
  final String? hsnCode;
  final String? sacCode;
  final bool isExport;
  final bool isExempt;
  final bool isZeroRated;
  final String? comments;
  final Map<String, dynamic>? metadata;

  const VatReturnItem({
    required this.id,
    required this.description,
    this.invoiceNumber,
    this.invoiceDate,
    required this.amount,
    required this.quantity,
    required this.unitPrice,
    required this.vatRate,
    required this.vatAmount,
    required this.netAmount,
    this.supplierName,
    this.customerName,
    this.category,
    this.hsnCode,
    this.sacCode,
    this.isExport = false,
    this.isExempt = false,
    this.isZeroRated = false,
    this.comments,
    this.metadata,
  });

  @override
  List<Object?> get props => [
        id,
        description,
        invoiceNumber,
        invoiceDate,
        amount,
        quantity,
        unitPrice,
        vatRate,
        vatAmount,
        netAmount,
        supplierName,
        customerName,
        category,
        hsnCode,
        sacCode,
        isExport,
        isExempt,
        isZeroRated,
        comments,
        metadata,
      ];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'invoiceNumber': invoiceNumber,
      'invoiceDate': invoiceDate?.toIso8601String(),
      'amount': amount,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'vatRate': vatRate.value,
      'vatAmount': vatAmount,
      'netAmount': netAmount,
      'supplierName': supplierName,
      'customerName': customerName,
      'category': category,
      'hsnCode': hsnCode,
      'sacCode': sacCode,
      'isExport': isExport,
      'isExempt': isExempt,
      'isZeroRated': isZeroRated,
      'comments': comments,
      'metadata': metadata,
    };
  }

  factory VatReturnItem.fromMap(Map<String, dynamic> map) {
    return VatReturnItem(
      id: map['id'] ?? '',
      description: map['description'] ?? '',
      invoiceNumber: map['invoiceNumber'],
      invoiceDate: map['invoiceDate'] != null
          ? DateTime.parse(map['invoiceDate'])
          : null,
      amount: (map['amount'] ?? 0.0).toDouble(),
      quantity: (map['quantity'] ?? 0.0).toDouble(),
      unitPrice: (map['unitPrice'] ?? 0.0).toDouble(),
      vatRate: VatRate.fromValue(map['vatRate'] ?? 0.0),
      vatAmount: (map['vatAmount'] ?? 0.0).toDouble(),
      netAmount: (map['netAmount'] ?? 0.0).toDouble(),
      supplierName: map['supplierName'],
      customerName: map['customerName'],
      category: map['category'],
      hsnCode: map['hsnCode'],
      sacCode: map['sacCode'],
      isExport: map['isExport'] ?? false,
      isExempt: map['isExempt'] ?? false,
      isZeroRated: map['isZeroRated'] ?? false,
      comments: map['comments'],
      metadata: map['metadata'],
    );
  }
}

/// VAT Rate Enum
enum VatRate {
  exempt(0.0),
  zero(0.0),
  standard(13.0),
  reduced(5.0),
  special(10.0);

  const VatRate(this.value);
  final double value;

  static VatRate fromValue(double value) {
    return VatRate.values.firstWhere(
      (rate) => rate.value == value,
      orElse: () => VatRate.standard,
    );
  }
}

/// VAT Tax Detail Entity
class VatTaxDetail extends Equatable {
  final String id;
  final VatRate vatRate;
  final double taxableAmount;
  final double vatAmount;
  final int itemCount;
  final String description;
  final Map<String, dynamic>? metadata;

  const VatTaxDetail({
    required this.id,
    required this.vatRate,
    required this.taxableAmount,
    required this.vatAmount,
    required this.itemCount,
    required this.description,
    this.metadata,
  });

  @override
  List<Object?> get props => [
        id,
        vatRate,
        taxableAmount,
        vatAmount,
        itemCount,
        description,
        metadata,
      ];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vatRate': vatRate.value,
      'taxableAmount': taxableAmount,
      'vatAmount': vatAmount,
      'itemCount': itemCount,
      'description': description,
      'metadata': metadata,
    };
  }

  factory VatTaxDetail.fromMap(Map<String, dynamic> map) {
    return VatTaxDetail(
      id: map['id'] ?? '',
      vatRate: VatRate.fromValue(map['vatRate'] ?? 0.0),
      taxableAmount: (map['taxableAmount'] ?? 0.0).toDouble(),
      vatAmount: (map['vatAmount'] ?? 0.0).toDouble(),
      itemCount: map['itemCount'] ?? 0,
      description: map['description'] ?? '',
      metadata: map['metadata'],
    );
  }
}

/// VAT Return Summary Entity
class VatReturnSummary extends Equatable {
  final double totalSales;
  final double totalPurchases;
  final double totalTaxableSales;
  final double totalExemptSales;
  final double totalZeroRatedSales;
  final double totalInputTax;
  final double totalOutputTax;
  final double totalNetTaxPayable;
  final double totalTaxPaid;
  final double totalTaxRefundable;
  final double totalPenalty;
  final double totalInterest;
  final double totalAmountDue;
  final int totalSalesItems;
  final int totalPurchaseItems;
  final Map<VatRate, VatRateSummary> rateSummaries;

  const VatReturnSummary({
    required this.totalSales,
    required this.totalPurchases,
    required this.totalTaxableSales,
    required this.totalExemptSales,
    required this.totalZeroRatedSales,
    required this.totalInputTax,
    required this.totalOutputTax,
    required this.totalNetTaxPayable,
    required this.totalTaxPaid,
    required this.totalTaxRefundable,
    required this.totalPenalty,
    required this.totalInterest,
    required this.totalAmountDue,
    required this.totalSalesItems,
    required this.totalPurchaseItems,
    required this.rateSummaries,
  });

  @override
  List<Object?> get props => [
        totalSales,
        totalPurchases,
        totalTaxableSales,
        totalExemptSales,
        totalZeroRatedSales,
        totalInputTax,
        totalOutputTax,
        totalNetTaxPayable,
        totalTaxPaid,
        totalTaxRefundable,
        totalPenalty,
        totalInterest,
        totalAmountDue,
        totalSalesItems,
        totalPurchaseItems,
        rateSummaries,
      ];

  Map<String, dynamic> toMap() {
    return {
      'totalSales': totalSales,
      'totalPurchases': totalPurchases,
      'totalTaxableSales': totalTaxableSales,
      'totalExemptSales': totalExemptSales,
      'totalZeroRatedSales': totalZeroRatedSales,
      'totalInputTax': totalInputTax,
      'totalOutputTax': totalOutputTax,
      'totalNetTaxPayable': totalNetTaxPayable,
      'totalTaxPaid': totalTaxPaid,
      'totalTaxRefundable': totalTaxRefundable,
      'totalPenalty': totalPenalty,
      'totalInterest': totalInterest,
      'totalAmountDue': totalAmountDue,
      'totalSalesItems': totalSalesItems,
      'totalPurchaseItems': totalPurchaseItems,
      'rateSummaries': rateSummaries.map(
        (key, value) => MapEntry(key.value.toString(), value.toMap()),
      ),
    };
  }

  factory VatReturnSummary.fromMap(Map<String, dynamic> map) {
    return VatReturnSummary(
      totalSales: (map['totalSales'] ?? 0.0).toDouble(),
      totalPurchases: (map['totalPurchases'] ?? 0.0).toDouble(),
      totalTaxableSales: (map['totalTaxableSales'] ?? 0.0).toDouble(),
      totalExemptSales: (map['totalExemptSales'] ?? 0.0).toDouble(),
      totalZeroRatedSales: (map['totalZeroRatedSales'] ?? 0.0).toDouble(),
      totalInputTax: (map['totalInputTax'] ?? 0.0).toDouble(),
      totalOutputTax: (map['totalOutputTax'] ?? 0.0).toDouble(),
      totalNetTaxPayable: (map['totalNetTaxPayable'] ?? 0.0).toDouble(),
      totalTaxPaid: (map['totalTaxPaid'] ?? 0.0).toDouble(),
      totalTaxRefundable: (map['totalTaxRefundable'] ?? 0.0).toDouble(),
      totalPenalty: (map['totalPenalty'] ?? 0.0).toDouble(),
      totalInterest: (map['totalInterest'] ?? 0.0).toDouble(),
      totalAmountDue: (map['totalAmountDue'] ?? 0.0).toDouble(),
      totalSalesItems: map['totalSalesItems'] ?? 0,
      totalPurchaseItems: map['totalPurchaseItems'] ?? 0,
      rateSummaries: (map['rateSummaries'] as Map<String, dynamic>?)
              ?.map(
                (key, value) => MapEntry(
                  VatRate.fromValue(double.parse(key)),
                  VatRateSummary.fromMap(value),
                ),
              ) ??
          {},
    );
  }
}

/// VAT Rate Summary Entity
class VatRateSummary extends Equatable {
  final VatRate vatRate;
  final double taxableAmount;
  final double vatAmount;
  final int itemCount;

  const VatRateSummary({
    required this.vatRate,
    required this.taxableAmount,
    required this.vatAmount,
    required this.itemCount,
  });

  @override
  List<Object?> get props => [vatRate, taxableAmount, vatAmount, itemCount];

  Map<String, dynamic> toMap() {
    return {
      'vatRate': vatRate.value,
      'taxableAmount': taxableAmount,
      'vatAmount': vatAmount,
      'itemCount': itemCount,
    };
  }

  factory VatRateSummary.fromMap(Map<String, dynamic> map) {
    return VatRateSummary(
      vatRate: VatRate.fromValue(map['vatRate'] ?? 0.0),
      taxableAmount: (map['taxableAmount'] ?? 0.0).toDouble(),
      vatAmount: (map['vatAmount'] ?? 0.0).toDouble(),
      itemCount: map['itemCount'] ?? 0,
    );
  }
}
