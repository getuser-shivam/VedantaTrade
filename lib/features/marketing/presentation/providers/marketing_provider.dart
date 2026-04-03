import 'package:flutter/foundation.dart';
import 'package:vedanta_trade/features/marketing/data/services/marketing_service.dart';
import '../models/marketing_campaign.dart';

class MarketingProvider extends ChangeNotifier {
  final MarketingService _marketingService = MarketingService();

  List<MarketingCampaign> _campaigns = [];
  bool _isLoading = false;
  String? _error;

  // Statistics
  int _totalCampaigns = 0;
  int _activeCampaigns = 0;
  int _completedCampaigns = 0;
  double _totalBudget = 0.0;
  double _totalSpent = 0.0;
  double _roi = 0.0;
  double _averageCTR = 0.0;
  double _averageConversionRate = 0.0;

  // Getters
  List<MarketingCampaign> get campaigns => _campaigns;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  int get totalCampaigns => _totalCampaigns;
  int get activeCampaigns => _activeCampaigns;
  int get completedCampaigns => _completedCampaigns;
  double get totalBudget => _totalBudget;
  double get totalSpent => _totalSpent;
  double get roi => _roi;
  double get averageCTR => _averageCTR;
  double get averageConversionRate => _averageConversionRate;

  MarketingProvider() {
    loadCampaigns();
  }

  // Load all campaigns
  Future<void> loadCampaigns() async {
    _setLoading(true);
    try {
      _campaigns = await _marketingService.getAllCampaigns();
      await _calculateStatistics();
      _error = null;
    } catch (e) {
      _error = 'Failed to load campaigns: ${e.toString()}';
      debugPrint(_error);
    } finally {
      _setLoading(false);
    }
  }

  // Refresh campaigns
  Future<void> refreshCampaigns() async {
    await loadCampaigns();
  }

  // Get campaigns by status
  Future<List<MarketingCampaign>> getCampaignsByStatus(String status) async {
    try {
      return await _marketingService.getCampaignsByStatus(status);
    } catch (e) {
      _error = 'Failed to load campaigns by status: ${e.toString()}';
      debugPrint(_error);
      return [];
    }
  }

  // Get campaigns by type
  Future<List<MarketingCampaign>> getCampaignsByType(String type) async {
    try {
      return await _marketingService.getCampaignsByType(type);
    } catch (e) {
      _error = 'Failed to load campaigns by type: ${e.toString()}';
      debugPrint(_error);
      return [];
    }
  }

  // Get campaign by ID
  Future<MarketingCampaign?> getCampaignById(String id) async {
    try {
      return await _marketingService.getCampaignById(id);
    } catch (e) {
      _error = 'Failed to load campaign: ${e.toString()}';
      debugPrint(_error);
      return null;
    }
  }

