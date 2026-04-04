import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:path/path.dart' as path;

/// Automated Build and Test System for VedantaTrade
class VedantaTradeBuildSystem {
  static const String _projectRoot = 'i:/Path/Projects/VedantaTrade';
  static const String _buildDir = 'build';
  static const String _testDir = 'test';
  static const String _coverageDir = 'coverage';
  
  final Map<String, dynamic> _buildResults = {};
  final List<String> _buildSteps = [];
  final List<String> _testResults = [];
  
  /// Main entry point for automated build and test
  Future<void> buildAndTest() async {
    print('🚀 Starting automated build and test system...');
    
    try {
      // 1. Prepare environment
      await _prepareEnvironment();
      
      // 2. Clean previous builds
      await _cleanPreviousBuilds();
      
      // 3. Analyze dependencies
      await _analyzeDependencies();
      
      // 4. Run unit tests
      await _runUnitTests();
      
      // 5. Run widget tests
      await _runWidgetTests();
      
      // 6. Run integration tests
      await _runIntegrationTests();
      
      // 7. Build for different platforms
      await _buildForPlatforms();
      
      // 8. Generate coverage report
      await _generateCoverageReport();
      
      // 9. Performance testing
      await _runPerformanceTests();
      
      // 10. Generate build report
      await _generateBuildReport();
      
      print('✅ Build and test system completed successfully!');
      
    } catch (e) {
      print('❌ Build system error: $e');
      await _logBuildError(e);
      rethrow;
    }
  }
  
  /// Prepare build environment
  Future<void> _prepareEnvironment() async {
    print('🔧 Preparing build environment...');
    
    // Check Flutter installation
    final flutterVersion = await Process.run('flutter', ['--version']);
    if (flutterVersion.exitCode != 0) {
      throw Exception('Flutter not installed or not in PATH');
    }
    
    // Check Dart installation
    final dartVersion = await Process.run('dart', ['--version']);
    if (dartVersion.exitCode != 0) {
      throw Exception('Dart not installed or not in PATH');
    }
    
    // Create necessary directories
    await _createBuildDirectories();
    
    // Verify project structure
    await _verifyProjectStructure();
    
    _buildSteps.add('Environment prepared successfully');
  }
  
  /// Create build directories
  Future<void> _createBuildDirectories() async {
    final directories = [
      _buildDir,
      _testDir,
      _coverageDir,
      'build/web',
      'build/android',
      'build/ios',
      'build/windows',
      'build/linux',
      'build/macos',
    ];
    
    for (final dir in directories) {
      final dirPath = path.join(_projectRoot, dir);
      await Directory(dirPath).create(recursive: true);
    }
  }
  
  /// Verify project structure
  Future<void> _verifyProjectStructure() async {
    final requiredFiles = [
      'pubspec.yaml',
      'lib/main.dart',
      'test/widget_test.dart',
    ];
    
    for (final file in requiredFiles) {
      final filePath = path.join(_projectRoot, file);
      if (!await File(filePath).exists()) {
        throw Exception('Required file missing: $file');
      }
    }
  }
  
  /// Clean previous builds
  Future<void> _cleanPreviousBuilds() async {
    print('🧹 Cleaning previous builds...');
    
    // Run flutter clean
    final cleanResult = await Process.run('flutter', ['clean'], 
        workingDirectory: _projectRoot);
    
    if (cleanResult.exitCode != 0) {
      throw Exception('Flutter clean failed: ${cleanResult.stderr}');
    }
    
    // Clean build directories
    final buildDir = Directory(path.join(_projectRoot, _buildDir));
    if (await buildDir.exists()) {
      await buildDir.delete(recursive: true);
    }
    
    _buildSteps.add('Previous builds cleaned');
  }
  
  /// Analyze dependencies
  Future<void> _analyzeDependencies() async {
    print('📦 Analyzing dependencies...');
    
    // Get dependencies
    final pubGetResult = await Process.run('flutter', ['pub', 'get'], 
        workingDirectory: _projectRoot);
    
    if (pubGetResult.exitCode != 0) {
      throw Exception('Flutter pub get failed: ${pubGetResult.stderr}');
    }
    
    // Check for outdated packages
    final outdatedResult = await Process.run('flutter', ['pub', 'outdated'], 
        workingDirectory: _projectRoot);
    
    _buildResults['dependencies_updated'] = pubGetResult.exitCode == 0;
    _buildResults['outdated_packages'] = outdatedResult.exitCode != 0;
    
    _buildSteps.add('Dependencies analyzed and updated');
  }
  
