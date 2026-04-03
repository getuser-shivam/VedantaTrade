import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:process_run/process_run.dart';

/// Comprehensive Dart code analyzer and problem fixer for VedantaTrade
class CodeAnalyzer {
  final String projectPath;
  final bool verbose;
  
  CodeAnalyzer(this.projectPath, {this.verbose = false});

  /// Run complete analysis and fix cycle
  Future<AnalysisResult> analyzeAndFix() async {
    final result = AnalysisResult();
    
    if (verbose) print('🔍 Starting code analysis...');
    
    // 1. Flutter analyze
    result.flutterIssues = await _runFlutterAnalyze();
    
    // 2. Dart format check
    result.formatIssues = await _checkDartFormat();
    
    // 3. Import analysis
    result.importIssues = await _analyzeImports();
    
    // 4. Unused code detection
    result.unusedCode = await _detectUnusedCode();
    
    // 5. Security issues
    result.securityIssues = await _checkSecurityIssues();
    
    // 6. Performance issues
    result.performanceIssues = await _checkPerformanceIssues();
    
    // 7. Fix issues automatically
    if (result.hasIssues) {
      result.fixResults = await _fixIssues(result);
    }
    
    return result;
  }

  /// Run flutter analyze
  Future<List<FlutterIssue>> _runFlutterAnalyze() async {
    final issues = <FlutterIssue>[];
    
    try {
      final process = await Process.run('flutter', ['analyze', '--json'], 
        workingDirectory: projectPath);
      
      if (process.exitCode != 0) {
        final output = process.stdout as String;
        final lines = output.split('\n');
        
        for (final line in lines) {
          if (line.trim().isEmpty) continue;
          
          try {
            final data = json.decode(line);
            if (data['type'] == 'issue') {
              issues.add(FlutterIssue.fromJson(data));
            }
          } catch (e) {
            // Skip invalid JSON lines
          }
        }
      }
    } catch (e) {
      if (verbose) print('❌ Flutter analyze failed: $e');
    }
    
    return issues;
  }

  /// Check dart format
  Future<List<FormatIssue>> _checkDartFormat() async {
    final issues = <FormatIssue>[];
    
    try {
      final process = await Process.run('dart', ['format', '--output=none', '--set-exit-if-changed', '.'], 
        workingDirectory: projectPath);
      
      if (process.exitCode != 0) {
        // Find unformatted files
        final formatProcess = await Process.run('dart', ['format', '--dry-run', '.'], 
          workingDirectory: projectPath);
        
        final output = formatProcess.stdout as String;
        final lines = output.split('\n');
        
        for (final line in lines) {
          if (line.trim().startsWith('Formatted')) {
            final file = line.replaceFirst('Formatted ', '').trim();
            issues.add(FormatIssue(file: file, type: 'unformatted'));
          }
        }
      }
    } catch (e) {
      if (verbose) print('❌ Dart format check failed: $e');
    }
    
    return issues;
  }

  /// Analyze imports
  Future<List<ImportIssue>> _analyzeImports() async {
    final issues = <ImportIssue>[];
    
    try {
      final dartFiles = await _findDartFiles();
      
      for (final file in dartFiles) {
        final content = await File(file).readAsString();
        final lines = content.split('\n');
        
        for (int i = 0; i < lines.length; i++) {
          final line = lines[i];
          
          // Check for unused imports
          if (line.trim().startsWith('import ')) {
            final importMatch = RegExp(r"import ['\"]([^'\"]+)['\"]").firstMatch(line);
            if (importMatch != null) {
              final importPath = importMatch.group(1)!;
              
              // Check if import is used
              final isUsed = await _isImportUsed(content, importPath);
              if (!isUsed) {
                issues.add(ImportIssue(
                  file: file,
                  line: i + 1,
                  importPath: importPath,
                  type: 'unused',
                ));
              }
            }
          }
          
          // Check for relative imports that should be absolute
          if (line.contains('import \'../') || line.contains('import \'../../')) {
            issues.add(ImportIssue(
              file: file,
              line: i + 1,
              importPath: line.trim(),
              type: 'relative',
            ));
          }
        }
      }
    } catch (e) {
      if (verbose) print('❌ Import analysis failed: $e');
    }
    
    return issues;
  }

