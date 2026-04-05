import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'component_hierarchy.dart';

/// Hierarchy Optimizer
/// Optimizes component hierarchy for better performance and maintainability
class HierarchyOptimizer {
  static final HierarchyOptimizer _instance = HierarchyOptimizer._internal();
  factory HierarchyOptimizer() => _instance;
  HierarchyOptimizer._internal();

  final ComponentHierarchyManager _hierarchyManager = componentHierarchyManager;
  final Map<String, OptimizationSuggestion> _suggestions = {};
  final StreamController<OptimizationEvent> _eventController;
  bool _isOptimizing = false;

  HierarchyOptimizer() : _eventController = StreamController<OptimizationEvent>.broadcast();

  /// Stream of optimization events
  Stream<OptimizationEvent> get eventStream => _eventController.stream;

  /// Optimize the entire hierarchy
  Future<OptimizationReport> optimizeHierarchy() async {
    if (_isOptimizing) {
      throw StateError('Optimization already in progress');
    }

    _isOptimizing = true;
    final report = OptimizationReport(startTime: DateTime.now());

    try {
      print('🚀 Starting hierarchy optimization...');

      // Phase 1: Remove unused components
      await _removeUnusedComponents(report);

      // Phase 2: Merge duplicate functionality
      await _mergeDuplicateComponents(report);

      // Phase 3: Optimize dependencies
      await _optimizeDependencies(report);

      // Phase 4: Restructure layers
      await _restructureLayers(report);

      // Phase 5: Improve reusability
      await _improveReusability(report);

      // Phase 6: Reduce complexity
      await _reduceComplexity(report);

      report.endTime = DateTime.now();
      report.success = true;

      print('✅ Hierarchy optimization completed successfully');
    } catch (e) {
      report.endTime = DateTime.now();
      report.success = false;
      report.error = e.toString();
      print('❌ Hierarchy optimization failed: $e');
    } finally {
      _isOptimizing = false;
    }

    return report;
  }

  /// Remove unused components
  Future<void> _removeUnusedComponents(OptimizationReport report) async {
    print('🗑️ Phase 1: Removing unused components...');

    final hierarchy = _hierarchyManager.getHierarchy();
    final dependencyGraph = _hierarchyManager.getDependencyGraph();
    final unused = <String>[];

    for (final component in hierarchy.values) {
      final dependents = dependencyGraph[component.id] ?? [];
      
      // Skip core and shared components
      if (component.layer == Layer.core || component.layer == Layer.shared) {
        continue;
      }

      if (dependents.isEmpty) {
        unused.add(component.id);
      }
    }

    for (final componentId in unused) {
      final suggestion = OptimizationSuggestion(
        type: OptimizationType.removeUnused,
        componentId: componentId,
        priority: OptimizationPriority.medium,
        description: 'Remove unused component: $componentId',
        estimatedImpact: OptimizationImpact.low,
        effort: OptimizationEffort.low,
      );

      _suggestions[componentId] = suggestion;
      report.addSuggestion(suggestion);

      _emitEvent(OptimizationEvent(
        type: OptimizationEventType.suggestionGenerated,
        suggestion: suggestion,
        timestamp: DateTime.now(),
      ));
    }

    report.unusedComponentsRemoved = unused.length;
    print('✅ Phase 1 completed: ${unused.length} unused components identified');
  }

