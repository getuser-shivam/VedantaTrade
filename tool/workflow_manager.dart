#!/usr/bin/env dart

import 'dart:io';
import 'dart:convert';
import 'dart:async';

/// VedantaTrade Workflow Manager
/// Main orchestrator for all development tools and workflows
class VedantaTradeWorkflowManager {
  static const String projectRoot = 'i:\\Path\\Projects\\VedantaTrade';
  
  final Map<String, dynamic> _workflowResults = {};
  final List<String> _workflowLogs = [];
  final DateTime _startTime = DateTime.now();
  
  /// Main workflow orchestrator
  Future<void> runCompleteWorkflow() async {
    print('🚀 Starting VedantaTrade Complete Development Workflow...');
    print('═' * 80);
    print('📅 Started: $_startTime');
    print('═' * 80);
    
    try {
      // 1. Environment Validation
      await _validateEnvironment();
      
      // 2. Code Analysis & Problem Detection
      await _runCodeAnalysis();
      
      // 3. Automatic Problem Fixing
      await _applyAutomaticFixes();
      
      // 4. Build Application
      await _buildApplication();
      
      // 5. Run Comprehensive Tests
      await _runComprehensiveTests();
      
      // 6. Quality Assurance
      await _runQualityAssurance();
      
      // 7. Version Control Integration
      await _integrateVersionControl();
      
      // 8. Documentation Updates
      await _updateDocumentation();
      
      // 9. Generate Final Report
      await _generateFinalReport();
      
      final duration = DateTime.now().difference(_startTime);
      print('\n✅ Complete Workflow Finished Successfully!');
      print('⏱️  Total Duration: ${duration.inMinutes} minutes ${duration.inSeconds % 60} seconds');
      
    } catch (e) {
      print('\n❌ Complete Workflow Failed!');
      print('Error: $e');
      await _logError(e.toString());
    }
  }
  
  /// Validate development environment
  Future<void> _validateEnvironment() async {
    print('\n🔍 Validating Development Environment...');
    
    try {
      // Check Flutter installation
      final flutterResult = await Process.run('flutter', ['--version']);
      if (flutterResult.exitCode == 0) {
        print('  ✓ Flutter: ${flutterResult.stdout.trim()}');
        _workflowResults['flutter_version'] = flutterResult.stdout.trim();
      } else {
        throw Exception('Flutter not installed or not working');
      }
      
      // Check Dart installation
      final dartResult = await Process.run('dart', ['--version']);
      if (dartResult.exitCode == 0) {
        print('  ✓ Dart: ${dartResult.stdout.trim()}');
        _workflowResults['dart_version'] = dartResult.stdout.trim();
      } else {
        throw Exception('Dart not installed or not working');
      }
      
      // Check project structure
      final projectDir = Directory(projectRoot);
      if (!await projectDir.exists()) {
        throw Exception('Project directory not found: $projectRoot');
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
        final filePath = '$projectRoot\\$file';
        final fileObj = File(filePath);
        
        if (await fileObj.exists()) {
          print('  ✓ $file exists');
        } else {
          print('  ⚠ $file missing');
          throw Exception('Required file missing: $file');
        }
      }
      
      // Check available tools
      final tools = ['git', 'flutter', 'dart'];
      for (final tool in tools) {
        final result = await Process.run(tool, ['--version'], runInShell: true);
        if (result.exitCode == 0) {
          print('  ✓ $tool available');
        } else {
          print('  ⚠ $tool not available');
        }
      }
      
      _workflowResults['environment_validation'] = 'passed';
      _workflowLogs.add('Environment validation completed');
      
    } catch (e) {
      print('  ❌ Environment validation failed: $e');
      _workflowResults['environment_validation'] = 'failed';
      throw e;
    }
  }
  
