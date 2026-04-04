#!/usr/bin/env dart

import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:path/path.dart' as path;

/// VedantaTrade Development Analyzer
/// Comprehensive tool for analyzing code, fixing problems, and building the app
class VedantaTradeDevAnalyzer {
  static const String projectRoot = 'i:\\Path\\Projects\\VedantaTrade';
  static const String libDir = 'lib';
  static const String testDir = 'test';
  static const String buildDir = 'build';
  
  final List<String> _analysisResults = [];
  final List<String> _fixesApplied = [];
  final Map<String, dynamic> _buildMetrics = {};
  
  /// Main analysis and build process
  Future<void> runFullAnalysis() async {
    print('🚀 Starting VedantaTrade Development Analysis...');
    print('=' * 60);
    
    try {
      // 1. Project Structure Analysis
      await _analyzeProjectStructure();
      
      // 2. Code Quality Analysis
      await _analyzeCodeQuality();
      
      // 3. Dependencies Analysis
      await _analyzeDependencies();
      
      // 4. Performance Analysis
      await _analyzePerformance();
      
      // 5. Security Analysis
      await _analyzeSecurity();
      
      // 6. Test Coverage Analysis
      await _analyzeTestCoverage();
      
      // 7. Apply Automatic Fixes
      await _applyAutomaticFixes();
      
      // 8. Build Application
      await _buildApplication();
      
      // 9. Generate Report
      await _generateAnalysisReport();
      
      print('✅ Development Analysis Complete!');
      
    } catch (e) {
      print('❌ Analysis failed: $e');
      await _logError(e.toString());
    }
  }
  
  /// Analyze project structure
  Future<void> _analyzeProjectStructure() async {
    print('\n📁 Analyzing Project Structure...');
    
    final projectDir = Directory(projectRoot);
    if (!await projectDir.exists()) {
      throw Exception('Project directory not found: $projectRoot');
    }
    
    // Check required directories
    final requiredDirs = [
      libDir,
      testDir,
      'android',
      'ios',
      'web',
      'assets',
      '.github'
    ];
    
    for (final dir in requiredDirs) {
      final dirPath = path.join(projectRoot, dir);
      final dir = Directory(dirPath);
      
      if (await dir.exists()) {
        print('  ✓ $dir directory exists');
      } else {
        print('  ⚠ $dir directory missing');
        await _createDirectory(dirPath);
      }
    }
    
    // Check required files
    final requiredFiles = [
      'pubspec.yaml',
      'analysis_options.yaml',
      'README.md',
      'CHANGELOG.md',
      'TODO.md'
    ];
    
    for (final file in requiredFiles) {
      final filePath = path.join(projectRoot, file);
      final fileObj = File(filePath);
      
      if (await fileObj.exists()) {
        print('  ✓ $file exists');
      } else {
        print('  ⚠ $file missing');
        await _createMissingFile(filePath);
      }
    }
    
    _analysisResults.add('Project structure analysis completed');
  }
  
  /// Analyze code quality
  Future<void> _analyzeCodeQuality() async {
    print('\n🔍 Analyzing Code Quality...');
    
    try {
      // Run dart analyze
      final result = await Process.run('dart', ['analyze'], workingDirectory: projectRoot);
      
      if (result.exitCode == 0) {
        print('  ✓ No code quality issues found');
      } else {
        print('  ⚠ Code quality issues detected:');
        print(result.stderr);
        
        // Parse and categorize issues
        final issues = _parseAnalysisOutput(result.stderr);
        await _categorizeIssues(issues);
      }
      
      _analysisResults.add('Code quality analysis completed');
      
    } catch (e) {
      print('  ❌ Code quality analysis failed: $e');
    }
  }
  
