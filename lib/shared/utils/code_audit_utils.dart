import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';

/// Code Audit and Cleanup Utilities
/// Ensures all components are working properly and removes unnecessary code
class CodeAuditUtils {
  static const List<String> _unnecessaryImports = [
    'dart:html',
    'dart:js',
    'dart:io', // Only if not used
    'dart:mirrors',
    'package:flutter/foundation.dart', // Only if kDebugMode not used
    'package:flutter/services.dart', // Only if SystemChrome not used
  ];

  static const List<String> _deprecatedWidgets = [
    'FlatButton',
    'RaisedButton',
    'OutlineButton',
    'Scaffold.of(context).showSnackBar',
    'AnimatedContainer',
    'FadeTransition',
  ];

  static const List<String> _performanceAntiPatterns = [
    'buildMethodInsideBuild',
    'setStateInBuildMethod',
    'expensiveOperationsInBuild',
    'missingConstConstructors',
    'unnecessaryWidgetRebuilds',
  ];

  /// Perform comprehensive code audit
  static Future<AuditReport> performAudit(String projectPath) async {
    final auditReport = AuditReport();
    
    try {
      // Scan for unused imports
      await _scanForUnusedImports(projectPath, auditReport);
      
      // Scan for deprecated widgets
      await _scanForDeprecatedWidgets(projectPath, auditReport);
      
      // Scan for performance issues
      await _scanForPerformanceIssues(projectPath, auditReport);
      
      // Scan for dead code
      await _scanForDeadCode(projectPath, auditReport);
      
      // Scan for security issues
      await _scanForSecurityIssues(projectPath, auditReport);
      
      // Scan for unused files
      await _scanForUnusedFiles(projectPath, auditReport);
      
    } catch (e) {
      auditReport.addError('Audit failed: $e');
    }
    
    return auditReport;
  }

  /// Scan for unused imports
  static Future<void> _scanForUnusedImports(String projectPath, AuditReport report) async {
    final dartFiles = await _getDartFiles(projectPath);
    
    for (final file in dartFiles) {
      try {
        final content = await File(file).readAsString();
        final lines = content.split('\n');
        
        for (int i = 0; i < lines.length; i++) {
          final line = lines[i].trim();
          
          // Check for unnecessary imports
          for (final unnecessaryImport in _unnecessaryImports) {
            if (line.contains("import '$unnecessaryImport'") && 
                !_isImportUsed(content, unnecessaryImport)) {
              report.addIssue(AuditIssue(
                type: AuditIssueType.unusedImport,
                file: file,
                line: i + 1,
                message: 'Unused import: $unnecessaryImport',
                severity: AuditSeverity.warning,
              ));
            }
          }
        }
      } catch (e) {
        report.addError('Failed to scan file $file: $e');
      }
    }
  }

  /// Scan for deprecated widgets
  static Future<void> _scanForDeprecatedWidgets(String projectPath, AuditReport report) async {
    final dartFiles = await _getDartFiles(projectPath);
    
    for (final file in dartFiles) {
      try {
        final content = await File(file).readAsString();
        final lines = content.split('\n');
        
        for (int i = 0; i < lines.length; i++) {
          final line = lines[i];
          
          for (final deprecatedWidget in _deprecatedWidgets) {
            if (line.contains(deprecatedWidget)) {
              report.addIssue(AuditIssue(
                type: AuditIssueType.deprecatedWidget,
                file: file,
                line: i + 1,
                message: 'Deprecated widget used: $deprecatedWidget',
                severity: AuditSeverity.warning,
                suggestion: _getReplacementForDeprecated(deprecatedWidget),
              ));
            }
          }
        }
      } catch (e) {
        report.addError('Failed to scan file $file: $e');
      }
    }
  }

