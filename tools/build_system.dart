import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:process_run/process_run.dart';

/// Automated build system for Flutter app
class BuildSystem {
  final String projectPath;
  final bool verbose;
  
  BuildSystem(this.projectPath, {this.verbose = false});

  /// Run complete build process
  Future<BuildResult> buildApp({BuildTarget target = BuildTarget.all}) async {
    final result = BuildResult();
    
    if (verbose) print('🔨 Starting build process...');
    
    // 1. Clean previous builds
    result.cleanResult = await _cleanBuild();
    
    // 2. Get dependencies
    result.depsResult = await _getDependencies();
    
    // 3. Run tests
    result.testResult = await _runTests();
    
    // 4. Build based on target
    switch (target) {
      case BuildTarget.apk:
        result.apkResult = await _buildAPK();
        break;
      case BuildTarget.aab:
        result.aabResult = await _buildAAB();
        break;
      case BuildTarget.web:
        result.webResult = await _buildWeb();
        break;
      case BuildTarget.ios:
        result.iosResult = await _buildIOS();
        break;
      case BuildTarget.all:
        result.apkResult = await _buildAPK();
        result.aabResult = await _buildAAB();
        result.webResult = await _buildWeb();
        result.iosResult = await _buildIOS();
        break;
    }
    
    // 5. Generate build report
    result.buildReport = await _generateBuildReport(result);
    
    return result;
  }

  /// Clean previous builds
  Future<CleanResult> _cleanBuild() async {
    final result = CleanResult();
    
    try {
      // Clean Flutter build
      final flutterClean = await Process.run('flutter', ['clean'], 
        workingDirectory: projectPath);
      result.flutterCleanSuccess = flutterClean.exitCode == 0;
      
      // Clean build directories
      final buildDir = Directory('$projectPath/build');
      if (await buildDir.exists()) {
        await buildDir.delete(recursive: true);
        result.buildDirCleaned = true;
      }
      
      // Clean web build
      final webBuildDir = Directory('$projectPath/build/web');
      if (await webBuildDir.exists()) {
        await webBuildDir.delete(recursive: true);
        result.webBuildCleaned = true;
      }
      
    } catch (e) {
      result.error = e.toString();
      if (verbose) print('❌ Clean failed: $e');
    }
    
    return result;
  }

  /// Get dependencies
  Future<DepsResult> _getDependencies() async {
    final result = DepsResult();
    
    try {
      // Flutter pub get
      final flutterPubGet = await Process.run('flutter', ['pub', 'get'], 
        workingDirectory: projectPath);
      result.flutterPubGetSuccess = flutterPubGet.exitCode == 0;
      
      if (!result.flutterPubGetSuccess) {
        result.flutterError = flutterPubGet.stderr as String;
      }
      
      // Backend dependencies (if exists)
      final backendDir = Directory('$projectPath/backend');
      if (await backendDir.exists()) {
        final npmInstall = await Process.run('npm', ['install'], 
          workingDirectory: '$projectPath/backend');
        result.npmInstallSuccess = npmInstall.exitCode == 0;
        
        if (!result.npmInstallSuccess) {
          result.npmError = npmInstall.stderr as String;
        }
      }
      
    } catch (e) {
      result.error = e.toString();
      if (verbose) print('❌ Dependencies failed: $e');
    }
    
    return result;
  }

  /// Run tests
  Future<TestResult> _runTests() async {
    final result = TestResult();
    
    try {
      // Flutter tests
      final flutterTest = await Process.run('flutter', ['test', '--coverage'], 
        workingDirectory: projectPath);
      result.flutterTestSuccess = flutterTest.exitCode == 0;
      result.flutterTestOutput = flutterTest.stdout as String;
      
      if (!result.flutterTestSuccess) {
        result.flutterTestError = flutterTest.stderr as String;
      }
      
      // Backend tests (if exists)
      final backendDir = Directory('$projectPath/backend');
      if (await backendDir.exists()) {
        final npmTest = await Process.run('npm', ['test'], 
          workingDirectory: '$projectPath/backend');
        result.backendTestSuccess = npmTest.exitCode == 0;
        result.backendTestOutput = npmTest.stdout as String;
        
        if (!result.backendTestSuccess) {
          result.backendTestError = npmTest.stderr as String;
        }
      }
      
    } catch (e) {
      result.error = e.toString();
      if (verbose) print('❌ Tests failed: $e');
    }
    
    return result;
  }

