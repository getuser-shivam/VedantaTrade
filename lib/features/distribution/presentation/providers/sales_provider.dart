import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../../data/models/sales_model.dart';
import '../../data/models/inventory_model.dart';
import '../../data/services/sales_service.dart';

class SalesProvider extends ChangeNotifier {
  final SalesService _salesService = SalesService();

  // Dashboard metrics
  double _totalRevenue = 0.0;
  int _totalOrders = 0;
  double _averageOrderValue = 0.0;
  int _totalCustomers = 0;
  int _newCustomers = 0;
  int _returningCustomers = 0;
  double _conversionRate = 0.0;
  double _customerRetentionRate = 0.0;
  double _onTimeDeliveryRate = 0.0;
  double _customerSatisfactionScore = 0.0;

  // Change metrics
  double _revenueChange = 0.0;
  double _revenueChangePercentage = 0.0;
  double _ordersChange = 0.0;
  double _ordersChangePercentage = 0.0;
  double _aovChange = 0.0;
  double _aovChangePercentage = 0.0;
  double _customersChange = 0.0;
  double _customersChangePercentage = 0.0;
  double _conversionRateChange = 0.0;
  double _conversionRateChangePercentage = 0.0;
  double _retentionRateChange = 0.0;
  double _retentionRateChangePercentage = 0.0;
  double _deliveryRateChange = 0.0;
  double _deliveryRateChangePercentage = 0.0;
  double _satisfactionChange = 0.0;
  double _satisfactionChangePercentage = 0.0;

  // Data collections
  List<SalesOrder> _recentOrders = [];
  List<SalesOrder> _allOrders = [];
  List<ProductSales> _topSellingProducts = [];
  Map<String, double> _revenueByCategory = {};
  Map<String, double> _revenueByChannel = {};
  Map<String, double> _revenueByRegion = {};
  Map<String, double> _salesByRegionData = {};
  Map<String, double> _revenueByCategoryData = {};
  Map<String, double> _channelPerformanceData = {};
  List<SalesDataPoint> _salesTrendData = [];

  // Loading states
  bool _isLoading = false;
  bool _isRefreshing = false;

  // Getters
  double get totalRevenue => _totalRevenue;
  int get totalOrders => _totalOrders;
  double get averageOrderValue => _averageOrderValue;
  int get totalCustomers => _totalCustomers;
  int get newCustomers => _newCustomers;
  int get returningCustomers => _returningCustomers;
  double get conversionRate => _conversionRate;
  double get customerRetentionRate => _customerRetentionRate;
  double get onTimeDeliveryRate => _onTimeDeliveryRate;
  double get customerSatisfactionScore => _customerSatisfactionScore;

  double get revenueChange => _revenueChange;
  double get revenueChangePercentage => _revenueChangePercentage;
  double get ordersChange => _ordersChange;
  double get ordersChangePercentage => _ordersChangePercentage;
  double get aovChange => _aovChange;
  double get aovChangePercentage => _aovChangePercentage;
  double get customersChange => _customersChange;
  double get customersChangePercentage => _customersChangePercentage;
  double get conversionRateChange => _conversionRateChange;
  double get conversionRateChangePercentage => _conversionRateChangePercentage;
  double get retentionRateChange => _retentionRateChange;
  double get retentionRateChangePercentage => _retentionRateChangePercentage;
  double get deliveryRateChange => _deliveryRateChange;
  double get deliveryRateChangePercentage => _deliveryRateChangePercentage;
  double get satisfactionChange => _satisfactionChange;
  double get satisfactionChangePercentage => _satisfactionChangePercentage;

  List<SalesOrder> get recentOrders => _recentOrders;
  List<SalesOrder> get allOrders => _allOrders;
  List<ProductSales> get topSellingProducts => _topSellingProducts;
  Map<String, double> get revenueByCategory => _revenueByCategory;
  Map<String, double> get revenueByChannel => _revenueByChannel;
  Map<String, double> get revenueByRegion => _revenueByRegion;
  Map<String, double> get salesByRegionData => _salesByRegionData;
  Map<String, double> get revenueByCategoryData => _revenueByCategoryData;
  Map<String, double> get channelPerformanceData => _channelPerformanceData;
  List<SalesDataPoint> get salesTrendData => _salesTrendData;

  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;