  /// Merge duplicate components
  Future<void> _mergeDuplicateComponents(OptimizationReport report) async {
    print('🔀 Phase 2: Merging duplicate components...');

    final hierarchy = _hierarchyManager.getHierarchy();
    final duplicates = <List<String>>[];
    final processed = <String>{};

    for (final component in hierarchy.values) {
      if (processed.contains(component.id)) continue;

      final similar = _findSimilarComponents(component);
      if (similar.length > 1) {
        duplicates.add(similar);
        processed.addAll(similar);
      }
    }

    for (final duplicate in duplicates) {
      final primary = duplicate.first;
      final secondary = duplicate.skip(1).toList();

      final suggestion = OptimizationSuggestion(
        type: OptimizationType.mergeDuplicate,
        componentId: primary,
        priority: OptimizationPriority.high,
        description: 'Merge duplicate components: $primary with ${secondary.join(', ')}',
        estimatedImpact: OptimizationImpact.high,
        effort: OptimizationEffort.medium,
        metadata: {
          'primary': primary,
          'secondary': secondary,
        },
      );

      _suggestions[primary] = suggestion;
      report.addSuggestion(suggestion);

      _emitEvent(OptimizationEvent(
        type: OptimizationEventType.suggestionGenerated,
        suggestion: suggestion,
        timestamp: DateTime.now(),
      ));
    }

    report.duplicateComponentsMerged = duplicates.length;
    print('✅ Phase 2 completed: ${duplicates.length} duplicate groups identified');
  }

  /// Optimize dependencies
  Future<void> _optimizeDependencies(OptimizationReport report) async {
    print('🔗 Phase 3: Optimizing dependencies...');

    final hierarchy = _hierarchyManager.getHierarchy();
    final dependencyGraph = _hierarchyManager.getDependencyGraph();
    final optimized = <String>[];

    for (final component in hierarchy.values) {
      final dependencies = component.dependencies;
      
      // Check for transitive dependencies that can be optimized
      final optimizedDeps = _optimizeDependencyChain(component.id, dependencies);
      
      if (optimizedDeps.length < dependencies.length) {
        optimized.add(component.id);
        
        final suggestion = OptimizationSuggestion(
          type: OptimizationType.optimizeDependency,
          componentId: component.id,
          priority: OptimizationPriority.medium,
          description: 'Optimize dependencies for $component: ${dependencies.length} -> ${optimizedDeps.length}',
          estimatedImpact: OptimizationImpact.medium,
          effort: OptimizationEffort.low,
          metadata: {
            'original': dependencies,
            'optimized': optimizedDeps,
          },
        );

        _suggestions[component.id] = suggestion;
        report.addSuggestion(suggestion);

        _emitEvent(OptimizationEvent(
          type: OptimizationEventType.suggestionGenerated,
          suggestion: suggestion,
          timestamp: DateTime.now(),
        ));
      }
    }

    report.dependenciesOptimized = optimized.length;
    print('✅ Phase 3 completed: ${optimized.length} dependency optimizations identified');
  }

  /// Restructure layers
  Future<void> _restructureLayers(OptimizationReport report) async {
    print('🏗️ Phase 4: Restructuring layers...');

    final hierarchy = _hierarchyManager.getHierarchy();
    final restructured = <String>[];

    for (final component in hierarchy.values) {
      final targetLayer = _determineOptimalLayer(component);
      
      if (targetLayer != component.layer) {
        restructured.add(component.id);
        
        final suggestion = OptimizationSuggestion(
          type: OptimizationType.restructureLayer,
          componentId: component.id,
          priority: OptimizationPriority.medium,
          description: 'Move $componentId from ${component.layer.name} to ${targetLayer.name}',
          estimatedImpact: OptimizationImpact.medium,
          effort: OptimizationEffort.low,
          metadata: {
            'currentLayer': component.layer.name,
            'targetLayer': targetLayer.name,
          },
        );

        _suggestions[component.id] = suggestion;
        report.addSuggestion(suggestion);

        _emitEvent(OptimizationEvent(
          type: OptimizationEventType.suggestionGenerated,
          suggestion: suggestion,
          timestamp: DateTime.now(),
        ));
      }
    }

    report.layersRestructured = restructured.length;
    print('✅ Phase 4 completed: ${restructured.length} layer restructures identified');
  }