  /// Build APK
  Future<BuildTargetResult> _buildAPK() async {
    final result = BuildTargetResult(target: 'APK');
    
    try {
      final process = await Process.run('flutter', [
        'build', 'apk', 
        '--release',
        '--split-per-abi',
        '--no-pub'
      ], workingDirectory: projectPath);
      
      result.success = process.exitCode == 0;
      result.output = process.stdout as String;
      
      if (!result.success) {
        result.error = process.stderr as String;
      } else {
        // Find APK files
        final buildDir = Directory('$projectPath/build/app/outputs/flutter-apk');
        if (await buildDir.exists()) {
          final files = await buildDir.list().toList();
          result.artifacts = files
              .where((f) => f.path.endsWith('.apk'))
              .map((f) => f.path)
              .toList();
        }
      }
      
    } catch (e) {
      result.error = e.toString();
      if (verbose) print('❌ APK build failed: $e');
    }
    
    return result;
  }

  /// Build AAB
  Future<BuildTargetResult> _buildAAB() async {
    final result = BuildTargetResult(target: 'AAB');
    
    try {
      final process = await Process.run('flutter', [
        'build', 'appbundle', 
        '--release',
        '--no-pub'
      ], workingDirectory: projectPath);
      
      result.success = process.exitCode == 0;
      result.output = process.stdout as String;
      
      if (!result.success) {
        result.error = process.stderr as String;
      } else {
        // Find AAB file
        final buildDir = Directory('$projectPath/build/app/outputs/bundle/release');
        if (await buildDir.exists()) {
          final files = await buildDir.list().toList();
          result.artifacts = files
              .where((f) => f.path.endsWith('.aab'))
              .map((f) => f.path)
              .toList();
        }
      }
      
    } catch (e) {
      result.error = e.toString();
      if (verbose) print('❌ AAB build failed: $e');
    }
    
    return result;
  }

  /// Build Web
  Future<BuildTargetResult> _buildWeb() async {
    final result = BuildTargetResult(target: 'Web');
    
    try {
      final process = await Process.run('flutter', [
        'build', 'web', 
        '--release',
        '--no-pub',
        '--web-renderer', 'canvaskit'
      ], workingDirectory: projectPath);
      
      result.success = process.exitCode == 0;
      result.output = process.stdout as String;
      
      if (!result.success) {
        result.error = process.stderr as String;
      } else {
        result.artifacts = ['$projectPath/build/web'];
      }
      
    } catch (e) {
      result.error = e.toString();
      if (verbose) print('❌ Web build failed: $e');
    }
    
    return result;
  }

  /// Build iOS
  Future<BuildTargetResult> _buildIOS() async {
    final result = BuildTargetResult(target: 'iOS');
    
    try {
      final process = await Process.run('flutter', [
        'build', 'ios', 
        '--release',
        '--no-pub',
        '--no-codesign'
      ], workingDirectory: projectPath);
      
      result.success = process.exitCode == 0;
      result.output = process.stdout as String;
      
      if (!result.success) {
        result.error = process.stderr as String;
      } else {
        result.artifacts = ['$projectPath/build/ios/iphoneos/Runner.app'];
      }
      
    } catch (e) {
      result.error = e.toString();
      if (verbose) print('❌ iOS build failed: $e');
    }
    
    return result;
  }

