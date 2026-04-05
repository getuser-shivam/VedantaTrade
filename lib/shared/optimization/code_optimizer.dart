import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';

/// Code Optimizer
/// Comprehensive code optimization system for removing unused sections and maximizing reusability
class CodeOptimizer {
  static final CodeOptimizer _instance = CodeOptimizer._internal();
  factory CodeOptimizer() => _instance;
  CodeOptimizer._internal();

  final Map<String, FileAnalysis> _fileAnalyses = {};
  final Map<String, OptimizationReport> _optimizationReports = {};
  final StreamController<OptimizationEvent> _eventController;
  bool _isOptimizing = false;

  CodeOptimizer() : _eventController = StreamController<OptimizationEvent>.broadcast();

  /// Stream of optimization events
  Stream<OptimizationEvent> get eventStream => _eventController.stream;

  /// Optimize the entire codebase
  Future<CodeOptimizationReport> optimizeCodebase(String projectPath) async {
    if (_isOptimizing) {
      throw StateError('Optimization already in progress');
    }

    _isOptimizing = true;
    final report = CodeOptimizationReport(startTime: DateTime.now());

    try {
// print('🚀 Starting codebase optimization...'); // Removed for production

      // Phase 1: Analyze all Dart files
      await _analyzeCodebase(projectPath, report);

      // Phase 2: Remove unused imports
      await _removeUnusedImports(report);

      // Phase 3: Remove unused code
      await _removeUnusedCode(report);

      // Phase 4: Consolidate duplicate code
      await _consolidateDuplicateCode(report);

      // Phase 5: Optimize component reusability
      await _optimizeReusability(report);

      // Phase 6: Reduce code complexity
      await _reduceComplexity(report);

      // Phase 7: Optimize performance
      await _optimizePerformance(report);

      report.endTime = DateTime.now();
      report.success = true;

// print('✅ Codebase optimization completed successfully'); // Removed for production
    } catch (e) {
      report.endTime = DateTime.now();
      report.success = false;
      report.error = e.toString();
// print('❌ Codebase optimization failed: $e'); // Removed for production
    } finally {
      _isOptimizing = false;
    }

    return report;
  }

  /// Analyze the codebase
  Future<void> _analyzeCodebase(String projectPath, CodeOptimizationReport report) async {
// print('📊 Phase 1: Analyzing codebase...'); // Removed for production

    final dartFiles = await _findDartFiles(projectPath);
    report.totalFiles = dartFiles.length;

    for (final filePath in dartFiles) {
      final analysis = await _analyzeFile(filePath);
      _fileAnalyses[filePath] = analysis;
      report.addFileAnalysis(analysis);

      _emitEvent(OptimizationEvent(
        type: OptimizationEventType.fileAnalyzed,
        filePath: filePath,
        timestamp: DateTime.now(),
        metadata: {
          'lines': analysis.totalLines,
          'imports': analysis.imports.length,
          'classes': analysis.classes.length,
          'functions': analysis.functions.length,
        },
      ));
    }

    report.analyzedFiles = dartFiles.length;
// print('✅ Phase 1 completed: ${dartFiles.length} files analyzed'); // Removed for production
  }

  /// Remove unused imports
  Future<void> _removeUnusedImports(CodeOptimizationReport report) async {
// print('🗑️ Phase 2: Removing unused imports...'); // Removed for production

    int totalImportsRemoved = 0;

    for (final analysis in _fileAnalyses.values) {
      final unusedImports = _findUnusedImports(analysis);
      
      if (unusedImports.isNotEmpty) {
        totalImportsRemoved += unusedImports.length;
        
        final suggestion = OptimizationSuggestion(
          type: OptimizationType.removeUnusedImports,
          filePath: analysis.filePath,
          priority: OptimizationPriority.medium,
          description: 'Remove ${unusedImports.length} unused imports from ${analysis.filePath}',
          estimatedImpact: OptimizationImpact.low,
          effort: OptimizationEffort.low,
          metadata: {
            'unusedImports': unusedImports,
          },
        );

        report.addSuggestion(suggestion);

        _emitEvent(OptimizationEvent(
          type: OptimizationEventType.suggestionGenerated,
          suggestion: suggestion,
          timestamp: DateTime.now(),
        ));
      }
    }

    report.unusedImportsRemoved = totalImportsRemoved;
// print('✅ Phase 2 completed: $totalImportsRemoved unused imports identified'); // Removed for production
  }

