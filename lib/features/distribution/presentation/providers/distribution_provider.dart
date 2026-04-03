import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/services/distribution_service.dart';
import '../widgets/distribution_center_card.dart';
import '../widgets/inventory_allocation_card.dart';

class DistributionProvider extends ChangeNotifier {
  final DistributionService _distributionService;
  
  List<DistributionCenter> _centers = [];
  List<InventoryAllocation> _inventoryAllocations = [];
  List<DistributionRoute> _routes = [];
  bool _isLoading = false;
  String? _error;
  bool _hasError = false;
  String? _errorMessage;
  
  // Dashboard stats
  int _totalCenters = 0;
  int _activeInventory = 0;
  int _activeCampaigns = 0;
  double _totalRevenue = 0.0;
  
  // Sales & Marketing
  List<Map<String, dynamic>> _sales = [];
  List<Map<String, dynamic>> _campaigns = [];
  Map<String, dynamic> _salesAnalytics = {};
  double _todaySales = 0.0;
  int _weeklyOrders = 0;
  
  // Pagination
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalItems = 0;
  final int _itemsPerPage = 20;

  DistributionProvider(this._distributionService);

  // Getters
  List<DistributionCenter> get centers => _centers;
  List<InventoryAllocation> get inventoryAllocations => _inventoryAllocations;
  List<DistributionRoute> get routes => _routes;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasError => _hasError;
  String? get errorMessage => _errorMessage;
  
  // Dashboard stats getters
  int get totalCenters => _totalCenters;
  int get activeInventory => _activeInventory;
  int get activeCampaigns => _activeCampaigns;
  double get totalRevenue => _totalRevenue;
  double get todaySales => _todaySales;
  int get weeklyOrders => _weeklyOrders;
  
  // Sales & Marketing getters
  List<Map<String, dynamic>> get sales => _sales;
  List<Map<String, dynamic>> get campaigns => _campaigns;
  Map<String, dynamic> get salesAnalytics => _salesAnalytics;
  
  // Pagination getters
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get totalItems => _totalItems;
  bool get hasNextPage => _currentPage < _totalPages;
  bool get hasPreviousPage => _currentPage > 1;

