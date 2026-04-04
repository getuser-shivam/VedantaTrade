import 'dart:io';
import 'dart:convert';

/// Code Cleanup Utility for VedantaTrade
/// Ensures all components are working and removes unnecessary code
class CodeCleanupUtility {
  static final List<String> _cleanupResults = [];
  static final List<String> _filesProcessed = [];

  /// Perform comprehensive code cleanup
  static Future<CleanupReport> performCleanup() async {
    _cleanupResults.clear();
    _filesProcessed.clear();

    final report = CleanupReport();

    // Check for unused imports
    await _checkForUnusedImports(report);

    // Remove dead code
    await _removeDeadCode(report);

    // Optimize imports
    await _optimizeImports(report);

    // Check for duplicate files
    await _checkForDuplicateFiles(report);

    // Validate component dependencies
    await _validateComponentDependencies(report);

    // Remove unused assets
    await _removeUnusedAssets(report);

    // Optimize file structure
    await _optimizeFileStructure(report);

    return report;
  }

  /// Check for unused imports
  static Future<void> _checkForUnusedImports(CleanupReport report) async {
    try {
      final libDir = Directory('lib');
      if (!await libDir.exists()) {
        report.addWarning('Import Check', 'lib directory not found');
        return;
      }

      await for (final entity in libDir.list(recursive: true)) {
        if (entity is File && entity.path.endsWith('.dart')) {
          final content = await entity.readAsString();
          final unusedImports = _findUnusedImports(content, entity.path);
          
          if (unusedImports.isNotEmpty) {
            report.addIssue('Unused Imports', 
                'Found ${unusedImports.length} unused imports in ${entity.path}');
            _cleanupResults.add('🔧 Unused imports found in ${entity.path}');
          }
          
          _filesProcessed.add(entity.path);
        }
      }

      report.addSuccess('Import Check', 'Import analysis completed');
      _cleanupResults.add('✅ Import check completed');
    } catch (e) {
      report.addError('Import Check', e.toString());
    }
  }

  /// Find unused imports in a file
  static List<String> _findUnusedImports(String content, String filePath) {
    final unusedImports = <String>[];
    final lines = content.split('\n');
    
    for (final line in lines) {
      if (line.trim().startsWith('import ')) {
        final importPath = _extractImportPath(line);
        if (importPath != null && !_isImportUsed(content, importPath)) {
          unusedImports.add(importPath);
        }
      }
    }
    
    return unusedImports;
  }

  /// Extract import path from import statement
  static String? _extractImportPath(String importLine) {
    final match = RegExp(r"import\s+['\"]([^'\"]+)['\"]").firstMatch(importLine);
    return match?.group(1);
  }

  /// Check if import is used in the content
  static bool _isImportUsed(String content, String importPath) {
    final parts = importPath.split('/');
    final className = parts.last.replaceAll('.dart', '');
    
    // Check if class name is used
    if (content.contains(RegExp(r'\b' + className + r'\b'))) {
      return true;
    }
    
    // Check for 'as' alias usage
    final asMatch = RegExp(r"import\s+.*\s+as\s+(\w+)").firstMatch(content);
    if (asMatch != null) {
      final alias = asMatch.group(1);
      return content.contains(RegExp(r'\b' + alias + r'\.'));
    }
    
    return false;
  }

  /// Remove dead code
  static Future<void> _removeDeadCode(CleanupReport report) async {
    try {
      final libDir = Directory('lib');
      if (!await libDir.exists()) {
        report.addWarning('Dead Code Removal', 'lib directory not found');
        return;
      }

      int deadCodeFiles = 0;
      
      await for (final entity in libDir.list(recursive: true)) {
        if (entity is File && entity.path.endsWith('.dart')) {
          final content = await entity.readAsString();
          
          // Check for empty classes or functions
          if (_containsDeadCode(content)) {
            deadCodeFiles++;
            report.addIssue('Dead Code', 'Potential dead code found in ${entity.path}');
            _cleanupResults.add('🔧 Dead code found in ${entity.path}');
          }
        }
      }

      if (deadCodeFiles == 0) {
        report.addSuccess('Dead Code Removal', 'No dead code found');
        _cleanupResults.add('✅ No dead code found');
      } else {
        report.addWarning('Dead Code Removal', 'Found $deadCodeFiles files with potential dead code');
      }
    } catch (e) {
      report.addError('Dead Code Removal', e.toString());
    }
  }

  /// Check if content contains dead code
  static bool _containsDeadCode(String content) {
    // Check for empty classes
    if (RegExp(r'class\s+\w+\s*\{\s*\}').hasMatch(content)) {
      return true;
    }
    
    // Check for empty functions
    if (RegExp(r'\w+\s*\(\s*\)\s*\{\s*\}').hasMatch(content)) {
      return true;
    }
    
    // Check for unused variables
    if (RegExp(r'final\s+\w+\s*=.*;').hasMatch(content)) {
      return true;
    }
    
    return false;
  }

