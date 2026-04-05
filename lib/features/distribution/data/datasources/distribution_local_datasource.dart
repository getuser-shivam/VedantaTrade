import 'dart:async';
import '../../domain/entities/distribution_entity.dart';
import '../../../shared/storage/storage_service.dart';

/// Distribution Local Data Source
/// Handles local storage and caching for distribution data
class DistributionLocalDataSource {
  final StorageService _storageService;

  DistributionLocalDataSource({
    required StorageService storageService,
  }) : _storageService = storageService;

  // Cache keys
  static const String _distributionsCacheKey = 'distributions_cache';
  static const String _campaignsCacheKey = 'campaigns_cache';
  static const String _routesCacheKey = 'routes_cache';
  static const String _inventoryCacheKey = 'inventory_cache';
  static const String _analyticsCacheKey = 'analytics_cache';
  static const String _recentSearchesKey = 'recent_distribution_searches';

  /// Cache distributions
  Future<void> cacheDistributions(List<DistributionEntity> distributions) async {
    try {
      await _storageService.saveData(
        _distributionsCacheKey,
        distributions.map((d) => d.toJson()).toList(),
      );
    } catch (e) {
      throw Exception('Failed to cache distributions: $e');
    }
  }

  /// Get cached distributions
  Future<List<DistributionEntity>> getCachedDistributions() async {
    try {
      final data = await _storageService.getData(_distributionsCacheKey);
      if (data == null) return [];

      final List<dynamic> distributionsData = data;
      return distributionsData
          .map((item) => DistributionEntity.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Failed to get cached distributions: $e');
    }
  }

  /// Get cached distribution by ID
  Future<DistributionEntity?> getCachedDistributionById(String id) async {
    try {
      final distributions = await getCachedDistributions();
      return distributions.firstWhere(
        (d) => d.id == id,
        orElse: () => null,
      );
    } catch (e) {
      throw Exception('Failed to get cached distribution by ID: $e');
    }
  }

  /// Cache single distribution
  Future<void> cacheDistribution(DistributionEntity distribution) async {
    try {
      final distributions = await getCachedDistributions();
      final existingIndex = distributions.indexWhere((d) => d.id == distribution.id);
      
      if (existingIndex != -1) {
        distributions[existingIndex] = distribution;
      } else {
        distributions.add(distribution);
      }
      
      await cacheDistributions(distributions);
    } catch (e) {
      throw Exception('Failed to cache distribution: $e');
    }
  }

  /// Remove cached distribution
  Future<void> removeCachedDistribution(String id) async {
    try {
      final distributions = await getCachedDistributions();
      distributions.removeWhere((d) => d.id == id);
      await cacheDistributions(distributions);
    } catch (e) {
      throw Exception('Failed to remove cached distribution: $e');
    }
  }

  /// Clear distributions cache
  Future<void> clearDistributionCache() async {
    try {
      await _storageService.removeData(_distributionsCacheKey);
    } catch (e) {
      throw Exception('Failed to clear distributions cache: $e');
    }
  }

  /// Cache campaigns
  Future<void> cacheCampaigns(List<MarketingCampaign> campaigns) async {
    try {
      await _storageService.saveData(
        _campaignsCacheKey,
        campaigns.map((c) => c.toJson()).toList(),
      );
    } catch (e) {
      throw Exception('Failed to cache campaigns: $e');
    }
  }

  /// Get cached campaigns
  Future<List<MarketingCampaign>> getCachedCampaigns() async {
    try {
      final data = await _storageService.getData(_campaignsCacheKey);
      if (data == null) return [];

      final List<dynamic> campaignsData = data;
      return campaignsData
          .map((item) => MarketingCampaign.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Failed to get cached campaigns: $e');
    }
  }

  /// Cache single campaign
  Future<void> cacheCampaign(MarketingCampaign campaign) async {
    try {
      final campaigns = await getCachedCampaigns();
      final existingIndex = campaigns.indexWhere((c) => c.id == campaign.id);
      
      if (existingIndex != -1) {
        campaigns[existingIndex] = campaign;
      } else {
        campaigns.add(campaign);
      }
      
      await cacheCampaigns(campaigns);
    } catch (e) {
      throw Exception('Failed to cache campaign: $e');
    }
  }

  /// Remove cached campaign
  Future<void> removeCachedCampaign(String id) async {
    try {
      final campaigns = await getCachedCampaigns();
      campaigns.removeWhere((c) => c.id == id);
      await cacheCampaigns(campaigns);
    } catch (e) {
      throw Exception('Failed to remove cached campaign: $e');
    }
  }

  /// Clear campaigns cache
  Future<void> clearCampaignCache() async {
    try {
      await _storageService.removeData(_campaignsCacheKey);
    } catch (e) {
      throw Exception('Failed to clear campaigns cache: $e');
    }
  }

  /// Cache routes
  Future<void> cacheRoutes(List<DistributionRoute> routes) async {
    try {
      await _storageService.saveData(
        _routesCacheKey,
        routes.map((r) => r.toJson()).toList(),
      );
    } catch (e) {
      throw Exception('Failed to cache routes: $e');
    }
  }

  /// Get cached routes
  Future<List<DistributionRoute>> getCachedRoutes() async {
    try {
      final data = await _storageService.getData(_routesCacheKey);
      if (data == null) return [];

      final List<dynamic> routesData = data;
      return routesData
          .map((item) => DistributionRoute.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Failed to get cached routes: $e');
    }
  }

  /// Cache single route
  Future<void> cacheRoute(DistributionRoute route) async {
    try {
      final routes = await getCachedRoutes();
      final existingIndex = routes.indexWhere((r) => r.id == route.id);
      
      if (existingIndex != -1) {
        routes[existingIndex] = route;
      } else {
        routes.add(route);
      }
      
      await cacheRoutes(routes);
    } catch (e) {
      throw Exception('Failed to cache route: $e');
    }
  }

  /// Remove cached route
  Future<void> removeCachedRoute(String id) async {
    try {
      final routes = await getCachedRoutes();
      routes.removeWhere((r) => r.id == id);
      await cacheRoutes(routes);
    } catch (e) {
      throw Exception('Failed to remove cached route: $e');
    }
  }

  /// Clear routes cache
  Future<void> clearRoutesCache() async {
    try {
      await _storageService.removeData(_routesCacheKey);
    } catch (e) {
      throw Exception('Failed to clear routes cache: $e');
    }
  }

  /// Cache inventory
  Future<void> cacheInventory(List<WarehouseInventory> inventory) async {
    try {
      await _storageService.saveData(
        _inventoryCacheKey,
        inventory.map((i) => i.toJson()).toList(),
      );
    } catch (e) {
      throw Exception('Failed to cache inventory: $e');
    }
  }

  /// Get cached inventory
  Future<List<WarehouseInventory>> getCachedInventory() async {
    try {
      final data = await _storageService.getData(_inventoryCacheKey);
      if (data == null) return [];

      final List<dynamic> inventoryData = data;
      return inventoryData
          .map((item) => WarehouseInventory.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Failed to get cached inventory: $e');
    }
  }

  /// Cache analytics
  Future<void> cacheAnalytics(DistributionAnalytics? analytics) async {
    if (analytics == null) return;
    
    try {
      await _storageService.saveData(
        _analyticsCacheKey,
        analytics.toJson(),
      );
    } catch (e) {
      throw Exception('Failed to cache analytics: $e');
    }
  }

  /// Get cached analytics
  Future<DistributionAnalytics?> getCachedAnalytics() async {
    try {
      final data = await _storageService.getData(_analyticsCacheKey);
      if (data == null) return null;

      return DistributionAnalytics.fromJson(data);
    } catch (e) {
      throw Exception('Failed to get cached analytics: $e');
    }
  }

  /// Save recent search
  Future<void> saveRecentSearch(String searchQuery) async {
    try {
      final recentSearches = await getRecentSearches();
      
      // Remove if already exists
      recentSearches.remove(searchQuery);
      
      // Add to beginning
      recentSearches.insert(0, searchQuery);
      
      // Keep only last 10 searches
      if (recentSearches.length > 10) {
        recentSearches.removeRange(10, recentSearches.length);
      }
      
      await _storageService.saveData(_recentSearchesKey, recentSearches);
    } catch (e) {
      throw Exception('Failed to save recent search: $e');
    }
  }

  /// Get recent searches
  Future<List<String>> getRecentSearches() async {
    try {
      final data = await _storageService.getData(_recentSearchesKey);
      if (data == null) return [];

      return List<String>.from(data);
    } catch (e) {
      throw Exception('Failed to get recent searches: $e');
    }
  }

  /// Clear recent searches
  Future<void> clearRecentSearches() async {
    try {
      await _storageService.removeData(_recentSearchesKey);
    } catch (e) {
      throw Exception('Failed to clear recent searches: $e');
    }
  }

  /// Check if data is fresh
  Future<bool> isDataFresh({Duration maxAge = const Duration(hours: 1)}) async {
    try {
      final lastUpdate = await _storageService.getLastUpdateTime(_distributionsCacheKey);
      if (lastUpdate == null) return false;

      return DateTime.now().difference(lastUpdate!) < maxAge;
    } catch (e) {
      throw Exception('Failed to check data freshness: $e');
    }
  }

  /// Clear all cache
  Future<void> clearAllCache() async {
    try {
      await Future.wait([
        clearDistributionCache(),
        clearCampaignCache(),
        clearRoutesCache(),
        clearInventoryCache(),
        clearRecentSearches(),
      ]);
    } catch (e) {
      throw Exception('Failed to clear all cache: $e');
    }
  }

  /// Get cache size
  Future<Map<String, int>> getCacheSize() async {
    try {
      final sizes = <String, int>{};
      
      sizes[_distributionsCacheKey] = (await getCachedDistributions()).length;
      sizes[_campaignsCacheKey] = (await getCachedCampaigns()).length;
      sizes[_routesCacheKey] = (await getCachedRoutes()).length;
      sizes[_inventoryCacheKey] = (await getCachedInventory()).length;
      sizes[_recentSearchesKey] = (await getRecentSearches()).length;
      
      return sizes;
    } catch (e) {
      throw Exception('Failed to get cache size: $e');
    }
  }

  /// Optimize cache
  Future<void> optimizeCache() async {
    try {
      final cacheSize = await getCacheSize();
      final totalItems = cacheSize.values.fold(0, (sum, count) => sum + count);
      
      // If cache is too large, clear old data
      if (totalItems > 1000) {
        await clearAllCache();
      }
    } catch (e) {
      throw Exception('Failed to optimize cache: $e');
    }
  }
}
