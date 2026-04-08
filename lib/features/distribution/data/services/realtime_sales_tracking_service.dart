import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:vedanta_trade/core/api_config.dart';
import '../models/sales_models.dart';
import '../models/inventory_models.dart';

/// Real-Time Sales Tracking Service
/// Tracks sales in real-time, provides analytics, and integrates with marketing strategies
class RealtimeSalesTrackingService {
  static final RealtimeSalesTrackingService _instance = RealtimeSalesTrackingService._internal();
  factory RealtimeSalesTrackingService() => _instance;
  RealtimeSalesTrackingService._internal();

  final Dio _dio = Dio();
  final StreamController<List<SalesRecord>> _salesStreamController = 
      StreamController<List<SalesRecord>>.broadcast();
  final StreamController<RealtimeSalesMetrics> _metricsController = 
      StreamController<RealtimeSalesMetrics>.broadcast();
  final StreamController<List<LiveTransaction>> _liveTransactionsController = 
      StreamController<List<LiveTransaction>>.broadcast();
  final StreamController<SalesAlert> _alertsController = 
      StreamController<SalesAlert>.broadcast();

  List<SalesRecord> _sales = [];
  List<LiveTransaction> _liveTransactions = [];
  RealtimeSalesMetrics _metrics = RealtimeSalesMetrics();
  Timer? _realtimeTimer;
  String? _currentStockistId;

  // Stream getters
  Stream<List<SalesRecord>> get salesStream => _salesStreamController.stream;
  Stream<RealtimeSalesMetrics> get metricsStream => _metricsController.stream;
  Stream<List<LiveTransaction>> get liveTransactionsStream => _liveTransactionsController.stream;
  Stream<SalesAlert> get alertsStream => _alertsController.stream;

  // Data getters
  List<SalesRecord> get sales => List.unmodifiable(_sales);
  List<LiveTransaction> get liveTransactions => List.unmodifiable(_liveTransactions);
  RealtimeSalesMetrics get metrics => _metrics;