  /// Run comprehensive code analysis
  Future<void> _runCodeAnalysis() async {
    print('\n🔍 Running Comprehensive Code Analysis...');
    
    try {
      // Run the dev analyzer
      print('  📊 Running development analyzer...');
      final analyzerResult = await Process.run('dart', [
        'tool/dev_analyzer.dart'
      ], workingDirectory: projectRoot);
      
      if (analyzerResult.exitCode == 0) {
        print('    ✓ Development analyzer completed');
        _workflowResults['code_analysis'] = 'passed';
      } else {
        print('    ⚠ Development analyzer found issues');
        print(analyzerResult.stderr);
        _workflowResults['code_analysis'] = 'issues_found';
      }
      
      // Run static analysis
      print('  🔍 Running static analysis...');
      final staticResult = await Process.run('dart', ['analyze'], workingDirectory: projectRoot);
      
      if (staticResult.exitCode == 0) {
        print('    ✓ Static analysis passed');
        _workflowResults['static_analysis'] = 'passed';
      } else {
        print('    ⚠ Static analysis found issues');
        _workflowResults['static_analysis'] = 'issues_found';
      }
      
      // Run dependency analysis
      print('  📦 Analyzing dependencies...');
      final depResult = await Process.run('flutter', ['pub', 'deps'], workingDirectory: projectRoot);
      
      if (depResult.exitCode == 0) {
        print('    ✓ Dependency analysis completed');
        _workflowResults['dependency_analysis'] = 'passed';
      } else {
        print('    ⚠ Dependency analysis failed');
        _workflowResults['dependency_analysis'] = 'failed';
      }
      
      _workflowLogs.add('Code analysis completed');
      
    } catch (e) {
      print('  ❌ Code analysis failed: $e');
      _workflowResults['code_analysis'] = 'failed';
      throw e;
    }
  }
  
  /// Apply automatic fixes
  Future<void> _applyAutomaticFixes() async {
    print('\n🔧 Applying Automatic Fixes...');
    
    try {
      // Fix import issues
      print('  📥 Fixing import issues...');
      final importResult = await Process.run('dart', ['fix', '--apply'], workingDirectory: projectRoot);
      
      if (importResult.exitCode == 0) {
        print('    ✓ Import issues fixed');
        _workflowResults['import_fixes'] = 'applied';
      } else {
        print('    ⚠ Import fix issues');
        _workflowResults['import_fixes'] = 'failed';
      }
      
      // Fix formatting issues
      print('  🎨 Fixing formatting issues...');
      final formatResult = await Process.run('dart', [
        'format',
        '.',
        '--set-exit-if-changed'
      ], workingDirectory: projectRoot);
      
      if (formatResult.exitCode == 0) {
        print('    ✓ Formatting issues fixed');
        _workflowResults['formatting_fixes'] = 'applied';
      } else {
        print('    ⚠ Formatting fix issues');
        _workflowResults['formatting_fixes'] = 'failed';
      }
      
      // Update dependencies
      print('  📦 Updating dependencies...');
      final updateResult = await Process.run('flutter', [
        'pub',
        'get'
      ], workingDirectory: projectRoot);
      
      if (updateResult.exitCode == 0) {
        print('    ✓ Dependencies updated');
        _workflowResults['dependency_updates'] = 'applied';
      } else {
        print('    ⚠ Dependency update issues');
        _workflowResults['dependency_updates'] = 'failed';
      }
      
      _workflowLogs.add('Automatic fixes applied');
      
    } catch (e) {
      print('  ❌ Automatic fixes failed: $e');
      _workflowResults['automatic_fixes'] = 'failed';
      throw e;
    }
  }
  
