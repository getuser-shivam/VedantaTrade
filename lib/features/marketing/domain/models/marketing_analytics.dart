import 'dart:convert';

class MarketingAnalytics {
  final String campaignId;
  final String campaignName;
  final String period;
  final DateTime startDate;
  final DateTime endDate;
  final double budget;
  final double spent;
  final double roi;
  final int impressions;
  final int clicks;
  final int conversions;
  final double ctr; // Click-through rate
  final double cpc; // Cost per click
  final double cpa; // Cost per acquisition
  final double conversionRate;
  final Map<String, int> engagementByRegion;
  final Map<String, int> engagementByDemographic;
  final List<String> topPerformingProducts;
  final Map<String, dynamic> attributionData;
  final double brandLift;
  final int socialShares;
  final int emailOpens;
  final int emailClicks;
  final Map<String, dynamic> customMetrics;
  final DateTime calculatedAt;

  MarketingAnalytics({
    required this.campaignId,
    required this.campaignName,
    required this.period,
    required this.startDate,
    required this.endDate,
    required this.budget,
    required this.spent,
    required this.roi,
    required this.impressions,
    required this.clicks,
    required this.conversions,
    required this.ctr,
    required this.cpc,
    required this.cpa,
    required this.conversionRate,
    required this.engagementByRegion,
    required this.engagementByDemographic,
    required this.topPerformingProducts,
    required this.attributionData,
    required this.brandLift,
    required this.socialShares,
    required this.emailOpens,
    required this.emailClicks,
    required this.customMetrics,
    required this.calculatedAt,
  });

