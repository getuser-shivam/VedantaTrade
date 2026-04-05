import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../domain/repositories/distribution_repository.dart';
import '../../domain/models/distribution_entity.dart';
import '../../domain/models/inventory_entity.dart';
import '../../domain/models/order_entity.dart';
import '../../domain/models/marketing_campaign_entity.dart';
import '../data/repositories/distribution_repository_impl.dart';

class DistributionManagementProvider extends ChangeNotifier {
  final DistributionRepository _repository;
  
  // Distribution state
  List<DistributionEntity> _distributions = [];
  List<DistributionEntity> _filteredDistributions = [];
  bool _isLoadingDistributions = false;
  String? _distributionsError;
  int _distributionsPage = 1;
  int _totalDistributionsPages = 1;
  
  // Inventory state
  List<InventoryEntity> _inventory = [];
  List<InventoryEntity> _filteredInventory = [];
  bool _isLoadingInventory = false;
  String? _inventoryError;
  int _inventoryPage = 1;
  int _totalInventoryPages = 1;
  
  // Orders state
  List<OrderEntity> _orders = [];
  List<OrderEntity> _filteredOrders = [];
  bool _isLoadingOrders = false;
  String? _ordersError;
  int _ordersPage = 1;
  int _totalOrdersPages = 1;
  
  // Campaigns state
  List<MarketingCampaignEntity> _campaigns = [];
  List<MarketingCampaignEntity> _filteredCampaigns = [];
  bool _isLoadingCampaigns = false;
  String? _campaignsError;
  int _campaignsPage = 1;
  int _totalCampaignsPages = 1;
  
  // Analytics state
  Map<String, dynamic> _analytics = {};
  bool _isLoadingAnalytics = false;
  String? _analyticsError;
  
  // Filter state
  String _searchQuery = '';
  String? _selectedWarehouse;
  String? _selectedStatus;
  String? _selectedCarrier;
  DateTime? _startDate;
  DateTime? _endDate;

  DistributionManagementProvider({required DistributionRepository repository})
      : _repository = repository;

  // Getters
  List<DistributionEntity> get distributions => _filteredDistributions;
  List<InventoryEntity> get inventory => _filteredInventory;
  List<OrderEntity> get orders => _filteredOrders;
  List<MarketingCampaignEntity> get campaigns => _filteredCampaigns;
  Map<String, dynamic> get analytics => _analytics;
  
  bool get isLoadingDistributions => _isLoadingDistributions;
  bool get isLoadingInventory => _isLoadingInventory;
  bool get isLoadingOrders => _isLoadingOrders;
  bool get isLoadingCampaigns => _isLoadingCampaigns;
  bool get isLoadingAnalytics => _isLoadingAnalytics;
  
  String? get distributionsError => _distributionsError;
  String? get inventoryError => _inventoryError;
  String? get ordersError => _ordersError;
  String? get campaignsError => _campaignsError;
  String? get analyticsError => _analyticsError;
  
  String get searchQuery => _searchQuery;
  String? get selectedWarehouse => _selectedWarehouse;
  String? get selectedStatus => _selectedStatus;
  String? get selectedCarrier => _selectedCarrier;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  
  // Initialize
  Future<void> initialize() async {
    await Future.wait([
      loadDistributions(),
      loadInventory(),
      loadOrders(),
      loadCampaigns(),
      loadAnalytics(),
    ]);
  }

  // Distribution methods
  Future<void> loadDistributions({bool refresh = false}) async {
    if (refresh) _distributionsPage = 1;
    
    _setDistributionsLoading(true);
    _clearDistributionsError();
    
    try {
      final result = await _repository.getDistributions(
        page: _distributionsPage,
        limit: 20,
      );
      
      if (_distributionsPage == 1) {
        _distributions = result;
      } else {
        _distributions.addAll(result);
      }
      
      _filteredDistributions = _applyDistributionFilters(_distributions);
      _calculateDistributionsPages();
      _notifyListeners();
    } catch (e) {
      _setDistributionsError('Failed to load distributions: $e');
    } finally {
      _setDistributionsLoading(false);
    }
  }

  Future<void> createDistribution(DistributionEntity distribution) async {
    try {
      await _repository.createDistribution(distribution);
      await loadDistributions(refresh: true);
    } catch (e) {
      _setDistributionsError('Failed to create distribution: $e');
    }
  }

  Future<void> updateDistributionStatus(String id, DistributionStatus status) async {
    try {
      await _repository.updateDistributionStatus(id, status);
      await loadDistributions(refresh: true);
    } catch (e) {
      _setDistributionsError('Failed to update distribution status: $e');
    }
  }

  // Inventory methods
  Future<void> loadInventory({bool refresh = false}) async {
    if (refresh) _inventoryPage = 1;
    
    _setInventoryLoading(true);
    _clearInventoryError();
    
    try {
      final result = await _repository.getInventory(
        page: _inventoryPage,
        limit: 20,
      );
      
      if (_inventoryPage == 1) {
        _inventory = result;
      } else {
        _inventory.addAll(result);
      }
      
      _filteredInventory = _applyInventoryFilters(_inventory);
      _calculateInventoryPages();
      _notifyListeners();
    } catch (e) {
      _setInventoryError('Failed to load inventory: $e');
    } finally {
      _setInventoryLoading(false);
    }
  }

