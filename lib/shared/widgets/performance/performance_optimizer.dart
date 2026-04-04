import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../theme/enhanced_theme.dart';
import '../animations/enhanced_animations.dart';

/// Performance Optimization System for VedantaTrade
/// Provides performance monitoring and optimization utilities

class PerformanceOptimizer {
  static const int _maxFrameTime = 16; // 60 FPS = 16ms per frame
  static const int _slowFrameThreshold = 33; // 30 FPS = 33ms per frame
  
  static bool _performanceMonitoringEnabled = false;
  static List<FrameData> _frameData = [];
  static int _droppedFrames = 0;
  static int _totalFrames = 0;
  
  // Performance metrics
  static double get averageFrameTime {
    if (_frameData.isEmpty) return 0.0;
    return _frameData.map((f) => f.time).reduce((a, b) => a + b) / _frameData.length;
  }
  
  static double get frameRate {
    if (averageFrameTime == 0) return 60.0;
    return 1000.0 / averageFrameTime;
  }
  
  static double get droppedFrameRate {
    if (_totalFrames == 0) return 0.0;
    return (_droppedFrames / _totalFrames) * 100;
  }
  
  static bool get isPerformingWell {
    return frameRate >= 55 && droppedFrameRate <= 5;
  }
  
  static bool get hasPerformanceIssues {
    return frameRate < 30 || droppedFrameRate > 10;
  }
  
  static void enablePerformanceMonitoring() {
    _performanceMonitoringEnabled = true;
    WidgetsBinding.instance.addPostFrameCallback(_onPostFrame);
  }
  
  static void disablePerformanceMonitoring() {
    _performanceMonitoringEnabled = false;
  }
  
  static void _onPostFrame(Duration timestamp) {
    if (!_performanceMonitoringEnabled) return;
    
    // Record frame data
    final frameTime = timestamp.inMicroseconds.toDouble() / 1000.0;
    _frameData.add(FrameData(
      time: frameTime,
      timestamp: timestamp,
    ));
    
    // Keep only last 100 frames
    if (_frameData.length > 100) {
      _frameData.removeAt(0);
    }
    
    _totalFrames++;
    
    // Check for dropped frames
    if (frameTime > _slowFrameThreshold) {
      _droppedFrames++;
    }
    
    // Continue monitoring
    WidgetsBinding.instance.addPostFrameCallback(_onPostFrame);
  }
  
  static void resetMetrics() {
    _frameData.clear();
    _droppedFrames = 0;
    _totalFrames = 0;
  }
  
  static PerformanceReport getReport() {
    return PerformanceReport(
      averageFrameTime: averageFrameTime,
      frameRate: frameRate,
      droppedFrameRate: droppedFrameRate,
      totalFrames: _totalFrames,
      droppedFrames: _droppedFrames,
      isPerformingWell: isPerformingWell,
      hasPerformanceIssues: hasPerformanceIssues,
    );
  }
}

class FrameData {
  final double time;
  final DateTime timestamp;
  
  FrameData({
    required this.time,
    required this.timestamp,
  });
}

class PerformanceReport {
  final double averageFrameTime;
  final double frameRate;
  final double droppedFrameRate;
  final int totalFrames;
  final int droppedFrames;
  final bool isPerformingWell;
  final bool hasPerformanceIssues;
  
  const PerformanceReport({
    required this.averageFrameTime,
    required this.frameRate,
    required this.droppedFrameRate,
    required this.totalFrames,
    required this.droppedFrames,
    required this.isPerformingWell,
    required this.hasPerformanceIssues,
  });
}

// Optimized Widgets
class OptimizedListView extends StatefulWidget {
  final List<Widget> children;
  final ScrollController? controller;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final ScrollDirection direction;
  final bool reverse;
  final ScrollPhysics? physics;
  final bool addAutomaticKeepAlives;
  final bool addRepaintBoundaries;
  final bool addSemanticIndexes;
  final double? cacheExtent;
  final int? semanticChildCount;
  final DragStartBehavior dragStartBehavior;
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;
  final String? restorationId;
  final Clip clipBehavior;
  final bool? primary;

  const OptimizedListView({
    Key? key,
    required this.children,
    this.controller,
    this.padding,
    this.shrinkWrap = false,
    this.direction = Axis.vertical,
    this.reverse = false,
    this.physics,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.cacheExtent,
    this.semanticChildCount,
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
    this.primary,
  }) : super(key: key);

