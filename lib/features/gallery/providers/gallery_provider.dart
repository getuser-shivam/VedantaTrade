import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/gallery_models.dart';

class GalleryStats {
  final int totalViews;
  final int uniqueUsers;
  final int avgSessionDuration;
  final Map<String, int> versionViews;
  final String mostViewedVersion;
  final DateTime lastUpdated;
  final int totalVersions;
  final int totalScreenshots;
  final int totalComparisons;
  final List<String> popularVersions;
  final Map<String, int> categoryDistribution;

  GalleryStats({
    required this.totalViews,
    required this.uniqueUsers,
    required this.avgSessionDuration,
    required this.versionViews,
    required this.mostViewedVersion,
    required this.lastUpdated,
    this.totalVersions = 0,
    this.totalScreenshots = 0,
    this.totalComparisons = 0,
    this.popularVersions = const [],
    this.categoryDistribution = const {},
  });
}

class GalleryProvider extends ChangeNotifier {
  List<GalleryVersion> _versions = [];
  List<GalleryScreenshot> _screenshots = [];
  List<GalleryVersion> _selectedVersions = [];
  GalleryStats _stats = GalleryStats(
    totalViews: 0,
    uniqueUsers: 0,
    avgSessionDuration: 0,
    versionViews: {},
    mostViewedVersion: '',
    lastUpdated: DateTime.now(),
  );
  
  List<GalleryVersion> get versions => _versions;
  List<GalleryScreenshot> get screenshots => _screenshots;
  List<GalleryVersion> get selectedVersions => _selectedVersions;
  GalleryStats get stats => _stats;

  // Gallery management methods
  Future<void> loadGalleryData() async {
    await _loadVersions();
    await _loadScreenshots();
    _updateStats();
    notifyListeners();
  }

  Future<void> _loadVersions() async {
    // Mock data for demonstration
    _versions = [
      GalleryVersion(
        id: 'v3.3.0',
        version: 'v3.3.0',
        title: 'Enhanced UI/UX System',
        description: 'Complete UI/UX overhaul with glassmorphic design',
        releaseDate: DateTime.now().subtract(const Duration(days: 1)),
        screenshots: [
          'assets/gallery/screenshots/v3.3.0/dashboard.png',
          'assets/gallery/screenshots/v3.3.0/components.png',
          'assets/gallery/screenshots/v3.3.0/theme.png',
        ],
        features: [
          'Glassmorphic Components',
          'Enhanced Navigation',
          'Responsive Design',
          'Dark Mode Support',
          'Micro-interactions',
        ],
        stats: {
          'views': 450,
          'viewTime': 35,
          'comparisons': 12,
        },
        isCurrent: true,
        isFavorite: false,
      ),
      GalleryVersion(
        id: 'v3.2.1',
        version: 'v3.2.1',
        title: 'CI/CD Implementation',
        description: 'Comprehensive CI/CD pipeline with automation',
        releaseDate: DateTime.now().subtract(const Duration(days: 7)),
        screenshots: [
          'assets/gallery/screenshots/v3.2.1/pipeline.png',
          'assets/gallery/screenshots/v3.2.1/monitoring.png',
          'assets/gallery/screenshots/v3.2.1/deployment.png',
        ],
        features: [
          'Enhanced CI/CD Pipeline',
          'Container Deployment',
          'Advanced Monitoring',
          'Security Scanning',
          'Multi-Platform Builds',
        ],
        stats: {
          'views': 380,
          'viewTime': 42,
          'comparisons': 8,
        },
        isCurrent: false,
        isFavorite: false,
      ),
      GalleryVersion(
        id: 'v3.2.0',
        version: 'v3.2.0',
        title: 'Performance Optimization',
        description: 'Performance improvements and bug fixes',
        releaseDate: DateTime.now().subtract(const Duration(days: 14)),
        screenshots: [
          'assets/gallery/screenshots/v3.2.0/performance.png',
          'assets/gallery/screenshots/v3.2.0/optimization.png',
        ],
        features: [
          'Performance Improvements',
          'Memory Optimization',
          'Animation Enhancements',
          'Code Cleanup',
        ],
        stats: {
          'views': 320,
          'viewTime': 28,
          'comparisons': 5,
        },
        isCurrent: false,
        isFavorite: true,
      ),
    ];
  }

  Future<void> _loadScreenshots() async {
    // Mock data for demonstration
    _screenshots = [
      GalleryScreenshot(
        id: 'ss1',
        versionId: 'v3.3.0',
        title: 'Dashboard Overview',
        description: 'Main dashboard with enhanced UI',
        imagePath: 'assets/gallery/screenshots/v3.3.0/dashboard.png',
        category: 'UI',
        capturedDate: DateTime.now().subtract(const Duration(days: 1)),
        metadata: {
          'resolution': '1920x1080',
          'size': '2.5MB',
        },
      ),
      GalleryScreenshot(
        id: 'ss2',
        versionId: 'v3.3.0',
        title: 'Component Library',
        description: 'Enhanced UI components showcase',
        imagePath: 'assets/gallery/screenshots/v3.3.0/components.png',
        category: 'UI',
        capturedDate: DateTime.now().subtract(const Duration(days: 1)),
        metadata: {
          'resolution': '1920x1080',
          'size': '1.8MB',
        },
      ),
      GalleryScreenshot(
        id: 'ss3',
        versionId: 'v3.2.1',
        title: 'CI/CD Pipeline',
        description: 'Automated deployment pipeline',
        imagePath: 'assets/gallery/screenshots/v3.2.1/pipeline.png',
        category: 'Development',
        capturedDate: DateTime.now().subtract(const Duration(days: 7)),
        metadata: {
          'resolution': '1920x1080',
          'size': '2.2MB',
        },
      ),
    ];
  }