  /// Build application
  Future<void> _buildApplication() async {
    print('\n🏗️ Building Application...');
    
    try {
      // Clean previous builds
      print('  🧹 Cleaning previous builds...');
      final cleanResult = await Process.run('flutter', ['clean'], workingDirectory: projectRoot);
      
      if (cleanResult.exitCode == 0) {
        print('    ✓ Build directory cleaned');
      } else {
        print('    ⚠ Build cleanup issues');
      }
      
      // Get dependencies
      print('  📦 Getting dependencies...');
      final getResult = await Process.run('flutter', ['pub', 'get'], workingDirectory: projectRoot);
      
      if (getResult.exitCode != 0) {
        throw Exception('Failed to get dependencies');
      }
      
      // Build for different platforms
      final platforms = ['web', 'android', 'ios'];
      final buildResults = <String, bool>{};
      
      for (final platform in platforms) {
        print('  🏗️ Building for $platform...');
        
        late ProcessResult result;
        
        switch (platform) {
          case 'web':
            result = await Process.run('flutter', [
              'build',
              'web',
              '--release',
              '--web-renderer=canvas',
              '--no-sound-null-safety'
            ], workingDirectory: projectRoot);
            break;
          case 'android':
            result = await Process.run('flutter', [
              'build',
              'apk',
              '--release',
              '--shrink'
            ], workingDirectory: projectRoot);
            break;
          case 'ios':
            result = await Process.run('flutter', [
              'build',
              'ios',
              '--release',
              '--no-codesign'
            ], workingDirectory: projectRoot);
            break;
        }
        
        if (result.exitCode == 0) {
          print('    ✓ $platform build successful');
          buildResults[platform] = true;
        } else {
          print('    ❌ $platform build failed');
          print(result.stderr);
          buildResults[platform] = false;
        }
      }
      
      _workflowResults['build_results'] = buildResults;
      _workflowResults['build_success'] = buildResults.values.every((success) => success);
      
      _workflowLogs.add('Application build completed');
      
    } catch (e) {
      print('  ❌ Application build failed: $e');
      _workflowResults['build_success'] = false;
      throw e;
    }
  }
  
  /// Run comprehensive tests
  Future<void> _runComprehensiveTests() async {
    print('\n🧪 Running Comprehensive Tests...');
    
    try {
      // Run unit tests
      print('  🧪 Running unit tests...');
      final unitResult = await Process.run('flutter', [
        'test',
        '--coverage',
        '--machine'
      ], workingDirectory: projectRoot);
      
      if (unitResult.exitCode == 0) {
        print('    ✓ Unit tests passed');
        final coverage = _parseTestCoverage(unitResult.stdout);
        _workflowResults['unit_tests'] = 'passed';
        _workflowResults['unit_coverage'] = coverage;
        print('    Coverage: ${coverage.toStringAsFixed(1)}%');
      } else {
        print('    ❌ Unit tests failed');
        _workflowResults['unit_tests'] = 'failed';
        _workflowResults['unit_test_errors'] = unitResult.stderr;
      }
      
      // Run widget tests
      print('  🎨 Running widget tests...');
      final widgetResult = await Process.run('flutter', [
        'test',
        'test/widget'
      ], workingDirectory: projectRoot);
      
      if (widgetResult.exitCode == 0) {
        print('    ✓ Widget tests passed');
        _workflowResults['widget_tests'] = 'passed';
      } else {
        print('    ❌ Widget tests failed');
        _workflowResults['widget_tests'] = 'failed';
        _workflowResults['widget_test_errors'] = widgetResult.stderr;
      }
      
      // Run integration tests
      final integrationDir = Directory('$projectRoot\\integration_test');
      if (await integrationDir.exists()) {
        print('  🔗 Running integration tests...');
        final integrationResult = await Process.run('flutter', [
          'test',
          'integration_test'
        ], workingDirectory: projectRoot);
        
        if (integrationResult.exitCode == 0) {
          print('    ✓ Integration tests passed');
          _workflowResults['integration_tests'] = 'passed';
        } else {
          print('    ❌ Integration tests failed');
          _workflowResults['integration_tests'] = 'failed';
          _workflowResults['integration_test_errors'] = integrationResult.stderr;
        }
      } else {
        print('    ⚠ No integration tests found');
        _workflowResults['integration_tests'] = 'not_found';
      }
      
      _workflowLogs.add('Comprehensive tests completed');
      
    } catch (e) {
      print('  ❌ Comprehensive tests failed: $e');
      _workflowResults['test_execution'] = 'failed';
      throw e;
    }
  }
  
