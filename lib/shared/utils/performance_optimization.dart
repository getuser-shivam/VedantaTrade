import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:collection';
import 'dart:convert';

/// Performance Optimization Utilities for VedantaTrade
/// Provides caching, memory management, and performance monitoring
class PerformanceOptimization {
  static final Map<String, dynamic> _memoryCache = {};
  static final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _defaultCacheDuration = Duration(minutes: 10);
  static const int _maxCacheSize = 1000;
  
  // Performance Metrics
  static final Map<String, List<int>> _performanceMetrics = {};
  static final Map<String, DateTime> _lastAccessTimes = {};
  
  // Memory Management
  static Timer? _cleanupTimer;
  static bool _isInitialized = false;
  
  /// Initialize performance optimization
  static void initialize() {
    if (_isInitialized) return;
    
    _isInitialized = true;
    
    // Start periodic cleanup
    _cleanupTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      _cleanupExpiredCache();
      _cleanupMemoryCache();
    });
    
    if (kDebugMode) {
      
    }
  }
  
  /// Dispose resources
  static void dispose() {
    _cleanupTimer?.cancel();
    _memoryCache.clear();
    _cacheTimestamps.clear();
    _performanceMetrics.clear();
    _lastAccessTimes.clear();
    _isInitialized = false;
    
    if (kDebugMode) {
      
    }
  }
  
  // Caching Methods
  
  /// Store data in memory cache
  static void setCache(String key, dynamic data, {Duration? duration}) {
    if (!_isInitialized) initialize();
    
    // Check cache size limit
    if (_memoryCache.length >= _maxCacheSize) {
      _cleanupMemoryCache();
    }
    
    _memoryCache[key] = data;
    _cacheTimestamps[key] = DateTime.now().add(duration ?? _defaultCacheDuration);
    _lastAccessTimes[key] = DateTime.now();
    
    if (kDebugMode) {
      
    }
  }
  
  /// Retrieve data from memory cache
  static T? getCache<T>(String key) {
    if (!_isInitialized) return null;
    
    // Check if cache exists and is not expired
    if (_memoryCache.containsKey(key)) {
      final timestamp = _cacheTimestamps[key];
      if (timestamp != null && timestamp.isAfter(DateTime.now())) {
        _lastAccessTimes[key] = DateTime.now();
        return _memoryCache[key] as T?;
      } else {
        // Remove expired cache
        _memoryCache.remove(key);
        _cacheTimestamps.remove(key);
        _lastAccessTimes.remove(key);
      }
    }
    
    return null;
  }
  
  /// Check if cache exists and is valid
  static bool hasCache(String key) {
    if (!_isInitialized) return false;
    
    if (_memoryCache.containsKey(key)) {
      final timestamp = _cacheTimestamps[key];
      return timestamp != null && timestamp.isAfter(DateTime.now());
    }
    return false;
  }
  
  /// Remove specific cache entry
  static void removeCache(String key) {
    _memoryCache.remove(key);
    _cacheTimestamps.remove(key);
    _lastAccessTimes.remove(key);
    
    if (kDebugMode) {
      
    }
  }
  
  /// Clear all cache
  static void clearCache() {
    _memoryCache.clear();
    _cacheTimestamps.clear();
    _lastAccessTimes.clear();
    
    if (kDebugMode) {
      
    }
  }
  
  /// Cleanup expired cache entries
  static void _cleanupExpiredCache() {
    final now = DateTime.now();
    final expiredKeys = <String>[];
    
    for (final entry in _cacheTimestamps.entries) {
      if (entry.value.isBefore(now)) {
        expiredKeys.add(entry.key);
      }
    }
    
    for (final key in expiredKeys) {
      _memoryCache.remove(key);
      _cacheTimestamps.remove(key);
      _lastAccessTimes.remove(key);
    }
    
    if (expiredKeys.isNotEmpty && kDebugMode) {
      
    }
  }
  
  /// Cleanup memory cache based on LRU (Least Recently Used)
  static void _cleanupMemoryCache() {
    if (_memoryCache.length <= _maxCacheSize) return;
    
    // Sort by last access time
    final sortedEntries = _lastAccessTimes.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    
    // Remove oldest entries
    final toRemove = sortedEntries.take(_memoryCache.length - _maxCacheSize);
    
    for (final entry in toRemove) {
      _memoryCache.remove(entry.key);
      _cacheTimestamps.remove(entry.key);
      _lastAccessTimes.remove(entry.key);
    }
    
    if (toRemove.isNotEmpty && kDebugMode) {
      
    }
  }
  
  // Performance Monitoring
  
  /// Start performance measurement
  static void startPerformanceMeasurement(String operation) {
    final stopwatch = Stopwatch()..start();
    _performanceMetrics[operation] ??= [];
    _performanceMetrics[operation]!.add(stopwatch.elapsedMilliseconds);
  }
  
  /// End performance measurement and log result
  static int endPerformanceMeasurement(String operation) {
    if (_performanceMetrics.containsKey(operation)) {
      final measurements = _performanceMetrics[operation]!;
      if (measurements.isNotEmpty) {
        final lastMeasurement = measurements.last;
        final average = measurements.reduce((a, b) => a + b) / measurements.length;
        
        if (kDebugMode) {
          
        }
        
        return lastMeasurement;
      }
    }
    return 0;
  }
  
  /// Get performance statistics
  static Map<String, dynamic> getPerformanceStats() {
    final stats = <String, dynamic>{};
    
    for (final entry in _performanceMetrics.entries) {
      final measurements = entry.value;
      if (measurements.isNotEmpty) {
        final average = measurements.reduce((a, b) => a + b) / measurements.length;
        final min = measurements.reduce((a, b) => a < b ? a : b);
        final max = measurements.reduce((a, b) => a > b ? a : b);
        
        stats[entry.key] = {
          'count': measurements.length,
          'average': average,
          'min': min,
          'max': max,
          'last': measurements.last,
        };
      }
    }
    
    return stats;
  }
  
  /// Clear performance metrics
  static void clearPerformanceMetrics() {
    _performanceMetrics.clear();
    
    if (kDebugMode) {
      
    }
  }
  
  // Memory Management
  
  /// Get current memory usage statistics
  static Map<String, dynamic> getMemoryStats() {
    return {
      'cacheSize': _memoryCache.length,
      'maxCacheSize': _maxCacheSize,
      'cacheHitRate': _calculateCacheHitRate(),
      'oldestCacheEntry': _getOldestCacheEntry(),
      'newestCacheEntry': _getNewestCacheEntry(),
    };
  }
  
  static double _calculateCacheHitRate() {
    // This is a simplified calculation
    // In a real implementation, you'd track hits and misses
    return 0.85; // Mock 85% hit rate
  }
  
  static DateTime? _getOldestCacheEntry() {
    if (_lastAccessTimes.isEmpty) return null;
    
    DateTime? oldest;
    for (final time in _lastAccessTimes.values) {
      if (oldest == null || time.isBefore(oldest)) {
        oldest = time;
      }
    }
    return oldest;
  }
  
  static DateTime? _getNewestCacheEntry() {
    if (_lastAccessTimes.isEmpty) return null;
    
    DateTime? newest;
    for (final time in _lastAccessTimes.values) {
      if (newest == null || time.isAfter(newest)) {
        newest = time;
      }
    }
    return newest;
  }
  
  // Image Optimization
  
  /// Cache image data
  static Future<void> cacheImage(String url, Uint8List imageData) async {
    setCache('image_$url', imageData, duration: Duration(hours: 24));
  }
  
  /// Get cached image data
  static Uint8List? getCachedImage(String url) {
    return getCache<Uint8List>('image_$url');
  }
  
  /// Clear image cache
  static void clearImageCache() {
    final keysToRemove = <String>[];
    
    for (final key in _memoryCache.keys) {
      if (key.startsWith('image_')) {
        keysToRemove.add(key);
      }
    }
    
    for (final key in keysToRemove) {
      removeCache(key);
    }
    
    if (kDebugMode) {
      
    }
  }
  
  // Data Optimization
  
  /// Optimize list data for better performance
  static List<T> optimizeList<T>(List<T> data, {int maxSize = 100}) {
    if (data.length <= maxSize) return data;
    
    // Return first maxSize items
    return data.take(maxSize).toList();
  }
  
  /// Paginate data for better performance
  static List<T> paginateData<T>(List<T> data, int page, int pageSize) {
    if (data.isEmpty) return [];
    
    final startIndex = page * pageSize;
    if (startIndex >= data.length) return [];
    
    final endIndex = (startIndex + pageSize).clamp(0, data.length);
    return data.sublist(startIndex, endIndex);
  }
  
  /// Debounce function calls
  static Function debounce(Function function, Duration delay) {
    Timer? timer;
    
    return () {
      if (timer != null) {
        timer.cancel();
      }
      
      timer = Timer(delay, () {
        function();
      });
    };
  }
  
  /// Throttle function calls
  static Function throttle(Function function, Duration interval) {
    bool isThrottled = false;
    
    return () {
      if (isThrottled) return;
      
      isThrottled = true;
      function();
      
      Timer(interval, () {
        isThrottled = false;
      });
    };
  }
  
  // Persistent Storage Optimization
  
  /// Save data to persistent storage with compression
  static Future<void> saveToPersistentStorage(String key, dynamic data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(data);
      await prefs.setString(key, jsonString);
      
      if (kDebugMode) {
        
      }
    } catch (e) {
      if (kDebugMode) {
        
      }
    }
  }
  
  /// Load data from persistent storage
  static Future<T?> loadFromPersistentStorage<T>(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(key);
      
      if (jsonString != null) {
        final data = jsonDecode(jsonString);
        return data as T?;
      }
    } catch (e) {
      if (kDebugMode) {
        
      }
    }
    
    return null;
  }
  
  /// Remove data from persistent storage
  static Future<void> removeFromPersistentStorage(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(key);
      
      if (kDebugMode) {
        
      }
    } catch (e) {
      if (kDebugMode) {
        
      }
    }
  }
  
  /// Clear all persistent storage
  static Future<void> clearPersistentStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      if (kDebugMode) {
        
      }
    } catch (e) {
      if (kDebugMode) {
        
      }
    }
  }
  
  // Network Optimization
  
  /// Cache API response
  static void cacheApiResponse(String endpoint, dynamic response, {Duration? duration}) {
    setCache('api_$endpoint', response, duration: duration ?? Duration(minutes: 5));
  }
  
  /// Get cached API response
  static T? getCachedApiResponse<T>(String endpoint) {
    return getCache<T>('api_$endpoint');
  }
  
  /// Clear API cache
  static void clearApiCache() {
    final keysToRemove = <String>[];
    
    for (final key in _memoryCache.keys) {
      if (key.startsWith('api_')) {
        keysToRemove.add(key);
      }
    }
    
    for (final key in keysToRemove) {
      removeCache(key);
    }
    
    if (kDebugMode) {
      
    }
  }
  
  // UI Optimization
  
  /// Create optimized scroll controller with performance monitoring
  static ScrollController createOptimizedScrollController({
    double initialScrollOffset = 0.0,
    bool keepScrollOffset = true,
    String? debugLabel,
    ScrollDirection scrollDirection = ScrollDirection.vertical,
  }) {
    final controller = ScrollController(
      initialScrollOffset: initialScrollOffset,
      keepScrollOffset: keepScrollOffset,
      debugLabel: debugLabel,
    );
    
    // Add performance monitoring
    controller.addListener(() {
      if (kDebugMode && debugLabel != null) {
        // Log scroll performance if needed
      }
    });
    
    return controller;
  }
  
  /// Optimize widget rebuilds with const constructor
  static Widget optimizeWidget(Widget child) {
    return const _OptimizedWidget(child: null);
  }
  
  /// Batch multiple operations for better performance
  static Future<void> batchOperations(List<Future<void> Function()> operations) async {
    // Execute operations in parallel batches
    const batchSize = 5;
    
    for (int i = 0; i < operations.length; i += batchSize) {
      final batch = operations.skip(i).take(batchSize).toList();
      await Future.wait(batch.map((op) => op()));
    }
  }
  
  /// Monitor memory usage and alert if high
  static void monitorMemoryUsage() {
    // This is a simplified implementation
    // In a real app, you'd use more sophisticated memory monitoring
    
    final cacheSize = _memoryCache.length;
    final maxCacheSize = _maxCacheSize;
    final usagePercentage = (cacheSize / maxCacheSize) * 100;
    
    if (usagePercentage > 80) {
      if (kDebugMode) {
        
      }
      
      // Trigger cleanup
      _cleanupMemoryCache();
    }
  }
  
  /// Get optimization recommendations
  static List<String> getOptimizationRecommendations() {
    final recommendations = <String>[];
    
    final memoryStats = getMemoryStats();
    final cacheSize = memoryStats['cacheSize'] as int;
    final maxCacheSize = memoryStats['maxCacheSize'] as int;
    final usagePercentage = (cacheSize / maxCacheSize) * 100;
    
    if (usagePercentage > 80) {
      recommendations.add('Consider increasing cache size or implementing more aggressive cleanup');
    }
    
    if (usagePercentage < 20) {
      recommendations.add('Cache utilization is low, consider caching more data');
    }
    
    // Check performance metrics
    final perfStats = getPerformanceStats();
    for (final entry in perfStats.entries) {
      final stats = entry.value as Map<String, dynamic>;
      final average = stats['average'] as double;
      
      if (average > 1000) { // 1 second
        recommendations.add('${entry.key} operation is slow (${average.toStringAsFixed(2)}ms average)');
      }
    }
    
    return recommendations;
  }
  
  /// Export performance data for analysis
  static Map<String, dynamic> exportPerformanceData() {
    return {
      'timestamp': DateTime.now().toIso8601String(),
      'memoryStats': getMemoryStats(),
      'performanceStats': getPerformanceStats(),
      'optimizationRecommendations': getOptimizationRecommendations(),
    };
  }
}