  /// Scan for performance issues
  static Future<void> _scanForPerformanceIssues(String projectPath, AuditReport report) async {
    final dartFiles = await _getDartFiles(projectPath);
    
    for (final file in dartFiles) {
      try {
        final content = await File(file).readAsString();
        final lines = content.split('\n');
        
        for (int i = 0; i < lines.length; i++) {
          final line = lines[i];
          
          // Check for setState in build method
          if (line.contains('setState(') && _isInBuildMethod(content, i)) {
            report.addIssue(AuditIssue(
              type: AuditIssueType.performanceIssue,
              file: file,
              line: i + 1,
              message: 'setState called in build method',
              severity: AuditSeverity.error,
              suggestion: 'Move setState outside build method',
            ));
          }
          
          // Check for expensive operations in build
          if (_isExpensiveOperation(line) && _isInBuildMethod(content, i)) {
            report.addIssue(AuditIssue(
              type: AuditIssueType.performanceIssue,
              file: file,
              line: i + 1,
              message: 'Expensive operation in build method',
              severity: AuditSeverity.warning,
              suggestion: 'Move operation outside build method or use memoization',
            ));
          }
          
          // Check for missing const constructors
          if (line.contains('new ') && !line.contains('const ') && _canBeConst(line)) {
            report.addIssue(AuditIssue(
              type: AuditIssueType.performanceIssue,
              file: file,
              line: i + 1,
              message: 'Missing const constructor',
              severity: AuditSeverity.info,
              suggestion: 'Use const constructor for better performance',
            ));
          }
        }
      } catch (e) {
        report.addError('Failed to scan file $file: $e');
      }
    }
  }

  /// Scan for dead code
  static Future<void> _scanForDeadCode(String projectPath, AuditReport report) async {
    final dartFiles = await _getDartFiles(projectPath);
    
    for (final file in dartFiles) {
      try {
        final content = await File(file).readAsString();
        
        // Check for unused classes
        final classes = _extractClasses(content);
        for (final className in classes) {
          if (!_isClassUsed(content, className)) {
            report.addIssue(AuditIssue(
              type: AuditIssueType.deadCode,
              file: file,
              message: 'Unused class: $className',
              severity: AuditSeverity.info,
            ));
          }
        }
        
        // Check for unused methods
        final methods = _extractMethods(content);
        for (final methodName in methods) {
          if (!_isMethodUsed(content, methodName)) {
            report.addIssue(AuditIssue(
              type: AuditIssueType.deadCode,
              file: file,
              message: 'Unused method: $methodName',
              severity: AuditSeverity.info,
            ));
          }
        }
        
        // Check for unused variables
        final variables = _extractVariables(content);
        for (final variableName in variables) {
          if (!_isVariableUsed(content, variableName)) {
            report.addIssue(AuditIssue(
              type: AuditIssueType.deadCode,
              file: file,
              message: 'Unused variable: $variableName',
              severity: AuditSeverity.info,
            ));
          }
        }
      } catch (e) {
        report.addError('Failed to scan file $file: $e');
      }
    }
  }

  /// Scan for security issues
  static Future<void> _scanForSecurityIssues(String projectPath, AuditReport report) async {
    final dartFiles = await _getDartFiles(projectPath);
    
    for (final file in dartFiles) {
      try {
        final content = await File(file).readAsString();
        final lines = content.split('\n');
        
        for (int i = 0; i < lines.length; i++) {
          final line = lines[i];
          
          // Check for hardcoded secrets
          if (_containsHardcodedSecret(line)) {
            report.addIssue(AuditIssue(
              type: AuditIssueType.securityIssue,
              file: file,
              line: i + 1,
              message: 'Potential hardcoded secret detected',
              severity: AuditSeverity.error,
              suggestion: 'Use environment variables or secure storage',
            ));
          }
          
          // Check for insecure HTTP usage
          if (line.contains('http://') && !line.contains('localhost')) {
            report.addIssue(AuditIssue(
              type: AuditIssueType.securityIssue,
              file: file,
              line: i + 1,
              message: 'Insecure HTTP usage detected',
              severity: AuditSeverity.warning,
              suggestion: 'Use HTTPS instead of HTTP',
            ));
          }
          
          // Check for debug prints in production
          if (line.contains('print(') || line.contains('debugPrint(')) {
            report.addIssue(AuditIssue(
              type: AuditIssueType.securityIssue,
              file: file,
              line: i + 1,
              message: 'Debug print statement found',
              severity: AuditSeverity.info,
              suggestion: 'Remove debug prints or wrap in kDebugMode',
            ));
          }
        }
      } catch (e) {
        report.addError('Failed to scan file $file: $e');
      }
    }
  }

