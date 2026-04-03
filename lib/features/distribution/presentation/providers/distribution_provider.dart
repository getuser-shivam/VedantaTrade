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
