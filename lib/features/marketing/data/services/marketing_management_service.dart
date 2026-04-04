import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:async';
import '../../../shared/widgets/premium_glassmorphic_theme.dart';
import '../models/marketing_models.dart';

class MarketingManagementService {
  static final MarketingManagementService _instance = MarketingManagementService._internal();
  factory MarketingManagementService() => _instance;
  MarketingManagementService._internal();

  late final Dio _dio;
  final StreamController<List<MarketingCampaign>> _campaignsController = 
      StreamController<List<MarketingCampaign>>.broadcast();
  final StreamController<List<CustomerSegment>> _segmentsController = 
      StreamController<List<CustomerSegment>>.broadcast();
  final StreamController<MarketingAnalytics> _analyticsController = 
      StreamController<MarketingAnalytics>.broadcast();
  final StreamController<List<Promotion>> _promotionsController = 
      StreamController<List<Promotion>>.broadcast();

  List<MarketingCampaign> _campaigns = [];
  List<CustomerSegment> _segments = [];
  MarketingAnalytics _analytics = MarketingAnalytics();
  List<Promotion> _promotions = [];
  
  Timer? _analyticsTimer;
  String? _currentUserId;

  // Stream getters
  Stream<List<MarketingCampaign>> get campaignsStream => _campaignsController.stream;
  Stream<List<CustomerSegment>> get segmentsStream => _segmentsController.stream;
  Stream<MarketingAnalytics> get analyticsStream => _analyticsController.stream;
  Stream<List<Promotion>> get promotionsStream => _promotionsController.stream;

  // Data getters
  List<MarketingCampaign> get campaigns => List.unmodifiable(_campaigns);
  List<CustomerSegment> get segments => List.unmodifiable(_segments);
  MarketingAnalytics get analytics => _analytics;
  List<Promotion> get promotions => List.unmodifiable(_promotions);

  void initialize({String? userId}) {
    try {
      debugPrint('🚀 Initializing Marketing Management Service...');
      
      _currentUserId = userId;
      _setupDioClient();
      _loadInitialData();
      _startAnalyticsUpdates();
      
      debugPrint('✅ Marketing Management Service initialized');
    } catch (e) {
      debugPrint('❌ Failed to initialize Marketing Management Service: $e');
      _campaignsController.addError(e);
    }
  }

  void _setupDioClient() {
    _dio = Dio(BaseOptions(
      baseUrl: 'https://api.vedantatrade.com.np',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'X-Country': 'NP',
        'X-Currency': 'NPR',
        'X-Timezone': 'Asia/Kathmandu',
      },
    ));

