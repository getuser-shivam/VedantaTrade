#!/usr/bin/env dart

/// Project Reorganization Script for VedantaTrade
/// 
/// This script helps reorganize the project structure and fix naming conventions
/// according to the established guidelines.

import 'dart:io';
import 'dart:convert';

class ProjectReorganizer {
  static const String libPath = 'lib';
  static const String featuresPath = 'lib/features';
  
  // Mapping of current problematic names to standardized names
  static const Map<String, String> directoryNameMap = {
    // Add any directories that need renaming
    // Example: 'UserProfile' -> 'user_profile'
  };
  
  static const Map<String, String> fileNameMap = {
    // Add files that need renaming
    // Example: 'UserProfileScreen.dart' -> 'user_profile_screen.dart'
  };

  Future<void> reorganize() async {
    print('🚀 Starting VedantaTrade project reorganization...\n');
    
    // Step 1: Analyze current structure
    await _analyzeCurrentStructure();
    
    // Step 2: Fix directory names
    await _fixDirectoryNames();
    
    // Step 3: Fix file names
    await _fixFileNames();
    
    // Step 4: Reorganize feature structure
    await _reorganizeFeatureStructure();
    
    // Step 5: Generate reorganization report
    await _generateReport();
    
    print('\n✅ Project reorganization completed!');
    print('📋 Check the reorganization_report.json for details.');
    print('🔍 Review and update import statements as needed.');
  }

  Future<void> _analyzeCurrentStructure() async {
    print('📊 Analyzing current project structure...');
    
    final featuresDir = Directory(featuresPath);
    if (!await featuresDir.exists()) {
      print('❌ Features directory not found!');
      return;
    }
    
    final issues = <String>[];
    
    await for (final entity in featuresDir.list()) {
      if (entity is Directory) {
        final dirName = entity.path.split('/').last;
        
        // Check directory naming convention
        if (!_isSnakeCase(dirName)) {
          issues.add('Directory name not snake_case: $dirName');
        }
        
        // Check feature structure
        await _checkFeatureStructure(entity, issues);
      }
    }
    
    if (issues.isEmpty) {
      print('✅ No structural issues found');
    } else {
      print('⚠️  Found ${issues.length} structural issues:');
      for (final issue in issues.take(10)) {
        print('   - $issue');
      }
      if (issues.length > 10) {
        print('   ... and ${issues.length - 10} more');
      }
    }
  }

  Future<void> _checkFeatureStructure(Directory featureDir, List<String> issues) async {
    final featureName = featureDir.path.split('/').last;
    final requiredDirs = ['data', 'domain', 'presentation'];
    
    for (final requiredDir in requiredDirs) {
      final dirPath = '${featureDir.path}/$requiredDir';
      final dir = Directory(dirPath);
      
      if (!await dir.exists()) {
        issues.add('Missing $requiredDir directory in feature: $featureName');
      }
    }
    
    // Check for feature export file
    final exportFile = File('${featureDir.path}/$featureName.dart');
    if (!await exportFile.exists()) {
      issues.add('Missing feature export file: $featureName.dart');
    }
  }

  Future<void> _fixDirectoryNames() async {
    print('\n📁 Fixing directory names...');
    
    final featuresDir = Directory(featuresPath);
    
    await for (final entity in featuresDir.list()) {
      if (entity is Directory) {
        final currentName = entity.path.split('/').last;
        
        if (!_isSnakeCase(currentName)) {
          final newName = _toSnakeCase(currentName);
          final newPath = '${featuresPath}/$newName';
          
          try {
            await entity.rename(newPath);
            print('✅ Renamed directory: $currentName -> $newName');
          } catch (e) {
            print('❌ Failed to rename directory $currentName: $e');
          }
        }
      }
    }
  }

  Future<void> _fixFileNames() async {
    print('\n📄 Fixing file names...');
    
    await _fixFilesInDirectory(Directory(libPath));
  }