  // Create new campaign
  Future<bool> createCampaign(MarketingCampaign campaign) async {
    _setLoading(true);
    try {
      final newCampaign = await _marketingService.createCampaign(campaign);
      _campaigns.add(newCampaign);
      await _calculateStatistics();
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to create campaign: ${e.toString()}';
      debugPrint(_error);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update campaign
  Future<bool> updateCampaign(MarketingCampaign campaign) async {
    _setLoading(true);
    try {
      final updatedCampaign = await _marketingService.updateCampaign(campaign);
      final index = _campaigns.indexWhere((c) => c.id == campaign.id);
      if (index != -1) {
        _campaigns[index] = updatedCampaign;
        await _calculateStatistics();
      }
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update campaign: ${e.toString()}';
      debugPrint(_error);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update campaign status
  Future<bool> updateCampaignStatus(String id, String status) async {
    _setLoading(true);
    try {
      final updatedCampaign = await _marketingService.updateCampaignStatus(id, status);
      final index = _campaigns.indexWhere((c) => c.id == id);
      if (index != -1) {
        _campaigns[index] = updatedCampaign;
        await _calculateStatistics();
      }
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update campaign status: ${e.toString()}';
      debugPrint(_error);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete campaign
  Future<bool> deleteCampaign(String id) async {
    _setLoading(true);
    try {
      final success = await _marketingService.deleteCampaign(id);
      if (success) {
        _campaigns.removeWhere((c) => c.id == id);
        await _calculateStatistics();
      }
      _error = null;
      notifyListeners();
      return success;
    } catch (e) {
      _error = 'Failed to delete campaign: ${e.toString()}';
      debugPrint(_error);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Search campaigns
  List<MarketingCampaign> searchCampaigns(String query) {
    if (query.isEmpty) return _campaigns;
    
    final lowercaseQuery = query.toLowerCase();
    return _campaigns.where((campaign) =>
      campaign.searchableText.contains(lowercaseQuery)
    ).toList();
  }

  // Filter campaigns by date range
  List<MarketingCampaign> filterCampaignsByDateRange(DateTime start, DateTime end) {
    return _campaigns.where((campaign) =>
      campaign.startDate.isAfter(start.subtract(const Duration(days: 1))) &&
      campaign.endDate.isBefore(end.add(const Duration(days: 1)))
    ).toList();
  }

  // Filter campaigns by budget range
  List<MarketingCampaign> filterCampaignsByBudgetRange(double min, double max) {
    return _campaigns.where((campaign) =>
      campaign.budget >= min && campaign.budget <= max
    ).toList();
  }

  // Get campaign statistics
  Future<Map<String, dynamic>> getCampaignStatistics() async {
    try {
      return await _marketingService.getMarketingStatistics();
    } catch (e) {
      _error = 'Failed to load campaign statistics: ${e.toString()}';
      debugPrint(_error);
      return {};
    }
  }

  // Get top performing campaigns
  List<MarketingCampaign> getTopPerformingCampaigns({int limit = 5}) {
    final sortedCampaigns = List<MarketingCampaign>.from(_campaigns);
    sortedCampaigns.sort((a, b) => b.conversions.compareTo(a.conversions));
    return sortedCampaigns.take(limit).toList();
  }

  // Get campaigns with highest ROI
  List<MarketingCampaign> getCampaignsWithHighestROI({int limit = 5}) {
    final sortedCampaigns = List<MarketingCampaign>.from(_campaigns);
    sortedCampaigns.sort((a, b) => b.cpa.compareTo(a.cpa));
    return sortedCampaigns.take(limit).toList();
  }

  // Get active campaigns that are near budget limit
  List<MarketingCampaign> getCampaignsNearBudgetLimit() {
    return _campaigns.where((campaign) =>
      campaign.isActive && campaign.isNearBudgetLimit
    ).toList();
  }

  // Get expired campaigns
  List<MarketingCampaign> getExpiredCampaigns() {
    return _campaigns.where((campaign) =>
      campaign.isExpired && !campaign.isCompleted
    ).toList();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Private methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<void> _calculateStatistics() async {
    _totalCampaigns = _campaigns.length;
    _activeCampaigns = _campaigns.where((c) => c.isActive).length;
    _completedCampaigns = _campaigns.where((c) => c.isCompleted).length;
    _totalBudget = _campaigns.fold<double>(0, (sum, c) => sum + c.budget);
    _totalSpent = _campaigns.fold<double>(0, (sum, c) => sum + c.spent);
    
    // Calculate average metrics
    if (_campaigns.isNotEmpty) {
      _averageCTR = _campaigns.fold<double>(0, (sum, c) => sum + c.ctr) / _campaigns.length;
      _averageConversionRate = _campaigns.fold<double>(0, (sum, c) => sum + c.conversionRate) / _campaigns.length;
    }
    
    // Calculate ROI (simplified)
    final totalConversions = _campaigns.fold<int>(0, (sum, c) => sum + c.conversions);
    if (_totalSpent > 0) {
      _roi = ((totalConversions * 50) - _totalSpent) / _totalSpent * 100; // Assuming $50 per conversion
    }
  }
}