  /// Run unit tests
  Future<void> _runUnitTests() async {
    print('🧪 Running unit tests...');
    
    final testResult = await Process.run('flutter', ['test', '--coverage'], 
        workingDirectory: _projectRoot);
    
    final output = testResult.stdout as String;
    final lines = output.split('\n');
    
    int passedTests = 0;
    int failedTests = 0;
    
    for (final line in lines) {
      if (line.contains('passed')) {
        passedTests++;
      } else if (line.contains('failed')) {
        failedTests++;
      }
    }
    
    _buildResults['unit_tests'] = {
      'passed': passedTests,
      'failed': failedTests,
      'success': testResult.exitCode == 0,
    };
    
    if (testResult.exitCode == 0) {
      _testResults.add('Unit tests passed: $passedTests');
    } else {
      _testResults.add('Unit tests failed: $failedTests');
    }
    
    _buildSteps.add('Unit tests completed');
  }
  
  /// Run widget tests
  Future<void> _runWidgetTests() async {
    print('🎨 Running widget tests...');
    
    final testResult = await Process.run('flutter', ['test', 'test/widget/'], 
        workingDirectory: _projectRoot);
    
    final output = testResult.stdout as String;
    final lines = output.split('\n');
    
    int passedTests = 0;
    int failedTests = 0;
    
    for (final line in lines) {
      if (line.contains('passed')) {
        passedTests++;
      } else if (line.contains('failed')) {
        failedTests++;
      }
    }
    
    _buildResults['widget_tests'] = {
      'passed': passedTests,
      'failed': failedTests,
      'success': testResult.exitCode == 0,
    };
    
    if (testResult.exitCode == 0) {
      _testResults.add('Widget tests passed: $passedTests');
    } else {
      _testResults.add('Widget tests failed: $failedTests');
    }
    
    _buildSteps.add('Widget tests completed');
  }
  
  /// Run integration tests
  Future<void> _runIntegrationTests() async {
    print('🔗 Running integration tests...');
    
    final testResult = await Process.run('flutter', ['test', 'integration_test/'], 
        workingDirectory: _projectRoot);
    
    final output = testResult.stdout as String;
    final lines = output.split('\n');
    
    int passedTests = 0;
    int failedTests = 0;
    
    for (final line in lines) {
      if (line.contains('passed')) {
        passedTests++;
      } else if (line.contains('failed')) {
        failedTests++;
      }
    }
    
    _buildResults['integration_tests'] = {
      'passed': passedTests,
      'failed': failedTests,
      'success': testResult.exitCode == 0,
    };
    
    if (testResult.exitCode == 0) {
      _testResults.add('Integration tests passed: $passedTests');
    } else {
      _testResults.add('Integration tests failed: $failedTests');
    }
    
    _buildSteps.add('Integration tests completed');
  }
  
  /// Build for different platforms
  Future<void> _buildForPlatforms() async {
    print('🏗️ Building for different platforms...');
    
    // Build for web
    await _buildForWeb();
    
    // Build for Android
    await _buildForAndroid();
    
    // Build for Windows
    await _buildForWindows();
    
    // Build for Linux
    await _buildForLinux();
    
    _buildSteps.add('Multi-platform builds completed');
  }
  
  /// Build for web
  Future<void> _buildForWeb() async {
    print('🌐 Building for web...');
    
    final buildResult = await Process.run('flutter', [
      'build', 'web', 
      '--no-tree-shake-icons',
      '--web-renderer', 'canvaskit'
    ], workingDirectory: _projectRoot);
    
    _buildResults['web_build'] = {
      'success': buildResult.exitCode == 0,
      'output_size': await _getBuildSize('build/web'),
    };
    
    if (buildResult.exitCode == 0) {
      _testResults.add('Web build successful');
    } else {
      _testResults.add('Web build failed');
    }
  }
  
  /// Build for Android
  Future<void> _buildForAndroid() async {
    print('📱 Building for Android...');
    
    final buildResult = await Process.run('flutter', [
      'build', 'apk', 
      '--release'
    ], workingDirectory: _projectRoot);
    
    _buildResults['android_build'] = {
      'success': buildResult.exitCode == 0,
      'output_size': await _getBuildSize('build/app/outputs/flutter-apk/app-release.apk'),
    };
    
    if (buildResult.exitCode == 0) {
      _testResults.add('Android build successful');
    } else {
      _testResults.add('Android build failed');
    }
  }
  
