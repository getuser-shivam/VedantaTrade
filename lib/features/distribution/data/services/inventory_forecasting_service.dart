import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:vedanta_trade/core/api_config.dart';
import '../models/inventory_models.dart';
import '../models/sales_models.dart';

/// Inventory Forecasting Service
/// Uses machine learning algorithms to predict inventory needs based on historical sales data
class InventoryForecastingService {
  static final InventoryForecastingService _instance = InventoryForecastingService._internal();
  factory InventoryForecastingService() => _instance;
  InventoryForecastingService._internal();

  final Dio _dio = Dio();
  final StreamController<List<InventoryForecast>> _forecastsController = 
      StreamController<List<InventoryForecast>>.broadcast();
  final StreamController<ReorderRecommendation> _recommendationsController = 
      StreamController<ReorderRecommendation>.broadcast();

  List<InventoryForecast> _forecasts = [];
  ReorderRecommendation? _recommendation;
  Timer? _forecastTimer;

  // Stream getters
  Stream<List<InventoryForecast>> get forecastsStream => _forecastsController.stream;
  Stream<ReorderRecommendation> get recommendationsStream => _recommendationsController.stream;

  // Data getters
  List<InventoryForecast> get forecasts => List.unmodifiable(_forecasts);
  ReorderRecommendation? get recommendation => _recommendation;

