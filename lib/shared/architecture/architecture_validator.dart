import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'component_hierarchy.dart';
import 'hierarchy_optimizer.dart';

/// Architecture Validator
/// Comprehensive architecture validation system for ensuring clean and scalable design
class ArchitectureValidator {
  static final ArchitectureValidator _instance = ArchitectureValidator._internal();
  factory ArchitectureValidator() => _instance;
  ArchitectureValidator._internal();

  final ComponentHierarchyManager _hierarchyManager = componentHierarchyManager;
  final HierarchyOptimizer _optimizer = hierarchyOptimizer;
  final Map<String, ArchitectureRule> _rules = {};
  final Map<String, ValidationReport> _validationReports = {};
  final StreamController<ValidationEvent> _eventController;
  bool _isValidating = false;

  ArchitectureValidator() : _eventController = StreamController<ValidationEvent>.broadcast();

  /// Stream of validation events
  Stream<ValidationEvent> get eventStream => _eventController.stream;

  /// Initialize the validator
  Future<void> initialize() async {
    print('🔧 Initializing Architecture Validator...');

    // Register architecture rules
    await _registerArchitectureRules();

    print('✅ Architecture Validator initialized');
  }

  /// Validate the entire architecture
  Future<ArchitectureValidationReport> validateArchitecture() async {
    if (_isValidating) {
      throw StateError('Validation already in progress');
    }

    _isValidating = true;
    final report = ArchitectureValidationReport(startTime: DateTime.now());

    try {
      print('🔍 Starting architecture validation...');

      // Phase 1: Validate component hierarchy
      await _validateComponentHierarchy(report);

      // Phase 2: Validate dependencies
      await _validateDependencies(report);

      // Phase 3: Validate layer separation
      await _validateLayerSeparation(report);

      // Phase 4: Validate naming conventions
      await _validateNamingConventions(report);

      // Phase 5: Validate code organization
      await _validateCodeOrganization(report);

      // Phase 6: Validate scalability patterns
      await _validateScalabilityPatterns(report);

      // Phase 7: Validate performance patterns
      await _validatePerformancePatterns(report);

      // Phase 8: Validate security patterns
      await _validateSecurityPatterns(report);

      report.endTime = DateTime.now();
      report.success = true;

      print('✅ Architecture validation completed successfully');
    } catch (e) {
      report.endTime = DateTime.now();
      report.success = false;
      report.error = e.toString();
      print('❌ Architecture validation failed: $e');
    } finally {
      _isValidating = false;
    }

    return report;
  }

  /// Register architecture rules
  Future<void> _registerArchitectureRules() async {
    // Component hierarchy rules
    _registerRule(ArchitectureRule(
      id: 'no_circular_dependencies',
      name: 'No Circular Dependencies',
      description: 'Components must not have circular dependencies',
      severity: RuleSeverity.critical,
      validator: _validateNoCircularDependencies,
    ));

    _registerRule(ArchitectureRule(
      id: 'proper_layer_separation',
      name: 'Proper Layer Separation',
      description: 'Components must respect layer boundaries',
      severity: RuleSeverity.high,
      validator: _validateProperLayerSeparation,
    ));

    _registerRule(ArchitectureRule(
      id: 'single_responsibility',
      name: 'Single Responsibility Principle',
      description: 'Components should have a single responsibility',
      severity: RuleSeverity.medium,
      validator: _validateSingleResponsibility,
    ));

    _registerRule(ArchitectureRule(
      id: 'dependency_inversion',
      name: 'Dependency Inversion Principle',
      description: 'High-level modules should not depend on low-level modules',
      severity: RuleSeverity.high,
      validator: _validateDependencyInversion,
    ));

    _registerRule(ArchitectureRule(
      id: 'interface_segregation',
      name: 'Interface Segregation Principle',
      description: 'Clients should not be forced to depend on unused interfaces',
      severity: RuleSeverity.medium,
      validator: _validateInterfaceSegregation,
    ));

    _registerRule(ArchitectureRule(
      id: 'open_closed',
      name: 'Open/Closed Principle',
      description: 'Components should be open for extension but closed for modification',
      severity: RuleSeverity.medium,
      validator: _validateOpenClosed,
    ));

    print('✅ Architecture rules registered');
  }

  /// Register a rule
  void _registerRule(ArchitectureRule rule) {
    _rules[rule.id] = rule;
  }

