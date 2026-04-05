import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';

/// Component Hierarchy Manager
/// Manages component relationships, dependencies, and optimization
class ComponentHierarchyManager {
  static final ComponentHierarchyManager _instance = ComponentHierarchyManager._internal();
  factory ComponentHierarchyManager() => _instance;
  ComponentHierarchyManager._internal();

  final Map<String, ComponentNode> _components = {};
  final Map<String, List<String>> _parentChildRelations = {};
  final Map<String, List<String>> _dependencyGraph = {};
  final Map<String, ComponentMetrics> _metrics = {};
  final StreamController<HierarchyEvent> _eventController;
  bool _isInitialized = false;

  ComponentHierarchyManager() : _eventController = StreamController<HierarchyEvent>.broadcast();

  /// Stream of hierarchy events
  Stream<HierarchyEvent> get eventStream => _eventController.stream;

  /// Initialize the hierarchy manager
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      print('🏗️ Initializing Component Hierarchy Manager...');

      // Register core components
      await _registerCoreComponents();

      // Register shared components
      await _registerSharedComponents();

      // Register feature components
      await _registerFeatureComponents();

      // Build dependency graph
      await _buildDependencyGraph();

      // Analyze component relationships
      await _analyzeRelationships();

      // Optimize hierarchy
      await _optimizeHierarchy();