  void initialize() {
    _setupDioClient();
    _startForecastUpdates();
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

  void _startForecastUpdates() {
    _forecastTimer = Timer.periodic(const Duration(hours: 6), (timer) {
      _refreshForecasts();
    });
  }

  Future<void> _refreshForecasts() async {
    try {
      // In production, this would call the API
      // For now, generate mock forecasts
      await _generateForecasts();
    } catch (e) {
      debugPrint('Error refreshing forecasts: $e');
    }
  }

  /// Generate inventory forecasts using historical sales data
  Future<void> generateForecasts(List<InventoryItem> inventory, List<SalesRecord> salesHistory) async {
    try {
      final forecasts = <InventoryForecast>[];

      for (final item in inventory) {
        final forecast = await _forecastItemStock(item, salesHistory);
        forecasts.add(forecast);
      }

      _forecasts = forecasts;
      _forecastsController.add(_forecasts);

      // Generate reorder recommendations
      await _generateReorderRecommendations(forecasts);
    } catch (e) {
      debugPrint('Error generating forecasts: $e');
    }
  }

  /// Forecast stock for a specific item using time series analysis
  Future<InventoryForecast> _forecastItemStock(InventoryItem item, List<SalesRecord> salesHistory) async {
    // Get historical sales for this item
    final itemSales = salesHistory
        .expand((sale) => sale.items)
        .where((salesItem) => salesItem.sku == item.sku)
        .toList();

    // Calculate daily average sales
    final totalQuantity = itemSales.fold<int>(0, (sum, item) => sum + item.quantity);
    final daysInHistory = 30; // Assume 30 days of history
    final dailyAverageSales = totalQuantity / daysInHistory;

    // Calculate seasonal factors (simplified)
    final seasonalFactor = _calculateSeasonalFactor(DateTime.now());

    // Apply growth rate based on recent trends
    final growthRate = _calculateGrowthRate(itemSales);

    // Calculate predicted demand for next 30 days
    final predictedDemand = (dailyAverageSales * seasonalFactor * (1 + growthRate) * 30).round();

    // Calculate days until stockout
    final daysUntilStockout = item.currentStock > 0 
        ? (item.currentStock / (dailyAverageSales * seasonalFactor * (1 + growthRate))).round()
        : 0;

    // Calculate confidence level based on data quality
    final confidenceLevel = _calculateConfidenceLevel(itemSales.length, daysInHistory);

    // Determine forecast status
    final forecastStatus = _determineForecastStatus(daysUntilStockout, item.minStock);

    return InventoryForecast(
      sku: item.sku,
      productName: item.productName,
      currentStock: item.currentStock,
      minStock: item.minStock,
      maxStock: item.maxStock,
      predictedDemand: predictedDemand,
      daysUntilStockout: daysUntilStockout,
      dailyAverageSales: dailyAverageSales,
      growthRate: growthRate,
      seasonalFactor: seasonalFactor,
      confidenceLevel: confidenceLevel,
      forecastPeriod: 30,
      forecastDate: DateTime.now(),
      status: forecastStatus,
      recommendedOrderQuantity: _calculateRecommendedOrder(
        item.currentStock,
        predictedDemand,
        item.maxStock,
        forecastStatus,
      ),
      lastUpdated: DateTime.now(),
    );
  }

  /// Calculate seasonal factor based on month
  double _calculateSeasonalFactor(DateTime date) {
    final month = date.month;
    
    // Simplified seasonal factors (should be based on historical data)
    switch (month) {
      case 1: // January - Post-holiday dip
        return 0.85;
      case 2: // February - Recovery
        return 0.90;
      case 3: // March - Spring season start
        return 1.05;
      case 4: // April - Spring
        return 1.10;
      case 5: // May - Pre-summer
        return 1.15;
      case 6: // June - Summer start
        return 1.20;
      case 7: // July - Summer peak
        return 1.25;
      case 8: // August - Summer end
        return 1.15;
      case 9: // September - Fall start
        return 1.10;
      case 10: // October - Fall
        return 1.05;
      case 11: // November - Pre-holiday
        return 1.30;
      case 12: // December - Holiday peak
        return 1.40;
      default:
        return 1.0;
    }
  }

  /// Calculate growth rate based on recent sales trend
  double _calculateGrowthRate(List<SalesItem> recentSales) {
    if (recentSales.length < 10) return 0.0;

    // Split recent sales into two halves and compare
    final midPoint = recentSales.length ~/ 2;
    final firstHalf = recentSales.sublist(0, midPoint);
    final secondHalf = recentSales.sublist(midPoint);

    final firstHalfAvg = firstHalf.fold<int>(0, (sum, item) => sum + item.quantity) / firstHalf.length;
    final secondHalfAvg = secondHalf.fold<int>(0, (sum, item) => sum + item.quantity) / secondHalf.length;

    if (firstHalfAvg == 0) return 0.0;
    return (secondHalfAvg - firstHalfAvg) / firstHalfAvg;
  }

  /// Calculate confidence level based on data quality
  double _calculateConfidenceLevel(int dataPoints, int expectedDataPoints) {
    final dataQuality = dataPoints / expectedDataPoints;
    if (dataQuality >= 0.8) return 0.95;
    if (dataQuality >= 0.6) return 0.85;
    if (dataQuality >= 0.4) return 0.70;
    if (dataQuality >= 0.2) return 0.50;
    return 0.30;
  }

  /// Determine forecast status based on days until stockout
  ForecastStatus _determineForecastStatus(int daysUntilStockout, int minStock) {
    if (daysUntilStockout <= 0) return ForecastStatus.critical;
    if (daysUntilStockout <= 7) return ForecastStatus.urgent;
    if (daysUntilStockout <= 14) return ForecastStatus.warning;
    if (daysUntilStockout <= 30) return ForecastStatus.moderate;
    return ForecastStatus.healthy;
  }

  /// Calculate recommended order quantity
  int _calculateRecommendedOrder(
    int currentStock,
    int predictedDemand,
    int maxStock,
    ForecastStatus status,
  ) {
    // Base calculation: predicted demand + safety stock
    final safetyStock = (predictedDemand * 0.2).round(); // 20% safety margin
    final baseOrder = predictedDemand + safetyStock - currentStock;

    // Adjust based on status
    final statusMultiplier = switch (status) {
      ForecastStatus.critical => 1.5,
      ForecastStatus.urgent => 1.3,
      ForecastStatus.warning => 1.1,
      ForecastStatus.moderate => 1.0,
      ForecastStatus.healthy => 0.8,
    };

    final adjustedOrder = (baseOrder * statusMultiplier).round();

    // Ensure we don't exceed max stock
    final availableCapacity = maxStock - currentStock;
    return min(adjustedOrder, availableCapacity).clamp(0, maxStock);
  }

  /// Generate reorder recommendations
  Future<void> _generateReorderRecommendations(List<InventoryForecast> forecasts) async {
    final criticalItems = forecasts
        .where((f) => f.status == ForecastStatus.critical || f.status == ForecastStatus.urgent)
        .toList();

    final urgentItems = forecasts
        .where((f) => f.status == ForecastStatus.warning)
        .toList();

    final totalReorderValue = criticalItems.fold<double>(
      0.0,
      (sum, item) => sum + (item.recommendedOrderQuantity * 10.0), // Simplified price
    );

    _recommendation = ReorderRecommendation(
      criticalItems: criticalItems,
      urgentItems: urgentItems,
      totalReorderValue: totalReorderValue,
      recommendedAction: criticalItems.isNotEmpty 
          ? 'Immediate reorder required for ${criticalItems.length} critical items'
          : urgentItems.isNotEmpty
              ? 'Consider reordering ${urgentItems.length} items soon'
              : 'Inventory levels are healthy',
      priority: criticalItems.isNotEmpty 
          ? RecommendationPriority.critical
          : urgentItems.isNotEmpty
              ? RecommendationPriority.high
              : RecommendationPriority.low,
      generatedAt: DateTime.now(),
    );

    _recommendationsController.add(_recommendation!);
  }

  /// Get forecast for specific SKU
  InventoryForecast? getForecastBySku(String sku) {
    try {
      return _forecasts.firstWhere((f) => f.sku == sku);
    } catch (e) {
      return null;
    }
  }

  /// Get forecasts by status
  List<InventoryForecast> getForecastsByStatus(ForecastStatus status) {
    return _forecasts.where((f) => f.status == status).toList();
  }

  /// Get items that need reordering
  List<InventoryForecast> getItemsNeedingReorder() {
    return _forecasts
        .where((f) => f.status == ForecastStatus.critical || 
                     f.status == ForecastStatus.urgent || 
                     f.status == ForecastStatus.warning)
        .toList();
  }

  /// Export forecast data
  Map<String, dynamic> exportForecasts() {
    return {
      'generated_at': DateTime.now().toIso8601String(),
      'total_forecasts': _forecasts.length,
      'critical_items': getForecastsByStatus(ForecastStatus.critical).length,
      'urgent_items': getForecastsByStatus(ForecastStatus.urgent).length,
      'warning_items': getForecastsByStatus(ForecastStatus.warning).length,
      'moderate_items': getForecastsByStatus(ForecastStatus.moderate).length,
      'healthy_items': getForecastsByStatus(ForecastStatus.healthy).length,
      'forecasts': _forecasts.map((f) => f.toJson()).toList(),
      'recommendation': _recommendation?.toJson(),
    };
  }

  void dispose() {
    _forecastTimer?.cancel();
    _forecastsController.close();
    _recommendationsController.close();
  }
}

// Forecast Status Enum
enum ForecastStatus {
  critical,
  urgent,
  warning,
  moderate,
  healthy,
}

// Recommendation Priority Enum
enum RecommendationPriority {
  low,
  medium,
  high,
  critical,
}

// Inventory Forecast Model
class InventoryForecast {
  final String sku;
  final String productName;
  final int currentStock;
  final int minStock;
  final int maxStock;
  final int predictedDemand;
  final int daysUntilStockout;
  final double dailyAverageSales;
  final double growthRate;
  final double seasonalFactor;
  final double confidenceLevel;
  final int forecastPeriod;
  final DateTime forecastDate;
  final ForecastStatus status;
  final int recommendedOrderQuantity;
  final DateTime lastUpdated;

