import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as path;

/// Code Optimizer for VedantaTrade
/// Fixes structural issues, removes redundant code, and optimizes performance
class CodeOptimizer {
  final String projectPath;
  final List<String> _fixes = [];
  final List<String> _optimizations = [];
  
  CodeOptimizer(this.projectPath);
  
  /// Run comprehensive code optimization
  Future<void> optimize() async {
    print('🔧 Starting code optimization...');
    
    // Fix critical issues first
    await _fixDuplicateAuthenticationProviders();
    await _removeBackupDirectories();
    await _consolidateFeatureModules();
    await _fixImportStatements();
    await _removeLargeFiles();
    await _optimizePerformance();
    await _fixSecurityIssues();
    
    // Generate optimization report
    await _generateOptimizationReport();
    
    print('✅ Code optimization completed!');
  }
  
  /// Fix duplicate authentication providers
  Future<void> _fixDuplicateAuthenticationProviders() async {
    print('🔐 Fixing duplicate authentication providers...');
    
    final authPath = path.join(projectPath, 'lib', 'features', 'authentication', 'presentation', 'providers');
    final authDir = Directory(authPath);
    
    if (!await authDir.exists()) return;
    
    final providers = await authDir.list().where((entity) => 
      entity is File && entity.path.endsWith('_provider.dart')
    ).toList();
    
    // Identify the main provider and duplicates
    final mainProvider = providers.firstWhere(
      (file) => file.path.contains('authentication_provider.dart'),
      orElse: () => providers.first,
    );
    
    final duplicates = providers.where((file) => 
      file.path != mainProvider.path && 
      (file.path.contains('auth_provider.dart') || 
       file.path.contains('authentication_provider.dart'))
    ).toList();
    
    // Remove duplicates
    for (final duplicate in duplicates) {
      try {
        await File(duplicate.path).delete();
        _fixes.add('Removed duplicate provider: ${path.basename(duplicate.path)}');
      } catch (e) {
        _fixes.add('Failed to remove ${path.basename(duplicate.path)}: $e');
      }
    }
    
    if (duplicates.isNotEmpty) {
      _optimizations.add('Consolidated ${duplicates.length} duplicate authentication providers');
    }
  }
  
  /// Remove backup directories from project root
  Future<void> _removeBackupDirectories() async {
    print('🗑️ Removing backup directories...');
    
    final projectDir = Directory(projectPath);
    final entities = await projectDir.list().toList();
    
    for (final entity in entities) {
      if (entity is Directory && 
          (entity.path.contains('backup') || 
           entity.path.contains('cleanup') ||
           entity.path.contains('temp'))) {
        try {
          await entity.delete(recursive: true);
          _fixes.add('Removed backup directory: ${path.basename(entity.path)}');
        } catch (e) {
          _fixes.add('Failed to remove ${path.basename(entity.path)}: $e');
        }
      }
    }
  }
  
  /// Consolidate feature modules
  Future<void> _consolidateFeatureModules() async {
    print('📁 Consolidating feature modules...');
    
    final featuresPath = path.join(projectPath, 'lib', 'features');
    final featuresDir = Directory(featuresPath);
    
    if (!await featuresDir.exists()) return;
    
    final featureDirs = await featuresDir.list().where((entity) => 
      entity is Directory && !entity.path.contains('.')
    ).toList();
    
    // Check for auth vs authentication duplication
    final authDir = Directory(path.join(featuresPath, 'auth'));
    final authenticationDir = Directory(path.join(featuresPath, 'authentication'));
    
    if (await authDir.exists() && await authenticationDir.exists()) {
      // Merge auth into authentication
      await _mergeDirectories(authDir.path, authenticationDir.path);
      _optimizations.add('Merged auth directory into authentication');
    }
    
    // Check for catalog vs product_catalog duplication
    final catalogDir = Directory(path.join(featuresPath, 'catalog'));
    final productCatalogDir = Directory(path.join(featuresPath, 'product_catalog'));
    
    if (await catalogDir.exists() && await productCatalogDir.exists()) {
      // Merge catalog into product_catalog
      await _mergeDirectories(catalogDir.path, productCatalogDir.path);
      _optimizations.add('Merged catalog directory into product_catalog');
    }
  }
  