  void _updateStats() {
    _stats = GalleryStats(
      totalViews: _calculateTotalViews(),
      uniqueUsers: _calculateUniqueUsers(),
      avgSessionDuration: _calculateAvgSessionDuration(),
      versionViews: _calculateVersionViews(),
      mostViewedVersion: _calculateMostViewedVersion(),
      lastUpdated: DateTime.now(),
      totalVersions: _versions.length,
      totalScreenshots: _screenshots.length,
      totalComparisons: _calculateTotalComparisons(),
      popularVersions: _calculatePopularVersions(),
      categoryDistribution: _calculateCategoryDistribution(),
    );
    notifyListeners();
  }

  int _calculateTotalViews() {
    return _versions.fold(0, (sum, version) => sum + (version.stats['views'] ?? 0));
  }

  int _calculateUniqueUsers() {
    // Mock calculation
    return (_calculateTotalViews() / 2.5).round();
  }

  int _calculateAvgSessionDuration() {
    final totalViewTime = _versions.fold(0, (sum, version) => sum + (version.stats['viewTime'] ?? 0));
    return totalViewTime > 0 ? totalViewTime ~/ _versions.length : 0;
  }

  Map<String, int> _calculateVersionViews() {
    return Map.fromEntries(
      _versions.map((version) => MapEntry(version.version, version.stats['views'] ?? 0)),
    );
  }

  String _calculateMostViewedVersion() {
    final versionViews = _calculateVersionViews();
    if (versionViews.isEmpty) return '';
    return versionViews.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  int _calculateTotalComparisons() {
    return _versions.fold(0, (sum, version) => sum + (version.stats['comparisons'] ?? 0));
  }

  List<String> _calculatePopularVersions() {
    final versionViews = _calculateVersionViews();
    final sortedEntries = versionViews.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sortedEntries.take(3).map((entry) => entry.key).toList();
  }

  Map<String, int> _calculateCategoryDistribution() {
    final distribution = <String, int>{};
    
    for (final version in _versions) {
      for (final feature in version.features) {
        final category = _categorizeFeature(feature);
        distribution[category] = (distribution[category] ?? 0) + 1;
      }
    }
    
    return distribution;
  }

  String _categorizeFeature(String feature) {
    if (feature.toLowerCase().contains('ui') || feature.toLowerCase().contains('theme')) {
      return 'UI';
    } else if (feature.toLowerCase().contains('performance')) {
      return 'Performance';
    } else if (feature.toLowerCase().contains('bug') || feature.toLowerCase().contains('fix')) {
      return 'Bug Fixes';
    } else if (feature.toLowerCase().contains('feature') || feature.toLowerCase().contains('new')) {
      return 'Features';
    } else {
      return 'Other';
    }
  }

  void selectVersionForComparison(GalleryVersion version, int? slot) {
    if (slot == null) {
      _selectedVersions.clear();
    } else if (slot == 0) {
      if (_selectedVersions.length < 2) {
        _selectedVersions.insert(0, version);
      }
    } else if (slot == 1) {
      if (_selectedVersions.length < 2) {
        _selectedVersions.add(version);
      }
    }
    notifyListeners();
  }

  void clearSelectedVersions() {
    _selectedVersions.clear();
    notifyListeners();
  }

  void toggleFavorite(GalleryVersion version) {
    final index = _versions.indexWhere((v) => v.id == version.id);
    if (index != -1) {
      _versions[index] = GalleryVersion(
        id: version.id,
        version: version.version,
        title: version.title,
        description: version.description,
        releaseDate: version.releaseDate,
        screenshots: version.screenshots,
        features: version.features,
        stats: version.stats,
        isCurrent: version.isCurrent,
        isFavorite: !version.isFavorite,
      );
      _updateStats();
      notifyListeners();
    }
  }

  Future<void> trackInteraction(String action, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_gallery_interaction', DateTime.now().toIso8601String());
    
    switch (action) {
      case 'view_version':
        await prefs.setInt('views_${data['version']}', (prefs.getInt('views_${data['version']}') ?? 0) + 1);
        break;
      case 'screenshot_view':
        await prefs.setInt('screenshot_views', (prefs.getInt('screenshot_views') ?? 0) + 1);
        break;
      case 'compare_versions':
        await prefs.setInt('comparisons', (prefs.getInt('comparisons') ?? 0) + 1);
        break;
      case 'favorite_version':
        await prefs.setString('favorite_version', data['version']);
        break;
    }
    
    _updateStats();
  }

class AppGalleryProvider extends ChangeNotifier {
  GalleryStats _stats = GalleryStats(
    totalViews: 0,
    uniqueUsers: 0,
    avgSessionDuration: 0,
    versionViews: {},
    mostViewedVersion: '3.2.1-alpha',
    lastUpdated: DateTime.now(),
  );

  GalleryStats get stats => _stats;

  void recordVersionView(String version) {
    _stats.versionViews[version] = (_stats.versionViews[version] ?? 0) + 1;
    _stats.totalViews++;
    _stats.lastUpdated = DateTime.now();
    
    // Update most viewed version
    if (_stats.versionViews[version]! > (_stats.versionViews[_stats.mostViewedVersion] ?? 0)) {
      _stats.mostViewedVersion = version;
    }
    
    notifyListeners();
  }

  void recordUserSession(int duration) {
    _stats.uniqueUsers++;
    _stats.avgSessionDuration = (_stats.avgSessionDuration + duration) ~/ 2;
    notifyListeners();
  }

  void updateStats(GalleryStats newStats) {
    _stats = newStats;
    notifyListeners();
  }
}