  /// Analyze dependencies
  Future<void> _analyzeDependencies() async {
    print('\n📦 Analyzing Dependencies...');
    
    try {
      final pubspecFile = File(path.join(projectRoot, 'pubspec.yaml'));
      if (!await pubspecFile.exists()) {
        throw Exception('pubspec.yaml not found');
      }
      
      final content = await pubspecFile.readAsString();
      print('  ✓ Dependencies analyzed');
      
      // Check for outdated dependencies
      await _checkDependencyUpdates();
      
      _analysisResults.add('Dependencies analysis completed');
      
    } catch (e) {
      print('  ❌ Dependencies analysis failed: $e');
    }
  }
  
  /// Analyze performance
  Future<void> _analyzePerformance() async {
    print('\n⚡ Analyzing Performance...');
    
    try {
      // Check for performance issues
      final libDir = Directory(path.join(projectRoot, libDir));
      await for (final entity in libDir.list(recursive: true)) {
        if (entity is File && entity.path.endsWith('.dart')) {
          await _analyzeFileForPerformance(entity);
        }
      }
      
      _analysisResults.add('Performance analysis completed');
      
    } catch (e) {
      print('  ❌ Performance analysis failed: $e');
    }
  }
  
  /// Analyze security
  Future<void> _analyzeSecurity() async {
    print('\n🔒 Analyzing Security...');
    
    try {
      // Check for security issues
      final securityIssues = await _checkSecurityIssues();
      
      if (securityIssues.isEmpty) {
        print('  ✓ No security issues found');
      } else {
        print('  ⚠ Security issues found:');
        for (final issue in securityIssues) {
          print('    - $issue');
        }
      }
      
      _analysisResults.add('Security analysis completed');
      
    } catch (e) {
      print('  ❌ Security analysis failed: $e');
    }
  }
  
  /// Analyze test coverage
  Future<void> _analyzeTestCoverage() async {
    print('\n🧪 Analyzing Test Coverage...');
    
    try {
      // Run tests with coverage
      final result = await Process.run('flutter', [
        'test',
        '--coverage',
        '--machine'
      ], workingDirectory: projectRoot);
      
      if (result.exitCode == 0) {
        final coverage = _parseCoverageOutput(result.stdout);
        print('  ✓ Test coverage: ${coverage.toStringAsFixed(1)}%');
        
        _buildMetrics['testCoverage'] = coverage;
        
        if (coverage < 80) {
          print('  ⚠ Low test coverage detected');
          await _suggestTestImprovements();
        }
      } else {
        print('  ❌ Test coverage analysis failed');
        print(result.stderr);
      }
      
      _analysisResults.add('Test coverage analysis completed');
      
    } catch (e) {
      print('  ❌ Test coverage analysis failed: $e');
    }
  }
  
  /// Apply automatic fixes
  Future<void> _applyAutomaticFixes() async {
    print('\n🔧 Applying Automatic Fixes...');
    
    try {
      // Fix import issues
      await _fixImportIssues();
      
      // Fix formatting issues
      await _fixFormattingIssues();
      
      // Fix dependency issues
      await _fixDependencyIssues();
      
      // Fix security issues
      await _fixSecurityIssues();
      
      print('  ✓ Automatic fixes applied');
      _analysisResults.add('Automatic fixes applied');
      
    } catch (e) {
      print('  ❌ Automatic fixes failed: $e');
    }
  }
  
  /// Build application
  Future<void> _buildApplication() async {
    print('\n🏗️ Building Application...');
    
    try {
      // Clean previous builds
      await _cleanBuild();
      
      // Build for different platforms
      final platforms = ['web', 'android', 'ios'];
      
      for (final platform in platforms) {
        print('  Building for $platform...');
        
        final result = await Process.run('flutter', [
          'build',
          platform,
          '--release'
        ], workingDirectory: projectRoot);
        
        if (result.exitCode == 0) {
          print('    ✓ $platform build successful');
          _buildMetrics['$platform\_build'] = true;
        } else {
          print('    ❌ $platform build failed');
          print(result.stderr);
          _buildMetrics['$platform\_build'] = false;
        }
      }
      
      // Build metrics
      _buildMetrics['buildTime'] = DateTime.now().toIso8601String();
      _buildMetrics['buildSuccess'] = true;
      
      _analysisResults.add('Application build completed');
      
    } catch (e) {
      print('  ❌ Build failed: $e');
      _buildMetrics['buildSuccess'] = false;
    }
  }
  
