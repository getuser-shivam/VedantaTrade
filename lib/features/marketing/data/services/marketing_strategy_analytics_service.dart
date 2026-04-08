import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:vedanta_trade/core/api_config.dart';
import '../../distribution/data/models/sales_models.dart';
import '../../distribution/data/models/inventory_models.dart';
import '../models/marketing_models.dart';

/// Marketing Strategy Analytics Service
/// Provides advanced analytics and insights to inform marketing strategies
class MarketingStrategyAnalyticsService {
  static final MarketingStrategyAnalyticsService _instance = MarketingStrategyAnalyticsService._internal();
  factory MarketingStrategyAnalyticsService() => _instance;
  MarketingStrategyAnalyticsService._internal();

  final Dio _dio = Dio();
  final StreamController<MarketingInsight> _insightsController = 
      StreamController<MarketingInsight>.broadcast();
  final StreamController<StrategyRecommendation> _recommendationsController = 
      StreamController<StrategyRecommendation>.broadcast();
  final StreamController<MarketTrend> _trendsController = 
      StreamController<MarketTrend>.broadcast();

  List<MarketingInsight> _insights = [];
  List<StrategyRecommendation> _recommendations = [];
  List<MarketTrend> _trends = [];

  // Stream getters
  Stream<MarketingInsight> get insightsStream => _insightsController.stream;
  Stream<StrategyRecommendation> get recommendationsStream => _recommendationsController.stream;
  Stream<MarketTrend> get trendsStream => _trendsController.stream;

  // Data getters
  List<MarketingInsight> get insights => List.unmodifiable(_insights);
  List<StrategyRecommendation> get recommendations => List.unmodifiable(_recommendations);
  List<MarketTrend> get trends => List.unmodifiable(_trends);

  void initialize() {
    _setupDioClient();
  }

