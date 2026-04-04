import 'package:flutter/foundation.dart';
import '../../domain/models/marketing_campaign.dart';
import '../../domain/models/marketing_analytics.dart';
import '../../data/services/marketing_analytics_service.dart';

class MarketingAnalyticsProvider extends ChangeNotifier {
  final MarketingAnalyticsService _marketingService;

  MarketingAnalyticsProvider({
    required MarketingAnalyticsService marketingService,
  }) : _marketingService = marketingService;

  // Campaigns
  List<MarketingCampaign> _campaigns = [];
  bool _isLoadingCampaigns = false;
  String? _campaignsError;

  // Campaign Analytics
  Map<String, MarketingAnalytics> _campaignAnalytics = {};
  bool _isLoadingAnalytics = false;
  String? _analyticsError;

  // Overall Analytics
  Map<String, dynamic> _overallAnalytics = {};
  bool _isLoadingOverallAnalytics = false;
  String? _overallAnalyticsError;

  // Customer Segments
  List<CustomerSegment> _customerSegments = [];
  bool _isLoadingSegments = false;
  String? _segmentsError;

  // Marketing Channels
  List<MarketingChannel> _marketingChannels = [];
  bool _isLoadingChannels = false;
  String? _channelsError;

  // Attribution Models
  List<AttributionModel> _attributionModels = [];
  bool _isLoadingAttribution = false;
  String? _attributionError;

  // Campaign Comparison
  Map<String, dynamic> _campaignComparison = {};
  bool _isLoadingComparison = false;
  String? _comparisonError;

  // Marketing Insights
  Map<String, dynamic> _insights = {};
  bool _isLoadingInsights = false;
  String? _insightsError;

  // Getters
  List<MarketingCampaign> get campaigns => _campaigns;
  bool get isLoadingCampaigns => _isLoadingCampaigns;
  String? get campaignsError => _campaignsError;

  Map<String, MarketingAnalytics> get campaignAnalytics => _campaignAnalytics;
  bool get isLoadingAnalytics => _isLoadingAnalytics;
  String? get analyticsError => _analyticsError;

  Map<String, dynamic> get overallAnalytics => _overallAnalytics;
  bool get isLoadingOverallAnalytics => _isLoadingOverallAnalytics;
  String? get overallAnalyticsError => _overallAnalyticsError;

  List<CustomerSegment> get customerSegments => _customerSegments;
  bool get isLoadingSegments => _isLoadingSegments;
  String? get segmentsError => _segmentsError;

  List<MarketingChannel> get marketingChannels => _marketingChannels;
  bool get isLoadingChannels => _isLoadingChannels;
  String? get channelsError => _channelsError;

  List<AttributionModel> get attributionModels => _attributionModels;
  bool get isLoadingAttribution => _isLoadingAttribution;
  String? get attributionError => _attributionError;

  Map<String, dynamic> get campaignComparison => _campaignComparison;
  bool get isLoadingComparison => _isLoadingComparison;
  String? get comparisonError => _comparisonError;

  Map<String, dynamic> get insights => _insights;
  bool get isLoadingInsights => _isLoadingInsights;
  String? get insightsError => _insightsError;

  // Load campaigns
  Future<void> loadCampaigns() async {
    _isLoadingCampaigns = true;
    _campaignsError = null;
    notifyListeners();

    try {
      // This would typically call a campaign service
      // For now, we'll simulate loading
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock data for demonstration
      _campaigns = [
        MarketingCampaign(
          id: '1',
          name: 'Summer Sale 2024',
          description: 'Annual summer promotional campaign',
          type: 'promotion',
          startDate: DateTime.now().subtract(const Duration(days: 30)),
          endDate: DateTime.now().add(const Duration(days: 30)),
          budget: 50000.0,
          spent: 35000.0,
          status: 'active',
          targetAudience: 'General consumers',
          targetProducts: ['product1', 'product2'],
          targetRegions: ['Kathmandu', 'Pokhara'],
          metrics: {'impressions': 100000, 'clicks': 5000, 'conversions': 250},
          createdBy: 'admin',
          createdAt: DateTime.now().subtract(const Duration(days: 35)),
          updatedAt: DateTime.now(),
        ),
      ];
    } catch (e) {
      _campaignsError = 'Error loading campaigns: ${e.toString()}';
    } finally {
      _isLoadingCampaigns = false;
      notifyListeners();
    }
  }