  /// Run quality assurance
  Future<void> _runQualityAssurance() async {
    print('\n🔍 Running Quality Assurance...');
    
    try {
      // Check build quality
      print('  🏗️ Checking build quality...');
      final buildSuccess = _workflowResults['build_success'] as bool? ?? false;
      
      if (buildSuccess) {
        print('    ✓ Build quality is good');
        _workflowResults['build_quality'] = 'passed';
      } else {
        print('    ⚠ Build quality issues detected');
        _workflowResults['build_quality'] = 'failed';
      }
      
      // Check test coverage
      print('  📊 Checking test coverage...');
      final unitCoverage = _workflowResults['unit_coverage'] as double? ?? 0.0;
      
      if (unitCoverage >= 80) {
        print('    ✓ Test coverage is excellent (${unitCoverage.toStringAsFixed(1)}%)');
        _workflowResults['test_coverage_quality'] = 'excellent';
      } else if (unitCoverage >= 60) {
        print('    ⚠ Test coverage is acceptable (${unitCoverage.toStringAsFixed(1)}%)');
        _workflowResults['test_coverage_quality'] = 'acceptable';
      } else {
        print('    ❌ Test coverage is poor (${unitCoverage.toStringAsFixed(1)}%)');
        _workflowResults['test_coverage_quality'] = 'poor';
      }
      
      // Check code quality
      print('  🔍 Checking code quality...');
      final codeAnalysis = _workflowResults['code_analysis'] as String? ?? 'failed';
      
      if (codeAnalysis == 'passed') {
        print('    ✓ Code quality is good');
        _workflowResults['code_quality'] = 'passed';
      } else {
        print('    ⚠ Code quality issues detected');
        _workflowResults['code_quality'] = 'failed';
      }
      
      // Generate quality score
      final qualityScore = _calculateQualityScore();
      _workflowResults['quality_score'] = qualityScore;
      print('    📊 Overall Quality Score: ${qualityScore.toStringAsFixed(1)}/100');
      
      _workflowLogs.add('Quality assurance completed');
      
    } catch (e) {
      print('  ❌ Quality assurance failed: $e');
      throw e;
    }
  }
  
  /// Integrate version control
  Future<void> _integrateVersionControl() async {
    print('\n🔀 Integrating Version Control...');
    
    try {
      // Check git status
      print('  📝 Checking git status...');
      final statusResult = await Process.run('git', ['status'], workingDirectory: projectRoot);
      
      if (statusResult.exitCode == 0) {
        print('    ✓ Git status checked');
        _workflowResults['git_status'] = 'checked';
      } else {
        print('    ⚠ Git status check failed');
        _workflowResults['git_status'] = 'failed';
      }
      
      // Stage changes
      print('  📥 Staging changes...');
      final addResult = await Process.run('git', ['add', '.'], workingDirectory: projectRoot);
      
      if (addResult.exitCode == 0) {
        print('    ✓ Changes staged');
        _workflowResults['git_staging'] = 'completed';
      } else {
        print('    ⚠ Git staging failed');
        _workflowResults['git_staging'] = 'failed';
      }
      
      // Commit changes
      print('  📝 Committing changes...');
      final commitMessage = _generateCommitMessage();
      final commitResult = await Process.run('git', [
        'commit',
        '-m',
        commitMessage
      ], workingDirectory: projectRoot);
      
      if (commitResult.exitCode == 0) {
        print('    ✓ Changes committed');
        _workflowResults['git_commit'] = 'completed';
      } else {
        print('    ⚠ Git commit failed');
        _workflowResults['git_commit'] = 'failed';
      }
      
      _workflowLogs.add('Version control integration completed');
      
    } catch (e) {
      print('  ❌ Version control integration failed: $e');
      _workflowResults['version_control'] = 'failed';
      throw e;
    }
  }
  