  /// Remove unused code
  Future<void> _removeUnusedCode(CodeOptimizationReport report) async {
// print('🗑️ Phase 3: Removing unused code...'); // Removed for production

    int totalUnusedCodeRemoved = 0;

    for (final analysis in _fileAnalyses.values) {
      final unusedCode = _findUnusedCode(analysis);
      
      if (unusedCode.isNotEmpty) {
        totalUnusedCodeRemoved += unusedCode.length;
        
        final suggestion = OptimizationSuggestion(
          type: OptimizationType.removeUnusedCode,
          filePath: analysis.filePath,
          priority: OptimizationPriority.high,
          description: 'Remove ${unusedCode.length} unused code elements from ${analysis.filePath}',
          estimatedImpact: OptimizationImpact.medium,
          effort: OptimizationEffort.medium,
          metadata: {
            'unusedCode': unusedCode,
          },
        );

        report.addSuggestion(suggestion);

        _emitEvent(OptimizationEvent(
          type: OptimizationEventType.suggestionGenerated,
          suggestion: suggestion,
          timestamp: DateTime.now(),
        ));
      }
    }

    report.unusedCodeRemoved = totalUnusedCodeRemoved;
// print('✅ Phase 3 completed: $totalUnusedCodeRemoved unused code elements identified'); // Removed for production
  }

  /// Consolidate duplicate code
  Future<void> _consolidateDuplicateCode(CodeOptimizationReport report) async {
// print('🔀 Phase 4: Consolidating duplicate code...'); // Removed for production

    final duplicates = _findDuplicateCode();
    int totalDuplicatesFound = 0;

    for (final duplicate in duplicates) {
      totalDuplicatesFound += duplicate.similarCode.length;
      
      final suggestion = OptimizationSuggestion(
        type: OptimizationType.consolidateDuplicate,
        filePath: duplicate.primaryFile,
        priority: OptimizationPriority.high,
        description: 'Consolidate duplicate code in ${duplicate.similarCode.length} files',
        estimatedImpact: OptimizationImpact.high,
        effort: OptimizationEffort.high,
        metadata: {
          'primaryFile': duplicate.primaryFile,
          'similarCode': duplicate.similarCode,
          'similarity': duplicate.similarity,
        },
      );

      report.addSuggestion(suggestion);

      _emitEvent(OptimizationEvent(
        type: OptimizationEventType.suggestionGenerated,
        suggestion: suggestion,
        timestamp: DateTime.now(),
      ));
    }

    report.duplicateCodeConsolidated = totalDuplicatesFound;
// print('✅ Phase 4 completed: $totalDuplicatesFound duplicate code blocks identified'); // Removed for production
  }

  /// Optimize reusability
  Future<void> _optimizeReusability(CodeOptimizationReport report) async {
// print('♻️ Phase 5: Optimizing reusability...'); // Removed for production

    int totalReusabilityOptimizations = 0;

    for (final analysis in _fileAnalyses.values) {
      final reusabilityIssues = _findReusabilityIssues(analysis);
      
      if (reusabilityIssues.isNotEmpty) {
        totalReusabilityOptimizations += reusabilityIssues.length;
        
        final suggestion = OptimizationSuggestion(
          type: OptimizationType.optimizeReusability,
          filePath: analysis.filePath,
          priority: OptimizationPriority.medium,
          description: 'Optimize reusability for ${reusabilityIssues.length} components',
          estimatedImpact: OptimizationImpact.high,
          effort: OptimizationEffort.medium,
          metadata: {
            'reusabilityIssues': reusabilityIssues,
          },
        );

        report.addSuggestion(suggestion);

        _emitEvent(OptimizationEvent(
          type: OptimizationEventType.suggestionGenerated,
          suggestion: suggestion,
          timestamp: DateTime.now(),
        ));
      }
    }

    report.reusabilityOptimized = totalReusabilityOptimizations;
// print('✅ Phase 5 completed: $totalReusabilityOptimizations reusability optimizations identified'); // Removed for production
  }