  /// Validate component hierarchy
  Future<void> _validateComponentHierarchy(ArchitectureValidationReport report) async {
    print('🏗️ Phase 1: Validating component hierarchy...');

    final hierarchy = _hierarchyManager.getHierarchy();
    final dependencyGraph = _hierarchyManager.getDependencyGraph();
    
    int violations = 0;

    // Check for orphaned components
    for (final component in hierarchy.values) {
      final hasDependencies = component.dependencies.isNotEmpty;
      final hasDependents = (dependencyGraph[component.id]?.length ?? 0) > 0;
      
      if (!hasDependencies && !hasDependents && component.layer != Layer.core) {
        violations++;
        
        final violation = ArchitectureViolation(
          ruleId: 'orphaned_component',
          componentId: component.id,
          severity: ViolationSeverity.medium,
          description: 'Component ${component.id} is orphaned (no dependencies or dependents)',
          suggestion: 'Consider removing the component or adding proper dependencies',
        );

        report.addViolation(violation);

        _emitEvent(ValidationEvent(
          type: ValidationEventType.violationDetected,
          violation: violation,
          timestamp: DateTime.now(),
        ));
      }
    }

    report.hierarchyViolations = violations;
    print('✅ Phase 1 completed: $violations hierarchy violations detected');
  }

  /// Validate dependencies
  Future<void> _validateDependencies(ArchitectureValidationReport report) async {
    print('🔗 Phase 2: Validating dependencies...');

    final hierarchy = _hierarchyManager.getHierarchy();
    final dependencyGraph = _hierarchyManager.getDependencyGraph();
    
    int violations = 0;

    // Check for missing dependencies
    for (final component in hierarchy.values) {
      for (final dependency in component.dependencies) {
        if (!hierarchy.containsKey(dependency)) {
          violations++;
          
          final violation = ArchitectureViolation(
            ruleId: 'missing_dependency',
            componentId: component.id,
            severity: ViolationSeverity.high,
            description: 'Component ${component.id} depends on missing component $dependency',
            suggestion: 'Add the missing dependency or remove the reference',
          );

          report.addViolation(violation);

          _emitEvent(ValidationEvent(
            type: ValidationEventType.violationDetected,
            violation: violation,
            timestamp: DateTime.now(),
          ));
        }
      }
    }

    report.dependencyViolations = violations;
    print('✅ Phase 2 completed: $violations dependency violations detected');
  }

  /// Validate layer separation
  Future<void> _validateLayerSeparation(ArchitectureValidationReport report) async {
    print('🏗️ Phase 3: Validating layer separation...');

    final hierarchy = _hierarchyManager.getHierarchy();
    
    int violations = 0;

    for (final component in hierarchy.values) {
      for (final dependency in component.dependencies) {
        final depComponent = hierarchy[dependency];
        if (depComponent != null && _isLayerViolation(component, depComponent)) {
          violations++;
          
          final violation = ArchitectureViolation(
            ruleId: 'layer_violation',
            componentId: component.id,
            severity: ViolationSeverity.high,
            description: 'Component ${component.id} (${component.layer.name}) depends on ${dependency} (${depComponent.layer.name})',
            suggestion: 'Restructure dependencies to respect layer boundaries',
          );

          report.addViolation(violation);

          _emitEvent(ValidationEvent(
            type: ValidationEventType.violationDetected,
            violation: violation,
            timestamp: DateTime.now(),
          ));
        }
      }
    }

    report.layerViolations = violations;
    print('✅ Phase 3 completed: $violations layer violations detected');
  }

  /// Validate naming conventions
  Future<void> _validateNamingConventions(ArchitectureValidationReport report) async {
    print('📝 Phase 4: Validating naming conventions...');

    final hierarchy = _hierarchyManager.getHierarchy();
    
    int violations = 0;

    for (final component in hierarchy.values) {
      // Check component ID naming
      if (!_isValidComponentId(component.id)) {
        violations++;
        
        final violation = ArchitectureViolation(
          ruleId: 'naming_convention',
          componentId: component.id,
          severity: ViolationSeverity.low,
          description: 'Component ID ${component.id} does not follow naming conventions',
          suggestion: 'Use snake_case for component IDs',
        );

        report.addViolation(violation);

        _emitEvent(ValidationEvent(
          type: ValidationEventType.violationDetected,
          violation: violation,
          timestamp: DateTime.now(),
        ));
      }
    }

    report.namingViolations = violations;
    print('✅ Phase 4 completed: $violations naming violations detected');
  }