  // Load campaign analytics
  Future<void> loadCampaignAnalytics(String campaignId) async {
    _isLoadingAnalytics = true;
    _analyticsError = null;
    notifyListeners();

    try {
      final result = await _marketingService.getCampaignAnalytics(campaignId);
      
      if (result['success'] == true) {
        _campaignAnalytics[campaignId] = result['analytics'] as MarketingAnalytics;
      } else {
        _analyticsError = result['message'] ?? 'Failed to load campaign analytics';
      }
    } catch (e) {
      _analyticsError = 'Error loading campaign analytics: ${e.toString()}';
    } finally {
      _isLoadingAnalytics = false;
      notifyListeners();
    }
  }

  // Load overall analytics
  Future<void> loadOverallAnalytics({
    String? period,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? campaignIds,
  }) async {
    _isLoadingOverallAnalytics = true;
    _overallAnalyticsError = null;
    notifyListeners();

    try {
      final result = await _marketingService.getMarketingAnalytics(
        period: period,
        startDate: startDate,
        endDate: endDate,
        campaignIds: campaignIds,
      );
      
      if (result['success'] == true) {
        _overallAnalytics = result['data'] as Map<String, dynamic>;
      } else {
        _overallAnalyticsError = result['message'] ?? 'Failed to load overall analytics';
      }
    } catch (e) {
      _overallAnalyticsError = 'Error loading overall analytics: ${e.toString()}';
    } finally {
      _isLoadingOverallAnalytics = false;
      notifyListeners();
    }
  }

  // Load customer segments
  Future<void> loadCustomerSegments() async {
    _isLoadingSegments = true;
    _segmentsError = null;
    notifyListeners();

    try {
      final result = await _marketingService.getCustomerSegments();
      
      if (result['success'] == true) {
        _customerSegments = result['segments'] as List<CustomerSegment>;
      } else {
        _segmentsError = result['message'] ?? 'Failed to load customer segments';
      }
    } catch (e) {
      _segmentsError = 'Error loading customer segments: ${e.toString()}';
    } finally {
      _isLoadingSegments = false;
      notifyListeners();
    }
  }

  // Load marketing channels
  Future<void> loadMarketingChannels() async {
    _isLoadingChannels = true;
    _channelsError = null;
    notifyListeners();

    try {
      final result = await _marketingService.getMarketingChannelsPerformance();
      
      if (result['success'] == true) {
        _marketingChannels = result['channels'] as List<MarketingChannel>;
      } else {
        _channelsError = result['message'] ?? 'Failed to load marketing channels';
      }
    } catch (e) {
      _channelsError = 'Error loading marketing channels: ${e.toString()}';
    } finally {
      _isLoadingChannels = false;
      notifyListeners();
    }
  }

  // Load attribution models
  Future<void> loadAttributionModels() async {
    _isLoadingAttribution = true;
    _attributionError = null;
    notifyListeners();

    try {
      final result = await _marketingService.getAttributionModels();
      
      if (result['success'] == true) {
        _attributionModels = result['models'] as List<AttributionModel>;
      } else {
        _attributionError = result['message'] ?? 'Failed to load attribution models';
      }
    } catch (e) {
      _attributionError = 'Error loading attribution models: ${e.toString()}';
    } finally {
      _isLoadingAttribution = false;
      notifyListeners();
    }
  }

  // Load campaign comparison
  Future<void> loadCampaignComparison(List<String> campaignIds) async {
    _isLoadingComparison = true;
    _comparisonError = null;
    notifyListeners();

    try {
      final result = await _marketingService.getCampaignComparison(campaignIds);
      
      if (result['success'] == true) {
        _campaignComparison = result['comparison'] as Map<String, dynamic>;
      } else {
        _comparisonError = result['message'] ?? 'Failed to load campaign comparison';
      }
    } catch (e) {
      _comparisonError = 'Error loading campaign comparison: ${e.toString()}';
    } finally {
      _isLoadingComparison = false;
      notifyListeners();
    }
  }