      _isInitialized = true;
      print('✅ Component Hierarchy Manager initialized successfully');
    } catch (e) {
      print('❌ Failed to initialize Component Hierarchy Manager: $e');
      rethrow;
    }
  }

  /// Register core components
  Future<void> _registerCoreComponents() async {
    // Core services
    _registerComponent('storage_service', ComponentType.service, layer: Layer.core);
    _registerComponent('network_service', ComponentType.service, layer: Layer.core);
    _registerComponent('validation_utils', ComponentType.utility, layer: Layer.core);
    _registerComponent('background_gps_service', ComponentType.service, layer: Layer.core);
    _registerComponent('nepal_vat_generator', ComponentType.utility, layer: Layer.core);
    _registerComponent('vat_pdf_generator', ComponentType.utility, layer: Layer.core);

    // Core infrastructure
    _registerComponent('dependency_container', ComponentType.infrastructure, layer: Layer.core);
    _registerComponent('security_manager', ComponentType.infrastructure, layer: Layer.core);
    _registerComponent('logger_service', ComponentType.service, layer: Layer.core);

    print('✅ Core components registered');
  }

  /// Register shared components
  Future<void> _registerSharedComponents() async {
    // Shared utilities
    _registerComponent('app_utils', ComponentType.utility, layer: Layer.shared);
    _registerComponent('app_router', ComponentType.infrastructure, layer: Layer.shared);
    _registerComponent('form_validator', ComponentType.utility, layer: Layer.shared);
    _registerComponent('websocket_manager', ComponentType.service, layer: Layer.shared);

    // Shared UI components
    _registerComponent('enhanced_theme', ComponentType.ui, layer: Layer.shared);
    _registerComponent('responsive_layout', ComponentType.ui, layer: Layer.shared);
    _registerComponent('micro_interactions', ComponentType.ui, layer: Layer.shared);
    _registerComponent('accessibility_helper', ComponentType.ui, layer: Layer.shared);

    print('✅ Shared components registered');
  }

  /// Register feature components
  Future<void> _registerFeatureComponents() async {
    // Accounting feature
    _registerComponent('accounting_service', ComponentType.service, layer: Layer.feature, feature: 'accounting');
    _registerComponent('accounting_provider', ComponentType.state, layer: Layer.feature, feature: 'accounting');
    _registerComponent('vat_return_service', ComponentType.service, layer: Layer.feature, feature: 'accounting');
    _registerComponent('expense_reconciliation_service', ComponentType.service, layer: Layer.feature, feature: 'accounting');

    // Distribution feature
    _registerComponent('distribution_service', ComponentType.service, layer: Layer.feature, feature: 'distribution');
    _registerComponent('inventory_repository', ComponentType.repository, layer: Layer.feature, feature: 'distribution');
    _registerComponent('order_management_service', ComponentType.service, layer: Layer.feature, feature: 'distribution');

    // Field force feature
    _registerComponent('location_service', ComponentType.service, layer: Layer.feature, feature: 'field_force');
    _registerComponent('geospatial_tracker', ComponentType.service, layer: Layer.feature, feature: 'field_force');
    _registerComponent('route_optimizer', ComponentType.service, layer: Layer.feature, feature: 'field_force');

    print('✅ Feature components registered');
  }

  /// Register a component
  void _registerComponent(
    String id,
    ComponentType type, {
    Layer layer = Layer.application,
    String? feature,
    List<String> dependencies = const [],
  }) {
    final component = ComponentNode(
      id: id,
      type: type,
      layer: layer,
      feature: feature,
      dependencies: dependencies,
      registeredAt: DateTime.now(),
    );

    _components[id] = component;
    _dependencyGraph[id] = dependencies;

    _emitEvent(HierarchyEvent(
      type: HierarchyEventType.componentRegistered,
      componentId: id,
      timestamp: DateTime.now(),
      metadata: {
        'type': type.name,
        'layer': layer.name,
        'feature': feature,
      },
    ));
  }

  /// Build dependency graph
  Future<void> _buildDependencyGraph() async {
    print('🔗 Building dependency graph...');

    for (final component in _components.values) {
      _parentChildRelations[component.id] = [];
      
      for (final dependency in component.dependencies) {
        if (_components.containsKey(dependency)) {
          _parentChildRelations[dependency] ??= [];
          _parentChildRelations[dependency]!.add(component.id);
        }
      }
    }

    // Validate dependency graph
    final cycles = _detectCycles();
    if (cycles.isNotEmpty) {
      print('⚠️ Detected circular dependencies: $cycles');
      for (final cycle in cycles) {
        _emitEvent(HierarchyEvent(
          type: HierarchyEventType.circularDependencyDetected,
          componentId: cycle.first,
          timestamp: DateTime.now(),
          metadata: {'cycle': cycle},
        ));
      }
    }

    print('✅ Dependency graph built');
  }

  /// Analyze component relationships
  Future<void> _analyzeRelationships() async {
    print('📊 Analyzing component relationships...');

    for (final component in _components.values) {
      final metrics = ComponentMetrics(
        componentId: component.id,
        dependencyCount: component.dependencies.length,
        dependentCount: _parentChildRelations[component.id]?.length ?? 0,
        layerDepth: _calculateLayerDepth(component),
        complexity: _calculateComplexity(component),
        reusability: _calculateReusability(component),
        lastAnalyzed: DateTime.now(),
      );

      _metrics[component.id] = metrics;
    }

    print('✅ Component relationships analyzed');
  }

  /// Optimize hierarchy
  Future<void> _optimizeHierarchy() async {
    print('⚡ Optimizing component hierarchy...');

    // Identify unused components
    final unusedComponents = _findUnusedComponents();
    for (final componentId in unusedComponents) {
      _emitEvent(HierarchyEvent(
        type: HierarchyEventType.unusedComponentDetected,
        componentId: componentId,
        timestamp: DateTime.now(),
      ));
    }

    // Identify duplicate functionality
    final duplicates = _findDuplicateFunctionality();
    for (final duplicate in duplicates) {
      _emitEvent(HierarchyEvent(
        type: HierarchyEventType.duplicateFunctionalityDetected,
        componentId: duplicate.first,
        timestamp: DateTime.now(),
        metadata: {'duplicates': duplicate},
      ));
    }

    // Suggest optimizations
    await _suggestOptimizations();

    print('✅ Component hierarchy optimized');
  }

  /// Detect circular dependencies
  List<List<String>> _detectCycles() {
    final cycles = <List<String>>[];
    final visited = <String>{};
    final recursionStack = <String>{};

    for (final componentId in _components.keys) {
      if (!visited.contains(componentId)) {
        final cycle = _detectCycle(componentId, visited, recursionStack);
        if (cycle.isNotEmpty) {
          cycles.add(cycle);
        }
      }
    }

    return cycles;
  }

  List<String> _detectCycle(String componentId, Set<String> visited, Set<String> recursionStack) {
    visited.add(componentId);
    recursionStack.add(componentId);

    final dependencies = _dependencyGraph[componentId] ?? [];
    for (final dependency in dependencies) {
      if (!visited.contains(dependency)) {
        final cycle = _detectCycle(dependency, visited, recursionStack);
        if (cycle.isNotEmpty) {
          return [componentId] + cycle;
        }
      } else if (recursionStack.contains(dependency)) {
        return [componentId, dependency];
      }
    }

    recursionStack.remove(componentId);
    return [];
  }

  /// Calculate layer depth
  int _calculateLayerDepth(ComponentNode component) {
    switch (component.layer) {
      case Layer.core:
        return 0;
      case Layer.shared:
        return 1;
      case Layer.feature:
        return 2;
      case Layer.application:
        return 3;
      case Layer.presentation:
        return 4;
    }
  }

  /// Calculate complexity
  double _calculateComplexity(ComponentNode component) {
    double complexity = 1.0;
    
    // Base complexity by type
    switch (component.type) {
      case ComponentType.service:
        complexity += 2.0;
        break;
      case ComponentType.repository:
        complexity += 1.5;
        break;
      case ComponentType.ui:
        complexity += 1.0;
        break;
      case ComponentType.state:
        complexity += 1.5;
        break;
      case ComponentType.utility:
        complexity += 0.5;
        break;
      case ComponentType.infrastructure:
        complexity += 2.5;
        break;
    }

    // Add dependency complexity
    complexity += component.dependencies.length * 0.3;

    // Add dependent complexity
    final dependentCount = _parentChildRelations[component.id]?.length ?? 0;
    complexity += dependentCount * 0.2;

    return complexity;
  }

  /// Calculate reusability
  double _calculateReusability(ComponentNode component) {
    double reusability = 0.5; // Base reusability

    // Higher reusability for shared and core components
    if (component.layer == Layer.core || component.layer == Layer.shared) {
      reusability += 0.3;
    }

    // Higher reusability for utilities
    if (component.type == ComponentType.utility) {
      reusability += 0.2;
    }

    // Higher reusability with more dependents
    final dependentCount = _parentChildRelations[component.id]?.length ?? 0;
    reusability += (dependentCount / 10).clamp(0.0, 0.2);

    return reusability.clamp(0.0, 1.0);
  }

  /// Find unused components
  List<String> _findUnusedComponents() {
    final unused = <String>[];
    
    for (final component in _components.values) {
      final dependentCount = _parentChildRelations[component.id]?.length ?? 0;
      
      // Core and shared components are never considered unused
      if (component.layer == Layer.core || component.layer == Layer.shared) {
        continue;
      }
      
      if (dependentCount == 0) {
        unused.add(component.id);
      }
    }

    return unused;
  }

  /// Find duplicate functionality
  List<List<String>> _findDuplicateFunctionality() {
    final duplicates = <List<String>>[];
    final processed = <String>{};

    for (final component in _components.values) {
      if (processed.contains(component.id)) continue;

      final similar = _findSimilarComponents(component);
      if (similar.length > 1) {
        duplicates.add(similar);
        processed.addAll(similar);
      }
    }

    return duplicates;
  }

  List<String> _findSimilarComponents(ComponentNode component) {
    final similar = [component.id];

    for (final other in _components.values) {
      if (other.id == component.id) continue;

      // Check for similar types and layers
      if (other.type == component.type && 
          other.layer == component.layer &&
          _calculateSimilarity(component, other) > 0.8) {
        similar.add(other.id);
      }
    }

    return similar;
  }

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

  /// Suggest optimizations
  Future<void> _suggestOptimizations() async {
    print('💡 Generating optimization suggestions...');

    // Suggest merging duplicate components
    final duplicates = _findDuplicateFunctionality();
    for (final duplicate in duplicates) {
      if (duplicate.length > 1) {
        print('💡 Consider merging duplicate components: ${duplicate.join(', ')}');
      }
    }

    // Suggest removing unused components
    final unused = _findUnusedComponents();
    for (final componentId in unused) {
      print('💡 Consider removing unused component: $componentId');
    }

    // Suggest optimizing high-complexity components
    for (final metrics in _metrics.values) {
      if (metrics.complexity > 5.0) {
        print('💡 Consider refactoring high-complexity component: ${metrics.componentId}');
      }
    }

    // Suggest improving low-reusability components
    for (final metrics in _metrics.values) {
      if (metrics.reusability < 0.3 && metrics.dependentCount > 0) {
        print('💡 Consider improving reusability of component: ${metrics.componentId}');
      }
    }

    print('✅ Optimization suggestions generated');
  }

  /// Get component hierarchy
  Map<String, ComponentNode> getHierarchy() {
    return Map.unmodifiable(_components);
  }

  /// Get dependency graph
  Map<String, List<String>> getDependencyGraph() {
    return Map.unmodifiable(_dependencyGraph);
  }

  /// Get component metrics
  Map<String, ComponentMetrics> getMetrics() {
    return Map.unmodifiable(_metrics);
  }

  /// Get components by layer
  Map<Layer, List<ComponentNode>> getComponentsByLayer() {
    final byLayer = <Layer, List<ComponentNode>>{};
    
    for (final component in _components.values) {
      byLayer[component.layer] ??= [];
      byLayer[component.layer]!.add(component);
    }

    return byLayer;
  }

  /// Get components by type
  Map<ComponentType, List<ComponentNode>> getComponentsByType() {
    final byType = <ComponentType, List<ComponentNode>>{};
    
    for (final component in _components.values) {
      byType[component.type] ??= [];
      byType[component.type]!.add(component);
    }

    return byType;
  }

  /// Get components by feature
  Map<String, List<ComponentNode>> getComponentsByFeature() {
    final byFeature = <String, List<ComponentNode>>{};
    
    for (final component in _components.values) {
      if (component.feature != null) {
        byFeature[component.feature!] ??= [];
        byFeature[component.feature]!.add(component);
      }
    }

    return byFeature;
  }

  /// Validate hierarchy
  List<String> validateHierarchy() {
    final errors = <String>[];

    // Check for circular dependencies
    final cycles = _detectCycles();
    for (final cycle in cycles) {
      errors.add('Circular dependency detected: ${cycle.join(' -> ')}');
    }

    // Check for missing dependencies
    for (final component in _components.values) {
      for (final dependency in component.dependencies) {
        if (!_components.containsKey(dependency)) {
          errors.add('Missing dependency: $dependency for component ${component.id}');
        }
      }
    }

    // Check for layer violations
    for (final component in _components.values) {
      for (final dependency in component.dependencies) {
        final depComponent = _components[dependency];
        if (depComponent != null && _isLayerViolation(component, depComponent)) {
          errors.add('Layer violation: ${component.id} depends on ${dependency}');
        }
      }
    }

    return errors;
  }

  bool _isLayerViolation(ComponentNode component, ComponentNode dependency) {
    return dependency.layer.index > component.layer.index;
  }

  /// Emit hierarchy event
  void _emitEvent(HierarchyEvent event) {
    _eventController.add(event);
  }

  /// Dispose resources
  void dispose() {
    print('🗑️ Disposing Component Hierarchy Manager...');
    _eventController.close();
    print('✅ Component Hierarchy Manager disposed');
  }
}

