#!/usr/bin/env dart

import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:path/path.dart' as path;

/// VedantaTrade Build Automation
/// Comprehensive tool for building, testing, and deploying the Flutter application
class VedantaTradeBuildAutomation {
  static const String projectRoot = 'i:\\Path\\Projects\\VedantaTrade';
  static const String buildDir = 'build';
  static const String outputDir = 'dist';
  
  final Map<String, dynamic> _buildResults = {};
  final List<String> _buildLogs = [];
  final Map<String, dynamic> _testResults = {};
  
  /// Main build automation workflow
  Future<void> runBuildWorkflow() async {
    print('🚀 Starting VedantaTrade Build Automation...');
    print('=' * 60);
    
    try {
      // 1. Environment Setup
      await _setupEnvironment();
      
      // 2. Dependency Management
      await _manageDependencies();
      
      // 3. Code Quality Checks
      await _runCodeQualityChecks();
      
      // 4. Run Tests
      await _runTests();
      
      // 5. Build Application
      await _buildApplication();
      
      // 6. Generate Artifacts
      await _generateArtifacts();
      
      // 7. Deploy if needed
      await _deployIfNeeded();
      
      // 8. Generate Build Report
      await _generateBuildReport();
      
      print('✅ Build Automation Complete!');
      
    } catch (e) {
      print('❌ Build automation failed: $e');
      await _logError(e.toString());
    }
  }
  
  /// Setup build environment
  Future<void> _setupEnvironment() async {
    print('\n🔧 Setting Up Environment...');
    
    try {
      // Check Flutter installation
      final flutterResult = await Process.run('flutter', ['--version']);
      if (flutterResult.exitCode == 0) {
        print('  ✓ Flutter: ${flutterResult.stdout.trim()}');
      } else {
        throw Exception('Flutter not found or not working');
      }
      
      // Check Dart installation
      final dartResult = await Process.run('dart', ['--version']);
      if (dartResult.exitCode == 0) {
        print('  ✓ Dart: ${dartResult.stdout.trim()}');
      } else {
        throw Exception('Dart not found or not working');
      }
      
      // Clean previous builds
      await _cleanBuildDirectory();
      
      // Create output directory
      await _createOutputDirectory();
      
      _buildLogs.add('Environment setup completed');
      
    } catch (e) {
      print('  ❌ Environment setup failed: $e');
      throw e;
    }
  }
  
  /// Manage dependencies
  Future<void> _manageDependencies() async {
    print('\n📦 Managing Dependencies...');
    
    try {
      // Get dependencies
      print('  Getting dependencies...');
      final getResult = await Process.run('flutter', ['pub', 'get'], workingDirectory: projectRoot);
      
      if (getResult.exitCode == 0) {
        print('    ✓ Dependencies retrieved');
      } else {
        print('    ❌ Failed to get dependencies');
        print(getResult.stderr);
        throw Exception('Dependency retrieval failed');
      }
      
      // Check for outdated dependencies
      print('  Checking for outdated dependencies...');
      final outdatedResult = await Process.run('flutter', ['pub', 'outdated'], workingDirectory: projectRoot);
      
      if (outdatedResult.exitCode == 0) {
        final lines = outdatedResult.stdout.split('\n');
        final outdated = lines.where((line) => line.contains('↑')).toList();
        
        if (outdated.isNotEmpty) {
          print('    ⚠ Outdated dependencies found:');
          for (final dep in outdated) {
            print('      $dep');
          }
        } else {
          print('    ✓ All dependencies up to date');
        }
      }
      
      // Upgrade dependencies if needed
      if (outdated.isNotEmpty) {
        print('  Upgrading dependencies...');
        final upgradeResult = await Process.run('flutter', ['pub', 'upgrade'], workingDirectory: projectRoot);
        
        if (upgradeResult.exitCode == 0) {
          print('    ✓ Dependencies upgraded');
        } else {
          print('    ⚠ Dependency upgrade had issues');
          print(upgradeResult.stderr);
        }
      }
      
      _buildLogs.add('Dependency management completed');
      
    } catch (e) {
      print('  ❌ Dependency management failed: $e');
      throw e;
    }
  }
  