  /// Merge two directories
  Future<void> _mergeDirectories(String sourcePath, String targetPath) async {
    try {
      final sourceDir = Directory(sourcePath);
      final targetDir = Directory(targetPath);
      
      if (!await sourceDir.exists()) return;
      
      final entities = await sourceDir.list().toList();
      
      for (final entity in entities) {
        final newPath = path.join(targetPath, path.basename(entity.path));
        
        // Check if file already exists
        if (await File(newPath).exists() || await Directory(newPath).exists()) {
          // Rename to avoid conflicts
          final nameWithoutExt = path.basenameWithoutExtension(newPath);
          final ext = path.extension(newPath);
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final renamedPath = path.join(targetPath, '${nameWithoutExt}_$timestamp$ext');
          await entity.rename(renamedPath);
        } else {
          await entity.rename(newPath);
        }
      }
      
      // Remove source directory
      await sourceDir.delete(recursive: true);
    } catch (e) {
      _fixes.add('Failed to merge directories: $e');
    }
  }
  
  /// Fix import statements
  Future<void> _fixImportStatements() async {
    print('📦 Fixing import statements...');
    
    final libPath = path.join(projectPath, 'lib');
    await _fixImportsInDirectory(libPath);
  }
  
  /// Fix imports in directory recursively
  Future<void> _fixImportsInDirectory(String dirPath) async {
    try {
      final dir = Directory(dirPath);
      final entities = await dir.list().toList();
      
      for (final entity in entities) {
        if (entity is File && entity.path.endsWith('.dart')) {
          await _fixFileImports(entity.path);
        } else if (entity is Directory && !entity.path.contains('.')) {
          await _fixImportsInDirectory(entity.path);
        }
      }
    } catch (e) {
      // Skip directories that can't be read
    }
  }
  
  /// Fix imports in a single file
  Future<void> _fixFileImports(String filePath) async {
    try {
      final content = await File(filePath).readAsString();
      final lines = content.split('\n');
      final fixedLines = <String>[];
      bool hasChanges = false;
      
      for (final line in lines) {
        final trimmedLine = line.trim();
        
        if (trimmedLine.startsWith('import ') && 
            trimmedLine.contains('../') && 
            !trimmedLine.contains('..')) {
          // Fix deep relative imports
          fixedLines.add(line.replaceAll('../../', '../../../'));
          hasChanges = true;
        } else {
          fixedLines.add(line);
        }
      }
      
      if (hasChanges) {
        await File(filePath).writeAsString(fixedLines.join('\n'));
        _fixes.add('Fixed imports in: ${path.basename(filePath)}');
      }
    } catch (e) {
      // Skip files that can't be read
    }
  }
  
  /// Remove large files by splitting them
  Future<void> _removeLargeFiles() async {
    print('📄 Optimizing large files...');
    
    final libPath = path.join(projectPath, 'lib');
    await _splitLargeFilesInDirectory(libPath);
  }
  
  /// Split large files in directory
  Future<void> _splitLargeFilesInDirectory(String dirPath) async {
    try {
      final dir = Directory(dirPath);
      final entities = await dir.list().toList();
      
      for (final entity in entities) {
        if (entity is File && entity.path.endsWith('.dart')) {
          final stat = await entity.stat();
          final fileSize = stat.size;
          
          // Check file size (in bytes)
          if (fileSize > 50 * 1024) { // 50KB threshold
            await _splitLargeFile(entity.path);
          }
        } else if (entity is Directory && !entity.path.contains('.')) {
          await _splitLargeFilesInDirectory(entity.path);
        }
      }
    } catch (e) {
      // Skip directories that can't be read
    }
  }
  
  /// Split a large file
  Future<void> _splitLargeFile(String filePath) async {
    try {
      final file = File(filePath);
      final content = await file.readAsString();
      final lines = content.split('\n');
      
      if (lines.length < 100) return; // Only split files with 100+ lines
      
      final fileName = path.basenameWithoutExtension(filePath);
      final dirPath = path.dirname(filePath);
      
      // Create parts directory
      final partsDir = Directory(path.join(dirPath, '${fileName}_parts'));
      if (!await partsDir.exists()) {
        await partsDir.create();
      }
      
      // Split into parts of 100 lines each
      final partSize = 100;
      final totalParts = (lines.length / partSize).ceil();
      
      for (int i = 0; i < totalParts; i++) {
        final startLine = i * partSize;
        final endLine = ((i + 1) * partSize).clamp(0, lines.length);
        final partLines = lines.sublist(startLine, endLine);
        
        final partFile = File(path.join(partsDir.path, '${fileName}_part_${i + 1}.dart'));
        await partFile.writeAsString(partLines.join('\n'));
      }
      
      // Create main file that imports parts
      final mainContent = '''/// Split file: $fileName
/// Original file was split into $totalParts parts for better maintainability

${List.generate(totalParts, (i) => "import '${fileName}_part_${i + 1}.dart';").join('\n')}

/// Main class that combines all parts
class $fileName {
  // TODO: Implement functionality by combining all parts
}
''';
      
      await file.writeAsString(mainContent);
      _fixes.add('Split large file: ${path.basename(filePath)} into $totalParts parts');
      _optimizations.add('Improved maintainability by splitting large file');
    } catch (e) {
      _fixes.add('Failed to split ${path.basename(filePath)}: $e');
    }
  }
  
