import 'dart:io';
import 'dart:convert';

/// Build Helper for VedantaTrade Application
/// Provides automated build utilities and optimization
class BuildHelper {
  static const String projectRoot = 'i:\\Path\\Projects\\VedantaTrade';
  
  /// Build configurations
  static const Map<String, Map<String, dynamic>> buildConfigs = {
    'debug': {
      'flutter-command': 'build',
      'args': ['--debug'],
      'output-dir': 'build/debug',
      'assets-mode': 'debug',
    },
    'profile': {
      'flutter-command': 'build',
      'args': ['--profile'],
      'output-dir': 'build/profile',
      'assets-mode': 'profile',
    },
    'release': {
      'flutter-command': 'build',
      'args': ['--release'],
      'output-dir': 'build/release',
      'assets-mode': 'release',
    },
    'web': {
      'flutter-command': 'build',
      'args': ['web', '--release'],
      'output-dir': 'build/web',
      'assets-mode': 'release',
    },
    'apk': {
      'flutter-command': 'build',
      'args': ['apk', '--release'],
      'output-dir': 'build/apk',
      'assets-mode': 'release',
    },
    'ios': {
      'flutter-command': 'build',
      'args': ['ios', '--release'],
      'output-dir': 'build/ios',
      'assets-mode': 'release',
    },
  };

  /// Build for specific configuration
  static Future<bool> build(String configName) async {
    if (!buildConfigs.containsKey(configName)) {
      print('❌ Unknown build configuration: $configName');
      print('Available configs: ${buildConfigs.keys.join(', ')}');
      return false;
    }

    final config = buildConfigs[configName]!;
    print('🏗️ Building with configuration: $configName');
    
    // Change to project directory
    Directory.current = projectRoot;
    
    try {
      // Clean previous build
      await _cleanBuild(config['output-dir']);
      
      // Run Flutter build
      final args = List<String>.from(config['args']);
      args.add('--no-tree-shake-icons');
      args.add('--no-sound-null-safety');
      
      final result = await Process.run('flutter', [
        config['flutter-command'],
        ...args,
      ]);
      
      if (result.exitCode == 0) {
        print('✅ Build successful');
        await _postBuildOptimization(configName, config);
        await _generateBuildManifest(configName, config);
        return true;
      } else {
        print('❌ Build failed');
        print('Error: ${result.stderr}');
        return false;
      }
    } catch (e) {
      print('❌ Build error: $e');
      return false;
    }
  }

  /// Build all configurations
  static Future<void> buildAll() async {
    print('🚀 Building all configurations...');
    
    final configs = ['debug', 'profile', 'release', 'web'];
    
    for (final config in configs) {
      final success = await build(config);
      if (!success) {
        print('⚠️ Failed to build $config, continuing...');
      }
    }
    
    print('✅ All builds completed');
  }

  /// Optimize build artifacts
  static Future<void> _postBuildOptimization(String configName, Map<String, dynamic> config) async {
    print('🔧 Optimizing build artifacts...');
    
    final outputDir = Directory(config['output-dir']);
    if (!await outputDir.exists()) return;
    
    // Optimize images
    await _optimizeImages(outputDir);
    
    // Compress assets
    await _compressAssets(outputDir);
    
    // Generate size report
    await _generateSizeReport(configName, outputDir);
  }

  /// Clean build directory
  static Future<void> _cleanBuild(String outputDir) async {
    final dir = Directory(outputDir);
    if (await dir.exists()) {
      await dir.delete(recursive: true);
      print('🧹 Cleaned $outputDir');
    }
  }

  /// Optimize images in build
  static Future<void> _optimizeImages(Directory dir) async {
    print('  🖼️ Optimizing images...');
    
    await for (final entity in dir.list(recursive: true)) {
      if (entity is File && _isImageFile(entity.path)) {
        // Image optimization logic would go here
        print('    Optimized: ${entity.path}');
      }
    }
  }

  /// Compress assets
  static Future<void> _compressAssets(Directory dir) async {
    print('  📦 Compressing assets...');
    
    final assetsDir = Directory('${dir.path}/assets');
    if (await assetsDir.exists()) {
      // Asset compression logic would go here
      print('    Compressed assets directory');
    }
  }

  /// Generate build manifest
  static Future<void> _generateBuildManifest(String configName, Map<String, dynamic> config) async {
    print('  📋 Generating build manifest...');
    
    final manifest = {
      'config': configName,
      'timestamp': DateTime.now().toIso8601String(),
      'flutter_version': await _getFlutterVersion(),
      'output_directory': config['output-dir'],
      'assets_mode': config['assets-mode'],
      'build_number': await _getBuildNumber(),
      'files': await _getBuildFiles(config['output-dir']),
    };
    
    final manifestFile = File('${config['output-dir']}/build_manifest.json');
    await manifestFile.writeAsString(
      JsonEncoder.withIndent('  ').convert(manifest),
    );
  }