  /// Detect unused code
  Future<List<UnusedCodeIssue>> _detectUnusedCode() async {
    final issues = <UnusedCodeIssue>[];
    
    try {
      final dartFiles = await _findDartFiles();
      
      for (final file in dartFiles) {
        final content = await File(file).readAsString();
        
        // Find unused classes
        final classMatches = RegExp(r'class\s+(\w+)').allMatches(content);
        for (final match in classMatches) {
          final className = match.group(1)!;
          if (className.startsWith('_')) continue; // Skip private classes
          
          final isUsed = await _isClassUsed(dartFiles, className);
          if (!isUsed) {
            issues.add(UnusedCodeIssue(
              file: file,
              type: 'class',
              name: className,
            ));
          }
        }
        
        // Find unused functions
        final funcMatches = RegExp(r'(?:^\s*|\s+)(\w+)\s*\([^)]*\)\s*{').allMatches(content);
        for (final match in funcMatches) {
          final funcName = match.group(1)!;
          if (funcName.startsWith('_')) continue; // Skip private functions
          if (['build', 'initState', 'dispose', 'createState'].contains(funcName)) continue;
          
          final isUsed = await _isFunctionUsed(dartFiles, funcName);
          if (!isUsed) {
            issues.add(UnusedCodeIssue(
              file: file,
              type: 'function',
              name: funcName,
            ));
          }
        }
      }
    } catch (e) {
      if (verbose) print('❌ Unused code detection failed: $e');
    }
    
    return issues;
  }

  /// Check security issues
  Future<List<SecurityIssue>> _checkSecurityIssues() async {
    final issues = <SecurityIssue>[];
    
    try {
      final dartFiles = await _findDartFiles();
      
      for (final file in dartFiles) {
        final content = await File(file).readAsString();
        final lines = content.split('\n');
        
        for (int i = 0; i < lines.length; i++) {
          final line = lines[i];
          
          // Check for print statements (should use debugPrint)
          if (line.contains('print(') && !line.contains('//')) {
            issues.add(SecurityIssue(
              file: file,
              line: i + 1,
              type: 'print_statement',
              description: 'Use debugPrint instead of print for production',
              severity: 'low',
            ));
          }
          
          // Check for hardcoded secrets
          if (line.contains('password') || line.contains('secret') || line.contains('api_key')) {
            if (line.contains('=') && !line.contains('//')) {
              issues.add(SecurityIssue(
                file: file,
                line: i + 1,
                type: 'hardcoded_secret',
                description: 'Potential hardcoded secret detected',
                severity: 'high',
              ));
            }
          }
          
          // Check for insecure HTTP usage
          if (line.contains('http://') && !line.contains('//')) {
            issues.add(SecurityIssue(
              file: file,
              line: i + 1,
              type: 'insecure_http',
              description: 'Use HTTPS instead of HTTP',
              severity: 'medium',
            ));
          }
        }
      }
    } catch (e) {
      if (verbose) print('❌ Security check failed: $e');
    }
    
    return issues;
  }

  /// Check performance issues
  Future<List<PerformanceIssue>> _checkPerformanceIssues() async {
    final issues = <PerformanceIssue>[];
    
    try {
      final dartFiles = await _findDartFiles();
      
      for (final file in dartFiles) {
        final content = await File(file).readAsString();
        final lines = content.split('\n');
        
        for (int i = 0; i < lines.length; i++) {
          final line = lines[i];
          
          // Check for setState in build method
          if (line.contains('setState') && line.contains('build')) {
            issues.add(PerformanceIssue(
              file: file,
              line: i + 1,
              type: 'setstate_in_build',
              description: 'setState should not be called in build method',
              severity: 'high',
            ));
          }
          
          // Check for missing const constructors
          if (line.contains('Widget(') && !line.contains('const Widget(')) {
            issues.add(PerformanceIssue(
              file: file,
              line: i + 1,
              type: 'missing_const',
              description: 'Use const constructor for better performance',
              severity: 'low',
            ));
          }
          
          // Check for large build methods
          if (line.contains('Widget build(')) {
            final buildMethodLines = _extractBuildMethodLines(lines, i);
            if (buildMethodLines > 50) {
              issues.add(PerformanceIssue(
                file: file,
                line: i + 1,
                type: 'large_build_method',
                description: 'Build method is too large (${buildMethodLines} lines)',
                severity: 'medium',
              ));
            }
          }
        }
      }
    } catch (e) {
      if (verbose) print('❌ Performance check failed: $e');
    }
    
    return issues;
  }