  /// Validate code organization
  Future<void> _validateCodeOrganization(ArchitectureValidationReport report) async {
    print('📁 Phase 5: Validating code organization...');

    final hierarchy = _hierarchyManager.getHierarchy();
    final byLayer = _hierarchyManager.getComponentsByLayer();
    
    int violations = 0;

    // Check for proper component distribution
    for (final layer in Layer.values) {
      final components = byLayer[layer] ?? [];
      
      if (components.isEmpty && layer != Layer.presentation) {
        violations++;
        
        final violation = ArchitectureViolation(
          ruleId: 'empty_layer',
          componentId: layer.name,
          severity: ViolationSeverity.medium,
          description: 'Layer ${layer.name} is empty',
          suggestion: 'Add components to the layer or remove it if not needed',
        );

        report.addViolation(violation);

        _emitEvent(ValidationEvent(
          type: ValidationEventType.violationDetected,
          violation: violation,
          timestamp: DateTime.now(),
        ));
      }
    }

    report.organizationViolations = violations;
    print('✅ Phase 5 completed: $violations organization violations detected');
  }

  /// Validate scalability patterns
  Future<void> _validateScalabilityPatterns(ArchitectureValidationReport report) async {
    print('📈 Phase 6: Validating scalability patterns...');

    final hierarchy = _hierarchyManager.getHierarchy();
    final metrics = _hierarchyManager.getMetrics();
    
    int violations = 0;

    for (final metric in metrics.values) {
      // Check for high complexity
      if (metric.complexity > 5.0) {
        violations++;
        
        final violation = ArchitectureViolation(
          ruleId: 'high_complexity',
          componentId: metric.componentId,
          severity: ViolationSeverity.medium,
          description: 'Component ${metric.componentId} has high complexity (${metric.complexity.toStringAsFixed(2)})',
          suggestion: 'Consider breaking down the component into smaller pieces',
        );

        report.addViolation(violation);

        _emitEvent(ValidationEvent(
          type: ValidationEventType.violationDetected,
          violation: violation,
          timestamp: DateTime.now(),
        ));
      }

      // Check for low reusability
      if (metric.reusability < 0.3 && metric.dependentCount > 0) {
        violations++;
        
        final violation = ArchitectureViolation(
          ruleId: 'low_reusability',
          componentId: metric.componentId,
          severity: ViolationSeverity.low,
          description: 'Component ${metric.componentId} has low reusability (${metric.reusability.toStringAsFixed(2)})',
          suggestion: 'Consider making the component more reusable',
        );

        report.addViolation(violation);

        _emitEvent(ValidationEvent(
          type: ValidationEventType.violationDetected,
          violation: violation,
          timestamp: DateTime.now(),
        ));
      }
    }

    report.scalabilityViolations = violations;
    print('✅ Phase 6 completed: $violations scalability violations detected');
  }

  /// Validate performance patterns
  Future<void> _validatePerformancePatterns(ArchitectureValidationReport report) async {
    print('⚡ Phase 7: Validating performance patterns...');

    final hierarchy = _hierarchyManager.getHierarchy();
    
    int violations = 0;

    for (final component in hierarchy.values) {
      // Check for deep dependency chains
      final depth = _calculateDependencyDepth(component.id);
      if (depth > 5) {
        violations++;
        
        final violation = ArchitectureViolation(
          ruleId: 'deep_dependency_chain',
          componentId: component.id,
          severity: ViolationSeverity.medium,
          description: 'Component ${component.id} has deep dependency chain (depth: $depth)',
          suggestion: 'Consider flattening the dependency hierarchy',
        );

        report.addViolation(violation);

        _emitEvent(ValidationEvent(
          type: ValidationEventType.violationDetected,
          violation: violation,
          timestamp: DateTime.now(),
        ));
      }
    }

    report.performanceViolations = violations;
    print('✅ Phase 7 completed: $violations performance violations detected');
  }

  /// Validate security patterns
  Future<void> _validateSecurityPatterns(ArchitectureValidationReport report) async {
    print('🔒 Phase 8: Validating security patterns...');

    final hierarchy = _hierarchyManager.getHierarchy();
    
    int violations = 0;

    for (final component in hierarchy.values) {
      // Check for security-sensitive components in wrong layers
      if (component.type == ComponentType.infrastructure && component.layer != Layer.core) {
        violations++;
        
        final violation = ArchitectureViolation(
          ruleId: 'security_layer_violation',
          componentId: component.id,
          severity: ViolationSeverity.high,
          description: 'Infrastructure component ${component.id} should be in core layer',
          suggestion: 'Move the component to the core layer for better security',
        );

        report.addViolation(violation);

        _emitEvent(ValidationEvent(
          type: ValidationEventType.violationDetected,
          violation: violation,
          timestamp: DateTime.now(),
        ));
      }
    }

    report.securityViolations = violations;
    print('✅ Phase 8 completed: $violations security violations detected');
  }