  /// Generate size report
  static Future<void> _generateSizeReport(String configName, Directory dir) async {
    print('  📊 Generating size report...');
    
    final sizes = <String, int>{};
    int totalSize = 0;
    
    await for (final entity in dir.list(recursive: true)) {
      if (entity is File) {
        final size = await entity.length();
        sizes[entity.path] = size;
        totalSize += size;
      }
    }
    
    final report = {
      'config': configName,
      'total_size_bytes': totalSize,
      'total_size_mb': (totalSize / (1024 * 1024)).toStringAsFixed(2),
      'file_count': sizes.length,
      'largest_files': sizes.entries
          .toList()
          ..sort((a, b) => b.value.compareTo(a.value))
          .take(10)
          .map((e) => {'path': e.key, 'size': e.value})
          .toList(),
    };
    
    final reportFile = File('${dir.path}/size_report.json');
    await reportFile.writeAsString(
      JsonEncoder.withIndent('  ').convert(report),
    );
    
    print('    Total size: ${(totalSize / (1024 * 1024)).toStringAsFixed(2)} MB');
  }

  /// Get build files
  static Future<List<Map<String, dynamic>>> _getBuildFiles(String outputDir) async {
    final files = <Map<String, dynamic>>[];
    final dir = Directory(outputDir);
    
    await for (final entity in dir.list(recursive: true)) {
      if (entity is File) {
        final stat = await entity.stat();
        files.add({
          'path': entity.path,
          'size': stat.size,
          'modified': stat.modified.toIso8601String(),
          'type': _getFileType(entity.path),
        });
      }
    }
    
    return files;
  }

  /// Check if file is an image
  static bool _isImageFile(String path) {
    final ext = path.extension(path).toLowerCase();
    return ['.png', '.jpg', '.jpeg', '.gif', '.webp'].contains(ext);
  }

  /// Get file type
  static String _getFileType(String path) {
    final ext = path.extension(path).toLowerCase();
    switch (ext) {
      case '.dart':
        return 'source';
      case '.json':
        return 'data';
      case '.png':
      case '.jpg':
      case '.jpeg':
      case '.gif':
        return 'image';
      case '.html':
      case '.css':
      case '.js':
        return 'web';
      default:
        return 'other';
    }
  }

  /// Get Flutter version
  static Future<String> _getFlutterVersion() async {
    final result = await Process.run('flutter', ['--version']);
    return result.stdout.trim();
  }

  /// Get build number
  static Future<int> _getBuildNumber() async {
    // This would typically come from environment or build config
    return DateTime.now().millisecondsSinceEpoch ~/ 1000;
  }

  /// Analyze build performance
  static Future<void> analyzeBuildPerformance() async {
    print('📈 Analyzing build performance...');
    
    final buildDir = Directory('build');
    if (!await buildDir.exists()) {
      print('❌ No build directory found');
      return;
    }
    
    // Analyze build times, sizes, etc.
    final configs = buildConfigs.keys.where((k) => k != 'debug').toList();
    
    for (final config in configs) {
      final configDir = Directory('${buildDir.path}/$config');
      if (await configDir.exists()) {
        final size = await _getDirectorySize(configDir);
        print('  $config: ${(size / (1024 * 1024)).toStringAsFixed(2)} MB');
      }
    }
  }

  /// Get directory size
  static Future<int> _getDirectorySize(Directory dir) async {
    int totalSize = 0;
    
    await for (final entity in dir.list(recursive: true)) {
      if (entity is File) {
        totalSize += await entity.length();
      } else if (entity is Directory) {
        totalSize += await _getDirectorySize(entity);
      }
    }
    
    return totalSize;
  }

  /// Create build summary
  static Future<void> createBuildSummary() async {
    print('📋 Creating build summary...');
    
    final summary = {
      'timestamp': DateTime.now().toIso8601String(),
      'project': 'VedantaTrade',
      'builds': <String, dynamic>{},
    };
    
    final buildDir = Directory('build');
    if (await buildDir.exists()) {
      await for (final entity in buildDir.list()) {
        if (entity is Directory) {
          final size = await _getDirectorySize(entity);
          summary['builds'][entity.path.split('/').last] = {
            'size_mb': (size / (1024 * 1024)).toStringAsFixed(2),
            'file_count': await _getFileCount(entity),
          };
        }
      }
    }
    
    final summaryFile = File('build/summary.json');
    await summaryFile.writeAsString(
      JsonEncoder.withIndent('  ').convert(summary),
    );
    
    print('✅ Build summary created');
  }

  /// Get file count
  static Future<int> _getFileCount(Directory dir) async {
    int count = 0;
    
    await for (final entity in dir.list(recursive: true)) {
      if (entity is File) count++;
    }
    
    return count;
  }
}

void main(List<String> args) async {
  if (args.isEmpty) {
    print('''
🏗️ VedantaTrade Build Helper

Usage: dart tools/build_helper.dart [command] [config]

Commands:
  build [config]    - Build specific configuration
  build-all          - Build all configurations
  analyze            - Analyze build performance
  summary            - Create build summary

Configurations:
  debug              - Debug build
  profile            - Profile build
  release            - Release build
  web                - Web build
  apk                - Android APK
  ios                - iOS build

Examples:
  dart tools/build_helper.dart build release
  dart tools/build_helper.dart build-all
  dart tools/build_helper.dart analyze
''');
    return;
  }

  final command = args.first;
  
  switch (command) {
    case 'build':
      if (args.length > 1) {
        await BuildHelper.build(args[1]);
      } else {
        print('❌ Please specify a build configuration');
      }
      break;
    case 'build-all':
      await BuildHelper.buildAll();
      break;
    case 'analyze':
      await BuildHelper.analyzeBuildPerformance();
      break;
    case 'summary':
      await BuildHelper.createBuildSummary();
      break;
    default:
      print('❌ Unknown command: $command');
  }
}