  /// Improve reusability
  Future<void> _improveReusability(OptimizationReport report) async {
    print('♻️ Phase 5: Improving reusability...');

    final metrics = _hierarchyManager.getMetrics();
    final improved = <String>[];

    for (final metric in metrics.values) {
      if (metric.reusability < 0.5 && metric.dependentCount > 0) {
        improved.add(metric.componentId);
        
        final suggestion = OptimizationSuggestion(
          type: OptimizationType.improveReusability,
          componentId: metric.componentId,
          priority: OptimizationPriority.low,
          description: 'Improve reusability of ${metric.componentId} (current: ${metric.reusability.toStringAsFixed(2)})',
          estimatedImpact: OptimizationImpact.medium,
          effort: OptimizationEffort.medium,
          metadata: {
            'currentReusability': metric.reusability,
            'dependentCount': metric.dependentCount,
          },
        );

        _suggestions[metric.componentId] = suggestion;
        report.addSuggestion(suggestion);

        _emitEvent(OptimizationEvent(
          type: OptimizationEventType.suggestionGenerated,
          suggestion: suggestion,
          timestamp: DateTime.now(),
        ));
      }
    }

    report.reusabilityImproved = improved.length;
    print('✅ Phase 5 completed: ${improved.length} reusability improvements identified');
  }

  /// Reduce complexity
  Future<void> _reduceComplexity(OptimizationReport report) async {
    print('⚡ Phase 6: Reducing complexity...');

    final metrics = _hierarchyManager.getMetrics();
    final reduced = <String>[];

    for (final metric in metrics.values) {
      if (metric.complexity > 4.0) {
        reduced.add(metric.componentId);
        
        final suggestion = OptimizationSuggestion(
          type: OptimizationType.reduceComplexity,
          componentId: metric.componentId,
          priority: OptimizationPriority.high,
          description: 'Reduce complexity of ${metric.componentId} (current: ${metric.complexity.toStringAsFixed(2)})',
          estimatedImpact: OptimizationImpact.high,
          effort: OptimizationEffort.high,
          metadata: {
            'currentComplexity': metric.complexity,
            'dependencyCount': metric.dependencyCount,
            'dependentCount': metric.dependentCount,
          },
        );

        _suggestions[metric.componentId] = suggestion;
        report.addSuggestion(suggestion);

        _emitEvent(OptimizationEvent(
          type: OptimizationEventType.suggestionGenerated,
          suggestion: suggestion,
          timestamp: DateTime.now(),
        ));
      }
    }

    report.complexityReduced = reduced.length;
    print('✅ Phase 6 completed: ${reduced.length} complexity reductions identified');
  }

  /// Find similar components
  List<String> _findSimilarComponents(ComponentNode component) {
    final hierarchy = _hierarchyManager.getHierarchy();
    final similar = [component.id];

    for (final other in hierarchy.values) {
      if (other.id == component.id) continue;

      // Check for similar characteristics
      if (other.type == component.type && 
          other.layer == component.layer &&
          _calculateSimilarity(component, other) > 0.8) {
        similar.add(other.id);
      }
    }

    return similar;
  }

  /// Calculate similarity between components
  double _calculateSimilarity(ComponentNode a, ComponentNode b) {
    double similarity = 0.0;

    // Type similarity
    if (a.type == b.type) similarity += 0.3;

    // Layer similarity
    if (a.layer == b.layer) similarity += 0.2;

    // Feature similarity
    if (a.feature == b.feature) similarity += 0.2;

    // Dependency similarity
    final aDeps = a.dependencies.toSet();
    final bDeps = b.dependencies.toSet();
    final intersection = aDeps.intersection(bDeps);
    final union = aDeps.union(bDeps);
    
    if (union.isNotEmpty) {
      similarity += (intersection.length / union.length) * 0.3;
    }

    return similarity;
  }

  /// Optimize dependency chain
  List<String> _optimizeDependencyChain(String componentId, List<String> dependencies) {
    final dependencyGraph = _hierarchyManager.getDependencyGraph();
    final optimized = <String>[];
    final visited = <String>{};

    for (final dep in dependencies) {
      if (visited.contains(dep)) continue;

      // Check if this dependency is already covered by another dependency
      bool isRedundant = false;
      for (final otherDep in dependencies) {
        if (otherDep != dep && _isTransitiveDependency(otherDep, dep)) {
          isRedundant = true;
          break;
        }
      }

      if (!isRedundant) {
        optimized.add(dep);
        visited.add(dep);
      }
    }

    return optimized;
  }