  factory MarketingAnalytics.fromJson(Map<String, dynamic> json) {
    return MarketingAnalytics(
      campaignId: json['campaign_id'] as String,
      campaignName: json['campaign_name'] as String,
      period: json['period'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      budget: (json['budget'] as num).toDouble(),
      spent: (json['spent'] as num).toDouble(),
      roi: (json['roi'] as num).toDouble(),
      impressions: json['impressions'] as int,
      clicks: json['clicks'] as int,
      conversions: json['conversions'] as int,
      ctr: (json['ctr'] as num).toDouble(),
      cpc: (json['cpc'] as num).toDouble(),
      cpa: (json['cpa'] as num).toDouble(),
      conversionRate: (json['conversion_rate'] as num).toDouble(),
      engagementByRegion: Map<String, int>.from(json['engagement_by_region'] as Map),
      engagementByDemographic: Map<String, int>.from(json['engagement_by_demographic'] as Map),
      topPerformingProducts: List<String>.from(json['top_performing_products'] as List),
      attributionData: Map<String, dynamic>.from(json['attribution_data'] as Map),
      brandLift: (json['brand_lift'] as num).toDouble(),
      socialShares: json['social_shares'] as int,
      emailOpens: json['email_opens'] as int,
      emailClicks: json['email_clicks'] as int,
      customMetrics: Map<String, dynamic>.from(json['custom_metrics'] as Map),
      calculatedAt: DateTime.parse(json['calculated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'campaign_id': campaignId,
      'campaign_name': campaignName,
      'period': period,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'budget': budget,
      'spent': spent,
      'roi': roi,
      'impressions': impressions,
      'clicks': clicks,
      'conversions': conversions,
      'ctr': ctr,
      'cpc': cpc,
      'cpa': cpa,
      'conversion_rate': conversionRate,
      'engagement_by_region': engagementByRegion,
      'engagement_by_demographic': engagementByDemographic,
      'top_performing_products': topPerformingProducts,
      'attribution_data': attributionData,
      'brand_lift': brandLift,
      'social_shares': socialShares,
      'email_opens': emailOpens,
      'email_clicks': emailClicks,
      'custom_metrics': customMetrics,
      'calculated_at': calculatedAt.toIso8601String(),
    };
  }
}

class CustomerSegment {
  final String id;
  final String name;
  final String description;
  final List<String> criteria;
  final int customerCount;
  final double averageOrderValue;
  final double totalRevenue;
  final double retentionRate;
  final double churnRate;
  final List<String> topProducts;
  final Map<String, double> demographics;
  final DateTime createdAt;
  final DateTime updatedAt;

  CustomerSegment({
    required this.id,
    required this.name,
    required this.description,
    required this.criteria,
    required this.customerCount,
    required this.averageOrderValue,
    required this.totalRevenue,
    required this.retentionRate,
    required this.churnRate,
    required this.topProducts,
    required this.demographics,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CustomerSegment.fromJson(Map<String, dynamic> json) {
    return CustomerSegment(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      criteria: List<String>.from(json['criteria'] as List),
      customerCount: json['customer_count'] as int,
      averageOrderValue: (json['average_order_value'] as num).toDouble(),
      totalRevenue: (json['total_revenue'] as num).toDouble(),
      retentionRate: (json['retention_rate'] as num).toDouble(),
      churnRate: (json['churn_rate'] as num).toDouble(),
      topProducts: List<String>.from(json['top_products'] as List),
      demographics: Map<String, double>.from(json['demographics'] as Map),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'criteria': criteria,
      'customer_count': customerCount,
      'average_order_value': averageOrderValue,
      'total_revenue': totalRevenue,
      'retention_rate': retentionRate,
      'churn_rate': churnRate,
      'top_products': topProducts,
      'demographics': demographics,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class MarketingChannel {
  final String id;
  final String name;
  final String type;
  final double budget;
  final double spent;
  final double revenue;
  final double roi;
  final int leads;
  final int conversions;
  final double conversionRate;
  final double cpl; // Cost per lead
  final Map<String, dynamic> performanceMetrics;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  MarketingChannel({
    required this.id,
    required this.name,
    required this.type,
    required this.budget,
    required this.spent,
    required this.revenue,
    required this.roi,
    required this.leads,
    required this.conversions,
    required this.conversionRate,
    required this.cpl,
    required this.performanceMetrics,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MarketingChannel.fromJson(Map<String, dynamic> json) {
    return MarketingChannel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      budget: (json['budget'] as num).toDouble(),
      spent: (json['spent'] as num).toDouble(),
      revenue: (json['revenue'] as num).toDouble(),
      roi: (json['roi'] as num).toDouble(),
      leads: json['leads'] as int,
      conversions: json['conversions'] as int,
      conversionRate: (json['conversion_rate'] as num).toDouble(),
      cpl: (json['cpl'] as num).toDouble(),
      performanceMetrics: Map<String, dynamic>.from(json['performance_metrics'] as Map),
      isActive: json['is_active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'budget': budget,
      'spent': spent,
      'revenue': revenue,
      'roi': roi,
      'leads': leads,
      'conversions': conversions,
      'conversion_rate': conversionRate,
      'cpl': cpl,
      'performance_metrics': performanceMetrics,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class AttributionModel {
  final String id;
  final String name;
  final String type; // first_touch, last_touch, linear, time_decay, position_based
  final Map<String, double> channelWeights;
  final double accuracy;
  final Map<String, dynamic> modelParameters;
  final DateTime trainedAt;
  final DateTime lastUpdated;
  final bool isActive;

  AttributionModel({
    required this.id,
    required this.name,
    required this.type,
    required this.channelWeights,
    required this.accuracy,
    required this.modelParameters,
    required this.trainedAt,
    required this.lastUpdated,
    required this.isActive,
  });

  factory AttributionModel.fromJson(Map<String, dynamic> json) {
    return AttributionModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      channelWeights: Map<String, double>.from(json['channel_weights'] as Map),
      accuracy: (json['accuracy'] as num).toDouble(),
      modelParameters: Map<String, dynamic>.from(json['model_parameters'] as Map),
      trainedAt: DateTime.parse(json['trained_at'] as String),
      lastUpdated: DateTime.parse(json['last_updated'] as String),
      isActive: json['is_active'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'channel_weights': channelWeights,
      'accuracy': accuracy,
      'model_parameters': modelParameters,
      'trained_at': trainedAt.toIso8601String(),
      'last_updated': lastUpdated.toIso8601String(),
      'is_active': isActive,
    };
  }
}