  /// Build for Windows
  Future<void> _buildForWindows() async {
    print('🪟 Building for Windows...');
    
    final buildResult = await Process.run('flutter', [
      'build', 'windows', 
      '--release'
    ], workingDirectory: _projectRoot);
    
    _buildResults['windows_build'] = {
      'success': buildResult.exitCode == 0,
      'output_size': await _getBuildSize('build/windows/runner/Release'),
    };
    
    if (buildResult.exitCode == 0) {
      _testResults.add('Windows build successful');
    } else {
      _testResults.add('Windows build failed');
    }
  }
  
  /// Build for Linux
  Future<void> _buildForLinux() async {
    print('🐧 Building for Linux...');
    
    final buildResult = await Process.run('flutter', [
      'build', 'linux', 
      '--release'
    ], workingDirectory: _projectRoot);
    
    _buildResults['linux_build'] = {
      'success': buildResult.exitCode == 0,
      'output_size': await _getBuildSize('build/linux/x64/release/bundle'),
    };
    
    if (buildResult.exitCode == 0) {
      _testResults.add('Linux build successful');
    } else {
      _testResults.add('Linux build failed');
    }
  }
  
  /// Get build size
  Future<int> _getBuildSize(String buildPath) async {
    final fullPath = path.join(_projectRoot, buildPath);
    final entity = FileSystemEntity.isDirectorySync(fullPath) 
        ? Directory(fullPath) 
        : File(fullPath);
    
    if (entity is File && await entity.exists()) {
      return await entity.length();
    } else if (entity is Directory && await entity.exists()) {
      int totalSize = 0;
      await for (final file in entity.list(recursive: true)) {
        if (file is File) {
          totalSize += await file.length();
        }
      }
      return totalSize;
    }
    
    return 0;
  }
  
  /// Generate coverage report
  Future<void> _generateCoverageReport() async {
    print('📊 Generating coverage report...');
    
    // Generate coverage from lcov
    final coverageResult = await Process.run('genhtml', [
      'coverage/lcov.info',
      '--output-directory',
      'coverage/html'
    ], workingDirectory: _projectRoot);
    
    _buildResults['coverage_generated'] = coverageResult.exitCode == 0;
    
    // Parse coverage data
    await _parseCoverageData();
    
    _buildSteps.add('Coverage report generated');
  }
  
  /// Parse coverage data
  Future<void> _parseCoverageData() async {
    final coverageFile = File(path.join(_projectRoot, 'coverage/lcov.info'));
    if (!await coverageFile.exists()) return;
    
    final content = await coverageFile.readAsString();
    final lines = content.split('\n');
    
    int totalLines = 0;
    int coveredLines = 0;
    
    for (final line in lines) {
      if (line.startsWith('LF:')) {
        totalLines += int.parse(line.split(':')[1]);
      } else if (line.startsWith('LH:')) {
        coveredLines += int.parse(line.split(':')[1]);
      }
    }
    
    final coveragePercentage = totalLines > 0 
        ? (coveredLines / totalLines * 100).round()
        : 0;
    
    _buildResults['coverage'] = {
      'total_lines': totalLines,
      'covered_lines': coveredLines,
      'percentage': coveragePercentage,
    };
  }
  
  /// Run performance tests
  Future<void> _runPerformanceTests() async {
    print('⚡ Running performance tests...');
    
    // Memory usage test
    await _testMemoryUsage();
    
    // CPU usage test
    await _testCpuUsage();
    
    // Startup time test
    await _testStartupTime();
    
    _buildSteps.add('Performance tests completed');
  }
  
  /// Test memory usage
  Future<void> _testMemoryUsage() async {
    final result = await Process.run('flutter', ['test', 'test/performance/memory_test.dart'], 
        workingDirectory: _projectRoot);
    
    _buildResults['memory_test'] = {
      'success': result.exitCode == 0,
      'memory_usage': result.exitCode == 0 ? 'Optimal' : 'Needs optimization',
    };
  }
  
  /// Test CPU usage
  Future<void> _testCpuUsage() async {
    final result = await Process.run('flutter', ['test', 'test/performance/cpu_test.dart'], 
        workingDirectory: _projectRoot);
    
    _buildResults['cpu_test'] = {
      'success': result.exitCode == 0,
      'cpu_usage': result.exitCode == 0 ? 'Optimal' : 'Needs optimization',
    };
  }
  
