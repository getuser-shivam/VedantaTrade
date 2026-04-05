import 'package:equatable/equatable.dart';

enum CampaignStatus {
  draft,
  active,
  paused,
  completed,
  cancelled,
}

enum CampaignType {
  discount,
  promotion,
  newProduct,
  awareness,
  loyalty,
}

enum TargetAudience {
  all,
  stockists,
  retailers,
  doctors,
  accountants,
}

class MarketingCampaignEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final CampaignType type;
  final CampaignStatus status;
  final TargetAudience targetAudience;
  final DateTime startDate;
  final DateTime endDate;
  final double? discountPercentage;
  final String? discountCode;
  final List<String> productIds;
  final List<String> categoryIds;
  final double? minimumOrderValue;
  final double? maximumDiscountAmount;
  final String? termsAndConditions;
  final String? imageUrl;
  final List<String> tags;
  final double budget;
  final String currency;
  final int? targetAudienceSize;
  final int? currentParticipants;
  final double? conversionRate;
  final double? roi;
  final Map<String, dynamic> performanceMetrics;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;
  final bool isRecurring;
  final String? recurringFrequency;
  final Map<String, dynamic> targetingCriteria;
  final List<String> communicationChannels;
  final bool isAutomated;
  final DateTime? lastSentAt;
  final int? totalSent;
  final int? totalOpened;
  final int? totalClicked;
  final int? totalConversions;

  const MarketingCampaignEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.status,
    required this.targetAudience,
    required this.startDate,
    required this.endDate,
    required this.budget,
    required this.currency,
    required this.createdAt,
    required this.updatedAt,
    this.discountPercentage,
    this.discountCode,
    this.productIds,
    this.categoryIds,
    this.minimumOrderValue,
    this.maximumDiscountAmount,
    this.termsAndConditions,
    this.imageUrl,
    this.tags,
    this.targetAudienceSize,
    this.currentParticipants,
    this.conversionRate,
    this.roi,
    this.performanceMetrics,
    this.createdBy,
    this.isRecurring,
    this.recurringFrequency,
    this.targetingCriteria,
    this.communicationChannels,
    this.isAutomated,
    this.lastSentAt,
    this.totalSent,
    this.totalOpened,
    this.totalClicked,
    this.totalConversions,
  });

  MarketingCampaignEntity copyWith({
    String? id,
    String? name,
    String? description,
    CampaignType? type,
    CampaignStatus? status,
    TargetAudience? targetAudience,
    DateTime? startDate,
    DateTime? endDate,
    double? discountPercentage,
    String? discountCode,
    List<String>? productIds,
    List<String>? categoryIds,
    double? minimumOrderValue,
    double? maximumDiscountAmount,
    String? termsAndConditions,
    String? imageUrl,
    List<String>? tags,
    double? budget,
    String? currency,
    int? targetAudienceSize,
    int? currentParticipants,
    double? conversionRate,
    double? roi,
    Map<String, dynamic>? performanceMetrics,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    bool? isRecurring,
    String? recurringFrequency,
    Map<String, dynamic>? targetingCriteria,
    List<String>? communicationChannels,
    bool? isAutomated,
    DateTime? lastSentAt,
    int? totalSent,
    int? totalOpened,
    int? totalClicked,
    int? totalConversions,
  }) {
    return MarketingCampaignEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      targetAudience: targetAudience ?? this.targetAudience,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      discountCode: discountCode ?? this.discountCode,
      productIds: productIds ?? this.productIds,
      categoryIds: categoryIds ?? this.categoryIds,
      minimumOrderValue: minimumOrderValue ?? this.minimumOrderValue,
      maximumDiscountAmount: maximumDiscountAmount ?? this.maximumDiscountAmount,
      termsAndConditions: termsAndConditions ?? this.termsAndConditions,
      imageUrl: imageUrl ?? this.imageUrl,
      tags: tags ?? this.tags,
      budget: budget ?? this.budget,
      currency: currency ?? this.currency,
      targetAudienceSize: targetAudienceSize ?? this.targetAudienceSize,
      currentParticipants: currentParticipants ?? this.currentParticipants,
      conversionRate: conversionRate ?? this.conversionRate,
      roi: roi ?? this.roi,
      performanceMetrics: performanceMetrics ?? this.performanceMetrics,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringFrequency: recurringFrequency ?? this.recurringFrequency,
      targetingCriteria: targetingCriteria ?? this.targetingCriteria,
      communicationChannels: communicationChannels ?? this.communicationChannels,
      isAutomated: isAutomated ?? this.isAutomated,
      lastSentAt: lastSentAt ?? this.lastSentAt,
      totalSent: totalSent ?? this.totalSent,
      totalOpened: totalOpened ?? this.totalOpened,
      totalClicked: totalClicked ?? this.totalClicked,
      totalConversions: totalConversions ?? this.totalConversions,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        type,
        status,
        targetAudience,
        startDate,
        endDate,
        discountPercentage,
        discountCode,
        productIds,
        categoryIds,
        minimumOrderValue,
        maximumDiscountAmount,
        termsAndConditions,
        imageUrl,
        tags,
        budget,
        currency,
        targetAudienceSize,
        currentParticipants,
        conversionRate,
        roi,
        performanceMetrics,
        createdAt,
        updatedAt,
        createdBy,
        isRecurring,
        recurringFrequency,
        targetingCriteria,
        communicationChannels,
        isAutomated,
        lastSentAt,
        totalSent,
        totalOpened,
        totalClicked,
        totalConversions,
      ];

  @override
  String toString() {
    return 'MarketingCampaignEntity(id: $id, name: $name, type: $type)';
  }

  // Computed properties
  bool get isActive => status == CampaignStatus.active;
  bool get isDraft => status == CampaignStatus.draft;
  bool get isCompleted => status == CampaignStatus.completed;
  bool get isCancelled => status == CampaignStatus.cancelled;
  bool get isPaused => status == CampaignStatus.paused;
  bool get isUpcoming => startDate.isAfter(DateTime.now());
  bool get isExpired => endDate.isBefore(DateTime.now());
  bool get isRunning => !isUpcoming && !isExpired && isActive;
  bool get hasDiscount => discountPercentage != null && discountPercentage! > 0;
  bool get hasTimeLimit => endDate != null;
  
  Duration? getDuration {
    if (startDate != null && endDate != null) {
      return endDate!.difference(startDate!);
    }
    return null;
  }
  
  String get formattedDuration {
    final duration = getDuration;
    if (duration == null) return 'N/A';
    
    final days = duration!.inDays;
    final hours = duration!.inHours.remainder(24);
    final minutes = duration!.inMinutes.remainder(60);
    
    if (days > 0) {
      return '${days}d ${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }
  
  String get formattedBudget => '$currency ${budget.toStringAsFixed(2)}';
  String get formattedDiscount => hasDiscount 
      ? '${discountPercentage!.toStringAsFixed(1)}% OFF'
      : 'No Discount';
  String get statusDisplay => status.name.split('').map((word) => 
      word[0].toUpperCase() + word.substring(1)).join(' ');
  String get typeDisplay => type.name.split('').map((word) => 
      word[0].toUpperCase() + word.substring(1)).join(' ');
  String get targetAudienceDisplay => targetAudience.name.split('').map((word) => 
      word[0].toUpperCase() + word.substring(1)).join(' ');
  
  double get budgetUtilization => budget > 0 
      ? ((budget - (performanceMetrics['spent'] ?? 0)) / budget) * 100
      : 0.0;
  
  double get engagementRate => totalSent > 0 
      ? (totalOpened! / totalSent!) * 100
      : 0.0;
  
  double get clickThroughRate => totalOpened > 0 
      ? (totalClicked! / totalOpened!) * 100
      : 0.0;
  
  double get conversionRateCalculated => totalClicked > 0 
      ? (totalConversions! / totalClicked!) * 100
      : 0.0;
  
  bool get isOverBudget => performanceMetrics['spent'] != null && 
      (performanceMetrics['spent'] as double) > budget;
  
  bool get isPerformingWell => conversionRateCalculated >= 2.0; // 2% conversion rate is good
  
  Map<String, dynamic> get performanceSummary => {
    'budget': budget,
    'spent': performanceMetrics['spent'] ?? 0,
    'remaining': budget - (performanceMetrics['spent'] ?? 0),
    'utilization': budgetUtilization,
    'targetAudience': targetAudienceSize,
    'participants': currentParticipants,
    'engagement': engagementRate,
    'clickThrough': clickThroughRate,
    'conversions': conversionRateCalculated,
    'roi': roi,
  };
}
