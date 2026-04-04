// Marketing Campaign Model
class MarketingCampaign {
  final String id;
  final String name;
  final String description;
  final CampaignType type;
  final CampaignStatus status;
  final DateTime startDate;
  final DateTime endDate;
  final double budget;
  final double spent;
  final List<String> targetAudience;
  final List<String> channels;
  final CampaignMetrics metrics;
  final String createdBy;
  final DateTime createdAt;

  const MarketingCampaign({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.budget,
    required this.spent,
    required this.targetAudience,
    required this.channels,
    required this.metrics,
    required this.createdBy,
    required this.createdAt,
  });

  factory MarketingCampaign.fromJson(Map<String, dynamic> json) {
    return MarketingCampaign(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      type: CampaignType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => CampaignType.brand,
      ),
      status: CampaignStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => CampaignStatus.planned,
      ),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      budget: (json['budget'] as num).toDouble(),
      spent: (json['spent'] as num).toDouble(),
      targetAudience: List<String>.from(json['targetAudience'] as List),
      channels: List<String>.from(json['channels'] as List),
      metrics: CampaignMetrics.fromJson(json['metrics']),
      createdBy: json['createdBy'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.toString(),
      'status': status.toString(),
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'budget': budget,
      'spent': spent,
      'targetAudience': targetAudience,
      'channels': channels,
      'metrics': metrics.toJson(),
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Computed properties
  double get remainingBudget => budget - spent;
  
  double get budgetUtilization => budget > 0 ? (spent / budget) * 100 : 0;
  
  int get daysRemaining => endDate.difference(DateTime.now()).inDays;
  
  bool get isOverBudget => spent > budget;
  
  bool get isExpired => DateTime.now().isAfter(endDate);
  
  double get conversionRate => metrics.impressions > 0 
      ? (metrics.conversions / metrics.impressions) * 100 
      : 0;
  
  double get clickThroughRate => metrics.impressions > 0 
      ? (metrics.clicks / metrics.impressions) * 100 
      : 0;
}

// Campaign Metrics Model
class CampaignMetrics {
  final int impressions;
  final int clicks;
  final int conversions;
  final double revenue;
  final double roi;

  const CampaignMetrics({
    required this.impressions,
    required this.clicks,
    required this.conversions,
    required this.revenue,
    required this.roi,
  });