  /// Reduce complexity
  Future<void> _reduceComplexity(CodeOptimizationReport report) async {
// print('⚡ Phase 6: Reducing complexity...'); // Removed for production

    int totalComplexityReductions = 0;

    for (final analysis in _fileAnalyses.values) {
      final complexityIssues = _findComplexityIssues(analysis);
      
      if (complexityIssues.isNotEmpty) {
        totalComplexityReductions += complexityIssues.length;
        
        final suggestion = OptimizationSuggestion(
          type: OptimizationType.reduceComplexity,
          filePath: analysis.filePath,
          priority: OptimizationPriority.high,
          description: 'Reduce complexity for ${complexityIssues.length} functions/classes',
          estimatedImpact: OptimizationImpact.high,
          effort: OptimizationEffort.high,
          metadata: {
            'complexityIssues': complexityIssues,
          },
        );

        report.addSuggestion(suggestion);

        _emitEvent(OptimizationEvent(
          type: OptimizationEventType.suggestionGenerated,
          suggestion: suggestion,
          timestamp: DateTime.now(),
        ));
      }
    }

    report.complexityReduced = totalComplexityReductions;
// print('✅ Phase 6 completed: $totalComplexityReductions complexity reductions identified'); // Removed for production
  }

  /// Optimize performance
  Future<void> _optimizePerformance(CodeOptimizationReport report) async {
// print('⚡ Phase 7: Optimizing performance...'); // Removed for production

    int totalPerformanceOptimizations = 0;

    for (final analysis in _fileAnalyses.values) {
      final performanceIssues = _findPerformanceIssues(analysis);
      
      if (performanceIssues.isNotEmpty) {
        totalPerformanceOptimizations += performanceIssues.length;
        
        final suggestion = OptimizationSuggestion(
          type: OptimizationType.optimizePerformance,
          filePath: analysis.filePath,
          priority: OptimizationPriority.medium,
          description: 'Optimize performance for ${performanceIssues.length} issues',
          estimatedImpact: OptimizationImpact.medium,
          effort: OptimizationEffort.low,
          metadata: {
            'performanceIssues': performanceIssues,
          },
        );

        report.addSuggestion(suggestion);

        _emitEvent(OptimizationEvent(
          type: OptimizationEventType.suggestionGenerated,
          suggestion: suggestion,
          timestamp: DateTime.now(),
        ));
      }
    }

    report.performanceOptimized = totalPerformanceOptimizations;
// print('✅ Phase 7 completed: $totalPerformanceOptimizations performance optimizations identified'); // Removed for production
  }

  /// Find all Dart files in the project
  Future<List<String>> _findDartFiles(String projectPath) async {
    final dartFiles = <String>[];
    final directory = Directory(projectPath);

    await for (final entity in directory.list(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        dartFiles.add(entity.path);
      }
    }

    return dartFiles;
  }

  /// Analyze a single file
  Future<FileAnalysis> _analyzeFile(String filePath) async {
    final file = File(filePath);
    final content = await file.readAsString();
    final lines = content.split('\n');

    final analysis = FileAnalysis(
      filePath: filePath,
      totalLines: lines.length,
      imports: _extractImports(content),
      classes: _extractClasses(content),
      functions: _extractFunctions(content),
      variables: _extractVariables(content),
      complexity: _calculateComplexity(content),
      analyzedAt: DateTime.now(),
    );

    return analysis;
  }

  /// Extract imports from file content
  List<String> _extractImports(String content) {
    final imports = <String>[];
    final importRegex = RegExp(r'^import\s+["\']([^"\']+)["\'];', multiLine: true);
    
    for (final match in importRegex.allMatches(content)) {
      imports.add(match.group(1)!);
    }

    return imports;
  }

  /// Extract classes from file content
  List<String> _extractClasses(String content) {
    final classes = <String>[];
    final classRegex = RegExp(r'^class\s+(\w+)', multiLine: true);
    
    for (final match in classRegex.allMatches(content)) {
      classes.add(match.group(1)!);
    }

    return classes;
  }