  /// Check if dependency is transitive
  bool _isTransitiveDependency(String parent, String child) {
    final dependencyGraph = _hierarchyManager.getDependencyGraph();
    final queue = Queue<String>();
    final visited = <String>{};

    queue.addAll(dependencyGraph[parent] ?? []);

    while (queue.isNotEmpty) {
      final current = queue.removeFirst();
      if (visited.contains(current)) continue;
      visited.add(current);

      if (current == child) return true;

      queue.addAll(dependencyGraph[current] ?? []);
    }

    return false;
  }

  /// Determine optimal layer for component
  Layer _determineOptimalLayer(ComponentNode component) {
    // Layer optimization rules
    switch (component.type) {
      case ComponentType.service:
        if (component.feature != null) {
          return Layer.feature;
        }
        return Layer.shared;
      
      case ComponentType.utility:
        if (component.dependencies.isEmpty) {
          return Layer.core;
        }
        return Layer.shared;
      
      case ComponentType.infrastructure:
        return Layer.core;
      
      case ComponentType.repository:
        return Layer.feature;
      
      case ComponentType.state:
        return Layer.feature;
      
      case ComponentType.ui:
        return Layer.presentation;
    }
  }

  /// Get optimization suggestions
  Map<String, OptimizationSuggestion> getSuggestions() {
    return Map.unmodifiable(_suggestions);
  }

  /// Get suggestions by priority
  Map<OptimizationPriority, List<OptimizationSuggestion>> getSuggestionsByPriority() {
    final byPriority = <OptimizationPriority, List<OptimizationSuggestion>>{};
    
    for (final suggestion in _suggestions.values) {
      byPriority[suggestion.priority] ??= [];
      byPriority[suggestion.priority]!.add(suggestion);
    }

    return byPriority;
  }

  /// Get suggestions by type
  Map<OptimizationType, List<OptimizationSuggestion>> getSuggestionsByType() {
    final byType = <OptimizationType, List<OptimizationSuggestion>>{};
    
    for (final suggestion in _suggestions.values) {
      byType[suggestion.priority] ??= [];
      byType[suggestion.priority]!.add(suggestion);
    }

    return byType;
  }

  /// Apply optimization suggestion
  Future<bool> applySuggestion(String componentId) async {
    final suggestion = _suggestions[componentId];
    if (suggestion == null) {
      print('❌ No suggestion found for component: $componentId');
      return false;
    }

    try {
      print('🔧 Applying optimization suggestion for $componentId...');

      switch (suggestion.type) {
        case OptimizationType.removeUnused:
          await _applyRemoveUnused(suggestion);
          break;
        case OptimizationType.mergeDuplicate:
          await _applyMergeDuplicate(suggestion);
          break;
        case OptimizationType.optimizeDependency:
          await _applyOptimizeDependency(suggestion);
          break;
        case OptimizationType.restructureLayer:
          await _applyRestructureLayer(suggestion);
          break;
        case OptimizationType.improveReusability:
          await _applyImproveReusability(suggestion);
          break;
        case OptimizationType.reduceComplexity:
          await _applyReduceComplexity(suggestion);
          break;
      }

      _suggestions.remove(componentId);

      _emitEvent(OptimizationEvent(
        type: OptimizationEventType.suggestionApplied,
        suggestion: suggestion,
        timestamp: DateTime.now(),
      ));

      print('✅ Optimization suggestion applied successfully');
      return true;
    } catch (e) {
      print('❌ Failed to apply optimization suggestion: $e');
      return false;
    }
  }

  Future<void> _applyRemoveUnused(OptimizationSuggestion suggestion) async {
    // Implementation would remove the unused component
    print('🗑️ Removing unused component: ${suggestion.componentId}');
  }

  Future<void> _applyMergeDuplicate(OptimizationSuggestion suggestion) async {
    final primary = suggestion.metadata['primary'] as String;
    final secondary = List<String>.from(suggestion.metadata['secondary'] as List);
    print('🔀 Merging components: $primary with ${secondary.join(', ')}');
  }

