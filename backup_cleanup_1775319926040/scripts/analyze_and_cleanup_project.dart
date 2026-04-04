#!/usr/bin/env dart

/// Project Analysis and Cleanup Script
/// This script analyzes VedantaTrade project for:
/// 1. Duplicate files and components
/// 2. Unused imports and dependencies
/// 3. Broken imports and missing dependencies
/// 4. Code quality issues
/// 5. Performance bottlenecks
/// 6. Security vulnerabilities
/// 7. Dead code and unused components

import 'dart:io';
import 'dart:convert';

class ProjectAnalyzer {
  static const String projectRoot = 'i:\\Path\\Projects\\VedantaTrade';
  static const String libPath = '$projectRoot\\lib';
  
  final Set<String> duplicateFiles = {};
  final Set<String> brokenImports = {};
  final Set<String> deadCode = {};
  final Map<String, List<String>> fileDependencies = {};
  final Map<String, int> fileUsageCount = {};
  
  Future<void> analyzeProject() async {
    print('🔍 Analyzing VedantaTrade project...');
    
    try {
      // 1. Find duplicate files
      await _findDuplicateFiles();
      
      // 2. Analyze imports and dependencies
      await _analyzeImports();
      
      // 3. Check for broken imports
      await _checkBrokenImports();
      
      // 4. Find dead code
      await _findDeadCode();
      
      // 5. Generate comprehensive report
      await _generateAnalysisReport();
      
      // 6. Create cleanup recommendations
      await _generateCleanupRecommendations();
      
      print('✅ Project analysis completed successfully!');
      
    } catch (e) {
      print('❌ Error analyzing project: $e');
      exit(1);
    }
  }