  /// Rule validation methods
  Future<RuleValidationResult> _validateNoCircularDependencies() async {
    final cycles = _hierarchyManager._detectCycles();
    
    if (cycles.isNotEmpty) {
      return RuleValidationResult(
        isValid: false,
        violations: cycles.map((cycle) => ArchitectureViolation(
          ruleId: 'no_circular_dependencies',
          componentId: cycle.first,
          severity: ViolationSeverity.critical,
          description: 'Circular dependency detected: ${cycle.join(' -> ')}',
          suggestion: 'Break the circular dependency by restructuring components',
        )).toList(),
      );
    }

    return const RuleValidationResult(isValid: true, violations: []);
  }

  Future<RuleValidationResult> _validateProperLayerSeparation() async {
    final hierarchy = _hierarchyManager.getHierarchy();
    final violations = <ArchitectureViolation>[];

    for (final component in hierarchy.values) {
      for (final dependency in component.dependencies) {
        final depComponent = hierarchy[dependency];
        if (depComponent != null && _isLayerViolation(component, depComponent)) {
          violations.add(ArchitectureViolation(
            ruleId: 'proper_layer_separation',
            componentId: component.id,
            severity: ViolationSeverity.high,
            description: 'Layer violation: ${component.id} depends on ${dependency}',
            suggestion: 'Restructure dependencies to respect layer boundaries',
          ));
        }
      }
    }

    return RuleValidationResult(
      isValid: violations.isEmpty,
      violations: violations,
    );
  }

  Future<RuleValidationResult> _validateSingleResponsibility() async {
    final metrics = _hierarchyManager.getMetrics();
    final violations = <ArchitectureViolation>[];

    for (final metric in metrics.values) {
      if (metric.complexity > 3.0) {
        violations.add(ArchitectureViolation(
          ruleId: 'single_responsibility',
          componentId: metric.componentId,
          severity: ViolationSeverity.medium,
          description: 'Component ${metric.componentId} may violate single responsibility principle',
          suggestion: 'Consider breaking down the component into smaller, focused components',
        ));
      }
    }

    return RuleValidationResult(
      isValid: violations.isEmpty,
      violations: violations,
    );
  }

  Future<RuleValidationResult> _validateDependencyInversion() async {
    final hierarchy = _hierarchyManager.getHierarchy();
    final violations = <ArchitectureViolation>[];

    for (final component in hierarchy.values) {
      if (component.layer == Layer.application || component.layer == Layer.presentation) {
        for (final dependency in component.dependencies) {
          final depComponent = hierarchy[dependency];
          if (depComponent != null && depComponent.layer == Layer.core) {
            violations.add(ArchitectureViolation(
              ruleId: 'dependency_inversion',
              componentId: component.id,
              severity: ViolationSeverity.high,
              description: 'High-level component ${component.id} depends on low-level component $dependency',
              suggestion: 'Introduce an abstraction layer to invert the dependency',
            ));
          }
        }
      }
    }

    return RuleValidationResult(
      isValid: violations.isEmpty,
      violations: violations,
    );
  }

  Future<RuleValidationResult> _validateInterfaceSegregation() async {
    // Simplified implementation
    return const RuleValidationResult(isValid: true, violations: []);
  }

  Future<RuleValidationResult> _validateOpenClosed() async {
    // Simplified implementation
    return const RuleValidationResult(isValid: true, violations: []);
  }

  /// Helper methods
  bool _isLayerViolation(ComponentNode component, ComponentNode dependency) {
    return dependency.layer.index > component.layer.index;
  }

  bool _isValidComponentId(String componentId) {
    return RegExp(r'^[a-z_][a-z0-9_]*$').hasMatch(componentId);
  }

  int _calculateDependencyDepth(String componentId) {
    final dependencyGraph = _hierarchyManager.getDependencyGraph();
    final visited = <String>{};
    final queue = Queue<String>();
    int maxDepth = 0;
    
    queue.add(componentId);
    
    while (queue.isNotEmpty) {
      final current = queue.removeFirst();
      if (visited.contains(current)) continue;
      visited.add(current);
      
      final dependencies = dependencyGraph[current] ?? [];
      for (final dep in dependencies) {
        queue.add(dep);
        maxDepth = max(maxDepth, visited.length);
      }
    }
    
    return maxDepth;
  }

