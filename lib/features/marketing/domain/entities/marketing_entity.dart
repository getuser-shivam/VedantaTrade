import 'package:equatable/equatable.dart';

class MarketingCampaignEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final String type; // discount, promotion, awareness, loyalty
  final String status; // draft, active, paused, completed, cancelled
  final DateTime startDate;
  final DateTime endDate;
  final double? budget;
  final double? spent;
  final String targetAudience; // all, retailers, doctors, stockists
  final List<String> targetProducts;
  final List<String> targetRegions;
  final Map<String, dynamic> rules;
  final List<PromotionRuleEntity> promotionRules;
  final int totalParticipants;
  final int conversionRate;
  final double roi; // return on investment
  final String? imageUrl;
  final List<String> tags;
  final Map<String, dynamic> analytics;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MarketingCampaignEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.status,
    required this.startDate,
    required this.endDate,
    this.budget,
    this.spent,
    required this.targetAudience,
    required this.targetProducts,
    required this.targetRegions,
    required this.rules,
    required this.promotionRules,
    required this.totalParticipants,
    required this.conversionRate,
    required this.roi,
    this.imageUrl,
    required this.tags,
    required this.analytics,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        type,
        status,
        startDate,
        endDate,
        budget,
        spent,
        targetAudience,
        targetProducts,
        targetRegions,
        rules,
        promotionRules,
        totalParticipants,
        conversionRate,
        roi,
        imageUrl,
        tags,
        analytics,
        createdBy,
        createdAt,
        updatedAt,
      ];

  // Computed properties
  bool get isDraft => status == 'draft';
  bool get isActive => status == 'active';
  bool get isPaused => status == 'paused';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';
  bool get isUpcoming => DateTime.now().isBefore(startDate);
  bool get isRunning => DateTime.now().isAfter(startDate) && DateTime.now().isBefore(endDate);
  bool get isExpired => DateTime.now().isAfter(endDate);
  bool get isOverBudget => budget != null && spent != null && spent! > budget!;
  double get budgetUtilization => budget != null && spent != null ? (spent! / budget!) * 100 : 0.0;
  int get durationInDays => endDate.difference(startDate).inDays;
  int get daysRemaining => isRunning ? endDate.difference(DateTime.now()).inDays : 0;
  double get averageDailySpend => spent != null && durationInDays > 0 ? spent! / durationInDays : 0.0;

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
        return 'Unknown';
    }
  }

  String get typeDisplay {
    switch (type) {
      case 'discount':
        return 'Discount Campaign';
      case 'promotion':
        return 'Promotion';
      case 'awareness':
        return 'Awareness Campaign';
      case 'loyalty':
        return 'Loyalty Program';
      default:
        return 'Unknown';
    }
  }

  MarketingCampaignEntity copyWith({
    String? id,
    String? name,
    String? description,
    String? type,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    double? budget,
    double? spent,
    String? targetAudience,
    List<String>? targetProducts,
    List<String>? targetRegions,
    Map<String, dynamic>? rules,
    List<PromotionRuleEntity>? promotionRules,
    int? totalParticipants,
    int? conversionRate,
    double? roi,
    String? imageUrl,
    List<String>? tags,
    Map<String, dynamic>? analytics,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MarketingCampaignEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      budget: budget ?? this.budget,
      spent: spent ?? this.spent,
      targetAudience: targetAudience ?? this.targetAudience,
      targetProducts: targetProducts ?? this.targetProducts,
      targetRegions: targetRegions ?? this.targetRegions,
      rules: rules ?? this.rules,
      promotionRules: promotionRules ?? this.promotionRules,
      totalParticipants: totalParticipants ?? this.totalParticipants,
      conversionRate: conversionRate ?? this.conversionRate,
      roi: roi ?? this.roi,
      imageUrl: imageUrl ?? this.imageUrl,
      tags: tags ?? this.tags,
      analytics: analytics ?? this.analytics,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type,
      'status': status,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'budget': budget,
      'spent': spent,
      'target_audience': targetAudience,
      'target_products': targetProducts,
      'target_regions': targetRegions,
      'rules': rules,
      'promotion_rules': promotionRules.map((rule) => rule.toJson()).toList(),
      'total_participants': totalParticipants,
      'conversion_rate': conversionRate,
      'roi': roi,
      'image_url': imageUrl,
      'tags': tags,
      'analytics': analytics,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory MarketingCampaignEntity.fromJson(Map<String, dynamic> json) {
    return MarketingCampaignEntity(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? 'discount',
      status: json['status'] ?? 'draft',
      startDate: DateTime.parse(json['start_date'] ?? json['startDate']),
      endDate: DateTime.parse(json['end_date'] ?? json['endDate']),
      budget: json['budget']?.toDouble(),
      spent: json['spent']?.toDouble(),
      targetAudience: json['target_audience'] ?? json['targetAudience'] ?? 'all',
      targetProducts: List<String>.from(json['target_products'] ?? json['targetProducts'] ?? []),
      targetRegions: List<String>.from(json['target_regions'] ?? json['targetRegions'] ?? []),
      rules: json['rules'] ?? {},
      promotionRules: (json['promotion_rules'] as List<dynamic>?)
          ?.map((rule) => PromotionRuleEntity.fromJson(rule))
          .toList() ?? [],
      totalParticipants: json['total_participants'] ?? json['totalParticipants'] ?? 0,
      conversionRate: json['conversion_rate'] ?? json['conversionRate'] ?? 0,
      roi: (json['roi'] ?? 0).toDouble(),
      imageUrl: json['image_url'] ?? json['imageUrl'],
      tags: List<String>.from(json['tags'] ?? []),
      analytics: json['analytics'] ?? {},
      createdBy: json['created_by'] ?? json['createdBy'] ?? '',
      createdAt: DateTime.parse(json['created_at'] ?? json['createdAt']),
      updatedAt: DateTime.parse(json['updated_at'] ?? json['updatedAt']),
    );
  }
}

class PromotionRuleEntity extends Equatable {
  final String id;
  final String campaignId;
  final String type; // percentage_discount, fixed_discount, buy_x_get_y, free_shipping
  final String condition; // minimum_quantity, minimum_amount, specific_products
  final double? discountPercentage;
  final double? discountAmount;
  final int? minimumQuantity;
  final double? minimumAmount;
  final List<String> applicableProducts;
  final List<String> excludedProducts;
  final int maxUsagePerCustomer;
  final int maxTotalUsage;
  final int currentUsage;
  final bool isActive;
  final DateTime? validFrom;
  final DateTime? validUntil;
  final Map<String, dynamic> metadata;

  const PromotionRuleEntity({
    required this.id,
    required this.campaignId,
    required this.type,
    required this.condition,
    this.discountPercentage,
    this.discountAmount,
    this.minimumQuantity,
    this.minimumAmount,
    required this.applicableProducts,
    required this.excludedProducts,
    required this.maxUsagePerCustomer,
    required this.maxTotalUsage,
    required this.currentUsage,
    required this.isActive,
    this.validFrom,
    this.validUntil,
    required this.metadata,
  });

  @override
  List<Object?> get props => [
        id,
        campaignId,
        type,
        condition,
        discountPercentage,
        discountAmount,
        minimumQuantity,
        minimumAmount,
        applicableProducts,
        excludedProducts,
        maxUsagePerCustomer,
        maxTotalUsage,
        currentUsage,
        isActive,
        validFrom,
        validUntil,
        metadata,
      ];

  // Computed properties
  bool get isPercentageDiscount => type == 'percentage_discount';
  bool get isFixedDiscount => type == 'fixed_discount';
  bool get isBuyXGetY => type == 'buy_x_get_y';
  bool get isFreeShipping => type == 'free_shipping';
  bool get isExpired => validUntil != null && DateTime.now().isAfter(validUntil!);
  bool get isNotStarted => validFrom != null && DateTime.now().isBefore(validFrom!);
  bool get isValid => !isExpired && !isNotStarted && isActive;
  bool get isFullyUsed => currentUsage >= maxTotalUsage;
  int get remainingUsage => maxTotalUsage - currentUsage;
  double get utilizationRate => maxTotalUsage > 0 ? (currentUsage / maxTotalUsage) * 100 : 0.0;

  String get typeDisplay {
    switch (type) {
      case 'percentage_discount':
        return '${discountPercentage?.toStringAsFixed(0)}% Off';
      case 'fixed_discount':
        return 'NPR ${discountAmount?.toStringAsFixed(0)} Off';
      case 'buy_x_get_y':
        return 'Buy X Get Y';
      case 'free_shipping':
        return 'Free Shipping';
      default:
        return 'Unknown';
    }
  }

  PromotionRuleEntity copyWith({
    String? id,
    String? campaignId,
    String? type,
    String? condition,
    double? discountPercentage,
    double? discountAmount,
    int? minimumQuantity,
    double? minimumAmount,
    List<String>? applicableProducts,
    List<String>? excludedProducts,
    int? maxUsagePerCustomer,
    int? maxTotalUsage,
    int? currentUsage,
    bool? isActive,
    DateTime? validFrom,
    DateTime? validUntil,
    Map<String, dynamic>? metadata,
  }) {
    return PromotionRuleEntity(
      id: id ?? this.id,
      campaignId: campaignId ?? this.campaignId,
      type: type ?? this.type,
      condition: condition ?? this.condition,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      discountAmount: discountAmount ?? this.discountAmount,
      minimumQuantity: minimumQuantity ?? this.minimumQuantity,
      minimumAmount: minimumAmount ?? this.minimumAmount,
      applicableProducts: applicableProducts ?? this.applicableProducts,
      excludedProducts: excludedProducts ?? this.excludedProducts,
      maxUsagePerCustomer: maxUsagePerCustomer ?? this.maxUsagePerCustomer,
      maxTotalUsage: maxTotalUsage ?? this.maxTotalUsage,
      currentUsage: currentUsage ?? this.currentUsage,
      isActive: isActive ?? this.isActive,
      validFrom: validFrom ?? this.validFrom,
      validUntil: validUntil ?? this.validUntil,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'campaign_id': campaignId,
      'type': type,
      'condition': condition,
      'discount_percentage': discountPercentage,
      'discount_amount': discountAmount,
      'minimum_quantity': minimumQuantity,
      'minimum_amount': minimumAmount,
      'applicable_products': applicableProducts,
      'excluded_products': excludedProducts,
      'max_usage_per_customer': maxUsagePerCustomer,
      'max_total_usage': maxTotalUsage,
      'current_usage': currentUsage,
      'is_active': isActive,
      'valid_from': validFrom?.toIso8601String(),
      'valid_until': validUntil?.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory PromotionRuleEntity.fromJson(Map<String, dynamic> json) {
    return PromotionRuleEntity(
      id: json['id'] ?? '',
      campaignId: json['campaign_id'] ?? json['campaignId'] ?? '',
      type: json['type'] ?? 'percentage_discount',
      condition: json['condition'] ?? json['condition'] ?? 'minimum_quantity',
      discountPercentage: json['discount_percentage']?.toDouble() ?? json['discountPercentage']?.toDouble(),
      discountAmount: json['discount_amount']?.toDouble() ?? json['discountAmount']?.toDouble(),
      minimumQuantity: json['minimum_quantity'] ?? json['minimumQuantity'],
      minimumAmount: json['minimum_amount']?.toDouble() ?? json['minimumAmount']?.toDouble(),
      applicableProducts: List<String>.from(json['applicable_products'] ?? json['applicableProducts'] ?? []),
      excludedProducts: List<String>.from(json['excluded_products'] ?? json['excludedProducts'] ?? []),
      maxUsagePerCustomer: json['max_usage_per_customer'] ?? json['maxUsagePerCustomer'] ?? 1,
      maxTotalUsage: json['max_total_usage'] ?? json['maxTotalUsage'] ?? 100,
      currentUsage: json['current_usage'] ?? json['currentUsage'] ?? 0,
      isActive: json['is_active'] ?? json['isActive'] ?? true,
      validFrom: json['valid_from'] != null
          ? DateTime.parse(json['valid_from'])
          : json['validFrom'] != null
              ? DateTime.parse(json['validFrom'])
              : null,
      validUntil: json['valid_until'] != null
          ? DateTime.parse(json['valid_until'])
          : json['validUntil'] != null
              ? DateTime.parse(json['validUntil'])
              : null,
      metadata: json['metadata'] ?? {},
    );
  }
}

class SalesAnalyticsEntity extends Equatable {
  final String id;
  final String productId;
  final String productName;
  final String period; // daily, weekly, monthly, yearly
  final DateTime periodStart;
  final DateTime periodEnd;
  final int totalUnitsSold;
  final double totalRevenue;
  final double totalProfit;
  final int totalOrders;
  final double averageOrderValue;
  final int uniqueCustomers;
  final double conversionRate;
  final Map<String, int> salesByRegion;
  final Map<String, int> salesByChannel;
  final List<String> topSellingProducts;
  final List<String> topCustomers;
  final Map<String, dynamic> trends;
  final String? competitorAnalysis;
  final Map<String, dynamic> marketShare;
  final DateTime createdAt;

  const SalesAnalyticsEntity({
    required this.id,
    required this.productId,
    required this.productName,
    required this.period,
    required this.periodStart,
    required this.periodEnd,
    required this.totalUnitsSold,
    required this.totalRevenue,
    required this.totalProfit,
    required this.totalOrders,
    required this.averageOrderValue,
    required this.uniqueCustomers,
    required this.conversionRate,
    required this.salesByRegion,
    required this.salesByChannel,
    required this.topSellingProducts,
    required this.topCustomers,
    required this.trends,
    this.competitorAnalysis,
    required this.marketShare,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        productId,
        productName,
        period,
        periodStart,
        periodEnd,
        totalUnitsSold,
        totalRevenue,
        totalProfit,
        totalOrders,
        averageOrderValue,
        uniqueCustomers,
        conversionRate,
        salesByRegion,
        salesByChannel,
        topSellingProducts,
        topCustomers,
        trends,
        competitorAnalysis,
        marketShare,
        createdAt,
      ];

  // Computed properties
  double get profitMargin => totalRevenue > 0 ? (totalProfit / totalRevenue) * 100 : 0.0;
  double get averageUnitsPerOrder => totalOrders > 0 ? totalUnitsSold / totalOrders : 0.0;
  double get revenuePerCustomer => uniqueCustomers > 0 ? totalRevenue / uniqueCustomers : 0.0;
  String get bestPerformingRegion {
    if (salesByRegion.isEmpty) return 'N/A';
    return salesByRegion.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }
  String get bestPerformingChannel {
    if (salesByChannel.isEmpty) return 'N/A';
    return salesByChannel.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'product_name': productName,
      'period': period,
      'period_start': periodStart.toIso8601String(),
      'period_end': periodEnd.toIso8601String(),
      'total_units_sold': totalUnitsSold,
      'total_revenue': totalRevenue,
      'total_profit': totalProfit,
      'total_orders': totalOrders,
      'average_order_value': averageOrderValue,
      'unique_customers': uniqueCustomers,
      'conversion_rate': conversionRate,
      'sales_by_region': salesByRegion,
      'sales_by_channel': salesByChannel,
      'top_selling_products': topSellingProducts,
      'top_customers': topCustomers,
      'trends': trends,
      'competitor_analysis': competitorAnalysis,
      'market_share': marketShare,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory SalesAnalyticsEntity.fromJson(Map<String, dynamic> json) {
    return SalesAnalyticsEntity(
      id: json['id'] ?? '',
      productId: json['product_id'] ?? json['productId'] ?? '',
      productName: json['product_name'] ?? json['productName'] ?? '',
      period: json['period'] ?? 'daily',
      periodStart: DateTime.parse(json['period_start'] ?? json['periodStart']),
      periodEnd: DateTime.parse(json['period_end'] ?? json['periodEnd']),
      totalUnitsSold: json['total_units_sold'] ?? json['totalUnitsSold'] ?? 0,
      totalRevenue: (json['total_revenue'] ?? json['totalRevenue'] ?? 0).toDouble(),
      totalProfit: (json['total_profit'] ?? json['totalProfit'] ?? 0).toDouble(),
      totalOrders: json['total_orders'] ?? json['totalOrders'] ?? 0,
      averageOrderValue: (json['average_order_value'] ?? json['averageOrderValue'] ?? 0).toDouble(),
      uniqueCustomers: json['unique_customers'] ?? json['uniqueCustomers'] ?? 0,
      conversionRate: (json['conversion_rate'] ?? json['conversionRate'] ?? 0).toDouble(),
      salesByRegion: Map<String, int>.from(json['sales_by_region'] ?? json['salesByRegion'] ?? {}),
      salesByChannel: Map<String, int>.from(json['sales_by_channel'] ?? json['salesByChannel'] ?? {}),
      topSellingProducts: List<String>.from(json['top_selling_products'] ?? json['topSellingProducts'] ?? []),
      topCustomers: List<String>.from(json['top_customers'] ?? json['topCustomers'] ?? []),
      trends: json['trends'] ?? {},
      competitorAnalysis: json['competitor_analysis'] ?? json['competitorAnalysis'],
      marketShare: Map<String, dynamic>.from(json['market_share'] ?? json['marketShare'] ?? {}),
      createdAt: DateTime.parse(json['created_at'] ?? json['createdAt']),
    );
  }
}