  /// Update documentation
  Future<void> _updateDocumentation() async {
    print('\n📚 Updating Documentation...');
    
    try {
      // Update TODO
      print('  📋 Updating TODO...');
      final todoResult = await Process.run('dart', [
        'tool/github_manager.dart',
        '--update-docs'
      ], workingDirectory: projectRoot);
      
      if (todoResult.exitCode == 0) {
        print('    ✓ TODO updated');
        _workflowResults['todo_update'] = 'completed';
      } else {
        print('    ⚠ TODO update failed');
        _workflowResults['todo_update'] = 'failed';
      }
      
      // Update README
      print('  📖 Updating README...');
      final readmeResult = await Process.run('dart', [
        'tool/github_manager.dart',
        '--update-docs'
      ], workingDirectory: projectRoot);
      
      if (readmeResult.exitCode == 0) {
        print('    ✓ README updated');
        _workflowResults['readme_update'] = 'completed';
      } else {
        print('    ⚠ README update failed');
        _workflowResults['readme_update'] = 'failed';
      }
      
      // Update CHANGELOG
      print('  📝 Updating CHANGELOG...');
      final changelogResult = await Process.run('dart', [
        'tool/github_manager.dart',
        '--update-docs'
      ], workingDirectory: projectRoot);
      
      if (changelogResult.exitCode == 0) {
        print('    ✓ CHANGELOG updated');
        _workflowResults['changelog_update'] = 'completed';
      } else {
        print('    ⚠ CHANGELOG update failed');
        _workflowResults['changelog_update'] = 'failed';
      }
      
      _workflowLogs.add('Documentation updates completed');
      
    } catch (e) {
      print('  ❌ Documentation updates failed: $e');
      _workflowResults['documentation_updates'] = 'failed';
      throw e;
    }
  }
  
  /// Generate final report
  Future<void> _generateFinalReport() async {
    print('\n📊 Generating Final Report...');
    
    try {
      final duration = DateTime.now().difference(_startTime);
      
      final report = {
        'workflow_info': {
          'start_time': _startTime.toIso8601String(),
          'end_time': DateTime.now().toIso8601String(),
          'duration_minutes': duration.inMinutes,
          'duration_seconds': duration.inSeconds % 60,
          'total_steps': 9
        },
        'environment_validation': _workflowResults['environment_validation'],
        'code_analysis': _workflowResults['code_analysis'],
        'automatic_fixes': {
          'import_fixes': _workflowResults['import_fixes'],
          'formatting_fixes': _workflowResults['formatting_fixes'],
          'dependency_updates': _workflowResults['dependency_updates']
        },
        'build_results': _workflowResults['build_results'],
        'test_results': {
          'unit_tests': _workflowResults['unit_tests'],
          'unit_coverage': _workflowResults['unit_coverage'],
          'widget_tests': _workflowResults['widget_tests'],
          'integration_tests': _workflowResults['integration_tests']
        },
        'quality_assurance': {
          'build_quality': _workflowResults['build_quality'],
          'test_coverage_quality': _workflowResults['test_coverage_quality'],
          'code_quality': _workflowResults['code_quality'],
          'quality_score': _workflowResults['quality_score']
        },
        'version_control': {
          'git_status': _workflowResults['git_status'],
          'git_staging': _workflowResults['git_staging'],
          'git_commit': _workflowResults['git_commit']
        },
        'documentation_updates': {
          'todo_update': _workflowResults['todo_update'],
          'readme_update': _workflowResults['readme_update'],
          'changelog_update': _workflowResults['changelog_update']
        },
        'workflow_logs': _workflowLogs,
        'overall_status': _getOverallStatus(),
        'recommendations': _getRecommendations()
      };
      
      // Save JSON report
      final jsonReport = File('$projectRoot\\workflow_report.json');
      await jsonReport.writeAsString(JsonEncoder.withIndent('  ').convert(report));
      
      // Save Markdown report
      final mdReport = File('$projectRoot\\workflow_report.md');
      await mdReport.writeAsString(_generateMarkdownReport(report));
      
      print('  ✓ Final report generated');
      print('    📄 workflow_report.json');
      print('    📄 workflow_report.md');
      
      _workflowLogs.add('Final report generated');
      
    } catch (e) {
      print('  ❌ Final report generation failed: $e');
      throw e;
    }
  }
  