  /// Scan for unused files
  static Future<void> _scanForUnusedFiles(String projectPath, AuditReport report) async {
    final allFiles = await _getAllFiles(projectPath);
    final usedFiles = <String>{};
    
    // Collect all imported files
    for (final file in allFiles) {
      if (file.endsWith('.dart')) {
        try {
          final content = await File(file).readAsString();
          final imports = _extractImports(content);
          
          for (final import in imports) {
            final importPath = _resolveImportPath(import, file);
            if (importPath != null) {
              usedFiles.add(importPath);
            }
          }
        } catch (e) {
          report.addError('Failed to scan file $file: $e');
        }
      }
    }
    
    // Find unused files
    for (final file in allFiles) {
      if (file.endsWith('.dart') && !usedFiles.contains(file)) {
        // Skip main files and test files
        if (!file.endsWith('_test.dart') && !file.endsWith('main.dart')) {
          report.addIssue(AuditIssue(
            type: AuditIssueType.unusedFile,
            file: file,
            message: 'Potentially unused file',
            severity: AuditSeverity.info,
          ));
        }
      }
    }
  }

  /// Get all Dart files in the project
  static Future<List<String>> _getDartFiles(String projectPath) async {
    final files = <String>[];
    await _collectDartFiles(Directory(projectPath), files);
    return files;
  }

  /// Recursively collect Dart files
  static Future<void> _collectDartFiles(Directory dir, List<String> files) async {
    try {
      await for (final entity in dir.list()) {
        if (entity is File && entity.path.endsWith('.dart')) {
          // Skip build and generated files
          if (!entity.path.contains('.dart_tool') && 
              !entity.path.contains('build/') && 
              !entity.path.contains('.g.dart')) {
            files.add(entity.path);
          }
        } else if (entity is Directory) {
          await _collectDartFiles(entity, files);
        }
      }
    } catch (e) {
      if (kDebugMode) 
    }
  }

  /// Get all files in the project
  static Future<List<String>> _getAllFiles(String projectPath) async {
    final files = <String>[];
    await _collectAllFiles(Directory(projectPath), files);
    return files;
  }

  /// Recursively collect all files
  static Future<void> _collectAllFiles(Directory dir, List<String> files) async {
    try {
      await for (final entity in dir.list()) {
        if (entity is File) {
          files.add(entity.path);
        } else if (entity is Directory) {
          await _collectAllFiles(entity, files);
        }
      }
    } catch (e) {
      if (kDebugMode) 
    }
  }

  /// Check if import is used in the file
  static bool _isImportUsed(String content, String importPath) {
    // Simple check - in a real implementation, this would be more sophisticated
    final importName = importPath.split('/').last.replaceAll('.dart', '');
    return content.contains(importName);
  }