  @override
  State<OptimizedListView> createState() => _OptimizedListViewState();
}

class _OptimizedListViewState extends State<OptimizedListView> {
  @override
  Widget build(BuildContext context) {
    // Use ListView.builder for better performance with large lists
    if (widget.children.length > 50) {
      return ListView.builder(
        controller: widget.controller,
        padding: widget.padding,
        shrinkWrap: widget.shrinkWrap,
        physics: widget.physics,
        addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
        addRepaintBoundaries: widget.addRepaintBoundaries,
        addSemanticIndexes: widget.addSemanticIndexes,
        cacheExtent: widget.cacheExtent,
        semanticChildCount: widget.semanticChildCount ?? widget.children.length,
        dragStartBehavior: widget.dragStartBehavior,
        keyboardDismissBehavior: widget.keyboardDismissBehavior,
        restorationId: widget.restorationId,
        clipBehavior: widget.clipBehavior,
        primary: widget.primary,
        itemBuilder: (context, index) {
          return widget.children[index];
        },
        itemCount: widget.children.length,
      );
    }
    
    // Use Column for small lists
    return ListView(
      controller: widget.controller,
      padding: widget.padding,
      shrinkWrap: widget.shrinkWrap,
      physics: widget.physics,
      addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
      addRepaintBoundaries: widget.addRepaintBoundaries,
      addSemanticIndexes: widget.addSemanticIndexes,
      cacheExtent: widget.cacheExtent,
      semanticChildCount: widget.semanticChildCount ?? widget.children.length,
      dragStartBehavior: widget.dragStartBehavior,
      keyboardDismissBehavior: widget.keyboardDismissBehavior,
      restorationId: widget.restorationId,
      clipBehavior: widget.clipBehavior,
      primary: widget.primary,
      children: widget.children,
    );
  }
}

class OptimizedGridView extends StatefulWidget {
  final List<Widget> children;
  final SliverGridDelegate gridDelegate;
  final ScrollController? controller;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final ScrollDirection direction;
  final bool reverse;
  final ScrollPhysics? physics;
  final bool addAutomaticKeepAlives;
  final bool addRepaintBoundaries;
  final bool addSemanticIndexes;
  final double? cacheExtent;
  final int? semanticChildCount;
  final DragStartBehavior dragStartBehavior;
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;
  final String? restorationId;
  final Clip clipBehavior;
  final bool? primary;

  const OptimizedGridView({
    Key? key,
    required this.children,
    required this.gridDelegate,
    this.controller,
    this.padding,
    this.shrinkWrap = false,
    this.direction = Axis.vertical,
    this.reverse = false,
    this.physics,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.cacheExtent,
    this.semanticChildCount,
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
    this.primary,
  }) : super(key: key);

  @override
  State<OptimizedGridView> createState() => _OptimizedGridViewState();
}

class _OptimizedGridViewState extends State<OptimizedGridView> {
  @override
  Widget build(BuildContext context) {
    // Use GridView.builder for better performance with large grids
    if (widget.children.length > 50) {
      return GridView.builder(
        controller: widget.controller,
        padding: widget.padding,
        shrinkWrap: widget.shrinkWrap,
        physics: widget.physics,
        addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
        addRepaintBoundaries: widget.addRepaintBoundaries,
        addSemanticIndexes: widget.addSemanticIndexes,
        cacheExtent: widget.cacheExtent,
        semanticChildCount: widget.semanticChildCount ?? widget.children.length,
        dragStartBehavior: widget.dragStartBehavior,
        keyboardDismissBehavior: widget.keyboardDismissBehavior,
        restorationId: widget.restorationId,
        clipBehavior: widget.clipBehavior,
        primary: widget.primary,
        gridDelegate: widget.gridDelegate,
        itemBuilder: (context, index) {
          return widget.children[index];
        },
        itemCount: widget.children.length,
      );
    }
    
    // Use GridView.count for small grids
    return GridView.count(
      controller: widget.controller,
      padding: widget.padding,
      shrinkWrap: widget.shrinkWrap,
      physics: widget.physics,
      addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
      addRepaintBoundaries: widget.addRepaintBoundaries,
      addSemanticIndexes: widget.addSemanticIndexes,
      cacheExtent: widget.cacheExtent,
      semanticChildCount: widget.semanticChildCount ?? widget.children.length,
      dragStartBehavior: widget.dragStartBehavior,
      keyboardDismissBehavior: widget.keyboardDismissBehavior,
      restorationId: widget.restorationId,
      clipBehavior: widget.clipBehavior,
      primary: widget.primary,
      crossAxisCount: widget.gridDelegate is SliverGridDelegateWithFixedCrossAxisCount
          ? (widget.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount).crossAxisCount
          : 2,
      childAspectRatio: widget.gridDelegate is SliverGridDelegateWithFixedCrossAxisCount
          ? (widget.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount).childAspectRatio
          : 1.0,
      children: widget.children,
    );
  }
}

class OptimizedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final bool enableCache;
  final Duration cacheDuration;
  final String? semanticLabel;

  const OptimizedImage({
    Key? key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.enableCache = true,
    this.cacheDuration = const Duration(hours: 1),
    this.semanticLabel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget image = Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }
        
        // Show placeholder while loading
        return Container(
          width: width,
          height: height,
          color: Colors.grey[200],
          child: Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                    : null,
                strokeWidth: 2,
              ),
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return errorWidget ?? Container(
          width: width,
          height: height,
          color: Colors.grey[200],
          child: const Icon(Icons.error, color: Colors.grey),
        );
      },
      semanticLabel: semanticLabel,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) {
          return child;
        }
        
        // Add fade-in animation for loaded images
        return AnimatedOpacity(
          opacity: frame == null ? 0.0 : 1.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: child,
        );
      },
    );

    // Add accessibility
    if (semanticLabel != null) {
      image = Semantics(
        label: semanticLabel,
        image: true,
        child: image,
      );
    }

    return image;
  }
}

class LazyLoader extends StatefulWidget {
  final Widget Function() builder;
  final bool enabled;
  final Duration delay;
  final Widget? placeholder;

  const LazyLoader({
    Key? key,
    required this.builder,
    this.enabled = true,
    this.delay = const Duration(milliseconds: 100),
    this.placeholder,
  }) : super(key: key);

  @override
  State<LazyLoader> createState() => _LazyLoaderState();
}

class _LazyLoaderState extends State<LazyLoader> {
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    if (widget.enabled) {
      _loadContent();
    }
  }

  @override
  void didUpdateWidget(LazyLoader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled && !oldWidget.enabled && !_isLoaded) {
      _loadContent();
    }
  }

  void _loadContent() {
    Future.delayed(widget.delay, () {
      if (mounted && widget.enabled) {
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

class MemoryEfficientBuilder extends StatefulWidget {
  final Widget Function(BuildContext context, int index) builder;
  final int itemCount;
  final ScrollController? controller;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const MemoryEfficientBuilder({
    Key? key,
    required this.builder,
    required this.itemCount,
    this.controller,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
  }) : super(key: key);

  @override
  State<MemoryEfficientBuilder> createState() => _MemoryEfficientBuilderState();
}

class _MemoryEfficientBuilderState extends State<MemoryEfficientBuilder> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: widget.controller,
      padding: widget.padding,
      shrinkWrap: widget.shrinkWrap,
      physics: widget.physics,
      addAutomaticKeepAlives: false, // Disable to save memory
      addRepaintBoundaries: false, // Disable to save memory
      addSemanticIndexes: false, // Disable to save memory
      cacheExtent: 250.0, // Limit cache size
      itemBuilder: (context, index) {
        return widget.builder(context, index);
      },
      itemCount: widget.itemCount,
    );
  }
}

class PerformanceMonitor extends StatefulWidget {
  final Widget child;
  final bool enabled;
  final bool showOverlay;
  final Position position;
  final bool showDetailedInfo;

  const PerformanceMonitor({
    Key? key,
    required this.child,
    this.enabled = true,
    this.showOverlay = false,
    this.position = Position.topRight,
    this.showDetailedInfo = false,
  }) : super(key: key);

  @override
  State<PerformanceMonitor> createState() => _PerformanceMonitorState();
}

class _PerformanceMonitorState extends State<PerformanceMonitor> {
  @override
  void initState() {
    super.initState();
    if (widget.enabled) {
      PerformanceOptimizer.enablePerformanceMonitoring();
    }
  }

  @override
  void dispose() {
    if (widget.enabled) {
      PerformanceOptimizer.disablePerformanceMonitoring();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled || !widget.showOverlay) {
      return widget.child;
    }

    return Stack(
      children: [
        widget.child,
        Positioned(
          top: widget.position == Position.topLeft || widget.position == Position.topRight
              ? 50
              : null,
          bottom: widget.position == Position.bottomLeft || widget.position == Position.bottomRight
              ? 50
              : null,
          left: widget.position == Position.topLeft || widget.position == Position.bottomLeft
              ? 10
              : null,
          right: widget.position == Position.topRight || widget.position == Position.bottomRight
              ? 10
              : null,
          child: _PerformanceOverlay(
            showDetailedInfo: widget.showDetailedInfo,
          ),
        ),
      ],
    );
  }
}

class _PerformanceOverlay extends StatelessWidget {
  final bool showDetailedInfo;

  const _PerformanceOverlay({
    Key? key,
    required this.showDetailedInfo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final report = PerformanceOptimizer.getReport();
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.speed,
                size: 16,
                color: report.isPerformingWell
                    ? EnhancedTheme.successGreen
                    : report.hasPerformanceIssues
                        ? EnhancedTheme.errorRed
                        : EnhancedTheme.warningAmber,
              ),
              const SizedBox(width: 4),
              Text(
                '${report.frameRate.toInt()} FPS',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: report.isPerformingWell
                      ? EnhancedTheme.successGreen
                      : report.hasPerformanceIssues
                          ? EnhancedTheme.errorRed
                          : EnhancedTheme.warningAmber,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (showDetailedInfo) ...[
            const SizedBox(height: 4),
            Text(
              'Avg: ${report.averageFrameTime.toStringAsFixed(1)}ms',
              style: theme.textTheme.labelSmall,
            ),
            Text(
              'Dropped: ${report.droppedFrameRate.toStringAsFixed(1)}%',
              style: theme.textTheme.labelSmall,
            ),
          ],
        ],
      ),
    );
  }
}