  /// Parse test coverage
  double _parseTestCoverage(String output) {
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
  
  /// Calculate quality score
  double _calculateQualityScore() {
    double score = 0.0;
    
    // Build quality (30 points)
    final buildSuccess = _workflowResults['build_success'] as bool? ?? false;
    if (buildSuccess) score += 30.0;
    
    // Test coverage (25 points)
    final unitCoverage = _workflowResults['unit_coverage'] as double? ?? 0.0;
    score += (unitCoverage / 100.0) * 25.0;
    
    // Code quality (25 points)
    final codeAnalysis = _workflowResults['code_analysis'] as String? ?? 'failed';
    if (codeAnalysis == 'passed') score += 25.0;
    
    // Documentation (10 points)
    final docsUpdated = (_workflowResults['todo_update'] == 'completed' &&
                      _workflowResults['readme_update'] == 'completed' &&
                      _workflowResults['changelog_update'] == 'completed');
    if (docsUpdated) score += 10.0;
    
    // Version control (10 points)
    final gitCommitted = _workflowResults['git_commit'] == 'completed';
    if (gitCommitted) score += 10.0;
    
    return score;
  }
  
  /// Get overall status
  String _getOverallStatus() {
    final qualityScore = _workflowResults['quality_score'] as double? ?? 0.0;
    
    if (qualityScore >= 90) {
      return 'EXCELLENT';
    } else if (qualityScore >= 80) {
      return 'GOOD';
    } else if (qualityScore >= 70) {
      return 'ACCEPTABLE';
    } else if (qualityScore >= 60) {
      return 'NEEDS_IMPROVEMENT';
    } else {
      return 'CRITICAL';
    }
  }
  
  /// Get recommendations
  List<String> _getRecommendations() {
    final recommendations = <String>[];
    final qualityScore = _workflowResults['quality_score'] as double? ?? 0.0;
    final unitCoverage = _workflowResults['unit_coverage'] as double? ?? 0.0;
    
    if (qualityScore < 80) {
      recommendations.add('Improve overall code quality to reach 80+ score');
    }
    
    if (unitCoverage < 80) {
      recommendations.add('Increase test coverage to at least 80%');
    }
    
    if (_workflowResults['build_success'] != true) {
      recommendations.add('Fix build issues across all platforms');
    }
    
    if (_workflowResults['code_analysis'] != 'passed') {
      recommendations.add('Address code analysis issues');
    }
    
    if (recommendations.isEmpty) {
      recommendations.add('Project is in excellent condition! 🎉');
    }
    
    return recommendations;
  }
  
  /// Generate commit message
  String _generateCommitMessage() {
    final timestamp = DateTime.now().toIso8601String();
    final qualityScore = _workflowResults['quality_score'] as double? ?? 0.0;
    final status = _getOverallStatus();
    
    return '''
feat: Complete development workflow automation

- Comprehensive code analysis and problem fixing
- Multi-platform application building
- Comprehensive testing with coverage reporting
- Quality assurance and validation
- Version control integration and documentation updates
- Generated workflow report with quality score: ${qualityScore.toStringAsFixed(1)}/100 ($status)

Workflow completed at: $timestamp
''';
  }
  
  /// Generate markdown report
  String _generateMarkdownReport(Map<String, dynamic> report) {
    final workflowInfo = report['workflow_info'] as Map<String, dynamic>;
    final overallStatus = report['overall_status'] as String;
    final qualityScore = report['quality_assurance']['quality_score'] as double;
    
    return '''
# VedantaTrade Development Workflow Report

**Generated:** ${DateTime.now().toIso8601String()}

## 📊 Overall Status: $overallStatus
**Quality Score:** ${qualityScore.toStringAsFixed(1)}/100

## 🕐 Workflow Information
- **Start Time:** ${workflowInfo['start_time']}
- **End Time:** ${workflowInfo['end_time']}
- **Duration:** ${workflowInfo['duration_minutes']} minutes ${workflowInfo['duration_seconds']} seconds
- **Total Steps:** ${workflowInfo['total_steps']}

## 🔍 Environment Validation
**Status:** ${report['environment_validation']}

## 🔍 Code Analysis
**Status:** ${report['code_analysis']}

## 🔧 Automatic Fixes Applied
- **Import Fixes:** ${report['automatic_fixes']['import_fixes']}
- **Formatting Fixes:** ${report['automatic_fixes']['formatting_fixes']}
- **Dependency Updates:** ${report['automatic_fixes']['dependency_updates']}

## 🏗️ Build Results
${(report['build_results'] as Map<String, bool>).entries.map((entry) => '- ${entry.key}: ${entry.value ? '✓' : '❌'}').join('\n')}

## 🧪 Test Results
- **Unit Tests:** ${report['test_results']['unit_tests']} (Coverage: ${report['test_results']['unit_coverage']}%)
- **Widget Tests:** ${report['test_results']['widget_tests']}
- **Integration Tests:** ${report['test_results']['integration_tests']}

## 🔍 Quality Assurance
- **Build Quality:** ${report['quality_assurance']['build_quality']}
- **Test Coverage Quality:** ${report['quality_assurance']['test_coverage_quality']}
- **Code Quality:** ${report['quality_assurance']['code_quality']}

## 🔀 Version Control
- **Git Status:** ${report['version_control']['git_status']}
- **Git Staging:** ${report['version_control']['git_staging']}
- **Git Commit:** ${report['version_control']['git_commit']}

## 📚 Documentation Updates
- **TODO Update:** ${report['documentation_updates']['todo_update']}
- **README Update:** ${report['documentation_updates']['readme_update']}
- **CHANGELOG Update:** ${report['documentation_updates']['changelog_update']}

## 💡 Recommendations
${(report['recommendations'] as List<String>).map((r) => '- $r').join('\n')}

## 📋 Workflow Logs
${(report['workflow_logs'] as List<String>).map((log) => '- $log').join('\n')}

---
*Report generated by VedantaTrade Workflow Manager*
''';
  }
  
  /// Log error
  Future<void> _logError(String error) async {
    final logFile = File('$projectRoot\\workflow_errors.log');
    final timestamp = DateTime.now().toIso8601String();
    await logFile.writeAsString('[$timestamp] $error\n', mode: FileMode.append);
  }
}

void main(List<String> arguments) async {
  final manager = VedantaTradeWorkflowManager();
  
  if (arguments.contains('--help') || arguments.contains('-h')) {
    print('''
VedantaTrade Workflow Manager

Usage: dart tool/workflow_manager.dart [options]

Options:
  --help, -h     Show this help message
  --analyze-only   Run analysis only (no build/test)
  --build-only     Run build only (no tests)
  --test-only      Run tests only (no build)
  --qa-only        Run quality assurance only
  --git-only       Run version control only
  --docs-only      Update documentation only
  --report-only    Generate report only

Examples:
  dart tool/workflow_manager.dart                    # Complete workflow
  dart tool/workflow_manager.dart --analyze-only      # Analysis only
  dart tool/workflow_manager.dart --build-only        # Build only
  dart tool/workflow_manager.dart --test-only         # Tests only
  dart tool/workflow_manager.dart --qa-only           # Quality assurance only
  dart tool/workflow_manager.dart --git-only          # Version control only
  dart tool/workflow_manager.dart --docs-only         # Documentation only
  dart tool/workflow_manager.dart --report-only       # Report only
''');
    return;
  }
  
  if (arguments.contains('--analyze-only')) {
    await manager._validateEnvironment();
    await manager._runCodeAnalysis();
    await manager._applyAutomaticFixes();
  } else if (arguments.contains('--build-only')) {
    await manager._validateEnvironment();
    await manager._runCodeAnalysis();
    await manager._applyAutomaticFixes();
    await manager._buildApplication();
  } else if (arguments.contains('--test-only')) {
    await manager._validateEnvironment();
    await manager._runComprehensiveTests();
  } else if (arguments.contains('--qa-only')) {
    await manager._runQualityAssurance();
  } else if (arguments.contains('--git-only')) {
    await manager._integrateVersionControl();
  } else if (arguments.contains('--docs-only')) {
    await manager._updateDocumentation();
  } else if (arguments.contains('--report-only')) {
    await manager._generateFinalReport();
  } else {
    await manager.runCompleteWorkflow();
  }
}
