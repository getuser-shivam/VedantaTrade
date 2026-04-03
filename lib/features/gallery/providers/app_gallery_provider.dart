import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';

class VersionInfo {
  final String version;
  final String date;
  final String title;
  final String description;
  final List<String> features;
  final String screenshot;
  final bool isNew;
  final String changelog;
  final List<String> screenshots;
  final Map<String, dynamic> metrics;

  VersionInfo({
    required this.version,
    required this.date,
    required this.title,
    required this.description,
    required this.features,
    required this.screenshot,
    required this.isNew,
    this.changelog = '',
    this.screenshots = const [],
    this.metrics = const {},
  });
}

class AppGalleryProvider extends ChangeNotifier {
  List<VersionInfo> _versions = [];
  int _currentIndex = 0;
  bool _isAutoPlay = false;
  String _searchQuery = '';
  List<String> _selectedVersions = [];
  Map<String, int> _viewCounts = {};

  List<VersionInfo> get versions => _versions;
  int get currentIndex => _currentIndex;
  bool get isAutoPlay => _isAutoPlay;
  String get searchQuery => _searchQuery;
  List<String> get selectedVersions => _selectedVersions;

  void initializeVersions() {
    _versions = [
      VersionInfo(
        version: '3.2.1-alpha',
        date: '2026-04-03',
        title: 'Comprehensive CI/CD Pipeline',
        description: 'Enterprise-grade automation with quality gates and security scanning',
        features: [
          'Complete CI/CD workflow with quality gates',
          'Automated testing suite with coverage reporting',
          'Multi-platform deployment automation',
          'Security vulnerability scanning',
          'Performance monitoring and optimization',
          'Release management with semantic versioning',
          'Environment management (staging/production)',
          'Health checks and monitoring',
          'Documentation updates and version management',
        ],
        screenshot: 'assets/screenshots/v3.2.1-alpha.png',
        isNew: true,
        changelog: 'Major infrastructure upgrade implementing enterprise-grade automated testing, deployment, and monitoring pipeline with enhanced UX system.',
        screenshots: [
          'assets/screenshots/v3.2.1-alpha-carousel.png',
          'assets/screenshots/v3.2.1-alpha-grid.png',
          'assets/screenshots/v3.2.1-alpha-compare.png',
        ],
        metrics: {
          'builds': 7,
          'tests': 15,
          'coverage': 85,
          'performance': 92,
          'security': 98,
        },
      ),
      VersionInfo(
        version: '3.2.0-alpha',
        date: '2026-04-03',
        title: 'Production Hardening',
        description: 'Production-ready infrastructure with enhanced monitoring',
        features: [
          'Production deployment automation',
          'Health checks and monitoring',
          'Performance optimization',
          'Security enhancements',
          'Documentation updates',
        ],
        screenshot: 'assets/screenshots/v3.2.0-alpha.png',
        isNew: false,
        changelog: 'Production hardening with comprehensive CI/CD pipeline, security monitoring, and performance optimization.',
        screenshots: [
          'assets/screenshots/v3.2.0-alpha-main.png',
          'assets/screenshots/v3.2.0-alpha-details.png',
        ],
        metrics: {
          'builds': 5,
          'tests': 12,
          'coverage': 82,
          'performance': 88,
          'security': 95,
        },
      ),
      VersionInfo(
        version: '3.1.0-alpha',
        date: '2026-04-02',
        title: 'Feature Complete',
        description: 'Complete feature implementation with enhanced UI',
        features: [
          '6-role architecture implementation',
          'Geospatial field force tracking',
          'Product catalog with search',
          'Distribution management',
          'VAT compliance system',
        ],
        screenshot: 'assets/screenshots/v3.1.0-alpha.png',
        isNew: false,
        changelog: 'Complete feature implementation with enhanced UI system and comprehensive functionality.',
        screenshots: [
          'assets/screenshots/v3.1.0-alpha-dashboard.png',
          'assets/screenshots/v3.1.0-alpha-mobile.png',
        ],
        metrics: {
          'builds': 4,
          'tests': 10,
          'coverage': 78,
          'performance': 85,
          'security': 90,
        },
      ),
      VersionInfo(
        version: '3.0.0-alpha',
        date: '2026-04-01',
        title: 'Initial Release',
        description: 'Initial production-ready release with core features',
        features: [
          'Basic 6-role system',
          'Product catalog',
          'Order management',
          'Authentication system',
        ],
        screenshot: 'assets/screenshots/v3.0.0-alpha.png',
        isNew: false,
        changelog: 'Initial production-ready release with core functionality and basic features.',
        screenshots: [
          'assets/screenshots/v3.0.0-alpha-home.png',
          'assets/screenshots/v3.0.0-alpha-features.png',
        ],
        metrics: {
          'builds': 2,
          'tests': 6,
          'coverage': 70,
          'performance': 80,
          'security': 85,
        },
      ),
    ];
    notifyListeners();
  }

  void setCurrentIndex(int index) {
    _currentIndex = index;
    _recordView(_versions[index].version);
    notifyListeners();
  }

  void toggleAutoPlay() {
    _isAutoPlay = !_isAutoPlay;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query.toLowerCase();
    notifyListeners();
  }

  void toggleVersionSelection(String version) {
    if (_selectedVersions.contains(version)) {
      _selectedVersions.remove(version);
    } else {
      _selectedVersions.add(version);
    }
    notifyListeners();
  }

  void clearSelection() {
    _selectedVersions.clear();
    notifyListeners();
  }

  List<VersionInfo> get filteredVersions {
    if (_searchQuery.isEmpty) {
      return _versions;
    }
    return _versions.where((version) =>
        version.title.toLowerCase().contains(_searchQuery) ||
        version.description.toLowerCase().contains(_searchQuery) ||
        version.features.any((feature) => feature.toLowerCase().contains(_searchQuery)) ||
        version.version.toLowerCase().contains(_searchQuery)
    ).toList();
  }

  VersionInfo? getVersion(String version) {
    try {
      return _versions.firstWhere((v) => v.version == version);
    } catch (e) {
      return null;
    }
  }

  void _recordView(String version) {
    _viewCounts[version] = (_viewCounts[version] ?? 0) + 1;
    // Save to SharedPreferences
    _saveViewCounts();
  }

  Future<void> _saveViewCounts() async {
    final prefs = await SharedPreferences.getInstance();
    final viewCountsJson = _viewCounts.map((key, value) => MapEntry(key, value)).toList();
    await prefs.setString('gallery_view_counts', json.encode(viewCountsJson));
  }

  Future<void> loadViewCounts() async {
    final prefs = await SharedPreferences.getInstance();
    final viewCountsJson = prefs.getString('gallery_view_counts');
    if (viewCountsJson != null) {
      final Map<String, dynamic> decoded = json.decode(viewCountsJson);
      _viewCounts = decoded.map((key, value) => MapEntry(key, value as int));
    }
  }

  Map<String, int> get viewCounts => _viewCounts;

  VersionInfo? get mostViewedVersion {
    if (_viewCounts.isEmpty) return null;
    return _versions.reduce((a, b) =>
        (_viewCounts[a.version] ?? 0) > (_viewCounts[b.version] ?? 0) ? a : b
    );
  }
}