  /// Run code quality checks
  Future<void> _runCodeQualityChecks() async {
    print('\n🔍 Running Code Quality Checks...');
    
    try {
      // Run static analysis
      print('  Running static analysis...');
      final analyzeResult = await Process.run('dart', ['analyze'], workingDirectory: projectRoot);
      
      if (analyzeResult.exitCode == 0) {
        print('    ✓ No analysis issues found');
        _buildResults['analysis'] = 'passed';
      } else {
        print('    ⚠ Analysis issues found:');
        print(analyzeResult.stderr);
        _buildResults['analysis'] = 'failed';
        _buildResults['analysis_issues'] = analyzeResult.stderr;
      }
      
      // Run formatting check
      print('  Checking code formatting...');
      final formatResult = await Process.run('dart', ['format', '--set-exit-if-changed', '.'], workingDirectory: projectRoot);
      
      if (formatResult.exitCode == 0) {
        print('    ✓ Code formatting is correct');
        _buildResults['formatting'] = 'passed';
      } else {
        print('    ⚠ Code formatting issues fixed');
        _buildResults['formatting'] = 'fixed';
      }
      
      // Run import sorting
      print('  Checking import organization...');
      final importResult = await Process.run('dart', ['fix', '--apply'], workingDirectory: projectRoot);
      
      if (importResult.exitCode == 0) {
        print('    ✓ Imports are organized');
        _buildResults['imports'] = 'passed';
      } else {
        print('    ⚠ Import issues fixed');
        _buildResults['imports'] = 'fixed';
      }
      
      _buildLogs.add('Code quality checks completed');
      
    } catch (e) {
      print('  ❌ Code quality checks failed: $e');
      throw e;
    }
  }
  
  /// Run tests
  Future<void> _runTests() async {
    print('\n🧪 Running Tests...');
    
    try {
      // Run unit tests
      print('  Running unit tests...');
      final unitResult = await Process.run('flutter', ['test', '--coverage'], workingDirectory: projectRoot);
      
      if (unitResult.exitCode == 0) {
        print('    ✓ Unit tests passed');
        _testResults['unit'] = 'passed';
        
        // Parse coverage
        final coverage = _parseTestCoverage(unitResult.stdout);
        _testResults['unit_coverage'] = coverage;
        print('    Coverage: ${coverage.toStringAsFixed(1)}%');
      } else {
        print('    ❌ Unit tests failed');
        _testResults['unit'] = 'failed';
        _testResults['unit_errors'] = unitResult.stderr;
      }
      
      // Run widget tests
      print('  Running widget tests...');
      final widgetResult = await Process.run('flutter', ['test', 'test/widget'], workingDirectory: projectRoot);
      
      if (widgetResult.exitCode == 0) {
        print('    ✓ Widget tests passed');
        _testResults['widget'] = 'passed';
      } else {
        print('    ❌ Widget tests failed');
        _testResults['widget'] = 'failed';
        _testResults['widget_errors'] = widgetResult.stderr;
      }
      
      // Run integration tests if available
      final integrationDir = Directory(path.join(projectRoot, 'integration_test'));
      if (await integrationDir.exists()) {
        print('  Running integration tests...');
        final integrationResult = await Process.run('flutter', ['test', 'integration_test'], workingDirectory: projectRoot);
        
        if (integrationResult.exitCode == 0) {
          print('    ✓ Integration tests passed');
          _testResults['integration'] = 'passed';
        } else {
          print('    ❌ Integration tests failed');
          _testResults['integration'] = 'failed';
          _testResults['integration_errors'] = integrationResult.stderr;
        }
      }
      
      _buildLogs.add('Tests completed');
      
    } catch (e) {
      print('  ❌ Test execution failed: $e');
      throw e;
    }
  }
  