  // Initialize dashboard
  Future<void> initializeDashboard({
    String period = 'Today',
    String region = 'All Regions',
    DateTimeRange? dateRange,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _loadDashboardData(period: period, region: region, dateRange: dateRange);
    } catch (e) {
      debugPrint('Error initializing dashboard: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Refresh dashboard
  Future<void> refreshDashboard({
    String period = 'Today',
    String region = 'All Regions',
    DateTimeRange? dateRange,
  }) async {
    _isRefreshing = true;
    notifyListeners();

    try {
      await _loadDashboardData(period: period, region: region, dateRange: dateRange);
    } catch (e) {
      debugPrint('Error refreshing dashboard: $e');
    } finally {
      _isRefreshing = false;
      notifyListeners();
    }
  }

  Future<void> _loadDashboardData({
    String period = 'Today',
    String region = 'All Regions',
    DateTimeRange? dateRange,
  }) async {
    // Load orders
    final orders = await _salesService.getOrders(
      period: period,
      region: region,
      dateRange: dateRange,
    );

    _allOrders = orders;
    _recentOrders = orders.take(10).toList();

    // Calculate basic metrics
    _totalRevenue = orders.fold(0.0, (sum, order) => sum + order.finalAmount);
    _totalOrders = orders.length;
    _averageOrderValue = _totalOrders > 0 ? _totalRevenue / _totalOrders : 0.0;

    // Calculate customer metrics
    final uniqueCustomers = orders.map((order) => order.customerId).toSet();
    _totalCustomers = uniqueCustomers.length;

    // Load analytics
    final analytics = await _salesService.getSalesAnalytics(
      period: period,
      region: region,
      dateRange: dateRange,
    );

    if (analytics != null) {
      _newCustomers = analytics.newCustomers;
      _returningCustomers = analytics.returningCustomers;
      _conversionRate = analytics.conversionRate;
      _customerRetentionRate = analytics.customerRetentionRate;
      _onTimeDeliveryRate = analytics.onTimeDeliveryRate;
      _customerSatisfactionScore = analytics.customerSatisfactionScore;

      _revenueByCategory = analytics.revenueByCategory;
      _revenueByChannel = analytics.revenueByChannel;
      _revenueByRegion = analytics.salesByRegion;

      // Prepare chart data
      _salesByRegionData = Map.from(_revenueByRegion);
      _revenueByCategoryData = Map.from(_revenueByCategory);
      _channelPerformanceData = Map.from(_revenueByChannel);
    }

    // Load top selling products
    _topSellingProducts = await _salesService.getTopSellingProducts(
      period: period,
      region: region,
      limit: 10,
    );

    // Generate sales trend data
    _salesTrendData = _generateSalesTrendData(orders, period);

    // Calculate changes (mock data for now)
    _calculateChanges(period);
  }

  void _calculateChanges(String period) {
    // Mock change calculations - in real app, this would compare with previous period
    final random = DateTime.now().millisecondsSinceEpoch % 100;
    final changeFactor = (random - 50) / 100.0;

    _revenueChange = _totalRevenue * changeFactor * 0.1;
    _revenueChangePercentage = changeFactor * 10;

    _ordersChange = _totalOrders * changeFactor * 0.15;
    _ordersChangePercentage = changeFactor * 15;

    _aovChange = _averageOrderValue * changeFactor * 0.08;
    _aovChangePercentage = changeFactor * 8;

    _customersChange = _totalCustomers * changeFactor * 0.12;
    _customersChangePercentage = changeFactor * 12;

    _conversionRateChange = _conversionRate * changeFactor * 0.05;
    _conversionRateChangePercentage = changeFactor * 5;

    _retentionRateChange = _customerRetentionRate * changeFactor * 0.03;
    _retentionRateChangePercentage = changeFactor * 3;

    _deliveryRateChange = _onTimeDeliveryRate * changeFactor * 0.02;
    _deliveryRateChangePercentage = changeFactor * 2;

    _satisfactionChange = _customerSatisfactionScore * changeFactor * 0.04;
    _satisfactionChangePercentage = changeFactor * 4;
  }

  List<SalesDataPoint> _generateSalesTrendData(List<SalesOrder> orders, String period) {
    final Map<String, double> dailySales = {};

    for (final order in orders) {
      final dateKey = _formatDateKey(order.orderDate, period);
      dailySales[dateKey] = (dailySales[dateKey] ?? 0.0) + order.finalAmount;
    }

    final sortedKeys = dailySales.keys.toList()..sort();
    
    return sortedKeys.map((key) {
      return SalesDataPoint(
        label: key,
        value: dailySales[key] ?? 0.0,
        date: _parseDateKey(key, period),
      );
    }).toList();
  }

  String _formatDateKey(DateTime date, String period) {
    switch (period) {
      case 'Today':
      case 'Yesterday':
        return '${date.hour.toString().padLeft(2, '0')}:00';
      case 'This Week':
      case 'Last Week':
        return '${date.day}/${date.month}';
      case 'This Month':
      case 'Last Month':
        return '${date.day}/${date.month}';
      case 'This Quarter':
      case 'Last Quarter':
        return 'Week ${((date.day - 1) ~/ 7) + 1}';
      case 'This Year':
      case 'Last Year':
        return '${date.month}/${date.year}';
      default:
        return '${date.day}/${date.month}';
    }
  }

  DateTime _parseDateKey(String key, String period) {
    // Simple parsing - in real app, this would be more sophisticated
    final now = DateTime.now();
    return now;
  }

  // Order management
  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await _salesService.updateOrderStatus(orderId, status);
      
      final orderIndex = _allOrders.indexWhere((order) => order.id == orderId);
      if (orderIndex != -1) {
        _allOrders[orderIndex] = _allOrders[orderIndex].copyWith(status: status);
        
        final recentOrderIndex = _recentOrders.indexWhere((order) => order.id == orderId);
        if (recentOrderIndex != -1) {
          _recentOrders[recentOrderIndex] = _recentOrders[recentOrderIndex].copyWith(status: status);
        }
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating order status: $e');
    }
  }

  Future<void> cancelOrder(String orderId, String reason) async {
    try {
      await _salesService.cancelOrder(orderId, reason);
      
      _allOrders.removeWhere((order) => order.id == orderId);
      _recentOrders.removeWhere((order) => order.id == orderId);
      
      // Recalculate metrics
      _totalRevenue = _allOrders.fold(0.0, (sum, order) => sum + order.finalAmount);
      _totalOrders = _allOrders.length;
      _averageOrderValue = _totalOrders > 0 ? _totalRevenue / _totalOrders : 0.0;
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error cancelling order: $e');
    }
  }

  // Export functionality
  Future<void> exportReport(String format) async {
    try {
      await _salesService.exportSalesReport(
        format: format,
        orders: _allOrders,
        metrics: {
          'totalRevenue': _totalRevenue,
          'totalOrders': _totalOrders,
          'averageOrderValue': _averageOrderValue,
          'totalCustomers': _totalCustomers,
          'revenueByCategory': _revenueByCategory,
          'revenueByChannel': _revenueByChannel,
          'topSellingProducts': _topSellingProducts,
        },
      );
    } catch (e) {
      debugPrint('Error exporting report: $e');
    }
  }

  // Search and filter
  List<SalesOrder> searchOrders(String query) {
    if (query.isEmpty) return _allOrders;
    
    return _allOrders.where((order) {
      return order.orderNumber.toLowerCase().contains(query.toLowerCase()) ||
             order.customerName.toLowerCase().contains(query.toLowerCase()) ||
             order.customerEmail.toLowerCase().contains(query.toLowerCase()) ||
             order.items.any((item) => 
                 item.productName.toLowerCase().contains(query.toLowerCase()));
    }).toList();
  }

  List<SalesOrder> filterOrders({
    String? status,
    String? paymentStatus,
    String? channel,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return _allOrders.where((order) {
      if (status != null && order.status != status) return false;
      if (paymentStatus != null && order.paymentStatus != paymentStatus) return false;
      if (channel != null && order.distributionChannel != channel) return false;
      if (startDate != null && order.orderDate.isBefore(startDate)) return false;
      if (endDate != null && order.orderDate.isAfter(endDate)) return false;
      return true;
    }).toList();
  }

  // Get order by ID
  SalesOrder? getOrderById(String orderId) {
    try {
      return _allOrders.firstWhere((order) => order.id == orderId);
    } catch (e) {
      return null;
    }
  }

  // Get order statistics
  Map<String, int> getOrderStatusStats() {
    final stats = <String, int>{};
    for (final order in _allOrders) {
      stats[order.status] = (stats[order.status] ?? 0) + 1;
    }
    return stats;
  }

  Map<String, int> getPaymentStatusStats() {
    final stats = <String, int>{};
    for (final order in _allOrders) {
      stats[order.paymentStatus] = (stats[order.paymentStatus] ?? 0) + 1;
    }
    return stats;
  }

  double getTotalRevenueByStatus(String status) {
    return _allOrders
        .where((order) => order.status == status)
        .fold(0.0, (sum, order) => sum + order.finalAmount);
  }
}

// Supporting classes
class ProductSales {
  final String productId;
  final String productName;
  final String productCategory;
  final int quantitySold;
  final double totalRevenue;
  final double averagePrice;
  final int orderCount;

  ProductSales({
    required this.productId,
    required this.productName,
    required this.productCategory,
    required this.quantitySold,
    required this.totalRevenue,
    required this.averagePrice,
    required this.orderCount,
  });
}

class SalesDataPoint {
  final String label;
  final double value;
  final DateTime date;

  SalesDataPoint({
    required this.label,
    required this.value,
    required this.date,
  });
}
