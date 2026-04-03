import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/services/distribution_service.dart';

class AnalyticsProvider extends ChangeNotifier {
  final DistributionService _distributionService;
  
  Map<String, dynamic>? _salesAnalytics;
  Map<String, dynamic>? _marketingAnalytics;
  Map<String, dynamic>? _distributionAnalytics;
  bool _isLoading = false;
  String? _error;
  
  // Pagination
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalItems = 0;
  final int _itemsPerPage = 20;

  AnalyticsProvider(this._distributionService);

  // Getters
  Map<String, dynamic>? get salesAnalytics => _salesAnalytics;
  Map<String, dynamic>? get marketingAnalytics => _marketingAnalytics;
  Map<String, dynamic>? get distributionAnalytics => _distributionAnalytics;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Pagination getters
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get totalItems => _totalItems;
  bool get hasNextPage => _currentPage < _totalPages;
  bool get hasPreviousPage => _currentPage > 1;

  // Load sales analytics
  Future<void> loadSalesAnalytics({String period = 'Last 30 Days', String metric = 'Revenue'}) async {
    _setLoading(true);
    _error = null;

    try {
      final response = await _distributionService.getSalesAnalytics(
        period: period,
        metric: metric,
      );

      if (response['success'] == true) {
        _salesAnalytics = response['data'];
      } else {
        _error = response['message'] ?? 'Failed to load sales analytics';
      }
    } catch (e) {
      _error = 'Failed to load sales analytics: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  // Load marketing analytics
  Future<void> loadMarketingAnalytics({String period = 'Last 30 Days'}) async {
    _setLoading(true);
    _error = null;

    try {
      final response = await _distributionService.getMarketingAnalytics(
        period: period,
      );

      if (response['success'] == true) {
        _marketingAnalytics = response['data'];
      } else {
        _error = response['message'] ?? 'Failed to load marketing analytics';
      }
    } catch (e) {
      _error = 'Failed to load marketing analytics: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  // Load distribution analytics
  Future<void> loadDistributionAnalytics({String period = 'Last 30 Days'}) async {
    _setLoading(true);
    _error = null;

    try {
      final response = await _distributionService.getDistributionAnalytics(
        period: period,
      );

      if (response['success'] == true) {
        _distributionAnalytics = response['data'];
      } else {
        _error = response['message'] ?? 'Failed to load distribution analytics';
      }
    } catch (e) {
      _error = 'Failed to load distribution analytics: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  // Load comprehensive analytics
  Future<void> loadComprehensiveAnalytics({String period = 'Last 30 Days'}) async {
    _setLoading(true);
    _error = null;

    try {
      final futures = [
        _distributionService.getSalesAnalytics(period: period),
        _distributionService.getMarketingAnalytics(period: period),
        _distributionService.getDistributionAnalytics(period: period),
      ];

      final responses = await Future.wait(futures);

      if (responses.every((response) => response['success'] == true)) {
        _salesAnalytics = responses[0]['data'];
        _marketingAnalytics = responses[1]['data'];
        _distributionAnalytics = responses[2]['data'];
      } else {
        final failedResponse = responses.firstWhere(
          (response) => response['success'] != true,
          orElse: () => responses[0],
        );
        _error = failedResponse['message'] ?? 'Failed to load analytics data';
      }
    } catch (e) {
      _error = 'Failed to load comprehensive analytics: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  // Export analytics data
  Future<bool> exportAnalyticsData(String type, {String? period, String? format}) async {
    _setLoading(true);
    _error = null;

    try {
      Map<String, dynamic> data;
      switch (type) {
        case 'sales':
          data = _salesAnalytics ?? {};
          break;
        case 'marketing':
          data = _marketingAnalytics ?? {};
          break;
        case 'distribution':
          data = _distributionAnalytics ?? {};
          break;
        case 'comprehensive':
          data = {
            'sales': _salesAnalytics ?? {},
            'marketing': _marketingAnalytics ?? {},
            'distribution': _distributionAnalytics ?? {},
          };
          break;
        default:
          _error = 'Invalid export type';
          return false;
      }

      final response = await _distributionService.exportAnalyticsData(
        type: type,
        data: data,
        period: period ?? 'Last 30 Days',
        format: format ?? 'csv',
      );

      if (response['success'] == true) {
        return true;
      } else {
        _error = response['message'] ?? 'Failed to export analytics data';
        return false;
      }
    } catch (e) {
      _error = 'Failed to export analytics data: ${e.toString()}';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Generate custom report
  Future<bool> generateCustomReport(Map<String, dynamic> reportConfig) async {
    _setLoading(true);
    _error = null;

    try {
      final response = await _distributionService.generateCustomReport(reportConfig);

      if (response['success'] == true) {
        return true;
      } else {
        _error = response['message'] ?? 'Failed to generate custom report';
        return false;
      }
    } catch (e) {
      _error = 'Failed to generate custom report: ${e.toString()}';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Load next page
  Future<void> loadNextPage() async {
    if (hasNextPage) {
      await loadComprehensiveAnalytics();
    }
  }

  // Load previous page
  Future<void> loadPreviousPage() async {
    if (hasPreviousPage) {
      _currentPage--;
      await loadComprehensiveAnalytics();
    }
  }

  // Refresh data
  Future<void> refresh() async {
    _currentPage = 1;
    await loadComprehensiveAnalytics();
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