  Future<void> _fixFilesInDirectory(Directory dir) async {
    await for (final entity in dir.list()) {
      if (entity is File) {
        final fileName = entity.path.split('/').last;
        
        if (fileName.endsWith('.dart') && !_isSnakeCase(fileName.replaceAll('.dart', ''))) {
          final newName = _toSnakeCase(fileName.replaceAll('.dart', '')) + '.dart';
          final newPath = '${entity.path.replaceAll(fileName, newName)}';
          
          try {
            await entity.rename(newPath);
            print('✅ Renamed file: $fileName -> $newName');
          } catch (e) {
            print('❌ Failed to rename file $fileName: $e');
          }
        }
      } else if (entity is Directory) {
        await _fixFilesInDirectory(entity);
      }
    }
  }

  Future<void> _reorganizeFeatureStructure() async {
    print('\n🏗️  Reorganizing feature structure...');
    
    final featuresDir = Directory(featuresPath);
    
    await for (final entity in featuresDir.list()) {
      if (entity is Directory) {
        await _ensureFeatureStructure(entity);
      }
    }
  }

  Future<void> _ensureFeatureStructure(Directory featureDir) async {
    final featureName = featureDir.path.split('/').last;
    
    // Ensure standard directories exist
    final standardDirs = [
      'data/datasources',
      'data/models',
      'data/repositories',
      'domain/entities',
      'domain/repositories',
      'domain/usecases',
      'presentation/providers',
      'presentation/screens',
      'presentation/widgets',
    ];
    
    for (final dirPath in standardDirs) {
      final fullPath = '${featureDir.path}/$dirPath';
      final dir = Directory(fullPath);
      
      if (!await dir.exists()) {
        await dir.create(recursive: true);
        print('✅ Created directory: $dirPath');
      }
    }
    
    // Create feature export file if missing
    final exportFile = File('${featureDir.path}/$featureName.dart');
    if (!await exportFile.exists()) {
      await exportFile.writeAsString(_generateFeatureExport(featureName));
      print('✅ Created feature export file: $featureName.dart');
    }
  }

  String _generateFeatureExport(String featureName) {
    return '''
// $featureName Feature Exports
// Clean Architecture structure

// Domain
export 'domain/entities/${featureName}_entity.dart';
export 'domain/repositories/${featureName}_repository.dart';
export 'domain/usecases/${featureName}_usecases.dart';

// Data
export 'data/models/${featureName}_model.dart';
export 'data/repositories/${featureName}_repository_impl.dart';
export 'data/datasources/${featureName}_datasource.dart';

// Presentation
export 'presentation/providers/${featureName}_provider.dart';
export 'presentation/screens/${featureName}_screen.dart';
export 'presentation/widgets/${featureName}_widgets.dart';
''';
  }

  Future<void> _generateReport() async {
    print('\n📋 Generating reorganization report...');
    
    final report = {
      'timestamp': DateTime.now().toIso8601String(),
      'project': 'VedantaTrade',
      'version': '1.0.0',
      'changes': {
        'directories_renamed': [],
        'files_renamed': [],
        'directories_created': [],
        'files_created': [],
      },
      'recommendations': [
        'Review and update all import statements',
        'Test the application after reorganization',
        'Update documentation if needed',
        'Run code formatting and linting',
      ],
      'next_steps': [
        'Update import statements in all Dart files',
        'Run flutter pub get',
        'Test the application',
        'Fix any remaining import issues',
      ],
    };
    
    final reportFile = File('reorganization_report.json');
    await reportFile.writeAsString(
      const JsonEncoder.withIndent('  ').convert(report),
    );
    
    print('✅ Reorganization report generated: reorganization_report.json');
  }

  bool _isSnakeCase(String name) {
    return RegExp(r'^[a-z]+(_[a-z]+)*$').hasMatch(name);
  }

  String _toSnakeCase(String name) {
    // Convert PascalCase or camelCase to snake_case
    return name
        .replaceAllMapped(RegExp(r'(?<!^)(?=[A-Z])'), (match) => '_')
        .toLowerCase();
  }
}

void main() async {
  final reorganizer = ProjectReorganizer();
  await reorganizer.reorganize();
}