  void initialize({String? stockistId}) {
    _currentStockistId = stockistId;
    _setupDioClient();
    _startRealtimeTracking();
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

  void _startRealtimeTracking() {
    // Poll for new sales every 10 seconds
    _realtimeTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _fetchNewSales();
      _updateMetrics();
    });
  }

  Future<void> _fetchNewSales() async {
    try {
      final response = await _dio.get(
        '/api/sales/realtime/$_currentStockistId',
      );

      if (response.statusCode == 200) {
        final newSales = (response.data['sales'] as List)
            .map((json) => SalesRecord.fromJson(json))
            .toList();

        // Add new sales to the list
        for (final sale in newSales) {
          if (!_sales.any((s) => s.id == sale.id)) {
            _sales.insert(0, sale);
            
            // Create live transaction
            _liveTransactions.add(LiveTransaction.fromSalesRecord(sale));
            
            // Check for sales alerts
            _checkForAlerts(sale);
          }
        }

        // Keep only last 100 sales
        if (_sales.length > 100) {
          _sales = _sales.sublist(0, 100);
        }

        // Keep only last 50 live transactions
        if (_liveTransactions.length > 50) {
          _liveTransactions = _liveTransactions.sublist(0, 50);
        }

        _salesStreamController.add(_sales);
        _liveTransactionsController.add(_liveTransactions);
      }
    } catch (e) {
      debugPrint('Error fetching new sales: $e');
    }
  }

  void _checkForAlerts(SalesRecord sale) {
    // Check for high-value orders
    if (sale.finalAmount > 50000) {
      _alertsController.add(SalesAlert(
        type: SalesAlertType.highValueOrder,
        message: 'High-value order detected: NPR ${sale.finalAmount.toStringAsFixed(2)}',
        orderId: sale.orderId,
        retailerId: sale.retailerId,
        value: sale.finalAmount,
        timestamp: DateTime.now(),
      ));
    }

    // Check for bulk orders
    final totalQuantity = sale.items.fold<int>(0, (sum, item) => sum + item.quantity);
    if (totalQuantity > 1000) {
      _alertsController.add(SalesAlert(
        type: SalesAlertType.bulkOrder,
        message: 'Bulk order detected: $totalQuantity units',
        orderId: sale.orderId,
        retailerId: sale.retailerId,
        value: totalQuantity.toDouble(),
        timestamp: DateTime.now(),
      ));
    }

    // Check for new customer
    if (sale.retailerId.startsWith('NEW-')) {
      _alertsController.add(SalesAlert(
        type: SalesAlertType.newCustomer,
        message: 'New customer order from ${sale.retailerName}',
        orderId: sale.orderId,
        retailerId: sale.retailerId,
        value: sale.finalAmount,
        timestamp: DateTime.now(),
      ));
    }
  }

  void _updateMetrics() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final weekAgo = today.subtract(const Duration(days: 7));
    final monthAgo = today.subtract(const Duration(days: 30));

    // Calculate metrics
    final todaySales = _sales.where((s) => s.date.isAfter(today)).toList();
    final yesterdaySales = _sales.where((s) => s.date.isAfter(yesterday) && s.date.isBefore(today)).toList();
    final weekSales = _sales.where((s) => s.date.isAfter(weekAgo)).toList();
    final monthSales = _sales.where((s) => s.date.isAfter(monthAgo)).toList();

    final todayRevenue = todaySales.fold<double>(0.0, (sum, s) => sum + s.finalAmount);
    final yesterdayRevenue = yesterdaySales.fold<double>(0.0, (sum, s) => sum + s.finalAmount);
    final weekRevenue = weekSales.fold<double>(0.0, (sum, s) => sum + s.finalAmount);
    final monthRevenue = monthSales.fold<double>(0.0, (sum, s) => sum + s.finalAmount);

    final todayOrders = todaySales.length;
    final yesterdayOrders = yesterdaySales.length;
    final weekOrders = weekSales.length;
    final monthOrders = monthSales.length;

    final todayAvgOrderValue = todayOrders > 0 ? todayRevenue / todayOrders : 0.0;
    final monthAvgOrderValue = monthOrders > 0 ? monthRevenue / monthOrders : 0.0;

    // Calculate growth rates
    final dailyGrowth = yesterdayOrders > 0 ? ((todayOrders - yesterdayOrders) / yesterdayOrders) * 100 : 0.0;
    final revenueGrowth = yesterdayRevenue > 0 ? ((todayRevenue - yesterdayRevenue) / yesterdayRevenue) * 100 : 0.0;

    // Get top selling products
    final productSales = <String, int>{};
    for (final sale in weekSales) {
      for (final item in sale.items) {
        productSales[item.productName] = (productSales[item.productName] ?? 0) + item.quantity;
      }
    }

    final topProducts = productSales.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topSellingProducts = topProducts.take(5).map((e) => {
        'product': e.key,
        'quantity': e.value,
      }).toList();

    // Get top retailers
    final retailerSales = <String, double>{};
    for (final sale in weekSales) {
      retailerSales[sale.retailerName] = (retailerSales[sale.retailerName] ?? 0.0) + sale.finalAmount;
    }

    final topRetailers = retailerSales.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topRetailersList = topRetailers.take(5).map((e) => {
        'retailer': e.key,
        'revenue': e.value,
      }).toList();

    _metrics = RealtimeSalesMetrics(
      todayRevenue: todayRevenue,
      yesterdayRevenue: yesterdayRevenue,
      weekRevenue: weekRevenue,
      monthRevenue: monthRevenue,
      todayOrders: todayOrders,
      yesterdayOrders: yesterdayOrders,
      weekOrders: weekOrders,
      monthOrders: monthOrders,
      todayAvgOrderValue: todayAvgOrderValue,
      monthAvgOrderValue: monthAvgOrderValue,
      dailyGrowth: dailyGrowth,
      revenueGrowth: revenueGrowth,
      topSellingProducts: topSellingProducts,
      topRetailers: topRetailersList,
      conversionRate: _calculateConversionRate(),
      activeCustomers: _getActiveCustomers(weekSales),
      lastUpdated: DateTime.now(),
    );

    _metricsController.add(_metrics);
  }

  double _calculateConversionRate() {
    // Simplified conversion rate calculation
    // In production, this would track leads/opportunities vs conversions
    final totalOrders = _sales.length;
    final completedOrders = _sales.where((s) => s.status == SalesStatus.completed).length;
    return totalOrders > 0 ? (completedOrders / totalOrders) * 100 : 0.0;
  }

  int _getActiveCustomers(List<SalesRecord> sales) {
    final uniqueRetailers = sales.map((s) => s.retailerId).toSet();
    return uniqueRetailers.length;
  }

  /// Record a new sale in real-time
  Future<bool> recordSale(SalesRecord sale) async {
    try {
      final response = await _dio.post(
        '/api/sales/record',
        data: sale.toJson(),
      );

      if (response.statusCode == 201) {
        _sales.insert(0, sale);
        _liveTransactions.add(LiveTransaction.fromSalesRecord(sale));
        _checkForAlerts(sale);
        _updateMetrics();
        return true;
      }
    } catch (e) {
      debugPrint('Error recording sale: $e');
    }
    return false;
  }

  /// Get sales by time period
  List<SalesRecord> getSalesByPeriod(TimePeriod period) {
    final now = DateTime.now();
    DateTime startDate;

    switch (period) {
      case TimePeriod.today:
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case TimePeriod.yesterday:
        startDate = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 1));
        break;
      case TimePeriod.week:
        startDate = now.subtract(const Duration(days: 7));
        break;
      case TimePeriod.month:
        startDate = now.subtract(const Duration(days: 30));
        break;
      case TimePeriod.quarter:
        startDate = now.subtract(const Duration(days: 90));
        break;
      case TimePeriod.year:
        startDate = now.subtract(const Duration(days: 365));
        break;
    }

    return _sales.where((s) => s.date.isAfter(startDate)).toList();
  }

  /// Get sales by status
  List<SalesRecord> getSalesByStatus(SalesStatus status) {
    return _sales.where((s) => s.status == status).toList();
  }

  /// Get sales by retailer
  List<SalesRecord> getSalesByRetailer(String retailerId) {
    return _sales.where((s) => s.retailerId == retailerId).toList();
  }

  /// Get sales by product
  List<SalesRecord> getSalesByProduct(String sku) {
    return _sales.where((s) => s.items.any((item) => item.sku == sku)).toList();
  }

  /// Get sales analytics for marketing
  Map<String, dynamic> getSalesAnalyticsForMarketing() {
    final weekSales = getSalesByPeriod(TimePeriod.week);
    final monthSales = getSalesByPeriod(TimePeriod.month);

    // Product category breakdown
    final categorySales = <String, double>{};
    for (final sale in weekSales) {
      for (final item in sale.items) {
        // In production, this would map SKU to category
        final category = 'General'; // Simplified
        categorySales[category] = (categorySales[category] ?? 0.0) + item.totalPrice;
      }
    }

    // Geographic distribution
    final locationSales = <String, int>{};
    for (final sale in weekSales) {
      locationSales[sale.retailerLocation] = (locationSales[sale.retailerLocation] ?? 0) + 1;
    }

    // Peak sales hours
    final hourlySales = <int, int>{};
    for (final sale in weekSales) {
      final hour = sale.date.hour;
      hourlySales[hour] = (hourlySales[hour] ?? 0) + 1;
    }

    return {
      'total_revenue_week': weekSales.fold<double>(0.0, (sum, s) => sum + s.finalAmount),
      'total_revenue_month': monthSales.fold<double>(0.0, (sum, s) => sum + s.finalAmount),
      'total_orders_week': weekSales.length,
      'total_orders_month': monthSales.length,
      'category_breakdown': categorySales,
      'geographic_distribution': locationSales,
      'peak_sales_hours': hourlySales,
      'average_order_value': _metrics.todayAvgOrderValue,
      'conversion_rate': _metrics.conversionRate,
      'growth_rate': _metrics.dailyGrowth,
    };
  }

  void dispose() {
    _realtimeTimer?.cancel();
    _salesStreamController.close();
    _metricsController.close();
    _liveTransactionsController.close();
    _alertsController.close();
  }
}