  /// Extract functions from file content
  List<String> _extractFunctions(String content) {
    final functions = <String>[];
    final functionRegex = RegExp(r'^\s*\w+\s+(\w+)\s*\(', multiLine: true);
    
    for (final match in functionRegex.allMatches(content)) {
      functions.add(match.group(1)!);
    }

    return functions;
  }

  /// Extract variables from file content
  List<String> _extractVariables(String content) {
    final variables = <String>[];
    final variableRegex = RegExp(r'^\s*(final|const|late)\s+\w+\s+(\w+)', multiLine: true);
    
    for (final match in variableRegex.allMatches(content)) {
      variables.add(match.group(2)!);
    }

    return variables;
  }

  /// Calculate complexity of file content
  double _calculateComplexity(String content) {
    double complexity = 1.0;

    // Add complexity for control structures
    final controlStructures = [
      'if', 'else', 'for', 'while', 'switch', 'case', 'try', 'catch',
    ];

    for (final structure in controlStructures) {
      final regex = RegExp(r'\b' + structure + r'\b', caseSensitive: false);
      complexity += regex.allMatches(content).length * 0.5;
    }

    // Add complexity for nested blocks
    final nestedBlocks = RegExp(r'{').allMatches(content).length;
    complexity += nestedBlocks * 0.3;

    // Add complexity for function length
    final functionLengths = _getFunctionLengths(content);
    for (final length in functionLengths) {
      if (length > 50) complexity += 0.5;
      if (length > 100) complexity += 1.0;
    }

    return complexity;
  }

  /// Get function lengths
  List<int> _getFunctionLengths(String content) {
    final lengths = <int>[];
    final functionRegex = RegExp(r'\w+\s+\w+\s*\([^)]*\)\s*{', multiLine: true);
    
    for (final match in functionRegex.allMatches(content)) {
      final startIndex = match.start;
      final openBraces = 1;
      int endIndex = startIndex + 1;

      while (endIndex < content.length && openBraces > 0) {
        if (content[endIndex] == '{') {
          openBraces++;
        } else if (content[endIndex] == '}') {
          openBraces--;
        }
        endIndex++;
      }

      lengths.add(endIndex - startIndex);
    }

    return lengths;
  }

  /// Find unused imports
  List<String> _findUnusedImports(FileAnalysis analysis) {
    final unused = <String>[];
    
    // This is a simplified implementation
    // In practice, you'd need to parse the AST to check if imports are used
    for (final import in analysis.imports) {
      if (import.startsWith('dart:') || import.startsWith('package:flutter/')) {
        continue; // Assume these are used
      }
      
      // Simple heuristic: check if import name appears in content
      final importName = import.split('/').last.replaceAll('.dart', '');
      final isUsed = analysis.classes.any((c) => c.contains(importName)) ||
                    analysis.functions.any((f) => f.contains(importName));
      
      if (!isUsed) {
        unused.add(import);
      }
    }

    return unused;
  }

  /// Find unused code
  List<String> _findUnusedCode(FileAnalysis analysis) {
    final unused = <String>[];
    
    // This is a simplified implementation
    // In practice, you'd need to parse the AST to check if code is used
    
    // Check for unused classes
    for (final className in analysis.classes) {
      if (!_isClassUsed(className, analysis)) {
        unused.add('class $className');
      }
    }

    // Check for unused functions
    for (final functionName in analysis.functions) {
      if (!_isFunctionUsed(functionName, analysis)) {
        unused.add('function $functionName');
      }
    }

    return unused;
  }

  /// Check if class is used
  bool _isClassUsed(String className, FileAnalysis analysis) {
    // Simplified check - in practice, you'd need full AST analysis
    return className == 'main' || className.contains('Widget');
  }

  /// Check if function is used
  bool _isFunctionUsed(String functionName, FileAnalysis analysis) {
    // Simplified check - in practice, you'd need full AST analysis
    return functionName == 'main' || functionName.startsWith('_');
  }

