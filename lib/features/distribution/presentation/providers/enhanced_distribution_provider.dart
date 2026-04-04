import 'package:flutter/foundation.dart';
import '../../domain/models/distribution_models.dart';
import '../../domain/models/sales_tracking_models.dart';
import '../../data/services/distribution_service.dart';
import '../../data/services/sales_tracking_service.dart';

class EnhancedDistributionProvider extends ChangeNotifier {
  final DistributionService _distributionService;
  final SalesTrackingService _salesTrackingService;

  EnhancedDistributionProvider({
    required DistributionService distributionService,
    required SalesTrackingService salesTrackingService,
  }) : _distributionService = distributionService,
       _salesTrackingService = salesTrackingService;

  // Distribution Centers
  List<DistributionCenter> _distributionCenters = [];
  bool _isLoadingCenters = false;
  String? _centersError;

  // Inventory Allocations
  List<InventoryAllocation> _inventoryAllocations = [];
  bool _isLoadingInventory = false;
  String? _inventoryError;

  // Sales Transactions
  List<SalesTransaction> _salesTransactions = [];
  bool _isLoadingTransactions = false;
  String? _transactionsError;

  // Sales Analytics
  SalesAnalytics? _salesAnalytics;
  bool _isLoadingAnalytics = false;
  String? _analyticsError;

  // Top Performers
  List<TopProduct> _topProducts = [];
  List<TopDistributor> _topDistributors = [];
  bool _isLoadingTopPerformers = false;
  String? _topPerformersError;

  // Sales Forecasts
  List<SalesForecast> _salesForecasts = [];
  bool _isLoadingForecasts = false;
  String? _forecastsError;

  // Performance Metrics
  Map<String, dynamic> _performanceMetrics = {};
  bool _isLoadingPerformance = false;
  String? _performanceError;

  // Getters
  List<DistributionCenter> get distributionCenters => _distributionCenters;
  bool get isLoadingCenters => _isLoadingCenters;
  String? get centersError => _centersError;

  List<InventoryAllocation> get inventoryAllocations => _inventoryAllocations;
  bool get isLoadingInventory => _isLoadingInventory;
  String? get inventoryError => _inventoryError;

  List<SalesTransaction> get salesTransactions => _salesTransactions;
  bool get isLoadingTransactions => _isLoadingTransactions;
  String? get transactionsError => _transactionsError;

  SalesAnalytics? get salesAnalytics => _salesAnalytics;
  bool get isLoadingAnalytics => _isLoadingAnalytics;
  String? get analyticsError => _analyticsError;

  List<TopProduct> get topProducts => _topProducts;
  List<TopDistributor> get topDistributors => _topDistributors;
  bool get isLoadingTopPerformers => _isLoadingTopPerformers;
  String? get topPerformersError => _topPerformersError;

  List<SalesForecast> get salesForecasts => _salesForecasts;
  bool get isLoadingForecasts => _isLoadingForecasts;
  String? get forecastsError => _forecastsError;

  Map<String, dynamic> get performanceMetrics => _performanceMetrics;
  bool get isLoadingPerformance => _isLoadingPerformance;
  String? get performanceError => _performanceError;

  // Load distribution centers
  Future<void> loadDistributionCenters() async {
    _isLoadingCenters = true;
    _centersError = null;
    notifyListeners();

    try {
      final result = await _distributionService.getDistributionCenters();
      
      if (result['success'] == true) {
        _distributionCenters = result['centers'] as List<DistributionCenter>;
      } else {
        _centersError = result['message'] ?? 'Failed to load distribution centers';
      }
    } catch (e) {
      _centersError = 'Error loading distribution centers: ${e.toString()}';
    } finally {
      _isLoadingCenters = false;
      notifyListeners();
    }
  }