  /// Fix detected issues automatically
  Future<FixResults> _fixIssues(AnalysisResult result) async {
    final fixResults = FixResults();
    
    if (verbose) print('🔧 Starting automatic fixes...');
    
    // Fix format issues
    if (result.formatIssues.isNotEmpty) {
      final formatFixed = await _fixFormatIssues();
      fixResults.formatFixed = formatFixed;
    }
    
    // Fix unused imports
    if (result.importIssues.isNotEmpty) {
      final importFixed = await _fixImportIssues(result.importIssues);
      fixResults.importsFixed = importFixed;
    }
    
    // Fix print statements
    if (result.securityIssues.isNotEmpty) {
      final securityFixed = await _fixSecurityIssues(result.securityIssues);
      fixResults.securityFixed = securityFixed;
    }
    
    // Fix performance issues
    if (result.performanceIssues.isNotEmpty) {
      final performanceFixed = await _fixPerformanceIssues(result.performanceIssues);
      fixResults.performanceFixed = performanceFixed;
    }
    
    return fixResults;
  }

  /// Fix format issues
  Future<bool> _fixFormatIssues() async {
    try {
      final process = await Process.run('dart', ['format', '.'], 
        workingDirectory: projectPath);
      return process.exitCode == 0;
    } catch (e) {
      if (verbose) print('❌ Format fix failed: $e');
      return false;
    }
  }

  /// Fix import issues
  Future<int> _fixImportIssues(List<ImportIssue> issues) async {
    int fixed = 0;
    
    for (final issue in issues.where((i) => i.type == 'unused')) {
      try {
        final file = File(issue.file);
        final content = await file.readAsString();
        final lines = content.split('\n');
        
        // Remove unused import line
        lines.removeAt(issue.line - 1);
        
        await file.writeAsString(lines.join('\n'));
        fixed++;
      } catch (e) {
        if (verbose) print('❌ Failed to fix import in ${issue.file}: $e');
      }
    }
    
    return fixed;
  }

  /// Fix security issues
  Future<int> _fixSecurityIssues(List<SecurityIssue> issues) async {
    int fixed = 0;
    
    for (final issue in issues.where((i) => i.type == 'print_statement')) {
      try {
        final file = File(issue.file);
        final content = await file.readAsString();
        
        // Replace print with debugPrint
        final fixedContent = content.replaceAll('print(', 'debugPrint(');
        
        await file.writeAsString(fixedContent);
        fixed++;
      } catch (e) {
        if (verbose) print('❌ Failed to fix security issue in ${issue.file}: $e');
      }
    }
    
    return fixed;
  }

  /// Fix performance issues
  Future<int> _fixPerformanceIssues(List<PerformanceIssue> issues) async {
    int fixed = 0;
    
    for (final issue in issues.where((i) => i.type == 'missing_const')) {
      try {
        final file = File(issue.file);
        final content = await file.readAsString();
        final lines = content.split('\n');
        
        // Add const to Widget constructor
        final line = lines[issue.line - 1];
        if (line.contains('Widget(') && !line.contains('const Widget(')) {
          lines[issue.line - 1] = line.replaceFirst('Widget(', 'const Widget(');
          await file.writeAsString(lines.join('\n'));
          fixed++;
        }
      } catch (e) {
        if (verbose) print('❌ Failed to fix performance issue in ${issue.file}: $e');
      }
    }
    
    return fixed;
  }

  /// Find all Dart files in the project
  Future<List<String>> _findDartFiles() async {
    final files = <String>[];
    
    await for (final entity in Directory(projectPath).list(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        // Skip generated files
        if (!entity.path.contains('.g.dart') && 
            !entity.path.contains('.freezed.dart') &&
            !entity.path.contains('generated/')) {
          files.add(entity.path);
        }
      }
    }
    
    return files;
  }