// Time Period Enum
enum TimePeriod {
  today,
  yesterday,
  week,
  month,
  quarter,
  year,
}

// Real-Time Sales Metrics
class RealtimeSalesMetrics {
  final double todayRevenue;
  final double yesterdayRevenue;
  final double weekRevenue;
  final double monthRevenue;
  final int todayOrders;
  final int yesterdayOrders;
  final int weekOrders;
  final int monthOrders;
  final double todayAvgOrderValue;
  final double monthAvgOrderValue;
  final double dailyGrowth;
  final double revenueGrowth;
  final List<Map<String, dynamic>> topSellingProducts;
  final List<Map<String, dynamic>> topRetailers;
  final double conversionRate;
  final int activeCustomers;
  final DateTime lastUpdated;

  const RealtimeSalesMetrics({
    this.todayRevenue = 0.0,
    this.yesterdayRevenue = 0.0,
    this.weekRevenue = 0.0,
    this.monthRevenue = 0.0,
    this.todayOrders = 0,
    this.yesterdayOrders = 0,
    this.weekOrders = 0,
    this.monthOrders = 0,
    this.todayAvgOrderValue = 0.0,
    this.monthAvgOrderValue = 0.0,
    this.dailyGrowth = 0.0,
    this.revenueGrowth = 0.0,
    this.topSellingProducts = const [],
    this.topRetailers = const [],
    this.conversionRate = 0.0,
    this.activeCustomers = 0,
    required this.lastUpdated,
  });
}