  // Load inventory allocations
  Future<void> loadInventoryAllocations({int? centerId}) async {
    _isLoadingInventory = true;
    _inventoryError = null;
    notifyListeners();

    try {
      final result = await _distributionService.getInventoryAllocations(centerId: centerId);
      
      if (result['success'] == true) {
        _inventoryAllocations = result['allocations'] as List<InventoryAllocation>;
      } else {
        _inventoryError = result['message'] ?? 'Failed to load inventory allocations';
      }
    } catch (e) {
      _inventoryError = 'Error loading inventory allocations: ${e.toString()}';
    } finally {
      _isLoadingInventory = false;
      notifyListeners();
    }
  }

  // Load sales transactions
  Future<void> loadSalesTransactions({
    String? distributorId,
    String? retailerId,
    String? productId,
    String? region,
    DateTime? startDate,
    DateTime? endDate,
    String? campaignId,
  }) async {
    _isLoadingTransactions = true;
    _transactionsError = null;
    notifyListeners();

    try {
      final result = await _salesTrackingService.getSalesTransactions(
        distributorId: distributorId,
        retailerId: retailerId,
        productId: productId,
        region: region,
        startDate: startDate,
        endDate: endDate,
        campaignId: campaignId,
      );
      
      if (result['success'] == true) {
        _salesTransactions = result['transactions'] as List<SalesTransaction>;
      } else {
        _transactionsError = result['message'] ?? 'Failed to load sales transactions';
      }
    } catch (e) {
      _transactionsError = 'Error loading sales transactions: ${e.toString()}';
    } finally {
      _isLoadingTransactions = false;
      notifyListeners();
    }
  }

  // Load sales analytics
  Future<void> loadSalesAnalytics({
    required String period,
    DateTime? startDate,
    DateTime? endDate,
    String? region,
    String? distributorId,
    String? productId,
  }) async {
    _isLoadingAnalytics = true;
    _analyticsError = null;
    notifyListeners();

    try {
      final result = await _salesTrackingService.getSalesAnalytics(
        period: period,
        startDate: startDate,
        endDate: endDate,
        region: region,
        distributorId: distributorId,
        productId: productId,
      );
      
      if (result['success'] == true) {
        _salesAnalytics = result['analytics'] as SalesAnalytics;
      } else {
        _analyticsError = result['message'] ?? 'Failed to load sales analytics';
      }
    } catch (e) {
      _analyticsError = 'Error loading sales analytics: ${e.toString()}';
    } finally {
      _isLoadingAnalytics = false;
      notifyListeners();
    }
  }

  // Load top performers
  Future<void> loadTopPerformers({
    required String period,
    String? region,
    String? distributorId,
  }) async {
    _isLoadingTopPerformers = true;
    _topPerformersError = null;
    notifyListeners();

    try {
      // Load top products
      final productsResult = await _salesTrackingService.getTopPerformingProducts(
        period: period,
        region: region,
        distributorId: distributorId,
      );
      
      // Load top distributors
      final distributorsResult = await _salesTrackingService.getTopPerformingDistributors(
        period: period,
        region: region,
      );
      
      if (productsResult['success'] == true) {
        _topProducts = productsResult['products'] as List<TopProduct>;
      } else {
        _topPerformersError = productsResult['message'] ?? 'Failed to load top performers';
      }
      
      if (distributorsResult['success'] == true) {
        _topDistributors = distributorsResult['distributors'] as List<TopDistributor>;
      }
    } catch (e) {
      _topPerformersError = 'Error loading top performers: ${e.toString()}';
    } finally {
      _isLoadingTopPerformers = false;
      notifyListeners();
    }
  }

  // Generate sales forecast
  Future<void> generateSalesForecast({
    required String productId,
    required String region,
    required DateTime forecastDate,
  }) async {
    _isLoadingForecasts = true;
    _forecastsError = null;
    notifyListeners();

    try {
      final result = await _salesTrackingService.generateSalesForecast(
        productId: productId,
        region: region,
        forecastDate: forecastDate,
      );
      
      if (result['success'] == true) {
        final forecast = result['forecast'] as SalesForecast;
        _salesForecasts.add(forecast);
      } else {
        _forecastsError = result['message'] ?? 'Failed to generate sales forecast';
      }
    } catch (e) {
      _forecastsError = 'Error generating sales forecast: ${e.toString()}';
    } finally {
      _isLoadingForecasts = false;
      notifyListeners();
    }
  }