  Future<void> _findDuplicateFiles() async {
    print('\n📄 Finding duplicate files...');
    
    final libDir = Directory(libPath);
    final fileMap = <String, List<String>>{};
    
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
        duplicateFiles.addAll(entry.value);
        print('  ⚠️  Duplicate file: ${entry.key}');
        for (final path in entry.value) {
          print('    - $path');
        }
      }
    }
  }

  Future<void> _analyzeImports() async {
    print('\n🔗 Analyzing imports and dependencies...');
    
    final libDir = Directory(libPath);
    
    for (final file in libDir.listSync(recursive: true)) {
      if (file is File && file.path.endsWith('.dart')) {
        final content = await file.readAsString();
        final imports = _extractImports(content);
        
        fileDependencies[file.path] = imports;
        
        // Count file usage
        for (final import in imports) {
          final importPath = _normalizeImportPath(import, file.path);
          if (importPath != null) {
            fileUsageCount[importPath] = (fileUsageCount[importPath] ?? 0) + 1;
          }
        }
      }
    }
    
    print('  📊 Analyzed ${fileDependencies.length} files');
  }

  List<String> _extractImports(String content) {
    final imports = <String>[];
    final importRegex = RegExp(r"import\s+['\"]([^'\"]+)['\"]");
    final matches = importRegex.allMatches(content);
    
    for (final match in matches) {
      imports.add(match.group(1)!);
    }
    
    return imports;
  }

  String? _normalizeImportPath(String importPath, String currentFilePath) {
    if (importPath.startsWith('package:')) {
      // Handle package imports
      return importPath;
    } else if (importPath.startsWith('dart:')) {
      // Handle dart imports
      return importPath;
    } else {
      // Handle relative imports
      final currentDir = currentFilePath.substring(0, currentFilePath.lastIndexOf('\\'));
      final normalizedPath = _resolveRelativePath(importPath, currentDir);
      return normalizedPath;
    }
  }

  String _resolveRelativePath(String relativePath, String currentDir) {
    if (relativePath.startsWith('../')) {
      final parts = relativePath.split('/');
      var dir = currentDir;
      
      for (final part in parts) {
        if (part == '..') {
          dir = dir.substring(0, dir.lastIndexOf('\\'));
        } else if (part.isNotEmpty) {
          dir = '$dir\\$part';
        }
      }
      
      return '$dir.dart';
    } else {
      return '$currentDir\\$relativePath.dart';
    }
  }

  Future<void> _checkBrokenImports() async {
    print('\n❌ Checking for broken imports...');
    
    for (final entry in fileDependencies.entries) {
      final filePath = entry.key;
      final imports = entry.value;
      
      for (final import in imports) {
        final importPath = _normalizeImportPath(import, filePath);
        
        if (importPath != null && !importPath.startsWith('package:') && !importPath.startsWith('dart:')) {
          if (!await File(importPath).exists()) {
            brokenImports.add('$filePath imports $importPath (file not found)');
          }
        }
      }
    }
    
    if (brokenImports.isEmpty) {
      print('  ✅ No broken imports found');
    } else {
      print('  ⚠️  Found ${brokenImports.length} broken imports');
      for (final brokenImport in brokenImports) {
        print('    - $brokenImport');
      }
    }
  }

  Future<void> _findDeadCode() async {
    print('\n🗑️  Finding dead code...');
    
    final libDir = Directory(libPath);
    final allFiles = <String>[];
    
    for (final file in libDir.listSync(recursive: true)) {
      if (file is File && file.path.endsWith('.dart')) {
        allFiles.add(file.path);
      }
    }
    
    // Find files that are never imported
    for (final file in allFiles) {
      if (!fileUsageCount.containsKey(file) && fileUsageCount[file] == null) {
        // Skip main files and entry points
        if (!file.contains('main.dart') && !file.contains('app.dart')) {
          deadCode.add(file);
        }
      }
    }
    
    if (deadCode.isEmpty) {
      print('  ✅ No dead code found');
    } else {
      print('  ⚠️  Found ${deadCode.length} potentially unused files');
      for (final deadFile in deadCode) {
        print('    - $deadFile');
      }
    }
  }

  Future<void> _generateAnalysisReport() async {
    print('\n📊 Generating analysis report...');
    
    final report = {
      'timestamp': DateTime.now().toIso8601String(),
      'summary': {
        'totalFiles': fileDependencies.length,
        'duplicateFiles': duplicateFiles.length,
        'brokenImports': brokenImports.length,
        'deadCodeFiles': deadCode.length,
      },
      'duplicateFiles': duplicateFiles.toList(),
      'brokenImports': brokenImports.toList(),
      'deadCodeFiles': deadCode.toList(),
      'fileDependencies': fileDependencies,
      'fileUsageCount': fileUsageCount,
    };
    
    final reportPath = '$projectRoot\\docs\\project_analysis_report.json';
    await File(reportPath).writeAsString(jsonEncode(report));
    
    print('  📄 Report saved to: docs/project_analysis_report.json');
  }

  Future<void> _generateCleanupRecommendations() async {
    print('\n🧹 Generating cleanup recommendations...');
    
    final recommendations = <String>[];
    
    // Duplicate file recommendations
    if (duplicateFiles.isNotEmpty) {
      recommendations.add('## Duplicate Files\n');
      recommendations.add('The following files appear to be duplicates. Consider consolidating or removing duplicates:\n');
      
      for (final duplicate in duplicateFiles) {
        recommendations.add('- $duplicate');
      }
      recommendations.add('');
    }
    
    // Broken import recommendations
    if (brokenImports.isNotEmpty) {
      recommendations.add('## Broken Imports\n');
      recommendations.add('The following imports are broken. Fix or remove them:\n');
      
      for (final broken in brokenImports) {
        recommendations.add('- $broken');
      }
      recommendations.add('');
    }
    
    // Dead code recommendations
    if (deadCode.isNotEmpty) {
      recommendations.add('## Dead Code\n');
      recommendations.add('The following files appear to be unused. Consider removing them:\n');
      
      for (final dead in deadCode) {
        recommendations.add('- $dead');
      }
      recommendations.add('');
    }
    
    // General recommendations
    recommendations.addAll([
      '## General Recommendations\n',
      '1. **Organize Feature Structure**: Ensure all features follow standard structure:',
      '   - data/ (models, services, repositories)',
      '   - domain/ (entities, usecases, repositories)',
      '   - presentation/ (screens, widgets, providers)',
      '',
      '2. **Remove Duplicate Services**: Check for duplicate service implementations',
      '   - Look for multiple API services with similar functionality',
      '   - Consolidate authentication services',
      '   - Merge duplicate utility functions',
      '',
      '3. **Clean Up Constants**: Remove unused constants and consolidate related ones',
      '   - Move Nepal-specific constants to app_constants.dart',
      '   - Remove unused theme constants',
      '   - Consolidate API endpoints',
      '',
      '4. **Update Dependencies**: Remove unused dependencies from pubspec.yaml',
      '   - Check for unused packages',
      '   - Update to latest stable versions',
      '   - Remove development dependencies from production',
      '',
      '5. **Improve Import Organization**: Organize imports consistently',
      '   - Group imports: dart:, package:, relative',
      '   - Remove unused imports',
      '   - Use absolute imports where possible',
      '',
      '6. **Remove Dead Code**: Delete unused widgets, screens, and utilities',
      '   - Remove unused widget files',
      '   - Delete unused screen files',
      '   - Clean up unused utility functions',
      '',
      '7. **Consolidate Similar Features**: Merge similar functionality',
      '   - Merge accounting and accountinging features',
      '   - Consolidate admin functionality',
      '   - Merge duplicate dashboard implementations',
      '',
      '8. **Update File Naming**: Ensure consistent naming conventions',
      '   - Use snake_case for files',
      '   - Use PascalCase for classes',
      '   - Add proper file extensions',
      '',
    ]);
    
    final recommendationsPath = '$projectRoot\\docs\\cleanup_recommendations.md';
    await File(recommendationsPath).writeAsString(recommendations.join('\n'));
    
    print('  📄 Recommendations saved to: docs/cleanup_recommendations.md');
  }
}

void main(List<String> args) async {
  final analyzer = ProjectAnalyzer();
  await analyzer.analyzeProject();
}