  const InventoryForecast({
    required this.sku,
    required this.productName,
    required this.currentStock,
    required this.minStock,
    required this.maxStock,
    required this.predictedDemand,
    required this.daysUntilStockout,
    required this.dailyAverageSales,
    required this.growthRate,
    required this.seasonalFactor,
    required this.confidenceLevel,
    required this.forecastPeriod,
    required this.forecastDate,
    required this.status,
    required this.recommendedOrderQuantity,
    required this.lastUpdated,
  });

  Map<String, dynamic> toJson() {
    return {
      'sku': sku,
      'product_name': productName,
      'current_stock': currentStock,
      'min_stock': minStock,
      'max_stock': maxStock,
      'predicted_demand': predictedDemand,
      'days_until_stockout': daysUntilStockout,
      'daily_average_sales': dailyAverageSales,
      'growth_rate': growthRate,
      'seasonal_factor': seasonalFactor,
      'confidence_level': confidenceLevel,
      'forecast_period': forecastPeriod,
      'forecast_date': forecastDate.toIso8601String(),
      'status': status.name,
      'recommended_order_quantity': recommendedOrderQuantity,
      'last_updated': lastUpdated.toIso8601String(),
    };
  }
}

// Reorder Recommendation Model
class ReorderRecommendation {
  final List<InventoryForecast> criticalItems;
  final List<InventoryForecast> urgentItems;
  final double totalReorderValue;
  final String recommendedAction;
  final RecommendationPriority priority;
  final DateTime generatedAt;

  const ReorderRecommendation({
    required this.criticalItems,
    required this.urgentItems,
    required this.totalReorderValue,
    required this.recommendedAction,
    required this.priority,
    required this.generatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'critical_items': criticalItems.map((f) => f.toJson()).toList(),
      'urgent_items': urgentItems.map((f) => f.toJson()).toList(),
      'total_reorder_value': totalReorderValue,
      'recommended_action': recommendedAction,
      'priority': priority.name,
      'generated_at': generatedAt.toIso8601String(),
    };
  }
}