  /// Check if an import is used in the file
  Future<bool> _isImportUsed(String content, String importPath) async {
    // Simple check - in real implementation, this would be more sophisticated
    final importName = importPath.split('/').last.replaceAll('.dart', '');
    return content.contains(RegExp(r'\b' + importName + r'\b'));
  }

  /// Check if a class is used in any file
  Future<bool> _isClassUsed(List<String> files, String className) async {
    for (final file in files) {
      final content = await File(file).readAsString();
      if (content.contains(RegExp(r'\b' + className + r'\b'))) {
        return true;
      }
    }
    return false;
  }

  /// Check if a function is used in any file
  Future<bool> _isFunctionUsed(List<String> files, String functionName) async {
    for (final file in files) {
      final content = await File(file).readAsString();
      if (content.contains(RegExp(r'\b' + functionName + r'\('))) {
        return true;
      }
    }
    return false;
  }

  /// Extract number of lines in build method
  int _extractBuildMethodLines(List<String> lines, int startIndex) {
    int braceCount = 0;
    int lineCount = 0;
    
    for (int i = startIndex; i < lines.length; i++) {
      final line = lines[i];
      
      if (line.contains('{')) braceCount++;
      if (line.contains('}')) braceCount--;
      
      lineCount++;
      
      if (braceCount == 0 && lineCount > 1) break;
    }
    
    return lineCount;
  }
}

/// Analysis result container
class AnalysisResult {
  List<FlutterIssue> flutterIssues = [];
  List<FormatIssue> formatIssues = [];
  List<ImportIssue> importIssues = [];
  List<UnusedCodeIssue> unusedCode = [];
  List<SecurityIssue> securityIssues = [];
  List<PerformanceIssue> performanceIssues = [];
  FixResults? fixResults;
  
  bool get hasIssues => 
      flutterIssues.isNotEmpty ||
      formatIssues.isNotEmpty ||
      importIssues.isNotEmpty ||
      unusedCode.isNotEmpty ||
      securityIssues.isNotEmpty ||
      performanceIssues.isNotEmpty;
  
  int get totalIssues => 
      flutterIssues.length +
      formatIssues.length +
      importIssues.length +
      unusedCode.length +
      securityIssues.length +
      performanceIssues.length;
}

/// Flutter issue model
class FlutterIssue {
  final String file;
  final int line;
  final String severity;
  final String type;
  final String message;
  
  FlutterIssue({
    required this.file,
    required this.line,
    required this.severity,
    required this.type,
    required this.message,
  });
  
  factory FlutterIssue.fromJson(Map<String, dynamic> json) {
    return FlutterIssue(
      file: json['location']['file'] ?? '',
      line: json['location']['line'] ?? 0,
      severity: json['severity'] ?? 'info',
      type: json['type'] ?? 'unknown',
      message: json['message'] ?? '',
    );
  }
}

/// Format issue model
class FormatIssue {
  final String file;
  final String type;
  
  FormatIssue({required this.file, required this.type});
}

/// Import issue model
class ImportIssue {
  final String file;
  final int line;
  final String importPath;
  final String type;
  
  ImportIssue({
    required this.file,
    required this.line,
    required this.importPath,
    required this.type,
  });
}

/// Unused code issue model
class UnusedCodeIssue {
  final String file;
  final String type;
  final String name;
  
  UnusedCodeIssue({
    required this.file,
    required this.type,
    required this.name,
  });
}

/// Security issue model
class SecurityIssue {
  final String file;
  final int line;
  final String type;
  final String description;
  final String severity;
  
  SecurityIssue({
    required this.file,
    required this.line,
    required this.type,
    required this.description,
    required this.severity,
  });
}

/// Performance issue model
class PerformanceIssue {
  final String file;
  final int line;
  final String type;
  final String description;
  final String severity;
  
  PerformanceIssue({
    required this.file,
    required this.line,
    required this.type,
    required this.description,
    required this.severity,
  });
}

/// Fix results model
class FixResults {
  bool formatFixed = false;
  int importsFixed = 0;
  int securityFixed = 0;
  int performanceFixed = 0;
  
  int get totalFixed => importsFixed + securityFixed + performanceFixed;
}