  /// Find duplicate code
  List<DuplicateCodeBlock> _findDuplicateCode() {
    final duplicates = <DuplicateCodeBlock>[];
    final processed = <String>{};

    for (final analysis in _fileAnalyses.values) {
      if (processed.contains(analysis.filePath)) continue;

      final similar = _findSimilarCode(analysis);
      if (similar.length > 1) {
        duplicates.add(DuplicateCodeBlock(
          primaryFile: analysis.filePath,
          similarCode: similar,
          similarity: _calculateSimilarity(analysis, similar.first),
        ));
        processed.addAll(similar.map((s) => s.filePath));
      }
    }

    return duplicates;
  }

  /// Find similar code blocks
  List<FileAnalysis> _findSimilarCode(FileAnalysis analysis) {
    final similar = [analysis];

    for (final other in _fileAnalyses.values) {
      if (other.filePath == analysis.filePath) continue;

      if (_calculateSimilarity(analysis, other) > 0.8) {
        similar.add(other);
      }
    }

    return similar;
  }

  /// Calculate similarity between two files
  double _calculateSimilarity(FileAnalysis a, FileAnalysis b) {
    double similarity = 0.0;

    // Import similarity
    final aImports = a.imports.toSet();
    final bImports = b.imports.toSet();
    final importIntersection = aImports.intersection(bImports);
    final importUnion = aImports.union(bImports);
    
    if (importUnion.isNotEmpty) {
      similarity += (importIntersection.length / importUnion.length) * 0.2;
    }

    // Class similarity
    final aClasses = a.classes.toSet();
    final bClasses = b.classes.toSet();
    final classIntersection = aClasses.intersection(bClasses);
    final classUnion = aClasses.union(bClasses);
    
    if (classUnion.isNotEmpty) {
      similarity += (classIntersection.length / classUnion.length) * 0.3;
    }

    // Function similarity
    final aFunctions = a.functions.toSet();
    final bFunctions = b.functions.toSet();
    final functionIntersection = aFunctions.intersection(bFunctions);
    final functionUnion = aFunctions.union(bFunctions);
    
    if (functionUnion.isNotEmpty) {
      similarity += (functionIntersection.length / functionUnion.length) * 0.3;
    }

    // Complexity similarity
    final complexityDiff = (a.complexity - b.complexity).abs();
    final maxComplexity = max(a.complexity, b.complexity);
    if (maxComplexity > 0) {
      similarity += (1 - complexityDiff / maxComplexity) * 0.2;
    }

    return similarity;
  }

  /// Find reusability issues
  List<String> _findReusabilityIssues(FileAnalysis analysis) {
    final issues = <String>[];

    // Check for hardcoded values
    if (analysis.classes.any((c) => c.contains('Constants') == false)) {
      issues.add('Consider extracting constants');
    }

    // Check for duplicate logic
    if (analysis.functions.length > 10) {
      issues.add('Consider consolidating similar functions');
    }

    // Check for large classes
    for (final className in analysis.classes) {
      if (className.length > 20) {
        issues.add('Consider breaking down large class: $className');
      }
    }

    return issues;
  }

  /// Find complexity issues
  List<String> _findComplexityIssues(FileAnalysis analysis) {
    final issues = <String>[];

    if (analysis.complexity > 10) {
      issues.add('High complexity: ${analysis.complexity.toStringAsFixed(2)}');
    }

    if (analysis.totalLines > 500) {
      issues.add('Large file: ${analysis.totalLines} lines');
    }

    if (analysis.functions.length > 20) {
      issues.add('Too many functions: ${analysis.functions.length}');
    }

    return issues;
  }

  /// Find performance issues
  List<String> _findPerformanceIssues(FileAnalysis analysis) {
    final issues = <String>[];

    // Check for potential performance issues
    if (analysis.imports.any((i) => i.contains('dart:io'))) {
      issues.add('File I/O operations detected');
    }

    if (analysis.imports.any((i) => i.contains('dart:convert'))) {
      issues.add('JSON operations detected');
    }

    return issues;
  }

  /// Get optimization suggestions
  Map<String, OptimizationSuggestion> getSuggestions() {
    final suggestions = <String, OptimizationSuggestion>{};
    
    for (final report in _optimizationReports.values) {
      for (final suggestion in report.suggestions) {
        suggestions[suggestion.filePath] = suggestion;
      }
    }

    return suggestions;
  }

