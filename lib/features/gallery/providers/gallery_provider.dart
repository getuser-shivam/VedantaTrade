import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class GalleryStats {
  final int totalViews;
  final int uniqueUsers;
  final int avgSessionDuration;
  final Map<String, int> versionViews;
  final String mostViewedVersion;
  final DateTime lastUpdated;

  GalleryStats({
    required this.totalViews,
    required this.uniqueUsers,
    required this.avgSessionDuration,
    required this.versionViews,
    required this.mostViewedVersion,
    required this.lastUpdated,
  });
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