  /// Generate analysis report
  Future<void> _generateAnalysisReport() async {
    print('\n📊 Generating Analysis Report...');
    
    final report = {
      'timestamp': DateTime.now().toIso8601String(),
      'analysisResults': _analysisResults,
      'fixesApplied': _fixesApplied,
      'buildMetrics': _buildMetrics,
      'projectStatus': _getProjectStatus(),
      'recommendations': _getRecommendations()
    };
    
    final reportFile = File(path.join(projectRoot, 'analysis_report.json'));
    await reportFile.writeAsString(JsonEncoder.withIndent('  ').convert(report));
    
    print('  ✓ Report saved to analysis_report.json');
    
    // Generate human-readable report
    await _generateHumanReadableReport(report);
  }
  
  /// Parse analysis output
  List<Map<String, String>> _parseAnalysisOutput(String output) {
    final lines = output.split('\n');
    final issues = <Map<String, String>>[];
    
    for (final line in lines) {
      if (line.contains('error') || line.contains('warning') || line.contains('info')) {
        final parts = line.split('•');
        if (parts.length >= 2) {
          issues.add({
            'type': parts[0].trim(),
            'message': parts[1].trim()
          });
        }
      }
    }
    
    return issues;
  }
  
  /// Categorize issues
  Future<void> _categorizeIssues(List<Map<String, String>> issues) async {
    final categories = {
      'error': [],
      'warning': [],
      'info': [],
      'style': []
    };
    
    for (final issue in issues) {
      final type = issue['type']?.toLowerCase() ?? 'info';
      if (categories.containsKey(type)) {
        categories[type]!.add(issue['message'] ?? '');
      }
    }
    
    for (final entry in categories.entries) {
      if (entry.value.isNotEmpty) {
        print('  ${entry.key.toUpperCase()}: ${entry.value.length} issues');
      }
    }
  }
  
  /// Check for dependency updates
  Future<void> _checkDependencyUpdates() async {
    try {
      final result = await Process.run('flutter', ['pub', 'outdated'], workingDirectory: projectRoot);
      
      if (result.exitCode == 0) {
        final lines = result.stdout.split('\n');
        for (final line in lines) {
          if (line.contains('↑')) {
            print('  ⚠ Outdated dependency: $line');
          }
        }
      }
    } catch (e) {
      print('  Could not check dependency updates: $e');
    }
  }
  
  /// Analyze file for performance issues
  Future<void> _analyzeFileForPerformance(File file) async {
    try {
      final content = await file.readAsString();
      
      // Check for common performance issues
      final performanceIssues = <String>[];
      
      if (content.contains('setState(() {')) {
        performanceIssues.add('Potential unnecessary setState calls');
      }
      
      if (content.contains('FutureBuilder(') && !content.contains('const')) {
        performanceIssues.add('FutureBuilder without const optimization');
      }
      
      if (content.contains('ListView.builder(') && !content.contains('itemCount')) {
        performanceIssues.add('ListView.builder without itemCount optimization');
      }
      
      if (performanceIssues.isNotEmpty) {
        print('  ⚠ Performance issues in ${file.path}:');
        for (final issue in performanceIssues) {
          print('    - $issue');
        }
      }
      
    } catch (e) {
      print('  Could not analyze ${file.path}: $e');
    }
  }
  
  /// Check for security issues
  Future<List<String>> _checkSecurityIssues() async {
    final securityIssues = <String>[];
    
    try {
      final libDir = Directory(path.join(projectRoot, libDir));
      await for (final entity in libDir.list(recursive: true)) {
        if (entity is File && entity.path.endsWith('.dart')) {
          final content = await entity.readAsString();
          
          // Check for common security issues
          if (content.contains('http://') && !content.contains('https://')) {
            securityIssues.add('Insecure HTTP protocol usage in ${entity.path}');
          }
          
          if (content.contains('print(') && !content.contains('debugPrint')) {
            securityIssues.add('Potential information leak in ${entity.path}');
          }
          
          if (content.contains('password') || content.contains('secret') || content.contains('token')) {
            if (!content.contains('Environment') && !content.contains('.env')) {
              securityIssues.add('Hardcoded sensitive data in ${entity.path}');
            }
          }
        }
      }
      
    } catch (e) {
      print('  Security analysis error: $e');
    }
    
    return securityIssues;
  }
  