    // Add request interceptor for authentication
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add auth token if available
          // final token = await _getAuthToken();
          // if (token != null) {
          //   options.headers['Authorization'] = 'Bearer $token';
          // }
          handler.next(options);
        },
        onError: (error, handler) {
          debugPrint('Marketing API Error: ${error.message}');
          handler.next(error);
        },
      ),
    );
  }

  Future<void> _loadInitialData() async {
    try {
      debugPrint('📂 Loading initial marketing data...');
      
      // Load campaigns
      await _loadCampaigns();
      
      // Load customer segments
      await _loadCustomerSegments();
      
      // Load promotions
      await _loadPromotions();
      
      // Load analytics
      await _loadAnalytics();
      
      debugPrint('✅ Initial data loaded successfully');
    } catch (e) {
      debugPrint('Failed to load initial data: $e');
      // Load mock data as fallback
      await _loadMockData();
    }
  }

  Future<void> _loadCampaigns() async {
    try {
      final response = await _dio.get('/api/marketing/campaigns');
      if (response.statusCode == 200) {
        _campaigns = (response.data['campaigns'] as List)
            .map((json) => MarketingCampaign.fromJson(json))
            .toList();
        _campaignsController.add(_campaigns);
      }
    } catch (e) {
      debugPrint('Failed to load campaigns: $e');
      rethrow;
    }
  }

  Future<void> _loadCustomerSegments() async {
    try {
      final response = await _dio.get('/api/marketing/segments');
      if (response.statusCode == 200) {
        _segments = (response.data['segments'] as List)
            .map((json) => CustomerSegment.fromJson(json))
            .toList();
        _segmentsController.add(_segments);
      }
    } catch (e) {
      debugPrint('Failed to load customer segments: $e');
      rethrow;
    }
  }

  Future<void> _loadPromotions() async {
    try {
      final response = await _dio.get('/api/marketing/promotions');
      if (response.statusCode == 200) {
        _promotions = (response.data['promotions'] as List)
            .map((json) => Promotion.fromJson(json))
            .toList();
        _promotionsController.add(_promotions);
      }
    } catch (e) {
      debugPrint('Failed to load promotions: $e');
      rethrow;
    }
  }

  Future<void> _loadAnalytics() async {
    try {
      final response = await _dio.get('/api/marketing/analytics');
      if (response.statusCode == 200) {
        _analytics = MarketingAnalytics.fromJson(response.data['analytics']);
        _analyticsController.add(_analytics);
      }
    } catch (e) {
      debugPrint('Failed to load analytics: $e');
      rethrow;
    }
  }

  void _startAnalyticsUpdates() {
    debugPrint('🔄 Starting analytics updates...');
    
    _analyticsTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      _refreshAnalytics();
    });
    
    debugPrint('✅ Analytics updates started');
  }

  Future<void> _refreshAnalytics() async {
    try {
      await _loadAnalytics();
    } catch (e) {
      debugPrint('Failed to refresh analytics: $e');
    }
  }

  Future<void> _loadMockData() async {
    debugPrint('📋 Loading mock marketing data...');
    
    // Mock campaigns
    _campaigns = [
      MarketingCampaign(
        id: '1',
        name: 'Summer Health Campaign',
        description: 'Promote essential medicines for summer season',
        type: CampaignType.seasonal,
        status: CampaignStatus.active,
        startDate: DateTime.now().subtract(const Duration(days: 15)),
        endDate: DateTime.now().add(const Duration(days: 45)),
        budget: 50000.0,
        spent: 25000.0,
        targetAudience: ['General Public', 'Elderly', 'Children'],
        channels: ['Social Media', 'Email', 'SMS'],
        metrics: CampaignMetrics(
          impressions: 150000,
          clicks: 7500,
          conversions: 450,
          revenue: 125000.0,
          roi: 4.0,
        ),
        createdBy: 'Marketing Team',
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
      ),
      MarketingCampaign(
        id: '2',
        name: 'Doctor Outreach Program',
        description: 'Connect with medical practitioners for prescription awareness',
        type: CampaignType.b2b,
        status: CampaignStatus.active,
        startDate: DateTime.now().subtract(const Duration(days: 30)),
        endDate: DateTime.now().add(const Duration(days: 60)),
        budget: 75000.0,
        spent: 45000.0,
        targetAudience: ['Doctors', 'Clinics', 'Hospitals'],
        channels: ['Direct Mail', 'Email', 'Phone'],
        metrics: CampaignMetrics(
          impressions: 25000,
          clicks: 2000,
          conversions: 180,
          revenue: 350000.0,
          roi: 6.8,
        ),
        createdBy: 'Marketing Team',
        createdAt: DateTime.now().subtract(const Duration(days: 35)),
      ),
      MarketingCampaign(
        id: '3',
        name: 'Monsoon Special Offers',
        description: 'Special discounts during monsoon season',
        type: CampaignType.promotional,
        status: CampaignStatus.planned,
        startDate: DateTime.now().add(const Duration(days: 10)),
        endDate: DateTime.now().add(const Duration(days: 70)),
        budget: 30000.0,
        spent: 0.0,
        targetAudience: ['Retailers', 'General Public'],
        channels: ['Social Media', 'In-Store', 'SMS'],
        metrics: CampaignMetrics(
          impressions: 0,
          clicks: 0,
          conversions: 0,
          revenue: 0.0,
          roi: 0.0,
        ),
        createdBy: 'Marketing Team',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ];
    
    // Mock customer segments
    _segments = [
      CustomerSegment(
        id: '1',
        name: 'High-Value Retailers',
        description: 'Retailers with monthly orders > NPR 50,000',
        customerCount: 150,
        averageOrderValue: 75000.0,
        totalRevenue: 11250000.0,
        growthRate: 12.5,
        characteristics: ['Large Orders', 'Regular Customers', 'Multiple Locations'],
        preferredProducts: ['Antibiotics', 'Chronic Medications'],
        lastUpdated: DateTime.now(),
      ),
      CustomerSegment(
        id: '2',
        name: 'Urban Pharmacies',
        description: 'Pharmacies located in urban areas',
        customerCount: 280,
        averageOrderValue: 25000.0,
        totalRevenue: 7000000.0,
        growthRate: 8.3,
        characteristics: ['Urban Location', 'Walk-in Customers', 'High Foot Traffic'],
        preferredProducts: ['OTC Medications', 'Personal Care'],
        lastUpdated: DateTime.now(),
      ),
      CustomerSegment(
        id: '3',
        name: 'Rural Health Centers',
        description: 'Health centers in rural areas',
        customerCount: 95,
        averageOrderValue: 15000.0,
        totalRevenue: 1425000.0,
        growthRate: 15.7,
        characteristics: ['Rural Location', 'Essential Medicines', 'Government Contracts'],
        preferredProducts: ['Basic Medications', 'Vaccines', 'First Aid'],
        lastUpdated: DateTime.now(),
      ),
    ];
    
    // Mock promotions
    _promotions = [
      Promotion(
        id: '1',
        name: 'Summer Health Package',
        description: '20% off on selected summer health products',
        type: PromotionType.discount,
        status: PromotionStatus.active,
        discountPercentage: 20.0,
        minimumOrder: 5000.0,
        applicableProducts: ['VT-001', 'VT-004', 'VT-007'],
        startDate: DateTime.now().subtract(const Duration(days: 10)),
        endDate: DateTime.now().add(const Duration(days: 20)),
        usageCount: 145,
        totalDiscount: 87500.0,
        additionalRevenue: 350000.0,
        conditions: ['Minimum order NPR 5,000', 'Valid for selected products only'],
        createdBy: 'Marketing Team',
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      Promotion(
        id: '2',
        name: 'New Customer Welcome',
        description: '15% discount on first order for new customers',
        type: PromotionType.newCustomer,
        status: PromotionStatus.active,
        discountPercentage: 15.0,
        minimumOrder: 2000.0,
        applicableProducts: [],
        startDate: DateTime.now().subtract(const Duration(days: 30)),
        endDate: DateTime.now().add(const Duration(days: 60)),
        usageCount: 78,
        totalDiscount: 23400.0,
        additionalRevenue: 156000.0,
        conditions: ['First time customers only', 'Minimum order NPR 2,000'],
        createdBy: 'Marketing Team',
        createdAt: DateTime.now().subtract(const Duration(days: 35)),
      ),
    ];
    
    // Mock analytics
    _analytics = MarketingAnalytics(
      period: DateTime.now(),
      totalCampaigns: 3,
      activeCampaigns: 2,
      totalBudget: 155000.0,
      totalSpent: 70000.0,
      totalImpressions: 175000,
      totalClicks: 9500,
      totalConversions: 630,
      totalRevenue: 475000.0,
      averageROI: 5.4,
      topPerformingChannels: ['Social Media', 'Email', 'SMS'],
      customerAcquisitionCost: 111.11,
      customerLifetimeValue: 8500.0,
      engagementRate: 5.4,
      conversionRate: 6.6,
    );
    
    // Update streams
    _campaignsController.add(_campaigns);
    _segmentsController.add(_segments);
    _promotionsController.add(_promotions);
    _analyticsController.add(_analytics);
    
    debugPrint('✅ Mock data loaded successfully');
  }

  // Campaign Management Methods
  Future<bool> createCampaign(MarketingCampaign campaign) async {
    try {
      final response = await _dio.post('/api/marketing/campaigns', data: campaign.toJson());

      if (response.statusCode == 201) {
        final newCampaign = MarketingCampaign.fromJson(response.data['campaign']);
        _campaigns.add(newCampaign);
        _campaignsController.add(_campaigns);
        return true;
      }
    } catch (e) {
      debugPrint('Failed to create campaign: $e');
    }
    return false;
  }

  Future<bool> updateCampaign(String campaignId, MarketingCampaign campaign) async {
    try {
      final response = await _dio.put('/api/marketing/campaigns/$campaignId', data: campaign.toJson());

      if (response.statusCode == 200) {
        final index = _campaigns.indexWhere((c) => c.id == campaignId);
        if (index != -1) {
          _campaigns[index] = campaign;
          _campaignsController.add(_campaigns);
        }
        return true;
      }
    } catch (e) {
      debugPrint('Failed to update campaign: $e');
    }
    return false;
  }

  Future<bool> deleteCampaign(String campaignId) async {
    try {
      final response = await _dio.delete('/api/marketing/campaigns/$campaignId');

      if (response.statusCode == 200) {
        _campaigns.removeWhere((c) => c.id == campaignId);
        _campaignsController.add(_campaigns);
        return true;
      }
    } catch (e) {
      debugPrint('Failed to delete campaign: $e');
    }
    return false;
  }

  // Promotion Management Methods
  Future<bool> createPromotion(Promotion promotion) async {
    try {
      final response = await _dio.post('/api/marketing/promotions', data: promotion.toJson());

      if (response.statusCode == 201) {
        final newPromotion = Promotion.fromJson(response.data['promotion']);
        _promotions.add(newPromotion);
        _promotionsController.add(_promotions);
        return true;
      }
    } catch (e) {
      debugPrint('Failed to create promotion: $e');
    }
    return false;
  }

  Future<bool> updatePromotion(String promotionId, Promotion promotion) async {
    try {
      final response = await _dio.put('/api/marketing/promotions/$promotionId', data: promotion.toJson());

      if (response.statusCode == 200) {
        final index = _promotions.indexWhere((p) => p.id == promotionId);
        if (index != -1) {
          _promotions[index] = promotion;
          _promotionsController.add(_promotions);
        }
        return true;
      }
    } catch (e) {
      debugPrint('Failed to update promotion: $e');
    }
    return false;
  }

  // Analytics Methods
  List<MarketingCampaign> getCampaignsByStatus(CampaignStatus status) {
    return _campaigns.where((campaign) => campaign.status == status).toList();
  }

  List<MarketingCampaign> getCampaignsByType(CampaignType type) {
    return _campaigns.where((campaign) => campaign.type == type).toList();
  }

  List<Promotion> getActivePromotions() {
    final now = DateTime.now();
    return _promotions.where((promotion) =>
      promotion.status == PromotionStatus.active &&
      promotion.startDate.isBefore(now) &&
      promotion.endDate.isAfter(now)
    ).toList();
  }

  Map<String, double> getRevenueByCampaign() {
    final Map<String, double> revenueByCampaign = {};
    
    for (final campaign in _campaigns) {
      revenueByCampaign[campaign.name] = campaign.metrics.revenue;
    }
    
    return revenueByCampaign;
  }

  Map<String, double> getROIByCampaign() {
    final Map<String, double> roiByCampaign = {};
    
    for (final campaign in _campaigns) {
      roiByCampaign[campaign.name] = campaign.metrics.roi;
    }
    
    return roiByCampaign;
  }

  List<CustomerSegment> getTopPerformingSegments({int limit = 5}) {
    final sortedSegments = List<CustomerSegment>.from(_segments)
      ..sort((a, b) => b.totalRevenue.compareTo(a.totalRevenue));
    
    return sortedSegments.take(limit).toList();
  }

  // Customer Segmentation Methods
  Future<bool> createCustomerSegment(CustomerSegment segment) async {
    try {
      final response = await _dio.post('/api/marketing/segments', data: segment.toJson());

      if (response.statusCode == 201) {
        final newSegment = CustomerSegment.fromJson(response.data['segment']);
        _segments.add(newSegment);
        _segmentsController.add(_segments);
        return true;
      }
    } catch (e) {
      debugPrint('Failed to create customer segment: $e');
    }
    return false;
  }

  Future<bool> updateCustomerSegment(String segmentId, CustomerSegment segment) async {
    try {
      final response = await _dio.put('/api/marketing/segments/$segmentId', data: segment.toJson());

      if (response.statusCode == 200) {
        final index = _segments.indexWhere((s) => s.id == segmentId);
        if (index != -1) {
          _segments[index] = segment;
          _segmentsController.add(_segments);
        }
        return true;
      }
    } catch (e) {
      debugPrint('Failed to update customer segment: $e');
    }
    return false;
  }

  // Reporting Methods
  Future<Map<String, dynamic>> generateCampaignReport({DateTime? startDate, DateTime? endDate}) async {
    final filteredCampaigns = startDate != null && endDate != null
        ? _campaigns.where((campaign) =>
            campaign.startDate.isAfter(startDate) && campaign.endDate.isBefore(endDate)
          ).toList()
        : _campaigns;
    
    final report = {
      'generatedAt': DateTime.now().toIso8601String(),
      'period': startDate != null && endDate != null
          ? '${startDate.toIso8601String()} - ${endDate.toIso8601String()}'
          : 'All time',
      'totalCampaigns': filteredCampaigns.length,
      'activeCampaigns': filteredCampaigns.where((c) => c.status == CampaignStatus.active).length,
      'totalBudget': filteredCampaigns.fold(0.0, (sum, campaign) => sum + campaign.budget),
      'totalSpent': filteredCampaigns.fold(0.0, (sum, campaign) => sum + campaign.spent),
      'totalImpressions': filteredCampaigns.fold(0, (sum, campaign) => sum + campaign.metrics.impressions),
      'totalClicks': filteredCampaigns.fold(0, (sum, campaign) => sum + campaign.metrics.clicks),
      'totalConversions': filteredCampaigns.fold(0, (sum, campaign) => sum + campaign.metrics.conversions),
      'totalRevenue': filteredCampaigns.fold(0.0, (sum, campaign) => sum + campaign.metrics.revenue),
      'averageROI': filteredCampaigns.isNotEmpty
          ? filteredCampaigns.fold(0.0, (sum, campaign) => sum + campaign.metrics.roi) / filteredCampaigns.length
          : 0.0,
      'campaignsByType': _getCampaignsByType(filteredCampaigns),
      'campaignsByStatus': _getCampaignsByStatus(filteredCampaigns),
      'topPerformingCampaigns': _getTopPerformingCampaigns(filteredCampaigns),
      'campaigns': filteredCampaigns.map((campaign) => campaign.toJson()).toList(),
    };
    
    return report;
  }

  Map<String, int> _getCampaignsByType(List<MarketingCampaign> campaigns) {
    final Map<String, int> countByType = {};
    
    for (final campaign in campaigns) {
      final type = campaign.type.toString();
      countByType[type] = (countByType[type] ?? 0) + 1;
    }
    
    return countByType;
  }

  Map<String, int> _getCampaignsByStatus(List<MarketingCampaign> campaigns) {
    final Map<String, int> countByStatus = {};
    
    for (final campaign in campaigns) {
      final status = campaign.status.toString();
      countByStatus[status] = (countByStatus[status] ?? 0) + 1;
    }
    
    return countByStatus;
  }

  List<MarketingCampaign> _getTopPerformingCampaigns(List<MarketingCampaign> campaigns) {
    final sortedCampaigns = List<MarketingCampaign>.from(campaigns)
      ..sort((a, b) => b.metrics.roi.compareTo(a.metrics.roi));
    
    return sortedCampaigns.take(5).toList();
  }

  Future<Map<String, dynamic>> generateCustomerSegmentReport() async {
    final report = {
      'generatedAt': DateTime.now().toIso8601String(),
      'totalSegments': _segments.length,
      'totalCustomers': _segments.fold(0, (sum, segment) => sum + segment.customerCount),
      'totalRevenue': _segments.fold(0.0, (sum, segment) => sum + segment.totalRevenue),
      'averageOrderValue': _segments.isNotEmpty
          ? _segments.fold(0.0, (sum, segment) => sum + segment.averageOrderValue) / _segments.length
          : 0.0,
      'averageGrowthRate': _segments.isNotEmpty
          ? _segments.fold(0.0, (sum, segment) => sum + segment.growthRate) / _segments.length
          : 0.0,
      'topSegments': getTopPerformingSegments(),
      'segments': _segments.map((segment) => segment.toJson()).toList(),
    };
    
    return report;
  }

  void dispose() {
    debugPrint('🗑️ Disposing Marketing Management Service...');
    
    _analyticsTimer?.cancel();
    _campaignsController.close();
    _segmentsController.close();
    _analyticsController.close();
    _promotionsController.close();
    
    debugPrint('✅ Marketing Management Service disposed');
  }
}