// Performance Optimization Utilities
class PerformanceUtils {
  // Debounce utility
  static Function debounce(Function function, Duration delay) {
    Timer? timer;
    return () {
      timer?.cancel();
      timer = Timer(delay, () => function());
    };
  }

  // Throttle utility
  static Function throttle(Function function, Duration interval) {
    Timer? timer;
    bool isThrottled = false;
    
    return () {
      if (!isThrottled) {
        function();
        isThrottled = true;
        timer = Timer(interval, () {
          isThrottled = false;
        });
      }
    };
  }

  // Memoization utility
  static Map<String, dynamic> _memoCache = {};
  
  static T memoize<T>(String key, T Function() computation) {
    if (_memoCache.containsKey(key)) {
      return _memoCache[key] as T;
    }
    
    final result = computation();
    _memoCache[key] = result;
    return result;
  }

  static void clearMemoCache() {
    _memoCache.clear();
  }

  // Image optimization
  static String getOptimizedImageUrl(String baseUrl, String imagePath, {
    int? width,
    int? height,
    int quality = 85,
    String format = 'webp',
  }) {
    final params = <String, String>{
      if (width != null) 'w': width.toString(),
      if (height != null) 'h': height.toString(),
      'q': quality.toString(),
      'f': format,
    };
    
    final queryString = params.entries
        .map((e) => '${e.key}=${e.value}')
        .join('&');
    
    return '$baseUrl$imagePath?$queryString';
  }

  // Widget optimization
  static Widget optimizeWidget(Widget widget) {
    return RepaintBoundary(
      child: widget,
    );
  }

  static Widget constOptimize(Widget widget) {
    return const RepaintBoundary(
      child: widget,
    );
  }
}

// Enums
enum Position {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
}

// Performance Extensions
extension PerformanceExtension on Widget {
  Widget optimize() {
    return PerformanceUtils.optimizeWidget(this);
  }

  Widget constOptimize() {
    return PerformanceUtils.constOptimize(this);
  }

  Widget lazyLoad({
    Duration delay = const Duration(milliseconds: 100),
    Widget? placeholder,
  }) {
    return LazyLoader(
      builder: () => this,
      delay: delay,
      placeholder: placeholder,
    );
  }

  Widget monitorPerformance({
    bool showOverlay = false,
    Position position = Position.topRight,
    bool showDetailedInfo = false,
  }) {
    return PerformanceMonitor(
      child: this,
      enabled: true,
      showOverlay: showOverlay,
      position: position,
      showDetailedInfo: showDetailedInfo,
    );
  }
}