  /// Generate build report
  Future<String> _generateBuildReport(BuildResult result) async {
    final report = StringBuffer();
    
    report.writeln('# Build Report');
    report.writeln('Generated: ${DateTime.now().toIso8601String()}');
    report.writeln('');
    
    // Clean results
    report.writeln('## Clean Results');
    report.writeln('- Flutter Clean: ${result.cleanResult?.flutterCleanSuccess ?? false}');
    report.writeln('- Build Directory Cleaned: ${result.cleanResult?.buildDirCleaned ?? false}');
    report.writeln('- Web Build Cleaned: ${result.cleanResult?.webBuildCleaned ?? false}');
    report.writeln('');
    
    // Dependencies
    report.writeln('## Dependencies');
    report.writeln('- Flutter Pub Get: ${result.depsResult?.flutterPubGetSuccess ?? false}');
    report.writeln('- NPM Install: ${result.depsResult?.npmInstallSuccess ?? false}');
    report.writeln('');
    
    // Tests
    report.writeln('## Test Results');
    report.writeln('- Flutter Tests: ${result.testResult?.flutterTestSuccess ?? false}');
    report.writeln('- Backend Tests: ${result.testResult?.backendTestSuccess ?? false}');
    report.writeln('');
    
    // Build results
    report.writeln('## Build Results');
    if (result.apkResult != null) {
      report.writeln('- APK: ${result.apkResult!.success}');
      if (result.apkResult!.artifacts.isNotEmpty) {
        report.writeln('  - Artifacts: ${result.apkResult!.artifacts.length}');
      }
    }
    
    if (result.aabResult != null) {
      report.writeln('- AAB: ${result.aabResult!.success}');
      if (result.aabResult!.artifacts.isNotEmpty) {
        report.writeln('  - Artifacts: ${result.aabResult!.artifacts.length}');
      }
    }
    
    if (result.webResult != null) {
      report.writeln('- Web: ${result.webResult!.success}');
      if (result.webResult!.artifacts.isNotEmpty) {
        report.writeln('  - Artifacts: ${result.webResult!.artifacts.length}');
      }
    }
    
    if (result.iosResult != null) {
      report.writeln('- iOS: ${result.iosResult!.success}');
      if (result.iosResult!.artifacts.isNotEmpty) {
        report.writeln('  - Artifacts: ${result.iosResult!.artifacts.length}');
      }
    }
    
    // Save report
    final reportFile = File('$projectPath/build_report.md');
    await reportFile.writeAsString(report.toString());
    
    return report.toString();
  }

  /// Get build statistics
  Future<BuildStats> getBuildStats() async {
    final stats = BuildStats();
    
    try {
      final buildDir = Directory('$projectPath/build');
      if (await buildDir.exists()) {
        await for (final entity in buildDir.list(recursive: true)) {
          if (entity is File) {
            final size = await entity.length();
            stats.totalBuildSize += size;
            
            if (entity.path.endsWith('.apk')) {
              stats.apkSize += size;
              stats.apkCount++;
            } else if (entity.path.endsWith('.aab')) {
              stats.aabSize += size;
              stats.aabCount++;
            }
          }
        }
      }
    } catch (e) {
      if (verbose) print('❌ Build stats failed: $e');
    }
    
    return stats;
  }
}

/// Build target enum
enum BuildTarget {
  apk,
  aab,
  web,
  ios,
  all,
}

/// Build result container
class BuildResult {
  CleanResult? cleanResult;
  DepsResult? depsResult;
  TestResult? testResult;
  BuildTargetResult? apkResult;
  BuildTargetResult? aabResult;
  BuildTargetResult? webResult;
  BuildTargetResult? iosResult;
  String? buildReport;
  
  bool get overallSuccess => 
      (cleanResult?.flutterCleanSuccess ?? false) &&
      (depsResult?.flutterPubGetSuccess ?? true) &&
      (testResult?.flutterTestSuccess ?? true) &&
      (apkResult?.success ?? true) &&
      (aabResult?.success ?? true) &&
      (webResult?.success ?? true) &&
      (iosResult?.success ?? true);
}

/// Clean result model
class CleanResult {
  bool flutterCleanSuccess = false;
  bool buildDirCleaned = false;
  bool webBuildCleaned = false;
  String? error;
}

/// Dependencies result model
class DepsResult {
  bool flutterPubGetSuccess = false;
  bool npmInstallSuccess = false;
  String? flutterError;
  String? npmError;
  String? error;
}

/// Test result model
class TestResult {
  bool flutterTestSuccess = false;
  bool backendTestSuccess = false;
  String? flutterTestOutput;
  String? flutterTestError;
  String? backendTestOutput;
  String? backendTestError;
  String? error;
}

/// Build target result model
class BuildTargetResult {
  final String target;
  bool success = false;
  String? output;
  String? error;
  List<String> artifacts = [];
  
  BuildTargetResult({required this.target});
}

/// Build statistics model
class BuildStats {
  int totalBuildSize = 0;
  int apkSize = 0;
  int aabSize = 0;
  int apkCount = 0;
  int aabCount = 0;
  
  String get formattedTotalSize => _formatBytes(totalBuildSize);
  String get formattedApkSize => _formatBytes(apkSize);
  String get formattedAabSize => _formatBytes(aabSize);
  
  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
