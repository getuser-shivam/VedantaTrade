import 'package:equatable/equatable.dart';

class MarketingCampaign extends Equatable {
  final String id;
  final String name;
  final String description;
  final String type; // email, sms, social_media, print, tv, radio, digital, events
  final String category; // product_launch, seasonal, promotional, awareness, retention
  final String status; // draft, scheduled, active, paused, completed, cancelled
  final DateTime startDate;
  final DateTime endDate;
  final String targetAudience;
  final List<String> targetRegions;
  final List<String> targetProducts;
  final List<String> targetCustomerSegments;
  final double budget;
  final double actualCost;
  final String currency;
  final List<CampaignObjective> objectives;
  final List<String> keyMessages;
  final List<String> creativeAssets;
  final List<String> channels;
  final String campaignManagerId;
  final String campaignManagerName;
  final List<String> teamMembers;
  final Map<String, dynamic> performanceMetrics;
  final List<CampaignMilestone> milestones;
  final String? approvalStatus;
  final String? approvedBy;
  final DateTime? approvedDate;
  final String? notes;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MarketingCampaign({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.category,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.targetAudience,
    required this.targetRegions,
    required this.targetProducts,
    required this.targetCustomerSegments,
    required this.budget,
    required this.actualCost,
    this.currency = 'NPR',
    required this.objectives,
    required this.keyMessages,
    required this.creativeAssets,
    required this.channels,
    required this.campaignManagerId,
    required this.campaignManagerName,
    required this.teamMembers,
    required this.performanceMetrics,
    required this.milestones,
    this.approvalStatus,
    this.approvedBy,
    this.approvedDate,
    this.notes,
    this.tags = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory MarketingCampaign.fromJson(Map<String, dynamic> json) {
    return MarketingCampaign(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? '',
      category: json['category'] ?? '',
      status: json['status'] ?? 'draft',
      startDate: DateTime.parse(json['startDate'] ?? DateTime.now().toIso8601String()),
      endDate: DateTime.parse(json['endDate'] ?? DateTime.now().toIso8601String()),
      targetAudience: json['targetAudience'] ?? '',
      targetRegions: List<String>.from(json['targetRegions'] ?? []),
      targetProducts: List<String>.from(json['targetProducts'] ?? []),
      targetCustomerSegments: List<String>.from(json['targetCustomerSegments'] ?? []),
      budget: (json['budget'] ?? 0.0).toDouble(),
      actualCost: (json['actualCost'] ?? 0.0).toDouble(),
      currency: json['currency'] ?? 'NPR',
      objectives: (json['objectives'] as List?)
              ?.map((obj) => CampaignObjective.fromJson(obj))
              .toList() ??
          [],
      keyMessages: List<String>.from(json['keyMessages'] ?? []),
      creativeAssets: List<String>.from(json['creativeAssets'] ?? []),
      channels: List<String>.from(json['channels'] ?? []),
      campaignManagerId: json['campaignManagerId'] ?? '',
      campaignManagerName: json['campaignManagerName'] ?? '',
      teamMembers: List<String>.from(json['teamMembers'] ?? []),
      performanceMetrics: Map<String, dynamic>.from(json['performanceMetrics'] ?? {}),
      milestones: (json['milestones'] as List?)
              ?.map((milestone) => CampaignMilestone.fromJson(milestone))
              .toList() ??
          [],
      approvalStatus: json['approvalStatus'],
      approvedBy: json['approvedBy'],
      approvedDate: json['approvedDate'] != null
          ? DateTime.parse(json['approvedDate'])
          : null,
      notes: json['notes'],
      tags: List<String>.from(json['tags'] ?? []),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type,
      'category': category,
      'status': status,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'targetAudience': targetAudience,
      'targetRegions': targetRegions,
      'targetProducts': targetProducts,
      'targetCustomerSegments': targetCustomerSegments,
      'budget': budget,
      'actualCost': actualCost,
      'currency': currency,
      'objectives': objectives.map((obj) => obj.toJson()).toList(),
      'keyMessages': keyMessages,
      'creativeAssets': creativeAssets,
      'channels': channels,
      'campaignManagerId': campaignManagerId,
      'campaignManagerName': campaignManagerName,
      'teamMembers': teamMembers,
      'performanceMetrics': performanceMetrics,
      'milestones': milestones.map((milestone) => milestone.toJson()).toList(),
      'approvalStatus': approvalStatus,
      'approvedBy': approvedBy,
      'approvedDate': approvedDate?.toIso8601String(),
      'notes': notes,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Computed properties
  bool get isDraft => status == 'draft';
  bool get isScheduled => status == 'scheduled';
  bool get isActive => status == 'active';
  bool get isPaused => status == 'paused';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';
  
  bool get isOverBudget => actualCost > budget;
  double get budgetUtilization => budget > 0 ? (actualCost / budget) * 100 : 0;
  bool get isRunning => DateTime.now().isAfter(startDate) && DateTime.now().isBefore(endDate);
  bool get isUpcoming => DateTime.now().isBefore(startDate);
  bool get isPast => DateTime.now().isAfter(endDate);
  
  Duration get duration => endDate.difference(startDate);
  int get daysRemaining => endDate.difference(DateTime.now()).inDays;
  int get daysElapsed => DateTime.now().difference(startDate).inDays;

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        type,
        category,
        status,
        startDate,
        endDate,
        targetAudience,
        targetRegions,
        targetProducts,
        targetCustomerSegments,
        budget,
        actualCost,
        currency,
        objectives,
        keyMessages,
        creativeAssets,
        channels,
        campaignManagerId,
        campaignManagerName,
        teamMembers,
        performanceMetrics,
        milestones,
        approvalStatus,
        approvedBy,
        approvedDate,
        notes,
        tags,
        createdAt,
        updatedAt,
      ];
}

class CampaignObjective extends Equatable {
  final String id;
  final String type; // awareness, lead_generation, sales, engagement, retention
  final String description;
  final String metric; // impressions, clicks, leads, sales, engagement_rate, retention_rate
  final double targetValue;
  final double currentValue;
  final String unit; // count, percentage, currency
  final bool isAchieved;
  final DateTime? achievedDate;

  const CampaignObjective({
    required this.id,
    required this.type,
    required this.description,
    required this.metric,
    required this.targetValue,
    required this.currentValue,
    required this.unit,
    this.isAchieved = false,
    this.achievedDate,
  });

  factory CampaignObjective.fromJson(Map<String, dynamic> json) {
    return CampaignObjective(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      description: json['description'] ?? '',
      metric: json['metric'] ?? '',
      targetValue: (json['targetValue'] ?? 0.0).toDouble(),
      currentValue: (json['currentValue'] ?? 0.0).toDouble(),
      unit: json['unit'] ?? '',
      isAchieved: json['isAchieved'] ?? false,
      achievedDate: json['achievedDate'] != null
          ? DateTime.parse(json['achievedDate'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'description': description,
      'metric': metric,
      'targetValue': targetValue,
      'currentValue': currentValue,
      'unit': unit,
      'isAchieved': isAchieved,
      'achievedDate': achievedDate?.toIso8601String(),
    };
  }

  double get progress => targetValue > 0 ? (currentValue / targetValue) * 100 : 0;

  @override
  List<Object?> get props => [
        id,
        type,
        description,
        metric,
        targetValue,
        currentValue,
        unit,
        isAchieved,
        achievedDate,
      ];
}

class CampaignMilestone extends Equatable {
  final String id;
  final String title;
  final String description;
  final DateTime plannedDate;
  final DateTime? actualDate;
  final String status; // pending, in_progress, completed, delayed
  final String? assignedTo;
  final String? assignedToName;
  final List<String> dependencies;
  final List<String> deliverables;
  final double progressPercentage;
  final String? notes;

  const CampaignMilestone({
    required this.id,
    required this.title,
    required this.description,
    required this.plannedDate,
    this.actualDate,
    required this.status,
    this.assignedTo,
    this.assignedToName,
    this.dependencies = const [],
    this.deliverables = const [],
    this.progressPercentage = 0.0,
    this.notes,
  });

  factory CampaignMilestone.fromJson(Map<String, dynamic> json) {
    return CampaignMilestone(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      plannedDate: DateTime.parse(json['plannedDate'] ?? DateTime.now().toIso8601String()),
      actualDate: json['actualDate'] != null
          ? DateTime.parse(json['actualDate'])
          : null,
      status: json['status'] ?? 'pending',
      assignedTo: json['assignedTo'],
      assignedToName: json['assignedToName'],
      dependencies: List<String>.from(json['dependencies'] ?? []),
      deliverables: List<String>.from(json['deliverables'] ?? []),
      progressPercentage: (json['progressPercentage'] ?? 0.0).toDouble(),
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'plannedDate': plannedDate.toIso8601String(),
      'actualDate': actualDate?.toIso8601String(),
      'status': status,
      'assignedTo': assignedTo,
      'assignedToName': assignedToName,
      'dependencies': dependencies,
      'deliverables': deliverables,
      'progressPercentage': progressPercentage,
      'notes': notes,
    };
  }

  bool get isPending => status == 'pending';
  bool get isInProgress => status == 'in_progress';
  bool get isCompleted => status == 'completed';
  bool get isDelayed => status == 'delayed';
  
  bool get isOverdue => !isCompleted && DateTime.now().isAfter(plannedDate);
  int get daysOverdue => isOverdue ? DateTime.now().difference(plannedDate).inDays : 0;

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        plannedDate,
        actualDate,
        status,
        assignedTo,
        assignedToName,
        dependencies,
        deliverables,
        progressPercentage,
        notes,
      ];
}

class MarketingAnalytics extends Equatable {
  final String id;
  final String campaignId;
  final String campaignName;
  final DateTime period;
  final String periodType; // daily, weekly, monthly, campaign_total
  final Map<String, double> metrics;
  final Map<String, double> channelPerformance;
  final Map<String, double> audienceEngagement;
  final Map<String, double> geographicPerformance;
  final List<String> topPerformingAssets;
  final List<String> underperformingAssets;
  final double totalImpressions;
  final double totalClicks;
  final double totalConversions;
  final double totalRevenue;
  final double totalCost;
  final double roi; // Return on Investment
  final double cpa; // Cost Per Acquisition
  final double cpc; // Cost Per Click
  final double cpm; // Cost Per Mille (Thousand Impressions)
  final double conversionRate;
  final double clickThroughRate;
  final double engagementRate;
  final List<String> recommendations;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MarketingAnalytics({
    required this.id,
    required this.campaignId,
    required this.campaignName,
    required this.period,
    required this.periodType,
    required this.metrics,
    required this.channelPerformance,
    required this.audienceEngagement,
    required this.geographicPerformance,
    required this.topPerformingAssets,
    required this.underperformingAssets,
    required this.totalImpressions,
    required this.totalClicks,
    required this.totalConversions,
    required this.totalRevenue,
    required this.totalCost,
    required this.roi,
    required this.cpa,
    required this.cpc,
    required this.cpm,
    required this.conversionRate,
    required this.clickThroughRate,
    required this.engagementRate,
    required this.recommendations,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MarketingAnalytics.fromJson(Map<String, dynamic> json) {
    return MarketingAnalytics(
      id: json['id'] ?? '',
      campaignId: json['campaignId'] ?? '',
      campaignName: json['campaignName'] ?? '',
      period: DateTime.parse(json['period'] ?? DateTime.now().toIso8601String()),
      periodType: json['periodType'] ?? '',
      metrics: Map<String, double>.from(json['metrics'] ?? {}),
      channelPerformance: Map<String, double>.from(json['channelPerformance'] ?? {}),
      audienceEngagement: Map<String, double>.from(json['audienceEngagement'] ?? {}),
      geographicPerformance: Map<String, double>.from(json['geographicPerformance'] ?? {}),
      topPerformingAssets: List<String>.from(json['topPerformingAssets'] ?? []),
      underperformingAssets: List<String>.from(json['underperformingAssets'] ?? []),
      totalImpressions: (json['totalImpressions'] ?? 0.0).toDouble(),
      totalClicks: (json['totalClicks'] ?? 0.0).toDouble(),
      totalConversions: (json['totalConversions'] ?? 0.0).toDouble(),
      totalRevenue: (json['totalRevenue'] ?? 0.0).toDouble(),
      totalCost: (json['totalCost'] ?? 0.0).toDouble(),
      roi: (json['roi'] ?? 0.0).toDouble(),
      cpa: (json['cpa'] ?? 0.0).toDouble(),
      cpc: (json['cpc'] ?? 0.0).toDouble(),
      cpm: (json['cpm'] ?? 0.0).toDouble(),
      conversionRate: (json['conversionRate'] ?? 0.0).toDouble(),
      clickThroughRate: (json['clickThroughRate'] ?? 0.0).toDouble(),
      engagementRate: (json['engagementRate'] ?? 0.0).toDouble(),
      recommendations: List<String>.from(json['recommendations'] ?? []),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'campaignId': campaignId,
      'campaignName': campaignName,
      'period': period.toIso8601String(),
      'periodType': periodType,
      'metrics': metrics,
      'channelPerformance': channelPerformance,
      'audienceEngagement': audienceEngagement,
      'geographicPerformance': geographicPerformance,
      'topPerformingAssets': topPerformingAssets,
      'underperformingAssets': underperformingAssets,
      'totalImpressions': totalImpressions,
      'totalClicks': totalClicks,
      'totalConversions': totalConversions,
      'totalRevenue': totalRevenue,
      'totalCost': totalCost,
      'roi': roi,
      'cpa': cpa,
      'cpc': cpc,
      'cpm': cpm,
      'conversionRate': conversionRate,
      'clickThroughRate': clickThroughRate,
      'engagementRate': engagementRate,
      'recommendations': recommendations,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Computed properties
  bool get isPerformingWell => roi > 0 && conversionRate > 2.0;
  bool get needsOptimization => roi < 0 || conversionRate < 1.0;
  bool get hasHighEngagement => engagementRate > 5.0;

  @override
  List<Object?> get props => [
        id,
        campaignId,
        campaignName,
        period,
        periodType,
        metrics,
        channelPerformance,
        audienceEngagement,
        geographicPerformance,
        topPerformingAssets,
        underperformingAssets,
        totalImpressions,
        totalClicks,
        totalConversions,
        totalRevenue,
        totalCost,
        roi,
        cpa,
        cpc,
        cpm,
        conversionRate,
        clickThroughRate,
        engagementRate,
        recommendations,
        createdAt,
        updatedAt,
      ];
}

class Promotion extends Equatable {
  final String id;
  final String name;
  final String description;
  final String type; // discount, bundle, bogo, free_shipping, loyalty_points
  final String discountType; // percentage, fixed_amount, buy_x_get_y
  final double discountValue;
  final String currency;
  final List<String> applicableProducts;
  final List<String> applicableCategories;
  final List<String> applicableCustomers;
  final List<String> excludedProducts;
  final DateTime startDate;
  final DateTime endDate;
  final int? minimumQuantity;
  final double? minimumAmount;
  final int? maximumUses;
  final int currentUses;
  final String status; // active, inactive, scheduled, expired
  final String? promoCode;
  final bool isAutoApplied;
  final bool isStackable;
  final double maxDiscountAmount;
  final List<String> conditions;
  final String createdBy;
  final String createdByName;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Promotion({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.discountType,
    required this.discountValue,
    this.currency = 'NPR',
    required this.applicableProducts,
    required this.applicableCategories,
    required this.applicableCustomers,
    required this.excludedProducts,
    required this.startDate,
    required this.endDate,
    this.minimumQuantity,
    this.minimumAmount,
    this.maximumUses,
    required this.currentUses,
    required this.status,
    this.promoCode,
    this.isAutoApplied = false,
    this.isStackable = false,
    this.maxDiscountAmount = 0.0,
    this.conditions = const [],
    required this.createdBy,
    required this.createdByName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Promotion.fromJson(Map<String, dynamic> json) {
    return Promotion(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? '',
      discountType: json['discountType'] ?? '',
      discountValue: (json['discountValue'] ?? 0.0).toDouble(),
      currency: json['currency'] ?? 'NPR',
      applicableProducts: List<String>.from(json['applicableProducts'] ?? []),
      applicableCategories: List<String>.from(json['applicableCategories'] ?? []),
      applicableCustomers: List<String>.from(json['applicableCustomers'] ?? []),
      excludedProducts: List<String>.from(json['excludedProducts'] ?? []),
      startDate: DateTime.parse(json['startDate'] ?? DateTime.now().toIso8601String()),
      endDate: DateTime.parse(json['endDate'] ?? DateTime.now().toIso8601String()),
      minimumQuantity: json['minimumQuantity'],
      minimumAmount: json['minimumAmount']?.toDouble(),
      maximumUses: json['maximumUses'],
      currentUses: json['currentUses'] ?? 0,
      status: json['status'] ?? 'inactive',
      promoCode: json['promoCode'],
      isAutoApplied: json['isAutoApplied'] ?? false,
      isStackable: json['isStackable'] ?? false,
      maxDiscountAmount: (json['maxDiscountAmount'] ?? 0.0).toDouble(),
      conditions: List<String>.from(json['conditions'] ?? []),
      createdBy: json['createdBy'] ?? '',
      createdByName: json['createdByName'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type,
      'discountType': discountType,
      'discountValue': discountValue,
      'currency': currency,
      'applicableProducts': applicableProducts,
      'applicableCategories': applicableCategories,
      'applicableCustomers': applicableCustomers,
      'excludedProducts': excludedProducts,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'minimumQuantity': minimumQuantity,
      'minimumAmount': minimumAmount,
      'maximumUses': maximumUses,
      'currentUses': currentUses,
      'status': status,
      'promoCode': promoCode,
      'isAutoApplied': isAutoApplied,
      'isStackable': isStackable,
      'maxDiscountAmount': maxDiscountAmount,
      'conditions': conditions,
      'createdBy': createdBy,
      'createdByName': createdByName,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Computed properties
  bool get isActive => status == 'active';
  bool get isInactive => status == 'inactive';
  bool get isScheduled => status == 'scheduled';
  bool get isExpired => status == 'expired';
  
  bool get isCurrentlyValid => DateTime.now().isAfter(startDate) && DateTime.now().isBefore(endDate);
  bool get isUpcoming => DateTime.now().isBefore(startDate);
  bool get isPast => DateTime.now().isAfter(endDate);
  
  bool get hasUsageLimit => maximumUses != null;
  bool get isUsageLimitReached => hasUsageLimit && currentUses >= maximumUses!;
  int get remainingUses => hasUsageLimit ? maximumUses! - currentUses : -1;
  
  double calculateDiscount(double originalAmount, int quantity) {
    if (!isCurrentlyValid || isUsageLimitReached) return 0.0;
    
    // Check minimum requirements
    if (minimumQuantity != null && quantity < minimumQuantity!) return 0.0;
    if (minimumAmount != null && originalAmount < minimumAmount!) return 0.0;
    
    double discount = 0.0;
    
    switch (discountType) {
      case 'percentage':
        discount = originalAmount * (discountValue / 100);
        break;
      case 'fixed_amount':
        discount = discountValue;
        break;
      case 'buy_x_get_y':
        // BOGO logic would be implemented here
        discount = originalAmount * (discountValue / 100);
        break;
    }
    
    // Apply maximum discount limit
    if (maxDiscountAmount > 0 && discount > maxDiscountAmount) {
      discount = maxDiscountAmount;
    }
    
    return discount;
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        type,
        discountType,
        discountValue,
        currency,
        applicableProducts,
        applicableCategories,
        applicableCustomers,
        excludedProducts,
        startDate,
        endDate,
        minimumQuantity,
        minimumAmount,
        maximumUses,
        currentUses,
        status,
        promoCode,
        isAutoApplied,
        isStackable,
        maxDiscountAmount,
        conditions,
        createdBy,
        createdByName,
        createdAt,
        updatedAt,
      ];
}