// Live Transaction Model
class LiveTransaction {
  final String orderId;
  final String retailerName;
  final String retailerLocation;
  final double totalAmount;
  final int totalItems;
  final DateTime timestamp;
  final TransactionStatus status;
  final List<String> productNames;

  const LiveTransaction({
    required this.orderId,
    required this.retailerName,
    required this.retailerLocation,
    required this.totalAmount,
    required this.totalItems,
    required this.timestamp,
    required this.status,
    required this.productNames,
  });

  factory LiveTransaction.fromSalesRecord(SalesRecord sale) {
    return LiveTransaction(
      orderId: sale.orderId,
      retailerName: sale.retailerName,
      retailerLocation: sale.retailerLocation,
      totalAmount: sale.finalAmount,
      totalItems: sale.items.fold<int>(0, (sum, item) => sum + item.quantity),
      timestamp: sale.date,
      status: _mapSalesStatusToTransactionStatus(sale.status),
      productNames: sale.items.map((item) => item.productName).toList(),
    );
  }

  static TransactionStatus _mapSalesStatusToTransactionStatus(SalesStatus status) {
    switch (status) {
      case SalesStatus.pending:
        return TransactionStatus.pending;
      case SalesStatus.processing:
        return TransactionStatus.processing;
      case SalesStatus.completed:
        return TransactionStatus.completed;
      case SalesStatus.cancelled:
        return TransactionStatus.cancelled;
      default:
        return TransactionStatus.pending;
    }
  }
}

// Transaction Status Enum
enum TransactionStatus {
  pending,
  processing,
  completed,
  cancelled,
}

// Sales Alert Model
class SalesAlert {
  final SalesAlertType type;
  final String message;
  final String orderId;
  final String retailerId;
  final double value;
  final DateTime timestamp;

  const SalesAlert({
    required this.type,
    required this.message,
    required this.orderId,
    required this.retailerId,
    required this.value,
    required this.timestamp,
  });
}

// Sales Alert Type Enum
enum SalesAlertType {
  highValueOrder,
  bulkOrder,
  newCustomer,
  lowStock,
  paymentFailed,
}
