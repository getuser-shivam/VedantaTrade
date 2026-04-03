import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/services/distribution_service.dart';

class MarketingProvider extends ChangeNotifier {
  final DistributionService _distributionService;
  
  List<MarketingCampaign> _campaigns = [];
  List<CampaignProduct> _campaignProducts = [];
  List<MarketingMetric> _metrics = [];
  bool _isLoading = false;
  String? _error;
  
  // Pagination
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalItems = 0;
  final int _itemsPerPage = 20;

  MarketingProvider(this._distributionService);

  // Getters
  List<MarketingCampaign> get campaigns => _campaigns;
  List<CampaignProduct> get campaignProducts => _campaignProducts;
  List<MarketingMetric> get metrics => _metrics;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Pagination getters
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get totalItems => _totalItems;
  bool get hasNextPage => _currentPage < _totalPages;
  bool get hasPreviousPage => _currentPage > 1;

  // Load marketing campaigns
  Future<void> loadCampaigns({int page = 1, String search = '', String status = 'All', String sort = 'Created Date'}) async {
    _setLoading(true);
    _error = null;

    try {
      final response = await _distributionService.getMarketingCampaigns(
        page: page,
        limit: _itemsPerPage,
        search: search,
        status: status,
        sort: sort,
      );

      if (response['success'] == true) {
        final data = response['data'];
        final pagination = response['pagination'];
        
        _campaigns = (data['campaigns'] as List<dynamic>)
            .map((campaign) => MarketingCampaign.fromJson(campaign))
            .toList();
        
        _currentPage = pagination['page'] ?? page;
        _totalPages = pagination['pages'] ?? 1;
        _totalItems = pagination['total'] ?? 0;
      } else {
        _error = response['message'] ?? 'Failed to load marketing campaigns';
      }
    } catch (e) {
      _error = 'Failed to load marketing campaigns: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  // Load campaign products
  Future<void> loadCampaignProducts(int campaignId, {int page = 1}) async {
    _setLoading(true);
    _error = null;

    try {
      final response = await _distributionService.getCampaignProducts(
        campaignId: campaignId,
        page: page,
        limit: _itemsPerPage,
      );

      if (response['success'] == true) {
        final data = response['data'];
        final pagination = response['pagination'];
        
        _campaignProducts = (data['products'] as List<dynamic>)
            .map((product) => CampaignProduct.fromJson(product))
            .toList();
        
        _currentPage = pagination['page'] ?? page;
        _totalPages = pagination['pages'] ?? 1;
        _totalItems = pagination['total'] ?? 0;
      } else {
        _error = response['message'] ?? 'Failed to load campaign products';
      }
    } catch (e) {
      _error = 'Failed to load campaign products: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  // Load marketing metrics
  Future<void> loadMarketingMetrics(int campaignId, {int page = 1}) async {
    _setLoading(true);
    _error = null;

    try {
      final response = await _distributionService.getMarketingMetrics(
        campaignId: campaignId,
        page: page,
        limit: _itemsPerPage,
      );

      if (response['success'] == true) {
        final data = response['data'];
        final pagination = response['pagination'];
        
        _metrics = (data['metrics'] as List<dynamic>)
            .map((metric) => MarketingMetric.fromJson(metric))
            .toList();
        
        _currentPage = pagination['page'] ?? page;
        _totalPages = pagination['pages'] ?? 1;
        _totalItems = pagination['total'] ?? 0;
      } else {
        _error = response['message'] ?? 'Failed to load marketing metrics';
      }
    } catch (e) {
      _error = 'Failed to load marketing metrics: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  // Create new marketing campaign
  Future<bool> createCampaign(Map<String, dynamic> campaignData) async {
    _setLoading(true);
    _error = null;

    try {
      final response = await _distributionService.createMarketingCampaign(campaignData);
      
      if (response['success'] == true) {
        final newCampaign = MarketingCampaign.fromJson(response['data']);
        _campaigns.insert(0, newCampaign);
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Failed to create marketing campaign';
        return false;
      }
    } catch (e) {
      _error = 'Failed to create marketing campaign: ${e.toString()}';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Add product to campaign
  Future<bool> addProductToCampaign(int campaignId, Map<String, dynamic> productData) async {
    _setLoading(true);
    _error = null;

    try {
      final response = await _distributionService.addProductToCampaign(campaignId, productData);
      
      if (response['success'] == true) {
        final newProduct = CampaignProduct.fromJson(response['data']);
        _campaignProducts.insert(0, newProduct);
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Failed to add product to campaign';
        return false;
      }
    } catch (e) {
      _error = 'Failed to add product to campaign: ${e.toString()}';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Record marketing metric
  Future<bool> recordMetric(int campaignId, Map<String, dynamic> metricData) async {
    _setLoading(true);
    _error = null;

    try {
      final response = await _distributionService.recordMarketingMetric(campaignId, metricData);
      
      if (response['success'] == true) {
        final newMetric = MarketingMetric.fromJson(response['data']);
        _metrics.insert(0, newMetric);
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Failed to record marketing metric';
        return false;
      }
    } catch (e) {
      _error = 'Failed to record marketing metric: ${e.toString()}';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Load next page
  Future<void> loadNextPage() async {
    if (hasNextPage) {
      await loadCampaigns(page: _currentPage + 1);
    }
  }

  // Load previous page
  Future<void> loadPreviousPage() async {
    if (hasPreviousPage) {
      await loadCampaigns(page: _currentPage - 1);
    }
  }

  // Refresh data
  Future<void> refresh() async {
    _currentPage = 1;
    await loadCampaigns();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
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