  // Load marketing insights
  Future<void> loadMarketingInsights({
    String? period,
    List<String>? campaignIds,
  }) async {
    _isLoadingInsights = true;
    _insightsError = null;
    notifyListeners();

    try {
      final result = await _marketingService.generateMarketingInsights(
        period: period,
        campaignIds: campaignIds,
      );
      
      if (result['success'] == true) {
        _insights = result['insights'] as Map<String, dynamic>;
      } else {
        _insightsError = result['message'] ?? 'Failed to load marketing insights';
      }
    } catch (e) {
      _insightsError = 'Error loading marketing insights: ${e.toString()}';
    } finally {
      _isLoadingInsights = false;
      notifyListeners();
    }
  }

  // Create customer segment
  Future<bool> createCustomerSegment({
    required String name,
    required String description,
    required List<String> criteria,
  }) async {
    try {
      final result = await _marketingService.createCustomerSegment(
        name: name,
        description: description,
        criteria: criteria,
      );
      
      if (result['success'] == true) {
        final segment = result['segment'] as CustomerSegment;
        _customerSegments.add(segment);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      
      return false;
    }
  }

  // Create attribution model
  Future<bool> createAttributionModel({
    required String name,
    required String type,
    required Map<String, double> channelWeights,
  }) async {
    try {
      final result = await _marketingService.createAttributionModel(
        name: name,
        type: type,
        channelWeights: channelWeights,
      );
      
      if (result['success'] == true) {
        final model = result['model'] as AttributionModel;
        _attributionModels.add(model);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      
      return false;
    }
  }

  // Track conversion
  Future<bool> trackConversion({
    required String campaignId,
    required String customerId,
    required String eventType,
    required double value,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final result = await _marketingService.trackConversion(
        campaignId: campaignId,
        customerId: customerId,
        eventType: eventType,
        value: value,
        metadata: metadata,
      );
      
      return result['success'] == true;
    } catch (e) {
      
      return false;
    }
  }

  // Calculate ROI
  Future<Map<String, dynamic>?> calculateROI({
    required String campaignId,
    required double revenue,
    required double costs,
  }) async {
    try {
      final result = await _marketingService.calculateROI(
        campaignId: campaignId,
        revenue: revenue,
        costs: costs,
      );
      
      if (result['success'] == true) {
        return {
          'roi': result['roi'],
          'roi_percentage': result['roi_percentage'],
          'break_even_point': result['break_even_point'],
        };
      }
      return null;
    } catch (e) {
      
      return null;
    }
  }

  // Get campaign by ID
  MarketingCampaign? getCampaignById(String id) {
    try {
      return _campaigns.firstWhere((campaign) => campaign.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get analytics for campaign
  MarketingAnalytics? getAnalyticsForCampaign(String campaignId) {
    return _campaignAnalytics[campaignId];
  }

  // Get total budget
  double getTotalBudget() {
    return _campaigns.fold(0.0, (sum, campaign) => sum + campaign.budget);
  }

  // Get total spent
  double getTotalSpent() {
    return _campaigns.fold(0.0, (sum, campaign) => sum + campaign.spent);
  }

  // Get active campaigns
  List<MarketingCampaign> getActiveCampaigns() {
    return _campaigns.where((campaign) => campaign.status == 'active').toList();
  }

  // Get campaigns by status
  List<MarketingCampaign> getCampaignsByStatus(String status) {
    return _campaigns.where((campaign) => campaign.status == status).toList();
  }

  // Clear errors
  void clearErrors() {
    _campaignsError = null;
    _analyticsError = null;
    _overallAnalyticsError = null;
    _segmentsError = null;
    _channelsError = null;
    _attributionError = null;
    _comparisonError = null;
    _insightsError = null;
    notifyListeners();
  }

  // Refresh all data
  Future<void> refreshAllData() async {
    await Future.wait([
      loadCampaigns(),
      loadCustomerSegments(),
      loadMarketingChannels(),
      loadAttributionModels(),
    ]);
  }
}