  /// Apply optimization suggestion
  Future<bool> applySuggestion(String filePath) async {
    // Implementation would apply the optimization suggestion
// print('🔧 Applying optimization for $filePath...'); // Removed for production
    return true;
  }

  /// Emit optimization event
  void _emitEvent(OptimizationEvent event) {
    _eventController.add(event);
  }

  /// Dispose resources
  void dispose() {
// print('🗑️ Disposing Code Optimizer...'); // Removed for production
    _eventController.close();
// print('✅ Code Optimizer disposed'); // Removed for production
  }
}

/// File analysis
class FileAnalysis {
  final String filePath;
  final int totalLines;
  final List<String> imports;
  final List<String> classes;
  final List<String> functions;
  final List<String> variables;
  final double complexity;
  final DateTime analyzedAt;

  FileAnalysis({
    required this.filePath,
    required this.totalLines,
    required this.imports,
    required this.classes,
    required this.functions,
    required this.variables,
    required this.complexity,
    required this.analyzedAt,
  });
}

/// Duplicate code block
class DuplicateCodeBlock {
  final String primaryFile;
  final List<FileAnalysis> similarCode;
  final double similarity;

  DuplicateCodeBlock({
    required this.primaryFile,
    required this.similarCode,
    required this.similarity,
  });
}

/// Code optimization report
class CodeOptimizationReport {
  final DateTime startTime;
  DateTime? endTime;
  bool success = false;
  String? error;
  final List<FileAnalysis> fileAnalyses = [];
  final List<OptimizationSuggestion> suggestions = [];

  // Statistics
  int totalFiles = 0;
  int analyzedFiles = 0;
  int unusedImportsRemoved = 0;
  int unusedCodeRemoved = 0;
  int duplicateCodeConsolidated = 0;
  int reusabilityOptimized = 0;
  int complexityReduced = 0;
  int performanceOptimized = 0;

  CodeOptimizationReport({required this.startTime});

  void addFileAnalysis(FileAnalysis analysis) {
    fileAnalyses.add(analysis);
  }

  void addSuggestion(OptimizationSuggestion suggestion) {
    suggestions.add(suggestion);
  }

  Duration? get duration {
    if (endTime == null) return null;
    return endTime!.difference(startTime);
  }

  Map<String, dynamic> get statistics => {
    'totalFiles': totalFiles,
    'analyzedFiles': analyzedFiles,
    'unusedImportsRemoved': unusedImportsRemoved,
    'unusedCodeRemoved': unusedCodeRemoved,
    'duplicateCodeConsolidated': duplicateCodeConsolidated,
    'reusabilityOptimized': reusabilityOptimized,
    'complexityReduced': complexityReduced,
    'performanceOptimized': performanceOptimized,
    'totalSuggestions': suggestions.length,
    'duration': duration?.inMilliseconds,
    'success': success,
  };
}

/// Optimization suggestion
class OptimizationSuggestion {
  final OptimizationType type;
  final String filePath;
  final OptimizationPriority priority;
  final String description;
  final OptimizationImpact estimatedImpact;
  final OptimizationEffort effort;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;

  OptimizationSuggestion({
    required this.type,
    required this.filePath,
    required this.priority,
    required this.description,
    required this.estimatedImpact,
    required this.effort,
    this.metadata = const {},
  }) : createdAt = DateTime.now();
}

/// Optimization event
class OptimizationEvent {
  final OptimizationEventType type;
  final String? filePath;
  final OptimizationSuggestion? suggestion;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  OptimizationEvent({
    required this.type,
    this.filePath,
    this.suggestion,
    required this.timestamp,
    this.metadata = const {},
  });
}

/// Enums
enum OptimizationType {
  removeUnusedImports,
  removeUnusedCode,
  consolidateDuplicate,
  optimizeReusability,
  reduceComplexity,
  optimizePerformance,
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
  fileAnalyzed,
  suggestionGenerated,
  suggestionApplied,
  optimizationStarted,
  optimizationCompleted,
}

/// Global optimizer instance
final codeOptimizer = CodeOptimizer();