  Future<void> adjustStock(String productId, int quantity, String reason) async {
    try {
      await _repository.adjustStock(productId, quantity, reason);
      await loadInventory(refresh: true);
    } catch (e) {
      _setInventoryError('Failed to adjust stock: $e');
    }
  }

  Future<void> transferStock(String productId, String fromWarehouseId, String toWarehouseId, int quantity) async {
    try {
      await _repository.transferStock(productId, fromWarehouseId, toWarehouseId, quantity);
      await loadInventory(refresh: true);
    } catch (e) {
      _setInventoryError('Failed to transfer stock: $e');
    }
  }

  // Order methods
  Future<void> loadOrders({bool refresh = false}) async {
    if (refresh) _ordersPage = 1;
    
    _setOrdersLoading(true);
    _clearOrdersError();
    
    try {
      final result = await _repository.getOrders(
        page: _ordersPage,
        limit: 20,
      );
      
      if (_ordersPage == 1) {
        _orders = result;
      } else {
        _orders.addAll(result);
      }
      
      _filteredOrders = _applyOrderFilters(_orders);
      _calculateOrdersPages();
      _notifyListeners();
    } catch (e) {
      _setOrdersError('Failed to load orders: $e');
    } finally {
      _setOrdersLoading(false);
    }
  }

  Future<void> createOrder(OrderEntity order) async {
    try {
      await _repository.createOrder(order);
      await loadOrders(refresh: true);
    } catch (e) {
      _setOrdersError('Failed to create order: $e');
    }
  }

  Future<void> updateOrderStatus(String id, OrderStatus status) async {
    try {
      await _repository.updateOrderStatus(id, status);
      await loadOrders(refresh: true);
    } catch (e) {
      _setOrdersError('Failed to update order status: $e');
    }
  }

  // Campaign methods
  Future<void> loadCampaigns({bool refresh = false}) async {
    if (refresh) _campaignsPage = 1;
    
    _setCampaignsLoading(true);
    _clearCampaignsError();
    
    try {
      final result = await _repository.getCampaigns(
        page: _campaignsPage,
        limit: 20,
      );
      
      if (_campaignsPage == 1) {
        _campaigns = result;
      } else {
        _campaigns.addAll(result);
      }
      
      _filteredCampaigns = _applyCampaignFilters(_campaigns);
      _calculateCampaignsPages();
      _notifyListeners();
    } catch (e) {
      _setCampaignsError('Failed to load campaigns: $e');
    } finally {
      _setCampaignsLoading(false);
    }
  }

  Future<void> createCampaign(MarketingCampaignEntity campaign) async {
    try {
      await _repository.createCampaign(campaign);
      await loadCampaigns(refresh: true);
    } catch (e) {
      _setCampaignsError('Failed to create campaign: $e');
    }
  }

  Future<void> launchCampaign(String id) async {
    try {
      await _repository.launchCampaign(id);
      await loadCampaigns(refresh: true);
    } catch (e) {
      _setCampaignsError('Failed to launch campaign: $e');
    }
  }

  // Analytics methods
  Future<void> loadAnalytics() async {
    _setAnalyticsLoading(true);
    _clearAnalyticsError();
    
    try {
      final result = await _repository.getOverallAnalytics();
      _analytics = result;
      _notifyListeners();
    } catch (e) {
      _setAnalyticsError('Failed to load analytics: $e');
    } finally {
      _setAnalyticsLoading(false);
    }
  }

  // Filter methods
  void updateSearchQuery(String query) {
    _searchQuery = query;
    _applyAllFilters();
  }

  void updateWarehouseFilter(String? warehouse) {
    _selectedWarehouse = warehouse;
    _applyAllFilters();
  }

  void updateStatusFilter(String? status) {
    _selectedStatus = status;
    _applyAllFilters();
  }

  void updateCarrierFilter(String? carrier) {
    _selectedCarrier = carrier;
    _applyAllFilters();
  }

  void updateDateRangeFilter(DateTime? start, DateTime? end) {
    _startDate = start;
    _endDate = end;
    _applyAllFilters();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedWarehouse = null;
    _selectedStatus = null;
    _selectedCarrier = null;
    _startDate = null;
    _endDate = null;
    _applyAllFilters();
  }

  void _applyAllFilters() {
    _filteredDistributions = _applyDistributionFilters(_distributions);
    _filteredInventory = _applyInventoryFilters(_inventory);
    _filteredOrders = _applyOrderFilters(_orders);
    _filteredCampaigns = _applyCampaignFilters(_campaigns);
    _notifyListeners();
  }