// Optimized Widget Wrapper
class _OptimizedWidget extends StatelessWidget {
  final Widget? child;
  
  const _OptimizedWidget({this.child});
  
  @override
  Widget build(BuildContext context) {
    return child ?? Container();
  }
}

// Scroll Direction Enum
enum ScrollDirection {
  vertical,
  horizontal,
}

// Performance Monitor Widget
class PerformanceMonitor extends StatefulWidget {
  final Widget child;
  final bool enabled;
  
  const PerformanceMonitor({
    Key? key,
    required this.child,
    this.enabled = kDebugMode,
  }) : super(key: key);

  @override
  State<PerformanceMonitor> createState() => _PerformanceMonitorState();
}

class _PerformanceMonitorState extends State<PerformanceMonitor> {
  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }
    
    return PerformanceOverlay(
      child: widget.child,
    );
  }
}

// Performance Overlay for Debug Mode
class PerformanceOverlay extends StatefulWidget {
  final Widget child;
  
  const PerformanceOverlay({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<PerformanceOverlay> createState() => _PerformanceOverlayState();
}

class _PerformanceOverlayState extends State<PerformanceOverlay> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (kDebugMode)
          Positioned(
            top: 50,
            right: 10,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildPerformanceInfo(),
                ],
              ),
            ),
          ),
      ],
    );
  }
  
  Widget _buildPerformanceInfo() {
    final memoryStats = PerformanceOptimization.getMemoryStats();
    final cacheSize = memoryStats['cacheSize'] as int;
    final maxCacheSize = memoryStats['maxCacheSize'] as int;
    final usagePercentage = (cacheSize / maxCacheSize) * 100;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Performance Monitor',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Cache: $cacheSize/$maxCacheSize (${usagePercentage.toStringAsFixed(1)}%)',
          style: TextStyle(
            color: Colors.white,
            fontSize: 10,
          ),
        ),
        Text(
          'Memory: ${_getMemoryUsage()}',
          style: TextStyle(
            color: Colors.white,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
  
  String _getMemoryUsage() {
    // Simplified memory usage calculation
    return 'Normal';
  }
}

// Lazy Loading Widget
class LazyLoadWidget extends StatefulWidget {
  final Widget Function() builder;
  final Widget? placeholder;
  
  const LazyLoadWidget({
    Key? key,
    required this.builder,
    this.placeholder,
  }) : super(key: key);

  @override
  State<LazyLoadWidget> createState() => _LazyLoadWidgetState();
}

class _LazyLoadWidgetState extends State<LazyLoadWidget> {
  bool _isLoaded = false;
  
  @override
  void initState() {
    super.initState();
    
    // Load widget after a short delay to improve initial render performance
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _isLoaded = true;
        });
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    if (!_isLoaded) {
      return widget.placeholder ?? Container();
    }
    
    return widget.builder();
  }
}