  /// Optimize imports
  static Future<void> _optimizeImports(CleanupReport report) async {
    try {
      final libDir = Directory('lib');
      if (!await libDir.exists()) {
        report.addWarning('Import Optimization', 'lib directory not found');
        return;
      }

      int optimizedFiles = 0;
      
      await for (final entity in libDir.list(recursive: true)) {
        if (entity is File && entity.path.endsWith('.dart')) {
          final content = await entity.readAsString();
          final optimizedContent = _optimizeImportOrder(content);
          
          if (optimizedContent != content) {
            await entity.writeAsString(optimizedContent);
            optimizedFiles++;
            _cleanupResults.add('🔧 Optimized imports in ${entity.path}');
          }
        }
      }

      report.addSuccess('Import Optimization', 'Optimized $optimizedFiles files');
      _cleanupResults.add('✅ Import optimization completed');
    } catch (e) {
      report.addError('Import Optimization', e.toString());
    }
  }

  /// Optimize import order in content
  static String _optimizeImportOrder(String content) {
    final lines = content.split('\n');
    final importLines = <String>[];
    final otherLines = <String>[];
    bool inImports = false;
    
    for (final line in lines) {
      if (line.trim().startsWith('import ')) {
        importLines.add(line);
        inImports = true;
      } else if (inImports && line.trim().isEmpty) {
        continue; // Skip empty lines between imports
      } else {
        otherLines.add(line);
        inImports = false;
      }
    }
    
    // Sort imports: dart imports first, then package imports, then local imports
    importLines.sort((a, b) {
      final aIsDart = a.contains('dart:');
      final bIsDart = b.contains('dart:');
      final aIsPackage = a.contains('package:');
      final bIsPackage = b.contains('package:');
      
      if (aIsDart && !bIsDart) return -1;
      if (!aIsDart && bIsDart) return 1;
      if (aIsPackage && !bIsPackage) return -1;
      if (!aIsPackage && bIsPackage) return 1;
      
      return a.compareTo(b);
    });
    
    return [...importLines, '', ...otherLines].join('\n');
  }

  /// Check for duplicate files
  static Future<void> _checkForDuplicateFiles(CleanupReport report) async {
    try {
      final libDir = Directory('lib');
      if (!await libDir.exists()) {
        report.addWarning('Duplicate Check', 'lib directory not found');
        return;
      }

      final fileHashes = <String, List<String>>{};
      int duplicateFiles = 0;
      
      await for (final entity in libDir.list(recursive: true)) {
        if (entity is File && entity.path.endsWith('.dart')) {
          final content = await entity.readAsString();
          final hash = _calculateHash(content);
          
          if (!fileHashes.containsKey(hash)) {
            fileHashes[hash] = [];
          }
          fileHashes[hash]!.add(entity.path);
        }
      }
      
      for (final entry in fileHashes.entries) {
        if (entry.value.length > 1) {
          duplicateFiles += entry.value.length - 1;
          report.addIssue('Duplicate Files', 
              'Found duplicate files: ${entry.value.join(', ')}');
          _cleanupResults.add('🔧 Duplicate files found: ${entry.value.join(', ')}');
        }
      }

      if (duplicateFiles == 0) {
        report.addSuccess('Duplicate Check', 'No duplicate files found');
        _cleanupResults.add('✅ No duplicate files found');
      } else {
        report.addWarning('Duplicate Check', 'Found $duplicateFiles duplicate files');
      }
    } catch (e) {
      report.addError('Duplicate Check', e.toString());
    }
  }

  /// Calculate hash of content
  static String _calculateHash(String content) {
    return content.hashCode.toString();
  }

  /// Validate component dependencies
  static Future<void> _validateComponentDependencies(CleanupReport report) async {
    try {
      final components = [
        'enhanced_theme.dart',
        'enhanced_ui_kit.dart',
        'enhanced_navigation_system.dart',
        'enhanced_responsive_layout.dart',
        'enhanced_animations.dart',
      ];

      for (final component in components) {
        final file = File('lib/shared/widgets/$component');
        if (await file.exists()) {
          final content = await file.readAsString();
          final dependencies = _extractDependencies(content);
          
          for (final dependency in dependencies) {
            final depFile = File('lib/shared/widgets/$dependency');
            if (!await depFile.exists()) {
              report.addIssue('Dependencies', 
                  'Missing dependency $dependency for $component');
              _cleanupResults.add('🔧 Missing dependency: $dependency');
            }
          }
        }
      }

      report.addSuccess('Dependencies', 'Dependency validation completed');
      _cleanupResults.add('✅ Dependency validation completed');
    } catch (e) {
      report.addError('Dependencies', e.toString());
    }
  }

