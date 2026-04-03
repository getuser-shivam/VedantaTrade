import 'dart:convert';

class MarketingCampaign {
  final String id;
  final String name;
  final String description;
  final String type; // promotion, discount, awareness, launch
  final DateTime startDate;
  final DateTime endDate;
  final double budget;
  final double spent;
  final String status; // draft, active, paused, completed, cancelled
  final String? targetAudience;
  final List<String> targetProducts;
  final List<String> targetRegions;
  final String? imageUrl;
  final Map<String, dynamic> metrics;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  MarketingCampaign({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.budget,
    required this.spent,
    required this.status,
    this.targetAudience,
    required this.targetProducts,
    required this.targetRegions,
    this.imageUrl,
    required this.metrics,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MarketingCampaign.fromJson(Map<String, dynamic> json) {
    return MarketingCampaign(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      type: json['type'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      budget: (json['budget'] as num).toDouble(),
      spent: (json['spent'] as num).toDouble(),
      status: json['status'] as String,
      targetAudience: json['target_audience'] as String?,
      targetProducts: List<String>.from(json['target_products'] as List),
      targetRegions: List<String>.from(json['target_regions'] as List),
      imageUrl: json['image_url'] as String?,
      metrics: Map<String, dynamic>.from(json['metrics'] as Map),
      createdBy: json['created_by'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'budget': budget,
      'spent': spent,
      'status': status,
      'target_audience': targetAudience,
      'target_products': targetProducts,
      'target_regions': targetRegions,
      'image_url': imageUrl,
      'metrics': metrics,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  MarketingCampaign copyWith({
    String? id,
    String? name,
    String? description,
    String? type,
    DateTime? startDate,
    DateTime? endDate,
    double? budget,
    double? spent,
    String? status,
    String? targetAudience,
    List<String>? targetProducts,
    List<String>? targetRegions,
    String? imageUrl,
    Map<String, dynamic>? metrics,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MarketingCampaign(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      budget: budget ?? this.budget,
      spent: spent ?? this.spent,
      status: status ?? this.status,
      targetAudience: targetAudience ?? this.targetAudience,
      targetProducts: targetProducts ?? this.targetProducts,
      targetRegions: targetRegions ?? this.targetRegions,
      imageUrl: imageUrl ?? this.imageUrl,
      metrics: metrics ?? this.metrics,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // UI Helper Properties
  String get typeDisplay {
    switch (type) {
      case 'promotion':
        return 'Promotion';
      case 'discount':
        return 'Discount';
      case 'awareness':
        return 'Awareness';
      case 'launch':
        return 'Product Launch';
      default:
        return type;
    }
  }

  String get statusDisplay {
    switch (status) {
      case 'draft':
        return 'Draft';
      case 'active':
        return 'Active';
      case 'paused':
        return 'Paused';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  String get formattedBudget => 'NPR ${budget.toStringAsFixed(2)}';
  String get formattedSpent => 'NPR ${spent.toStringAsFixed(2)}';
  String get formattedRemaining => 'NPR ${(budget - spent).toStringAsFixed(2)}';
  
  double get budgetUtilization => budget > 0 ? (spent / budget) * 100 : 0;
  String get formattedBudgetUtilization => '${budgetUtilization.toStringAsFixed(1)}%';
  
  String get formattedStartDate => '${startDate.day}/${startDate.month}/${startDate.year}';
  String get formattedEndDate => '${endDate.day}/${endDate.month}/${endDate.year}';
  String get formattedDuration => '${endDate.difference(startDate).inDays} days';
  
  bool get isActive => status == 'active';
  bool get isDraft => status == 'draft';
  bool get isCompleted => status == 'completed';
  bool get isPaused => status == 'paused';
  bool get isCancelled => status == 'cancelled';
  
  bool get isOverBudget => spent > budget;
  bool get isNearBudgetLimit => budgetUtilization > 80;
  bool get isExpired => DateTime.now().isAfter(endDate);
  bool get isUpcoming => DateTime.now().isBefore(startDate);
  
  // Campaign metrics helpers
  int get impressions => metrics['impressions'] as int? ?? 0;
  int get clicks => metrics['clicks'] as int? ?? 0;
  int get conversions => metrics['conversions'] as int? ?? 0;
  double get ctr => impressions > 0 ? (clicks / impressions) * 100 : 0;
  double get conversionRate => clicks > 0 ? (conversions / clicks) * 100 : 0;
  double get cpa => conversions > 0 ? spent / conversions : 0;
  
  String get formattedCTR => '${ctr.toStringAsFixed(2)}%';
  String get formattedConversionRate => '${conversionRate.toStringAsFixed(2)}%';
  String get formattedCPA => 'NPR ${cpa.toStringAsFixed(2)}';

  // Search helpers
  String get searchableText => 
      '$name $description $type $status $targetAudience'.toLowerCase();
}