  /// Test startup time
  Future<void> _testStartupTime() async {
    final result = await Process.run('flutter', ['test', 'test/performance/startup_test.dart'], 
        workingDirectory: _projectRoot);
    
    _buildResults['startup_test'] = {
      'success': result.exitCode == 0,
      'startup_time': result.exitCode == 0 ? 'Fast' : 'Needs optimization',
    };
  }
  
  /// Generate build report
  Future<void> _generateBuildReport() async {
    print('📄 Generating build report...');
    
    final report = {
      'timestamp': DateTime.now().toIso8601String(),
      'build_steps': _buildSteps,
      'build_results': _buildResults,
      'test_results': _testResults,
      'summary': {
        'total_steps': _buildSteps.length,
        'total_tests': _testResults.length,
        'build_success': _isBuildSuccessful(),
        'test_success': _isTestSuccessful(),
      },
    };
    
    // Save JSON report
    final reportPath = path.join(_projectRoot, 'docs', 'build_report.json');
    final reportFile = File(reportPath);
    await reportFile.writeAsString(jsonEncode(report));
    
    // Generate human-readable report
    await _generateHumanReadableBuildReport();
    
    print('📄 Build report generated');
  }
  
  /// Check if build was successful
  bool _isBuildSuccessful() {
    return _buildResults['web_build']['success'] == true &&
           _buildResults['android_build']['success'] == true &&
           _buildResults['windows_build']['success'] == true &&
           _buildResults['linux_build']['success'] == true;
  }
  
  /// Check if tests were successful
  bool _isTestSuccessful() {
    return _buildResults['unit_tests']['success'] == true &&
           _buildResults['widget_tests']['success'] == true &&
           _buildResults['integration_tests']['success'] == true;
  }
  
  /// Generate human-readable build report
  Future<void> _generateHumanReadableBuildReport() async {
    final reportPath = path.join(_projectRoot, 'docs', 'BUILD_REPORT.md');
    final reportFile = File(reportPath);
    
    final report = '''
# VedantaTrade Build Report

**Generated**: ${DateTime.now().toIso8601String()}

## 📊 Summary

- **Total Build Steps**: ${_buildSteps.length}
- **Total Tests**: ${_testResults.length}
- **Build Success**: ${_isBuildSuccessful() ? '✅' : '❌'}
- **Test Success**: ${_isTestSuccessful() ? '✅' : '❌'}

## 🔧 Build Steps

${_buildSteps.map((step) => '- ✅ $step').join('\n')}

## 🧪 Test Results

${_testResults.map((result) => '- $result').join('\n')}

## 📈 Build Results

### Web Build
- **Success**: ${_buildResults['web_build']['success'] ? '✅' : '❌'}
- **Size**: ${_formatFileSize(_buildResults['web_build']['output_size'])}

### Android Build
- **Success**: ${_buildResults['android_build']['success'] ? '✅' : '❌'}
- **Size**: ${_formatFileSize(_buildResults['android_build']['output_size'])}

### Windows Build
- **Success**: ${_buildResults['windows_build']['success'] ? '✅' : '❌'}
- **Size**: ${_formatFileSize(_buildResults['windows_build']['output_size'])}

### Linux Build
- **Success**: ${_buildResults['linux_build']['success'] ? '✅' : '❌'}
- **Size**: ${_formatFileSize(_buildResults['linux_build']['output_size'])}

## 📊 Coverage Report

- **Total Lines**: ${_buildResults['coverage']['total_lines'] ?? 0}
- **Covered Lines**: ${_buildResults['coverage']['covered_lines'] ?? 0}
- **Coverage Percentage**: ${_buildResults['coverage']['percentage'] ?? 0}%

## ⚡ Performance Tests

- **Memory Usage**: ${_buildResults['memory_test']['memory_usage'] ?? 'N/A'}
- **CPU Usage**: ${_buildResults['cpu_test']['cpu_usage'] ?? 'N/A'}
- **Startup Time**: ${_buildResults['startup_test']['startup_time'] ?? 'N/A'}

---

*This report was generated automatically by the VedantaTrade Build System*
''';
    
    await reportFile.writeAsString(report);
  }
  
  /// Format file size
  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
  
  /// Log build error
  Future<void> _logBuildError(dynamic error) async {
    final logPath = path.join(_projectRoot, 'docs', 'build_error_log.txt');
    final logFile = File(logPath);
    
    final logEntry = '[${DateTime.now().toIso8601String()}] Build Error: $error\n';
    await logFile.writeAsString(logEntry, mode: FileMode.append);
  }
}

/// Main entry point
void main() async {
  final buildSystem = VedantaTradeBuildSystem();
  await buildSystem.buildAndTest();
}