  void _setupDioClient() {
    _dio.options.baseUrl = ApiConfig.baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'X-Country': 'NP',
      'X-Currency': 'NPR',
      'X-Timezone': 'Asia/Kathmandu',
    };
  }

  /// Generate comprehensive marketing analytics
  Future<MarketingAnalyticsReport> generateAnalytics({
    required List<SalesRecord> salesData,
    required List<InventoryItem> inventory,
    required List<MarketingCampaign> campaigns,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final period = startDate != null && endDate != null
        ? AnalyticsPeriod.custom
        : AnalyticsPeriod.month;

    // Calculate customer segmentation
    final customerSegments = await _analyzeCustomerSegments(salesData);

    // Calculate product performance
    final productPerformance = await _analyzeProductPerformance(salesData, inventory);

    // Calculate geographic analysis
    final geographicAnalysis = await _analyzeGeographicDistribution(salesData);

    // Calculate seasonal trends
    final seasonalTrends = await _analyzeSeasonalTrends(salesData);

    // Calculate campaign effectiveness
    final campaignEffectiveness = await _analyzeCampaignEffectiveness(campaigns, salesData);

    // Calculate market opportunities
    final marketOpportunities = await _identifyMarketOpportunities(salesData, inventory);

    // Generate strategy recommendations
    final strategyRecommendations = await _generateStrategyRecommendations(
      customerSegments,
      productPerformance,
      geographicAnalysis,
      seasonalTrends,
      campaignEffectiveness,
    );

    // Calculate key performance indicators
    final kpis = await _calculateKPIs(salesData, campaigns);

    return MarketingAnalyticsReport(
      period: period,
      startDate: startDate ?? DateTime.now().subtract(const Duration(days: 30)),
      endDate: endDate ?? DateTime.now(),
      customerSegments: customerSegments,
      productPerformance: productPerformance,
      geographicAnalysis: geographicAnalysis,
      seasonalTrends: seasonalTrends,
      campaignEffectiveness: campaignEffectiveness,
      marketOpportunities: marketOpportunities,
      strategyRecommendations: strategyRecommendations,
      kpis: kpis,
      generatedAt: DateTime.now(),
    );
  }

  /// Analyze customer segments
  Future<List<CustomerSegmentAnalysis>> _analyzeCustomerSegments(List<SalesRecord> salesData) async {
    final customerOrders = <String, List<SalesRecord>>{};
    
    // Group orders by retailer
    for (final sale in salesData) {
      customerOrders[sale.retailerId] = [...(customerOrders[sale.retailerId] ?? []), sale];
    }

    final segments = <CustomerSegmentAnalysis>[];

    for (final entry in customerOrders.entries) {
      final orders = entry.value;
      final totalRevenue = orders.fold<double>(0.0, (sum, order) => sum + order.finalAmount);
      final totalOrders = orders.length;
      final avgOrderValue = totalOrders > 0 ? totalRevenue / totalOrders : 0.0;
      
      // Determine segment based on behavior
      final segment = _determineCustomerSegment(totalRevenue, totalOrders, avgOrderValue);
      
      // Calculate loyalty score
      final loyaltyScore = _calculateLoyaltyScore(orders);
      
      // Calculate purchase frequency
      final purchaseFrequency = _calculatePurchaseFrequency(orders);
      
      segments.add(CustomerSegmentAnalysis(
        customerId: entry.key,
        retailerName: orders.first.retailerName,
        segment: segment,
        totalRevenue: totalRevenue,
        totalOrders: totalOrders,
        avgOrderValue: avgOrderValue,
        loyaltyScore: loyaltyScore,
        purchaseFrequency: purchaseFrequency,
        preferredCategories: _getPreferredCategories(orders),
        lastPurchaseDate: orders.first.date,
        lifetimeValue: _calculateCustomerLifetimeValue(orders),
      ));
    }

    // Sort by revenue
    segments.sort((a, b) => b.totalRevenue.compareTo(a.totalRevenue));

    return segments.take(20).toList();
  }

  /// Determine customer segment
  CustomerSegment _determineCustomerSegment(double revenue, int orders, double avgOrderValue) {
    if (revenue > 100000 && orders > 10) return CustomerSegment.vip;
    if (revenue > 50000 && orders > 5) return CustomerSegment.premium;
    if (revenue > 20000) return CustomerSegment.regular;
    if (orders >= 2) return CustomerSegment.occasional;
    return CustomerSegment.newCustomer;
  }

  /// Calculate loyalty score
  double _calculateLoyaltyScore(List<SalesRecord> orders) {
    if (orders.isEmpty) return 0.0;
    
    var score = 0.0;
    
    // Order frequency contribution
    score += min(orders.length * 5, 30);
    
    // Recency contribution
    final daysSinceLastOrder = DateTime.now().difference(orders.first.date).inDays;
    score += max(0, 30 - daysSinceLastOrder);
    
    // Average order value contribution
    final avgOrderValue = orders.fold<double>(0.0, (sum, order) => sum + order.finalAmount) / orders.length;
    score += min(avgOrderValue / 1000, 20);
    
    return (score / 80) * 100; // Normalize to 0-100
  }

  /// Calculate purchase frequency
  double _calculatePurchaseFrequency(List<SalesRecord> orders) {
    if (orders.length < 2) return 0.0;
    
    final firstOrder = orders.last;
    final lastOrder = orders.first;
    final daysBetween = lastOrder.date.difference(firstOrder.date).inDays;
    
    if (daysBetween == 0) return orders.length.toDouble();
    
    return (orders.length / daysBetween) * 30; // Orders per month
  }

  /// Get preferred categories
  List<String> _getPreferredCategories(List<SalesRecord> orders) {
    final categoryCounts = <String, int>{};
    
    for (final order in orders) {
      for (final item in order.items) {
        // In production, this would map SKU to category
        final category = 'General';
        categoryCounts[category] = (categoryCounts[category] ?? 0) + item.quantity;
      }
    }
    
    final sortedCategories = categoryCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sortedCategories.take(3).map((e) => e.key).toList();
  }

  /// Calculate customer lifetime value
  double _calculateCustomerLifetimeValue(List<SalesRecord> orders) {
    if (orders.isEmpty) return 0.0;
    
    final totalRevenue = orders.fold<double>(0.0, (sum, order) => sum + order.finalAmount);
    final purchaseFrequency = _calculatePurchaseFrequency(orders);
    final avgOrderValue = orders.fold<double>(0.0, (sum, order) => sum + order.finalAmount) / orders.length;
    
    // Simplified CLV calculation
    // CLV = (Average Order Value × Purchase Frequency × Customer Lifespan)
    // Assuming average customer lifespan of 12 months
    return avgOrderValue * purchaseFrequency * 12;
  }

  /// Analyze product performance
  Future<List<ProductPerformanceAnalysis>> _analyzeProductPerformance(
    List<SalesRecord> salesData,
    List<InventoryItem> inventory,
  ) async {
    final productSales = <String, ProductSalesData>{};
    
    // Aggregate sales by product
    for (final sale in salesData) {
      for (final item in sale.items) {
        final existing = productSales[item.sku] ?? ProductSalesData(
          sku: item.sku,
          productName: item.productName,
          totalQuantity: 0,
          totalRevenue: 0.0,
          orderCount: 0,
        );
        
        productSales[item.sku] = ProductSalesData(
          sku: item.sku,
          productName: item.productName,
          totalQuantity: existing.totalQuantity + item.quantity,
          totalRevenue: existing.totalRevenue + item.totalPrice,
          orderCount: existing.orderCount + 1,
        );
      }
    }

    final analyses = <ProductPerformanceAnalysis>[];

    for (final entry in productSales.entries) {
      final salesData = entry.value;
      final inventoryItem = inventory.firstWhere(
        (item) => item.sku == entry.key,
        orElse: () => InventoryItem(
          id: '',
          sku: entry.key,
          productName: salesData.productName,
          brand: '',
          category: 'Unknown',
          description: '',
          unitPrice: 0.0,
          currentStock: 0,
          minStock: 0,
          maxStock: 0,
          reorderLevel: 0,
          batchNumber: '',
          expiryDate: DateTime.now(),
          manufacturer: '',
          storageConditions: '',
          lastUpdated: DateTime.now(),
        ),
      );

      // Calculate performance metrics
      final revenue = salesData.totalRevenue;
      final quantity = salesData.totalQuantity;
      final orders = salesData.orderCount;
      const price = 0.0; // Would come from inventory
      
      final profitMargin = _calculateProfitMargin(revenue, quantity, price);
      final turnoverRate = _calculateTurnoverRate(quantity, inventoryItem.currentStock);
      final marketShare = _calculateMarketShare(quantity, salesData.totalQuantity);
      
      // Determine performance rating
      final rating = _determineProductPerformanceRating(revenue, quantity, profitMargin);

      analyses.add(ProductPerformanceAnalysis(
        sku: entry.key,
        productName: salesData.productName,
        category: inventoryItem.category,
        revenue: revenue,
        quantitySold: quantity,
        orderCount: orders,
        profitMargin: profitMargin,
        turnoverRate: turnoverRate,
        marketShare: marketShare,
        rating: rating,
        trend: _calculateProductTrend(salesData),
        recommendations: _generateProductRecommendations(rating, turnoverRate, inventoryItem),
      ));
    }

    // Sort by revenue
    analyses.sort((a, b) => b.revenue.compareTo(a.revenue));

    return analyses.take(20).toList();
  }

  double _calculateProfitMargin(double revenue, int quantity, double cost) {
    if (revenue == 0) return 0.0;
    // Simplified - would need actual cost data
    return ((revenue - (cost * quantity)) / revenue) * 100;
  }

  double _calculateTurnoverRate(int sold, int stock) {
    if (stock == 0) return sold.toDouble();
    return sold / stock;
  }

  double _calculateMarketShare(int productQuantity, int totalQuantity) {
    if (totalQuantity == 0) return 0.0;
    return (productQuantity / totalQuantity) * 100;
  }

  PerformanceRating _determineProductPerformanceRating(double revenue, int quantity, double margin) {
    var score = 0.0;
    
    score += min(revenue / 10000, 30);
    score += min(quantity / 100, 30);
    score += min(margin, 40);
    
    if (score >= 80) return PerformanceRating.excellent;
    if (score >= 60) return PerformanceRating.good;
    if (score >= 40) return PerformanceRating.average;
    if (score >= 20) return PerformanceRating.poor;
    return PerformanceRating.critical;
  }

  ProductTrend _calculateProductTrend(ProductSalesData salesData) {
    // Simplified trend calculation
    // In production, would analyze time series data
    if (salesData.totalQuantity > 100) return ProductTrend.growing;
    if (salesData.totalQuantity > 50) return ProductTrend.stable;
    return ProductTrend.declining;
  }

  List<String> _generateProductRecommendations(PerformanceRating rating, double turnover, InventoryItem item) {
    final recommendations = <String>[];
    
    if (rating == PerformanceRating.excellent) {
      recommendations.add('Increase marketing investment');
      recommendations.add('Consider expanding inventory');
    } else if (rating == PerformanceRating.good) {
      recommendations.add('Maintain current strategy');
    } else if (rating == PerformanceRating.average) {
      recommendations.add('Review pricing strategy');
      recommendations.add('Increase promotional activities');
    } else if (rating == PerformanceRating.poor) {
      recommendations.add('Consider discontinuation');
      recommendations.add('Clear existing inventory');
    } else {
      recommendations.add('Immediate action required');
      recommendations.add('Review product viability');
    }
    
    if (turnover > 2.0) {
      recommendations.add('Increase stock levels');
    } else if (turnover < 0.5) {
      recommendations.add('Reduce stock levels');
    }
    
    return recommendations;
  }

  /// Analyze geographic distribution
  Future<GeographicAnalysis> _analyzeGeographicDistribution(List<SalesRecord> salesData) async {
    final locationSales = <String, List<SalesRecord>>{};
    
    for (final sale in salesData) {
      locationSales[sale.retailerLocation] = [...(locationSales[sale.retailerLocation] ?? []), sale];
    }

    final regionData = <RegionData>[];

    for (final entry in locationSales.entries) {
      final orders = entry.value;
      final revenue = orders.fold<double>(0.0, (sum, order) => sum + order.finalAmount);
      final orderCount = orders.length;
      
      regionData.add(RegionData(
        region: entry.key,
        revenue: revenue,
        orderCount: orderCount,
        avgOrderValue: orderCount > 0 ? revenue / orderCount : 0.0,
        growthRate: _calculateRegionGrowthRate(orders),
        marketPenetration: _calculateMarketPenetration(orders),
      ));
    }

    regionData.sort((a, b) => b.revenue.compareTo(a.revenue));

    return GeographicAnalysis(
      regions: regionData,
      topPerformingRegion: regionData.isNotEmpty ? regionData.first.region : 'N/A',
      growthOpportunities: _identifyGrowthOpportunities(regionData),
      recommendedExpansion: _recommendRegionalExpansion(regionData),
    );
  }

  double _calculateRegionGrowthRate(List<SalesRecord> orders) {
    // Simplified growth rate calculation
    if (orders.length < 2) return 0.0;
    
    final recentOrders = orders.take(5).toList();
    final olderOrders = orders.skip(5).take(5).toList();
    
    if (olderOrders.isEmpty) return 0.0;
    
    final recentRevenue = recentOrders.fold<double>(0.0, (sum, order) => sum + order.finalAmount);
    final olderRevenue = olderOrders.fold<double>(0.0, (sum, order) => sum + order.finalAmount);
    
    if (olderRevenue == 0) return 0.0;
    return ((recentRevenue - olderRevenue) / olderRevenue) * 100;
  }

  double _calculateMarketPenetration(List<SalesRecord> orders) {
    // Simplified market penetration
    // In production, would compare against total addressable market
    return min(orders.length * 2, 100).toDouble();
  }

  List<String> _identifyGrowthOpportunities(List<RegionData> regions) {
    final opportunities = <String>[];
    
    for (final region in regions) {
      if (region.growthRate > 20) {
        opportunities.add('Expand marketing in ${region.region}');
      }
      if (region.marketPenetration < 30) {
        opportunities.add('Increase sales efforts in ${region.region}');
      }
    }
    
    return opportunities;
  }

  String _recommendRegionalExpansion(List<RegionData> regions) {
    if (regions.isEmpty) return 'No data available';
    
    // Find region with highest growth but low penetration
    final target = regions.where((r) => r.growthRate > 10 && r.marketPenetration < 50)
        .toList()
      ..sort((a, b) => b.growthRate.compareTo(a.growthRate));
    
    return target.isNotEmpty ? target.first.region : regions.first.region;
  }

  /// Analyze seasonal trends
  Future<SeasonalTrends> _analyzeSeasonalTrends(List<SalesRecord> salesData) async {
    final monthlySales = <int, double>{};
    
    for (final sale in salesData) {
      final month = sale.date.month;
      monthlySales[month] = (monthlySales[month] ?? 0.0) + sale.finalAmount;
    }

    // Identify peak and low seasons
    final sortedMonths = monthlySales.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    final peakSeason = sortedMonths.isNotEmpty ? sortedMonths.first.key : 1;
    final lowSeason = sortedMonths.isNotEmpty ? sortedMonths.last.key : 1;

    return SeasonalTrends(
      monthlySales: monthlySales,
      peakSeason: peakSeason,
      lowSeason: lowSeason,
      seasonalPatterns: _identifySeasonalPatterns(monthlySales),
      recommendations: _generateSeasonalRecommendations(peakSeason, lowSeason),
    );
  }

  List<SeasonalPattern> _identifySeasonalPatterns(Map<int, double> monthlySales) {
    final patterns = <SeasonalPattern>[];
    
    if (monthlySales.isEmpty) return patterns;
    
    final avgSales = monthlySales.values.reduce((a, b) => a + b) / monthlySales.length;
    
    for (final entry in monthlySales.entries) {
      final month = entry.key;
      final sales = entry.value;
      final variance = ((sales - avgSales) / avgSales) * 100;
      
      if (variance > 20) {
        patterns.add(SeasonalPattern(
          month: month,
          pattern: SeasonalPatternType.high,
          variance: variance,
        ));
      } else if (variance < -20) {
        patterns.add(SeasonalPattern(
          month: month,
          pattern: SeasonalPatternType.low,
          variance: variance,
        ));
      }
    }
    
    return patterns;
  }

  List<String> _generateSeasonalRecommendations(int peakSeason, int lowSeason) {
    final recommendations = <String>[];
    
    recommendations.add('Increase inventory before peak season (month $peakSeason)');
    recommendations.add('Launch promotional campaigns during low season (month $lowSeason)');
    recommendations.add('Adjust staffing based on seasonal demand');
    
    return recommendations;
  }

  /// Analyze campaign effectiveness
  Future<CampaignEffectivenessAnalysis> _analyzeCampaignEffectiveness(
    List<MarketingCampaign> campaigns,
    List<SalesRecord> salesData,
  ) async {
    final analyses = <CampaignPerformance>[];

    for (final campaign in campaigns) {
      // Calculate campaign metrics
      final roi = campaign.metrics.roi;
      final conversionRate = campaign.metrics.conversions > 0
          ? (campaign.metrics.conversions / campaign.metrics.clicks) * 100
          : 0.0;
      final costPerAcquisition = campaign.metrics.spent > 0
          ? campaign.metrics.spent / campaign.metrics.conversions
          : 0.0;
      
      // Determine effectiveness rating
      final rating = _determineCampaignEffectivenessRating(roi, conversionRate);
      
      analyses.add(CampaignPerformance(
        campaignId: campaign.id,
        campaignName: campaign.name,
        roi: roi,
        conversionRate: conversionRate,
        costPerAcquisition: costPerAcquisition,
        revenue: campaign.metrics.revenue,
        spent: campaign.spent,
        rating: rating,
        recommendations: _generateCampaignRecommendations(rating, roi),
      ));
    }

    analyses.sort((a, b) => b.roi.compareTo(a.roi));

    return CampaignEffectivenessAnalysis(
      campaigns: analyses,
      bestPerformingChannel: _identifyBestPerformingChannel(analyses),
      avgROI: analyses.isNotEmpty 
          ? analyses.fold<double>(0.0, (sum, c) => sum + c.roi) / analyses.length 
          : 0.0,
      avgConversionRate: analyses.isNotEmpty
          ? analyses.fold<double>(0.0, (sum, c) => sum + c.conversionRate) / analyses.length
          : 0.0,
    );
  }

  EffectivenessRating _determineCampaignEffectivenessRating(double roi, double conversionRate) {
    if (roi > 5.0 && conversionRate > 5.0) return EffectivenessRating.excellent;
    if (roi > 3.0 && conversionRate > 3.0) return EffectivenessRating.good;
    if (roi > 1.0 && conversionRate > 1.0) return EffectivenessRating.average;
    return EffectivenessRating.poor;
  }

  String _identifyBestPerformingChannel(List<CampaignPerformance> analyses) {
    // Simplified - would analyze actual channel data
    return analyses.isNotEmpty ? 'Social Media' : 'N/A';
  }

  List<String> _generateCampaignRecommendations(EffectivenessRating rating, double roi) {
    final recommendations = <String>[];
    
    switch (rating) {
      case EffectivenessRating.excellent:
        recommendations.add('Scale up successful campaigns');
        recommendations.add('Increase budget allocation');
        break;
      case EffectivenessRating.good:
        recommendations.add('Optimize targeting');
        recommendations.add('A/B test variations');
        break;
      case EffectivenessRating.average:
        recommendations.add('Review campaign strategy');
        recommendations.add('Adjust messaging');
        break;
      case EffectivenessRating.poor:
        recommendations.add('Consider pausing campaign');
        recommendations.add('Redesign creative assets');
        break;
    }
    
    return recommendations;
  }

  /// Identify market opportunities
  Future<List<MarketOpportunity>> _identifyMarketOpportunities(
    List<SalesRecord> salesData,
    List<InventoryItem> inventory,
  ) async {
    final opportunities = <MarketOpportunity>[];

    // Identify underperforming categories with potential
    final categoryPerformance = <String, double>{};
    for (final sale in salesData) {
      for (final item in sale.items) {
        // In production, would map to actual categories
        final category = 'General';
        categoryPerformance[category] = (categoryPerformance[category] ?? 0.0) + item.totalPrice;
      }
    }

    // Identify low stock high demand products
    for (final item in inventory) {
      if (item.currentStock < item.minStock) {
        opportunities.add(MarketOpportunity(
          type: OpportunityType.inventory,
          title: 'Restock ${item.productName}',
          description: 'High demand, low stock',
          priority: OpportunityPriority.high,
          estimatedValue: (item.maxStock - item.currentStock) * item.unitPrice,
          actionRequired: true,
        ));
      }
    }

    // Identify cross-selling opportunities
    opportunities.add(MarketOpportunity(
      type: OpportunityType.crossSell,
      title: 'Bundle complementary products',
      description: 'Increase average order value through product bundles',
      priority: OpportunityPriority.medium,
      estimatedValue: 0.0,
      actionRequired: false,
    ));

    // Identify new market segments
    opportunities.add(MarketOpportunity(
      type: OpportunityType.marketExpansion,
      title: 'Expand to underserved regions',
      description: 'Geographic areas with low market penetration',
      priority: OpportunityPriority.medium,
      estimatedValue: 0.0,
      actionRequired: false,
    ));

    return opportunities;
  }

  /// Generate strategy recommendations
  Future<List<StrategyRecommendation>> _generateStrategyRecommendations(
    List<CustomerSegmentAnalysis> customerSegments,
    List<ProductPerformanceAnalysis> productPerformance,
    GeographicAnalysis geographicAnalysis,
    SeasonalTrends seasonalTrends,
    CampaignEffectivenessAnalysis campaignEffectiveness,
  ) async {
    final recommendations = <StrategyRecommendation>[];

    // Customer-focused recommendations
    final vipCustomers = customerSegments.where((c) => c.segment == CustomerSegment.vip).length;
    if (vipCustomers > 0) {
      recommendations.add(StrategyRecommendation(
        category: StrategyCategory.customerRetention,
        title: 'VIP Customer Program',
        description: 'Implement loyalty program for high-value customers',
        priority: RecommendationPriority.high,
        expectedImpact: 'Increase retention by 15%',
        implementationCost: 'Medium',
        timeframe: '3 months',
      ));
    }

    // Product-focused recommendations
    final topProducts = productPerformance.where((p) => p.rating == PerformanceRating.excellent).length;
    if (topProducts > 0) {
      recommendations.add(StrategyRecommendation(
        category: StrategyCategory.productStrategy,
        title: 'Focus on Top Products',
        description: 'Increase marketing for best-performing products',
        priority: RecommendationPriority.high,
        expectedImpact: 'Increase revenue by 10%',
        implementationCost: 'Low',
        timeframe: '1 month',
      ));
    }

    // Geographic recommendations
    if (geographicAnalysis.growthOpportunities.isNotEmpty) {
      recommendations.add(StrategyRecommendation(
        category: StrategyCategory.geographicExpansion,
        title: 'Regional Growth Initiative',
        description: geographicAnalysis.growthOpportunities.first,
        priority: RecommendationPriority.medium,
        expectedImpact: 'Increase market share by 5%',
        implementationCost: 'High',
        timeframe: '6 months',
      ));
    }

    // Seasonal recommendations
    recommendations.add(StrategyRecommendation(
      category: StrategyCategory.seasonalStrategy,
      title: 'Seasonal Campaign Planning',
      description: 'Align marketing with seasonal demand patterns',
      priority: RecommendationPriority.medium,
      expectedImpact: 'Optimize inventory and marketing spend',
      implementationCost: 'Medium',
      timeframe: '2 months',
    ));

    return recommendations;
  }

  /// Calculate KPIs
  Future<MarketingKPIs> _calculateKPIs(
    List<SalesRecord> salesData,
    List<MarketingCampaign> campaigns,
  ) async {
    final totalRevenue = salesData.fold<double>(0.0, (sum, sale) => sum + sale.finalAmount);
    final totalOrders = salesData.length;
    final avgOrderValue = totalOrders > 0 ? totalRevenue / totalOrders : 0.0;
    
    final totalMarketingSpend = campaigns.fold<double>(0.0, (sum, c) => sum + c.spent);
    final marketingROI = totalMarketingSpend > 0 
        ? (totalRevenue - totalMarketingSpend) / totalMarketingSpend 
        : 0.0;
    
    final totalConversions = campaigns.fold<int>(0, (sum, c) => sum + c.metrics.conversions);
    final totalImpressions = campaigns.fold<int>(0, (sum, c) => sum + c.metrics.impressions);
    final conversionRate = totalImpressions > 0 
        ? (totalConversions / totalImpressions) * 100 
        : 0.0;

    return MarketingKPIs(
      totalRevenue: totalRevenue,
      totalOrders: totalOrders,
      avgOrderValue: avgOrderValue,
      marketingROI: marketingROI,
      marketingSpend: totalMarketingSpend,
      conversionRate: conversionRate,
      customerAcquisitionCost: totalMarketingSpend > 0 
          ? totalMarketingSpend / totalConversions 
          : 0.0,
      customerLifetimeValue: avgOrderValue * 12, // Simplified
    );
  }
}

// Supporting Models
class ProductSalesData {
  final String sku;
  final String productName;
  final int totalQuantity;
  final double totalRevenue;
  final int orderCount;

  const ProductSalesData({
    required this.sku,
    required this.productName,
    required this.totalQuantity,
    required this.totalRevenue,
    required this.orderCount,
  });
}

enum CustomerSegment { vip, premium, regular, occasional, newCustomer }

enum PerformanceRating { excellent, good, average, poor, critical }

enum ProductTrend { growing, stable, declining }

enum OpportunityType { inventory, crossSell, marketExpansion, newProduct }

enum OpportunityPriority { high, medium, low }

enum StrategyCategory { customerRetention, productStrategy, geographicExpansion, seasonalStrategy }

enum SeasonalPatternType { high, low }

enum EffectivenessRating { excellent, good, average, poor }