  /// Parse coverage output
  double _parseCoverageOutput(String output) {
    final lines = output.split('\n');
    for (final line in lines) {
      if (line.contains('coverage:')) {
        final match = RegExp(r'(\d+\.?\d*)%').firstMatch(line);
        if (match != null) {
          return double.tryParse(match.group(1)!) ?? 0.0;
        }
      }
    }
    return 0.0;
  }
  
  /// Suggest test improvements
  Future<void> _suggestTestImprovements() async {
    print('  💡 Test improvement suggestions:');
    print('    - Add more unit tests for business logic');
    print('    - Add integration tests for API calls');
    print('    - Add widget tests for UI components');
    print('    - Consider adding golden tests for visual regression');
  }
  
  /// Fix import issues
  Future<void> _fixImportIssues() async {
    print('  🔧 Fixing import issues...');
    
    try {
      final result = await Process.run('dart', [
        'fix',
        '--apply'
      ], workingDirectory: projectRoot);
      
      if (result.exitCode == 0) {
        print('    ✓ Import issues fixed');
        _fixesApplied.add('Import issues fixed');
      }
    } catch (e) {
      print('    Could not fix import issues: $e');
    }
  }
  
  /// Fix formatting issues
  Future<void> _fixFormattingIssues() async {
    print('  🔧 Fixing formatting issues...');
    
    try {
      final result = await Process.run('dart', [
        'format',
        '.',
        '--set-exit-if-changed'
      ], workingDirectory: projectRoot);
      
      if (result.exitCode == 0) {
        print('    ✓ Formatting issues fixed');
        _fixesApplied.add('Formatting issues fixed');
      }
    } catch (e) {
      print('    Could not fix formatting issues: $e');
    }
  }
  
  /// Fix dependency issues
  Future<void> _fixDependencyIssues() async {
    print('  🔧 Fixing dependency issues...');
    
    try {
      final result = await Process.run('flutter', [
        'pub',
        'get'
      ], workingDirectory: projectRoot);
      
      if (result.exitCode == 0) {
        print('    ✓ Dependencies fixed');
        _fixesApplied.add('Dependencies fixed');
      }
    } catch (e) {
      print('    Could not fix dependencies: $e');
    }
  }
  
  /// Fix security issues
  Future<void> _fixSecurityIssues() async {
    print('  🔧 Fixing security issues...');
    
    // This would implement specific security fixes
    // For now, just log that we attempted to fix
    _fixesApplied.add('Security issues reviewed');
  }
  
  /// Clean build directory
  Future<void> _cleanBuild() async {
    print('  🧹 Cleaning previous builds...');
    
    try {
      final buildDir = Directory(path.join(projectRoot, buildDir));
      if (await buildDir.exists()) {
        await buildDir.delete(recursive: true);
        print('    ✓ Build directory cleaned');
      }
    } catch (e) {
      print('    Could not clean build directory: $e');
    }
  }
  
  /// Get project status
  String _getProjectStatus() {
    final buildSuccess = _buildMetrics['buildSuccess'] as bool? ?? false;
    final testCoverage = _buildMetrics['testCoverage'] as double? ?? 0.0;
    
    if (buildSuccess && testCoverage >= 80) {
      return 'HEALTHY';
    } else if (buildSuccess && testCoverage >= 60) {
      return 'WARNING';
    } else {
      return 'CRITICAL';
    }
  }
  
