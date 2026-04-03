import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/premium_glassmorphic_theme.dart';
import '../models/distribution_center_model.dart';

class MarketingCampaign {
  final String id;
  final String name;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final double budget;
  final String status;
  final String targetAudience;
  final List<String> products;
  final double discount;
  final String imageUrl;
  final DateTime createdAt;

  MarketingCampaign({
    required this.id,
    required this.name,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.budget,
    this.status = 'Planning',
    required this.targetAudience,
    required this.products,
    this.discount = 0.0,
    this.imageUrl = '',
    required this.createdAt,
  });

  factory MarketingCampaign.fromJson(Map<String, dynamic> json) {
    return MarketingCampaign(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      startDate: DateTime.tryParse(json['startDate']?.toString() ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(json['endDate']?.toString() ?? '') ?? DateTime.now(),
      budget: (json['budget'] ?? 0).toDouble(),
      status: json['status']?.toString() ?? 'Planning',
      targetAudience: json['targetAudience']?.toString() ?? '',
      products: List<String>.from(json['products'] ?? []),
      discount: (json['discount'] ?? 0).toDouble(),
      imageUrl: json['imageUrl']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'budget': budget,
      'status': status,
      'targetAudience': targetAudience,
      'products': products,
      'discount': discount,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  MarketingCampaign copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    double? budget,
    String? status,
    String? targetAudience,
    List<String>? products,
    double? discount,
    String? imageUrl,
    DateTime? createdAt,
  }) {
    return MarketingCampaign(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      budget: budget ?? this.budget,
      status: status ?? this.status,
      targetAudience: targetAudience ?? this.targetAudience,
      products: products ?? this.products,
      discount: discount ?? this.discount,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool get isActive => status == 'Active';
  bool get isUpcoming => status == 'Upcoming';
  bool get isCompleted => status == 'Completed';
  bool get isPaused => status == 'Paused';

  String get statusDisplay {
    switch (status) {
      case 'Planning':
        return 'Planning';
      case 'Active':
        return 'Active';
      case 'Upcoming':
        return 'Upcoming';
      case 'Completed':
        return 'Completed';
      case 'Paused':
        return 'Paused';
      case 'Cancelled':
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  int get durationInDays {
    return endDate.difference(startDate).inDays;
  }

  double get budgetUtilized {
    // Mock calculation - in real implementation, this would come from actual sales data
    return budget * 0.65; // 65% budget utilization
  }

  String get formattedBudget {
    return 'NPR ${budget.toStringAsFixed(2)}';
  }

  String get formattedDiscount {
    if (discount == 0) return 'No Discount';
    return '${discount.toStringAsFixed(1)}% OFF';
  }

  String get durationDisplay {
    final days = durationInDays;
    if (days == 0) return 'Today';
    if (days == 1) return '1 Day';
    if (days <= 7) return '$days Days';
    if (days <= 30) return '${(days / 7).floor()} Weeks';
    return '${(days / 30).floor()} Months';
  }

  List<String> get topProducts {
    return products.take(3).toList();
  }

  String get targetAudienceDisplay {
    switch (targetAudience) {
      case 'general':
        return 'General Public';
      case 'registered':
        return 'Registered Customers';
      case 'medical':
        return 'Medical Professionals';
      case 'senior':
        return 'Senior Citizens';
      case 'youth':
        return 'Youth (18-35)';
      default:
        return 'All Customers';
    }
  }
}