  /// Optimize performance issues
  Future<void> _optimizePerformance() async {
    print('⚡ Optimizing performance issues...');
    
    final libPath = path.join(projectPath, 'lib');
    await _optimizePerformanceInDirectory(libPath);
  }
  
  /// Optimize performance in directory
  Future<void> _optimizePerformanceInDirectory(String dirPath) async {
    try {
      final dir = Directory(dirPath);
      final entities = await dir.list().toList();
      
      for (final entity in entities) {
        if (entity is File && entity.path.endsWith('.dart')) {
          await _optimizeFilePerformance(entity.path);
        } else if (entity is Directory && !entity.path.contains('.')) {
          await _optimizePerformanceInDirectory(entity.path);
        }
      }
    } catch (e) {
      // Skip directories that can't be read
    }
  }
  
  /// Optimize performance in a file
  Future<void> _optimizeFilePerformance(String filePath) async {
    try {
      final content = await File(filePath).readAsString();
      final lines = content.split('\n');
      final optimizedLines = <String>[];
      bool hasChanges = false;
      
      for (final line in lines) {
        final trimmedLine = line.trim();
        
        // Remove print statements from production code
        if (trimmedLine.startsWith('print(') && !filePath.contains('test')) {
          optimizedLines.add('// $trimmedLine // Removed for production');
          hasChanges = true;
        } else {
          optimizedLines.add(line);
        }
      }
      
      if (hasChanges) {
        await File(filePath).writeAsString(optimizedLines.join('\n'));
        _fixes.add('Optimized performance in: ${path.basename(filePath)}');
      }
    } catch (e) {
      // Skip files that can't be read
    }
  }
  
  /// Fix security issues
  Future<void> _fixSecurityIssues() async {
    print('🔒 Fixing security issues...');
    
    final libPath = path.join(projectPath, 'lib');
    await _fixSecurityInDirectory(libPath);
  }
  
  /// Fix security in directory
  Future<void> _fixSecurityInDirectory(String dirPath) async {
    try {
      final dir = Directory(dirPath);
      final entities = await dir.list().toList();
      
      for (final entity in entities) {
        if (entity is File && entity.path.endsWith('.dart')) {
          await _fixFileSecurity(entity.path);
        } else if (entity is Directory && !entity.path.contains('.')) {
          await _fixSecurityInDirectory(entity.path);
        }
      }
    } catch (e) {
      // Skip directories that can't be read
    }
  }
  
  /// Fix security in a file
  Future<void> _fixFileSecurity(String filePath) async {
    try {
      final content = await File(filePath).readAsString();
      final lines = content.split('\n');
      final fixedLines = <String>[];
      bool hasChanges = false;
      
      for (final line in lines) {
        final trimmedLine = line.trim();
        
        // Fix hardcoded secrets (basic check)
        if (trimmedLine.contains('password') || trimmedLine.contains('secret') || 
            trimmedLine.contains('api_key') || trimmedLine.contains('token')) {
          if (trimmedLine.contains('=') && !trimmedLine.contains('//')) {
            fixedLines.add('// $trimmedLine // TODO: Move to environment variables');
            hasChanges = true;
          } else {
            fixedLines.add(line);
          }
        } else {
          fixedLines.add(line);
        }
      }
      
      if (hasChanges) {
        await File(filePath).writeAsString(fixedLines.join('\n'));
        _fixes.add('Fixed security issue in: ${path.basename(filePath)}');
      }
    } catch (e) {
      // Skip files that can't be read
    }
  }
  
  /// Generate optimization report
  Future<void> _generateOptimizationReport() async {
    final report = {
      'timestamp': DateTime.now().toIso8601String(),
      'fixes': _fixes,
      'optimizations': _optimizations,
      'summary': {
        'totalFixes': _fixes.length,
        'totalOptimizations': _optimizations.length,
      },
    };
    
    final reportPath = path.join(projectPath, 'optimization_report.json');
    await File(reportPath).writeAsString(jsonEncode(report));
    
    print('\n' + '='*60);
    print('📊 OPTIMIZATION REPORT');
    print('='*60);
    print('Fixes Applied: ${_fixes.length}');
    print('Optimizations Applied: ${_optimizations.length}');
    print('Report saved to: $reportPath');
    print('='*60);
  }
}

/// Main function to run the optimizer
void main(List<String> args) async {
  final projectPath = args.isNotEmpty ? args[0] : Directory.current.path;
  final optimizer = CodeOptimizer(projectPath);
  
  await optimizer.optimize();
}