/// Component node
class ComponentNode {
  final String id;
  final ComponentType type;
  final Layer layer;
  final String? feature;
  final List<String> dependencies;
  final DateTime registeredAt;

  ComponentNode({
    required this.id,
    required this.type,
    required this.layer,
    this.feature,
    required this.dependencies,
    required this.registeredAt,
  });
}

/// Component metrics
class ComponentMetrics {
  final String componentId;
  final int dependencyCount;
  final int dependentCount;
  final int layerDepth;
  final double complexity;
  final double reusability;
  final DateTime lastAnalyzed;

  ComponentMetrics({
    required this.componentId,
    required this.dependencyCount,
    required this.dependentCount,
    required this.layerDepth,
    required this.complexity,
    required this.reusability,
    required this.lastAnalyzed,
  });
}

/// Hierarchy event
class HierarchyEvent {
  final HierarchyEventType type;
  final String componentId;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  HierarchyEvent({
    required this.type,
    required this.componentId,
    required this.timestamp,
    this.metadata = const {},
  });
}

/// Component type enum
enum ComponentType {
  service,
  repository,
  ui,
  state,
  utility,
  infrastructure,
}

/// Layer enum
enum Layer {
  core,
  shared,
  feature,
  application,
  presentation,
}

/// Hierarchy event type enum
enum HierarchyEventType {
  componentRegistered,
  circularDependencyDetected,
  unusedComponentDetected,
  duplicateFunctionalityDetected,
  layerViolationDetected,
}

/// Global hierarchy manager instance
final componentHierarchyManager = ComponentHierarchyManager();
