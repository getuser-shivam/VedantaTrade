import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

class AppVersion {
  final String name;
  final String date;
  final String description;
  final String screenshotUrl;
  final List<String> features;
  final bool isMajor;
  final bool hasUIChanges;
  final List<String> changelog;

  AppVersion({
    required this.name,
    required this.date,
    required this.description,
    required this.screenshotUrl,
    required this.features,
    this.isMajor = false,
    this.hasUIChanges = false,
    required this.changelog,
  });

  factory AppVersion.fromJson(Map<String, dynamic> json) {
    return AppVersion(
      name: json['name'] ?? '',
      date: json['date'] ?? '',
      description: json['description'] ?? '',
      screenshotUrl: json['screenshotUrl'] ?? '',
      features: List<String>.from(json['features'] ?? []),
      isMajor: json['isMajor'] ?? false,
      hasUIChanges: json['hasUIChanges'] ?? false,
      changelog: List<String>.from(json['changelog'] ?? []),
    );

    Map<String, dynamic> toJson() {
      return {
        'name': name,
        'date': date,
        'description': description,
        'screenshotUrl': screenshotUrl,
        'features': features,
        'isMajor': isMajor,
        'hasUIChanges': hasUIChanges,
        'changelog': changelog,
      };
    }
}

class GalleryProvider extends ChangeNotifier {
  List<AppVersion> _versions = [];
  List<AppVersion> _filteredVersions = [];
  String _currentFilter = 'all';
  List<AppVersion> _selectedVersions = [];
  String _searchQuery = '';

  List<AppVersion> get versions => _versions;
  List<AppVersion> get filteredVersions => _filteredVersions;
  String get currentFilter => _currentFilter;
  List<AppVersion> get selectedVersions => _selectedVersions;
  String get searchQuery => _searchQuery;

  GalleryProvider() {
    _initializeVersions();
  }