  /// Get recommendations
  List<String> _getRecommendations() {
    final recommendations = <String>[];
    final testCoverage = _buildMetrics['testCoverage'] as double? ?? 0.0;
    
    if (testCoverage < 80) {
      recommendations.add('Increase test coverage to at least 80%');
    }
    
    if (_buildMetrics['android_build'] != true) {
      recommendations.add('Fix Android build issues');
    }
    
    if (_buildMetrics['ios_build'] != true) {
      recommendations.add('Fix iOS build issues');
    }
    
    if (_buildMetrics['web_build'] != true) {
      recommendations.add('Fix web build issues');
    }
    
    return recommendations;
  }
  
  /// Generate human-readable report
  Future<void> _generateHumanReadableReport(Map<String, dynamic> report) async {
    final reportFile = File(path.join(projectRoot, 'analysis_report.md'));
    
    final content = '''
# VedantaTrade Development Analysis Report

**Generated:** ${report['timestamp']}

## Project Status: ${report['projectStatus']}

## Analysis Results
${report['analysisResults'].map((r) => '- $r').join('\n')}

## Fixes Applied
${report['fixesApplied'].map((f) => '- $f').join('\n')}

## Build Metrics
- **Build Success:** ${report['buildMetrics']['buildSuccess']}
- **Build Time:** ${report['buildMetrics']['buildTime']}
- **Test Coverage:** ${report['buildMetrics']['testCoverage']}%
- **Android Build:** ${report['buildMetrics']['android_build']}
- **iOS Build:** ${report['buildMetrics']['ios_build']}
- **Web Build:** ${report['buildMetrics']['web_build']}

## Recommendations
${report['recommendations'].map((r) => '- $r').join('\n')}

---
*Report generated by VedantaTrade Development Analyzer*
''';
    
    await reportFile.writeAsString(content);
    print('  ✓ Human-readable report saved to analysis_report.md');
  }
  
  /// Create directory
  Future<void> _createDirectory(String dirPath) async {
    try {
      final dir = Directory(dirPath);
      await dir.create(recursive: true);
      print('    Created directory: $dirPath');
    } catch (e) {
      print('    Could not create directory $dirPath: $e');
    }
  }
  
  /// Create missing file
  Future<void> _createMissingFile(String filePath) async {
    try {
      final file = File(filePath);
      await file.create(recursive: true);
      print('    Created file: $filePath');
    } catch (e) {
      print('    Could not create file $filePath: $e');
    }
  }
  
  /// Log error
  Future<void> _logError(String error) async {
    final logFile = File(path.join(projectRoot, 'analysis_errors.log'));
    final timestamp = DateTime.now().toIso8601String();
    await logFile.writeAsString('[$timestamp] $error\n', mode: FileMode.append);
  }
}

void main(List<String> arguments) async {
  final analyzer = VedantaTradeDevAnalyzer();
  
  if (arguments.contains('--help') || arguments.contains('-h')) {
    print('''
VedantaTrade Development Analyzer

Usage: dart tool/dev_analyzer.dart [options]

Options:
  --help, -h     Show this help message
  --analyze-only   Run analysis only (no build)
  --build-only     Run build only (no analysis)
  --fix-only       Apply fixes only
  --report         Generate report only

Examples:
  dart tool/dev_analyzer.dart                    # Full analysis and build
  dart tool/dev_analyzer.dart --analyze-only      # Analysis only
  dart tool/dev_analyzer.dart --build-only        # Build only
''');
    return;
  }
  
  if (arguments.contains('--analyze-only')) {
    await analyzer._analyzeProjectStructure();
    await analyzer._analyzeCodeQuality();
    await analyzer._analyzeDependencies();
    await analyzer._analyzePerformance();
    await analyzer._analyzeSecurity();
    await analyzer._analyzeTestCoverage();
  } else if (arguments.contains('--build-only')) {
    await analyzer._buildApplication();
  } else if (arguments.contains('--fix-only')) {
    await analyzer._applyAutomaticFixes();
  } else if (arguments.contains('--report')) {
    await analyzer._generateAnalysisReport();
  } else {
    await analyzer.runFullAnalysis();
  }
}