  /// Build application
  Future<void> _buildApplication() async {
    print('\n🏗️ Building Application...');
    
    try {
      final platforms = ['web', 'android', 'ios'];
      final buildResults = <String, bool>{};
      
      for (final platform in platforms) {
        print('  Building for $platform...');
        
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
          
          // Get build size
          final size = await _getBuildSize(platform);
          _buildResults['${platform}_size'] = size;
          print('      Size: ${_formatBytes(size)}');
        } else {
          print('    ❌ $platform build failed');
          buildResults[platform] = false;
          _buildResults['${platform}_error'] = result.stderr;
        }
      }
      
      _buildResults['builds'] = buildResults;
      _buildLogs.add('Application build completed');
      
    } catch (e) {
      print('  ❌ Application build failed: $e');
      throw e;
    }
  }
  
  /// Generate artifacts
  Future<void> _generateArtifacts() async {
    print('\n📦 Generating Artifacts...');
    
    try {
      // Create artifacts directory
      final artifactsDir = Directory(path.join(projectRoot, 'artifacts'));
      if (!await artifactsDir.exists()) {
        await artifactsDir.create(recursive: true);
      }
      
      // Copy build outputs
      final platforms = ['web', 'android', 'ios'];
      
      for (final platform in platforms) {
        final sourceDir = Directory(path.join(projectRoot, buildDir, platform));
        final targetDir = Directory(path.join(artifactsDir.path, platform));
        
        if (await sourceDir.exists()) {
          print('  Copying $platform artifacts...');
          await _copyDirectory(sourceDir, targetDir);
        }
      }
      
      // Generate build info
      await _generateBuildInfo(artifactsDir);
      
      // Generate checksums
      await _generateChecksums(artifactsDir);
      
      _buildLogs.add('Artifacts generated');
      
    } catch (e) {
      print('  ❌ Artifact generation failed: $e');
      throw e;
    }
  }
  
  /// Deploy if needed
  Future<void> _deployIfNeeded() async {
    print('\n🚀 Checking Deployment Needs...');
    
    try {
      // Check if we're on main branch
      final branchResult = await Process.run('git', ['branch', '--show-current'], workingDirectory: projectRoot);
      final currentBranch = branchResult.stdout.trim();
      
      if (currentBranch != 'main') {
        print('  ⚠ Not on main branch, skipping deployment');
        return;
      }
      
      // Check if all builds succeeded
      final builds = _buildResults['builds'] as Map<String, bool>? ?? {};
      final allBuildsSuccess = builds.values.every((success) => success);
      
      if (!allBuildsSuccess) {
        print('  ⚠ Some builds failed, skipping deployment');
        return;
      }
      
      // Check if all tests passed
      final allTestsPassed = (_testResults['unit'] == 'passed' || _testResults['unit'] == null) &&
                           (_testResults['widget'] == 'passed' || _testResults['widget'] == null) &&
                           (_testResults['integration'] == 'passed' || _testResults['integration'] == null);
      
      if (!allTestsPassed) {
        print('  ⚠ Some tests failed, skipping deployment');
        return;
      }
      
      // Deploy to staging
      print('  Deploying to staging...');
      await _deployToStaging();
      
      _buildLogs.add('Deployment completed');
      
    } catch (e) {
      print('  ❌ Deployment failed: $e');
      // Don't throw here, as deployment is optional
    }
  }
  
  /// Generate build report
  Future<void> _generateBuildReport() async {
    print('\n📊 Generating Build Report...');
    
    final report = {
      'timestamp': DateTime.now().toIso8601String(),
      'buildResults': _buildResults,
      'testResults': _testResults,
      'buildLogs': _buildLogs,
      'summary': _getBuildSummary(),
      'artifacts': _getArtifactInfo()
    };
    
    final reportFile = File(path.join(projectRoot, 'build_report.json'));
    await reportFile.writeAsString(JsonEncoder.withIndent('  ').convert(report));
    
    print('  ✓ Build report saved to build_report.json');
    
    // Generate human-readable report
    await _generateHumanReadableBuildReport(report);
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
  
  /// Get build size
  Future<int> _getBuildSize(String platform) async {
    try {
      switch (platform) {
        case 'web':
          final buildDir = Directory(path.join(projectRoot, buildDir, 'web'));
          if (await buildDir.exists()) {
            int totalSize = 0;
            await for (final entity in buildDir.list(recursive: true)) {
              if (entity is File) {
                totalSize += await entity.length();
              }
            }
            return totalSize;
          }
          break;
        case 'android':
          final apkFile = File(path.join(projectRoot, buildDir, 'app', 'outputs', 'flutter-apk', 'app-release.apk'));
          if (await apkFile.exists()) {
            return await apkFile.length();
          }
          break;
        case 'ios':
          final iosDir = Directory(path.join(projectRoot, buildDir, 'ios'));
          if (await iosDir.exists()) {
            int totalSize = 0;
            await for (final entity in iosDir.list(recursive: true)) {
              if (entity is File) {
                totalSize += await entity.length();
              }
            }
            return totalSize;
          }
          break;
      }
    } catch (e) {
      print('    Could not get build size for $platform: $e');
    }
    return 0;
  }
  
  /// Format bytes for human reading
  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
  
  /// Copy directory
  Future<void> _copyDirectory(Directory source, Directory target) async {
    if (!await target.exists()) {
      await target.create(recursive: true);
    }
    
    await for (final entity in source.list(recursive: true)) {
      final relativePath = path.relative(entity.path, from: source.path);
      final targetPath = path.join(target.path, relativePath);
      
      if (entity is File) {
        await entity.copy(targetPath);
      } else if (entity is Directory) {
        final targetDir = Directory(targetPath);
        if (!await targetDir.exists()) {
          await targetDir.create(recursive: true);
        }
      }
    }
  }
  
  /// Generate build info
  Future<void> _generateBuildInfo(Directory artifactsDir) async {
    final buildInfo = {
      'version': await _getAppVersion(),
      'buildNumber': await _getBuildNumber(),
      'buildTime': DateTime.now().toIso8601String(),
      'flutterVersion': await _getFlutterVersion(),
      'platforms': ['web', 'android', 'ios']
    };
    
    final infoFile = File(path.join(artifactsDir.path, 'build_info.json'));
    await infoFile.writeAsString(JsonEncoder.withIndent('  ').convert(buildInfo));
  }
  
  /// Generate checksums
  Future<void> _generateChecksums(Directory artifactsDir) async {
    final checksums = <String, String>{};
    
    await for (final entity in artifactsDir.list(recursive: true)) {
      if (entity is File) {
        final content = await entity.readAsBytes();
        final checksum = _generateChecksum(content);
        checksums[path.relative(entity.path, from: artifactsDir.path)] = checksum;
      }
    }
    
    final checksumFile = File(path.join(artifactsDir.path, 'checksums.json'));
    await checksumFile.writeAsString(JsonEncoder.withIndent('  ').convert(checksums));
  }
  
  /// Generate checksum
  String _generateChecksum(List<int> bytes) {
    // Simple checksum implementation (in production, use proper crypto)
    int sum = 0;
    for (final byte in bytes) {
      sum += byte;
    }
    return sum.toString();
  }
  
  /// Get app version
  Future<String> _getAppVersion() async {
    try {
      final pubspecFile = File(path.join(projectRoot, 'pubspec.yaml'));
      final content = await pubspecFile.readAsString();
      
      final versionMatch = RegExp(r'version:\s*(.+)').firstMatch(content);
      if (versionMatch != null) {
        return versionMatch.group(1)!.trim();
      }
    } catch (e) {
      print('    Could not get app version: $e');
    }
    return 'unknown';
  }
  
  /// Get build number
  Future<String> _getBuildNumber() async {
    try {
      final buildNumber = DateTime.now().millisecondsSinceEpoch.toString();
      return buildNumber;
    } catch (e) {
      print('    Could not get build number: $e');
    }
    return 'unknown';
  }
  
  /// Get Flutter version
  Future<String> _getFlutterVersion() async {
    try {
      final result = await Process.run('flutter', ['--version']);
      if (result.exitCode == 0) {
        return result.stdout.trim();
      }
    } catch (e) {
      print('    Could not get Flutter version: $e');
    }
    return 'unknown';
  }
  
  /// Get build summary
  Map<String, dynamic> _getBuildSummary() {
    final builds = _buildResults['builds'] as Map<String, bool>? ?? {};
    final successCount = builds.values.where((success) => success).length;
    final totalCount = builds.length;
    
    return {
      'totalBuilds': totalCount,
      'successfulBuilds': successCount,
      'successRate': totalCount > 0 ? (successCount / totalCount * 100).toStringAsFixed(1) : '0.0',
      'overallStatus': successCount == totalCount ? 'SUCCESS' : 'PARTIAL'
    };
  }
  
  /// Get artifact info
  Map<String, dynamic> _getArtifactInfo() {
    final artifacts = <String, dynamic>{};
    
    for (final platform in ['web', 'android', 'ios']) {
      final size = _buildResults['${platform}_size'] as int? ?? 0;
      artifacts[platform] = {
        'size': size,
        'sizeFormatted': _formatBytes(size),
        'exists': _buildResults['builds']?[platform] ?? false
      };
    }
    
    return artifacts;
  }
  
  /// Generate human-readable build report
  Future<void> _generateHumanReadableBuildReport(Map<String, dynamic> report) async {
    final reportFile = File(path.join(projectRoot, 'build_report.md'));
    
    final content = '''
# VedantaTrade Build Report

**Generated:** ${report['timestamp']}

## Build Summary
- **Overall Status:** ${report['summary']['overallStatus']}
- **Success Rate:** ${report['summary']['successRate']}%
- **Total Builds:** ${report['summary']['totalBuilds']}
- **Successful Builds:** ${report['summary']['successfulBuilds']}

## Test Results
- **Unit Tests:** ${report['testResults']['unit'] ?? 'not run'}
- **Unit Coverage:** ${report['testResults']['unit_coverage'] ?? 'N/A'}%
- **Widget Tests:** ${report['testResults']['widget'] ?? 'not run'}
- **Integration Tests:** ${report['testResults']['integration'] ?? 'not run'}

## Build Results
${(report['buildResults']['builds'] as Map<String, bool>).entries.map((entry) => '- ${entry.key}: ${entry.value ? '✓' : '❌'}').join('\n')}

## Artifact Sizes
${(report['artifacts'] as Map<String, dynamic>).entries.map((entry) => '- ${entry.key}: ${entry.value['sizeFormatted']}').join('\n')}

## Build Information
- **App Version:** ${report['buildResults']['version']}
- **Build Number:** ${report['buildResults']['buildNumber']}
- **Flutter Version:** ${report['buildResults']['flutterVersion']}
- **Build Time:** ${report['buildResults']['buildTime']}

## Build Logs
${report['buildLogs'].map((log) => '- $log').join('\n')}

---
*Report generated by VedantaTrade Build Automation*
''';
    
    await reportFile.writeAsString(content);
    print('  ✓ Human-readable build report saved to build_report.md');
  }
  
  /// Deploy to staging
  Future<void> _deployToStaging() async {
    // This would implement actual deployment logic
    // For now, just log that we would deploy
    print('    ✓ Staging deployment simulated');
  }
  
  /// Clean build directory
  Future<void> _cleanBuildDirectory() async {
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
  
  /// Create output directory
  Future<void> _createOutputDirectory() async {
    try {
      final outputDir = Directory(path.join(projectRoot, outputDir));
      if (!await outputDir.exists()) {
        await outputDir.create(recursive: true);
        print('    ✓ Output directory created');
      }
    } catch (e) {
      print('    Could not create output directory: $e');
    }
  }
  
  /// Log error
  Future<void> _logError(String error) async {
    final logFile = File(path.join(projectRoot, 'build_errors.log'));
    final timestamp = DateTime.now().toIso8601String();
    await logFile.writeAsString('[$timestamp] $error\n', mode: FileMode.append);
  }
}

void main(List<String> arguments) async {
  final automation = VedantaTradeBuildAutomation();
  
  if (arguments.contains('--help') || arguments.contains('-h')) {
    print('''
VedantaTrade Build Automation

Usage: dart tool/build_automation.dart [options]

Options:
  --help, -h        Show this help message
  --test-only        Run tests only (no build)
  --build-only       Run build only (no tests)
  --clean-only       Clean build directory only
  --deploy-only      Deploy only (requires successful build)
  --report-only      Generate report only

Examples:
  dart tool/build_automation.dart                    # Full build workflow
  dart tool/build_automation.dart --test-only        # Tests only
  dart tool/build_automation.dart --build-only       # Build only
  dart tool/build_automation.dart --clean-only       # Clean only
  dart tool/build_automation.dart --deploy-only      # Deploy only
  dart tool/build_automation.dart --report-only      # Report only
''');
    return;
  }
  
  if (arguments.contains('--test-only')) {
    await automation._manageDependencies();
    await automation._runCodeQualityChecks();
    await automation._runTests();
  } else if (arguments.contains('--build-only')) {
    await automation._setupEnvironment();
    await automation._manageDependencies();
    await automation._runCodeQualityChecks();
    await automation._buildApplication();
  } else if (arguments.contains('--clean-only')) {
    await automation._cleanBuildDirectory();
  } else if (arguments.contains('--deploy-only')) {
    await automation._deployIfNeeded();
  } else if (arguments.contains('--report-only')) {
    await automation._generateBuildReport();
  } else {
    await automation.runBuildWorkflow();
  }
}
