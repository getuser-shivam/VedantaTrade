import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/premium_glassmorphic_theme.dart';
import '../models/distribution_center_model.dart';
import '../models/marketing_campaign_model.dart';

class InventoryTransfer {
  final String id;
  final String fromCenter;
  final String toCenter;
  final List<String> productIds;
  final List<String> productNames;
  final List<int> quantities;
  final String status;
  final String? requestedBy;
  final DateTime? requestedAt;
  final String? approvedBy;
  final DateTime? approvedAt;
  final String? rejectedBy;
  final String? rejectedReason;
  final DateTime? rejectedAt;
  final DateTime createdAt;

  InventoryTransfer({
    required this.id,
    required this.fromCenter,
    required this.toCenter,
    required this.productIds,
    required this.productNames,
    required this.quantities,
    this.status = 'Pending',
    this.requestedBy,
    this.requestedAt,
    this.approvedBy,
    this.approvedAt,
    this.rejectedBy,
    this.rejectedReason,
    this.rejectedAt,
    required this.createdAt,
  });

  factory InventoryTransfer.fromJson(Map<String, dynamic> json) {
    return InventoryTransfer(
      id: json['id']?.toString() ?? '',
      fromCenter: json['fromCenter']?.toString() ?? '',
      toCenter: json['toCenter']?.toString() ?? '',
      productIds: List<String>.from(json['productIds'] ?? []),
      productNames: List<String>.from(json['productNames'] ?? []),
      quantities: List<int>.from(json['quantities'] ?? []),
      status: json['status']?.toString() ?? 'Pending',
      requestedBy: json['requestedBy']?.toString(),
      requestedAt: json['requestedAt'] != null 
          ? DateTime.tryParse(json['requestedAt'].toString())
          : null,
      approvedBy: json['approvedBy']?.toString(),
      approvedAt: json['approvedAt'] != null 
          ? DateTime.tryParse(json['approvedAt'].toString())
          : null,
      rejectedBy: json['rejectedBy']?.toString(),
      rejectedReason: json['rejectedReason']?.toString(),
      rejectedAt: json['rejectedAt'] != null 
          ? DateTime.tryParse(json['rejectedAt'].toString())
          : null,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fromCenter': fromCenter,
      'toCenter': toCenter,
      'productIds': productIds,
      'productNames': productNames,
      'quantities': quantities,
      'status': status,
      'requestedBy': requestedBy,
      'requestedAt': requestedAt?.toIso8601String(),
      'approvedBy': approvedBy,
      'approvedAt': approvedAt?.toIso8601String(),
      'rejectedBy': rejectedBy,
      'rejectedReason': rejectedReason,
      'rejectedAt': rejectedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  InventoryTransfer copyWith({
    String? id,
    String? fromCenter,
    String? toCenter,
    List<String>? productIds,
    List<String>? productNames,
    List<int>? quantities,
    String? status,
    String? requestedBy,
    DateTime? requestedAt,
    String? approvedBy,
    DateTime? approvedAt,
    String? rejectedBy,
    String? rejectedReason,
    DateTime? rejectedAt,
    DateTime? createdAt,
  }) {
    return InventoryTransfer(
      id: id ?? this.id,
      fromCenter: fromCenter ?? this.fromCenter,
      toCenter: toCenter ?? this.toCenter,
      productIds: productIds ?? this.productIds,
      productNames: productNames ?? this.productNames,
      quantities: quantities ?? this.quantities,
      status: status ?? this.status,
      requestedBy: requestedBy ?? this.requestedBy,
      requestedAt: requestedAt ?? this.requestedAt,
      approvedBy: approvedBy ?? this.approvedBy,
      approvedAt: approvedAt ?? this.approvedAt,
      rejectedBy: rejectedBy ?? this.rejectedBy,
      rejectedReason: rejectedReason ?? this.rejectedReason,
      rejectedAt: rejectedAt ?? this.rejectedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool get isPending => status == 'Pending';
  bool get isApproved => status == 'Approved';
  bool get isRejected => status == 'Rejected';
  bool get isCompleted => status == 'Completed';

  String get statusDisplay {
    switch (status) {
      case 'Pending':
        return 'Pending Approval';
      case 'Approved':
        return 'Approved';
      case 'Rejected':
        return 'Rejected';
      case 'Completed':
        return 'Completed';
      case 'In Transit':
        return 'In Transit';
      default:
        return 'Unknown';
    }
  }

  Color get statusColor {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Approved':
        return Colors.green;
      case 'Rejected':
        return Colors.red;
      case 'Completed':
        return Colors.blue;
      case 'In Transit':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  int get totalProducts {
    return productIds.length;
  }

  int get totalQuantity {
    return quantities.fold(0, (sum, quantity) => sum + quantity);
  }

  String get productsDisplay {
    if (productNames.isEmpty) return 'No products';
    if (productNames.length <= 2) {
      return productNames.join(', ');
    }
    return '${productNames.take(2).join(', ')} + ${productNames.length - 2} more';
  }

  String get requestedAtDisplay {
    if (requestedAt == null) return 'Not specified';
    return '${requestedAt!.day}/${requestedAt!.month}/${requestedAt!.year}';
  }

  String get processedAtDisplay {
    if (approvedAt != null) {
      return '${approvedAt!.day}/${approvedAt!.month}/${approvedAt!.year}';
    }
    if (rejectedAt != null) {
      return '${rejectedAt!.day}/${rejectedAt!.month}/${rejectedAt!.year}';
    }
    return 'Not processed';
  }

  String get processingTime {
    if (requestedAt == null) return 'N/A';
    
    DateTime? processedDate = approvedAt ?? rejectedAt;
    if (processedDate == null) return 'N/A';
    
    final duration = processedDate.difference(requestedAt!);
    if (duration.inDays > 0) {
      return '${duration.inDays} days';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} hours';
    } else {
      return '${duration.inMinutes} minutes';
    }
  }
}