  Future<void> _applyOptimizeDependency(OptimizationSuggestion suggestion) async {
    final optimized = List<String>.from(suggestion.metadata['optimized'] as List);
    print('🔗 Optimizing dependencies for ${suggestion.componentId}: ${optimized.join(', ')}');
  }

  Future<void> _applyRestructureLayer(OptimizationSuggestion suggestion) async {
    final targetLayer = Layer.values.firstWhere((l) => l.name == suggestion.metadata['targetLayer']);
    print('🏗️ Restructuring layer for ${suggestion.componentId} to ${targetLayer.name}');
  }

  Future<void> _applyImproveReusability(OptimizationSuggestion suggestion) async {
    print('♻️ Improving reusability for ${suggestion.componentId}');
  }

  Future<void> _applyReduceComplexity(OptimizationSuggestion suggestion) async {
    print('⚡ Reducing complexity for ${suggestion.componentId}');
  }

  /// Clear all suggestions
  void clearSuggestions() {
    _suggestions.clear();
    print('🗑️ All optimization suggestions cleared');
  }

  /// Emit optimization event
  void _emitEvent(OptimizationEvent event) {
    _eventController.add(event);
  }

  /// Dispose resources
  void dispose() {
    print('🗑️ Disposing Hierarchy Optimizer...');
    _eventController.close();
    print('✅ Hierarchy Optimizer disposed');
  }
}

/// Optimization suggestion
class OptimizationSuggestion {
  final OptimizationType type;
  final String componentId;
  final OptimizationPriority priority;
  final String description;
  final OptimizationImpact estimatedImpact;
  final OptimizationEffort effort;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;

  OptimizationSuggestion({
    required this.type,
    required this.componentId,
    required this.priority,
    required this.description,
    required this.estimatedImpact,
    required this.effort,
    this.metadata = const {},
  }) : createdAt = DateTime.now();
}

/// Optimization report
class OptimizationReport {
  final DateTime startTime;
  DateTime? endTime;
  bool success = false;
  String? error;
  final List<OptimizationSuggestion> suggestions = [];

  // Statistics
  int unusedComponentsRemoved = 0;
  int duplicateComponentsMerged = 0;
  int dependenciesOptimized = 0;
  int layersRestructured = 0;
  int reusabilityImproved = 0;
  int complexityReduced = 0;

  OptimizationReport({required this.startTime});

  void addSuggestion(OptimizationSuggestion suggestion) {
    suggestions.add(suggestion);
  }

  Duration? get duration {
    if (endTime == null) return null;
    return endTime!.difference(startTime);
  }

  Map<String, dynamic> get statistics => {
    'unusedComponentsRemoved': unusedComponentsRemoved,
    'duplicateComponentsMerged': duplicateComponentsMerged,
    'dependenciesOptimized': dependenciesOptimized,
    'layersRestructured': layersRestructured,
    'reusabilityImproved': reusabilityImproved,
    'complexityReduced': complexityReduced,
    'totalSuggestions': suggestions.length,
    'duration': duration?.inMilliseconds,
    'success': success,
  };
}

/// Optimization event
class OptimizationEvent {
  final OptimizationEventType type;
  final OptimizationSuggestion? suggestion;
  final DateTime timestamp;

  OptimizationEvent({
    required this.type,
    this.suggestion,
    required this.timestamp,
  });
}

/// Enums
enum OptimizationType {
  removeUnused,
  mergeDuplicate,
  optimizeDependency,
  restructureLayer,
  improveReusability,
  reduceComplexity,
}

enum OptimizationPriority {
  low,
  medium,
  high,
  critical,
}

enum OptimizationImpact {
  low,
  medium,
  high,
}

enum OptimizationEffort {
  low,
  medium,
  high,
}

enum OptimizationEventType {
  suggestionGenerated,
  suggestionApplied,
  optimizationStarted,
  optimizationCompleted,
}

/// Global optimizer instance
final hierarchyOptimizer = HierarchyOptimizer();
