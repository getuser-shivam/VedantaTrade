import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class AppVersion {
  final String version;
  final String releaseDate;
  final String status;
  final String buildNumber;
  final String platform;
  final String description;
  final List<String> screenshots;
  final List<String> features;
  final List<String> changelog;
  final bool isFeatured;

  AppVersion({
    required this.version,
    required this.releaseDate,
    required this.status,
    required this.buildNumber,
    required this.platform,
    required this.description,
    required this.screenshots,
    required this.features,
    required this.changelog,
    this.isFeatured = false,
  });

  factory AppVersion.fromJson(Map<String, dynamic> json) {
    return AppVersion(
      version: json['version'] ?? '',
      releaseDate: json['releaseDate'] ?? '',
      status: json['status'] ?? 'Stable',
      buildNumber: json['buildNumber'] ?? '',
      platform: json['platform'] ?? 'Multi-Platform',
      description: json['description'] ?? '',
      screenshots: List<String>.from(json['screenshots'] ?? []),
      features: List<String>.from(json['features'] ?? []),
      changelog: List<String>.from(json['changelog'] ?? []),
      isFeatured: json['isFeatured'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'releaseDate': releaseDate,
      'status': status,
      'buildNumber': buildNumber,
      'platform': platform,
      'description': description,
      'screenshots': screenshots,
      'features': features,
      'changelog': changelog,
      'isFeatured': isFeatured,
    };
  }
}

class GalleryProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;
  
  List<AppVersion> _versions = [];
  AppVersion? _selectedVersion1;
  AppVersion? _selectedVersion2;
  
  // Filters
  String _searchQuery = '';
  List<String> _selectedFeatures = [];
  String _sortBy = 'version';

  // Getters
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String? get errorMessage => _errorMessage;
  
  List<AppVersion> get versions => _filteredVersions;
  List<AppVersion> get featuredVersions => _versions.where((v) => v.isFeatured).toList();
  
  AppVersion? get selectedVersion1 => _selectedVersion1;
  AppVersion? get selectedVersion2 => _selectedVersion2;
  
  String get searchQuery => _searchQuery;
  List<String> get selectedFeatures => _selectedFeatures;
  String get sortBy => _sortBy;

  // Computed getter for filtered versions
  List<AppVersion> get _filteredVersions {
    var filtered = List<AppVersion>.from(_versions);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((version) {
        return version.version.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               version.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               version.features.any((feature) => 
                   feature.toLowerCase().contains(_searchQuery.toLowerCase()));
      }).toList();
    }

    // Apply feature filter
    if (_selectedFeatures.isNotEmpty) {
      filtered = filtered.where((version) {
        return _selectedFeatures.any((feature) => 
            version.features.contains(feature));
      }).toList();
    }

    // Apply sorting
    switch (_sortBy) {
      case 'version':
        filtered.sort((a, b) => _compareVersions(b.version, a.version));
        break;
      case 'date':
        filtered.sort((a, b) => b.releaseDate.compareTo(a.releaseDate));
        break;
      case 'name':
        filtered.sort((a, b) => a.version.compareTo(b.version));
        break;
    }

    return filtered;
  }

  Future<void> loadGalleryData() async {
    _setLoading(true);
    _hasError = false;
    _errorMessage = null;

    try {
      // Load from JSON file
      final String response = await rootBundle.loadString('assets/data/versions.json');
      final List<dynamic> data = json.decode(response);
      _versions = data.map((json) => AppVersion.fromJson(json)).toList();

      _hasError = false;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _hasError = true;
      _errorMessage = 'Failed to load gallery data: ${e.toString()}';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  void selectVersion1(AppVersion? version) {
    _selectedVersion1 = version;
    notifyListeners();
  }

  void selectVersion2(AppVersion? version) {
    _selectedVersion2 = version;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedFeatures(List<String> features) {
    _selectedFeatures = features;
    notifyListeners();
  }

  void setSortBy(String sortBy) {
    _sortBy = sortBy;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedFeatures = [];
    _sortBy = 'version';
    notifyListeners();
  }

  Future<void> addVersion(AppVersion version) async {
    _setLoading(true);
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));
      
      _versions.insert(0, version);
      notifyListeners();
    } catch (e) {
      _hasError = true;
      _errorMessage = 'Failed to add version: ${e.toString()}';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateVersion(AppVersion version) async {
    _setLoading(true);
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));
      
      final index = _versions.indexWhere((v) => v.version == version.version);
      if (index != -1) {
        _versions[index] = version;
        notifyListeners();
      }
    } catch (e) {
      _hasError = true;
      _errorMessage = 'Failed to update version: ${e.toString()}';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteVersion(String version) async {
    _setLoading(true);
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));
      
      _versions.removeWhere((v) => v.version == version);
      
      // Clear selections if deleted version was selected
      if (_selectedVersion1?.version == version) {
        _selectedVersion1 = null;
      }
      if (_selectedVersion2?.version == version) {
        _selectedVersion2 = null;
      }
      
      notifyListeners();
    } catch (e) {
      _hasError = true;
      _errorMessage = 'Failed to delete version: ${e.toString()}';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    _hasError = false;
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Helper method to compare version numbers
  int _compareVersions(String a, String b) {
    final aParts = a.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final bParts = b.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    
    for (int i = 0; i < aParts.length && i < bParts.length; i++) {
      if (aParts[i] != bParts[i]) {
        return aParts[i].compareTo(bParts[i]);
      }
    }
    
    return aParts.length.compareTo(bParts.length);
  }

  // Get all unique features across all versions
  List<String> get allFeatures {
    final features = <String>{};
    for (final version in _versions) {
      features.addAll(version.features);
    }
    return features.toList()..sort();
  }

  // Get version statistics
  Map<String, dynamic> get statistics {
    return {
      'totalVersions': _versions.length,
      'featuredVersions': featuredVersions.length,
      'totalScreenshots': _versions.fold<int>(0, (sum, v) => sum + v.screenshots.length),
      'totalFeatures': allFeatures.length,
      'latestVersion': _versions.isNotEmpty ? _versions.first.version : null,
    };
  }
}