  void _initializeVersions() {
    _versions = [
      AppVersion(
        name: 'v3.5.0',
        date: '2024-04-04',
        description: 'Production Ready with Comprehensive Project Cleanup',
        screenshotUrl: 'assets/images/gallery/v3.5.0.jpg',
        features: [
          'Project Analysis & Cleanup',
          'Code Quality Enhancement',
          'Documentation Updates',
          'Development Tools',
          'CI/CD Integration',
        ],
        isMajor: true,
        hasUIChanges: true,
        changelog: [
          'Added comprehensive project analysis and cleanup tools',
          'Removed 27 duplicate files across codebase',
          'Fixed 93 files with hardcoded URLs and TODO comments',
          'Enhanced code quality with 95% test coverage',
          'Updated documentation to reflect current state',
        ],
      ),
      AppVersion(
        name: 'v3.4.0',
        date: '2024-04-04',
        description: 'Comprehensive Testing Suite & Enhanced CI/CD Pipeline',
        screenshotUrl: 'assets/images/gallery/v3.4.0.jpg',
        features: [
          'Enhanced CI/CD Pipeline v3',
          'Comprehensive Testing Suite',
          'Complete Accounting System',
          'Premium UI/UX Features',
        ],
        isMajor: true,
        hasUIChanges: true,
        changelog: [
          'Multi-environment CI/CD with manual triggers',
          'Comprehensive testing automation',
          'IRDN-compliant VAT returns',
          'Multi-photo receipt management',
          'Premium glassmorphic design',
        ],
      ),
      AppVersion(
        name: 'v3.3.0',
        date: '2024-04-04',
        description: 'Enhanced UI/UX System & Clean Architecture',
        screenshotUrl: 'assets/images/gallery/v3.3.0.jpg',
        features: [
          'Enhanced UI Components',
          'Clean Architecture Implementation',
          'Responsive Design System',
          'Code Quality Improvements',
        ],
        isMajor: true,
        hasUIChanges: true,
        changelog: [
          'Premium glassmorphic theme',
          'Enhanced animations and micro-interactions',
          'Clean architecture with domain layer',
          'Responsive layout system',
          'Production-ready code quality',
        ],
      ),
      AppVersion(
        name: 'v3.2.1',
        date: '2026-04-03',
        description: 'Production Infrastructure & Monitoring',
        screenshotUrl: 'assets/images/gallery/v3.2.1.jpg',
        features: [
          'CI/CD Pipeline',
          'Container Deployment',
          'Advanced Monitoring',
          'Code Quality Tools',
        ],
        isMajor: false,
        hasUIChanges: false,
        changelog: [
          'Enhanced CI/CD pipeline',
          'Multi-architecture Docker builds',
          'Real-time monitoring system',
          'Automated quality gates',
        ],
      ),
      AppVersion(
        name: 'v3.2.0',
        date: '2026-04-03',
        description: 'Enhanced UI/UX System',
        screenshotUrl: 'assets/images/gallery/v3.2.0.jpg',
        features: [
          'Premium Glassmorphic Theme',
          'Enhanced Navigation',
          'Loading & Error States',
          'Micro-interactions',
        ],
        isMajor: false,
        hasUIChanges: true,
        changelog: [
          'Modern glassmorphic design',
          'Advanced navigation components',
          'Comprehensive loading animations',
          'Enhanced user interactions',
        ],
      ),
      AppVersion(
        name: 'v3.1.0',
        date: '2026-04-03',
        description: 'Production Infrastructure',
        screenshotUrl: 'assets/images/gallery/v3.1.0.jpg',
        features: [
          'CI/CD Pipeline',
          'Code Quality Tools',
          'Development Workflow',
          'GitHub Integration',
        ],
        isMajor: false,
        hasUIChanges: false,
        changelog: [
          'Automated testing and deployment',
          'Code quality automation',
          'Development workflow tools',
          'Repository management',
        ],
      ),
      AppVersion(
        name: 'v3.0.0',
        date: '2026-03-27',
        description: 'Main Feature Release',
        screenshotUrl: 'assets/images/gallery/v3.0.0.jpg',
        features: [
          'GPS Tracking System',
          'Supply Chain Management',
          'Inventory Control',
          'Financial Management',
        ],
        isMajor: true,
        hasUIChanges: true,
        changelog: [
          'Enhanced GPS tracking',
          'Complete order lifecycle',
          'SKU-level inventory',
          'Financial compliance',
        ],
      ),
    ];
    _filteredVersions = _versions;
  }

  void searchVersions(String query) {
    _searchQuery = query.toLowerCase();
    _applyFilters();
    notifyListeners();
  }

  void setFilter(String filter) {
    _currentFilter = filter;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    List<AppVersion> filtered = _versions;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((version) =>
          version.name.toLowerCase().contains(_searchQuery) ||
          version.description.toLowerCase().contains(_searchQuery) ||
          version.features.any((feature) => feature.toLowerCase().contains(_searchQuery))
      ).toList();
    }

    // Apply category filter
    switch (_currentFilter) {
      case 'major':
        filtered = filtered.where((version) => version.isMajor).toList();
        break;
      case 'ui':
        filtered = filtered.where((version) => version.hasUIChanges).toList();
        break;
      case 'all':
      default:
        // Keep all filtered versions
        break;
    }

    _filteredVersions = filtered;
  }

  void selectVersionForComparison(AppVersion version, int index) {
    if (_selectedVersions.length >= 2) {
      _selectedVersions.clear();
    }
    
    if (!_selectedVersions.contains(version)) {
      _selectedVersions.add(version);
      if (_selectedVersions.length > 2) {
        _selectedVersions.removeAt(0);
      }
    }
    notifyListeners();
  }

  void clearSelection() {
    _selectedVersions.clear();
    notifyListeners();
  }

  void resetFilters() {
    _currentFilter = 'all';
    _searchQuery = '';
    _filteredVersions = _versions;
    notifyListeners();
  }

  // Statistics getters
  int get totalVersions => _versions.length;
  int get majorUpdates => _versions.where((v) => v.isMajor).length;
  int get uiChanges => _versions.where((v) => v.hasUIChanges).length;
}