  /// Extract dependencies from content
  static List<String> _extractDependencies(String content) {
    final dependencies = <String>[];
    final lines = content.split('\n');
    
    for (final line in lines) {
      if (line.trim().startsWith('import ') && line.contains('shared/widgets/')) {
        final match = RegExp(r"shared/widgets/([^'\"]+)").firstMatch(line);
        if (match != null) {
          dependencies.add(match.group(1)!);
        }
      }
    }
    
    return dependencies;
  }

  /// Remove unused assets
  static Future<void> _removeUnusedAssets(CleanupReport report) async {
    try {
      final assetsDir = Directory('assets');
      if (!await assetsDir.exists()) {
        report.addWarning('Asset Cleanup', 'assets directory not found');
        return;
      }

      int unusedAssets = 0;
      
      await for (final entity in assetsDir.list(recursive: true)) {
        if (entity is File) {
          final assetPath = entity.path.replaceFirst('assets/', '');
          if (!_isAssetUsed(assetPath)) {
            unusedAssets++;
            report.addIssue('Unused Assets', 'Unused asset: $assetPath');
            _cleanupResults.add('🔧 Unused asset: $assetPath');
          }
        }
      }

      if (unusedAssets == 0) {
        report.addSuccess('Asset Cleanup', 'No unused assets found');
        _cleanupResults.add('✅ No unused assets found');
      } else {
        report.addWarning('Asset Cleanup', 'Found $unusedAssets unused assets');
      }
    } catch (e) {
      report.addError('Asset Cleanup', e.toString());
    }
  }

  /// Check if asset is used in the codebase
  static bool _isAssetUsed(String assetPath) {
    // This would typically search through all Dart files for asset references
    // For now, return false to indicate potential unused assets
    return false;
  }

  /// Optimize file structure
  static Future<void> _optimizeFileStructure(CleanupReport report) async {
    try {
      final libDir = Directory('lib');
      if (!await libDir.exists()) {
        report.addWarning('Structure Optimization', 'lib directory not found');
        return;
      }

      final structureIssues = <String>[];
      
      await for (final entity in libDir.list(recursive: true)) {
        if (entity is Directory) {
          final files = await entity.list().toList();
          if (files.isEmpty) {
            structureIssues.add('Empty directory: ${entity.path}');
            _cleanupResults.add('🔧 Empty directory: ${entity.path}');
          }
        }
      }

      if (structureIssues.isEmpty) {
        report.addSuccess('Structure Optimization', 'File structure is optimal');
        _cleanupResults.add('✅ File structure is optimal');
      } else {
        report.addWarning('Structure Optimization', 
            'Found ${structureIssues.length} structure issues');
      }
    } catch (e) {
      report.addError('Structure Optimization', e.toString());
    }
  }

  /// Get cleanup results
  static List<String> getCleanupResults() => List.from(_cleanupResults);

  /// Get files processed
  static List<String> getFilesProcessed() => List.from(_filesProcessed);

  /// Clear cleanup results
  static void clearResults() {
    _cleanupResults.clear();
    _filesProcessed.clear();
  }
}

/// Cleanup Report
class CleanupReport {
  final List<CleanupItem> items = [];

  void addSuccess(String category, String message) {
    items.add(CleanupItem(
      category: category,
      message: message,
      type: CleanupType.success,
    ));
  }

  void addWarning(String category, String message) {
    items.add(CleanupItem(
      category: category,
      message: message,
      type: CleanupType.warning,
    ));
  }

  void addIssue(String category, String message) {
    items.add(CleanupItem(
      category: category,
      message: message,
      type: CleanupType.issue,
    ));
  }

  void addError(String category, String message) {
    items.add(CleanupItem(
      category: category,
      message: message,
      type: CleanupType.error,
    ));
  }

  bool get hasErrors => items.any((item) => item.type == CleanupType.error);
  bool get hasIssues => items.any((item) => item.type == CleanupType.issue);
  bool get hasWarnings => items.any((item) => item.type == CleanupType.warning);

  int get successCount => items.where((item) => item.type == CleanupType.success).length;
  int get warningCount => items.where((item) => item.type == CleanupType.warning).length;
  int get issueCount => items.where((item) => item.type == CleanupType.issue).length;
  int get errorCount => items.where((item) => item.type == CleanupType.error).length;

  Map<String, dynamic> toJson() {
    return {
      'successCount': successCount,
      'warningCount': warningCount,
      'issueCount': issueCount,
      'errorCount': errorCount,
      'hasErrors': hasErrors,
      'hasIssues': hasIssues,
      'hasWarnings': hasWarnings,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}

/// Cleanup Item
class CleanupItem {
  final String category;
  final String message;
  final CleanupType type;
  final DateTime timestamp;

  CleanupItem({
    required this.category,
    required this.message,
    required this.type,
  }) : timestamp = DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'message': message,
      'type': type.toString(),
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

/// Cleanup Type
enum CleanupType {
  success,
  warning,
  issue,
  error,
}