  /// Check if line is in build method
  static bool _isInBuildMethod(String content, int lineIndex) {
    final lines = content.split('\n');
    int buildMethodStart = -1;
    int buildMethodEnd = -1;
    
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.startsWith('Widget build(') || line.startsWith('@override\n  Widget build(')) {
        buildMethodStart = i;
      }
      if (buildMethodStart != -1 && line.contains('}') && i > buildMethodStart) {
        buildMethodEnd = i;
        break;
      }
    }
    
    return buildMethodStart != -1 && buildMethodEnd != -1 && 
           lineIndex >= buildMethodStart && lineIndex <= buildMethodEnd;
  }

  /// Check if operation is expensive
  static bool _isExpensiveOperation(String line) {
    final expensivePatterns = [
      'FutureBuilder',
      'StreamBuilder',
      'ListView.builder',
      'GridView.builder',
      'Image.network',
      'http.',
      'dio.',
      'shared_preferences.',
      'sqlite.',
    ];
    
    for (final pattern in expensivePatterns) {
      if (line.contains(pattern)) {
        return true;
      }
    }
    
    return false;
  }

  /// Check if widget can be const
  static bool _canBeConst(String line) {
    // Simple check - in a real implementation, this would be more sophisticated
    final nonConstPatterns = [
      'final ',
      'var ',
      'DateTime.now()',
      'Random()',
      'Color(',
      'EdgeInsets.all(',
    ];
    
    for (final pattern in nonConstPatterns) {
      if (line.contains(pattern)) {
        return false;
      }
    }
    
    return true;
  }

  /// Extract classes from content
  static List<String> _extractClasses(String content) {
    final classes = <String>[];
    final regex = RegExp(r'class\s+(\w+)\s+(?:extends|implements|with)');
    final matches = regex.allMatches(content);
    
    for (final match in matches) {
      classes.add(match.group(1)!);
    }
    
    return classes;
  }

  /// Extract methods from content
  static List<String> _extractMethods(String content) {
    final methods = <String>[];
    final regex = RegExp(r'(?:\w+\s+)?(\w+)\s*\(');
    final matches = regex.allMatches(content);
    
    for (final match in matches) {
      final methodName = match.group(1);
      if (methodName != null && 
          methodName != 'build' && 
          methodName != 'initState' && 
          methodName != 'dispose') {
        methods.add(methodName);
      }
    }
    
    return methods;
  }

  /// Extract variables from content
  static List<String> _extractVariables(String content) {
    final variables = <String>[];
    final regex = RegExp(r'(?:final|const|var)\s+(\w+)\s*=');
    final matches = regex.allMatches(content);
    
    for (final match in matches) {
      variables.add(match.group(1)!);
    }
    
    return variables;
  }

  /// Check if class is used
  static bool _isClassUsed(String content, String className) {
    return content.contains(className) && content.contains('new $className');
  }

  /// Check if method is used
  static bool _isMethodUsed(String content, String methodName) {
    return content.contains('$methodName(');
  }

  /// Check if variable is used
  static bool _isVariableUsed(String content, String variableName) {
    return content.split(variableName).length > 2; // More than declaration + 1 usage
  }

  /// Check for hardcoded secrets
  static bool _containsHardcodedSecret(String line) {
// final secretPatterns = [ // TODO: Move to environment variables
// RegExp(r'password\s*=\s*[\'"][^\'"]+[\'"]'), // TODO: Move to environment variables
// RegExp(r'api_key\s*=\s*[\'"][^\'"]+[\'"]'), // TODO: Move to environment variables
// RegExp(r'secret\s*=\s*[\'"][^\'"]+[\'"]'), // TODO: Move to environment variables
// RegExp(r'token\s*=\s*[\'"][^\'"]+[\'"]'), // TODO: Move to environment variables
    ];
    
    for (final pattern in secretPatterns) {
      if (pattern.hasMatch(line)) {
        return true;
      }
    }
    
    return false;
  }

  /// Extract imports from content
  static List<String> _extractImports(String content) {
    final imports = <String>[];
    final regex = RegExp(r"import\s+['\"]([^'\"]+)['\"]");
    final matches = regex.allMatches(content);
    
    for (final match in matches) {
      imports.add(match.group(1)!);
    }
    
    return imports;
  }

  /// Resolve import path
  static String? _resolveImportPath(String importPath, String currentFile) {
    // Simple resolution - in a real implementation, this would be more sophisticated
    if (importPath.startsWith('package:')) {
      return importPath;
    }
    
    final currentDir = Directory(currentFile).parent;
    final resolvedPath = '${currentDir.path}/$importPath';
    
    if (File(resolvedPath).existsSync()) {
      return resolvedPath;
    }
    
    return null;
  }

  /// Get replacement for deprecated widget
  static String _getReplacementForDeprecated(String deprecated) {
    final replacements = {
      'FlatButton': 'TextButton',
      'RaisedButton': 'ElevatedButton',
      'OutlineButton': 'OutlinedButton',
      'Scaffold.of(context).showSnackBar': 'ScaffoldMessenger.of(context).showSnackBar',
    };
    
    return replacements[deprecated] ?? 'Check Flutter documentation for replacement';
  }

  /// Clean up code based on audit report
  static Future<void> cleanupCode(AuditReport report, {bool autoFix = false}) async {
    for (final issue in report.issues) {
      if (autoFix && issue.severity != AuditSeverity.error) {
        await _autoFixIssue(issue);
      }
    }
  }

  /// Auto-fix an issue
  static Future<void> _autoFixIssue(AuditIssue issue) async {
    try {
      final file = File(issue.file);
      if (!file.existsSync()) return;
      
      String content = await file.readAsString();
      final lines = content.split('\n');
      
      if (issue.line > 0 && issue.line <= lines.length) {
        final lineIndex = issue.line - 1;
        String line = lines[lineIndex];
        
        switch (issue.type) {
          case AuditIssueType.unusedImport:
            // Remove unused import
            lines.removeAt(lineIndex);
            break;
            
          case AuditIssueType.deprecatedWidget:
            // Replace deprecated widget
            if (issue.suggestion != null) {
              line = line.replaceAll(issue.message.split(':').last, issue.suggestion!);
              lines[lineIndex] = line;
            }
            break;
            
          case AuditIssueType.performanceIssue:
            // Add const constructor
            if (issue.message.contains('Missing const constructor')) {
              line = line.replaceAll('new ', 'const new ');
              lines[lineIndex] = line;
            }
            break;
        }
        
        // Write back the fixed content
        await file.writeAsString(lines.join('\n'));
      }
    } catch (e) {
      if (kDebugMode) 
    }
  }
}

