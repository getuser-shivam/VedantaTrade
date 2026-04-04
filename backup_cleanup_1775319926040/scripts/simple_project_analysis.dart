#!/usr/bin/env dart

/// Simple Project Analysis Script
/// Analyzes VedantaTrade project for basic issues

import 'dart:io';
import 'dart:convert';

class SimpleProjectAnalyzer {
  static const String projectRoot = 'i:\\Path\\Projects\\VedantaTrade';
  static const String libPath = '$projectRoot\\lib';
  
  Future<void> analyzeProject() async {
    print('🔍 Analyzing VedantaTrade project...');
    
    try {
      // 1. Count files by category
      await _analyzeFileStructure();
      
      // 2. Check for duplicate files
      await _findDuplicateFiles();
      
      // 3. Check for common issues
      await _checkCommonIssues();
      
      // 4. Generate basic report
      await _generateBasicReport();
      
      print('✅ Project analysis completed successfully!');
      
    } catch (e) {
      print('❌ Error analyzing project: $e');
      exit(1);
    }
  }

  Future<void> _analyzeFileStructure() async {
    print('\n📁 Analyzing file structure...');
    
    final libDir = Directory(libPath);
    final fileStats = <String, int>{};
    final dirStats = <String, int>{};
    
    for (final entity in libDir.listSync(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        final pathParts = entity.path.split('\\');
        
        // Count by feature
        if (pathParts.contains('features')) {
          final featureIndex = pathParts.indexOf('features');
          if (featureIndex < pathParts.length - 1) {
            final feature = pathParts[featureIndex + 1];
            fileStats[feature] = (fileStats[feature] ?? 0) + 1;
          }
        }
        
        // Count by type
        if (pathParts.contains('data')) {
          dirStats['data'] = (dirStats['data'] ?? 0) + 1;
        } else if (pathParts.contains('presentation')) {
          dirStats['presentation'] = (dirStats['presentation'] ?? 0) + 1;
        } else if (pathParts.contains('domain')) {
          dirStats['domain'] = (dirStats['domain'] ?? 0) + 1;
        } else if (pathParts.contains('core')) {
          dirStats['core'] = (dirStats['core'] ?? 0) + 1;
        } else if (pathParts.contains('shared')) {
          dirStats['shared'] = (dirStats['shared'] ?? 0) + 1;
        }
      }
    }
    
    print('  📊 File Statistics:');
    print('    Features: ${fileStats.length}');
    for (final entry in fileStats.entries) {
      print('      ${entry.key}: ${entry.value} files');
    }
    
    print('  📁 Directory Statistics:');
    for (final entry in dirStats.entries) {
      print('      ${entry.key}: ${entry.value} files');
    }
  }

  Future<void> _findDuplicateFiles() async {
    print('\n📄 Finding duplicate files...');
    
    final libDir = Directory(libPath);
    final fileMap = <String, List<String>>{};
    int duplicateCount = 0;
    
    for (final file in libDir.listSync(recursive: true)) {
      if (file is File && file.path.endsWith('.dart')) {
        final fileName = file.path.split('\\').last;
        
        if (!fileMap.containsKey(fileName)) {
          fileMap[fileName] = [];
        }
        fileMap[fileName]!.add(file.path);
      }
    }
    
    for (final entry in fileMap.entries) {
      if (entry.value.length > 1) {
        duplicateCount++;
        print('  ⚠️  Duplicate: ${entry.key}');
        for (final path in entry.value) {
          print('    - $path');
        }
      }
    }
    
    if (duplicateCount == 0) {
      print('  ✅ No duplicate files found');
    } else {
      print('  ⚠️  Found $duplicateCount duplicate files');
    }
  }

  Future<void> _checkCommonIssues() async {
    print('\n🔍 Checking for common issues...');
    
    final libDir = Directory(libPath);
    final issues = <String>[];
    
    for (final file in libDir.listSync(recursive: true)) {
      if (file is File && file.path.endsWith('.dart')) {
        final content = await file.readAsString();
        final fileName = file.path.split('\\').last;
        
        // Check for empty files
        if (content.trim().isEmpty) {
          issues.add('Empty file: $fileName');
        }
        
        // Check for TODO comments
        if (content.contains('TODO:') || content.contains('FIXME:')) {
          issues.add('Contains TODO/FIXME: $fileName');
        }
        
        // Check for print statements
        if (content.contains('print(') && !fileName.contains('main.dart')) {
          issues.add('Contains print statement: $fileName');
        }
        
        // Check for hardcoded strings
        if (content.contains('http://') || content.contains('https://')) {
          issues.add('Contains hardcoded URL: $fileName');
        }
      }
    }
    
    if (issues.isEmpty) {
      print('  ✅ No common issues found');
    } else {
      print('  ⚠️  Found ${issues.length} issues:');
      for (final issue in issues) {
        print('    - $issue');
      }
    }
  }

  Future<void> _generateBasicReport() async {
    print('\n📊 Generating basic report...');
    
    final libDir = Directory(libPath);
    final totalFiles = <String>[];
    final features = <String>[];
    final duplicates = <String>[];
    
    for (final file in libDir.listSync(recursive: true)) {
      if (file is File && file.path.endsWith('.dart')) {
        totalFiles.add(file.path);
        
        final pathParts = file.path.split('\\');
        if (pathParts.contains('features')) {
          final featureIndex = pathParts.indexOf('features');
          if (featureIndex < pathParts.length - 1) {
            final feature = pathParts[featureIndex + 1];
            if (!features.contains(feature)) {
              features.add(feature);
            }
          }
        }
      }
    }
    
    final report = {
      'timestamp': DateTime.now().toIso8601String(),
      'summary': {
        'totalDartFiles': totalFiles.length,
        'totalFeatures': features.length,
        'projectPath': libPath,
      },
      'features': features,
      'files': totalFiles.map((f) => f.replaceFirst('$libPath\\', '')).toList(),
    };
    
    final reportPath = '$projectRoot\\docs\\basic_project_analysis.json';
    await File(reportPath).writeAsString(jsonEncode(report));
    
    print('  📄 Report saved to: docs/basic_project_analysis.json');
  }
}

void main() async {
  final analyzer = SimpleProjectAnalyzer();
  await analyzer.analyzeProject();
}