  factory CampaignMetrics.fromJson(Map<String, dynamic> json) {
    return CampaignMetrics(
      impressions: (json['impressions'] as num).toInt(),
      clicks: (json['clicks'] as num).toInt(),
      conversions: (json['conversions'] as num).toInt(),
      revenue: (json['revenue'] as num).toDouble(),
      roi: (json['roi'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'impressions': impressions,
      'clicks': clicks,
      'conversions': conversions,
      'revenue': revenue,
      'roi': roi,
    };
  }

  double get conversionRate => impressions > 0 ? (conversions / impressions) * 100 : 0;
  
  double get clickThroughRate => impressions > 0 ? (clicks / impressions) * 100 : 0;
  
  double get costPerConversion => conversions > 0 ? (revenue / conversions) : 0;
  
  double get costPerClick => clicks > 0 ? (revenue / clicks) : 0;
}

// Customer Segment Model
class CustomerSegment {
  final String id;
  final String name;
  final String description;
  final int customerCount;
  final double averageOrderValue;
  final double totalRevenue;
  final double growthRate;
  final List<String> characteristics;
  final List<String> preferredProducts;
  final DateTime lastUpdated;

  const CustomerSegment {
    required this.id,
    required this.name,
    required this.description,
    required this.customerCount,
    required this.averageOrderValue,
    required this.totalRevenue,
    required this.growthRate,
    required this.characteristics,
    required this.preferredProducts,
    required this.lastUpdated,
  });

  factory CustomerSegment.fromJson(Map<String, dynamic> json) {
    return CustomerSegment(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      customerCount: (json['customerCount'] as num).toInt(),
      averageOrderValue: (json['averageOrderValue'] as num).toDouble(),
      totalRevenue: (json['totalRevenue'] as num).toDouble(),
      growthRate: (json['growthRate'] as num).toDouble(),
      characteristics: List<String>.from(json['characteristics'] as List),
      preferredProducts: List<String>.from(json['preferredProducts'] as List),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'customerCount': customerCount,
      'averageOrderValue': averageOrderValue,
      'totalRevenue': totalRevenue,
      'growthRate': growthRate,
      'characteristics': characteristics,
      'preferredProducts': preferredProducts,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  String get sizeCategory {
    if (customerCount >= 200) return 'Large';
    if (customerCount >= 100) return 'Medium';
    return 'Small';
  }

  String get performanceCategory {
    if (growthRate >= 15) return 'High Growth';
    if (growthRate >= 5) return 'Moderate Growth';
    if (growthRate >= 0) return 'Stable';
    return 'Declining';
  }
}

// Promotion Model
class Promotion {
  final String id;
  final String name;
  final String description;
  final PromotionType type;
  final PromotionStatus status;
  final double discountPercentage;
  final double minimumOrder;
  final List<String> applicableProducts;
  final DateTime startDate;
  final DateTime endDate;
  final int usageCount;
  final double totalDiscount;
  final double additionalRevenue;
  final List<String> conditions;
  final String createdBy;
  final DateTime createdAt;

  const Promotion({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.status,
    required this.discountPercentage,
    required this.minimumOrder,
    required this.applicableProducts,
    required this.startDate,
    required this.endDate,
    required this.usageCount,
    required this.totalDiscount,
    required this.additionalRevenue,
    required this.conditions,
    required this.createdBy,
    required this.createdAt,
  });

  factory Promotion.fromJson(Map<String, dynamic> json) {
    return Promotion(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      type: PromotionType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => PromotionType.discount,
      ),
      status: PromotionStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => PromotionStatus.active,
      ),
      discountPercentage: (json['discountPercentage'] as num).toDouble(),
      minimumOrder: (json['minimumOrder'] as num).toDouble(),
      applicableProducts: List<String>.from(json['applicableProducts'] as List),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      usageCount: (json['usageCount'] as num).toInt(),
      totalDiscount: (json['totalDiscount'] as num).toDouble(),
      additionalRevenue: (json['additionalRevenue'] as num).toDouble(),
      conditions: List<String>.from(json['conditions'] as List),
      createdBy: json['createdBy'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.toString(),
      'status': status.toString(),
      'discountPercentage': discountPercentage,
      'minimumOrder': minimumOrder,
      'applicableProducts': applicableProducts,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'usageCount': usageCount,
      'totalDiscount': totalDiscount,
      'additionalRevenue': additionalRevenue,
      'conditions': conditions,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Computed properties
  bool get isActive => status == PromotionStatus.active &&
      DateTime.now().isAfter(startDate) &&
      DateTime.now().isBefore(endDate);
  
  bool get isExpired => DateTime.now().isAfter(endDate);
  
  bool get isUpcoming => DateTime.now().isBefore(startDate);
  
  int get daysRemaining => endDate.difference(DateTime.now()).inDays;
  
  double get roi => totalDiscount > 0 ? (additionalRevenue / totalDiscount) : 0;
  
  double get averageDiscountPerUsage => usageCount > 0 ? totalDiscount / usageCount : 0;
}

// Marketing Analytics Model
class MarketingAnalytics {
  final DateTime period;
  final int totalCampaigns;
  final int activeCampaigns;
  final double totalBudget;
  final double totalSpent;
  final int totalImpressions;
  final int totalClicks;
  final int totalConversions;
  final double totalRevenue;
  final double averageROI;
  final List<String> topPerformingChannels;
  final double customerAcquisitionCost;
  final double customerLifetimeValue;
  final double engagementRate;
  final double conversionRate;

  const MarketingAnalytics({
    required this.period,
    required this.totalCampaigns,
    required this.activeCampaigns,
    required this.totalBudget,
    required this.totalSpent,
    required this.totalImpressions,
    required this.totalClicks,
    required this.totalConversions,
    required this.totalRevenue,
    required this.averageROI,
    required this.topPerformingChannels,
    required this.customerAcquisitionCost,
    required this.customerLifetimeValue,
    required this.engagementRate,
    required this.conversionRate,
  });

  factory MarketingAnalytics.fromJson(Map<String, dynamic> json) {
    return MarketingAnalytics(
      period: DateTime.parse(json['period'] as String),
      totalCampaigns: (json['totalCampaigns'] as num).toInt(),
      activeCampaigns: (json['activeCampaigns'] as num).toInt(),
      totalBudget: (json['totalBudget'] as num).toDouble(),
      totalSpent: (json['totalSpent'] as num).toDouble(),
      totalImpressions: (json['totalImpressions'] as num).toInt(),
      totalClicks: (json['totalClicks'] as num).toInt(),
      totalConversions: (json['totalConversions'] as num).toInt(),
      totalRevenue: (json['totalRevenue'] as num).toDouble(),
      averageROI: (json['averageROI'] as num).toDouble(),
      topPerformingChannels: List<String>.from(json['topPerformingChannels'] as List),
      customerAcquisitionCost: (json['customerAcquisitionCost'] as num).toDouble(),
      customerLifetimeValue: (json['customerLifetimeValue'] as num).toDouble(),
      engagementRate: (json['engagementRate'] as num).toDouble(),
      conversionRate: (json['conversionRate'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'period': period.toIso8601String(),
      'totalCampaigns': totalCampaigns,
      'activeCampaigns': activeCampaigns,
      'totalBudget': totalBudget,
      'totalSpent': totalSpent,
      'totalImpressions': totalImpressions,
      'totalClicks': totalClicks,
      'totalConversions': totalConversions,
      'totalRevenue': totalRevenue,
      'averageROI': averageROI,
      'topPerformingChannels': topPerformingChannels,
      'customerAcquisitionCost': customerAcquisitionCost,
      'customerLifetimeValue': customerLifetimeValue,
      'engagementRate': engagementRate,
      'conversionRate': conversionRate,
    };
  }

  // Computed properties
  double get budgetUtilization => totalBudget > 0 ? (totalSpent / totalBudget) * 100 : 0;
  
  double get remainingBudget => totalBudget - totalSpent;
  
  double get clickThroughRate => totalImpressions > 0 ? (totalClicks / totalImpressions) * 100 : 0;
  
  double get overallConversionRate => totalClicks > 0 ? (totalConversions / totalClicks) * 100 : 0;
  
  double get returnOnAdSpend => totalSpent > 0 ? (totalRevenue / totalSpent) : 0;
  
  double get customerValueRatio => customerAcquisitionCost > 0 
      ? (customerLifetimeValue / customerAcquisitionCost) 
      : 0;
}

// Lead Model
class Lead {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String company;
  final String position;
  final LeadSource source;
  final LeadStatus status;
  final double potentialValue;
  final DateTime createdAt;
  final DateTime? lastContactDate;
  final List<String> interests;
  final Map<String, dynamic> customFields;
  final String? assignedTo;

  const Lead({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.company,
    required this.position,
    required this.source,
    required this.status,
    required this.potentialValue,
    required this.createdAt,
    this.lastContactDate,
    required this.interests,
    required this.customFields,
    this.assignedTo,
  });

  factory Lead.fromJson(Map<String, dynamic> json) {
    return Lead(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      company: json['company'] as String,
      position: json['position'] as String,
      source: LeadSource.values.firstWhere(
        (e) => e.toString() == json['source'],
        orElse: () => LeadSource.website,
      ),
      status: LeadStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => LeadStatus.new_,
      ),
      potentialValue: (json['potentialValue'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastContactDate: json['lastContactDate'] != null
          ? DateTime.parse(json['lastContactDate'] as String)
          : null,
      interests: List<String>.from(json['interests'] as List),
      customFields: Map<String, dynamic>.from(json['customFields']),
      assignedTo: json['assignedTo'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'company': company,
      'position': position,
      'source': source.toString(),
      'status': status.toString(),
      'potentialValue': potentialValue,
      'createdAt': createdAt.toIso8601String(),
      'lastContactDate': lastContactDate?.toIso8601String(),
      'interests': interests,
      'customFields': customFields,
      'assignedTo': assignedTo,
    };
  }

  int get daysSinceCreation => DateTime.now().difference(createdAt).inDays;
  
  int get daysSinceLastContact => lastContactDate != null
      ? DateTime.now().difference(lastContactDate!).inDays
      : daysSinceCreation;
  
  bool get isHotLead => potentialValue >= 100000 && status == LeadStatus.qualified;
  
  bool get isStale => daysSinceLastContact > 30 && status != LeadStatus.converted;
}

// Email Campaign Model
class EmailCampaign {
  final String id;
  final String name;
  final String subject;
  final String content;
  final EmailCampaignType type;
  final EmailStatus status;
  final List<String> recipientSegments;
  final int totalRecipients;
  final int sentCount;
  final int deliveredCount;
  final int openedCount;
  final int clickedCount;
  final int unsubscribedCount;
  final DateTime scheduledDate;
  final DateTime? sentDate;
  final String createdBy;

  const EmailCampaign({
    required this.id,
    required this.name,
    required this.subject,
    required this.content,
    required this.type,
    required this.status,
    required this.recipientSegments,
    required this.totalRecipients,
    required this.sentCount,
    required this.deliveredCount,
    required this.openedCount,
    required this.clickedCount,
    required this.unsubscribedCount,
    required this.scheduledDate,
    this.sentDate,
    required this.createdBy,
  });

  factory EmailCampaign.fromJson(Map<String, dynamic> json) {
    return EmailCampaign(
      id: json['id'] as String,
      name: json['name'] as String,
      subject: json['subject'] as String,
      content: json['content'] as String,
      type: EmailCampaignType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => EmailCampaignType.promotional,
      ),
      status: EmailStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => EmailStatus.draft,
      ),
      recipientSegments: List<String>.from(json['recipientSegments'] as List),
      totalRecipients: (json['totalRecipients'] as num).toInt(),
      sentCount: (json['sentCount'] as num).toInt(),
      deliveredCount: (json['deliveredCount'] as num).toInt(),
      openedCount: (json['openedCount'] as num).toInt(),
      clickedCount: (json['clickedCount'] as num).toInt(),
      unsubscribedCount: (json['unsubscribedCount'] as num).toInt(),
      scheduledDate: DateTime.parse(json['scheduledDate'] as String),
      sentDate: json['sentDate'] != null
          ? DateTime.parse(json['sentDate'] as String)
          : null,
      createdBy: json['createdBy'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'subject': subject,
      'content': content,
      'type': type.toString(),
      'status': status.toString(),
      'recipientSegments': recipientSegments,
      'totalRecipients': totalRecipients,
      'sentCount': sentCount,
      'deliveredCount': deliveredCount,
      'openedCount': openedCount,
      'clickedCount': clickedCount,
      'unsubscribedCount': unsubscribedCount,
      'scheduledDate': scheduledDate.toIso8601String(),
      'sentDate': sentDate?.toIso8601String(),
      'createdBy': createdBy,
    };
  }

  double get deliveryRate => sentCount > 0 ? (deliveredCount / sentCount) * 100 : 0;
  
  double get openRate => deliveredCount > 0 ? (openedCount / deliveredCount) * 100 : 0;
  
  double get clickRate => openedCount > 0 ? (clickedCount / openedCount) * 100 : 0;
  
  double get unsubscribeRate => deliveredCount > 0 ? (unsubscribedCount / deliveredCount) * 100 : 0;
}

// Enums
enum CampaignType {
  brand,
  product,
  seasonal,
  promotional,
  awareness,
  b2b,
  retention,
  acquisition,
}

enum CampaignStatus {
  planned,
  active,
  paused,
  completed,
  cancelled,
}

enum PromotionType {
  discount,
  bundle,
  freeShipping,
  buyOneGetOne,
  newCustomer,
  loyalty,
  seasonal,
  clearance,
}

enum PromotionStatus {
  active,
  inactive,
  scheduled,
  expired,
  paused,
}

enum LeadSource {
  website,
  email,
  social,
  referral,
  phone,
  event,
  advertisement,
  partner,
}

enum LeadStatus {
  new_,
  contacted,
  qualified,
  proposal,
  negotiation,
  converted,
  lost,
  recycled,
}

enum EmailCampaignType {
  promotional,
  newsletter,
  announcement,
  survey,
  invitation,
  followup,
  reengagement,
}

enum EmailStatus {
  draft,
  scheduled,
  sending,
  sent,
  paused,
  cancelled,
}