/// Audit Report
class AuditReport {
  final List<AuditIssue> issues = [];
  final List<String> errors = [];
  
  void addIssue(AuditIssue issue) => issues.add(issue);
  void addError(String error) => errors.add(error);
  
  int get totalIssues => issues.length;
  int get errorCount => issues.where((i) => i.severity == AuditSeverity.error).length;
  int get warningCount => issues.where((i) => i.severity == AuditSeverity.warning).length;
  int get infoCount => issues.where((i) => i.severity == AuditSeverity.info).length;
  
  Map<String, dynamic> toJson() {
    return {
      'totalIssues': totalIssues,
      'errorCount': errorCount,
      'warningCount': warningCount,
      'infoCount': infoCount,
      'errors': errors,
      'issues': issues.map((i) => i.toJson()).toList(),
    };
  }
  
  void printReport() {

    if (errors.isNotEmpty) {
      
      for (final error in errors) {
        
      }
    }
    
    if (issues.isNotEmpty) {
      
      for (final issue in issues) {
        
        if (issue.suggestion != null) {
          
        }
      }
    }

  }
}

/// Audit Issue
class AuditIssue {
  final AuditIssueType type;
  final String file;
  final int line;
  final String message;
  final AuditSeverity severity;
  final String? suggestion;
  
  AuditIssue({
    required this.type,
    required this.file,
    required this.line,
    required this.message,
    required this.severity,
    this.suggestion,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'file': file,
      'line': line,
      'message': message,
      'severity': severity.name,
      'suggestion': suggestion,
    };
  }
}

/// Audit Issue Types
enum AuditIssueType {
  unusedImport,
  deprecatedWidget,
  performanceIssue,
  deadCode,
  securityIssue,
  unusedFile,
}

/// Audit Severity Levels
enum AuditSeverity {
  error,
  warning,
  info,
}