  // Private filter methods
  List<DistributionEntity> _applyDistributionFilters(List<DistributionEntity> items) {
    return items.where((item) {
      if (_searchQuery.isNotEmpty && 
          !item.id.toLowerCase().contains(_searchQuery.toLowerCase()) &&
          !item.orderId.toLowerCase().contains(_searchQuery.toLowerCase()) &&
          !item.productId.toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }
      
      if (_selectedWarehouse != null && 
          item.fromWarehouseId != _selectedWarehouse &&
          item.toWarehouseId != _selectedWarehouse) {
        return false;
      }
      
      if (_selectedStatus != null && 
          item.status.name != _selectedStatus) {
        return false;
      }
      
      if (_selectedCarrier != null && 
          item.carrierId != _selectedCarrier) {
        return false;
      }
      
      if (_startDate != null && 
          item.createdAt.isBefore(_startDate!)) {
        return false;
      }
      
      if (_endDate != null && 
          item.createdAt.isAfter(_endDate!)) {
        return false;
      }
      
      return true;
    }).toList();
  }

  List<InventoryEntity> _applyInventoryFilters(List<InventoryEntity> items) {
    return items.where((item) {
      if (_searchQuery.isNotEmpty && 
          !item.id.toLowerCase().contains(_searchQuery.toLowerCase()) &&
          !item.productId.toLowerCase().contains(_searchQuery.toLowerCase()) &&
          !item.location.toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }
      
      if (_selectedWarehouse != null && 
          item.warehouseId != _selectedWarehouse) {
        return false;
      }
      
      if (_selectedStatus != null && 
          item.status.name != _selectedStatus) {
        return false;
      }
      
      return true;
    }).toList();
  }

  List<OrderEntity> _applyOrderFilters(List<OrderEntity> items) {
    return items.where((item) {
      if (_searchQuery.isNotEmpty && 
          !item.id.toLowerCase().contains(_searchQuery.toLowerCase()) &&
          !item.orderNumber.toLowerCase().contains(_searchQuery.toLowerCase()) &&
          !item.customerId.toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }
      
      if (_selectedStatus != null && 
          item.status.name != _selectedStatus) {
        return false;
      }
      
      if (_startDate != null && 
          item.createdAt.isBefore(_startDate!)) {
        return false;
      }
      
      if (_endDate != null && 
          item.createdAt.isAfter(_endDate!)) {
        return false;
      }
      
      return true;
    }).toList();
  }

  List<MarketingCampaignEntity> _applyCampaignFilters(List<MarketingCampaignEntity> items) {
    return items.where((item) {
      if (_searchQuery.isNotEmpty && 
          !item.id.toLowerCase().contains(_searchQuery.toLowerCase()) &&
          !item.name.toLowerCase().contains(_searchQuery.toLowerCase()) &&
          !item.description.toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }
      
      if (_selectedStatus != null && 
          item.status.name != _selectedStatus) {
        return false;
      }
      
      if (_startDate != null && 
          item.createdAt.isBefore(_startDate!)) {
        return false;
      }
      
      if (_endDate != null && 
          item.createdAt.isAfter(_endDate!)) {
        return false;
      }
      
      return true;
    }).toList();
  }

  // Private helper methods
  void _setDistributionsLoading(bool loading) {
    _isLoadingDistributions = loading;
    _notifyListeners();
  }

  void _setInventoryLoading(bool loading) {
    _isLoadingInventory = loading;
    _notifyListeners();
  }

  void _setOrdersLoading(bool loading) {
    _isLoadingOrders = loading;
    _notifyListeners();
  }

  void _setCampaignsLoading(bool loading) {
    _isLoadingCampaigns = loading;
    _notifyListeners();
  }

  void _setAnalyticsLoading(bool loading) {
    _isLoadingAnalytics = loading;
    _notifyListeners();
  }

  void _setDistributionsError(String error) {
    _distributionsError = error;
    _notifyListeners();
  }

  void _setInventoryError(String error) {
    _inventoryError = error;
    _notifyListeners();
  }

  void _setOrdersError(String error) {
    _ordersError = error;
    _notifyListeners();
  }

  void _setCampaignsError(String error) {
    _campaignsError = error;
    _notifyListeners();
  }

  void _setAnalyticsError(String error) {
    _analyticsError = error;
    _notifyListeners();
  }

  void _clearDistributionsError() {
    _distributionsError = null;
    _notifyListeners();
  }

  void _clearInventoryError() {
    _inventoryError = null;
    _notifyListeners();
  }

  void _clearOrdersError() {
    _ordersError = null;
    _notifyListeners();
  }

  void _clearCampaignsError() {
    _campaignsError = null;
    _notifyListeners();
  }

  void _clearAnalyticsError() {
    _analyticsError = null;
    _notifyListeners();
  }

  void _calculateDistributionsPages() {
    _totalDistributionsPages = (_distributions.length / 20).ceil();
  }

  void _calculateInventoryPages() {
    _totalInventoryPages = (_inventory.length / 20).ceil();
  }

  void _calculateOrdersPages() {
    _totalOrdersPages = (_orders.length / 20).ceil();
  }

  void _calculateCampaignsPages() {
    _totalCampaignsPages = (_campaigns.length / 20).ceil();
  }

  void _notifyListeners() {
    if (!hasListeners) return;
    notifyListeners();
  }
}