  /// Get validation report
  ArchitectureValidationReport? getValidationReport(String reportId) {
    return _validationReports[reportId];
  }

  /// Get all validation reports
  Map<String, ArchitectureValidationReport> getAllValidationReports() {
    return Map.unmodifiable(_validationReports);
  }

  /// Get architecture health score
  double getArchitectureHealthScore() {
    if (_validationReports.isEmpty) return 0.0;

    double totalScore = 0.0;
    int reportCount = 0;

    for (final report in _validationReports.values) {
      totalScore += report.healthScore;
      reportCount++;
    }

    return reportCount > 0 ? totalScore / reportCount : 0.0;
  }

  /// Emit validation event
  void _emitEvent(ValidationEvent event) {
    _eventController.add(event);
  }

  /// Dispose resources
  void dispose() {
    print('🗑️ Disposing Architecture Validator...');
    _eventController.close();
    print('✅ Architecture Validator disposed');
  }
}

/// Architecture rule
class ArchitectureRule {
  final String id;
  final String name;
  final String description;
  final RuleSeverity severity;
  final Future<RuleValidationResult> Function() validator;

  ArchitectureRule({
    required this.id,
    required this.name,
    required this.description,
    required this.severity,
    required this.validator,
  });
}

/// Rule validation result
class RuleValidationResult {
  final bool isValid;
  final List<ArchitectureViolation> violations;

  const RuleValidationResult({
    required this.isValid,
    required this.violations,
  });
}

/// Architecture violation
class ArchitectureViolation {
  final String ruleId;
  final String componentId;
  final ViolationSeverity severity;
  final String description;
  final String suggestion;
  final DateTime detectedAt;

  ArchitectureViolation({
    required this.ruleId,
    required this.componentId,
    required this.severity,
    required this.description,
    required this.suggestion,
  }) : detectedAt = DateTime.now();
}

/// Architecture validation report
class ArchitectureValidationReport {
  final DateTime startTime;
  DateTime? endTime;
  bool success = false;
  String? error;
  final List<ArchitectureViolation> violations = [];

  // Statistics
  int hierarchyViolations = 0;
  int dependencyViolations = 0;
  int layerViolations = 0;
  int namingViolations = 0;
  int organizationViolations = 0;
  int scalabilityViolations = 0;
  int performanceViolations = 0;
  int securityViolations = 0;

  ArchitectureValidationReport({required this.startTime});

  void addViolation(ArchitectureViolation violation) {
    violations.add(violation);
  }

  Duration? get duration {
    if (endTime == null) return null;
    return endTime!.difference(startTime);
  }

  double get healthScore {
    if (violations.isEmpty) return 100.0;

    double totalWeight = 0.0;
    double totalScore = 0.0;

    for (final violation in violations) {
      double weight = 1.0;
      switch (violation.severity) {
        case ViolationSeverity.critical:
          weight = 10.0;
          break;
        case ViolationSeverity.high:
          weight = 5.0;
          break;
        case ViolationSeverity.medium:
          weight = 2.0;
          break;
        case ViolationSeverity.low:
          weight = 1.0;
          break;
      }

      totalWeight += weight;
      totalScore += weight;
    }

    return max(0.0, 100.0 - (totalScore / totalWeight) * 10);
  }

  Map<String, dynamic> get statistics => {
    'hierarchyViolations': hierarchyViolations,
    'dependencyViolations': dependencyViolations,
    'layerViolations': layerViolations,
    'namingViolations': namingViolations,
    'organizationViolations': organizationViolations,
    'scalabilityViolations': scalabilityViolations,
    'performanceViolations': performanceViolations,
    'securityViolations': securityViolations,
    'totalViolations': violations.length,
    'healthScore': healthScore,
    'duration': duration?.inMilliseconds,
    'success': success,
  };
}

/// Validation event
class ValidationEvent {
  final ValidationEventType type;
  final ArchitectureViolation? violation;
  final DateTime timestamp;

  ValidationEvent({
    required this.type,
    this.violation,
    required this.timestamp,
  });
}

/// Enums
enum RuleSeverity {
  low,
  medium,
  high,
  critical,
}

enum ViolationSeverity {
  low,
  medium,
  high,
  critical,
}

enum ValidationEventType {
  validationStarted,
  validationCompleted,
  violationDetected,
  ruleValidated,
}

/// Global validator instance
final architectureValidator = ArchitectureValidator();