  // Load performance metrics
  Future<void> loadPerformanceMetrics({
    String? distributorId,
    String? region,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    _isLoadingPerformance = true;
    _performanceError = null;
    notifyListeners();

    try {
      final result = await _salesTrackingService.getSalesPerformanceMetrics(
        distributorId: distributorId,
        region: region,
        startDate: startDate,
        endDate: endDate,
      );
      
      if (result['success'] == true) {
        _performanceMetrics = result['metrics'] as Map<String, dynamic>;
      } else {
        _performanceError = result['message'] ?? 'Failed to load performance metrics';
      }
    } catch (e) {
      _performanceError = 'Error loading performance metrics: ${e.toString()}';
    } finally {
      _isLoadingPerformance = false;
      notifyListeners();
    }
  }

  // Record sales transaction
  Future<bool> recordSalesTransaction(SalesTransaction transaction) async {
    try {
      final result = await _salesTrackingService.recordSalesTransaction(transaction);
      
      if (result['success'] == true) {
        _salesTransactions.insert(0, transaction);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error recording sales transaction: ${e.toString()}');
      return false;
    }
  }

  // Add distribution center
  Future<bool> addDistributionCenter(DistributionCenter center) async {
    try {
      final result = await _distributionService.addDistributionCenter(center);
      
      if (result['success'] == true) {
        _distributionCenters.add(center);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error adding distribution center: ${e.toString()}');
      return false;
    }
  }

  // Update inventory allocation
  Future<bool> updateInventoryAllocation(
    int allocationId,
    Map<String, dynamic> updates,
  ) async {
    try {
      final result = await _distributionService.updateInventoryAllocation(
        allocationId,
        updates,
      );
      
      if (result['success'] == true) {
        // Update local allocation
        final index = _inventoryAllocations.indexWhere((a) => a.id == allocationId);
        if (index != -1) {
          // Update the allocation with new data
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error updating inventory allocation: ${e.toString()}');
      return false;
    }
  }

  // Get distribution center by ID
  DistributionCenter? getDistributionCenterById(int id) {
    try {
      return _distributionCenters.firstWhere((center) => center.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get inventory by center
  List<InventoryAllocation> getInventoryByCenter(int centerId) {
    return _inventoryAllocations
        .where((allocation) => allocation.centerId == centerId)
        .toList();
  }

  // Get sales by period
  List<SalesTransaction> getSalesByPeriod(DateTime startDate, DateTime endDate) {
    return _salesTransactions
        .where((transaction) =>
            transaction.transactionDate.isAfter(startDate) &&
            transaction.transactionDate.isBefore(endDate))
        .toList();
  }

  // Get total revenue
  double getTotalRevenue({DateTime? startDate, DateTime? endDate}) {
    var transactions = _salesTransactions;
    
    if (startDate != null && endDate != null) {
      transactions = getSalesByPeriod(startDate, endDate);
    }
    
    return transactions.fold(0.0, (sum, transaction) => sum + transaction.finalAmount);
  }

  // Get total units sold
  int getTotalUnitsSold({DateTime? startDate, DateTime? endDate}) {
    var transactions = _salesTransactions;
    
    if (startDate != null && endDate != null) {
      transactions = getSalesByPeriod(startDate, endDate);
    }
    
    return transactions.fold(0, (sum, transaction) => sum + transaction.quantity);
  }

  // Clear errors
  void clearErrors() {
    _centersError = null;
    _inventoryError = null;
    _transactionsError = null;
    _analyticsError = null;
    _topPerformersError = null;
    _forecastsError = null;
    _performanceError = null;
    notifyListeners();
  }

  // Refresh all data
  Future<void> refreshAllData() async {
    await Future.wait([
      loadDistributionCenters(),
      loadInventoryAllocations(),
      loadSalesTransactions(),
      loadSalesAnalytics(period: 'monthly'),
      loadTopPerformers(period: 'monthly'),
      loadPerformanceMetrics(),
    ]);
  }
}