  // Load distribution centers
  Future<void> loadDistributionCenters({int page = 1, String search = '', String category = 'All'}) async {
    _setLoading(true);
    _error = null;

    try {
      final response = await _distributionService.getDistributionCenters(
        page: page,
        limit: _itemsPerPage,
        search: search,
        category: category,
      );

      if (response['success'] == true) {
        final data = response['data'];
        final pagination = response['pagination'];
        
        _centers = (data['centers'] as List<dynamic>)
            .map((center) => DistributionCenter.fromJson(center))
            .toList();
        
        _currentPage = pagination['page'] ?? page;
        _totalPages = pagination['pages'] ?? 1;
        _totalItems = pagination['total'] ?? 0;
      } else {
        _error = response['message'] ?? 'Failed to load distribution centers';
      }
    } catch (e) {
      _error = 'Failed to load distribution centers: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  // Load inventory allocations for a center
  Future<void> loadInventoryAllocations(int centerId, {int page = 1, String search = ''}) async {
    _setLoading(true);
    _error = null;

    try {
      final response = await _distributionService.getInventoryAllocations(
        centerId: centerId,
        page: page,
        limit: _itemsPerPage,
        search: search,
      );

      if (response['success'] == true) {
        final data = response['data'];
        final pagination = response['pagination'];
        
        _inventoryAllocations = (data['allocations'] as List<dynamic>)
            .map((allocation) => InventoryAllocation.fromJson(allocation))
            .toList();
        
        _currentPage = pagination['page'] ?? page;
        _totalPages = pagination['pages'] ?? 1;
        _totalItems = pagination['total'] ?? 0;
      } else {
        _error = response['message'] ?? 'Failed to load inventory allocations';
      }
    } catch (e) {
      _error = 'Failed to load inventory allocations: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  // Load distribution routes
  Future<void> loadDistributionRoutes({int page = 1, int? centerId}) async {
    _setLoading(true);
    _error = null;

    try {
      final response = await _distributionService.getDistributionRoutes(
        page: page,
        limit: _itemsPerPage,
        centerId: centerId,
      );

      if (response['success'] == true) {
        final data = response['data'];
        final pagination = response['pagination'];
        
        _routes = (data['routes'] as List<dynamic>)
            .map((route) => DistributionRoute.fromJson(route))
            .toList();
        
        _currentPage = pagination['page'] ?? page;
        _totalPages = pagination['pages'] ?? 1;
        _totalItems = pagination['total'] ?? 0;
      } else {
        _error = response['message'] ?? 'Failed to load distribution routes';
      }
    } catch (e) {
      _error = 'Failed to load distribution routes: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  // Create new distribution center
  Future<bool> createDistributionCenter(Map<String, dynamic> centerData) async {
    _setLoading(true);
    _error = null;

    try {
      final response = await _distributionService.createDistributionCenter(centerData);
      
      if (response['success'] == true) {
        final newCenter = DistributionCenter.fromJson(response['data']);
        _centers.insert(0, newCenter);
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Failed to create distribution center';
        return false;
      }
    } catch (e) {
      _error = 'Failed to create distribution center: ${e.toString()}';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Allocate inventory
  Future<bool> allocateInventory(Map<String, dynamic> allocationData) async {
    _setLoading(true);
    _error = null;

    try {
      final response = await _distributionService.allocateInventory(allocationData);
      
      if (response['success'] == true) {
        final newAllocation = InventoryAllocation.fromJson(response['data']);
        _inventoryAllocations.insert(0, newAllocation);
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Failed to allocate inventory';
        return false;
      }
    } catch (e) {
      _error = 'Failed to allocate inventory: ${e.toString()}';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Create new distribution route
  Future<bool> createDistributionRoute(Map<String, dynamic> routeData) async {
    _setLoading(true);
    _error = null;

    try {
      final response = await _distributionService.createDistributionRoute(routeData);
      
      if (response['success'] == true) {
        final newRoute = DistributionRoute.fromJson(response['data']);
        _routes.insert(0, newRoute);
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Failed to create distribution route';
        return false;
      }
    } catch (e) {
      _error = 'Failed to create distribution route: ${e.toString()}';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Load next page
  Future<void> loadNextPage() async {
    if (hasNextPage) {
      await loadDistributionCenters(page: _currentPage + 1);
    }
  }

  // Load previous page
  Future<void> loadPreviousPage() async {
    if (hasPreviousPage) {
      await loadDistributionCenters(page: _currentPage - 1);
    }
  }

  // Refresh data
  Future<void> refresh() async {
    _currentPage = 1;
    await loadDistributionCenters();
  }

  // Clear error
  void clearError() {
    _error = null;
    _hasError = false;
    _errorMessage = null;
    notifyListeners();
  }

  // Load dashboard data
  Future<void> loadDashboardData() async {
    _setLoading(true);
    _hasError = false;
    _errorMessage = null;
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      
      // Update mock data
      _totalCenters = 12;
      _activeInventory = 3450;
      _activeCampaigns = 8;
      _totalRevenue = 125000.50;
      
      _hasError = false;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _hasError = true;
      _errorMessage = 'Failed to load dashboard data: ${e.toString()}';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Refresh dashboard data
  Future<void> refreshData() async {
    await loadDashboardData();
  }

  // ============================================
  // SALES TRACKING & MARKETING MANAGEMENT
  // ============================================

  // Load sales data with optional filters
  Future<void> loadSales({
    DateTime? startDate,
    DateTime? endDate,
    int? centerId,
    int? productId,
    int? campaignId,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      final response = await _distributionService.getSalesAnalytics(
        startDate: startDate,
        endDate: endDate,
        centerId: centerId,
        productId: productId,
        campaignId: campaignId,
      );

      if (response['success'] == true) {
        _sales = (response['data']['sales'] as List<dynamic>?)
                ?.cast<Map<String, dynamic>>() ??
            [];
        _salesAnalytics = response['data']['analytics'] ?? {};
        _todaySales = response['data']['today_sales']?.toDouble() ?? 0.0;
        _weeklyOrders = response['data']['weekly_orders'] ?? 0;
      } else {
        _error = response['message'] ?? 'Failed to load sales data';
      }
    } catch (e) {
      _error = 'Failed to load sales: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  // Record a new sale
  Future<bool> recordSale({
    required int productId,
    required int centerId,
    required int quantity,
    required double unitPrice,
    double? discount,
    int? campaignId,
    String? customerId,
    String? notes,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      final response = await _distributionService.recordSale(
        productId: productId,
        centerId: centerId,
        quantity: quantity,
        unitPrice: unitPrice,
        discount: discount,
        campaignId: campaignId,
        customerId: customerId,
        notes: notes,
      );

      if (response['success'] == true) {
        // Refresh sales data after recording
        await loadSales();
        return true;
      } else {
        _error = response['message'] ?? 'Failed to record sale';
        return false;
      }
    } catch (e) {
      _error = 'Failed to record sale: ${e.toString()}';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Load marketing campaigns
  Future<void> loadMarketingCampaigns({
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      final response = await _distributionService.getMarketingCampaigns(
        status: status,
        startDate: startDate,
        endDate: endDate,
        page: page,
        limit: _itemsPerPage,
      );

      if (response['success'] == true) {
        _campaigns = (response['data']['campaigns'] as List<dynamic>?)
                ?.cast<Map<String, dynamic>>() ??
            [];
        final pagination = response['pagination'] ?? {};
        _currentPage = pagination['page'] ?? page;
        _totalPages = pagination['pages'] ?? 1;
        _totalItems = pagination['total'] ?? 0;
      } else {
        _error = response['message'] ?? 'Failed to load campaigns';
      }
    } catch (e) {
      _error = 'Failed to load campaigns: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  // Create new marketing campaign
  Future<bool> createMarketingCampaign({
    required String name,
    String? description,
    required DateTime startDate,
    DateTime? endDate,
    double budget = 0,
    String? targetAudience,
    required int createdBy,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      final response = await _distributionService.createMarketingCampaign(
        name: name,
        description: description,
        startDate: startDate,
        endDate: endDate,
        budget: budget,
        targetAudience: targetAudience,
        createdBy: createdBy,
      );

      if (response['success'] == true) {
        await loadMarketingCampaigns();
        return true;
      } else {
        _error = response['message'] ?? 'Failed to create campaign';
        return false;
      }
    } catch (e) {
      _error = 'Failed to create campaign: ${e.toString()}';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Add product to campaign
  Future<bool> addProductToCampaign({
    required int campaignId,
    required int productId,
    double discountPercentage = 0,
    double? specialPrice,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      final response = await _distributionService.addProductToCampaign(
        campaignId: campaignId,
        productId: productId,
        discountPercentage: discountPercentage,
        specialPrice: specialPrice,
        startDate: startDate,
        endDate: endDate,
      );

      if (response['success'] == true) {
        return true;
      } else {
        _error = response['message'] ?? 'Failed to add product to campaign';
        return false;
      }
    } catch (e) {
      _error = 'Failed to add product: ${e.toString()}';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Transfer inventory between centers
  Future<bool> transferInventory({
    required int productId,
    required int fromCenterId,
    required int toCenterId,
    required int quantity,
    String? notes,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      final response = await _distributionService.transferInventory(
        productId: productId,
        fromCenterId: fromCenterId,
        toCenterId: toCenterId,
        quantity: quantity,
        notes: notes,
      );

      if (response['success'] == true) {
        // Refresh inventory data
        if (_inventoryAllocations.isNotEmpty) {
          await loadInventoryAllocations(fromCenterId);
        }
        return true;
      } else {
        _error = response['message'] ?? 'Failed to transfer inventory';
        return false;
      }
    } catch (e) {
      _error = 'Failed to transfer: ${e.toString()}';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get campaign metrics
  Future<Map<String, dynamic>?> getCampaignMetrics({
    required int campaignId,
    String? metricType,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final response = await _distributionService.getCampaignMetrics(
        campaignId: campaignId,
        metricType: metricType,
        startDate: startDate,
        endDate: endDate,
      );

      if (response['success'] == true) {
        return response['data'];
      } else {
        _error = response['message'] ?? 'Failed to load metrics';
        return null;
      }
    } catch (e) {
      _error = 'Failed to load metrics: ${e.toString()}';
      return null;
    }
  }

  // Record campaign metric
  Future<bool> recordCampaignMetric({
    required int campaignId,
    required String metricType,
    required double metricValue,
  }) async {
    try {
      final response = await _distributionService.recordCampaignMetric(
        campaignId: campaignId,
        metricType: metricType,
        metricValue: metricValue,
      );

      return response['success'] == true;
    } catch (e) {
      _error = 'Failed to record metric: ${e.toString()}';
      return false;
    }
  }

  // Refresh all distribution data
  Future<void> refreshAllData() async {
    await Future.wait([
      loadDashboardData(),
      loadDistributionCenters(),
      loadMarketingCampaigns(),
      loadSales(),
    ]);
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _resetPagination() {
    _currentPage = 1;
    _totalPages = 1;
    _totalItems = 0;
  }
}
